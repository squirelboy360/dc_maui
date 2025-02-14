import UIKit
import AVKit

@available(iOS 13.0, *)
extension NativeUIManager {
    // Stack View Components
    func createStackView(axis: String, spacing: CGFloat = 0) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis == "horizontal" ? .horizontal : .vertical
        stackView.spacing = spacing
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // List View Components
    func createListView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }
    
    // Button Components
    func createButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }
    
    // Image Components
    func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func createVideoView() -> UIView {
        let player = AVPlayerView()
        player.translatesAutoresizingMaskIntoConstraints = false
        player.showsPlaybackControls = true
        return player
    }
    
    private func handleUpdateMediaView(_ view: UIView, properties: [String: Any]) {
        switch view {
        case let imageView as UIImageView:
            if let url = properties["url"] as? String {
                // Use IconRegistry's loadImage implementation
                IconRegistry.shared.loadImage(from: url, into: imageView)
            } else if let asset = properties["asset"] as? String {
                imageView.image = UIImage(named: asset)
            } else if let svgName = properties["svg"] as? String {
                imageView.image = IconRegistry.shared.getIcon(svgName)
            }
            
        case let playerView as AVPlayerView:
            if let url = properties["url"] as? String,
               let videoURL = URL(string: url) {
                playerView.player = AVPlayer(url: videoURL)
            } else if let asset = properties["asset"] as? String,
                      let url = Bundle.main.url(forResource: asset, withExtension: nil) {
                playerView.player = AVPlayer(url: url)
            }
            
            if let showControls = properties["showControls"] as? Bool {
                playerView.showsPlaybackControls = showControls
            }
        default:
            break
        }
    }
    
    // Container Components
    func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }
    
    // Text Components
    func createLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }
    
    func createTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        return textField
    }
    
    // Consolidate gesture handling
//    func addGestureRecognizer(to view: UIView, for eventType: String) -> UIGestureRecognizer? {
//        switch eventType {
//        case "onClick":
//            return UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
//        case "onLongPress":
//            return UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        case "onPan":
//            return UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        case "onPinch":
//            return UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        default:
//            return nil
//        }
//    }
    
    // Add missing handlers for UIComponent properties
    func applyCommonProperties(_ view: UIView, properties: [String: Any]) {
        if let opacity = properties["opacity"] as? CGFloat {
            view.alpha = opacity
        }
        
        if let transform = properties["transform"] as? [String: Any] {
            applyTransform(to: view, transform: transform)
        }
        
        if let clipBehavior = properties["clipBehavior"] as? String {
            view.clipsToBounds = clipBehavior == "clip"
        }
        
        if let visible = properties["visible"] as? Bool {
            view.isHidden = !visible
        }
    }
    
    // Add helper for alerts/action sheets
    func createAlertController(title: String?, message: String?, style: UIAlertController.Style) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        return alert
    }
    
    // Add missing view types
    func createForm() -> UIView {
        let formView = UIView()
        formView.translatesAutoresizingMaskIntoConstraints = false
        return formView
    }
    
    func createModalSheet() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        return containerView
    }
    
    // Add touchable opacity view
    func createTouchableOpacity() -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        return button
    }
}

class AVPlayerView: UIView {
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    var showsPlaybackControls: Bool = true {
        didSet {
            playerViewController.showsPlaybackControls = showsPlaybackControls
        }
    }
    
    private let playerViewController = AVPlayerViewController()
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    private var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayer()
    }
    
    private func setupPlayer() {
        playerViewController.view.frame = bounds
        playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(playerViewController.view)
    }
}
