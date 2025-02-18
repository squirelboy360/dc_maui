
## Organization Principles

1. **Core Manager**
   - `NativeUIManager.swift` contains the main plugin class and core functionality
   - Handles plugin registration, method channel setup, and basic view management

2. **Extensions Directory**
   - Contains extensions to system classes (UIView, UIColor, etc.)
   - Naming convention: `ClassName+Feature.swift`
   - Example: `UIView+Extensions.swift` for UIView extensions

3. **Views Directory**
   - Contains custom view implementations
   - Each custom view gets its own file
   - Example: `ZStackView.swift` for custom stack view implementation

4. **component+extensions Directory**
   - Contains feature-specific extensions of NativeUIManager
   - Separates complex functionality into focused files
   - Naming convention: `NativeUIManager+Feature.swift`
   - Examples:
     - `NativeUIManager+Color.swift` for color management
     - `NativeUIManager+Layout.swift` for layout functionality
     - `NativeUIManager+ListView.swift` for list view handling

## Guidelines for Contributors

1. **File Placement**
   - New system class extensions → Extensions/
   - New custom views → Views/
   - New NativeUIManager features → component+extensions/
   - Core functionality updates → NativeUIManager.swift

2. **Code Organization**
   - Keep related functionality together
   - Use extensions to break down large classes
   - Follow feature-based separation

3. **Naming Conventions**
   - Extensions: `BaseClass+Feature.swift`
   - Custom Views: `FeatureNameView.swift`
   - Component Extensions: `NativeUIManager+Feature.swift`

4. **When to Create New Files**
   - When adding a new major feature
   - When implementing a new custom view
   - When extending system classes
   - When NativeUIManager.swift becomes too large

5. **Benefits**
   - Improved code maintainability
   - Better code navigation
   - Easier testing and debugging
   - Clearer feature boundaries
   - Faster compilation (changes only recompile affected files)