import UIKit

final class CompleteViewController: UIViewController {

    private let scroll = UIScrollView()
    private let content = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        navigationItem.largeTitleDisplayMode = .never

        let title = UILabel()
        title.text = "팀 완성"
        title.font = .systemFont(ofSize: 27, weight: .heavy); title.textColor = Theme.text
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        content.axis = .vertical; content.spacing = 12
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scroll.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.topAnchor.constraint(equalTo: scroll.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -16),
            content.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -20),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -32),
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(rebuild), name: .dreamTeamChanged, object: nil)
        rebuild()
    }
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); rebuild() }

    @objc private func rebuild() {
        content.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let st = AppState.shared
        if st.count < 11 { content.addArrangedSubview(makeEmpty(remaining: 11 - st.count)); return }

        content.addArrangedSubview(makeTrophyCard())
        let lineTitle = UILabel()
        lineTitle.text = "라인업 · \(st.formation)"
        lineTitle.font = .systemFont(ofSize: 12.5, weight: .semibold); lineTitle.textColor = Theme.faint
        content.addArrangedSubview(lineTitle)

        for (cat, label) in [(PosCat.FW,"공격"),(.MF,"미드필더"),(.DF,"수비"),(.GK,"골키퍼")] {
            let ps = st.players.filter { $0.cat == cat }.sorted { $0.ovr > $1.ovr }
            if ps.isEmpty { continue }
            content.addArrangedSubview(makeLineGroup(cat: cat, label: label, players: ps))
        }

        // 액션
        let formBtn = UIButton(type: .system)
        formBtn.setTitle("포메이션 보기", for: .normal)
        formBtn.titleLabel?.font = .systemFont(ofSize: 14.5, weight: .bold)
        formBtn.setTitleColor(Theme.text, for: .normal)
        formBtn.layer.cornerRadius = 13; formBtn.layer.borderWidth = 1; formBtn.layer.borderColor = Theme.line2.cgColor
        formBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        formBtn.addTarget(self, action: #selector(goTeam), for: .touchUpInside)
        let saveBtn = UIButton(type: .system)
        saveBtn.setTitle(st.saved ? "✓ 저장됨" : "☁️ 저장하기", for: .normal)
        saveBtn.titleLabel?.font = .systemFont(ofSize: 14.5, weight: .heavy)
        saveBtn.setTitleColor(st.saved ? Theme.accent : Theme.accentInk, for: .normal)
        saveBtn.backgroundColor = st.saved ? Theme.accentDim : Theme.accent
        saveBtn.layer.cornerRadius = 13
        saveBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        saveBtn.addTarget(self, action: #selector(save), for: .touchUpInside)
        let actions = UIStackView(arrangedSubviews: [formBtn, saveBtn])
        actions.spacing = 10; actions.distribution = .fillEqually
        content.addArrangedSubview(actions)
    }

    private func makeEmpty(remaining: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.card
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1; card.layer.borderColor = Theme.line2.cgColor
        let ball = UILabel(); ball.text = "⚽"; ball.font = .systemFont(ofSize: 40)
        let t = UILabel(); t.text = "아직 \(remaining)명이 더 필요해요"; t.font = .systemFont(ofSize: 16, weight: .bold); t.textColor = Theme.text
        let s = UILabel(); s.text = "선수를 모두 채우면\n완성된 드림팀 카드를 받을 수 있어요"
        s.font = .systemFont(ofSize: 13); s.textColor = Theme.sub; s.numberOfLines = 0; s.textAlignment = .center
        let btn = UIButton(type: .system)
        btn.setTitle("선수 픽하러 가기 →", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.setTitleColor(Theme.accentInk, for: .normal)
        btn.backgroundColor = Theme.accent; btn.layer.cornerRadius = 12
        btn.contentEdgeInsets = .init(top: 11, left: 22, bottom: 11, right: 22)
        btn.addTarget(self, action: #selector(goPlayers), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [ball, t, s, btn])
        stack.axis = .vertical; stack.alignment = .center; stack.spacing = 8
        stack.setCustomSpacing(16, after: s)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 32),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -32),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
        ])
        return card
    }

    private func makeTrophyCard() -> UIView {
        let st = AppState.shared
        let card = UIView()
        card.backgroundColor = UIColor(hex: "#221F13")
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1; card.layer.borderColor = Theme.goldDim.cgColor

        let trophy = UILabel(); trophy.text = "🏆"; trophy.font = .systemFont(ofSize: 44)
        let kicker = UILabel(); kicker.text = "MY WORLD CUP XI"; kicker.font = Theme.numFont(11, weight: .bold); kicker.textColor = Theme.gold
        let done = UILabel(); done.text = "드림팀 완성!"; done.font = .systemFont(ofSize: 19, weight: .heavy); done.textColor = Theme.text
        let mid = UIStackView(arrangedSubviews: [kicker, done]); mid.axis = .vertical; mid.spacing = 3; mid.alignment = .leading
        let ovr = UILabel(); ovr.text = "\(st.avgOVR)"; ovr.font = Theme.numFont(34, weight: .bold); ovr.textColor = Theme.gold
        let ovrCap = UILabel(); ovrCap.text = "TEAM OVR"; ovrCap.font = Theme.numFont(9.5, weight: .semibold); ovrCap.textColor = Theme.faint
        let ovrStack = UIStackView(arrangedSubviews: [ovr, ovrCap]); ovrStack.axis = .vertical; ovrStack.alignment = .trailing
        let top = UIStackView(arrangedSubviews: [trophy, mid, UIView(), ovrStack])
        top.spacing = 14; top.alignment = .center

        // 국가 분포
        var dist: [String:Int] = [:]
        st.players.forEach { dist[$0.natCode, default: 0] += 1 }
        let flow = UIStackView(); flow.axis = .horizontal; flow.spacing = 6
        let flowWrap = WrapStack(); flowWrap.spacing = 6; flowWrap.lineSpacing = 6
        for (code, n) in dist.sorted(by: { $0.value > $1.value }) {
            guard let nat = DataStore.nations[code] else { continue }
            let chip = UIView(); chip.backgroundColor = UIColor(white: 1, alpha: 0.05); chip.layer.cornerRadius = 8
            let f = UILabel(); f.text = nat.flag; f.font = .systemFont(ofSize: 14)
            let nm = UILabel(); nm.text = nat.name; nm.font = .systemFont(ofSize: 12); nm.textColor = Theme.sub
            let cnt = UILabel(); cnt.text = "\(n)"; cnt.font = Theme.numFont(12, weight: .bold); cnt.textColor = Theme.gold
            let row = UIStackView(arrangedSubviews: [f, nm, cnt]); row.spacing = 5; row.alignment = .center
            row.isLayoutMarginsRelativeArrangement = true; row.layoutMargins = .init(top: 4, left: 9, bottom: 4, right: 9)
            row.translatesAutoresizingMaskIntoConstraints = false
            chip.addSubview(row)
            NSLayoutConstraint.activate([row.topAnchor.constraint(equalTo: chip.topAnchor), row.bottomAnchor.constraint(equalTo: chip.bottomAnchor), row.leadingAnchor.constraint(equalTo: chip.leadingAnchor), row.trailingAnchor.constraint(equalTo: chip.trailingAnchor)])
            flowWrap.addArrangedSubview(chip)
        }

        let main = UIStackView(arrangedSubviews: [top, flowWrap])
        main.axis = .vertical; main.spacing = 16
        main.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(main)
        NSLayoutConstraint.activate([
            main.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            main.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
            main.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            main.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
        ])
        return card
    }

    private func makeLineGroup(cat: PosCat, label: String, players: [Player]) -> UIView {
        let bar = UIView(); bar.backgroundColor = cat.color; bar.layer.cornerRadius = 2
        bar.widthAnchor.constraint(equalToConstant: 4).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 13).isActive = true
        let lbl = UILabel(); lbl.text = label; lbl.font = .systemFont(ofSize: 12, weight: .bold); lbl.textColor = Theme.sub
        let head = UIStackView(arrangedSubviews: [bar, lbl]); head.spacing = 7; head.alignment = .center

        let rows = UIStackView(); rows.axis = .vertical; rows.spacing = 6
        for p in players { rows.addArrangedSubview(makePlayerRow(p)) }

        let group = UIStackView(arrangedSubviews: [head, rows])
        group.axis = .vertical; group.spacing = 7
        return group
    }

    private func makePlayerRow(_ p: Player) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.card; card.layer.cornerRadius = 12
        card.layer.borderWidth = 1; card.layer.borderColor = Theme.line.cgColor
        let portrait = PortraitView(); portrait.configure(player: p)
        portrait.translatesAutoresizingMaskIntoConstraints = false
        let name = UILabel(); name.text = p.name; name.font = .systemFont(ofSize: 15, weight: .bold); name.textColor = Theme.text
        let flag = UILabel(); flag.text = p.flag; flag.font = .systemFont(ofSize: 16)
        let ovr = UILabel(); ovr.text = "\(p.ovr)"; ovr.font = Theme.numFont(18, weight: .bold); ovr.textColor = Theme.text
        let row = UIStackView(arrangedSubviews: [portrait, name, UIView(), flag, ovr])
        row.spacing = 11; row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(row)
        NSLayoutConstraint.activate([
            portrait.widthAnchor.constraint(equalToConstant: 36),
            portrait.heightAnchor.constraint(equalToConstant: 36),
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 9),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -9),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
        ])
        return card
    }

    @objc private func save() { AppState.shared.save(); Toast.show("☁️ 완성된 드림팀을 저장했어요!", in: view); rebuild() }
    @objc private func goTeam() { tabBarController?.selectedIndex = 2 }
    @objc private func goPlayers() { tabBarController?.selectedIndex = 1 }
}
