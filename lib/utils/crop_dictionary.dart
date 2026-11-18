class CropSynonym {
  final String canonicalEnglish;
  final String canonicalKannada;
  final String canonicalHindi;
  final List<String> englishVariants;
  final List<String> kannadaVariants;
  final List<String> hindiVariants;
  final List<String> transliteratedVariants;

  const CropSynonym({
    required this.canonicalEnglish,
    required this.canonicalKannada,
    required this.canonicalHindi,
    required this.englishVariants,
    required this.kannadaVariants,
    required this.hindiVariants,
    required this.transliteratedVariants,
  });

  /// Check if the search query matches any variant of this crop
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return false;

    // Check exact or substring in all languages
    for (final word in englishVariants) {
      if (word.contains(q) || q.contains(word)) return true;
    }
    for (final word in kannadaVariants) {
      if (word.contains(q) || q.contains(word)) return true;
    }
    for (final word in hindiVariants) {
      if (word.contains(q) || q.contains(word)) return true;
    }
    for (final word in transliteratedVariants) {
      if (word.contains(q) || q.contains(word)) return true;
    }
    return false;
  }

  /// Check if a crop listing name belongs to this synonym entry
  bool containsCropName(String cropName) {
    final name = cropName.trim().toLowerCase();
    for (final word in englishVariants) {
      if (name.contains(word) || word.contains(name)) return true;
    }
    for (final word in kannadaVariants) {
      if (name.contains(word) || word.contains(name)) return true;
    }
    for (final word in hindiVariants) {
      if (name.contains(word) || word.contains(name)) return true;
    }
    return false;
  }
}

