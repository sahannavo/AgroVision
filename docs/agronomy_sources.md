# Agronomy Sources & Requirement Baselines

This document provides official references, source links, and agronomic justifications for the data structures in:
- `app/assets/data/crop_requirements.json`
- `app/assets/data/irrigation_requirements.json`

Both files support the **Advisor Engine** (RMO) and the **Irrigation/Fertilizer Planner Engine** (AHMS) in AgroVision.

---

## 1. Primary Sources & Authorities

1. **Department of Agriculture (DOA), Sri Lanka**
   - Vegetable Crop Production Recommendations, Technical Bulletin Series.
   - Website: [https://doa.gov.lk](https://doa.gov.lk)
   - Crop advisory circulars on Nightshade family (*Solanaceae*): Tomato, Chilli, Potato, Eggplant.

2. **Horticultural Crop Research and Development Institute (HORDI), Gannoruwa**
   - Guidelines for Micro-irrigation and Crop Water Requirements in Sri Lanka.
   - Reference: HORDI Research Report on Drip Irrigation Scheduling for Solanaceous Crops.

3. **Natural Resources Management Center (NRMC), Peradeniya**
   - Agro-ecological Regions of Sri Lanka and Soil Classification (Reddish Brown Earths, Red-Yellow Podzolic, Sandy Regosols).
   - Website: [https://doa.gov.lk/nrmc/](https://doa.gov.lk/nrmc/)

4. **Food and Agriculture Organization (FAO) - Irrigation and Drainage Paper No. 56**
   - *Crop Evapotranspiration - Guidelines for Computing Crop Water Requirements* (Allen, R.G., Pereira, L.S., Raes, D., Smith, M.).
   - Used for stage crop coefficients ($K_c$) for Solanaceae: Seedling (0.6), Vegetative (0.8), Mid-season/Flowering (1.05–1.15), Late/Fruiting (0.8–0.9).

---

## 2. Crop Profiles & Requirements

### 2.1 Tomato (*Solanum lycopersicum*)
- **Suitable Soils**: Sandy Loam, Reddish Brown Earth (RBE), Red-Yellow Podzolic, Non-calcic Brown, Loam.
- **pH Range**: 6.0 – 7.0 (DOA Recommended).
- **Seasons**: Maha (October – March), Yala (April – September).
- **Temperature**: Optimal 20°C – 28°C; growth halts below 15°C or above 35°C.
- **Water & Fertilizer**:
  - Seedling: $14\,\text{L/m}^2/\text{week}$, Basal NPK 4:25:8.
  - Vegetative: $22\,\text{L/m}^2/\text{week}$, Urea side-dressing.
  - Flowering: $28\,\text{L/m}^2/\text{week}$, NPK 12–12–17 ($20\,\text{g/plant}$).
  - Fruiting: $32\,\text{L/m}^2/\text{week}$, Potassium supplementation.

### 2.2 Potato (*Solanum tuberosum*)
- **Suitable Soils**: Red-Yellow Podzolic, Sandy Loam, Well-drained Loam, Regosol.
- **pH Range**: 5.0 – 6.5.
- **Seasons**: Upcountry Wet/Intermediate (Badulla, Nuwara Eliya: Yala and Maha), Jaffna (Maha).
- **Temperature**: Optimal 16°C – 20°C. Night temperatures $>20^\circ\text{C}$ impede tuber initiation.
- **Water & Fertilizer**:
  - Seedling: $18\,\text{L/m}^2/\text{week}$, Basal 10:25:20.
  - Vegetative: $25\,\text{L/m}^2/\text{week}$, Urea earthing up.
  - Flowering: $32\,\text{L/m}^2/\text{week}$, SOP potassium.
  - Fruiting/Maturation: $20\,\text{L/m}^2/\text{week}$ with withholding prior to dehaulming.

### 2.3 Chilli (*Capsicum annuum*)
- **Suitable Soils**: Reddish Brown Earth (RBE), Non-calcic Brown, Sandy Loam, Alluvial.
- **pH Range**: 6.0 – 6.8.
- **Seasons**: Maha and Yala (Dry and Intermediate zones).
- **Temperature**: Optimal 22°C – 30°C.
- **Water & Fertilizer**:
  - Seedling: $12\,\text{L/m}^2/\text{week}$.
  - Vegetative: $20\,\text{L/m}^2/\text{week}$.
  - Flowering: $26\,\text{L/m}^2/\text{week}$, NPK 12–12–17 top-dress.
  - Fruiting: $28\,\text{L/m}^2/\text{week}$, MOP + Urea flush application.

### 2.4 Eggplant / Brinjal (*Solanum melongena*)
- **Suitable Soils**: Sandy Loam, Reddish Brown Earth (RBE), Loam, Clay Loam.
- **pH Range**: 5.5 – 6.8.
- **Seasons**: Maha and Yala.
- **Temperature**: Optimal 24°C – 32°C.
- **Water & Fertilizer**:
  - Seedling: $14\,\text{L/m}^2/\text{week}$, Basal 5:15:15.
  - Vegetative: $24\,\text{L/m}^2/\text{week}$, Urea circular band.
  - Flowering: $30\,\text{L/m}^2/\text{week}$, NPK 12–12–17.
  - Fruiting: $34\,\text{L/m}^2/\text{week}$, repeat every 14 days during prolonged picking flushes.

---

## 3. Notes & Marked Estimates

- **Estimates Notice**: Water volume values in litres per square metre per week ($\text{L/m}^2/\text{week}$) are normalized estimates based on FAO-56 crop coefficient calculations for average Sri Lankan Dry/Intermediate zone pan evaporation ($4.5\,\text{mm/day}$ to $6.0\,\text{mm/day}$) with an assumed 85% drip irrigation efficiency.
- **Soil Sensor Thresholds**: For rain-skip events, a tensiometer reading below $20\,\text{kPa}$ or rainfall forecast exceeding $15\,\text{mm}$ triggers the *"Rain expected. Skip watering."* routine.
