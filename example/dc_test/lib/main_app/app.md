# App Structure Guidelines

## View/Screen Organization

Each view or screen in the application must follow this structure:

```
lib/
    ├── views/
            └── home/
                    ├── home_binder.dart
                    └── home_components.dart
```

### Naming Convention
- Create a folder for each screen inside `views/`
- Folder name should match the screen name in lowercase
- Each screen consists of two main files:
    1. `*_binder.dart` - Contains view bindings and logic
    2. `*_components.dart` - Contains components for the screen

This structure ensures consistency and maintainability across the application.
