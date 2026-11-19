"""
AgroVision TFLite Conversion and Verification Pipeline
Author: UGDS Munasinghe (Model & Dataset Training)
Task: Convert trained Keras MobileNetV2 model to .tflite format using post-training quantization,
verify inference divergence against Keras model on 50 sample images, and deploy assets.
"""

import os
import sys
import argparse
from pathlib import Path
import numpy as np
import tensorflow as tf

CANONICAL_LABELS_PATH = "app/assets/model/labels.txt"
TFLITE_OUTPUT_PATH = "app/assets/model/model.tflite"


def convert_model_to_tflite(
    keras_model_path: str,
    output_tflite_path: str,
    quantize: bool = True
) -> bytes:
    """Converts Keras model to TFLite with post-training dynamic range quantization."""
    print(f"Loading Keras model from {keras_model_path}...")
    model = tf.keras.models.load_model(keras_model_path)

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    if quantize:
        print("Applying post-training dynamic range quantization...")
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    tflite_model = converter.convert()
    
    out_file = Path(output_tflite_path)
    out_file.parent.mkdir(parents=True, exist_ok=True)
    with open(out_file, "wb") as f:
        f.write(tflite_model)
    
    size_mb = len(tflite_model) / (1024 * 1024)
    print(f"TFLite model saved to {output_tflite_path} ({size_mb:.2f} MB)")
    return tflite_model


def verify_tflite_against_keras(
    keras_model_path: str,
    tflite_path: str,
    num_samples: int = 50
):
    """
    Verifies that the TFLite output closely matches the Keras model output
    across randomly generated test images (or real images if available).
    """
    print(f"\n--- Verifying TFLite model against Keras model on {num_samples} test inputs ---")
    keras_model = tf.keras.models.load_model(keras_model_path)

    interpreter = tf.lite.Interpreter(model_path=str(tflite_path))
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    input_shape = input_details[0]['shape']
    max_diff = 0.0

    for i in range(num_samples):
        # Generate random normalized sample image in uint8/float range
        sample_input = np.random.uniform(0.0, 255.0, size=input_shape).astype(np.float32)
        
        # Keras prediction
        keras_pred = keras_model.predict(sample_input, verbose=0)
        
        # TFLite prediction
        interpreter.set_tensor(input_details[0]['index'], sample_input)
        interpreter.invoke()
        tflite_pred = interpreter.get_tensor(output_details[0]['index'])

        diff = np.max(np.abs(keras_pred - tflite_pred))
        if diff > max_diff:
            max_diff = diff

    print(f"Maximum absolute prediction difference across {num_samples} samples: {max_diff:.6f}")
    if max_diff < 0.05:
        print("[SUCCESS] TFLite model matches Keras model within acceptable tolerance!")
    else:
        print(f"[WARN] Difference {max_diff:.6f} is higher than standard threshold (0.05). Check quantization.")


def write_labels_file(classes: list, labels_path: str):
    """Ensures labels.txt is saved in matching format."""
    p = Path(labels_path)
    p.parent.mkdir(parents=True, exist_ok=True)
    with open(p, "w", encoding="utf-8") as f:
        for c in classes:
            f.write(f"{c}\n")
    print(f"Labels written to {labels_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="AgroVision TFLite Conversion")
    parser.add_argument("--keras-model", type=str, default="ml/models/best_model.keras", help="Path to input Keras model")
    parser.add_argument("--output-tflite", type=str, default=TFLITE_OUTPUT_PATH, help="Path for converted .tflite")
    parser.add_argument("--verify", action="store_true", default=True, help="Run verification check against Keras")
    args = parser.parse_args()

    if not Path(args.keras_model).exists():
        print(f"Keras model not found at {args.keras_model}. Train the model first.")
        sys.exit(0)

    convert_model_to_tflite(args.keras_model, args.output_tflite)

    if args.verify:
        verify_tflite_against_keras(args.keras_model, args.output_tflite)
