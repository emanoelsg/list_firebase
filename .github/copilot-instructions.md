# Copilot Instructions for list_firebase

## Project Overview
- This is a modular Flutter app for daily task management, using Clean Architecture principles.
- Main features: Firebase authentication, Firestore CRUD, local notifications, and reactive UI with GetX.
- Code is split into `data/`, `domain/`, `presentation/`, and `service/` layers under `lib/app/features/*`.

## Key Architectural Patterns
- **Clean Architecture:**
  - `data/` handles repository implementations and Firebase integration.
  - `domain/` contains entities and repository interfaces.
  - `presentation/` includes controllers (GetX), pages, and widgets.
  - `service/` is for external integrations (e.g., notifications).
- **Reactive State:** All UI state is managed via GetX controllers and Rx variables.
- **Testing:** Unit tests are in `test/lib/app/features/*` and use `mocktail` and `fake_firestore`.

## Developer Workflows
- **Build:**
  - Run: `flutter run`
  - Build APK: `flutter build apk`
- **Test:**
  - Run all tests: `flutter test --coverage`
  - Coverage report: see `coverage/lcov.info`
- **Debug:**
  - Use GetX's `Obx` for reactive UI updates.
  - Error and loading states are handled via Rx variables in controllers.

## Project-Specific Conventions
- **Task Management:**
  - All task operations (CRUD, streams) are handled via `TaskRepository` and its implementation.
  - Use `watchTasks(userId)` for real-time updates (returns a Stream).
- **Error Handling:**
  - Controllers expose `isLoading`, `error`, and `message` Rx variables for UI feedback.
- **Validation:**
  - Form validation logic is centralized in `lib/app/utils/validators/validation.dart`.
- **Network Retry:**
  - Use `NetworkRetry.retry` for robust Firebase operations (see `lib/app/core/network/network_retry.dart`).

## Integration Points
- **Firebase:**
  - Auth, Firestore, Storage are used via official packages.
  - Credentials/config in `firebase_options.dart` and `android/app/google-services.json`.
- **Notifications:**
  - Local notifications are scheduled via `NotificationController` and related service files.

## Examples
- To add a new feature, create a folder in `lib/app/features/` with `data/`, `domain/`, and `presentation/` subfolders.
- For a new repository, define the interface in `domain/`, implement in `data/`, and inject into controllers in `presentation/controller/`.

## References
- See `README.md` for tech stack and project goals.
- See `test/` for unit and widgettest patterns.
- See `lib/app/features/tasks/` for a complete feature example.

---

If any section is unclear or missing, please provide feedback so this guide can be improved for future agents.
