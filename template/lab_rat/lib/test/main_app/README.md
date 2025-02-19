# App Structure Guidelines

## View/Screen Organization

Each view/screen in the application follows a specific modular structure designed for maintainability and scalability.

### Directory Structure
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



### File Purposes

1. **screen_name_components.dart**
   - Contains component declarations
   - Defines the structure of UI elements
   - No logic implementation
   - Abstract class with component IDs

2. **screen_name.dart**
   - Implements core UI creation logic
   - Extends the components class
   - Contains methods to create and configure UI elements
   - Handles layout and styling

3. **screen_name_binder.dart**
   - Contains view binding logic
   - Manages component lifecycle
   - Handles event registration
   - Orchestrates UI assembly

### Naming Conventions

- Use lowercase with underscores for folder names
- Match file names with their parent folder
- Suffix files according to their role:
  - `_components.dart` for component declarations
  - `_binder.dart` for binding logic
  - `.dart` for core implementation

### Example Structure
```
lib/
 ├── views/ 
 └── home/ 
 ├── home_binder.dart // Home screen binding logic 
 ├── home_components.dart // Home screen components 
 └── home.dart // Home screen implementation
```


This structure ensures:
- Clear separation of concerns
- Consistent organization
- Easy maintenance
- Scalable architecture
- Predictable file locations
