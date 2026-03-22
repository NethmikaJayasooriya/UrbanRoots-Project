import 'package:flutter/material.dart';
import 'app_styles.dart';

// Model representing detailed medical information for a plant disease, including symptoms, causes, and recommended remedies.
class DiseaseInfo {
  final String       name;
  final String       scientificName;
  final String       category;       // Viral | Fungal | Bacterial | Pest
  final Color        categoryColor;
  final String       severity;       // Low | Medium | High
  final String       overview;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> prevention;
  final List<String> treatments;
  final String       spreadRate;     // Slow | Moderate | Fast
  final String       affectedParts;  // Leaves | Stem | Root | All
  final List<RemedyInfo> remedies;

  const DiseaseInfo({
    required this.name,
    required this.scientificName,
    required this.category,
    required this.categoryColor,
    required this.severity,
    required this.overview,
    required this.symptoms,
    required this.causes,
    required this.prevention,
    required this.treatments,
    required this.spreadRate,
    required this.affectedParts,
    required this.remedies,
  });
}

class RemedyInfo {
  final String name;
  final String type;        // Organic | Chemical
  final String description;
  final String frequency;

  const RemedyInfo({
    required this.name,
    required this.type,
    required this.description,
    required this.frequency,
  });
}

// Local data repository containing treatment protocols and descriptive data for supported plant diseases.
const _diseaseDatabase = {

  // Tomato Diseases
  'Tomato__Tomato_YellowLeaf__Curl_Virus': DiseaseInfo(
    name:           'Tomato Yellow Leaf Curl Virus',
    scientificName: 'Tomato Yellow Leaf Curl Virus (TYLCV)',
    category:       'Viral',
    categoryColor:  AppColors.danger,
    severity:       'High',
    overview:       'A viral infection spread by whiteflies causing leaves to curl upward, turn yellow and stunt plant growth. Early detection is critical.',
    symptoms:       ['Leaves curl upward and inward', 'Yellowing of leaf edges', 'Stunted bushy growth', 'Flowers drop before fruit sets', 'Small deformed fruits'],
    causes:         ['Whitefly (Bemisia tabaci) transmission', 'Infected transplants', 'Proximity to infected plants', 'Warm humid conditions'],
    prevention:     ['Use reflective mulch', 'Install yellow sticky traps', 'Inspect new plants before introducing', 'Use insect-proof netting'],
    treatments:     ['Isolate infected plant immediately', 'Remove infected leaves', 'Apply neem oil every 5–7 days', 'Use insecticidal soap'],
    spreadRate:     'Fast',
    affectedParts:  'Leaves, Flowers, Fruit',
    remedies: [
      RemedyInfo(name: 'Organic Neem Oil', type: 'Organic', description: 'Disrupts whitefly life cycle', frequency: 'Every 7 days'),
      RemedyInfo(name: 'Imidacloprid', type: 'Chemical', description: 'Systemic insecticide for severe infestations', frequency: 'Once per season'),
    ],
  ),

  'Tomato__Tomato_mosaic_virus': DiseaseInfo(
    name:           'Tomato Mosaic Virus',
    scientificName: 'Tomato Mosaic Virus (ToMV)',
    category:       'Viral',
    categoryColor:  AppColors.danger,
    severity:       'High',
    overview:       'A highly contagious viral disease causing mosaic-like yellow and green patterns on leaves. Spreads through contact and contaminated tools.',
    symptoms:       ['Mosaic yellow-green leaf pattern', 'Leaf distortion and curling', 'Stunted growth', 'Reduced fruit yield', 'Fruit discoloration'],
    causes:         ['Contact with infected plants', 'Contaminated tools', 'Infected seeds', 'Aphid transmission'],
    prevention:     ['Use certified virus-free seeds', 'Disinfect tools with bleach', 'Wash hands before handling plants', 'Remove and destroy infected plants'],
    treatments:     ['No cure — remove infected plants', 'Control aphid populations', 'Disinfect all tools', 'Plant resistant varieties'],
    spreadRate:     'Fast',
    affectedParts:  'Leaves, Fruit',
    remedies: [
      RemedyInfo(name: 'Insecticidal Soap', type: 'Organic', description: 'Controls aphid vectors', frequency: 'Every 5 days'),
      RemedyInfo(name: 'Copper Fungicide', type: 'Chemical', description: 'Reduces secondary infections', frequency: 'Every 10 days'),
    ],
  ),

  'Tomato_Bacterial_spot': DiseaseInfo(
    name:           'Tomato Bacterial Spot',
    scientificName: 'Xanthomonas vesicatoria',
    category:       'Bacterial',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A bacterial disease causing dark water-soaked spots on leaves and fruits. Thrives in warm wet conditions and spreads rapidly through rain splash.',
    symptoms:       ['Small dark water-soaked spots on leaves', 'Yellow halo around spots', 'Spots on fruits turning brown', 'Defoliation in severe cases'],
    causes:         ['Bacteria spread by rain and wind', 'Infected seeds or transplants', 'Overhead irrigation', 'Warm wet weather'],
    prevention:     ['Use disease-free seeds', 'Avoid overhead watering', 'Rotate crops annually', 'Remove infected plant debris'],
    treatments:     ['Apply copper-based bactericide', 'Remove heavily infected leaves', 'Improve air circulation', 'Reduce leaf wetness'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves, Stems, Fruit',
    remedies: [
      RemedyInfo(name: 'Copper Bactericide', type: 'Chemical', description: 'Kills surface bacteria', frequency: 'Every 7–10 days'),
      RemedyInfo(name: 'Neem Oil Spray', type: 'Organic', description: 'Natural antibacterial properties', frequency: 'Every 7 days'),
    ],
  ),

  'Tomato_Early_blight': DiseaseInfo(
    name:           'Tomato Early Blight',
    scientificName: 'Alternaria solani',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A fungal disease causing dark concentric ring spots on lower leaves first, then spreading upward. Weakens plants and reduces yield significantly.',
    symptoms:       ['Dark brown spots with concentric rings', 'Yellow halo around spots', 'Lower leaves affected first', 'Premature leaf drop', 'Dark lesions on stems'],
    causes:         ['Fungal spores in soil', 'Overhead watering', 'Dense planting', 'Warm humid conditions', 'Plant stress'],
    prevention:     ['Mulch around plants', 'Water at base only', 'Space plants for air circulation', 'Remove infected lower leaves early'],
    treatments:     ['Apply fungicide at first sign', 'Remove infected leaves', 'Avoid wetting foliage', 'Apply organic copper spray'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves, Stems, Fruit',
    remedies: [
      RemedyInfo(name: 'Chlorothalonil', type: 'Chemical', description: 'Broad spectrum fungicide', frequency: 'Every 7 days'),
      RemedyInfo(name: 'Copper Octanoate', type: 'Organic', description: 'OMRI listed organic fungicide', frequency: 'Every 7–10 days'),
    ],
  ),

  'Tomato_Late_blight': DiseaseInfo(
    name:           'Tomato Late Blight',
    scientificName: 'Phytophthora infestans',
    category:       'Fungal',
    categoryColor:  AppColors.danger,
    severity:       'High',
    overview:       'A devastating water mold disease that can destroy entire crops within days. The same pathogen that caused the Irish Potato Famine.',
    symptoms:       ['Large irregular water-soaked lesions', 'White fuzzy growth on leaf undersides', 'Dark brown stem lesions', 'Fruit develops firm brown rot', 'Rapid plant collapse'],
    causes:         ['Cool wet weather (60-70°F)', 'High humidity above 90%', 'Infected transplants', 'Wind-carried spores'],
    prevention:     ['Plant resistant varieties', 'Avoid overhead irrigation', 'Ensure good air circulation', 'Apply preventive fungicide in wet weather'],
    treatments:     ['Apply systemic fungicide immediately', 'Remove and destroy infected plants', 'Do not compost infected material', 'Treat surrounding plants preventively'],
    spreadRate:     'Fast',
    affectedParts:  'Leaves, Stems, Fruit',
    remedies: [
      RemedyInfo(name: 'Mancozeb', type: 'Chemical', description: 'Protective fungicide — apply before infection', frequency: 'Every 5–7 days'),
      RemedyInfo(name: 'Copper Hydroxide', type: 'Organic', description: 'Organic protective spray', frequency: 'Every 5 days'),
    ],
  ),

  'Tomato_Leaf_Mold': DiseaseInfo(
    name:           'Tomato Leaf Mold',
    scientificName: 'Passalora fulva',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A fungal disease common in greenhouse tomatoes causing pale green or yellow spots on upper leaf surfaces with olive-green mold on undersides.',
    symptoms:       ['Pale green or yellow spots on upper leaf', 'Olive-green velvety mold on undersides', 'Leaves turn brown and dry', 'Reduced photosynthesis', 'Defoliation in severe cases'],
    causes:         ['High humidity above 85%', 'Poor air circulation', 'Cool temperatures', 'Overhead watering'],
    prevention:     ['Reduce humidity below 85%', 'Improve ventilation', 'Space plants widely', 'Avoid wetting leaves'],
    treatments:     ['Apply fungicide at first sign', 'Prune lower leaves for air flow', 'Reduce irrigation frequency', 'Remove infected leaves'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves',
    remedies: [
      RemedyInfo(name: 'Chlorothalonil', type: 'Chemical', description: 'Preventive and curative fungicide', frequency: 'Every 7–14 days'),
      RemedyInfo(name: 'Potassium Bicarbonate', type: 'Organic', description: 'Disrupts fungal cell walls', frequency: 'Every 7 days'),
    ],
  ),

  'Tomato_Septoria_leaf_spot': DiseaseInfo(
    name:           'Tomato Septoria Leaf Spot',
    scientificName: 'Septoria lycopersici',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'One of the most common tomato diseases causing small circular spots with dark borders and light centers, leading to severe defoliation.',
    symptoms:       ['Small circular spots with dark border', 'Light gray or tan center with dark specks', 'Lower leaves affected first', 'Heavy defoliation', 'Weakened plants'],
    causes:         ['Fungal spores in soil and plant debris', 'Splashing water', 'Warm wet weather', 'Dense planting'],
    prevention:     ['Rotate crops every 3 years', 'Mulch to prevent soil splash', 'Water at base', 'Remove plant debris after season'],
    treatments:     ['Apply fungicide immediately', 'Remove infected lower leaves', 'Avoid working with wet plants', 'Stake plants to improve air flow'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves',
    remedies: [
      RemedyInfo(name: 'Mancozeb + Chlorothalonil', type: 'Chemical', description: 'Combined fungicide for best control', frequency: 'Every 7–10 days'),
      RemedyInfo(name: 'Copper Soap', type: 'Organic', description: 'OMRI listed copper fungicide', frequency: 'Every 7 days'),
    ],
  ),

  'Tomato_Spider_mites_Two_spotted_spider_mite': DiseaseInfo(
    name:           'Tomato Spider Mites',
    scientificName: 'Tetranychus urticae',
    category:       'Pest',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'Tiny spider mites that feed on leaf undersides causing stippling, bronzing and fine webbing. Severe infestations can defoliate entire plants.',
    symptoms:       ['Fine stippling or speckling on leaves', 'Bronze or yellow discoloration', 'Fine webbing on leaf undersides', 'Leaf drop in severe cases', 'Tiny moving dots visible'],
    causes:         ['Hot dry conditions', 'Dusty environments', 'Over-fertilization with nitrogen', 'Pesticide resistance buildup'],
    prevention:     ['Keep plants well-watered', 'Spray water on leaf undersides', 'Introduce predatory mites', 'Avoid excessive nitrogen'],
    treatments:     ['Spray strong water jet on undersides', 'Apply insecticidal soap or neem oil', 'Introduce Phytoseiulus predatory mites', 'Use miticide for severe infestations'],
    spreadRate:     'Fast',
    affectedParts:  'Leaves',
    remedies: [
      RemedyInfo(name: 'Neem Oil', type: 'Organic', description: 'Suffocates mites and disrupts life cycle', frequency: 'Every 5–7 days'),
      RemedyInfo(name: 'Abamectin', type: 'Chemical', description: 'Miticide for severe infestations', frequency: 'Once, repeat after 7 days'),
    ],
  ),

  'Tomato__Target_Spot': DiseaseInfo(
    name:           'Tomato Target Spot',
    scientificName: 'Corynespora cassiicola',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A fungal disease causing distinctive target-like concentric ring spots on leaves, stems and fruits. Common in warm humid tropical climates.',
    symptoms:       ['Circular spots with concentric rings', 'Dark brown to black lesions', 'Yellow halo around lesions', 'Spots on fruits and stems', 'Premature defoliation'],
    causes:         ['Warm humid conditions', 'Poor air circulation', 'Infected plant debris', 'Splashing water'],
    prevention:     ['Improve air circulation', 'Avoid overhead watering', 'Remove infected debris', 'Crop rotation'],
    treatments:     ['Apply fungicide at first sign', 'Remove heavily infected leaves', 'Improve drainage', 'Apply copper-based spray'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves, Stems, Fruit',
    remedies: [
      RemedyInfo(name: 'Azoxystrobin', type: 'Chemical', description: 'Systemic fungicide with curative action', frequency: 'Every 7–14 days'),
      RemedyInfo(name: 'Copper Fungicide', type: 'Organic', description: 'Broad spectrum protection', frequency: 'Every 7 days'),
    ],
  ),

  'Tomato_healthy': DiseaseInfo(
    name:           'Healthy Tomato',
    scientificName: 'Solanum lycopersicum',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your tomato plant appears healthy! Maintain good cultural practices to keep it thriving and producing well.',
    symptoms:       ['Deep green uniform leaf color', 'Strong upright stems', 'Vigorous new growth', 'No spots or lesions'],
    causes:         ['Good soil nutrition', 'Proper watering', 'Adequate sunlight', 'Good air circulation'],
    prevention:     ['Water consistently at base', 'Fertilize every 2 weeks', 'Stake or cage plant', 'Monitor regularly for pests'],
    treatments:     ['Continue current care routine', 'Apply balanced fertilizer monthly', 'Prune suckers for better fruit'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Balanced NPK Fertilizer', type: 'Organic', description: 'Maintains healthy growth', frequency: 'Every 2 weeks'),
    ],
  ),

  // Potato Diseases
  'Potato___Early_blight': DiseaseInfo(
    name:           'Potato Early Blight',
    scientificName: 'Alternaria solani',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A fungal disease affecting potato leaves causing dark spots with concentric rings. Usually appears on older lower leaves first and moves upward.',
    symptoms:       ['Dark brown circular spots with rings', 'Yellow halo around lesions', 'Lower leaves affected first', 'Premature defoliation', 'Reduced tuber yield'],
    causes:         ['Fungal spores in soil', 'Warm humid weather', 'Plant stress from drought', 'Dense planting'],
    prevention:     ['Rotate crops every 3 years', 'Use certified disease-free seed potatoes', 'Mulch soil surface', 'Avoid excessive nitrogen'],
    treatments:     ['Apply fungicide at first sign', 'Remove infected leaves', 'Improve air circulation', 'Reduce plant stress'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves, Tubers',
    remedies: [
      RemedyInfo(name: 'Chlorothalonil', type: 'Chemical', description: 'Protectant fungicide — apply preventively', frequency: 'Every 7–10 days'),
      RemedyInfo(name: 'Copper Oxychloride', type: 'Organic', description: 'Organic broad-spectrum fungicide', frequency: 'Every 7 days'),
    ],
  ),

  'Potato___Late_blight': DiseaseInfo(
    name:           'Potato Late Blight',
    scientificName: 'Phytophthora infestans',
    category:       'Fungal',
    categoryColor:  AppColors.danger,
    severity:       'High',
    overview:       'The most destructive potato disease — the same organism that caused the Irish Potato Famine. Can destroy entire fields within days under ideal conditions.',
    symptoms:       ['Large irregular dark lesions on leaves', 'White fuzzy growth on leaf undersides', 'Brown rot spreading to stems', 'Infected tubers with reddish-brown rot', 'Rapid plant collapse'],
    causes:         ['Cool wet weather', 'High humidity', 'Infected seed potatoes', 'Wind-carried spores from nearby fields'],
    prevention:     ['Plant certified disease-free seed potatoes', 'Apply preventive fungicide in wet seasons', 'Ensure good drainage', 'Monitor forecasts for blight risk'],
    treatments:     ['Apply systemic fungicide immediately', 'Destroy infected plants and tubers', 'Do not store infected tubers', 'Treat surrounding plants preventively'],
    spreadRate:     'Fast',
    affectedParts:  'Leaves, Stems, Tubers',
    remedies: [
      RemedyInfo(name: 'Metalaxyl + Mancozeb', type: 'Chemical', description: 'Systemic + contact fungicide combination', frequency: 'Every 5–7 days'),
      RemedyInfo(name: 'Copper Hydroxide', type: 'Organic', description: 'Preventive organic spray', frequency: 'Every 5 days'),
    ],
  ),

  'Potato___healthy': DiseaseInfo(
    name:           'Healthy Potato',
    scientificName: 'Solanum tuberosum',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your potato plant looks healthy! Keep up the good work with regular monitoring and proper care.',
    symptoms:       ['Dark green healthy leaves', 'Strong stems', 'No spots or lesions', 'Vigorous growth'],
    causes:         ['Proper soil nutrition', 'Consistent moisture', 'Good drainage', 'Disease-free seed potatoes'],
    prevention:     ['Hill soil around stems', 'Water consistently', 'Monitor for pests weekly', 'Apply balanced fertilizer'],
    treatments:     ['Continue current care', 'Apply potassium-rich fertilizer for tuber development'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Potassium Fertilizer', type: 'Organic', description: 'Promotes healthy tuber development', frequency: 'Monthly'),
    ],
  ),

  // Pepper Diseases
  'Pepper__bell___Bacterial_spot': DiseaseInfo(
    name:           'Pepper Bacterial Spot',
    scientificName: 'Xanthomonas campestris pv. vesicatoria',
    category:       'Bacterial',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A bacterial disease causing water-soaked spots on pepper leaves and fruits. Spreads rapidly in warm wet conditions through rain splash and irrigation.',
    symptoms:       ['Small water-soaked spots on leaves', 'Spots turn brown with yellow halo', 'Raised scab-like spots on fruits', 'Defoliation', 'Reduced yield'],
    causes:         ['Bacteria spread by water splash', 'Infected transplants', 'High humidity', 'Warm temperatures 75-86°F'],
    prevention:     ['Use certified disease-free transplants', 'Avoid overhead irrigation', 'Apply copper spray preventively', 'Rotate crops'],
    treatments:     ['Apply copper bactericide immediately', 'Remove infected plant parts', 'Reduce leaf wetness', 'Improve drainage'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves, Fruit',
    remedies: [
      RemedyInfo(name: 'Copper Hydroxide', type: 'Chemical', description: 'Bactericidal copper spray', frequency: 'Every 7 days'),
      RemedyInfo(name: 'Acibenzolar-S-methyl', type: 'Chemical', description: 'Plant defense activator', frequency: 'Every 14 days'),
    ],
  ),

  'Pepper__bell___healthy': DiseaseInfo(
    name:           'Healthy Bell Pepper',
    scientificName: 'Capsicum annuum',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your bell pepper plant is healthy and thriving! Continue good cultural practices for a great harvest.',
    symptoms:       ['Glossy dark green leaves', 'Upright healthy stems', 'No spots or blemishes', 'Active flowering and fruiting'],
    causes:         ['Adequate nutrition', 'Proper watering', 'Good drainage', 'Sufficient sunlight'],
    prevention:     ['Water at base consistently', 'Fertilize with calcium-rich fertilizer', 'Support heavy fruiting branches', 'Monitor for pests'],
    treatments:     ['Continue current care', 'Apply calcium spray to prevent blossom end rot'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Calcium Nitrate', type: 'Chemical', description: 'Prevents blossom end rot', frequency: 'Every 2 weeks'),
    ],
  ),

  // Grape Diseases
  'Grape___Black_rot': DiseaseInfo(
    name:           'Grape Black Rot',
    scientificName: 'Guignardia bidwellii',
    category:       'Fungal',
    categoryColor:  AppColors.danger,
    severity:       'High',
    overview:       'A devastating fungal disease that can destroy up to 80% of a grape crop. Black mummified berries and brown leaf spots are characteristic signs.',
    symptoms:       ['Tan brown spots with dark borders on leaves', 'Black mummified berries', 'Infected berries shrivel and fall', 'Lesions on shoots and tendrils'],
    causes:         ['Fungal spores from mummified berries', 'Warm wet spring weather', 'Poor air circulation', 'Infected canes overwintering'],
    prevention:     ['Remove and destroy mummified berries', 'Prune for good air circulation', 'Apply fungicide from bud break', 'Avoid overhead irrigation'],
    treatments:     ['Apply fungicide immediately', 'Remove all infected material', 'Destroy mummified berries', 'Apply dormant spray in winter'],
    spreadRate:     'Fast',
    affectedParts:  'Leaves, Berries, Shoots',
    remedies: [
      RemedyInfo(name: 'Myclobutanil', type: 'Chemical', description: 'Systemic fungicide highly effective against black rot', frequency: 'Every 10–14 days'),
      RemedyInfo(name: 'Captan', type: 'Chemical', description: 'Protectant fungicide', frequency: 'Every 7–10 days'),
    ],
  ),

  'Grape___Esca_(Black_Measles)': DiseaseInfo(
    name:           'Grape Esca (Black Measles)',
    scientificName: 'Phaeomoniella chlamydospora',
    category:       'Fungal',
    categoryColor:  AppColors.danger,
    severity:       'High',
    overview:       'A complex wood disease of grapevines causing tiger-stripe leaf symptoms and black spots on berries. Can kill vines within years of infection.',
    symptoms:       ['Tiger-stripe pattern on leaves', 'Black spots on berries', 'Dried bleached wood inside trunk', 'Sudden vine collapse', 'Marginal leaf scorch'],
    causes:         ['Fungal infection through pruning wounds', 'Old or stressed vines', 'Poor wound care', 'Warm dry conditions'],
    prevention:     ['Seal pruning wounds immediately', 'Prune during dry weather', 'Use clean sterilized tools', 'Remove and destroy infected wood'],
    treatments:     ['No cure — manage symptom progression', 'Remove infected wood', 'Apply wound sealant after pruning', 'Maintain vine vigor'],
    spreadRate:     'Slow',
    affectedParts:  'Leaves, Wood, Berries',
    remedies: [
      RemedyInfo(name: 'Pruning Wound Sealant', type: 'Organic', description: 'Prevents fungal entry through cuts', frequency: 'After every pruning'),
      RemedyInfo(name: 'Tebuconazole', type: 'Chemical', description: 'Reduces fungal spread in wood', frequency: 'Seasonally'),
    ],
  ),

  'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)': DiseaseInfo(
    name:           'Grape Leaf Blight',
    scientificName: 'Isariopsis clavispora',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A fungal leaf disease causing irregular brown spots on upper leaf surfaces leading to premature defoliation and reduced fruit quality.',
    symptoms:       ['Irregular brown spots on upper leaf', 'Dark brown lesions', 'Premature yellowing', 'Defoliation in severe cases', 'Reduced berry quality'],
    causes:         ['Fungal spores spread by wind and rain', 'Warm humid conditions', 'Dense canopy', 'Poor air circulation'],
    prevention:     ['Prune for open canopy', 'Remove infected leaves', 'Apply preventive fungicide', 'Avoid overhead irrigation'],
    treatments:     ['Apply fungicide at first sign', 'Remove infected leaves', 'Improve air circulation through pruning'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves',
    remedies: [
      RemedyInfo(name: 'Mancozeb', type: 'Chemical', description: 'Protectant fungicide for leaf diseases', frequency: 'Every 10–14 days'),
      RemedyInfo(name: 'Bordeaux Mixture', type: 'Organic', description: 'Traditional copper-lime fungicide', frequency: 'Every 10 days'),
    ],
  ),

  'Grape___healthy': DiseaseInfo(
    name:           'Healthy Grape',
    scientificName: 'Vitis vinifera',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your grapevine looks healthy! Proper pruning and canopy management are key to keeping it productive.',
    symptoms:       ['Healthy green leaves', 'Strong canes', 'No spots or lesions', 'Good cluster development'],
    causes:         ['Good soil nutrition', 'Proper pruning', 'Adequate sunlight', 'Good drainage'],
    prevention:     ['Prune annually for air circulation', 'Train on trellis properly', 'Apply dormant spray in winter', 'Monitor for disease weekly'],
    treatments:     ['Continue current care', 'Apply balanced fertilizer in spring'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Balanced Vine Fertilizer', type: 'Organic', description: 'Supports healthy vine growth', frequency: 'Spring application'),
    ],
  ),

  // Cherry Diseases
  'Cherry_(including_sour)___Powdery_mildew': DiseaseInfo(
    name:           'Cherry Powdery Mildew',
    scientificName: 'Podosphaera clandestina',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A fungal disease coating cherry leaves with white powdery growth. Affects young leaves and shoots and can reduce fruit quality significantly.',
    symptoms:       ['White powdery coating on leaves', 'Distorted curled young leaves', 'Stunted shoot growth', 'Fruit russeting', 'Premature leaf drop'],
    causes:         ['Fungal spores spread by wind', 'Warm dry days with cool nights', 'High humidity', 'Dense shading'],
    prevention:     ['Prune for good air circulation', 'Avoid excessive nitrogen', 'Choose resistant varieties', 'Apply preventive sulfur spray'],
    treatments:     ['Apply sulfur or potassium bicarbonate', 'Remove infected shoots', 'Improve air circulation', 'Apply systemic fungicide'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves, Shoots, Fruit',
    remedies: [
      RemedyInfo(name: 'Wettable Sulfur', type: 'Organic', description: 'Effective organic powdery mildew control', frequency: 'Every 7–10 days'),
      RemedyInfo(name: 'Myclobutanil', type: 'Chemical', description: 'Systemic fungicide for severe cases', frequency: 'Every 14 days'),
    ],
  ),

  'Cherry_(including_sour)___healthy': DiseaseInfo(
    name:           'Healthy Cherry',
    scientificName: 'Prunus avium / cerasus',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your cherry tree is healthy! Regular pruning and monitoring will keep it productive for many years.',
    symptoms:       ['Glossy healthy green leaves', 'Strong branch structure', 'Good fruit development', 'No disease signs'],
    causes:         ['Good soil nutrition', 'Proper pruning', 'Adequate water and drainage', 'Full sun exposure'],
    prevention:     ['Prune after harvest', 'Apply dormant oil spray', 'Monitor for pests and disease', 'Mulch around base'],
    treatments:     ['Continue current care', 'Apply balanced fertilizer in spring'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Balanced Fruit Tree Fertilizer', type: 'Organic', description: 'Supports healthy growth and fruiting', frequency: 'Spring application'),
    ],
  ),

  // Strawberry Diseases
  'Strawberry___Leaf_scorch': DiseaseInfo(
    name:           'Strawberry Leaf Scorch',
    scientificName: 'Diplocarpon earliana',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A fungal disease causing numerous small dark purple spots on strawberry leaves that merge to give a scorched appearance.',
    symptoms:       ['Small dark purple spots on leaves', 'Spots merge giving scorched look', 'Reddish-purple borders on spots', 'Leaf tip and margin browning', 'Reduced plant vigor'],
    causes:         ['Fungal spores from infected debris', 'Wet weather conditions', 'Dense planting', 'Overhead irrigation'],
    prevention:     ['Remove and destroy old leaves', 'Avoid overhead irrigation', 'Space plants adequately', 'Use resistant varieties'],
    treatments:     ['Apply fungicide at first sign', 'Remove heavily infected leaves', 'Improve air circulation', 'Reduce leaf wetness'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves',
    remedies: [
      RemedyInfo(name: 'Captan', type: 'Chemical', description: 'Effective protectant fungicide', frequency: 'Every 7–10 days'),
      RemedyInfo(name: 'Copper Fungicide', type: 'Organic', description: 'Organic broad-spectrum protection', frequency: 'Every 7 days'),
    ],
  ),

  'Strawberry___healthy': DiseaseInfo(
    name:           'Healthy Strawberry',
    scientificName: 'Fragaria × ananassa',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your strawberry plants look healthy! Good runner management and renewal keeps plants productive.',
    symptoms:       ['Bright green healthy leaves', 'White flowers developing', 'No spots or lesions', 'Vigorous runner production'],
    causes:         ['Rich well-draining soil', 'Consistent moisture', 'Full sun', 'Proper fertilization'],
    prevention:     ['Renovate bed after harvest', 'Remove old leaves', 'Control runners', 'Apply balanced fertilizer'],
    treatments:     ['Continue current care', 'Apply potassium fertilizer before fruiting'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Strawberry Fertilizer', type: 'Organic', description: 'Balanced nutrition for fruit production', frequency: 'Every 3 weeks'),
    ],
  ),

  // Orange Diseases
  'Orange___Haunglongbing_(Citrus_greening)': DiseaseInfo(
    name:           'Citrus Greening (HLB)',
    scientificName: 'Candidatus Liberibacter asiaticus',
    category:       'Bacterial',
    categoryColor:  AppColors.danger,
    severity:       'High',
    overview:       'The most destructive citrus disease worldwide. Spread by the Asian citrus psyllid, it causes blotchy mottling, lopsided bitter fruits and eventual tree death. There is no cure.',
    symptoms:       ['Blotchy yellow mottling on leaves', 'Asymmetric yellowing', 'Small lopsided bitter fruits', 'Premature fruit drop', 'Twig dieback and tree decline'],
    causes:         ['Asian citrus psyllid insect transmission', 'Infected budwood', 'No natural resistance in citrus'],
    prevention:     ['Control psyllid populations aggressively', 'Use certified disease-free trees', 'Inspect regularly for psyllids', 'Report suspected cases immediately'],
    treatments:     ['No cure available', 'Remove and destroy infected trees', 'Apply aggressive psyllid control', 'Nutritional therapy to prolong tree life'],
    spreadRate:     'Fast',
    affectedParts:  'Leaves, Fruit, Whole Tree',
    remedies: [
      RemedyInfo(name: 'Imidacloprid', type: 'Chemical', description: 'Controls Asian citrus psyllid vector', frequency: 'Every 3 months'),
      RemedyInfo(name: 'Foliar Micronutrients', type: 'Organic', description: 'Nutritional therapy to prolong tree life', frequency: 'Monthly'),
    ],
  ),

  // Rose Diseases
  'Rose___blight': DiseaseInfo(
    name:           'Rose Blight',
    scientificName: 'Botrytis cinerea',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A gray mold disease affecting roses particularly in cool humid conditions causing bud blast, petal spotting and stem cankers.',
    symptoms:       ['Gray fuzzy mold on flowers and buds', 'Brown water-soaked spots on petals', 'Bud blast — buds fail to open', 'Stem cankers at soil level', 'Dieback of young shoots'],
    causes:         ['High humidity above 90%', 'Cool temperatures', 'Poor air circulation', 'Overhead watering', 'Damaged or dead plant tissue'],
    prevention:     ['Space roses for good air flow', 'Water at base only', 'Remove dead flowers promptly', 'Avoid wetting foliage'],
    treatments:     ['Remove infected plant parts immediately', 'Apply fungicide', 'Improve air circulation', 'Reduce humidity around plants'],
    spreadRate:     'Moderate',
    affectedParts:  'Flowers, Stems, Leaves',
    remedies: [
      RemedyInfo(name: 'Iprodione', type: 'Chemical', description: 'Effective against Botrytis gray mold', frequency: 'Every 7–14 days'),
      RemedyInfo(name: 'Bacillus subtilis', type: 'Organic', description: 'Biological fungicide', frequency: 'Every 7 days'),
    ],
  ),

  'Rose___healthy': DiseaseInfo(
    name:           'Healthy Rose',
    scientificName: 'Rosa spp.',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your rose plant is healthy and beautiful! Regular deadheading and feeding will keep it blooming prolifically.',
    symptoms:       ['Dark glossy green leaves', 'Strong canes', 'Abundant healthy buds', 'No spots or discoloration'],
    causes:         ['Good soil with compost', 'Regular watering', 'Full sun 6+ hours', 'Regular feeding'],
    prevention:     ['Water at base not on leaves', 'Apply mulch around base', 'Deadhead spent blooms', 'Apply balanced rose fertilizer'],
    treatments:     ['Continue current care', 'Apply rose fertilizer after each bloom cycle'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Rose Fertilizer', type: 'Organic', description: 'Promotes abundant blooming', frequency: 'Every 4–6 weeks'),
    ],
  ),

  // Hibiscus Diseases
  'Hibiscus_Blight': DiseaseInfo(
    name:           'Hibiscus Blight',
    scientificName: 'Phytophthora spp.',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A water mold disease affecting hibiscus causing wilting, stem rot and dieback. Often strikes during wet periods or overwatering.',
    symptoms:       ['Sudden wilting of branches', 'Dark brown stem cankers', 'Root and crown rot', 'Yellowing leaves', 'Plant collapse'],
    causes:         ['Overwatering or poor drainage', 'Infected soil', 'Warm wet conditions', 'Stem wounds'],
    prevention:     ['Ensure excellent drainage', 'Avoid overwatering', 'Do not plant in low areas', 'Sterilize pruning tools'],
    treatments:     ['Improve drainage immediately', 'Apply phosphonate fungicide', 'Remove infected tissue', 'Reduce watering frequency'],
    spreadRate:     'Moderate',
    affectedParts:  'Stems, Roots, Leaves',
    remedies: [
      RemedyInfo(name: 'Phosphorous Acid', type: 'Chemical', description: 'Systemic Phytophthora control', frequency: 'Every 30 days'),
      RemedyInfo(name: 'Trichoderma', type: 'Organic', description: 'Biological soil fungicide', frequency: 'Monthly soil drench'),
    ],
  ),

  'Hibiscus_Death_leaf': DiseaseInfo(
    name:           'Hibiscus Death Leaf',
    scientificName: 'Multiple pathogens',
    category:       'Fungal',
    categoryColor:  AppColors.danger,
    severity:       'High',
    overview:       'Severe leaf death and dieback in hibiscus caused by a combination of fungal pathogens and environmental stress leading to complete leaf loss.',
    symptoms:       ['Complete leaf browning and death', 'Leaves dry and fall rapidly', 'Stem dieback', 'No new growth', 'Plant decline'],
    causes:         ['Fungal infection combined with stress', 'Extreme heat or cold', 'Root damage', 'Overwatering or drought'],
    prevention:     ['Maintain consistent watering', 'Protect from extreme temperatures', 'Ensure good drainage', 'Apply preventive fungicide'],
    treatments:     ['Remove all dead leaves and branches', 'Apply systemic fungicide', 'Reduce environmental stress', 'Apply root stimulant'],
    spreadRate:     'Fast',
    affectedParts:  'Leaves, Stems',
    remedies: [
      RemedyInfo(name: 'Systemic Fungicide', type: 'Chemical', description: 'Treats multiple fungal pathogens', frequency: 'Every 7 days'),
      RemedyInfo(name: 'Root Stimulant', type: 'Organic', description: 'Promotes recovery and new growth', frequency: 'Every 2 weeks'),
    ],
  ),

  'Hibiscus_Scorch': DiseaseInfo(
    name:           'Hibiscus Leaf Scorch',
    scientificName: 'Environmental / Bacterial',
    category:       'Bacterial',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'Browning and scorching of hibiscus leaf margins caused by environmental stress, bacterial infection or root problems affecting water uptake.',
    symptoms:       ['Brown crispy leaf margins', 'Scorched leaf edges', 'Yellowing between veins', 'Premature leaf drop', 'Wilting in heat'],
    causes:         ['Drought stress', 'Root damage', 'Salt toxicity', 'Bacterial leaf scorch', 'Extreme heat'],
    prevention:     ['Water consistently', 'Avoid salt-based fertilizers near roots', 'Mulch to retain moisture', 'Plant in suitable location'],
    treatments:     ['Increase watering frequency', 'Apply anti-transpirant spray', 'Check roots for damage', 'Apply balanced fertilizer'],
    spreadRate:     'Slow',
    affectedParts:  'Leaves',
    remedies: [
      RemedyInfo(name: 'Anti-transpirant Spray', type: 'Organic', description: 'Reduces water loss from leaves', frequency: 'Every 2 weeks in heat'),
      RemedyInfo(name: 'Seaweed Extract', type: 'Organic', description: 'Reduces heat and drought stress', frequency: 'Every 2 weeks'),
    ],
  ),

  'Hibiscus_healthy': DiseaseInfo(
    name:           'Healthy Hibiscus',
    scientificName: 'Hibiscus rosa-sinensis',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your hibiscus is healthy and vibrant! Regular feeding and consistent watering will keep the blooms coming.',
    symptoms:       ['Dark glossy green leaves', 'Abundant flower buds', 'Strong stems', 'Vigorous new growth'],
    causes:         ['Well-draining soil', 'Regular watering', 'Full to partial sun', 'Regular fertilization'],
    prevention:     ['Feed every 2 weeks in growing season', 'Water when top inch of soil dries', 'Prune after flowering', 'Monitor for pests'],
    treatments:     ['Continue current care routine', 'Apply hibiscus fertilizer for more blooms'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Hibiscus Fertilizer', type: 'Organic', description: 'High potassium formula for abundant blooms', frequency: 'Every 2 weeks'),
    ],
  ),

  // Other Healthy Plants
  'Blueberry___healthy': DiseaseInfo(
    name:           'Healthy Blueberry',
    scientificName: 'Vaccinium corymbosum',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your blueberry bush is healthy! Blueberries need acidic soil (pH 4.5-5.5) to thrive.',
    symptoms:       ['Green healthy leaves', 'Good berry development', 'No spots or lesions', 'Strong branch structure'],
    causes:         ['Acidic soil pH 4.5-5.5', 'Consistent moisture', 'Full sun', 'Good drainage'],
    prevention:     ['Test and maintain soil pH', 'Mulch with pine bark', 'Net against birds', 'Apply acid fertilizer'],
    treatments:     ['Continue current care', 'Acidify soil if needed with sulfur'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Acidic Fertilizer', type: 'Organic', description: 'Maintains proper soil pH for blueberries', frequency: 'Spring and summer'),
    ],
  ),

  'Raspberry___healthy': DiseaseInfo(
    name:           'Healthy Raspberry',
    scientificName: 'Rubus idaeus',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your raspberry canes look healthy! Proper cane management is key to good yields.',
    symptoms:       ['Healthy green canes', 'Good leaf color', 'Strong new primocanes', 'No disease signs'],
    causes:         ['Well-draining soil', 'Regular watering', 'Full sun', 'Annual cane management'],
    prevention:     ['Remove fruited canes after harvest', 'Thin new canes to 6 per hill', 'Trellis for support', 'Apply balanced fertilizer in spring'],
    treatments:     ['Continue current care', 'Apply nitrogen fertilizer in spring'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Balanced Fertilizer', type: 'Organic', description: 'Supports vigorous cane growth', frequency: 'Spring application'),
    ],
  ),

  'Soybean___healthy': DiseaseInfo(
    name:           'Healthy Soybean',
    scientificName: 'Glycine max',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your soybean crop looks healthy! Soybeans fix their own nitrogen so minimal fertilizer is needed.',
    symptoms:       ['Dark green trifoliate leaves', 'Strong stems', 'Good pod development', 'No lesions'],
    causes:         ['Well-drained fertile soil', 'Adequate moisture', 'Full sun', 'Proper inoculation with rhizobia'],
    prevention:     ['Rotate with non-legume crops', 'Use certified disease-free seed', 'Inoculate seed with rhizobia', 'Monitor for pest insects'],
    treatments:     ['Continue current care', 'Apply phosphorus fertilizer if needed'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Rhizobium Inoculant', type: 'Organic', description: 'Enhances nitrogen fixation', frequency: 'At planting'),
    ],
  ),

  // Crape Jasmine Diseases
  'Crape_jasmine_healthy': DiseaseInfo(
    name:           'Healthy Crape Jasmine',
    scientificName: 'Tabernaemontana divaricata',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your crape jasmine is healthy and blooming well! A beautiful ornamental plant that requires minimal care.',
    symptoms:       ['Glossy dark green leaves', 'White fragrant flowers', 'Strong branching', 'No disease signs'],
    causes:         ['Well-draining soil', 'Regular watering', 'Partial to full sun', 'Balanced nutrition'],
    prevention:     ['Prune after flowering', 'Water consistently', 'Apply slow-release fertilizer', 'Monitor for pests'],
    treatments:     ['Continue current care', 'Apply balanced fertilizer monthly'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Balanced Fertilizer', type: 'Organic', description: 'Promotes healthy growth and flowering', frequency: 'Monthly'),
    ],
  ),

  'Crape_jasmine_insect_bite': DiseaseInfo(
    name:           'Crape Jasmine Insect Damage',
    scientificName: 'Various insects',
    category:       'Pest',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'Insect feeding damage on crape jasmine leaves causing holes, notching and discoloration. Various insects including caterpillars and beetles may be responsible.',
    symptoms:       ['Holes in leaves', 'Notched leaf margins', 'Skeletonized leaves', 'Visible insects on plant', 'Distorted new growth'],
    causes:         ['Caterpillar feeding', 'Beetle damage', 'Aphid colonies', 'Scale insects'],
    prevention:     ['Inspect plant regularly', 'Remove insects by hand', 'Apply neem oil preventively', 'Encourage beneficial insects'],
    treatments:     ['Identify and remove insects', 'Apply neem oil or insecticidal soap', 'Use systemic insecticide for severe cases', 'Apply Bt for caterpillars'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves, Stems',
    remedies: [
      RemedyInfo(name: 'Neem Oil', type: 'Organic', description: 'Broad-spectrum insect deterrent', frequency: 'Every 7 days'),
      RemedyInfo(name: 'Imidacloprid', type: 'Chemical', description: 'Systemic insecticide for persistent pests', frequency: 'Once per season'),
    ],
  ),

  'Crape_jasmine_Yellow_leaf_disease': DiseaseInfo(
    name:           'Crape Jasmine Yellow Leaf Disease',
    scientificName: 'Phytoplasma / Nutritional',
    category:       'Viral',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'Yellowing of crape jasmine leaves caused by phytoplasma infection or nutritional deficiency, particularly iron or magnesium chlorosis.',
    symptoms:       ['Interveinal yellowing', 'Pale yellow new leaves', 'Stunted growth', 'Reduced flowering', 'Leaf drop'],
    causes:         ['Phytoplasma transmitted by leafhoppers', 'Iron deficiency in alkaline soil', 'Magnesium deficiency', 'Root problems'],
    prevention:     ['Control leafhopper insects', 'Maintain proper soil pH', 'Apply chelated iron if needed', 'Ensure good drainage'],
    treatments:     ['Apply chelated iron foliar spray', 'Treat leafhoppers with insecticide', 'Acidify soil if pH too high', 'Apply magnesium sulfate'],
    spreadRate:     'Slow',
    affectedParts:  'Leaves',
    remedies: [
      RemedyInfo(name: 'Chelated Iron Spray', type: 'Chemical', description: 'Corrects iron deficiency chlorosis', frequency: 'Every 2 weeks until green'),
      RemedyInfo(name: 'Magnesium Sulfate', type: 'Organic', description: 'Corrects magnesium deficiency', frequency: 'Monthly foliar spray'),
    ],
  ),

  // Dwarf White Bauhinia Diseases
  'Dwarf_white_bauhinia_healthy': DiseaseInfo(
    name:           'Healthy Dwarf White Bauhinia',
    scientificName: 'Bauhinia acuminata',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your dwarf white bauhinia is healthy! This ornamental shrub produces beautiful white orchid-like flowers.',
    symptoms:       ['Healthy bilobed green leaves', 'White flowers blooming', 'Strong branches', 'No disease signs'],
    causes:         ['Well-draining soil', 'Full sun to partial shade', 'Regular watering', 'Balanced nutrition'],
    prevention:     ['Prune after flowering', 'Water consistently', 'Apply fertilizer in growing season', 'Monitor for pests'],
    treatments:     ['Continue current care', 'Apply slow-release fertilizer'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Slow-release Fertilizer', type: 'Organic', description: 'Supports consistent healthy growth', frequency: 'Every 3 months'),
    ],
  ),

  'Dwarf_white_bauhinia_Death_leaf': DiseaseInfo(
    name:           'Bauhinia Death Leaf',
    scientificName: 'Multiple pathogens',
    category:       'Fungal',
    categoryColor:  AppColors.danger,
    severity:       'High',
    overview:       'Severe leaf death in dwarf white bauhinia characterized by rapid browning and complete leaf loss, often triggered by fungal infection combined with stress.',
    symptoms:       ['Rapid complete leaf browning', 'Leaves dry and fall', 'Branch dieback', 'No recovery of affected parts', 'Overall plant decline'],
    causes:         ['Fungal infection', 'Extreme heat combined with drought', 'Waterlogging', 'Root rot'],
    prevention:     ['Ensure good drainage', 'Avoid waterlogging', 'Water consistently', 'Apply preventive fungicide in wet season'],
    treatments:     ['Remove all dead material', 'Apply systemic fungicide', 'Reduce environmental stress', 'Apply root conditioner'],
    spreadRate:     'Fast',
    affectedParts:  'Leaves, Branches',
    remedies: [
      RemedyInfo(name: 'Systemic Fungicide', type: 'Chemical', description: 'Controls multiple fungal pathogens', frequency: 'Every 7–10 days'),
      RemedyInfo(name: 'Root Conditioner', type: 'Organic', description: 'Promotes recovery and new root growth', frequency: 'Every 2 weeks'),
    ],
  ),

  'Dwarf_white_bauhinia_Yellow_Leaf_Disease': DiseaseInfo(
    name:           'Bauhinia Yellow Leaf Disease',
    scientificName: 'Nutritional / Phytoplasma',
    category:       'Viral',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'Yellowing of bauhinia leaves due to nutritional deficiency or phytoplasma infection causing chlorosis and reduced plant vigor.',
    symptoms:       ['Yellowing of leaves', 'Interveinal chlorosis', 'Pale new growth', 'Reduced flowering', 'Overall plant yellowing'],
    causes:         ['Iron or manganese deficiency', 'Alkaline soil', 'Phytoplasma infection', 'Root problems'],
    prevention:     ['Maintain acidic to neutral soil pH', 'Apply chelated micronutrients', 'Control leafhopper insects', 'Ensure proper drainage'],
    treatments:     ['Apply chelated iron or manganese', 'Acidify soil if needed', 'Control insect vectors', 'Apply balanced fertilizer'],
    spreadRate:     'Slow',
    affectedParts:  'Leaves',
    remedies: [
      RemedyInfo(name: 'Chelated Micronutrients', type: 'Chemical', description: 'Corrects multiple nutrient deficiencies', frequency: 'Every 2 weeks'),
      RemedyInfo(name: 'Soil Acidifier', type: 'Organic', description: 'Lowers soil pH for better nutrient uptake', frequency: 'Monthly'),
    ],
  ),

  // Night Flowering Jasmine Diseases
  'Night_flowering_jasmine_healthy': DiseaseInfo(
    name:           'Healthy Night Flowering Jasmine',
    scientificName: 'Nyctanthes arbor-tristis',
    category:       'Healthy',
    categoryColor:  AppColors.neonGreen,
    severity:       'Low',
    overview:       'Your night flowering jasmine (Parijat) is healthy! This sacred plant produces fragrant flowers that bloom at night.',
    symptoms:       ['Healthy green leaves', 'Fragrant white-orange flowers', 'Strong stems', 'No disease signs'],
    causes:         ['Well-draining soil', 'Full sun to partial shade', 'Regular watering', 'Balanced nutrition'],
    prevention:     ['Prune after flowering', 'Water consistently but avoid waterlogging', 'Apply fertilizer in growing season'],
    treatments:     ['Continue current care', 'Apply balanced fertilizer'],
    spreadRate:     'None',
    affectedParts:  'None',
    remedies: [
      RemedyInfo(name: 'Balanced Fertilizer', type: 'Organic', description: 'Promotes healthy growth and flowering', frequency: 'Monthly'),
    ],
  ),

  'Night_flowering_jasmine_Early_blight': DiseaseInfo(
    name:           'Night Jasmine Early Blight',
    scientificName: 'Alternaria spp.',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'Early blight fungal disease affecting night flowering jasmine causing dark spots with concentric rings on leaves leading to defoliation.',
    symptoms:       ['Dark brown spots with rings', 'Yellow halo around spots', 'Lower leaves affected first', 'Premature leaf drop', 'Reduced flowering'],
    causes:         ['Fungal spores', 'Warm humid conditions', 'Overhead watering', 'Plant stress'],
    prevention:     ['Water at base only', 'Improve air circulation', 'Remove infected leaves promptly', 'Apply preventive fungicide'],
    treatments:     ['Apply copper-based fungicide', 'Remove infected leaves', 'Reduce humidity around plant', 'Apply neem oil'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves',
    remedies: [
      RemedyInfo(name: 'Copper Fungicide', type: 'Organic', description: 'Broad-spectrum fungal control', frequency: 'Every 7–10 days'),
      RemedyInfo(name: 'Mancozeb', type: 'Chemical', description: 'Protectant fungicide', frequency: 'Every 7 days'),
    ],
  ),

  'Night_flowering_jasmine_Red_spot': DiseaseInfo(
    name:           'Night Jasmine Red Spot',
    scientificName: 'Cercospora spp.',
    category:       'Fungal',
    categoryColor:  AppColors.warning,
    severity:       'Medium',
    overview:       'A fungal disease causing distinctive red to purple spots on night flowering jasmine leaves that can coalesce and cause significant defoliation.',
    symptoms:       ['Red to purple circular spots', 'Dark red spot borders', 'Spots coalesce in severe cases', 'Yellowing around spots', 'Leaf drop'],
    causes:         ['Cercospora fungal spores', 'Warm wet conditions', 'Poor air circulation', 'Infected plant debris'],
    prevention:     ['Remove fallen infected leaves', 'Improve air circulation', 'Avoid overhead watering', 'Apply preventive fungicide'],
    treatments:     ['Apply fungicide at first sign', 'Remove heavily infected leaves', 'Improve drainage', 'Apply copper spray'],
    spreadRate:     'Moderate',
    affectedParts:  'Leaves',
    remedies: [
      RemedyInfo(name: 'Copper Oxychloride', type: 'Organic', description: 'Effective against Cercospora leaf spots', frequency: 'Every 10 days'),
      RemedyInfo(name: 'Propiconazole', type: 'Chemical', description: 'Systemic fungicide for leaf spots', frequency: 'Every 14 days'),
    ],
  ),
};

List<RemedyInfo> getRemediesForDisease(String diseaseName) {
  final info = _diseaseDatabase[diseaseName];
  if (info == null) return [];
  return info.remedies;
}

// Screen that displays in-depth information about a specific plant disease, organized into tabs.
class DiseaseDetailScreen extends StatefulWidget {
  final String diseaseName;
  const DiseaseDetailScreen({super.key, required this.diseaseName});

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = _diseaseDatabase[widget.diseaseName];

    // If disease not in database yet
    if (info == null) return _buildNotFound();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          _buildTopBar(info),
          _buildHeroCard(info),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildOverviewTab(info),
                _buildSymptomsTab(info),
                _buildTreatmentTab(info),
                _buildRemediesTab(info),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Standard app bar with navigation and scientific name display
  Widget _buildTopBar(DiseaseInfo info) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        top:    statusBarHeight + 8,
        left:   14,
        right:  14,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color:  AppColors.bgColor,
        border: Border(
          bottom: BorderSide(
              color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: AppStyles.iconCircle,
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Disease Info', style: AppText.title),
                Text(info.scientificName,
                    style: AppText.tip.copyWith(
                        color: Colors.white38,
                        fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Main summary card showing category, risk level, and primary stats
  Widget _buildHeroCard(DiseaseInfo info) {
    // ✅ Using AppSeverity helper — single source of truth
    final severityColor = AppSeverity.color(info.severity);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            info.categoryColor.withOpacity(0.15),
            AppColors.surfaceColor,
          ],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lgBR,
        border: Border.all(
            color: info.categoryColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category badge
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:        info.categoryColor.withOpacity(0.12),
                    borderRadius: AppRadius.pillBR,
                    border: Border.all(
                        color: info.categoryColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_categoryIcon(info.category),
                          color: info.categoryColor, size: 12),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(info.category,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:      info.categoryColor,
                              fontSize:   11,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Severity badge
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:        severityColor.withOpacity(0.12),
                    borderRadius: AppRadius.pillBR,
                    border: Border.all(
                        color: severityColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: severityColor, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text('${info.severity} Risk',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:      severityColor,
                              fontSize:   11,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(info.name,
              style: AppText.heading.copyWith(fontSize: 22)),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              _statChip(Icons.speed_rounded,       'Spread',   info.spreadRate),
              const SizedBox(width: 8),
              _statChip(Icons.eco_rounded,          'Affects',  info.affectedParts),
            ],
          ),
        ],
      ),
    );
  }

  // Navigation tab bar for switching between Overview, Symptoms, and Treatment
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color:        AppColors.surfaceColor,
        borderRadius: AppRadius.mdBR,
      ),
      child: TabBar(
        controller:          _tabCtrl,
        indicatorSize:       TabBarIndicatorSize.tab,
        dividerColor:        Colors.transparent,
        indicator: BoxDecoration(
          color:        AppColors.neonGreen.withOpacity(0.15),
          borderRadius: AppRadius.mdBR,
          border: Border.all(
              color: AppColors.neonGreen.withOpacity(0.4), width: 1),
        ),
        labelColor:          AppColors.neonGreen,
        unselectedLabelColor: Colors.white38,
        labelStyle:   const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Symptoms'),
          Tab(text: 'Treatment'),
          Tab(text: 'Remedies'),
        ],
      ),
    );
  }

  // Displays general disease information, causes, and prevention methods
  Widget _buildOverviewTab(DiseaseInfo info) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // What is it
        _sectionHeader(Icons.info_outline_rounded, 'What is it?'),
        const SizedBox(height: 10),
        Container(
          padding: AppSpacing.cardPadding,
          decoration: AppStyles.card,
          child: Text(info.overview, style: AppText.body),
        ),
        const SizedBox(height: 20),

        // Causes
        _sectionHeader(Icons.search_rounded, 'Causes'),
        const SizedBox(height: 10),
        ...info.causes.map((c) => _bulletCard(c, AppColors.warning)),

        const SizedBox(height: 20),

        // Prevention
        _sectionHeader(Icons.shield_outlined, 'Prevention'),
        const SizedBox(height: 10),
        ...info.prevention.map((p) => _bulletCard(p, AppColors.neonGreen)),

        const SizedBox(height: 80),
      ],
    );
  }

  // Lists specific visual indicators to help users identify the disease
  Widget _buildSymptomsTab(DiseaseInfo info) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.sick_rounded, 'What to look for'),
        const SizedBox(height: 10),
        Container(
          padding: AppSpacing.cardPadding,
          decoration: AppStyles.card,
          child: Column(
            children: info.symptoms.asMap().entries.map((e) {
              final isLast = e.key == info.symptoms.length - 1;
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color:        AppColors.danger.withOpacity(0.12),
                          shape:        BoxShape.circle,
                          border: Border.all(
                              color: AppColors.danger.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: TextStyle(
                              color:      AppColors.danger,
                              fontSize:   11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(e.value, style: AppText.body),
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 10),
                    Divider(
                        color: Colors.white.withOpacity(0.05),
                        height: 1),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // Provides actionable treatment steps for handling the infection
  Widget _buildTreatmentTab(DiseaseInfo info) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.medical_services_rounded, 'Step-by-Step Treatment'),
        const SizedBox(height: 10),
        ...info.treatments.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: AppStyles.card,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color:        AppColors.neonGreen.withOpacity(0.12),
                    borderRadius: AppRadius.smBR,
                    border: Border.all(
                        color: AppColors.neonGreen.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      '${e.key + 1}',
                      style: TextStyle(
                        color:      AppColors.neonGreen,
                        fontSize:   13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(e.value, style: AppText.body),
                  ),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 80),
      ],
    );
  }

  // Lists specific organic and chemical remedies recommended for this disease
  Widget _buildRemediesTab(DiseaseInfo info) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader(Icons.eco_rounded, 'Recommended Remedies'),
        const SizedBox(height: 10),
        ...info.remedies.map((r) {
          final isOrganic = r.type == 'Organic';
          final typeColor = isOrganic ? AppColors.neonGreen : AppColors.warning;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: AppSpacing.cardPadding,
              decoration: AppStyles.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color:        typeColor.withOpacity(0.12),
                          borderRadius: AppRadius.smBR,
                          border: Border.all(
                              color: typeColor.withOpacity(0.3)),
                        ),
                        child: Icon(
                          isOrganic
                              ? Icons.eco_rounded
                              : Icons.science_rounded,
                          color: typeColor, size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name,
                                style: AppText.subheading
                                    .copyWith(fontSize: 14)),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color:        typeColor.withOpacity(0.1),
                                borderRadius: AppRadius.pillBR,
                                border: Border.all(
                                    color: typeColor.withOpacity(0.3)),
                              ),
                              child: Text(r.type,
                                  style: TextStyle(
                                    color:      typeColor,
                                    fontSize:   10,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(
                      color: Colors.white.withOpacity(0.06), height: 1),
                  const SizedBox(height: 10),
                  Text(r.description, style: AppText.body),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          color: Colors.white38, size: 14),
                      const SizedBox(width: 5),
                      Text('Apply: ${r.frequency}',
                          style: AppText.tip.copyWith(
                              color: Colors.white38)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  // Fallback UI for when a disease ID is not found in the local database
  Widget _buildNotFound() {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: AppStyles.iconCircle,
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Icon(Icons.search_off_rounded,
                color: AppColors.neonGreen.withOpacity(0.4), size: 60),
            const SizedBox(height: 16),
            Text('No Info Available', style: AppText.subheading),
            const SizedBox(height: 6),
            Text('Details for "${widget.diseaseName}" not found',
                style: AppText.caption),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // UI helper methods for consistent icon and card styling
  IconData _categoryIcon(String category) => switch (category) {
        'Viral'     => Icons.coronavirus_rounded,
        'Fungal'    => Icons.grass_rounded,
        'Bacterial' => Icons.biotech_rounded,
        _           => Icons.bug_report_rounded,
      };

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonGreen, size: 18),
        const SizedBox(width: 8),
        Text(title, style: AppText.subheading),
      ],
    );
  }

  Widget _bulletCard(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: AppStyles.card,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8, height: 8,
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color:  color,
                shape:  BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: AppText.body)),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color:        AppColors.bgColor.withOpacity(0.5),
          borderRadius: AppRadius.smBR,
          border: Border.all(
              color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white38, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.tip.copyWith(color: Colors.white30)),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:      Colors.white70,
                        fontSize:   12,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}