# Machine Learning Dataset Sources & Licensing Audit

**Project:** AgroVision (SE205.3 Mobile Application Development)  
**Author / Responsible Member:** MASN Weerasinghe (ML Data & Evaluation)  
**Target Crops:** Nightshade Family (*Solanaceae*) — Tomato (*Solanum lycopersicum*), Potato (*Solanum tuberosum*), Chilli (*Capsicum annuum*), and Eggplant (*Solanum melongena*).  
**Target Tasks:** Leaf disease detection, pest symptom classification, and nutrient deficiency recognition.

---

## 1. Executive Summary & Sourcing Strategy

The AgroVision on-device vision model is trained to support smallholder nightshade crop farmers in Sri Lanka. Because the standard **PlantVillage** dataset contains primarily lab-conditioned photographs (uniform grey/black backgrounds, leaves excised from plants, artificial lighting), deploying such a model directly to smallholder farmers causes severe domain shift and high false-confidence rates in real field environments.

To address this challenge, our dataset sourcing strategy combines:
1. **Curated Open Laboratory Datasets:** For broad baseline feature extraction of classical pathologies (e.g. Early Blight, Late Blight, Bacterial Spot).
2. **In-the-Wild / Natural Field Datasets:** Openly licensed field photographs with natural soil, weeds, variable sunlight, and morning condensation.
3. **Primary Field Photos (Team Captured):** At least 100 high-resolution smartphone photographs collected across local farming plots in Sri Lanka (Kurunegala, Kandy, Welimada), reserved strictly for the held-out test split.

---

## 2. Dataset Inventory & Licensing Matrix

| Dataset Identifier | Primary Crops & Pathologies Covered | Image Count | Image Resolution | Source & Direct URL | License | Verified Legally Usable? |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **PlantVillage** | Tomato (9 classes), Potato (3 classes), Bell Pepper (2 classes) | ~54,300 (total) / ~18,200 (Solanaceae) | $256 \times 256$ | [PlantVillage on Mendeley / TFDS](https://www.kaggle.com/datasets/emmarex/plantdisease) | CC BY-SA 4.0 | Yes |
| **Chilli Leaf Disease Dataset** | Chilli Leaf Curl Virus, Bacterial Spot, Cercospora, Healthy Chilli | ~2,500 | Variable (up to $1024 \times 1024$) | [Mendeley Data / Kaggle](https://data.mendeley.com/datasets/tywbtsjrjv/1) | CC BY 4.0 | Yes |
| **Eggplant / Brinjal Disease Dataset** | Healthy Eggplant, Phomopsis Blight, Tobacco Mosaic Virus, Little Leaf | ~1,800 | $224 \times 224$ to $512 \times 512$ | [Kaggle - Brinjal Leaf Disease](https://www.kaggle.com/datasets/siddharthkumarsah/brinjal-leaf-disease-dataset) | Apache 2.0 / CC BY 4.0 | Yes |
| **Plant Nutrient Deficiency (NPK) Dataset** | Nitrogen (N), Phosphorus (P), Potassium (K) deficiency in Tomato & Pepper | ~1,200 | High Res ($1920 \times 1080$) | [Mendeley Data - Tomato NPK Deficiency](https://data.mendeley.com/datasets/p6p3p9x3w8/1) | CC BY 4.0 | Yes |
| **AgroVision Primary Field Test Set** | Real Sri Lankan farm photos (Tomato, Chilli, Potato) in natural outdoor lighting | 120 | Native Mobile (12MP) resized to $224 \times 224$ | Primary Collection (AgroVision Team) | Academic Coursework / Open Source | Yes |

---

## 3. Class-by-Class Mapping to Canonical Labels

All collected data maps strictly to the canonical format `<Crop>___<Condition>` matching `app/assets/model/labels.txt` and `app/assets/data/disease_catalog.json`:

```
Tomato___Early_blight
Tomato___Late_blight
Tomato___Bacterial_spot
Tomato___Leaf_Mold
Tomato___Septoria_leaf_spot
Tomato___Spider_mites_Two-spotted_spider_mite
Tomato___Target_Spot
Tomato___Tomato_Yellow_Leaf_Curl_Virus
Tomato___Tomato_mosaic_virus
Tomato___healthy
Potato___Early_blight
Potato___Late_blight
Potato___healthy
Pepper___Bacterial_spot
Pepper___healthy
Chilli___Leaf_curl
Eggplant___healthy
General___Nitrogen_deficiency
```

---

## 4. Notes & Observations for Coursework Lecturer Review

1. **Licensing Compliance:**
   - Every secondary dataset used carries an open permissive academic license (Creative Commons Attribution CC-BY or Apache 2.0).
   - Full citations and attributions are maintained in `docs/disease_catalog_sources.md` and this document.
2. **Domain Adaptation & Laboratory Bias Mitigation:**
   - Standard PlantVillage images have artificial solid backgrounds. To prevent the convolutional neural network from learning background artifacts instead of foliar lesions, extensive data augmentation (random lighting shifts, color jitter, blur, and random crops) is integrated during training.
3. **Strict Test Set Quarantine (No Data Leakage):**
   - The AgroVision team's 120 mobile phone photographs are quarantined strictly inside the **test split only**. Under no circumstances are field images included in the training or validation sets, ensuring the evaluation reflects authentic generalization on smallholder farms.
4. **Handling Imbalanced Classes:**
   - Eggplant and nutrient deficiency classes possess smaller sample counts (~800–1,200 images) compared to PlantVillage Tomato (~2,000 images per class). Weighted cross-entropy loss and targeted augmentation are applied to prevent model bias towards majority classes.

