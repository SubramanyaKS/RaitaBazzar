import 'package:flutter_test/flutter_test.dart';
import 'package:raitabazzar/utils/crop_dictionary.dart';

void main() {
  group('Vernacular Crop Search Dictionary Tests', () {
    test('Kannada script matches English crop names', () {
      expect(CropDictionary.matches('ಟೊಮೇಟೊ', 'Bangalore Fresh Tomatoes'), isTrue);
      expect(CropDictionary.matches('ತೊಮೆಟೊ', 'Tomato (Hybrid)'), isTrue);
      expect(CropDictionary.matches('ಈರುಳ್ಳಿ', 'Red Onions'), isTrue);
      expect(CropDictionary.matches('ಆಲೂಗಡ್ಡೆ', 'Potatoes Jyoti'), isTrue);
      expect(CropDictionary.matches('ರಾಗಿ', 'Ragi (Finger Millet)'), isTrue);
      expect(CropDictionary.matches('ಭತ್ತ', 'Sona Masoori Paddy'), isTrue);
      expect(CropDictionary.matches('ಮೆಣಸಿನಕಾಯಿ', 'Green Chilli'), isTrue);
      expect(CropDictionary.matches('ಬೆಂಡೆಕಾಯಿ', 'Ladies Finger'), isTrue);
      expect(CropDictionary.matches('ಕಬ್ಬು', 'Sugarcane CO 86032'), isTrue);
      expect(CropDictionary.matches('ಬಾಳೆಹಣ್ಣು', 'Robusta Banana'), isTrue);
    });

    test('Hindi script matches English crop names', () {
      expect(CropDictionary.matches('टमाटर', 'Bangalore Fresh Tomatoes'), isTrue);
      expect(CropDictionary.matches('प्याज', 'Red Onions'), isTrue);
      expect(CropDictionary.matches('प्याज़', 'Red Onions'), isTrue);
      expect(CropDictionary.matches('आलू', 'Potatoes Jyoti'), isTrue);
      expect(CropDictionary.matches('चावल', 'Sona Masoori Paddy'), isTrue);
      expect(CropDictionary.matches('मिर्च', 'Green Chilli'), isTrue);
      expect(CropDictionary.matches('भिंडी', 'Ladies Finger'), isTrue);
    });

    test('Transliterated Kanglish/Hinglish matches English crop names', () {
      expect(CropDictionary.matches('eerulli', 'Red Onions'), isTrue);
      expect(CropDictionary.matches('irulli', 'Red Onions'), isTrue);
      expect(CropDictionary.matches('aalugadde', 'Potatoes'), isTrue);
      expect(CropDictionary.matches('menasinakayi', 'Green Chilli'), isTrue);
      expect(CropDictionary.matches('tamatar', 'Tomatoes'), isTrue);
      expect(CropDictionary.matches('pyaz', 'Red Onions'), isTrue);
      expect(CropDictionary.matches('kanda', 'Red Onions'), isTrue);
    });

    test('English search continues to work normally', () {
      expect(CropDictionary.matches('tomato', 'Bangalore Fresh Tomatoes'), isTrue);
      expect(CropDictionary.matches('onion', 'Red Onions'), isTrue);
      expect(CropDictionary.matches('paddy', 'Sona Masoori Paddy'), isTrue);
    });

    test('Location search continues to work normally', () {
      expect(CropDictionary.matches('Mandya', 'Fresh Tomatoes', location: 'Mandya, Karnataka'), isTrue);
      expect(CropDictionary.matches('Bangalore', 'Red Onions', location: 'Bangalore Rural'), isTrue);
    });

    test('Unrelated query does not match', () {
      expect(CropDictionary.matches('ಮಾವಿನಹಣ್ಣು', 'Tomato (Hybrid)'), isFalse);
      expect(CropDictionary.matches('mango', 'Fresh Tomatoes'), isFalse);
      expect(CropDictionary.matches('cotton', 'Sona Masoori Paddy'), isFalse);
    });
  });
}
