# Contributing to ByteFlow

Thank you for your interest in contributing to **ByteFlow**! ByteFlow is an open-source, battery-efficient Android network monitor built with Flutter, Kotlin, Riverpod, Drift SQLite, and Shizuku.

Whether you are fixing a bug, proposing a new feature, writing documentation, or optimizing performance, we welcome your contributions.

---

## Code of Conduct

By participating in this project, you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md). Please report any unacceptable behavior according to our reporting guidelines.

---

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your development machine:

- **Flutter SDK**: `3.22.0` or higher (`master` or `stable` channel)
- **Dart SDK**: `3.4.0` or higher
- **Java Development Kit (JDK)**: OpenJDK 17 or 21
- **Android SDK**: API Level 34+ (compileSdk 35, minSdk 26)
- **Git**

### Fork & Clone

1. Fork the repository on GitHub: [https://github.com/Roni077/byteflow](https://github.com/Roni077/byteflow)
2. Clone your fork locally:
   ```bash
   git clone https://github.com/<your-username>/byteflow.git
   cd byteflow
   ```
3. Set up the upstream remote:
   ```bash
   git remote add upstream https://github.com/Roni077/byteflow.git
   ```

### Initial Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run code generation (for Drift database & Riverpod models):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. Verify static analysis:
   ```bash
   flutter analyze
   ```

4. Run the comprehensive verification test suite:
   ```bash
   dart test/verify_all_phases.dart
   ```

---

## Development Workflow

### Creating a Branch

Create a descriptive feature branch from `main`:

```bash
git checkout -b feat/your-feature-name
# or
git checkout -b fix/issue-description
```

### Code Style & Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines.
- Use strict typing and pattern matching (Dart 3 switch expressions and records).
- Keep Riverpod state providers scoped and decoupled from UI widgets.
- Respect battery and memory constraints:
  - Avoid frequent writes to persistent flash memory; buffer data in memory and write in batches.
  - Cancel any stream subscriptions, timers, or native listeners in `dispose()` / `ref.onDispose()`.
- Run `flutter analyze` before committing changes to ensure **0 warnings and 0 errors**.

### Testing Requirements

- **Unit & Widget Tests**: Add or update corresponding unit tests in `test/unit/` or widget tests in `test/widget/`.
- Run tests locally:
  ```bash
  flutter test
  ```
- Run the all-phases verification suite:
  ```bash
  dart test/verify_all_phases.dart
  ```

---

## Commit Message Guidelines

We adhere to [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

### Common Types:
- `feat`: A new feature or capability
- `fix`: A bug fix
- `docs`: Documentation improvements or additions
- `style`: Formatting or cosmetic changes that do not affect logic
- `refactor`: Code changes that neither fix a bug nor add a feature
- `perf`: Performance or battery efficiency improvements
- `test`: Adding or correcting tests
- `ci`: Changes to CI/CD workflows or scripts

*Example:* `feat(dashboard): add dynamic Mbps and KBps toggle to live speed card`

---

## Submitting a Pull Request

1. Push your branch to your GitHub fork:
   ```bash
   git push origin feat/your-feature-name
   ```
2. Open a Pull Request against the `main` branch of `Roni077/byteflow`.
3. Fill out the [Pull Request Template](.github/PULL_REQUEST_TEMPLATE.md) completely.
4. Ensure the GitHub Actions CI pipeline passes all checks:
   - **Test**: `flutter test`
   - **Analyze**: `flutter analyze`
   - **Build Debug APK**: `flutter build apk --debug`
   - **Build Release APK**: `flutter build apk --release`
5. Address any review comments or suggestions. Once approved, your PR will be squash-merged into `main`.

---

## Reporting Issues & Requesting Features

- **Bug Reports**: Please open an issue using the [Bug Report Template](.github/ISSUE_TEMPLATE/bug_report.yml). Include device details, Android OS version, and Shizuku status.
- **Feature Requests**: Open an issue using the [Feature Request Template](.github/ISSUE_TEMPLATE/feature_request.yml) describing the motivation, expected behavior, and alternatives considered.

Thank you for helping make ByteFlow better for everyone!
