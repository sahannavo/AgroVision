# Disease Catalog Agronomic Sources & References

This document records the references, Department of Agriculture (DOA) Sri Lanka extension guidelines, and academic publications utilized for formulating the disease information, recommended actions, and prevention practices in `app/assets/data/disease_catalog.json`.

---

## 1. Department of Agriculture (DOA) Sri Lanka Publications

1. **Horticultural Crop Research and Development Institute (HORDI), Gannoruwa**
   - *Technical Bulletin on Solanaceous Vegetable Cultivation*: Pest and Disease Identification Guidelines for Tomato (*Solanum lycopersicum*), Chilli (*Capsicum annuum*), and Eggplant (*Solanum melongena*).
   - *Integrated Pest Management (IPM) in Protected Agriculture*: Focus on Whitefly (*Bemisia tabaci*) vectors, Two-spotted Spider Mite (*Tetranychus urticae*), and Tomato Yellow Leaf Curl Virus (TYLCV).
   - DOA Pest & Disease Advisory Portal: https://doa.gov.lk

2. **Regional Agricultural Research and Development Centre (RARDC), Bandarawela & Nuwara Eliya**
   - *Up-Country Potato Disease Management Guide*: Identification and control of Late Blight (*Phytophthora infestans*) and Early Blight (*Alternaria solani*) in potato mounds.
   - Recommended soil-hilling practices, haulm-cutting protocols 10–14 days prior to harvest, and fungicide spray timing in cool humid climates.

3. **Chilli Research Station, Mahailluppallama**
   - *Chilli Leaf Curl Complex Management Package*: Cultural control measures including 40-mesh nursery netting, reflective plastic mulching, and yellow/blue sticky trap densities.

---

## 2. International & Academic References

1. **PlantVillage Dataset & Agro-Taxonomy**
   - Hughes, D. and Salathé, M. (2015). *An open access repository of images on plant health to enable the development of mobile disease diagnostics*. arXiv:1511.08060.
   - Standard PlantVillage label classification format: `<Crop>___<Condition>`.

2. **CABI Crop Protection Compendium (CPC)**
   - *Alternaria solani* (Early blight of potato and tomato): Datasheet and global control strategies.
   - *Phytophthora infestans* (Late blight): Etiology, climate epidemiology, and host resistance.
   - *Xanthomonas campestris pv. vesicatoria* (Bacterial spot): Seed sanitation and copper-mancozeb bactericide management.

3. **University of California Statewide Integrated Pest Management Program (UC IPM)**
   - Pest Management Guidelines: Tomato, Potato, and Pepper. Focus on sanitation, crop rotation, and avoidance of overhead irrigation.

---

## 3. Catalog Formulation Principles

- **Terminology:** Clear, actionable sentences translated and simplified for smallholder farmers.
- **Safety First:** Chemical recommendations are deliberately kept generic by active compound category (e.g. *protective copper fungicide*, *mancozeb*) rather than brand names or hazardous dosage estimates.
- **Regulatory Compliance:** Every intervention explicitly reinforces: *"follow the product label and local extension advice"*.
- **Completeness:** 100% parity maintained between labels defined in `app/assets/model/labels.txt` and entries in `disease_catalog.json`.
