# Contributing

Thanks for your interest in contributing to expo-native-emojis-popup! Pull requests are welcome.

## Getting Started

1. Fork and clone the repository
2. Install dependencies: `yarn install`
3. Set up the example app:
   ```bash
   cd example
   yarn install
   npx expo prebuild --clean
   npx expo run:ios   # or run:android
   ```
4. Make your changes in the `src/`, `ios/`, or `android/` directories
5. Test on both platforms before submitting

## Commit Convention

This project follows [Conventional Commits](https://www.conventionalcommits.org/). All commit messages must follow this format:

```
<type>(<scope>): <description>

[optional body]
```

Lefthook enforces this automatically on commit.

### Types

| Type | Description |
|-|-|
| feat | A new feature |
| fix | A bug fix |
| docs | Documentation changes |
| style | Code style changes (formatting, no logic change) |
| refactor | Code refactoring (no feature or bug fix) |
| perf | Performance improvements |
| test | Adding or updating tests |
| chore | Build process, tooling, or dependency updates |

### Examples

```
feat(ios): add spring damping customization for hover animations
fix(android): resolve popup positioning when anchor is near screen edge
docs: update style props table with hover label defaults
chore: bump expo-modules-core to 55.0.20
```

## Pull Request Guidelines

- Keep PRs focused on a single change
- Include a clear description of what changed and why
- Test on both iOS and Android
- Follow the existing code style
- Update the README if your change affects the public API
- Add yourself to the contributors list if you'd like

## Pre-commit Hooks

This project uses [Lefthook](https://github.com/evilmartians/lefthook) for git hooks. They are installed automatically on `yarn install`. The hooks run:

- **pre-commit**: ESLint, Prettier check, and TypeScript typecheck on staged files
- **commit-msg**: Conventional commit format validation

## Project Structure

```
src/           TypeScript layer (module, types, declarative component)
ios/           Swift native code (UIKit)
android/       Kotlin native code
example/       Expo example app for development
```

## Native Development

- **iOS**: Swift, UIKit, CASpringAnimation, UIScrollView
- **Android**: Kotlin, SpringAnimation, HorizontalScrollView

Both platforms use the Expo Modules API for bridging. The module name is `ExpoNativeEmojisPopup` and the view wrapper is `EmojisPopupWrapper`.

## Running the Example

The example app is a full Expo SDK 55 project. It requires a native build (not Expo Go) since this is a native module:

```bash
cd example
yarn install
npx expo prebuild --clean
npx expo run:ios
# or
npx expo run:android
```

## Questions?

Open an issue on GitHub for bugs, feature requests, or questions.
