//
//  Coordinator+Shared.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import Foundation
import Flutter

extension DCViewCoordinator {
    private static var _shared: DCViewCoordinator?
    
    static var shared: DCViewCoordinator? {
        get {
            return _shared
        }
        set {
            _shared = newValue
        }
    }
    
    
    // MARK: - Plugin Registration
       static func register(with registrar: FlutterPluginRegistrar) {
           let instance = DCViewCoordinator()
           let channel = FlutterMethodChannel(
               name: "com.dcmaui.framework",
               binaryMessenger: registrar.messenger()
           )
           registrar.addMethodCallDelegate(instance, channel: channel)
           instance.methodChannel = channel
           
           
           // Set up event channel and register the stream handler
           let eventChannel = FlutterEventChannel(name: "com.dcmaui.framework/events",
                                                binaryMessenger: registrar.messenger())
           
           // Set the coordinator as the stream handler for the event channel
           eventChannel.setStreamHandler(instance)
           print("DC MAUI: Event channel registered successfully")
           
           // Store shared instance
           shared = instance
           
           print("DC MAUI: Coordinator registered successfully")
           
           
           
           // Initialize after a brief delay to ensure Flutter is ready
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
               instance.setupRootView()
           }
       }
    
   
}

