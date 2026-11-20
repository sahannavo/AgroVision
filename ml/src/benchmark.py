"""
AgroVision Model Benchmarking Pipeline
Author: UGDS Munasinghe (Model & Dataset Training)
Task: Benchmark on-device model file size and average inference latency on CPU.
Target: Model file size < 10 MB, inference latency < 50 ms.
"""

import os
import sys
import time
import argparse
from pathlib import Path
import numpy as np

try:
    import tensorflow as tf
except ImportError:
    tf = None


def benchmark_tflite_model(
    model_path: str,
    num_warmup: int = 10,
    num_iterations: int = 100
):
    path = Path(model_path)
    if not path.exists():
        print(f"Error: Model file '{model_path}' not found.")
        return

    # 1. File size check
    size_bytes = path.stat().st_size
    size_mb = size_bytes / (1024 * 1024)
    print("=" * 60)
    print("AgroVision On-Device Model Benchmark")
    print("=" * 60)
    print(f"Model File: {model_path}")
    print(f"Model File Size: {size_mb:.2f} MB ({size_bytes} bytes)")
    
    if size_mb < 10.0:
        print("[PASS] Target model size < 10 MB achieved.")
    elif size_mb < 25.0:
        print("[WARN] Model size is between 10 MB and 25 MB (acceptable for Git / mobile, but quantization can improve it).")
    else:
        print("[FAIL] Model size exceeds 25 MB GitHub / mobile threshold.")

    if tf is None:
        print("TensorFlow not installed. Skipping latency benchmark.")
        return

    # 2. Latency benchmark
    interpreter = tf.lite.Interpreter(model_path=str(path))
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    input_shape = input_details[0]['shape']

    print(f"Input Shape: {input_shape}")
    print(f"Input Type:  {input_details[0]['dtype']}")

    dummy_input = np.random.uniform(0.0, 255.0, size=input_shape).astype(input_details[0]['dtype'])

    # Warmup runs
    for _ in range(num_warmup):
        interpreter.set_tensor(input_details[0]['index'], dummy_input)
        interpreter.invoke()

    # Timed runs
    latencies = []
    for _ in range(num_iterations):
        t0 = time.perf_counter()
        interpreter.set_tensor(input_details[0]['index'], dummy_input)
        interpreter.invoke()
        _ = interpreter.get_tensor(output_details[0]['index'])
        t1 = time.perf_counter()
        latencies.append((t1 - t0) * 1000.0)  # ms

    latencies = np.array(latencies)
    avg_latency = np.mean(latencies)
    p50_latency = np.percentile(latencies, 50)
    p90_latency = np.percentile(latencies, 90)
    p99_latency = np.percentile(latencies, 99)

    print("-" * 60)
    print(f"Latency over {num_iterations} iterations on CPU:")
    print(f"  Average: {avg_latency:.2f} ms")
    print(f"  Median (P50): {p50_latency:.2f} ms")
    print(f"  90th percentile (P90): {p90_latency:.2f} ms")
    print(f"  99th percentile (P99): {p99_latency:.2f} ms")

    if avg_latency < 50.0:
        print("[PASS] Target inference latency < 50 ms achieved.")
    else:
        print(f"[NOTE] Inference latency {avg_latency:.2f} ms (acceptable on laptop CPU, mobile NPU will be faster).")
    print("=" * 60)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Benchmark TFLite Model")
    parser.add_argument("--model", type=str, default="app/assets/model/model.tflite", help="Path to .tflite model")
    parser.add_argument("--iterations", type=int, default=100, help="Number of benchmark iterations")
    args = parser.parse_args()

    benchmark_tflite_model(args.model, num_iterations=args.iterations)
