import 'package:flutter/foundation.dart';

/// Enumeration of all detectable leaf disease and health classes.
enum DiseaseClass {
  earlyBlight,
  lateBlight,
  leafCurl,
  bacterialSpot,
  nitrogenDeficiency,
  healthy;

  String get displayName => DiseaseInfo.forClass(this).displayName;
  String get scientificName => DiseaseInfo.forClass(this).scientificName;
}

/// Rich agronomy information for a disease class.
@immutable
class DiseaseInfo {
  final DiseaseClass diseaseClass;
  final String displayName;
  final String scientificName;
  final String description;
  final List<String> recommendedActionSteps;
  final List<String> preventionTips;
  final bool isHealthy;

  const DiseaseInfo({
    required this.diseaseClass,
    required this.displayName,
    required this.scientificName,
    required this.description,
    required this.recommendedActionSteps,
    required this.preventionTips,
    this.isHealthy = false,
  });

  /// Catalog lookup of official Sri Lankan Department of Agriculture (DOA) agronomy advice.
  static DiseaseInfo forClass(DiseaseClass diseaseClass) {
    switch (diseaseClass) {
      case DiseaseClass.earlyBlight:
        return const DiseaseInfo(
          diseaseClass: DiseaseClass.earlyBlight,
          displayName: 'Early Blight',
          scientificName: 'Alternaria solani',
          description:
              'A common fungal infection causing dark brown to black spots with concentric rings (target-board pattern) on older leaves. Rapidly spreads in humid, overcast conditions.',
          recommendedActionSteps: [
            'Prune and destroy infected lower leaves immediately to prevent upward spore dispersal.',
            'Apply copper hydroxide or mancozeb protective fungicide early in the morning following label rates.',
            'Switch to drip irrigation or water at the base to keep leaves dry.',
          ],
          preventionTips: [
            'Maintain at least 45-60 cm spacing between plants for adequate ventilation.',
            'Practice 3-year crop rotation avoiding other Solanaceae family members.',
            'Apply clean straw mulch to stop fungal spores splashing from soil onto lower foliage.',
          ],
        );
      case DiseaseClass.lateBlight:
        return const DiseaseInfo(
          diseaseClass: DiseaseClass.lateBlight,
          displayName: 'Late Blight',
          scientificName: 'Phytophthora infestans',
          description:
              'A destructive water-mold pathogen causing pale green to water-soaked lesions that rapidly turn dark brown or purplish-black with white fungal growth underneath during cool, wet periods.',
          recommendedActionSteps: [
            'Uproot and bury severely affected plants outside the cultivation perimeter.',
            'Spray systemic fungicide (e.g., metalaxyl or dimethomorph) immediately on neighbouring rows.',
            'Disinfect pruning tools with 70% alcohol or 10% bleach solution between beds.',
          ],
          preventionTips: [
            'Plant certified disease-free seedlings or resistant cultivars (e.g., Thilina for tomato).',
            'Avoid overhead irrigation; ensure drainage channels freely discharge excess monsoon runoff.',
            'Check daily during periods of high humidity (>90%) and cool night temperatures (15-20°C).',
          ],
        );
      case DiseaseClass.leafCurl:
        return const DiseaseInfo(
          diseaseClass: DiseaseClass.leafCurl,
          displayName: 'Leaf Curl Virus',
          scientificName: 'Begomovirus (transmitted by Bemisia tabaci)',
          description:
              'A viral infection transmitted by silverleaf whiteflies, resulting in upward curling, puckering, chlorosis of leaf margins, and stunted plant growth.',
          recommendedActionSteps: [
            'Rogue and burn infected plants early before whiteflies transmit the virus across the field.',
            'Install yellow sticky traps (15-20 per hectare) at canopy height to monitor and trap whiteflies.',
            'Spray organic neem oil extract (5ml/L) or approved systemic insecticide to control the vector.',
          ],
          preventionTips: [
            'Erect 40-mesh insect-proof netting over nursery beds during seedling stage.',
            'Eliminate weed hosts (such as Ageratum and Parthenium) along field margins.',
            'Use reflective silver polyethylene mulch to deter incoming whitefly vectors.',
          ],
        );
      case DiseaseClass.bacterialSpot:
        return const DiseaseInfo(
          diseaseClass: DiseaseClass.bacterialSpot,
          displayName: 'Bacterial Spot',
          scientificName: 'Xanthomonas campestris pv. vesicatoria',
          description:
              'Bacterial disease causing small, water-soaked, angular dark lesions on leaves and raised scab-like spots on fruits, thriving in warm, rainy weather.',
          recommendedActionSteps: [
            'Do not work in fields or cultivate while foliage is wet to prevent bacterial spreading.',
            'Apply fixed copper bactericide mixed with mancozeb to slow lesion development.',
            'Safely discard infected fruit and plant debris far from water sources.',
          ],
          preventionTips: [
            'Use hot-water treated or certified pathogen-free seeds.',
            'Disinfect seedling trays and nursery equipment with sodium hypochlorite.',
            'Avoid high-pressure overhead irrigation that causes leaf abrasions.',
          ],
        );
      case DiseaseClass.nitrogenDeficiency:
        return const DiseaseInfo(
          diseaseClass: DiseaseClass.nitrogenDeficiency,
          displayName: 'Nitrogen Deficiency',
          scientificName: 'Nutrient Deficiency (N)',
          description:
              'Physiological disorder characterized by general yellowing (chlorosis) beginning uniformly on older lower leaves, slender stems, and stunted vegetative growth.',
          recommendedActionSteps: [
            'Apply balanced nitrogenous fertilizer (such as Urea or Ammonium Sulfate) based on DOA soil test guidelines.',
            'Apply dilute foliar spray of 1-2% urea solution for rapid leaf absorption and greening.',
            'Incorporate compost or well-decomposed cattle manure to boost soil organic matter.',
          ],
          preventionTips: [
            'Perform baseline soil testing before each cultivation season (Maha/Yala).',
            'Split nitrogen applications across basal, vegetative, and flowering stages rather than all at once.',
            'Avoid heavy waterlogging which causes nitrogen leaching and denitrification in root zones.',
          ],
        );
      case DiseaseClass.healthy:
        return const DiseaseInfo(
          diseaseClass: DiseaseClass.healthy,
          displayName: 'Healthy Plant',
          scientificName: 'Solanaceae (Normal Growth)',
          description:
              'The foliage displays vibrant green colouration, robust cell turgor, uniform leaf development, and no visible symptoms of disease or pest infestation.',
          recommendedActionSteps: [
            'Maintain standard irrigation schedules and balanced fertilizer top-dressing intervals.',
            'Continue routine weekly scouting of both upper and lower leaf surfaces.',
          ],
          preventionTips: [
            'Maintain optimal soil moisture and aeration around the root zone.',
            'Adhere to recommended pruning, weeding, and mulching best practices.',
            'Regularly log scans to track crop vitality across all growth stages.',
          ],
          isHealthy: true,
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiseaseInfo &&
          runtimeType == other.runtimeType &&
          diseaseClass == other.diseaseClass &&
          displayName == other.displayName &&
          scientificName == other.scientificName;

  @override
  int get hashCode => Object.hash(diseaseClass, displayName, scientificName);

  @override
  String toString() => 'DiseaseInfo($displayName, $scientificName)';
}
