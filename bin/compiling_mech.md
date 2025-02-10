## Framework Setup and Flow

The framework contains a library that exposes the core SDK to Dart. This Dart interface binds to the native classes located in the native folders for both iOS and Android. The `podspec` (for iOS) and `build.gradle` (for Android) files ensure that the Flutter engine is installed, enabling us to always access the runtime during the compilation process.

### Step-by-Step Flow

1. **Create Script**: 
   The user runs a global SDK create script, which utilizes Xcode and Android SDK tools to generate an app template for both iOS and Android.

2. **Copy Native Folders**: 
   The script copies the relevant native folders (iOS and Android) into their respective platform directories. 

3. **Install Dependencies**: 
   Once the app structure is generated, the user runs `pod install` for iOS and the equivalent for Android. This ensures that the Flutter engine and dependencies are installed, enabling the app to run and communicate with the Dart code.

4. **Compile Dart Code**: 
   After the dependencies are installed, the user runs a build script, which compiles the library folder (including the Dart code). It then embeds the compiled Dart code into the app.

5. **Run the Dart VM**: 
   The Dart VM is embedded within the app, and when the app is run, it executes the embedded Dart code, completing the integration between Dart and native code.

### Conclusion

This flow ensures that the app is set up and ready to go by generating the necessary native project structure, embedding the Flutter engine, installing dependencies, and compiling the Dart code into the app, all while ensuring seamless communication between the native and Dart layers.