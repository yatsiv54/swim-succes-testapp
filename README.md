# Swim Progress Test App

An interactive, premium-designed Flutter application for swimmers to track and build their 12-week training program based on their fastest 100m freestyle pace. 

Built in compliance with high-standard production coding practices using **Clean Architecture** (Feature-First approach) and **BLoC** (via `flutter_bloc`) for clean state management.

---

## 🏊 Swimmer Level Pace Ranges

swimmer level classifications are dynamically computed based on the total seconds of their fastest 100m freestyle pace:

| Swimmer Level | Pace Range (100m Freestyle) | Total Seconds |
| :--- | :--- | :--- |
| **Elite** | `0:45` to `1:09` | `45s` - `69s` |
| **Advanced** | `1:10` to `1:29` | `70s` - `89s` |
| **Intermediate** | `1:30` to `1:59` | `90s` - `119s` |
| **Beginner** | `2:00` to `4:00` | `120s` - `240s` |

---

## 🏛 Clean Architecture Layout

The codebase separates concerns across three primary layers (Domain, Data, and Presentation) grouped by features for maximum scalability:

```
lib/
├── core/
│   ├── errors/          # Common application Failures & Exceptions
│   ├── network/         # HTTP ApiClient wrapper
│   └── theme/           # Global styles and application themes
│
└── features/
    ├── pace_selector/
    │   ├── data/
    │   │   ├── datasources/   # Remote POST data-source (PaceRemoteDataSource)
    │   │   └── repositories/  # PaceRepositoryImpl (error handling translation)
    │   ├── domain/
    │   │   ├── entities/      # Core entities (PaceEntity, SwimmerLevel enum)
    │   │   ├── repositories/  # PaceRepository contract
    │   │   └── usecases/      # SubmitPaceUseCase
    │   └── presentation/
    │       ├── bloc/          # SwimPaceBloc (API states, increments, slider updates)
    │       ├── pages/         # PaceSelectionPage (First Screen - Pixel-Perfect)
    │       └── widgets/       # DirectInputDialog (tap-to-edit Form), slider styles
    │
    └── training_plan/
        └── presentation/
            └── pages/         # TrainingPlanPage (Second Screen - Premium Dashboard)
```

---

## 🚀 Key Features Implemented

1. **Tap to Edit (Direct Input)**:
   - Tapping on the minutes or seconds digits opens a custom popup containing form text fields.
   - Validation ensures minutes stay within `0-5` and seconds remain strictly in the range of `0-59`.
2. **Dynamic Range Slider**:
   - Spans values smoothly. Utilizes a piecewise linear mapping so that slider quarters correspond to level thresholds (`1:10`, `1:30`, `2:00`).
   - The custom slider features a glowing teal outer aura thumb shape.
3. **HTTP API Integration**:
   - Triggers on clicking the **Continue** button.
   - Encodes pace into total seconds (`MIN * 60 + SEC`) and makes a `POST` request to `https://jsonplaceholder.typicode.com/posts` with the body `{"pace_seconds": 137}`.
   - Displays a revolving loading indicator inside the button and disables interaction during the API request.
   - Gracefully handles network timeouts and connection errors by showing a red notification bar.
4. **Interactive Training Dashboard**:
   - Shows dynamic volume parameters and session counts depending on the swimmer's level.
   - Expanding workouts displays individual training sets with toggling checkboxes that update the session's overall progress bar.

---

## ⚙️ How to Run

1. Clone or download the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```
