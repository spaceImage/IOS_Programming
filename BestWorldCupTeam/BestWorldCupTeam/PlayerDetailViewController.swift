import UIKit

final class PlayerDetailViewController: UIViewController {

    private let player: Player
    private let pickButton = UIButton(type: .system)
    private var statBars: [StatBarView] = []
    private let scrollContent = UIView()

    init(player: Player) { self.player = player; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        title = "선수 상세"

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scrollContent.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(scrollContent)

        // 픽 버튼
        updatePickButton()
        pickButton.layer.cornerRadius = 15
        pickButton.titleLabel?.font = .systemFont(ofSize: 16.5, weight: .heavy)
        pickButton.translatesAutoresizingMaskIntoConstraints = false
        pickButton.addTarget(self, action: #selector(pick), for: .touchUpInside)
        view.addSubview(pickButton)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: pickButton.topAnchor, constant: -8),
            scrollContent.topAnchor.constraint(equalTo: scroll.topAnchor),
            scrollContent.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            scrollContent.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            scrollContent.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            scrollContent.widthAnchor.constraint(equalTo: scroll.widthAnchor),

            pickButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            pickButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            pickButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            pickButton.heightAnchor.constraint(equalToConstant: 52),
        ])

        buildContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for (i, bar) in statBars.enumerated() { bar.animateFill(in: scrollContent, delay: Double(i) * 0.07) }
    }

    private func buildContent() {
        // 히어로
        let portrait = PortraitView()
        portrait.configure(player: player)
        portrait.translatesAutoresizingMaskIntoConstraints = false

        let posChip = PosChipView(cat: player.cat)
        let tierBadge = TierBadge(tier: player.tier, size: 24)
        let natLabel = UILabel()
        natLabel.text = "\(player.flag) \(player.teamName)"
        natLabel.font = .systemFont(ofSize: 13); natLabel.textColor = Theme.sub
        let chipRow = UIStackView(arrangedSubviews: [tierBadge, posChip, natLabel])
        chipRow.spacing = 8; chipRow.alignment = .center

        let nameLabel = UILabel()
        nameLabel.text = player.name
        nameLabel.font = .systemFont(ofSize: 30, weight: .heavy)
        nameLabel.textColor = Theme.text

        // 소속 클럽
        let clubIcon = UIImageView(image: UIImage(systemName: "shield.lefthalf.filled"))
        clubIcon.tintColor = Theme.sub
        clubIcon.contentMode = .scaleAspectFit
        clubIcon.translatesAutoresizingMaskIntoConstraints = false
        clubIcon.widthAnchor.constraint(equalToConstant: 13).isActive = true
        clubIcon.heightAnchor.constraint(equalToConstant: 13).isActive = true
        let clubLabel = UILabel()
        clubLabel.text = player.club
        clubLabel.font = .systemFont(ofSize: 13.5, weight: .medium); clubLabel.textColor = Theme.sub
        let clubRow = UIStackView(arrangedSubviews: [clubIcon, clubLabel])
        clubRow.spacing = 6; clubRow.alignment = .center

        let metaLabel = UILabel()
        metaLabel.text = "\(player.conf) · \(player.age)세 · \(player.foot) · \(player.tier.desc)"
        metaLabel.font = .systemFont(ofSize: 13); metaLabel.textColor = Theme.faint

        let info = UIStackView(arrangedSubviews: [chipRow, nameLabel, clubRow, metaLabel])
        info.axis = .vertical; info.spacing = 7; info.alignment = .leading

        let hero = UIStackView(arrangedSubviews: [portrait, info])
        hero.spacing = 16; hero.alignment = .center
        hero.translatesAutoresizingMaskIntoConstraints = false

        // OVR 스트립
        let strip = UIStackView()
        strip.axis = .horizontal; strip.spacing = 9; strip.distribution = .fillEqually
        strip.translatesAutoresizingMaskIntoConstraints = false
        let cells: [(String,String,Bool)] = [("OVR","\(player.ovr)",true),("포지션",player.pos,false),("등번호","#\(player.number)",false),("주발",player.foot,false)]
        for (k,v,hl) in cells { strip.addArrangedSubview(statCard(k, v, hl)) }

        // 능력치
        let attrTitle = UILabel()
        attrTitle.text = "ATTRIBUTES · 능력치"
        attrTitle.font = Theme.numFont(12, weight: .bold)
        attrTitle.textColor = Theme.faint

        let barsStack = UIStackView()
        barsStack.axis = .vertical; barsStack.spacing = 12
        for s in player.stats { let b = StatBarView(stat: s); statBars.append(b); barsStack.addArrangedSubview(b) }

        let main = UIStackView(arrangedSubviews: [hero, strip, attrTitle, barsStack])
        main.axis = .vertical; main.spacing = 24; main.setCustomSpacing(26, after: strip)
        main.translatesAutoresizingMaskIntoConstraints = false
        scrollContent.addSubview(main)

        NSLayoutConstraint.activate([
            portrait.widthAnchor.constraint(equalToConstant: 88),
            portrait.heightAnchor.constraint(equalToConstant: 88),
            main.topAnchor.constraint(equalTo: scrollContent.topAnchor, constant: 18),
            main.leadingAnchor.constraint(equalTo: scrollContent.leadingAnchor, constant: 22),
            main.trailingAnchor.constraint(equalTo: scrollContent.trailingAnchor, constant: -22),
            main.bottomAnchor.constraint(equalTo: scrollContent.bottomAnchor, constant: -20),
        ])
    }

    private func statCard(_ k: String, _ v: String, _ hl: Bool) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.card
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        let tierColor = player.tier.color
        card.layer.borderColor = (hl ? tierColor.withAlphaComponent(0.4) : Theme.line).cgColor
        let val = UILabel(); val.text = v
        val.font = Theme.numFont(hl ? 24 : 18, weight: .bold)
        val.textColor = hl ? tierColor : Theme.text
        let cap = UILabel(); cap.text = k; cap.font = .systemFont(ofSize: 10); cap.textColor = Theme.faint
        let s = UIStackView(arrangedSubviews: [val, cap])
        s.axis = .vertical; s.alignment = .center; s.spacing = 4
        s.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(s)
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 60),
            s.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            s.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])
        return card
    }

    @objc private func pick() {
        let msg = AppState.shared.togglePick(player)
        Toast.show(msg, in: view)
        updatePickButton()
    }

    private func updatePickButton() {
        let picked = AppState.shared.isPicked(player.id)
        pickButton.setTitle(picked ? "✓ 드림팀에서 빼기" : "⭐ 이 선수 픽!", for: .normal)
        pickButton.backgroundColor = picked ? Theme.card : Theme.accent
        pickButton.setTitleColor(picked ? Theme.text : Theme.accentInk, for: .normal)
        pickButton.layer.borderWidth = picked ? 1.5 : 0
        pickButton.layer.borderColor = Theme.line2.cgColor
    }
}
