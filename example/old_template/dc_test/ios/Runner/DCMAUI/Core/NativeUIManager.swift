/*
 BSD 3-Clause License

Copyright (c) 2025, Tahiru Agbanwa

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit
import Flutter
import YogaKit

enum ViewType: String {
    case view = "View"
    case label = "Label"
    case image = "Image"
    case scrollView = "ScrollView"
    case textInput = "TextInput"
    case touchableOpacity = "TouchableOpacity"
    case listView = "ListView"
    case animatedView = "AnimatedView"
    case safeAreaView = "SafeAreaView"
}

@available(iOS 13.0, *)
class NativeUIManager: NSObject, FlutterPlugin {
    // MARK: - Properties
    private var methodChannel: FlutterMethodChannel?
    internal var views: [String: DCView] = [:]
    internal var childViews: [String: [String]] = [:]
    private var rootViewId: String?
    private var window: UIWindow?
    
    // CRUD operations handler
    private lazy var operationsHandler = NativeUIOperationsHandler(manager: self)
    
    // MARK: - Plugin Registration
    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = NativeUIManager()
        let channel = FlutterMethodChannel(
            name: "com.dcmaui.framework",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.methodChannel = channel
        
        // Initialize after a brief delay to ensure Flutter is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            instance.setupRootView()
        }
    }
    
    // MARK: - Method Channel Handler
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("Handling method: \(call.method)")
            
            switch call.method {
            case "createView":
                self.operationsHandler.handleCreateView(call, result: result)
                
            case "attachView":
                self.operationsHandler.handleAttachView(call, result: result)
                
            case "detachView":
                self.operationsHandler.handleDetachView(call, result: result)
                
            case "deleteView":
                self.operationsHandler.handleDeleteView(call, result: result)
                
            case "getRootView":
                self.operationsHandler.handleGetRootView(result: result)
                
            case "setState":
                self.operationsHandler.handleSetState(call, result: result)
                
            case "updateViewState":
                self.operationsHandler.handleUpdateViewState(call, result: result)
                
            case "getState":
                self.operationsHandler.handleGetState(call, result: result)
                
            case "getChildrenIds":
                self.operationsHandler.handleGetChildrenIds(call, result: result)
                
            case "addEventListener":
                self.operationsHandler.handleAddEventListener(call, result: result)
            
            // Add ListView-specific methods
            case "setItem":
                print("NativeUIManager: Handling setItem method")
                self.operationsHandler.handleSetItem(call, result: result)
                
            case "scrollToIndex":
                print("NativeUIManager: Handling scrollToIndex method")
                self.operationsHandler.handleScrollToIndex(call, result: result)
                
            case "refreshData":
                print("NativeUIManager: Handling refreshData method")
                self.operationsHandler.handleRefreshData(call, result: result)
                
            default:
                print("⚠️ Method not implemented: \(call.method)")
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // MARK: - Root View Setup
    func setupRootView() {
        print("Setting up root view")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let nativeWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
            nativeWindow.windowScene = windowScene
            
            let rootVC = UIViewController()
            rootVC.view.backgroundColor = .clear
            
            // Create root view with explicit frame and yoga config
            let rootView = DCView(viewId: "root")
            rootView.frame = rootVC.view.bounds
            rootView.backgroundColor = .clear
            rootView.yoga.isEnabled = true
            rootView.yoga.flexDirection = .column
            rootView.yoga.width = YGValue(value: Float(rootVC.view.bounds.width), unit: .point)
            rootView.yoga.height = YGValue(value: Float(rootVC.view.bounds.height), unit: .point)
            
            print("Root view frame: \(rootView.frame)")
            
            rootVC.view.addSubview(rootView)
            nativeWindow.rootViewController = rootVC
            nativeWindow.makeKeyAndVisible()
            
            self.window = nativeWindow
            self.rootViewId = rootView.viewId
            self.views[rootView.viewId] = rootView
            self.childViews[rootView.viewId] = []
            
            print("Root view setup complete with ID: \(rootView.viewId)")
        }
    }
    
    // MARK: - Helper Methods
    internal func getMethodChannel() -> FlutterMethodChannel? {
        return methodChannel
    }
    
    internal func getRootViewId() -> String? {
        return rootViewId
    }
}

// MARK: - Cleanup
@available(iOS 13.0, *)
extension NativeUIManager {
    func cleanup() {
        views.values.forEach { $0.removeFromSuperview() }
        views.removeAll()
        childViews.removeAll()
        rootViewId = nil
        window = nil
        methodChannel = nil
    }
}

// ViewType helper extension
extension ViewType {
    init?(fromViewId viewId: String) {
        let components = viewId.split(separator: "-")
        guard !components.isEmpty else { return nil }
        self.init(rawValue: String(components[0]))
    }
}
