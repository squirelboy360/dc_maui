import YogaKit

extension YGValue {
    static let zero = YGValue(value: 0, unit: .point)
    
    init(_ value: Float, _ unit: YGUnit) {
        self.init(value: value, unit: unit)
    }
}
