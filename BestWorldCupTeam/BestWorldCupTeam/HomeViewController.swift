import UIKit

final class HomeViewController: UIViewController {

    private let ring = RingView()
    private let ringCount = UILabel()
    private let statusLabel = UILabel()
    private let metaLabel = UILabel()
    private let carousel = UIScrollView()
    private let carStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        navigationItem.largeTitleDisplayMode = .never
        build()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .dreamTeamChanged, object: nil)
        refresh()
    }
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); refresh() }

    private func build() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        let content = UIStackView()
        content.axis = .vertical; content.spacing = 20
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 8),
            content.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -16),
            content.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -20),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -32),
        ])

        // 헤더
        let kicker = UILabel()
        kicker.text = "🏆 WORLD CUP 2026"
        kicker.font = Theme.numFont(12, weight: .bold); kicker.textColor = Theme.gold
        let title = UILabel()
        title.text = "나의 드림팀"
        title.font = .systemFont(ofSize: 28, weight: .heavy); title.textColor = Theme.text
        let head = UIStackView(arrangedSubviews: [kicker, title])
        head.axis = .vertical; head.spacing = 4; head.alignment = .leading

        // 도움말 버튼 (❗️동그라미)
        let helpButton = UIButton(type: .system)
        helpButton.setImage(UIImage(systemName: "exclamationmark.circle.fill"), for: .normal)
        helpButton.tintColor = Theme.gold
        helpButton.setPreferredSymbolConfiguration(.init(pointSize: 28, weight: .regular), forImageIn: .normal)
        helpButton.addTarget(self, action: #selector(openHelp), for: .touchUpInside)
        helpButton.setContentHuggingPriority(.required, for: .horizontal)

        let headerRow = UIStackView(arrangedSubviews: [head, UIView(), helpButton])
        headerRow.alignment = .center
        content.addArrangedSubview(headerRow)

        // 완성도 카드
        content.addArrangedSubview(makeProgressCard())

        // 바로가기
        let quick = UIStackView(arrangedSubviews: [
            quickButton("선수 둘러보기", "🔍", #selector(goPlayers)),
            quickButton("포메이션 짜기", "⚽", #selector(goTeam)),
        ])
        quick.spacing = 10; quick.distribution = .fillEqually
        content.addArrangedSubview(quick)

        // 최고 평점
        let secTitle = UILabel()
        secTitle.text = "최고 평점 선수"
        secTitle.font = .systemFont(ofSize: 16, weight: .heavy); secTitle.textColor = Theme.text
        content.addArrangedSubview(secTitle)

        carousel.showsHorizontalScrollIndicator = false
        carStack.axis = .horizontal; carStack.spacing = 13
        carStack.translatesAutoresizingMaskIntoConstraints = false
        carousel.addSubview(carStack)
        carousel.heightAnchor.constraint(equalToConstant: 200).isActive = true
        NSLayoutConstraint.activate([
            carStack.topAnchor.constraint(equalTo: carousel.topAnchor),
            carStack.bottomAnchor.constraint(equalTo: carousel.bottomAnchor),
            carStack.leadingAnchor.constraint(equalTo: carousel.leadingAnchor),
            carStack.trailingAnchor.constraint(equalTo: carousel.trailingAnchor),
            carStack.heightAnchor.constraint(equalTo: carousel.heightAnchor),
        ])
        content.addArrangedSubview(carousel)
        buildCarousel()

        // 최근 경기 결과
        let matchTitle = UILabel()
        matchTitle.text = "⚽ 최근 경기 결과"
        matchTitle.font = .systemFont(ofSize: 16, weight: .heavy); matchTitle.textColor = Theme.text
        content.addArrangedSubview(matchTitle)

        let matchStack = UIStackView()
        matchStack.axis = .vertical; matchStack.spacing = 10
        for m in DataStore.recentMatches {
            matchStack.addArrangedSubview(makeMatchRow(m))
        }
        content.addArrangedSubview(matchStack)
    }

    private func makeMatchRow(_ m: MatchResult) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.card
        card.layer.cornerRadius = 14
        card.layer.borderWidth = 1; card.layer.borderColor = Theme.line.cgColor

        let homeFlag = UILabel(); homeFlag.text = m.home?.flag ?? ""; homeFlag.font = .systemFont(ofSize: 18)
        let homeName = UILabel(); homeName.text = m.home?.name ?? m.homeCode
        homeName.font = .systemFont(ofSize: 12, weight: .semibold); homeName.textColor = Theme.text
        homeName.textAlignment = .right
        homeName.lineBreakMode = .byTruncatingTail
        let homeSide = UIStackView(arrangedSubviews: [homeName, homeFlag])
        homeSide.spacing = 6; homeSide.alignment = .center

        let score = UILabel()
        score.text = "\(m.homeScore) - \(m.awayScore)"
        score.font = Theme.numFont(16, weight: .bold); score.textColor = Theme.accent
        score.textAlignment = .center
        score.setContentHuggingPriority(.required, for: .horizontal)

        let awayFlag = UILabel(); awayFlag.text = m.away?.flag ?? ""; awayFlag.font = .systemFont(ofSize: 18)
        let awayName = UILabel(); awayName.text = m.away?.name ?? m.awayCode
        awayName.font = .systemFont(ofSize: 12, weight: .semibold); awayName.textColor = Theme.text
        awayName.textAlignment = .left
        awayName.lineBreakMode = .byTruncatingTail
        let awaySide = UIStackView(arrangedSubviews: [awayFlag, awayName])
        awaySide.spacing = 6; awaySide.alignment = .center

        let row = UIStackView(arrangedSubviews: [homeSide, score, awaySide])
        row.distribution = .fill; row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        homeSide.translatesAutoresizingMaskIntoConstraints = false
        awaySide.translatesAutoresizingMaskIntoConstraints = false
        homeSide.widthAnchor.constraint(equalTo: awaySide.widthAnchor).isActive = true

        let stage = UILabel()
        stage.text = m.stage
        stage.font = .systemFont(ofSize: 10.5); stage.textColor = Theme.faint
        stage.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(row); card.addSubview(stage)
        score.widthAnchor.constraint(equalToConstant: 56).isActive = true
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            stage.topAnchor.constraint(equalTo: row.bottomAnchor, constant: 6),
            stage.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            stage.centerXAnchor.constraint(equalTo: card.centerXAnchor),
        ])
        return card
    }

    private func makeProgressCard() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(hex: "#15211A")
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1; card.layer.borderColor = Theme.line.cgColor

        ring.translatesAutoresizingMaskIntoConstraints = false
        ringCount.font = Theme.numFont(22, weight: .bold); ringCount.textColor = Theme.text
        ringCount.textAlignment = .center
        let ringCap = UILabel(); ringCap.text = "/ 11"; ringCap.font = Theme.numFont(11); ringCap.textColor = Theme.faint; ringCap.textAlignment = .center
        let ringText = UIStackView(arrangedSubviews: [ringCount, ringCap])
        ringText.axis = .vertical; ringText.spacing = -2; ringText.alignment = .center
        ringText.translatesAutoresizingMaskIntoConstraints = false
        ring.addSubview(ringText)

        statusLabel.font = .systemFont(ofSize: 15, weight: .bold); statusLabel.textColor = Theme.text
        metaLabel.font = .systemFont(ofSize: 12.5); metaLabel.textColor = Theme.sub
        let goBtn = UIButton(type: .system)
        goBtn.setTitle("드림팀 보기 →", for: .normal)
        goBtn.titleLabel?.font = .systemFont(ofSize: 12.5, weight: .bold)
        goBtn.setTitleColor(Theme.accent, for: .normal)
        goBtn.backgroundColor = Theme.accentDim
        goBtn.layer.cornerRadius = 9
        goBtn.contentEdgeInsets = .init(top: 7, left: 13, bottom: 7, right: 13)
        goBtn.addTarget(self, action: #selector(goTeam), for: .touchUpInside)
        let goWrap = UIStackView(arrangedSubviews: [goBtn, UIView()])
        let right = UIStackView(arrangedSubviews: [statusLabel, metaLabel, goWrap])
        right.axis = .vertical; right.spacing = 4; right.alignment = .leading
        right.setCustomSpacing(11, after: metaLabel)

        let row = UIStackView(arrangedSubviews: [ring, right])
        row.spacing = 18; row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)
        NSLayoutConstraint.activate([
            ring.widthAnchor.constraint(equalToConstant: 76),
            ring.heightAnchor.constraint(equalToConstant: 76),
            ringText.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            ringText.centerYAnchor.constraint(equalTo: ring.centerYAnchor),
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
        ])
        return card
    }

    private func quickButton(_ t: String, _ icon: String, _ sel: Selector) -> UIButton {
        let b = UIButton(type: .system)
        b.backgroundColor = Theme.card
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 1; b.layer.borderColor = Theme.line.cgColor
        b.contentHorizontalAlignment = .leading
        let ic = UILabel(); ic.text = icon; ic.font = .systemFont(ofSize: 22)
        let lb = UILabel(); lb.text = t; lb.font = .systemFont(ofSize: 13.5, weight: .bold); lb.textColor = Theme.text
        let s = UIStackView(arrangedSubviews: [ic, lb])
        s.axis = .vertical; s.spacing = 7; s.alignment = .leading; s.isUserInteractionEnabled = false
        s.translatesAutoresizingMaskIntoConstraints = false
        b.addSubview(s)
        NSLayoutConstraint.activate([
            b.heightAnchor.constraint(equalToConstant: 78),
            s.leadingAnchor.constraint(equalTo: b.leadingAnchor, constant: 14),
            s.centerYAnchor.constraint(equalTo: b.centerYAnchor),
        ])
        b.addTarget(self, action: sel, for: .touchUpInside)
        return b
    }

    private func buildCarousel() {
        carStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let top = DataStore.players.sorted { $0.ovr > $1.ovr }.prefix(8)
        for p in top {
            let card = UIView()
            card.backgroundColor = Theme.card
            card.layer.cornerRadius = 18
            card.layer.borderWidth = 1; card.layer.borderColor = Theme.line.cgColor
            card.widthAnchor.constraint(equalToConstant: 132).isActive = true
            let ovr = UILabel(); ovr.text = "\(p.ovr)"; ovr.font = Theme.numFont(26, weight: .bold); ovr.textColor = p.tier.color
            let badge = TierBadge(tier: p.tier, size: 20)
            let flag = UILabel(); flag.text = p.flag; flag.font = .systemFont(ofSize: 17)
            let topRow = UIStackView(arrangedSubviews: [ovr, badge, UIView(), flag])
            topRow.spacing = 6; topRow.alignment = .center
            let portrait = PortraitView(); portrait.configure(player: p)
            portrait.translatesAutoresizingMaskIntoConstraints = false
            let name = UILabel(); name.text = p.name; name.font = .systemFont(ofSize: 14.5, weight: .bold); name.textColor = Theme.text
            name.lineBreakMode = .byTruncatingTail
            let pos = UILabel(); pos.text = "\(p.pos) · \(p.teamName)"; pos.font = .systemFont(ofSize: 11.5); pos.textColor = Theme.sub
            pos.lineBreakMode = .byTruncatingTail
            let club = UILabel(); club.text = p.club; club.font = .systemFont(ofSize: 10.5); club.textColor = Theme.faint
            club.lineBreakMode = .byTruncatingTail
            let s = UIStackView(arrangedSubviews: [topRow, portrait, name, pos, club])
            s.axis = .vertical; s.spacing = 7; s.alignment = .leading
            s.setCustomSpacing(13, after: topRow)
            s.setCustomSpacing(11, after: portrait)
            s.setCustomSpacing(4, after: pos)
            s.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(s)
            NSLayoutConstraint.activate([
                portrait.widthAnchor.constraint(equalToConstant: 44),
                portrait.heightAnchor.constraint(equalToConstant: 44),
                s.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
                s.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
                s.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
                s.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -16),
            ])
            let tap = UITapGestureRecognizer(target: self, action: #selector(openCard(_:)))
            card.addGestureRecognizer(tap); card.accessibilityIdentifier = p.id
            carStack.addArrangedSubview(card)
        }
    }

    @objc private func refresh() {
        let st = AppState.shared
        ring.progress = CGFloat(st.count) / 11.0
        ringCount.text = "\(st.count)"
        statusLabel.text = st.count == 11 ? "라인업 완성! 🎉" : (st.count == 0 ? "아직 비어 있어요" : "선수를 더 픽하세요")
        let avg = st.avgOVR
        metaLabel.text = "\(st.formation) · 평균 OVR \(avg == 0 ? "–" : "\(avg)")"
    }

    @objc private func goPlayers() { tabBarController?.selectedIndex = 1 }
    @objc private func goTeam() { tabBarController?.selectedIndex = 2 }
    @objc private func openHelp() {
        let help = HelpViewController()
        let nav = UINavigationController(rootViewController: help)
        present(nav, animated: true)
    }
    @objc private func openCard(_ g: UITapGestureRecognizer) {
        guard let id = g.view?.accessibilityIdentifier, let p = DataStore.player(id) else { return }
        navigationController?.pushViewController(PlayerDetailViewController(player: p), animated: true)
    }
}

/// 원형 진행률 링
final class RingView: UIView {
    var progress: CGFloat = 0 { didSet { setNeedsLayout() } }
    private let trackLayer = CAShapeLayer()
    private let fillLayer = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        for l in [trackLayer, fillLayer] {
            l.fillColor = UIColor.clear.cgColor; l.lineWidth = 7; l.lineCap = .round; layer.addSublayer(l)
        }
        trackLayer.strokeColor = UIColor(white: 1, alpha: 0.08).cgColor
        fillLayer.strokeColor = Theme.accent.cgColor
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        let r = bounds.width/2 - 4
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: r,
                                startAngle: -.pi/2, endAngle: -.pi/2 + .pi*2, clockwise: true)
        trackLayer.path = path.cgPath
        fillLayer.path = path.cgPath
        fillLayer.strokeEnd = max(0, min(1, progress))
    }
}
