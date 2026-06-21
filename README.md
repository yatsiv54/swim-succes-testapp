# Swim Progress Test App

A two-screen Flutter application demonstrating pace selection with interactive custom widgets (Task 1) and a user directory with API integration (Task 2).

Built with **Clean Architecture** (Feature-First approach) and **BLoC** (`flutter_bloc`) for predictable state management.

---

## 🏊 Swimmer Level Pace Ranges

Swimmer level classifications are dynamically computed based on the total seconds of the fastest 100m freestyle pace:

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
│   ├── network/         # HTTP ApiClient wrapper (GET/POST with timeout)
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
    │       ├── bloc/          # SwimPaceBloc (debounced slider, API states)
    │       └── pages/         # PaceSelectionPage & MainSwipePage
    │
    └── user_list/
        ├── data/
        │   ├── datasources/   # Remote User data-source (UserRemoteDataSource)
        │   ├── models/        # UserModel (typed JSON parser mapping)
        │   └── repositories/  # UserRepositoryImpl
        ├── domain/
        │   ├── entities/      # Typed models (UserEntity, AddressEntity, CompanyEntity)
        │   ├── repositories/  # UserRepository contract
        │   └── usecases/      # GetUsersUseCase
        └── presentation/
            ├── bloc/          # UserListBloc (Fetch, Search, Refresh events/states)
            └── pages/         # UserListPage (Searchable list) & UserDetailPage
```

---

## 🧠 State Management Decision (BLoC)

We chose **BLoC** (`flutter_bloc`) as the state management library because:
1. **Consistency**: Both screens use BLoC, making the codebase highly unified with a single state management approach.
2. **Separation of Concerns**: Events (like `FetchUsers`, `SearchUsers`, and `RefreshUsers`) map linearly to data streams, keeping state transitions predictable and testable.
3. **Search & Filter Flow**: Keeping both the complete list (`users`) and the filtered subset (`filteredUsers`) inside a single state prevents repeated API queries during local search operations.

---

## 🚀 Key Features Implemented

1. **Tap to Edit (Direct Input)**:
   - Tapping on the minutes or seconds digits opens a keyboard for direct numeric input.
   - Validation ensures minutes stay within `0-5` and seconds remain strictly in the range of `0-59`.
2. **Dynamic Range Slider with Debounce**:
   - Utilizes a piecewise linear mapping so that slider thresholds correspond to level boundaries (`1:10`, `1:30`, `2:00`).
   - Custom slider with a glowing segment highlight that colors only the active swimmer level sector.
   - Slider changes are debounced (~500ms) to coalesce rapid drags into a single state emission.
3. **HTTP API Integration (GET & POST)**:
   - Screen 1 POSTs the pace to `/posts`.
   - Screen 2 fetches users from `/users`.
   - All requests have a 15-second timeout. Displays loading indicators and gracefully handles network errors with user-friendly messages.
4. **Interactive User Directory & Detail Dashboard**:
   - Screen 2 displays a searchable list of users with Pull-to-Refresh functionality.
   - Navigates to a detailed user profile showing website, company catch phrases, and address details.
5. **Swipe Navigation with State Preservation**:
   - Screens are arranged in a horizontal `PageView` with a shared animated progress indicator at the top.
   - `AutomaticKeepAliveClientMixin` ensures all state (inputs, search queries, loaded data) is preserved during swipes.

---

## 🔄 What I'd Do Differently With More Time

- **Unit & widget tests**: Add `bloc_test` for all BLoC event/state flows, `mockito`/`mocktail` for repository testing, and widget tests for key UI interactions.
- **Dependency injection**: Replace manual DI in `main.dart` with `get_it` or `injectable` for better scalability and testability.
- **Extract widgets**: Break the 800+ line `pace_selection_page.dart` into smaller, reusable widget files (custom slider, picker column, colon separator).
- **Either pattern**: Use `dartz` or `fpdart` `Either<Failure, T>` in repositories instead of throwing failures, for more explicit error handling.
- **Accessibility**: Add semantic labels to interactive elements and test with screen readers.
- **Localization**: Extract all user-facing strings into ARB files for i18n support.

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
