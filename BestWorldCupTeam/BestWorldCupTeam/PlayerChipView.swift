import UIKit

final class PlayerChipView: UIView {
    var player: Player?
    var slotID: String?

    private let portrait = PortraitView()
    private let ovrBadge = PaddingLabel()
    private let flagLabel = UILabel()
    private let nameWrap = UIView()
    private let nameLabel = UILabel()

    init(player: Player) {
        self.player = player
        super.init(frame: .zero)
        let col = player.cat.color

        portrait.configure(player: player, ring: false)
        portrait.layer.cornerRadius = 21
        portrait.layer.borderWidth = 1.8
        portrait.layer.borderColor = col.cgColor
        portrait.translatesAutoresizingMaskIntoConstraints = false

        ovrBadge.text = "\(player.ovr)"
        ovrBadge.inset = .init(top: 0, left: 4, bottom: 0, right: 4)
        ovrBadge.font = Theme.numFont(11, weight: .bold)
        ovrBadge.textColor = col
        ovrBadge.backgroundColor = Theme.bg
        ovrBadge.layer.cornerRadius = 6
        ovrBadge.layer.borderWidth = 1
        ovrBadge.layer.borderColor = col.cgColor
        ovrBadge.clipsToBounds = true
        ovrBadge.translatesAutoresizingMaskIntoConstraints = false

        flagLabel.text = player.flag
        flagLabel.font = .systemFont(ofSize: 12)
        flagLabel.translatesAutoresizingMaskIntoConstraints = false

        nameWrap.backgroundColor = UIColor(white: 0.03, alpha: 0.82)
        nameWrap.layer.cornerRadius = 5
        nameWrap.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = player.name
        nameLabel.font = .systemFont(ofSize: 10.5, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameWrap.addSubview(nameLabel)

        [portrait, ovrBadge, flagLabel, nameWrap].forEach { addSubview($0) }
        NSLayoutConstraint.activate([
            portrait.topAnchor.constraint(equalTo: topAnchor),
            portrait.centerXAnchor.constraint(equalTo: centerXAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 42),
            portrait.heightAnchor.constraint(equalToConstant: 42),
            ovrBadge.topAnchor.constraint(equalTo: topAnchor, constant: -4),
            ovrBadge.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: -8),
            flagLabel.bottomAnchor.constraint(equalTo: portrait.bottomAnchor, constant: 2),
            flagLabel.trailingAnchor.constraint(equalTo: portrait.leadingAnchor, constant: 8),
            nameWrap.topAnchor.constraint(equalTo: portrait.bottomAnchor, constant: 4),
            nameWrap.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameWrap.bottomAnchor.constraint(equalTo: bottomAnchor),
            nameWrap.widthAnchor.constraint(lessThanOrEqualToConstant: 62),
            nameLabel.topAnchor.constraint(equalTo: nameWrap.topAnchor, constant: 2),
            nameLabel.bottomAnchor.constraint(equalTo: nameWrap.bottomAnchor, constant: -2),
            nameLabel.leadingAnchor.constraint(equalTo: nameWrap.leadingAnchor, constant: 6),
            nameLabel.trailingAnchor.constraint(equalTo: nameWrap.trailingAnchor, constant: -6),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    override var intrinsicContentSize: CGSize { CGSize(width: 62, height: 64) }
    override func sizeThatFits(_ size: CGSize) -> CGSize { intrinsicContentSize }
}

final class EmptySlotView: UIView {
    var slot: Slot?
    var slotID: String?
    private let circle = UIView()
    private let label = UILabel()

    init(slot: Slot) {
        self.slot = slot; self.slotID = slot.id
        super.init(frame: .zero)
        let col = slot.cat.color
        circle.layer.cornerRadius = 21
        circle.layer.borderWidth = 1.6
        circle.layer.borderColor = col.withAlphaComponent(0.47).cgColor
        circle.backgroundColor = col.withAlphaComponent(0.06)
        circle.translatesAutoresizingMaskIntoConstraints = false
        let plus = UILabel(); plus.text = "+"; plus.textColor = col
        plus.font = .systemFont(ofSize: 20, weight: .light)
        plus.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(plus)

        label.text = slot.label
        label.font = Theme.numFont(11, weight: .bold)
        label.textColor = col.withAlphaComponent(0.87)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(circle); addSubview(label)
        NSLayoutConstraint.activate([
            circle.topAnchor.constraint(equalTo: topAnchor),
            circle.centerXAnchor.constraint(equalTo: centerXAnchor),
            circle.widthAnchor.constraint(equalToConstant: 42),
            circle.heightAnchor.constraint(equalToConstant: 42),
            plus.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            plus.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            label.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 4),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    override var intrinsicContentSize: CGSize { CGSize(width: 56, height: 62) }
    override func sizeThatFits(_ size: CGSize) -> CGSize { intrinsicContentSize }
}
