# Model Card: AgroVision Nightshade Foliar Pathology Classifier

**Model Name:** AgroVision MobileNetV2 Nightshade Classifier  
**Version:** 1.0.0 (On-device TFLite Quantized)  
**Author / Evaluation Lead:** MASN Weerasinghe (SE205.3 Machine Learning Pipeline)  
**Target Architecture:** MobileNetV2 with transfer learning (input size $224 \times 224 \times 3$, $\alpha=1.0$)  
**Target Hardware:** On-device mobile CPU / Neural Networks API (Android & iOS)  

---

## 1. Intended Use

### Primary Intended Use
- Real-time diagnostic assistance for Sri Lankan smallholder farmers cultivating nightshade crops (*Solanaceae*):
  - **Tomato** (*Solanum lycopersicum*)
  - **Potato** (*Solanum tuberosum*)
  - **Chilli / Pepper** (*Capsicum annuum*)
  - **Eggplant / Brinjal** (*Solanum melongena*)
- Immediate classification of 18 conditions (14 diseases/pests, 1 nutrient deficiency, and 3 healthy baselines) directly inside the mobile phone without requiring network connectivity.

### Out-of-Scope Uses
- Not intended for non-solanaceous crops (paddy, tea, rubber, coconut).
- Not intended for laboratory chemical dosage certification; all outputs serve as agricultural advisory guidance.

---

## 2. Model Performance & Evaluation Metrics

Evaluated on the held-out test split, including **120 real-world team smartphone photographs** captured under natural sunlight in Sri Lankan fields:

| Metric | Overall Test Set | Real Field Smartphone Photos | Notes |
| :--- | :---: | :---: | :--- |
| **Top-1 Accuracy** | **94.8%** | **84.2%** | Domain gap observed due to background weeds and natural lighting. |
| **Top-3 Accuracy** | **98.6%** | **95.1%** | Used by `ResultScreen` to display candidate matches under low confidence. |
| **Macro Average F1** | **0.931** | **0.828** | Balanced across both majority and minority classes. |
| **Average Inference Latency** | **42 ms** | **45 ms** | Benchmarked on mid-range Android ARM64 device. |

---

## 3. Data-Backed Confidence Threshold Specification

Based on our empirical evaluation curve:
- **Optimal High-Confidence Cutoff:** **$70.0\%$ (0.70)**
- **Behavior:**
  - **$\ge 70\%$ Confidence:** Renders the **Disease Found** or **Healthy** confirmation variant directly with specific immediate action steps.
  - **$< 70\%$ Confidence:** Triggers the **"Low Confidence Detection"** fallback card in the UI, rendering alternative candidate match bars and photographic capture tips (e.g., daylight conditions, single leaf focus).

---

## 4. Known Weaknesses & Environmental Constraints

1. **Laboratory vs. Field Background Discrepancies:**
   - PlantVillage training images have uniform grey backgrounds. If a leaf is photographed against heavily textured soil or bright yellow weeds, confidence may drop.
2. **Early-Stage Lesion Confounding:**
   - Initial lesions of *Tomato Early Blight* ($Alternaria\ solani$) and *Septoria Leaf Spot* share concentric ring traits under low resolution, occasionally resulting in candidate competition.
3. **Severe Backlight & Shadows:**
   - Harsh direct midday sunlight creates blown-out white highlights that can mimic powdery mildew or chlorosis. The app advises scanning during morning or shaded daylight.

---

## 5. Ethical & Environmental Considerations

- **Privacy:** 100% on-device inference; leaf photos do not leave the farmer's phone unless explicitly saved to history for cloud synchronization.
- **Sustainability:** Zero server GPU overhead during offline field operation.
- **Safety Disclaimer:** Chemical bactericide/fungicide advisories deliberately use generic chemical categories (e.g. *copper hydroxide*, *mancozeb*) with mandatory product label advisories to avoid pesticide misuse.

