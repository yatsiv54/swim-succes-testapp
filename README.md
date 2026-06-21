<div align="center">

<img src="https://storage.googleapis.com/cms-storage-bucket/6e19fee6b47b36ca613f.png" alt="Flutter" width="80" />

# 🏊 Swim Success

**Flutter Developer Test Task**

A two-screen Flutter application showcasing custom interactive widgets, API integration, and clean architecture.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State-BLoC-blue)](https://bloclibrary.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean-green)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

### 🎬 Video Walkthrough

[![Loom Video](https://img.shields.io/badge/Watch%20on-Loom-8B5CF6?logo=loom&logoColor=white&style=for-the-badge)](https://www.loom.com/share/15b67ebdcff648a88631fe1b6b709077)

</div>

---

## 📱 Screens

### Screen 1 — Pace Selector
> Set your fastest 100m freestyle time with an interactive custom UI

- **Pace input (MIN : SEC)** — large numeric displays with up/down arrows + tap-to-edit direct input
- **Validation** — seconds clamped to `0–59`, total range `0:45` – `4:00`
- **Custom slider** — piecewise linear mapping with glowing active sector, tick labels at `1:10`, `1:30`, `2:00`
- **Swimmer level** — dynamically computed and displayed with animated color transitions
- **Continue button** — sends `POST` to `/posts` with `{ "pace_seconds": N }`, debounced ~500ms, with loading spinner and error handling
- **Skip option** — swipes to Screen 2

### Screen 2 — User Directory
> Fetch and browse users from a public REST API

- **User list** — fetched from `GET /users` with typed models
- **Search** — instant filter by name
- **Pull-to-refresh** — re-fetches data from API
- **User detail** — tapping a user navigates to a full profile with contact, address (with geo coordinates), and company details
- **Error handling** — clean, user-friendly error messages for network/server failures

---

## 🏊 Swimmer Level Ranges

| Level | Pace Range | Seconds |
|:---|:---|:---|
| 🥇 **Elite** | `0:45` – `1:09` | 45s – 69s |
| 🥈 **Advanced** | `1:10` – `1:29` | 70s – 89s |
| 🥉 **Intermediate** | `1:30` – `1:59` | 90s – 119s |
| 🏅 **Beginner** | `2:00` – `4:00` | 120s – 240s |

---

## 🧠 State Management — Why BLoC?

I chose **BLoC** (`flutter_bloc`) for the following reasons:

1. **Consistency** — both screens use the same state management approach, making the codebase unified and predictable
2. **Separation of concerns** — events (`FetchUsers`, `SearchUsers`, `SubmitPace`) map linearly to state transitions, keeping logic fully separated from the UI
3. **Efficient search** — keeping both `users` (full list) and `filteredUsers` (search subset) in a single state avoids redundant API calls during local filtering

---

## 🏛 Project Structure

Feature-first **Clean Architecture** with three layers per feature:

```
lib/
├── core/
│   ├── errors/             # Failure types (ServerFailure, NetworkFailure)
│   ├── network/            # ApiClient — HTTP wrapper with timeout
│   └── theme/              # AppTheme — colors, typography, dark theme
│
└── features/
    ├── pace_selector/
    │   ├── data/
    │   │   ├── datasources/    # PaceRemoteDataSource (POST)
    │   │   └── repositories/   # PaceRepositoryImpl
    │   ├── domain/
    │   │   ├── entities/       # PaceEntity, SwimmerLevel enum
    │   │   ├── repositories/   # PaceRepository (contract)
    │   │   └── usecases/       # SubmitPaceUseCase
    │   └── presentation/
    │       ├── bloc/           # SwimPaceBloc + events + state
    │       └── pages/          # PaceSelectionPage, MainSwipePage
    │
    └── user_list/
        ├── data/
        │   ├── datasources/    # UserRemoteDataSource (GET)
        │   ├── models/         # UserModel (typed JSON parsing)
        │   └── repositories/   # UserRepositoryImpl
        ├── domain/
        │   ├── entities/       # UserEntity, AddressEntity, CompanyEntity
        │   ├── repositories/   # UserRepository (contract)
        │   └── usecases/       # GetUsersUseCase
        └── presentation/
            ├── bloc/           # UserListBloc + events + state
            └── pages/          # UserListPage, UserDetailPage
```

---

## ⚙️ Technical Highlights

| Area | Implementation |
|:---|:---|
| **API calls** | `http` package with 15s timeout, `ServerException` / `NetworkException` classification |
| **Error handling** | Repository layer maps technical exceptions → user-friendly `Failure` messages. No raw exceptions leak to the UI |
| **Typed models** | `UserModel.fromJson()` with null-safe defaults. Zero `Map<String, dynamic>` in the UI layer |
| **Debounce** | ~500ms debounce on `SubmitPace` to prevent rapid-fire POST requests |
| **Navigation** | Horizontal `PageView` with swipe transitions + shared animated top indicator |
| **State preservation** | `AutomaticKeepAliveClientMixin` keeps all inputs/search/data alive across swipes |
| **Custom painting** | `GlowSliderThumbShape` + `CustomSliderTrackShape` for the piecewise glowing slider |
| **Lint rules** | Strict `analysis_options.yaml` with `prefer_const_constructors`, `prefer_final_locals`, etc. |

---

## 🔄 What I'd Do Differently With More Time

- **Cubit instead of BLoC** — for screens like these, `Cubit` is more concise and sufficient. Full BLoC with events is overkill when there are no complex event-to-event transformations
- **Freezed + build_runner instead of Equatable** — auto-generated `copyWith`, `==`, `toString`, sealed unions, and JSON serialization out of the box. Less boilerplate, fewer human errors
- **GetIt for dependency injection** — replace manual DI wiring in `main.dart` with `GetIt` + `Injectable` for a scalable, testable service locator
- **GoRouter instead of Navigator** — declarative routing with deep linking support, typed route parameters, and better navigation state management
- **Dio instead of http** — built-in interceptors, request cancellation, automatic retries, and `FormData` support. Much more flexible for production apps
- **Public widget classes instead of private build methods** — extract `_buildUserCard()`, `_buildSearchBar()`, `_buildPickerColumn()` etc. into separate public widget files. This improves reusability, testability, and keeps files under 200–300 lines
- **Tests** — unit tests for BLoCs with `bloc_test`, repository tests with `mocktail`, widget tests for key UI flows

---

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/yatsiv54/swim-succes-testapp.git
cd swim-succes-testapp

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

<div align="center">

Built with ❤️ and Flutter

</div>
