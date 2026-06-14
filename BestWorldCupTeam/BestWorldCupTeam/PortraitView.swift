import UIKit

final class PortraitView: UIView {

    private let gradient = CAGradientLayer()
    private let imageView = UIImageView()
    private let silhouette = CAShapeLayer()
    private var ringColor: UIColor = Theme.accent
    private var showRing = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.addSublayer(gradient)
        silhouette.fillColor = UIColor(white: 1, alpha: 0.82).cgColor
        layer.addSublayer(silhouette)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        addSubview(imageView)
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(player: Player, ring: Bool = true) {
        ringColor = player.cat.color
        showRing = ring
        let nat = player.nation.color
        gradient.colors = [nat.withAlphaComponent(0.36).cgColor,
                           nat.withAlphaComponent(0.13).cgColor,
                           Theme.cardHi.cgColor]
        gradient.locations = [0, 0.46, 1]
        // 에셋에 player.id 이름의 이미지가 있으면 사진, 없으면 실루엣 유지
        if let img = UIImage(named: player.id) {
            imageView.image = img
            imageView.isHidden = false
            silhouette.isHidden = true
        } else {
            imageView.image = nil
            imageView.isHidden = true
            silhouette.isHidden = false
        }
        setNeedsLayout()
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
        imageView.isHidden = (image == nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let s = bounds.width
        layer.cornerRadius = s / 2
        gradient.frame = bounds
        imageView.frame = bounds
        imageView.layer.cornerRadius = s / 2

        // 머리 + 어깨 실루엣 (viewBox 48 기준 스케일)
        let k = s / 48.0
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: 24*k, y: 19*k), radius: 8.4*k,
                    startAngle: 0, endAngle: .pi*2, clockwise: true)
        let sh = UIBezierPath()
        sh.move(to: CGPoint(x: 8*k, y: 47*k))
        sh.addCurve(to: CGPoint(x: 40*k, y: 47*k),
                    controlPoint1: CGPoint(x: 8*k, y: 38*k),
                    controlPoint2: CGPoint(x: 40*k, y: 38*k))
        path.append(sh)
        silhouette.path = path.cgPath

        if showRing {
            layer.borderWidth = max(1.4, s * 0.035)
            layer.borderColor = ringColor.withAlphaComponent(0.7).cgColor
        } else {
            layer.borderWidth = 0
        }
    }
}
