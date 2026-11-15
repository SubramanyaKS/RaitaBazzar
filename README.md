# 🌾 RaitaBazzar (ರೈತಬಜಾರ್)

> **Direct Farmer-to-Buyer Agricultural Marketplace**  
> Empowering farmers across India to sell their produce directly to retail buyers, bulk consumers, and merchants at fair, transparent market prices without middlemen or commission agents.

---

## 🌟 Key Features

### 👨‍🌾 For Farmers
* **2-Minute Crop Listing:** Take harvest photos directly with the camera or pick from the gallery, set quantity in **Quintals** or **Kg**, expected price, harvest readiness date, and location.
* **Smart Agri Dashboard:**
  * Active produce inventory management (*Mark as Sold*, *Edit Price*, *Delete*).
  * Real-time buyer offers with **Accept** and **Decline** action buttons.
  * Today's APMC Mandi rates preview ticker.
  * Agricultural weather conditions and harvesting advisories.
* **Direct Negotiation:** Receive bids directly from buyers without brokers cutting into profit margins.

### 🛒 For Buyers (Retailers, Wholesalers, Consumers)
* **Fresh Produce Discovery:** Browse crops harvested directly by local farmers with photos, quantity, and pricing.
* **Fast Filters & Search:** Filter by category (*Vegetables, Fruits, Grains & Cereals, Pulses, Spices*) and search in multiple regional languages.
* **Middleman-Free Direct Connect:**
  * 📞 **1-Tap Call:** Directly call the farmer via the phone dialer.
  * 💬 **1-Tap WhatsApp:** Instant WhatsApp chat with pre-filled crop inquiry messages.
  * 🏷️ **Make Offer:** Submit custom price and quantity counter-bids.

### 🌍 Vernacular & Inclusive Design
* **Multilingual:** Seamless, 1-tap switching between **English**, **ಕನ್ನಡ (Kannada)**, and **हिंदी (Hindi)**.
* **Farmer-Centric UX:** High-contrast buttons, visual role cards, and responsive layout optimized for budget Android phones under field sunlight.

---

## 📱 Screenshots & User Flow

```
[ Welcome Screen ]  --> Select Role (Farmer / Buyer) & Language (EN / KN / HI)
       │
       ▼
[ Mobile Login ]    --> Phone Number + OTP Verification
       │
       ├───────────────────────────────┐
       ▼                               ▼
[ Farmer Dashboard ]          [ Buyer Marketplace ]
• List Harvest (Camera)       • Browse Nearby Produce
• Active Crops                • Category Filters & Search
• Buyer Offers (Accept/Decline) • 1-Tap Call & WhatsApp
• APMC Mandi Ticker           • Submit Custom Counter-Bids
• Weather Advisory
```

---

## 🛠️ Tech Stack & Architecture

* **Framework:** [Flutter](https://flutter.dev) (v3.47+ / Dart 3.13+)
* **Design System:** Material 3 with agricultural green palette
* **State Management:** [Provider](https://pub.dev/packages/provider) (`ChangeNotifierProvider`, `Consumer2`)
* **Localization:** `flutter_localizations` with `.arb` translation catalogs (`en`, `kn`, `hi`)
* **Backend Database:** [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore) (Real-time NoSQL streams)
* **Cloud File Storage:** [Firebase Storage](https://firebase.google.com/docs/storage) (Produce photos CDN)
* **Hardware & Communication:**
  * [image_picker](https://pub.dev/packages/image_picker) for Camera & Gallery uploads
  * [url_launcher](https://pub.dev/packages/url_launcher) for direct WhatsApp & phone dialer integration
  * [geolocator](https://pub.dev/packages/geolocator) for GPS coordinates and distance calculations

---

## 📂 Project Structure

```
lib/
├── components/           # Reusable UI widgets (CropThumbnail, OptionChips, etc.)
├── l10n/                 # Localization ARB files (app_en.arb, app_kn.arb, app_hi.arb)
├── models/               # Data models (CropListing, BuyerOffer)
├── provider/             # State providers (ListingProvider, AppProvider, ThemeProvider)
├── screens/              # App screens:
│   ├── welcome_screen.dart       # Role selection & language switcher
│   ├── login_screen.dart         # Mobile number & OTP verification
│   ├── farmer_home_screen.dart   # Farmer dashboard, inventory & offers
│   ├── add_produce_screen.dart   # Camera upload & crop listing form
│   ├── buyer_home_screen.dart    # Buyer feed, search, filters & bidding
│   └── weather_screen.dart       # Ag weather forecasts & farming tips
├── services/             # Backend services (FirebaseService)
├── utils/                # Constants, helpers (ContactHelper), themes
├── firebase_options.dart # Generated Firebase configuration
└── main.dart             # Application root with MultiProvider
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.47 or later)
* Dart SDK (3.13 or later)
* Android Studio / VS Code with Flutter extension
* An active Firebase project (Spark Plan / Free)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/raitabazzar.git
   cd raitabazzar
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Localization Files:**
   ```bash
   flutter gen-l10n
   ```

4. **Run Code Quality Check:**
   ```bash
   flutter analyze   # Checks for 0 errors/warnings
   flutter test      # Runs all widget & unit tests
   ```

5. **Run the App:**
   ```bash
   flutter run
   ```

---

## 🗺️ Roadmap & Status

For detailed project status, upcoming milestones (APMC Mandi Hub, GPS Radius Slider, WhatsApp digital receipts), and cost analyses, refer to:
👉 **[PROJECT_STATUS_AND_ROADMAP.md](PROJECT_STATUS_AND_ROADMAP.md)**

---

## 📄 License
This project is open for community contributions to support Indian farmers. Distributed under the MIT License.
