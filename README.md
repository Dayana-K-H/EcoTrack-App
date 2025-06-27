# EcoTrack - Monitoring Your Ecological Footprint

![EcoTrack App Logo](assets/ecotrack_logo.png)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)

---

## 🌿 1. Project Overview

"EcoTrack" is a simplified mobile application designed to help users understand and reduce their personal carbon footprint. It enables users to easily log daily activities that contribute to their carbon impact, view a summary of their footprint, and receive basic tips for eco-friendly habits. The app aims to foster a sense of personal responsibility and gradual behavioral change towards more sustainable living.

---

## 🌱 2. Chosen SDG and Justification

**Targeted SDG: SDG 12 - Responsible Consumption and Production**

**Justification:** "EcoTrack" directly supports SDG 12 by focusing on:

* **Target 12.8: Ensure that people everywhere have the relevant information and awareness for sustainable development and lifestyles in harmony with nature.** By providing a tool for tracking and visualizing personal carbon impact, the app raises awareness and educates users on the environmental consequences of their daily choices. For example, a user might see that their daily commute by car has a higher carbon impact than using public transport, prompting them to consider alternatives. The app simplifies complex environmental data into an understandable, personal metric.

* **Encouraging Sustainable Lifestyles:** The act of logging activities and seeing the resulting impact incentivizes users to make more conscious, eco-friendly decisions in their daily lives, promoting responsible consumption patterns. The direct feedback loop from logging to seeing an "impact score" can be a powerful motivator for behavioral change. Users might strive to achieve lower daily carbon scores or maintain streaks of eco-friendly habits.

By fostering individual accountability and providing actionable insights into personal environmental impact, EcoTrack contributes significantly to the broader goals of responsible consumption and production at a personal level.

---

## 💻 3. Tech Stack

* **Development Framework:** Flutter (for cross-platform mobile application development)
* **Programming Language:** Dart
* **State Management:** Provider
* **Authentication:** Firebase Authentication
* **Database:** Supabase
* **Flutter SDK Version:** `3.29.0`

**Key Dependencies:**

* `flutter`
* `provider`: For state management.
* `cupertino_icons`: iOS-style icons.
* `flutter_secure_dotenv`: For managing secure environment variables.
* `firebase_core`: Core Firebase services.
* `firebase_auth`: User authentication.
* `intl`: Internationalization and localization utilities.
* `google_sign_in`: Google Sign-In integration.
* `font_awesome_flutter`: For Font Awesome icons.
* `supabase_flutter`: Supabase integration for database.
* `flutter_dotenv`: For managing environment variables.
* `sign_in_button`: Pre-built UI for sign-in buttons.

---

## 🚀 4. Setup & Installation Instructions

To run the EcoTrack application in your development environment:

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/[Your_Username]/[Your_EcoTrack_Repo_Name].git
    cd [Your_EcoTrack_Repo_Name]
    ```

2.  **Install Flutter Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Firebase Authentication:**

    * Create a new project in the [Firebase Console](https://console.firebase.google.com/).
    * Add an Android app to your Firebase project. Follow the instructions to add `google-services.json` to your Flutter project's `android/app/` directory.
    * Ensure you enable the necessary Firebase service (Authentication) from the Firebase Console.
    * If using Google Sign-In, add your app's SHA-1 fingerprint in Firebase settings.

4.  **Configure Supabase:**

    * Create a new project in [Supabase](https://supabase.com/).
    * Get your Supabase URL and `anon` public key from your project settings (`API` section).
    * Initialize Supabase in your Flutter app (e.g., in `main.dart` or a dedicated service) using these credentials.
    * Set up your database tables and Row Level Security (RLS) policies as needed for EcoTrack's data.

5.  **Run the Application:**

    * Ensure an Android device is connected or an emulator is running.
    * Run the application from the terminal:
        ```bash
        flutter run
        ```
    * Or run from VS Code: Open `main.dart` and click "Run" above the `main` function.

---

## 🛠️ 5. How to Use / Contribution Guidelines

### How to Use the App:

1.  **Sign Up/Login:** Create a new account or log in with your credentials.
2.  **Tracking:** Input your daily consumption data (e.g., electricity usage, transportation type, waste amount).
3.  **View Progress:** See your ecological footprint visualized in graphs and numbers.
4.  **Recommendations:** Get advice to reduce your environmental impact.

### Contribution Guidelines:

We welcome contributions from anyone! If you'd like to contribute:

1.  **Fork** this repository.
2.  **Create a new branch** for your feature or fix (`git checkout -b feature/new-feature-name`).
3.  **Make your changes** and test thoroughly.
4.  **Commit your changes** (`git commit -m 'feat: add new feature'`).
5.  **Push your branch** to your fork (`git push origin feature/new-feature-name`).
6.  **Create a Pull Request** to the `main` branch of the original repository.

Ensure your code follows Flutter linting guidelines and includes clear comments.

---

## 🔥 6. Backend Usage: Firebase Auth & Supabase

EcoTrack leverages a combination of Firebase and Supabase for its backend functionalities:

* **Firebase Authentication:** Handles user sign-up, login, and session management securely. This ensures that each user's carbon footprint data is private and accessible only to them.

* **Supabase:**
    * Stores user-specific daily carbon log data (activity type, value, date, and calculated carbon score).
    * Facilitates all Create, Read, Update, and Delete (CRUD) operations for logging new activities, viewing historical data, modifying entries, and removing them. The real-time nature of Supabase ensures the user's log and dashboard summary update instantly when changes occur.

Ensure you have properly initialized both Firebase Auth and Supabase in your Flutter project and have appropriate security rules (Firebase Security Rules for Auth and Supabase RLS for data) to protect user data.

---

## ⬇️ 7. APK Download Link

You can download the release version of the EcoTrack application directly via the link below. This page will guide you to the correct APK for your device's architecture for the best performance.

**Important:** After downloading, you may need to enable "Install unknown apps" or "Unknown sources" in your phone's security settings to install the APK.

* **Download EcoTrack APK:** [https://dayana-k-h.github.io/Ecotrack-Download/](https://dayana-k-h.github.io/Ecotrack-Download/)

---

## 📧 8. Contact

For questions or support, please contact us:

* **Email:** [harahapdayana01@gmail.com](mailto:harahapdayana01@gmail.com)
* **LinkedIn:** [www.linkedin.com/in/dayana-khoiriyah-harahap](https://www.linkedin.com/in/dayana-khoiriyah-harahap)

---

Thank you for using EcoTrack! Let's build a greener future together.