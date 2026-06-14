import UIKit

final class DreamTeamViewController: UIViewController, PitchViewDelegate {

    private let countLabel = UILabel()
    private let subLabel = UILabel()
    private let formationButton = UIButton(type: .system)
    private let pitch = PitchView()
    private let resetButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        navigationItem.largeTitleDisplayMode = .never

        let title = UILabel()
        title.text = "내 드림팀"
        title.font = .systemFont(ofSize: 27, weight: .heavy)
        title.textColor = Theme.text
        countLabel.font = Theme.numFont(17, weight: .bold)
        subLabel.font = .systemFont(ofSize: 12.5)
        subLabel.textColor = Theme.faint

        // 도움말(ⓘ) 버튼
        let helpButton = UIButton(type: .system)
        helpButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        helpButton.tintColor = Theme.accent
        helpButton.addTarget(self, action: #selector(showHelp), for: .touchUpInside)
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.widthAnchor.constraint(equalToConstant: 26).isActive = true
        helpButton.heightAnchor.constraint(equalToConstant: 26).isActive = true

        let titleRow = UIStackView(arrangedSubviews: [title, countLabel, helpButton])
        titleRow.spacing = 7; titleRow.alignment = .center
        let headerLeft = UIStackView(arrangedSubviews: [titleRow, subLabel])
        headerLeft.axis = .vertical; headerLeft.spacing = 3; headerLeft.alignment = .leading

        formationButton.titleLabel?.font = Theme.numFont(15, weight: .bold)
        formationButton.setTitleColor(Theme.text, for: .normal)
        formationButton.backgroundColor = Theme.card
        formationButton.layer.cornerRadius = 11
        formationButton.layer.borderWidth = 1
        formationButton.layer.borderColor = Theme.line2.cgColor
        formationButton.contentEdgeInsets = .init(top: 8, left: 13, bottom: 8, right: 13)
        formationButton.addTarget(self, action: #selector(openFormation), for: .touchUpInside)

        let header = UIStackView(arrangedSubviews: [headerLeft, UIView(), formationButton])
        header.alignment = .center
        header.translatesAutoresizingMaskIntoConstraints = false

        pitch.delegate = self
        pitch.translatesAutoresizingMaskIntoConstraints = false

        resetButton.setTitle("전체 초기화", for: .normal)
        resetButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        resetButton.setTitleColor(UIColor(hex: "#FF5D6C"), for: .normal)
        resetButton.layer.cornerRadius = 13
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = Theme.line.cgColor
        resetButton.addTarget(self, action: #selector(resetTeam), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(header); view.addSubview(pitch); view.addSubview(resetButton)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            pitch.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            pitch.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            pitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            pitch.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -10),

            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -6),
            resetButton.heightAnchor.constraint(equalToConstant: 46),
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .dreamTeamChanged, object: nil)
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); refresh() }

    @objc private func refresh() {
        let st = AppState.shared
        countLabel.text = "\(st.count)/11"
        countLabel.textColor = st.count == 11 ? Theme.accent : Theme.sub
        let avg = st.avgOVR
        subLabel.text = "평균 OVR \(avg == 0 ? "–" : "\(avg)") · 드래그로 교체"
        formationButton.setTitle(st.formation + "  ▾", for: .normal)
        pitch.configure(slots: st.slots)
        resetButton.isEnabled = st.count > 0
        resetButton.alpha = st.count > 0 ? 1 : 0.5
    }

    // MARK: PitchViewDelegate
    func pitch(_ pitch: PitchView, didTapPlayer id: String) {
        guard let p = DataStore.player(id) else { return }
        navigationController?.pushViewController(PlayerDetailViewController(player: p), animated: true)
    }
    func pitch(_ pitch: PitchView, didTapEmpty slot: Slot) {
        Toast.show("\(slot.cat.korName)을(를) 골라 \(slot.label) 자리를 채워보세요", in: view)
        if let tab = tabBarController, let nav = tab.viewControllers?[1] as? UINavigationController,
           let players = nav.viewControllers.first as? PlayersViewController {
            players.focus(cat: slot.cat)
            tab.selectedIndex = 1
        }
    }
    func pitch(_ pitch: PitchView, didSwap from: String, to: String) {
        AppState.shared.swap(from, to)
    }

    // MARK: 액션
    @objc private func openFormation() {
        let vc = FormationPickerViewController(current: AppState.shared.formation) { f in
            AppState.shared.setFormation(f)
        }
        present(vc, animated: true)
    }
    @objc private func resetTeam() {
        AppState.shared.reset()
        Toast.show("드림팀을 초기화했어요", in: view)
    }

    @objc private func showHelp() {
        let help = HelpViewController()
        let nav = UINavigationController(rootViewController: help)
        present(nav, animated: true)
    }
}
