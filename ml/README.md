# AgroVision Machine Learning Pipeline

**Owner / Author:** UGDS Munasinghe (Model & Dataset Training)  
**Evaluation Lead & Review Partner:** MASN Weerasinghe (Custom Data, Catalog, and Evaluation)

This directory contains the complete dataset preparation, training, quantization, and benchmarking pipeline for AgroVision's on-device leaf disease classifier.

---

## 1. Directory Structure

```
ml/
├── README.md                 # This guide & execution instructions
├── requirements.txt          # Python dependencies
├── labels_schema.md          # 18 canonical class definitions
├── MODEL_CARD.md             # Model evaluation card & specifications
├── data_sources.md           # Dataset sources, licenses, and audits
├── notebooks/                # Google Colab / Jupyter training notebooks
├── src/
│   ├── prepare_data.py       # [UGDS] PlantVillage ingest, deduplication & splitting
│   ├── train.py              # [UGDS] MobileNetV2 two-stage training pipeline
│   ├── convert_tflite.py     # [UGDS] Quantization and .tflite export
│   ├── benchmark.py          # [UGDS] Model file size and CPU latency benchmark
│   ├── prepare_custom_data.py# [MASN] Field photos & local dataset sanitation
│   └── evaluate.py           # [MASN] Confusion matrix and test-split benchmarking
└── reports/
    └── class_counts.csv      # Dataset split distributions
```

---

## 2. Requirements & Setup

Install dependencies:
```bash
pip install -r ml/requirements.txt
```

---

## 3. End-to-End Execution Guide

### Step 1: Prepare the Dataset Splits
```bash
python ml/src/prepare_data.py --raw-dir data/raw --output-dir data/processed
```
* Generates train (70%), validation (15%), and test (15%) splits with duplicate image detection.
* Exports class distribution table to `ml/reports/class_counts.csv`.

### Step 2: Train the MobileNetV2 Classifier
```bash
python ml/src/train.py --data-dir data/processed --epochs-head 10 --epochs-fine 15
```
* Uses transfer learning with MobileNetV2 ($224 \times 224 \times 3$).
* Applies strong augmentations (rotations, zoom, contrast, brightness) to handle outdoor field variance.
* Saves best checkpoint to `ml/models/best_model.keras`.

### Step 3: Convert to Quantized TensorFlow Lite
```bash
python ml/src/convert_tflite.py --keras-model ml/models/best_model.keras --output-tflite app/assets/model/model.tflite
```
* Applies post-training dynamic range quantization.
* Verifies inference divergence across 50 sample images against the Keras baseline.
* Writes model directly to `app/assets/model/model.tflite`.

### Step 4: Benchmark Performance
```bash
python ml/src/benchmark.py --model app/assets/model/model.tflite --iterations 100
```
* Verifies model size is $< 10\text{ MB}$ (hard limit: $< 25\text{ MB}$).
* Verifies CPU inference latency is $< 50\text{ ms}$.

### Step 5: Partner Evaluation Handoff (MASN)
Once your model is exported to `app/assets/model/model.tflite`, your review partner **MASN** runs:
```bash
python ml/src/evaluate.py --model app/assets/model/model.tflite --labels app/assets/model/labels.txt --data data/processed/test
```

---

## 4. Mobile Client Preprocessing Contract
The Flutter client application (`tflite_classifier.dart`) must replicate the exact preprocessing:
- **Input Dimension:** $224 \times 224$ pixels, 3 channels (RGB).
- **Pixel Range:** Normalized from $[0, 255]$ to $[-1.0, 1.0]$:
  $$\text{pixel}_{\text{norm}} = \frac{\text{pixel} - 127.5}{127.5}$$
- **Output:** Vector of 15 (v1) or 18 (v2) floats representing softmax probabilities mapped to `app/assets/model/labels.txt`.
