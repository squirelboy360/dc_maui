import UIKit

class DCButton: DCView {
    private let button = UIButton(type: .system)
    private weak var methodChannel: FlutterMethodChannel?
    private var pressStartTime: TimeInterval = 0
    
    override func setupDefaults() {
        super.setupDefaults()
        
        button.yoga.isEnabled = true
        addSubview(button)
        
        // Fill parent
        button.yoga.position = .absolute
        button.yoga.left = .zero
        button.yoga.top = .zero
        button.yoga.right = .zero
        button.yoga.bottom = .zero
    }
    
    override func setupEvents(_ events: [String: Any], channel: FlutterMethodChannel?) {
        self.methodChannel = channel
        
        if events["onClick"] != nil {
            button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        }
        if events["onPressIn"] != nil {
            button.addTarget(self, action: #selector(handlePressIn), for: .touchDown)
        }
        if events["onPressOut"] != nil {
            button.addTarget(self, action: #selector(handlePressOut), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
    }
    
    @objc private func handleTap(_ sender: UIButton) {
        let pressTime = Date().timeIntervalSince1970 - pressStartTime
        let touchPoint = sender.convert(CGPoint.zero, to: nil)
        
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onClick",
            "data": [
                "duration": pressTime,
                "position": [
                    "x": touchPoint.x,
                    "y": touchPoint.y
                ],
                "timestamp": Date().timeIntervalSince1970
            ]
        ])
    }
    
    @objc private func handlePressIn(_ sender: UIButton) {
        pressStartTime = Date().timeIntervalSince1970
        let touchPoint = sender.convert(CGPoint.zero, to: nil)
        
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onPressIn",
            "data": [
                "position": [
                    "x": touchPoint.x,
                    "y": touchPoint.y
                ],
                "timestamp": pressStartTime
            ]
        ])
        
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.7
        }
    }
    
    @objc private func handlePressOut(_ sender: UIButton) {
        let endTime = Date().timeIntervalSince1970
        let touchPoint = sender.convert(CGPoint.zero, to: nil)
        
        methodChannel?.invokeMethod("onComponentEvent", arguments: [
            "viewId": viewId,
            "type": "onPressOut",
            "data": [
                "duration": endTime - pressStartTime,
                "position": [
                    "x": touchPoint.x,
                    "y": touchPoint.y
                ],
                "timestamp": endTime
            ]
        ])
        
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1.0
        }
    }
    
    override func applyStyle(_ style: [String: Any]) {
        super.applyStyle(style)
        
        if let textStyle = style["textStyle"] as? [String: Any] {
            if let text = textStyle["text"] as? String {
                button.setTitle(text, for: .normal)
            }
            if let color = textStyle["color"] as? UInt32 {
                button.setTitleColor(UIColor(rgb: color), for: .normal)
            }
            if let fontSize = textStyle["fontSize"] as? CGFloat {
                button.titleLabel?.font = .systemFont(ofSize: fontSize, weight: .semibold)
            }
        }
    }
}