/// Vernacular Crop Search Dictionary for Kannada, English, and Hindi.
/// Supports bidirectional script matching and Kanglish/Manglish transliteration.
class CropDictionary {
  static const List<CropSynonym> synonyms = [
    // 1. Tomato
    CropSynonym(
      canonicalEnglish: 'Tomato',
      canonicalKannada: 'ಟೊಮೇಟೊ',
      canonicalHindi: 'टमाटर',
      englishVariants: ['tomato', 'tomatoes', 'hybrid tomato', 'nati tomato', 'cherry tomato'],
      kannadaVariants: ['ಟೊಮೇಟೊ', 'ತೊಮೆಟೊ', 'ಟೊಮೆಟೊ', 'ನಾಟಿ ಟೊಮೇಟೊ', 'ಹೈಬ್ರಿಡ್ ಟೊಮೇಟೊ'],
      hindiVariants: ['टमाटर', 'तमाटर'],
      transliteratedVariants: ['tometo', 'tamatar', 'naati tomato'],
    ),

    // 2. Onion
    CropSynonym(
      canonicalEnglish: 'Onion',
      canonicalKannada: 'ಈರುಳ್ಳಿ',
      canonicalHindi: 'प्याज',
      englishVariants: ['onion', 'onions', 'red onion', 'white onion', 'bellary onion', 'sambar onion', 'shallot'],
      kannadaVariants: ['ಈರುಳ್ಳಿ', 'ಈರುಳಿ', 'ಬೆಳ್ಳಾರಿ ಈರುಳ್ಳಿ', 'ಕೆಂಪು ಈರುಳ್ಳಿ', 'ಸಾಂಬಾರ್ ಈರುಳ್ಳಿ'],
      hindiVariants: ['प्याज', 'प्याज़', 'कांदा'],
      transliteratedVariants: ['eerulli', 'irulli', 'kanda', 'pyaz', 'pyaj'],
    ),

    // 3. Potato
    CropSynonym(
      canonicalEnglish: 'Potato',
      canonicalKannada: 'ಆಲೂಗಡ್ಡೆ',
      canonicalHindi: 'आलू',
      englishVariants: ['potato', 'potatoes', 'baby potato', 'jyoti potato', 'kufri'],
      kannadaVariants: ['ಆಲೂಗಡ್ಡೆ', 'ಆಲೂಗೆಡ್ಡೆ', 'ಆಲೂ', 'ಆಲೂಗಡ್ಡೆಗಳು'],
      hindiVariants: ['आलू', 'बटाटा'],
      transliteratedVariants: ['aalugadde', 'alugadde', 'aalu', 'aloo', 'batata'],
    ),

    // 4. Paddy / Rice
    CropSynonym(
      canonicalEnglish: 'Paddy',
      canonicalKannada: 'ಭತ್ತ',
      canonicalHindi: 'धान',
      englishVariants: ['paddy', 'rice', 'sona masoori', 'bpt', 'basmati', 'ir 64', 'raw rice', 'boiled rice', 'paddy(common)'],
      kannadaVariants: ['ಭತ್ತ', 'ಅಕ್ಕಿ', 'ಸೋನಾ ಮಸೂರಿ', 'ರಾಜಮುಡಿ', 'ಬಾಸ್ಮತಿ', 'ಕುಚ್ಚಲಕ್ಕಿ'],
      hindiVariants: ['धान', 'चावल', 'बासमती'],
      transliteratedVariants: ['bhatta,', 'bhatta', 'akki', 'dhaan', 'chawal', 'sona masoori'],
    ),

    // 5. Ragi (Finger Millet)
    CropSynonym(
      canonicalEnglish: 'Ragi',
      canonicalKannada: 'ರಾಗಿ',
      canonicalHindi: 'रागी',
      englishVariants: ['ragi', 'finger millet', 'red millet', 'ragi(finger millet)'],
      kannadaVariants: ['ರಾಗಿ', 'ಕೆಂಪು ರಾಗಿ', 'ನಾಟಿ ರಾಗಿ', 'ಇಂದಾಫ್'],
      hindiVariants: ['रागी', 'मड़ुआ', 'नाचणी'],
      transliteratedVariants: ['ragi', 'nachni', 'madua'],
    ),

    // 6. Chilli
    CropSynonym(
      canonicalEnglish: 'Chilli',
      canonicalKannada: 'ಮೆಣಸಿನಕಾಯಿ',
      canonicalHindi: 'मिर्च',
      englishVariants: ['chilli', 'chili', 'chilies', 'green chilli', 'red chilli', 'byadagi', 'guntur', 'chilly', 'green chili'],
      kannadaVariants: ['ಮೆಣಸಿನಕಾಯಿ', 'ಹಸಿಮೆಣಸಿನಕಾಯಿ', 'ಒಣಮೆಣಸಿನಕಾಯಿ', 'ಬ್ಯಾಡಗಿ ಮೆಣಸಿನಕಾಯಿ', 'ಗುಂಟೂರು'],
      hindiVariants: ['मिर्च', 'हरी मिर्च', 'लाल मिर्च', 'मिर्ची'],
      transliteratedVariants: ['menasinakayi,', 'menasinakayi', 'hasi menasinakayi', 'mirchi', 'byadagi'],
    ),

    // 7. Coconut
    CropSynonym(
      canonicalEnglish: 'Coconut',
      canonicalKannada: 'ತೆಂಗಿನಕಾಯಿ',
      canonicalHindi: 'नारियल',
      englishVariants: ['coconut', 'tender coconut', 'copra', 'dry coconut'],
      kannadaVariants: ['ತೆಂಗಿನಕಾಯಿ', 'ಎಳನೀರು', 'ಕೊಬ್ಬರಿ', 'ಒಣ ಕೊಬ್ಬರಿ', 'ತೆಂಗು'],
      hindiVariants: ['नारियल', 'सूखा नारियल', 'गोला', 'डाब'],
      transliteratedVariants: ['tenginakayi', 'elaneeru', 'kobbari', 'nariyal', 'copra'],
    ),

    // 8. Banana
    CropSynonym(
      canonicalEnglish: 'Banana',
      canonicalKannada: 'ಬಾಳೆಹಣ್ಣು',
      canonicalHindi: 'केला',
      englishVariants: ['banana', 'bananas', 'robusta', 'elakki', 'rasabale', 'plantain', 'raw banana'],
      kannadaVariants: ['ಬಾಳೆಹಣ್ಣು', 'ಬಾಳೆಕಾಯಿ', 'ಏಲಕ್ಕಿ ಬಾಳೆ', 'ರೋಬಸ್ಟಾ', 'ನಂಜನಗೂಡು ರಸಬಾಳೆ', 'ಬಾಳೆ'],
      hindiVariants: ['केला', 'कच्चा केला'],
      transliteratedVariants: ['balehannu', 'balekayi', 'elakki bale', 'kela'],
    ),

    // 9. Sugarcane
    CropSynonym(
      canonicalEnglish: 'Sugarcane',
      canonicalKannada: 'ಕಬ್ಬು',
      canonicalHindi: 'गन्ना',
      englishVariants: ['sugarcane', 'cane', 'sugar cane'],
      kannadaVariants: ['ಕಬ್ಬು', 'ಕಬ್ಬಿನ'],
      hindiVariants: ['गन्ना', 'ईख'],
      transliteratedVariants: ['kabbu', 'ganna', 'eekh'],
    ),

    // 10. Ginger
    CropSynonym(
      canonicalEnglish: 'Ginger',
      canonicalKannada: 'ಶುಂಠಿ',
      canonicalHindi: 'अदरक',
      englishVariants: ['ginger', 'green ginger', 'dry ginger', 'ginger(green)'],
      kannadaVariants: ['ಶುಂಠಿ', 'ಹಸಿ ಶುಂಠಿ', 'ಒಣ ಶುಂಠಿ'],
      hindiVariants: ['अदरक', 'सोंठ'],
      transliteratedVariants: ['shunthi', 'adrak', 'sonth'],
    ),

    // 11. Garlic
    CropSynonym(
      canonicalEnglish: 'Garlic',
      canonicalKannada: 'ಬೆಳ್ಳುಳ್ಳಿ',
      canonicalHindi: 'लहसुन',
      englishVariants: ['garlic'],
      kannadaVariants: ['ಬೆಳ್ಳುಳ್ಳಿ', 'ಬೆಳ್ಳುಳಿ'],
      hindiVariants: ['लहसुन', 'लसन'],
      transliteratedVariants: ['bellulli', 'lehsun', 'lasun'],
    ),

    // 12. Carrot
    CropSynonym(
      canonicalEnglish: 'Carrot',
      canonicalKannada: 'ಕ್ಯಾರೆಟ್',
      canonicalHindi: 'गाजर',
      englishVariants: ['carrot', 'carrots', 'red carrot'],
      kannadaVariants: ['ಕ್ಯಾರೆಟ್', 'ಗಜ್ಜರಿ', 'ಕ್ಯಾರಟ್'],
      hindiVariants: ['गाजर'],
      transliteratedVariants: ['carrot', 'gajjari', 'gajar'],
    ),

    // 13. Beetroot
    CropSynonym(
      canonicalEnglish: 'Beetroot',
      canonicalKannada: 'ಬೀಟ್ರೂಟ್',
      canonicalHindi: 'चुकंदर',
      englishVariants: ['beetroot', 'beet'],
      kannadaVariants: ['ಬೀಟ್ರೂಟ್', 'ಬೀಟ್ ರೂಟ್'],
      hindiVariants: ['चुकंदर'],
      transliteratedVariants: ['beetroot', 'chukandar'],
    ),

    // 14. Brinjal (Eggplant)
    CropSynonym(
      canonicalEnglish: 'Brinjal',
      canonicalKannada: 'ಬದನೆಕಾಯಿ',
      canonicalHindi: 'बैंगन',
      englishVariants: ['brinjal', 'eggplant', 'aubergine'],
      kannadaVariants: ['ಬದನೆಕಾಯಿ', 'ಬದನೆ', 'ಗುಂಡು ಬದನೆ', 'ಹಸಿರು ಬದನೆ'],
      hindiVariants: ['बैंगन', 'भांटा'],
      transliteratedVariants: ['badanekayi', 'badane', 'baingan'],
    ),

    // 15. Ladies Finger (Okra)
    CropSynonym(
      canonicalEnglish: 'Ladies Finger',
      canonicalKannada: 'ಬೆಂಡೆಕಾಯಿ',
      canonicalHindi: 'भिंडी',
      englishVariants: ['ladies finger', 'lady finger', 'okra', 'bhindi'],
      kannadaVariants: ['ಬೆಂಡೆಕಾಯಿ', 'ಬೆಂಡೆ'],
      hindiVariants: ['भिंडी', 'ओकरा'],
      transliteratedVariants: ['bendekayi', 'bende', 'bhindi', 'okra'],
    ),

    // 16. Cauliflower
    CropSynonym(
      canonicalEnglish: 'Cauliflower',
      canonicalKannada: 'ಹೂಕೋಸು',
      canonicalHindi: 'फूलगोभी',
      englishVariants: ['cauliflower', 'gobi'],
      kannadaVariants: ['ಹೂಕೋಸು', 'ಹೂ ಕೋಸು'],
      hindiVariants: ['फूलगोभी', 'गोभी'],
      transliteratedVariants: ['hookosu', 'phool gobhi', 'gobi'],
    ),

    // 17. Cabbage
    CropSynonym(
      canonicalEnglish: 'Cabbage',
      canonicalKannada: 'ಎಲೆಕೋಸು',
      canonicalHindi: 'पत्तागोभी',
      englishVariants: ['cabbage', 'green cabbage'],
      kannadaVariants: ['ಎಲೆಕೋಸು', 'ಎಲೆ ಕೋಸು'],
      hindiVariants: ['पत्तागोभी', 'पत्ता गोभी', 'बंदगोभी'],
      transliteratedVariants: ['elekosu', 'patta gobhi', 'band gobhi'],
    ),

    // 18. Cucumber
    CropSynonym(
      canonicalEnglish: 'Cucumber',
      canonicalKannada: 'ಸೌತೆಕಾಯಿ',
      canonicalHindi: 'खीरा',
      englishVariants: ['cucumber', 'cucumbar(kheera)', 'kheera'],
      kannadaVariants: ['ಸೌತೆಕಾಯಿ', 'ಸೌತೆ', 'ಮುಳ್ಳು ಸೌತೆ'],
      hindiVariants: ['खीरा', 'ककड़ी'],
      transliteratedVariants: ['sauthekayi', 'sowtekayi', 'kheera', 'kakdi'],
    ),

    // 19. Maize / Corn
    CropSynonym(
      canonicalEnglish: 'Maize',
      canonicalKannada: 'ಮೆಕ್ಕೆಜೋಳ',
      canonicalHindi: 'मक्का',
      englishVariants: ['maize', 'corn', 'sweet corn', 'baby corn', 'popcorn'],
      kannadaVariants: ['ಮೆಕ್ಕೆಜೋಳ', 'ಮೆಕ್ಕೆ ಜೋಳ', 'ಜೋಳ', 'ಸ್ವೀಟ್ ಕಾರ್ನ್'],
      hindiVariants: ['मक्का', 'भुट्टा', 'कॉर्न'],
      transliteratedVariants: ['mekke jola', 'jola', 'makka', 'bhutta', 'corn'],
    ),

    // 20. Red Gram (Tur)
    CropSynonym(
      canonicalEnglish: 'Red Gram',
      canonicalKannada: 'ತೊಗರಿ',
      canonicalHindi: 'अरहर',
      englishVariants: ['red gram', 'tur', 'toor', 'pigeon pea', 'thogrikai'],
      kannadaVariants: ['ತೊಗರಿ', 'ತೊಗರಿ ಬೇಳೆ', 'ತೊಗರಿಕಾಯಿ'],
      hindiVariants: ['अरहर', 'तुअर', 'तुवर', 'दाल'],
      transliteratedVariants: ['thogari', 'thogarikai', 'arhar', 'toor'],
    ),

    // 21. Bengal Gram (Chana)
    CropSynonym(
      canonicalEnglish: 'Bengal Gram',
      canonicalKannada: 'ಕಡಲೆ',
      canonicalHindi: 'चना',
      englishVariants: ['bengal gram', 'chickpea', 'chana', 'gram'],
      kannadaVariants: ['ಕಡಲೆ', 'ಕಡಲೆ ಕಾಳು', 'ಕಡಲೆ ಬೇಳೆ'],
      hindiVariants: ['चना', 'काबुली चना', 'छोले'],
      transliteratedVariants: ['kadale', 'chana', 'chole'],
    ),

    // 22. Groundnut (Peanut)
    CropSynonym(
      canonicalEnglish: 'Groundnut',
      canonicalKannada: 'ನೆಲಗಡಲೆ',
      canonicalHindi: 'मूंगफली',
      englishVariants: ['groundnut', 'peanut', 'peanuts'],
      kannadaVariants: ['ನೆಲಗಡಲೆ', 'ಶೇಂಗಾ', 'ಕಡಲೆಕಾಯಿ'],
      hindiVariants: ['मूंगफली', 'मूँगफली', 'सिंगदाना'],
      transliteratedVariants: ['nelagadale', 'shenga', 'kadalekayi', 'moongphali'],
    ),

    // 23. Arecanut (Betel Nut)
    CropSynonym(
      canonicalEnglish: 'Arecanut',
      canonicalKannada: 'ಅಡಿಕೆ',
      canonicalHindi: 'सुपारी',
      englishVariants: ['arecanut', 'areca nut', 'betel nut', 'supari'],
      kannadaVariants: ['ಅಡಿಕೆ', 'ಅಡಕೆ', 'ರಾಶಿ ಅಡಿಕೆ'],
      hindiVariants: ['सुपारी'],
      transliteratedVariants: ['adike', 'adake', 'supari'],
    ),

    // 24. Cotton
    CropSynonym(
      canonicalEnglish: 'Cotton',
      canonicalKannada: 'ಹತ್ತಿ',
      canonicalHindi: 'कपास',
      englishVariants: ['cotton', 'raw cotton'],
      kannadaVariants: ['ಹತ್ತಿ', 'ಅರಳೆ'],
      hindiVariants: ['कपास', 'रुई'],
      transliteratedVariants: ['hatti', 'kapas', 'rui'],
    ),

    // 25. Beans
    CropSynonym(
      canonicalEnglish: 'Beans',
      canonicalKannada: 'ಬೀನ್ಸ್',
      canonicalHindi: 'बीन्स',
      englishVariants: ['beans', 'french beans', 'cluster beans', 'broad beans'],
      kannadaVariants: ['ಬೀನ್ಸ್', 'ಹುರುಳಿಕಾಯಿ', 'ಚವಳಿಕಾಯಿ', 'ಅವರೆಕಾಯಿ'],
      hindiVariants: ['बीन्स', 'फलियां', 'ग्वारफली'],
      transliteratedVariants: ['beans', 'hurulikayi', 'chavalikayi', 'avarekayi'],
    ),

    // 26. Capsicum
    CropSynonym(
      canonicalEnglish: 'Capsicum',
      canonicalKannada: 'ದೊಣ್ಣೆ ಮೆಣಸಿನಕಾಯಿ',
      canonicalHindi: 'शिमला मिर्च',
      englishVariants: ['capsicum', 'bell pepper', 'chilly capsicum'],
      kannadaVariants: ['ಕ್ಯಾಪ್ಸಿಕಂ', 'ದೊಣ್ಣೆ ಮೆಣಸಿನಕಾಯಿ'],
      hindiVariants: ['शिमला मिर्च', 'कैप्सಿಕम'],
      transliteratedVariants: ['capsicum', 'donne menasinakayi', 'shimla mirch'],
    ),

    // 27. Mango
    CropSynonym(
      canonicalEnglish: 'Mango',
      canonicalKannada: 'ಮಾವಿನಹಣ್ಣು',
      canonicalHindi: 'आम',
      englishVariants: ['mango', 'mangoes', 'totapuri', 'alphonso', 'badami', 'kesar', 'raw mango'],
      kannadaVariants: ['ಮಾವಿನಹಣ್ಣು', 'ಮಾವಿನಕಾಯಿ', 'ತೋತಾಪುರಿ', 'ಬಾದಾಮಿ', 'ಮಾವಿನ'],
      hindiVariants: ['आम', 'कच्चा आम', 'तोतापरी', 'बादामी'],
      transliteratedVariants: ['mavina hannu', 'mavinakayi', 'aam', 'totapuri', 'badami'],
    ),
  ];

