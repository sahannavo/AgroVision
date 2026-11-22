"""
AgroVision PlantVillage Baseline Dataset Preparation Pipeline
Author: UGDS Munasinghe (Model & Dataset Training)
Task: Download or ingest PlantVillage dataset, filter for nightshade classes,
sanitize/deduplicate images, and partition into train/val/test splits without leakage.
"""

import os
import sys
import shutil
import hashlib
import csv
from pathlib import Path
from typing import Dict, List, Tuple

try:
    from PIL import Image
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

TARGET_SIZE = (224, 224)
SUPPORTED_EXTS = {".jpg", ".jpeg", ".png", ".webp"}

BASELINE_15_CLASSES = [
    "Tomato___Early_blight",
    "Tomato___Late_blight",
    "Tomato___Bacterial_spot",
    "Tomato___Leaf_Mold",
    "Tomato___Septoria_leaf_spot",
    "Tomato___Spider_mites_Two-spotted_spider_mite",
    "Tomato___Target_Spot",
    "Tomato___Tomato_Yellow_Leaf_Curl_Virus",
    "Tomato___Tomato_mosaic_virus",
    "Tomato___healthy",
    "Potato___Early_blight",
    "Potato___Late_blight",
    "Potato___healthy",
    "Pepper___Bacterial_spot",
    "Pepper___healthy",
]


def compute_file_hash(filepath: Path) -> str:
    """Computes SHA-256 hash to detect exact duplicate images."""
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(8192):
            hasher.update(chunk)
    return hasher.hexdigest()


def prepare_dataset_splits(
    raw_dir: Path,
    output_dir: Path,
    train_ratio: float = 0.70,
    val_ratio: float = 0.15,
    test_ratio: float = 0.15,
) -> Dict[str, Dict[str, int]]:
    """
    Partitions raw images into train, val, and test splits with deduplication.
    """
    assert abs((train_ratio + val_ratio + test_ratio) - 1.0) < 1e-5, "Ratios must sum to 1.0"

    splits = ["train", "val", "test"]
    for split in splits:
        for cls in BASELINE_15_CLASSES:
            (output_dir / split / cls).mkdir(parents=True, exist_ok=True)

    seen_hashes = set()
    stats = {split: {cls: 0 for cls in BASELINE_15_CLASSES} for split in splits}

    for cls in BASELINE_15_CLASSES:
        src_cls_dir = raw_dir / cls
        if not src_cls_dir.exists():
            print(f"[WARN] Class folder not found in raw data: {src_cls_dir}")
            continue

        images = [p for p in src_cls_dir.iterdir() if p.suffix.lower() in SUPPORTED_EXTS]
        valid_images = []

        for img_path in images:
            h = compute_file_hash(img_path)
            if h in seen_hashes:
                continue
            seen_hashes.add(h)
            valid_images.append(img_path)

        n = len(valid_images)
        n_train = int(n * train_ratio)
        n_val = int(n * val_ratio)

        train_imgs = valid_images[:n_train]
        val_imgs = valid_images[n_train:n_train + n_val]
        test_imgs = valid_images[n_train + n_val:]

        for split, img_list in [("train", train_imgs), ("val", val_imgs), ("test", test_imgs)]:
            for img_p in img_list:
                dest = output_dir / split / cls / img_p.name
                shutil.copy2(img_p, dest)
                stats[split][cls] += 1

        print(f"Processed {cls}: {len(train_imgs)} train, {len(val_imgs)} val, {len(test_imgs)} test")

    return stats


def export_class_counts_csv(stats: Dict[str, Dict[str, int]], report_path: Path):
    """Exports class split distribution table to CSV."""
    report_path.parent.mkdir(parents=True, exist_ok=True)
    with open(report_path, mode="w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Class", "Train", "Val", "Test", "Total"])
        for cls in BASELINE_15_CLASSES:
            tr = stats["train"].get(cls, 0)
            va = stats["val"].get(cls, 0)
            te = stats["test"].get(cls, 0)
            writer.writerow([cls, tr, va, te, tr + va + te])
    print(f"Report exported to {report_path}")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="AgroVision Data Preparation Pipeline")
    parser.add_argument("--raw-dir", type=str, default="data/raw", help="Path to raw PlantVillage dataset")
    parser.add_argument("--output-dir", type=str, default="data/processed", help="Path for output splits")
    parser.add_argument("--report", type=str, default="ml/reports/class_counts.csv", help="Path for report CSV")
    args = parser.parse_args()

    raw_path = Path(args.raw_dir)
    out_path = Path(args.output_dir)
    rep_path = Path(args.report)

    if not raw_path.exists():
        print(f"Raw directory '{raw_path}' does not exist. Please place raw dataset there.")
        sys.exit(0)

    print("Starting dataset preparation & splitting...")
    summary = prepare_dataset_splits(raw_path, out_path)
    export_class_counts_csv(summary, rep_path)
    print("Done!")
