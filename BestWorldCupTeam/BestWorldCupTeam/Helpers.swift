import UIKit

// MARK: - 토스트

enum Toast {
    static func show(_ message: String, in view: UIView) {
        let host = view.window ?? view
        let label = PaddingLabel()
        label.text = message
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = Theme.text
        label.backgroundColor = UIColor(white: 0.08, alpha: 0.95)
        label.layer.cornerRadius = 14
        label.layer.borderWidth = 1
        label.layer.borderColor = Theme.line2.cgColor
        label.clipsToBounds = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        host.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: host.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: host.safeAreaLayoutGuide.bottomAnchor, constant: -84),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: host.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(lessThanOrEqualTo: host.trailingAnchor, constant: -24),
        ])
        UIView.animate(withDuration: 0.25) { label.alpha = 1 }
        UIView.animate(withDuration: 0.3, delay: 2.0, options: [],
                       animations: { label.alpha = 0 },
                       completion: { _ in label.removeFromSuperview() })
    }
}

final class PaddingLabel: UILabel {
    var inset = UIEdgeInsets(top: 11, left: 18, bottom: 11, right: 18)
    override func drawText(in rect: CGRect) { super.drawText(in: rect.inset(by: inset)) }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + inset.left + inset.right,
                      height: s.height + inset.top + inset.bottom)
    }
}

// MARK: - 포지션 칩

final class PosChipView: UIView {
    private let label = UILabel()
    init(cat: PosCat, small: Bool = false) {
        super.init(frame: .zero)
        let c = cat.color
        backgroundColor = c.withAlphaComponent(0.11)
        layer.cornerRadius = 5
        label.text = cat.label
        label.textColor = c
        label.font = Theme.numFont(small ? 10 : 11.5, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        let px: CGFloat = small ? 6 : 8, py: CGFloat = small ? 2 : 3
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: py),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -py),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: px),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -px),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - 등급 배지 (S/A/B/C/D)

final class TierBadge: UIView {
    private let label = UILabel()
    init(tier: Tier, size: CGFloat = 20) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let c = tier.color
        backgroundColor = c.withAlphaComponent(0.18)
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = c.withAlphaComponent(0.5).cgColor
        label.text = tier.label
        label.textColor = c
        label.font = Theme.numFont(size * 0.6, weight: .heavy)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - 국기 배지

final class FlagBadge: UIView {
    private let label = UILabel()
    init(nation: Nation, size: CGFloat = 22) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = nation.color.withAlphaComponent(0.15)
        layer.cornerRadius = size * 0.3
        layer.borderWidth = 1
        layer.borderColor = nation.color.withAlphaComponent(0.4).cgColor
        label.text = nation.flag
        label.font = .systemFont(ofSize: size * 0.6)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - 능력치 바 (Ch05 UIProgressView 느낌)

final class StatBarView: UIView {
    private let nameLabel = UILabel()
    private let valueLabel = UILabel()
    private let track = UIView()
    private let fill = UIView()
    private var fillWidth: NSLayoutConstraint!

    init(stat: Stat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let col: UIColor = stat.value >= 85 ? Theme.accent : (stat.value >= 70 ? UIColor(hex: "#8FE3B0") : Theme.sub)

        nameLabel.text = stat.label
        nameLabel.font = .systemFont(ofSize: 13)
        nameLabel.textColor = Theme.sub
        valueLabel.text = "\(stat.value)"
        valueLabel.font = Theme.numFont(16, weight: .bold)
        valueLabel.textColor = Theme.text
        valueLabel.textAlignment = .right

        track.backgroundColor = UIColor(white: 1, alpha: 0.08)
        track.layer.cornerRadius = 3
        fill.backgroundColor = col
        fill.layer.cornerRadius = 3
        track.addSubview(fill)

        [nameLabel, valueLabel, track].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; addSubview($0) }
        fill.translatesAutoresizingMaskIntoConstraints = false
        fillWidth = fill.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 52),
            valueLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.widthAnchor.constraint(equalToConstant: 26),
            track.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 12),
            track.trailingAnchor.constraint(equalTo: trailingAnchor),
            track.centerYAnchor.constraint(equalTo: centerYAnchor),
            track.heightAnchor.constraint(equalToConstant: 6),
            heightAnchor.constraint(equalToConstant: 20),
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fillWidth,
        ])
        self.value = stat.value
    }
    required init?(coder: NSCoder) { fatalError() }
    private var value = 0

    /// 등장 애니메이션 (상세 진입 시 호출)
    func animateFill(in container: UIView, delay: TimeInterval = 0) {
        layoutIfNeeded()
        let full = track.bounds.width * CGFloat(value) / 100.0
        fillWidth.constant = full
        UIView.animate(withDuration: 0.7, delay: delay, options: [.curveEaseOut]) {
            container.layoutIfNeeded()
        }
    }
}