  /// Core matching algorithm:
  /// Evaluates whether a search [query] matches a [cropName] using:
  /// 1. Direct case-insensitive substring match
  /// 2. Location matching (if [location] is provided)
  /// 3. Category matching (if [category] is provided)
  /// 4. Vernacular Cross-Language Synonym Resolution (Kannada/Hindi/English/Transliterated)
  static bool matches(
    String query,
    String cropName, {
    String? location,
    String? category,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;

    final cleanCrop = cropName.toLowerCase();

    // 1. Direct Substring Check
    if (cleanCrop.contains(cleanQuery)) return true;
    if (location != null && location.toLowerCase().contains(cleanQuery)) return true;
    if (category != null && category.toLowerCase().contains(cleanQuery)) return true;

    // 2. Vernacular Synonym Resolution
    // Find if the query matches ANY known crop synonym group
    for (final syn in synonyms) {
      if (syn.matches(cleanQuery)) {
        // Query belongs to this synonym group!
        // Now check if the listing's cropName belongs to the same synonym group
        if (syn.containsCropName(cleanCrop)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get canonical localized name for a crop
  static String getLocalizedDisplayName(String cropName, String languageCode) {
    final clean = cropName.trim().toLowerCase();
    for (final syn in synonyms) {
      if (syn.containsCropName(clean)) {
        if (languageCode == 'kn') return syn.canonicalKannada;
        if (languageCode == 'hi') return syn.canonicalHindi;
        return syn.canonicalEnglish;
      }
    }
    return cropName;
  }
}
