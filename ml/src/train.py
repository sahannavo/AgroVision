"""
AgroVision MobileNetV2 Baseline Model Training Pipeline
Author: UGDS Munasinghe (Model & Dataset Training)
Task: Train MobileNetV2 on nightshade leaf disease classes with strong data augmentation,
class weight balancing, and two-stage fine-tuning.
"""

import os
import sys
import json
import argparse
from pathlib import Path
from typing import Dict, Tuple

import tensorflow as tf
from tensorflow.keras import layers, models, callbacks, optimizers
import numpy as np

IMG_SIZE = (224, 224)
BATCH_SIZE = 32
RANDOM_SEED = 42

tf.random.set_seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)


def get_data_augmentation():
    """Builds robust data augmentation pipeline for outdoor illumination & orientation invariance."""
    return tf.keras.Sequential([
        layers.RandomFlip("horizontal_and_vertical"),
        layers.RandomRotation(0.2),
        layers.RandomZoom(0.15),
        layers.RandomContrast(0.2),
        layers.RandomBrightness(0.2),
    ], name="data_augmentation")


def build_model(num_classes: int = 15) -> Tuple[tf.keras.Model, tf.keras.Model]:
    """
    Constructs transfer learning model using pre-trained MobileNetV2.
    Returns (full_model, base_model).
    """
    inputs = layers.Input(shape=(224, 224, 3), name="input_image")
    
    # Preprocessing: MobileNetV2 expects [-1, 1] range
    x = layers.Rescaling(scale=1./127.5, offset=-1.0)(inputs)
    x = get_data_augmentation()(x)

    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(224, 224, 3),
        include_top=False,
        weights="imagenet",
        alpha=1.0
    )
    base_model.trainable = False

    x = base_model(x, training=False)
    x = layers.GlobalAveragePooling2D(name="global_avg_pool")(x)
    x = layers.Dropout(0.2, name="dropout")(x)
    outputs = layers.Dense(num_classes, activation="softmax", name="predictions")(x)

    model = models.Model(inputs=inputs, outputs=outputs, name="AgroVision_MobileNetV2")
    return model, base_model


def compute_class_weights(dataset) -> Dict[int, float]:
    """Calculates class weights from dataset for imbalanced classes."""
    labels = []
    for _, y in dataset:
        labels.extend(np.argmax(y.numpy(), axis=-1))
    
    classes, counts = np.unique(labels, return_counts=True)
    total = len(labels)
    n_classes = len(classes)
    
    weights = {c: total / (n_classes * count) for c, count in zip(classes, counts)}
    return weights


def train(
    data_dir: str,
    epochs_head: int = 10,
    epochs_fine: int = 15,
    output_dir: str = "ml/models",
    config_out: str = "ml/models/model_config.json"
):
    data_path = Path(data_dir)
    train_dir = data_path / "train"
    val_dir = data_path / "val"

    if not train_dir.exists() or not val_dir.exists():
        print(f"Dataset directories not found under {data_path}. Please check data split paths.")
        return

    train_ds = tf.keras.utils.image_dataset_from_directory(
        train_dir,
        image_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        label_mode="categorical",
        shuffle=True,
        seed=RANDOM_SEED
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        val_dir,
        image_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        label_mode="categorical",
        shuffle=False
    )

    class_names = train_ds.class_names
    num_classes = len(class_names)
    print(f"Training for {num_classes} classes: {class_names}")

    # Optimize pipeline throughput
    AUTOTUNE = tf.data.AUTOTUNE
    train_ds = train_ds.prefetch(buffer_size=AUTOTUNE)
    val_ds = val_ds.prefetch(buffer_size=AUTOTUNE)

    model, base_model = build_model(num_classes=num_classes)
    
    model.compile(
        optimizer=optimizers.Adam(learning_rate=1e-3),
        loss="categorical_crossentropy",
        metrics=["accuracy", tf.keras.metrics.TopKCategoricalAccuracy(k=3, name="top_3_accuracy")]
    )

    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)
    checkpoint_path = out_path / "best_model.keras"

    early_stopping = callbacks.EarlyStopping(
        monitor="val_accuracy",
        patience=5,
        restore_best_weights=True
    )
    checkpoint = callbacks.ModelCheckpoint(
        filepath=str(checkpoint_path),
        monitor="val_accuracy",
        save_best_only=True
    )

    print("\n--- Stage 1: Training Classification Head ---")
    history_head = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=epochs_head,
        callbacks=[early_stopping, checkpoint]
    )

    print("\n--- Stage 2: Fine-Tuning Top Convolutional Layers ---")
    base_model.trainable = True
    # Freeze the first 100 layers of MobileNetV2
    for layer in base_model.layers[:100]:
        layer.trainable = False

    model.compile(
        optimizer=optimizers.Adam(learning_rate=1e-5),
        loss="categorical_crossentropy",
        metrics=["accuracy", tf.keras.metrics.TopKCategoricalAccuracy(k=3, name="top_3_accuracy")]
    )

    history_fine = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=epochs_fine,
        callbacks=[early_stopping, checkpoint]
    )

    final_model_path = out_path / "agrovision_mobilenetv2_final.keras"
    model.save(final_model_path)
    print(f"\nModel saved successfully to {final_model_path}")

    # Write training metadata configuration
    config = {
        "model_name": "AgroVision MobileNetV2 Nightshade Foliar Classifier",
        "input_size": [224, 224, 3],
        "preprocessing": "rescaling [-1, 1]",
        "num_classes": num_classes,
        "classes": class_names,
        "random_seed": RANDOM_SEED,
        "epochs_head": epochs_head,
        "epochs_fine": epochs_fine
    }
    with open(config_out, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=4)
    print(f"Config exported to {config_out}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="AgroVision MobileNetV2 Training")
    parser.add_argument("--data-dir", type=str, default="data/processed", help="Path to processed dataset")
    parser.add_argument("--epochs-head", type=int, default=10, help="Epochs for training head")
    parser.add_argument("--epochs-fine", type=int, default=15, help="Epochs for fine-tuning")
    parser.add_argument("--output-dir", type=str, default="ml/models", help="Output directory for checkpoints")
    args = parser.parse_args()

    train(
        data_dir=args.data_dir,
        epochs_head=args.epochs_head,
        epochs_fine=args.epochs_fine,
        output_dir=args.output_dir
    )
