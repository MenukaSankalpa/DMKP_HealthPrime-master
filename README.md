# HealthPrime - Comprehensive Health & Fitness Companion

**HealthPrime** is a feature-rich Flutter mobile application designed to be your all-in-one health companion. Beyond simple tracking, it integrates social competition, gamification, and AI-powered insights to keep users motivated. It leverages Firebase for real-time data and sync, while offering robust offline capabilities to ensure your health journey never stops.

## Features

### Core Functionality
* **Cloud & Offline Sync:** Built on Firebase Firestore for real-time cloud storage, with a custom `OfflineService` that buffers data locally (using Shared Preferences) when the internet is unavailable and syncs automatically when online.
* **Authentication:** Secure login and registration via Email/Password and Google Sign-In, managed by Firebase Auth.
* **State Management:** Utilizes the `Provider` package for efficient state management across complex features like tournaments, friends, and alerts.
* **Background Services:** Implements background tasks (via `workmanager`) to handle notifications and alerts even when the app is closed.

### Main Features

#### Home Tab
* **Holistic Dashboard:** At-a-glance view of your "Health Score," Active Days, Current Streak, and Goals Completed today.
* **Today’s Values:** A interactive grid tracking 9 key metrics: Steps, Calories, Water, Sleep, Heart Rate, Weight, Fruits, Workout, and Mood.
* **AI Health Insights:** Access to the **Google Gemini AI** integration, which analyzes your averages to provide personalized summaries, strengths, and areas for improvement.

#### Records Tab
* **History Log:** A scrollable chronological list of all your past health records.
* **Search by Date:** Built-in calendar picker to filter and find records for specific days.
* **Management:** Easy-to-use overlays to add new records or edit existing entries.

#### Statistics Tab
* **Weekly Charts:** Visual bar charts showing trends over the last 7 days for every metric (Steps, Sleep, Hydration, etc.).
* **Summary Grid:** A quick statistical overview showing your all-time averages for every category.

#### Achievements Tab
* **Personal Bests:** Automatically tracks and highlights your all-time highest records (e.g., "Most Steps," "Longest Workout").
* **Medals System:** A gamified grid of medals that unlock when you hit specific milestones (e.g., "3 Day Streak," "10K Steps").

#### Friends Tab
* **Friends List:** View your connected friends and their online status.
* **Comparison Overlay:** Real-time "VS" mode to compare your average stats directly against a friend's stats.
* **Request Management:** dedicated sections to handle incoming friend requests and monitor pending invites you've sent.

#### Tournaments Tab
* **Active Tournaments:** Track progress in competitions you have joined, complete with leaderboards and milestones.
* **Discover:** Browse and join public tournaments or accept private invites.
* **Creation:** Tools to create your own competitions (Public, Private, or Friends-Only) with custom metrics, durations, and targets.

#### Account & Settings Tab
* **Profile:** Customizable avatar selection and personal details (Age, Gender, Height).
* **Goal Setting:** Fully customizable daily targets for all 9 health metrics.
* **Notifications:** Granular toggles for Friend Requests, Tournament Updates, and Reminders.
* **Security:** Options to change passwords or manage account deletion.

#### Alerts (Overlay)
* **Notification Hub:** A centralized list of all recent updates, accessible from the bell icon in the header.
* **Interactive Requests:** Accept or reject friend requests directly from the notification card.
* **Tournament Actions:** View details and join tournaments immediately when invited or notified of a new public competition.
* **Management:** Dismiss individual alerts once read.

## Technologies Used

* **Flutter:** Cross-platform UI toolkit.
* **Firebase:**
    * **Core & Firestore:** Cloud backend and NoSQL database.
    * **Auth:** User authentication.
* **Google Services:**
    * **Generative AI (Gemini):** For generating personalized health insights.
    * **Google Sign-In:** Integration for Google account authentication.
* **State Management:**
    * **Provider:** For efficient state management and dependency injection.
* **UI & Visualization:**
    * **Syncfusion Flutter Charts:** For visualizing health metrics (weekly charts).
    * **Table Calendar:** For calendar interfaces and history views.
    * **Percent Indicator:** For displaying health goal progress bars and circles.
    * **Font Awesome Flutter:** For an extended set of UI icons.
    * **Cupertino Icons:** For iOS-style iconography.
    * **Flutter SVG:** For rendering scalable vector graphics.
* **Data & Connectivity:**
    * **Shared Preferences:** For local data persistence and offline buffering.
    * **Connectivity Plus:** For monitoring network status and handling offline/online transitions.
* **Background & Notifications:**
    * **Workmanager:** For executing background tasks (e.g., notification scans).
    * **Flutter Local Notifications:** For displaying local push notifications.
* **Utilities:**
    * **Intl:** For date and number formatting.

## How to Use

1.  **Configuration:** Ensure you have the `firebase_options.dart` file generated and your API keys for Firebase set up.

2.  **Installation:** Install dependencies by running:
    ```bash
    flutter pub get
    ```

3.  **Run:** Launch the app on your preferred device:
    ```bash
    flutter run
    ```

4.  **Get Started:** Register an account, set your daily goals in the Account tab, and start logging your data!

5.  **Explore:** Add a friend, join a tournament, or check the AI Insights tab for personalized advice.