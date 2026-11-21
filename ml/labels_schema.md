# AgroVision Machine Learning Class Labels Schema

This document is the **single source of truth** for all foliar disease classification labels used in AgroVision across the machine learning pipeline, TensorFlow Lite model, Flutter client application, and Firebase backend.

## 1. Label Format Specification

All class labels strictly follow the canonical naming convention:
```
<Crop>___<Condition>
```
* Three underscores (`___`) separate the crop name from the specific pathology or healthy condition.
* Capitalization is strictly preserved as written.
* Words within the condition are separated by a single underscore (`_`).

---

## 2. Baseline Model v1 (15 PlantVillage Classes)
Trained by **UGDS (Savindi)** on the baseline PlantVillage dataset (*Solanaceae* subset):

| Index | Canonical Label | Common Name / Pathology | Crop Family |
| :---: | :--- | :--- | :--- |
| 0 | `Tomato___Early_blight` | Tomato Early Blight (*Alternaria solani*) | Tomato (*Solanum lycopersicum*) |
| 1 | `Tomato___Late_blight` | Tomato Late Blight (*Phytophthora infestans*) | Tomato (*Solanum lycopersicum*) |
| 2 | `Tomato___Bacterial_spot` | Tomato Bacterial Spot (*Xanthomonas*) | Tomato (*Solanum lycopersicum*) |
| 3 | `Tomato___Leaf_Mold` | Tomato Leaf Mold (*Passalora fulva*) | Tomato (*Solanum lycopersicum*) |
| 4 | `Tomato___Septoria_leaf_spot` | Tomato Septoria Leaf Spot (*Septoria lycopersici*) | Tomato (*Solanum lycopersicum*) |
| 5 | `Tomato___Spider_mites_Two-spotted_spider_mite` | Two-spotted Spider Mite infestation | Tomato (*Solanum lycopersicum*) |
| 6 | `Tomato___Target_Spot` | Tomato Target Spot (*Corynespora cassiicola*) | Tomato (*Solanum lycopersicum*) |
| 7 | `Tomato___Tomato_Yellow_Leaf_Curl_Virus` | Tomato Yellow Leaf Curl Virus (TYLCV) | Tomato (*Solanum lycopersicum*) |
| 8 | `Tomato___Tomato_mosaic_virus` | Tomato Mosaic Virus (ToMV) | Tomato (*Solanum lycopersicum*) |
| 9 | `Tomato___healthy` | Healthy Tomato Foliage | Tomato (*Solanum lycopersicum*) |
| 10 | `Potato___Early_blight` | Potato Early Blight (*Alternaria solani*) | Potato (*Solanum tuberosum*) |
| 11 | `Potato___Late_blight` | Potato Late Blight (*Phytophthora infestans*) | Potato (*Solanum tuberosum*) |
| 12 | `Potato___healthy` | Healthy Potato Foliage | Potato (*Solanum tuberosum*) |
| 13 | `Pepper___Bacterial_spot` | Bell Pepper Bacterial Spot (*Xanthomonas campestris*) | Pepper (*Capsicum annuum*) |
| 14 | `Pepper___healthy` | Healthy Pepper Foliage | Pepper (*Capsicum annuum*) |

---

## 3. Extended Model v2 (18 Canonical Classes)
Incorporates the 3 additional classes curated by **MASN (Sahan)** for local Sri Lankan nightshade cultivation:

| Index | Canonical Label | Common Name / Pathology | Source Dataset |
| :---: | :--- | :--- | :--- |
| 15 | `Chilli___Leaf_curl` | Chilli Leaf Curl Virus | Chilli Leaf Disease Dataset |
| 16 | `Eggplant___healthy` | Healthy Brinjal / Eggplant | Brinjal Leaf Disease Dataset |
| 17 | `General___Nitrogen_deficiency` | Foliar Nitrogen (N) Deficiency Chlorosis | Tomato NPK Deficiency Dataset |

---

## 4. Verification Checksum
* `app/assets/model/labels.txt` matches this exact order line-by-line.
* `app/assets/data/disease_catalog.json` contains entries mapped to these exact keys.
* The Flutter app `DiagnosisClassifier` relies on this 0-indexed output mapping.
