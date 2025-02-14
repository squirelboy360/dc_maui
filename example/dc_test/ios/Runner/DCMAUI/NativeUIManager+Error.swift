import Foundation
import os.log

enum NativeUIError: Error {
    case invalidArguments(String)
    case viewNotFound(String)
    case operationFailed(String)
    case invalidState(String)
    case resourceError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidArguments(let msg): return "Invalid arguments: \(msg)"
        case .viewNotFound(let id): return "View not found: \(id)"
        case .operationFailed(let op): return "Operation failed: \(op)"
        case .invalidState(let state): return "Invalid state: \(state)"
        case .resourceError(let res): return "Resource error: \(res)"
        }
    }
}

@available(iOS 13.0, *)
extension NativeUIManager {
    // Thread-safe view access
    private let viewAccessQueue = DispatchQueue(label: "com.dcmaui.viewAccess", attributes: .concurrent)
    
    func safeGetView(_ viewId: String) -> UIView? {
        viewAccessQueue.sync {
            views[viewId]
        }
    }
    
    func safeSetView(_ view: UIView, forId viewId: String) {
        viewAccessQueue.async(flags: .barrier) {
            self.views[viewId] = view
        }
    }
    
    func safeRemoveView(_ viewId: String) {
        viewAccessQueue.async(flags: .barrier) {
            self.views.removeValue(forKey: viewId)
        }
    }
    
    // Error handling wrapper
    func handleMethodSafely(_ call: FlutterMethodCall, result: @escaping FlutterResult, operation: @escaping () throws -> Any?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(FlutterError(code: "DEALLOCATED", message: "Manager was deallocated", details: nil))
                return
            }
            
            do {
                let value = try operation()
                result(value)
            } catch let error as NativeUIError {
                os_log(.error, log: self.logger, "Operation failed: %{public}@", error.localizedDescription)
                result(FlutterError(code: "OPERATION_FAILED", message: error.localizedDescription, details: nil))
            } catch {
                os_log(.error, log: self.logger, "Unknown error: %{public}@", error.localizedDescription)
                result(FlutterError(code: "UNKNOWN_ERROR", message: error.localizedDescription, details: nil))
            }
        }
    }
}
