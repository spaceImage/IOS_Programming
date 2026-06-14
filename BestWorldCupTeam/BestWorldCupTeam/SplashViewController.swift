import UIKit

final class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        addBackgroundGlow()

        // 트로피 엠블럼
        let emblem = UIView()
        emblem.backgroundColor = UIColor(hex: "#19211C")
        emblem.layer.cornerRadius = 26
        emblem.layer.borderWidth = 1.5
        emblem.layer.borderColor = Theme.gold.withAlphaComponent(0.27).cgColor
        let trophy = UILabel()
        trophy.text = "🏆"; trophy.font = .systemFont(ofSize: 50)
        trophy.translatesAutoresizingMaskIntoConstraints = false
        emblem.addSubview(trophy)
        NSLayoutConstraint.activate([
            trophy.centerXAnchor.constraint(equalTo: emblem.centerXAnchor),
            trophy.centerYAnchor.constraint(equalTo: emblem.centerYAnchor),
            emblem.widthAnchor.constraint(equalToConstant: 92),
            emblem.heightAnchor.constraint(equalToConstant: 92),
        ])

        let kicker = label("WORLD CUP 2026", Theme.numFont(12, weight: .bold), Theme.gold)
        kicker.setKern(4)
        let title = label("Dream XI Builder", .systemFont(ofSize: 34, weight: .heavy), Theme.text)
        title.numberOfLines = 0; title.textAlignment = .center
        let subtitle = label("전 세계 스타를 모아\n나만의 월드컵 드림팀을 완성하세요",
                             .systemFont(ofSize: 15.5), Theme.sub)
        subtitle.numberOfLines = 0; subtitle.textAlignment = .center

        // 메타 카드
        let metaCard = makeMetaCard()

        let stack = UIStackView(arrangedSubviews: [emblem, spacer(14), kicker, spacer(6), title, spacer(8), subtitle, spacer(22), metaCard])
        stack.axis = .vertical; stack.alignment = .center; stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        // 시작하기 버튼
        let cta = UIButton(type: .system)
        cta.setTitle("시작하기  →", for: .normal)
        cta.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        cta.setTitleColor(Theme.accentInk, for: .normal)
        cta.backgroundColor = Theme.accent
        cta.layer.cornerRadius = 16
        cta.translatesAutoresizingMaskIntoConstraints = false
        cta.addTarget(self, action: #selector(start), for: .touchUpInside)
        view.addSubview(cta)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            metaCard.widthAnchor.constraint(equalToConstant: 320),
            cta.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cta.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            cta.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            cta.heightAnchor.constraint(equalToConstant: 54),
        ])

        // 엠블럼 둥실 애니메이션
        UIView.animate(withDuration: 1.7, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            emblem.transform = CGAffineTransform(translationX: 0, y: -7)
        }
    }

    @objc private func start() { SceneDelegate.showMain() }

    private func makeMetaCard() -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.card.withAlphaComponent(0.6)
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = Theme.line.cgColor
        let rows: [(String,String)] = [
            ("과목","iOS 프로그래밍"), ("프로젝트 유형","미니 프로젝트"),
            ("개발 플랫폼","VMWare / Xcode"), ("학번 · 이름","2171467 · 최지환"),
        ]
        let vstack = UIStackView(); vstack.axis = .vertical; vstack.translatesAutoresizingMaskIntoConstraints = false
        for (i, r) in rows.enumerated() {
            let k = label(r.0, .systemFont(ofSize: 13), Theme.faint)
            let v = label(r.1, .systemFont(ofSize: 13.5, weight: .semibold), Theme.text)
            let row = UIStackView(arrangedSubviews: [k, UIView(), v])
            row.alignment = .center
            row.heightAnchor.constraint(equalToConstant: 44).isActive = true
            vstack.addArrangedSubview(row)
            if i < rows.count - 1 {
                let sep = UIView(); sep.backgroundColor = Theme.line
                sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
                vstack.addArrangedSubview(sep)
            }
        }
        card.addSubview(vstack)
        NSLayoutConstraint.activate([
            vstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            vstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            vstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 4),
            vstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -4),
        ])
        return card
    }

    private func addBackgroundGlow() {
        let glow = CAGradientLayer()
        glow.type = .radial
        glow.colors = [UIColor(hex: "#123A24").cgColor, Theme.bg.cgColor]
        glow.locations = [0, 0.6]
        glow.startPoint = CGPoint(x: 0.5, y: 0.0)
        glow.endPoint = CGPoint(x: 1.3, y: 0.9)
        glow.frame = UIScreen.main.bounds
        view.layer.insertSublayer(glow, at: 0)
    }

    // 헬퍼
    private func label(_ t: String, _ f: UIFont, _ c: UIColor) -> UILabel {
        let l = UILabel(); l.text = t; l.font = f; l.textColor = c; return l
    }
    private func spacer(_ h: CGFloat) -> UIView {
        let v = UIView(); v.heightAnchor.constraint(equalToConstant: h).isActive = true; return v
    }
}

private extension UILabel {
    func setKern(_ k: CGFloat) {
        guard let t = text else { return }
        attributedText = NSAttributedString(string: t, attributes: [.kern: k])
    }
}
