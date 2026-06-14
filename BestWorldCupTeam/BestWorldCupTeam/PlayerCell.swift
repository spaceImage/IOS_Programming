import UIKit

final class PlayerCell: UITableViewCell {
    static let reuseID = "PlayerCell"

    private let bgCard = UIView()
    private let portrait = PortraitView()
    private let nameLabel = UILabel()
    private let pickedLabel = UILabel()
    private let teamLabel = UILabel()     // 국가 · 포지션
    private let clubLabel = UILabel()     // 소속 클럽
    private let ovrLabel = UILabel()
    private let ovrCaption = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    private let nameRow = UIStackView()
    private let teamRow = UIStackView()
    private let clubRow = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        bgCard.backgroundColor = Theme.card
        bgCard.layer.cornerRadius = 14
        bgCard.layer.borderWidth = 1
        bgCard.layer.borderColor = Theme.line.cgColor
        bgCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgCard)

        portrait.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = Theme.text
        pickedLabel.text = "✓픽"
        pickedLabel.font = Theme.numFont(10, weight: .bold)
        pickedLabel.textColor = Theme.accent
        teamLabel.font = .systemFont(ofSize: 12.5)
        teamLabel.textColor = Theme.sub
        clubLabel.font = .systemFont(ofSize: 11.5)
        clubLabel.textColor = Theme.faint
        ovrLabel.font = Theme.numFont(30, weight: .bold)
        ovrLabel.textColor = Theme.text
        ovrCaption.text = "OVR"
        ovrCaption.font = Theme.numFont(9.5, weight: .semibold)
        ovrCaption.textColor = Theme.faint
        chevron.tintColor = Theme.faint
        chevron.contentMode = .scaleAspectFit

        nameRow.axis = .horizontal; nameRow.spacing = 7; nameRow.alignment = .center
        teamRow.axis = .horizontal; teamRow.spacing = 6; teamRow.alignment = .center
        clubRow.axis = .horizontal; clubRow.spacing = 5; clubRow.alignment = .center

        let ovrStack = UIStackView(arrangedSubviews: [ovrLabel, ovrCaption])
        ovrStack.axis = .vertical; ovrStack.alignment = .trailing; ovrStack.spacing = -2

        let textCol = UIStackView(arrangedSubviews: [nameRow, teamRow, clubRow])
        textCol.axis = .vertical; textCol.spacing = 5; textCol.alignment = .leading

        [bgCard, portrait, textCol, ovrStack, chevron].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        [portrait, textCol, ovrStack, chevron].forEach { bgCard.addSubview($0) }

        NSLayoutConstraint.activate([
            bgCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            bgCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
            bgCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            bgCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),

            portrait.leadingAnchor.constraint(equalTo: bgCard.leadingAnchor, constant: 14),
            portrait.centerYAnchor.constraint(equalTo: bgCard.centerYAnchor),
            portrait.widthAnchor.constraint(equalToConstant: 48),
            portrait.heightAnchor.constraint(equalToConstant: 48),

            textCol.leadingAnchor.constraint(equalTo: portrait.trailingAnchor, constant: 14),
            textCol.centerYAnchor.constraint(equalTo: bgCard.centerYAnchor),
            textCol.trailingAnchor.constraint(lessThanOrEqualTo: ovrStack.leadingAnchor, constant: -8),

            chevron.trailingAnchor.constraint(equalTo: bgCard.trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: bgCard.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 8),
            ovrStack.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -12),
            ovrStack.centerYAnchor.constraint(equalTo: bgCard.centerYAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(_ p: Player, picked: Bool) {
        portrait.configure(player: p)
        nameLabel.text = p.name
        ovrLabel.text = "\(p.ovr)"
        ovrLabel.textColor = p.tier.color          // 등급별 OVR 색상
        teamLabel.text = "\(p.teamName) · \(p.pos)"
        clubLabel.text = p.club

        nameRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        teamRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        clubRow.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 1행: 이름 + 등급배지 + 포지션칩 (+픽)
        nameRow.addArrangedSubview(nameLabel)
        nameRow.addArrangedSubview(TierBadge(tier: p.tier, size: 20))
        nameRow.addArrangedSubview(PosChipView(cat: p.cat, small: true))
        if picked { nameRow.addArrangedSubview(pickedLabel) }
        // 2행: 국기 + 국가·포지션
        teamRow.addArrangedSubview(FlagBadge(nation: p.nation, size: 17))
        teamRow.addArrangedSubview(teamLabel)
        // 3행: 클럽 아이콘 + 클럽명
        let clubIcon = UIImageView(image: UIImage(systemName: "shield.lefthalf.filled"))
        clubIcon.tintColor = Theme.faint
        clubIcon.contentMode = .scaleAspectFit
        clubIcon.translatesAutoresizingMaskIntoConstraints = false
        clubIcon.widthAnchor.constraint(equalToConstant: 11).isActive = true
        clubIcon.heightAnchor.constraint(equalToConstant: 11).isActive = true
        clubRow.addArrangedSubview(clubIcon)
        clubRow.addArrangedSubview(clubLabel)

        bgCard.layer.borderColor = (picked ? Theme.accentDim : Theme.line).cgColor
    }
}
