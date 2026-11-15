"""
AgroVision Custom Data Preparation Pipeline
Author: MASN Weerasinghe (ML Data & Evaluation)
Task: Preprocess, sanitize, resize, and split datasets into canonical classes without data leakage.
"""

import os
import sys
import shutil
import hashlib
import csv
from pathlib import Path
from typing import Dict, List, Set, Tuple

# Optional PIL import for image manipulation
try:
    from PIL import Image, ImageOps, UnidentifiedImageError
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

TARGET_SIZE = (224, 224)
SUPPORTED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}

CANONICAL_CLASSES = [
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
    "Chilli___Leaf_curl",
    "Eggplant___healthy",
    "General___Nitrogen_deficiency",
]


def compute_file_hash(filepath: Path) -> str:
    """Computes SHA-256 hash of a file to identify exact duplicate images."""
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    return hasher.hexdigest()


def verify_and_resize_image(src_path: Path, dest_path: Path, target_size: Tuple[int, int] = TARGET_SIZE) -> bool:
    """
    Validates that the file is an intact image, resizes it to target_size (224x224),
    and saves it to dest_path as RGB. Returns True if successful.
    """
    if not HAS_PIL:
        # Fallback if PIL is not installed in the environment: copy directly
        shutil.copy2(src_path, dest_path)
        return True

    try:
        with Image.open(src_path) as img:
            img.verify()

        # Reopen after verify
        with Image.open(src_path) as img:
            img = ImageOps.exif_transpose(img)
            img = img.convert("RGB")
            img = img.resize(target_size, Image.Resampling.BILINEAR)
            dest_path.parent.mkdir(parents=True, exist_ok=True)
            img.save(dest_path, "JPEG", quality=90)
        return True
    except Exception as e:
        print(f"[Corrupted/Skipped] Could not process {src_path}: {e}")
        return False


def build_splits(
    raw_dir: Path,
    output_dir: Path,
    field_photos_dir: Path,
    reports_dir: Path,
    train_ratio: float = 0.70,
    val_ratio: float = 0.15,
    test_ratio: float = 0.15,
) -> None:
    """
    Scans raw dataset folders, removes duplicates, resizes images, and writes
    leak-free train, val, and test splits. Real field phone photos are strictly
    isolated to the test split only.
    """
    print(f"[*] Initializing AgroVision Custom Data Pipeline...")
    output_dir.mkdir(parents=True, exist_ok=True)
    reports_dir.mkdir(parents=True, exist_ok=True)

    splits = ["train", "val", "test"]
    for s in splits:
        for c in CANONICAL_CLASSES:
            (output_dir / s / c).mkdir(parents=True, exist_ok=True)

    seen_hashes: Set[str] = set()
    class_counts: Dict[str, Dict[str, int]] = {
        c: {"train": 0, "val": 0, "test": 0, "field_test": 0, "total": 0}
        for c in CANONICAL_CLASSES
    }

    # 1. Process Raw/Lab Datasets
    if raw_dir.exists():
        print(f"[*] Scanning base and custom dataset directory: {raw_dir}")
        for cls_name in CANONICAL_CLASSES:
            cls_folder = raw_dir / cls_name
            if not cls_folder.exists():
                continue

            valid_images: List[Path] = []
            for file_path in cls_folder.rglob("*"):
                if file_path.suffix.lower() in SUPPORTED_EXTENSIONS and file_path.is_file():
                    f_hash = compute_file_hash(file_path)
                    if f_hash in seen_hashes:
                        continue  # Skip duplicate image
                    seen_hashes.add(f_hash)
                    valid_images.append(file_path)

            # Deterministic split sorting
            valid_images.sort(key=lambda p: p.name)
            total = len(valid_images)
            n_train = int(total * train_ratio)
            n_val = int(total * val_ratio)

            train_imgs = valid_images[:n_train]
            val_imgs = valid_images[n_train:n_train + n_val]
            test_imgs = valid_images[n_train + n_val:]

            for img in train_imgs:
                dest = output_dir / "train" / cls_name / f"{img.stem}.jpg"
                if verify_and_resize_image(img, dest):
                    class_counts[cls_name]["train"] += 1

            for img in val_imgs:
                dest = output_dir / "val" / cls_name / f"{img.stem}.jpg"
                if verify_and_resize_image(img, dest):
                    class_counts[cls_name]["val"] += 1

            for img in test_imgs:
                dest = output_dir / "test" / cls_name / f"{img.stem}.jpg"
                if verify_and_resize_image(img, dest):
                    class_counts[cls_name]["test"] += 1

    # 2. Ingest Field Phone Photos (Strictly to test split only)
    if field_photos_dir.exists():
        print(f"[*] Ingesting team smartphone field photos from: {field_photos_dir}")
        for cls_name in CANONICAL_CLASSES:
            cls_field_dir = field_photos_dir / cls_name
            if not cls_field_dir.exists():
                continue

            for file_path in cls_field_dir.rglob("*"):
                if file_path.suffix.lower() in SUPPORTED_EXTENSIONS and file_path.is_file():
                    f_hash = compute_file_hash(file_path)
                    if f_hash in seen_hashes:
                        continue
                    seen_hashes.add(f_hash)
                    dest = output_dir / "test" / cls_name / f"field_{file_path.stem}.jpg"
                    if verify_and_resize_image(file_path, dest):
                        class_counts[cls_name]["test"] += 1
                        class_counts[cls_name]["field_test"] += 1

    # Calculate totals
    for c in CANONICAL_CLASSES:
        class_counts[c]["total"] = (
            class_counts[c]["train"] + class_counts[c]["val"] + class_counts[c]["test"]
        )

    # 3. Export class_counts.csv
    csv_path = reports_dir / "class_counts.csv"
    with open(csv_path, mode="w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["canonical_class", "train_count", "val_count", "test_count", "field_test_photos", "total_samples"])
        for c in CANONICAL_CLASSES:
            counts = class_counts[c]
            writer.writerow([
                c,
                counts["train"],
                counts["val"],
                counts["test"],
                counts["field_test"],
                counts["total"],
            ])

    print(f"[✔] Class distribution report exported to: {csv_path}")
    print(f"[✔] Custom data processing pipeline completed successfully.")


if __name__ == "__main__":
    base_ml_dir = Path(__file__).resolve().parent.parent
    raw_data_dir = base_ml_dir / "data" / "raw"
    processed_dir = base_ml_dir / "data" / "processed"
    field_data_dir = base_ml_dir / "data" / "field_test_photos"
    reports_out = base_ml_dir / "reports"

    build_splits(
        raw_dir=raw_data_dir,
        output_dir=processed_dir,
        field_photos_dir=field_data_dir,
        reports_dir=reports_out,
    )

