//
//  DCTestApp.swift
//  DCTest
//
//  Created by Tahiru Agbanwa on 2/10/25.
//

import SwiftUI
import Foundation
import Darwin

@main
struct DCTestApp: App {
    // This is where you initialize the Dart runtime (libdart.dylib)
    init() {
        initializeDartRuntime()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func initializeDartRuntime() {
        // Path to your libdart.dylib
        let dartLibraryPath = "/path/to/libdart.dylib"
        
        // Load the Dart library
        guard let dartLibrary = dlopen(dartLibraryPath, RTLD_NOW) else {
            fatalError("Failed to load libdart.dylib")
        }
        
        // Define the Dart initialization function signature
        typealias Dart_InitializeApiDL = @convention(c) (UnsafeMutablePointer<CChar>?) -> Int32
        
        // Retrieve the Dart API initialization function
        let initializeApiRawPointer = dlsym(dartLibrary, "Dart_InitializeApiDL")
        
        // Safely unwrap the raw pointer to the Dart initialization function
        guard let initializeApiRawPointer = initializeApiRawPointer else {
            fatalError("Failed to locate Dart_InitializeApiDL in libdart.dylib")
        }
        
        // Now safely cast the raw pointer to the Dart_InitializeApiDL function
        let initializeApi = unsafeBitCast(initializeApiRawPointer, to: Dart_InitializeApiDL.self)
        
        // Initialize Dart VM
        let result = initializeApi(nil)
        if result != 0 {
            fatalError("Dart VM initialization failed")
        }
        
        // You can now start interacting with Dart runtime
        print("Dart VM initialized successfully!")
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}
