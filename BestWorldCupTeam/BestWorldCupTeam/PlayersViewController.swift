import UIKit

final class PlayersViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchField = UITextField()
    private let confControl = UISegmentedControl(items: DataStore.confs)
    private let natScroll = UIScrollView()
    private let natStack = UIStackView()
    private let filterStack = UIStackView()
    private let countLabel = UILabel()
    private let sortButton = UIButton(type: .system)

    private var conf = "전체"
    private var natFilter: String? = nil
    private var posFilter = "전체"
    private var search = ""
    private var sort = "ovr"   // ovr / name / no
    private var rows: [Player] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        title = "선수 탐색"
        navigationController?.navigationBar.prefersLargeTitles = true

        sortButton.setTitle("OVR순", for: .normal)
        sortButton.setTitleColor(Theme.sub, for: .normal)
        sortButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        sortButton.addTarget(self, action: #selector(openSort), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortButton)

        setupHeader()
        setupTable()
        reload()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .dreamTeamChanged, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    // MARK: 헤더 (검색 / 대륙 / 국가칩 / 포지션)
    private func setupHeader() {
        // 검색창
        let searchWrap = UIView()
        searchWrap.backgroundColor = Theme.card
        searchWrap.layer.cornerRadius = 12
        searchWrap.layer.borderWidth = 1
        searchWrap.layer.borderColor = Theme.line.cgColor
        let mag = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        mag.tintColor = Theme.faint
        searchField.placeholder = "선수·국가 검색…"
        searchField.textColor = Theme.text
        searchField.font = .systemFont(ofSize: 15)
        searchField.attributedPlaceholder = NSAttributedString(string: "선수·국가 검색…", attributes: [.foregroundColor: Theme.faint])
        searchField.returnKeyType = .done
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        [mag, searchField].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; searchWrap.addSubview($0) }
        NSLayoutConstraint.activate([
            mag.leadingAnchor.constraint(equalTo: searchWrap.leadingAnchor, constant: 13),
            mag.centerYAnchor.constraint(equalTo: searchWrap.centerYAnchor),
            mag.widthAnchor.constraint(equalToConstant: 15), mag.heightAnchor.constraint(equalToConstant: 15),
            searchField.leadingAnchor.constraint(equalTo: mag.trailingAnchor, constant: 8),
            searchField.trailingAnchor.constraint(equalTo: searchWrap.trailingAnchor, constant: -12),
            searchField.topAnchor.constraint(equalTo: searchWrap.topAnchor),
            searchField.bottomAnchor.constraint(equalTo: searchWrap.bottomAnchor),
            searchWrap.heightAnchor.constraint(equalToConstant: 42),
        ])

        // 대륙 세그먼트
        confControl.selectedSegmentIndex = 0
        confControl.selectedSegmentTintColor = Theme.cardHi
        confControl.backgroundColor = Theme.card
        confControl.setTitleTextAttributes([.foregroundColor: Theme.faint], for: .normal)
        confControl.setTitleTextAttributes([.foregroundColor: Theme.text], for: .selected)
        confControl.addTarget(self, action: #selector(confChanged), for: .valueChanged)

        // 국가 칩 (가로 스크롤)
        natScroll.showsHorizontalScrollIndicator = false
        natStack.axis = .horizontal; natStack.spacing = 8
        natStack.translatesAutoresizingMaskIntoConstraints = false
        natScroll.addSubview(natStack)
        NSLayoutConstraint.activate([
            natStack.topAnchor.constraint(equalTo: natScroll.topAnchor),
            natStack.bottomAnchor.constraint(equalTo: natScroll.bottomAnchor),
            natStack.leadingAnchor.constraint(equalTo: natScroll.leadingAnchor),
            natStack.trailingAnchor.constraint(equalTo: natScroll.trailingAnchor),
        ])
        rebuildNatChips()

        // 포지션 필터
        filterStack.axis = .horizontal; filterStack.spacing = 7; filterStack.distribution = .fillEqually
        rebuildPosFilter()

        countLabel.font = .systemFont(ofSize: 12)
        countLabel.textColor = Theme.faint

        let header = UIStackView(arrangedSubviews: [searchWrap, confControl, natScroll, filterStack, countLabel])
        header.axis = .vertical; header.spacing = 11
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confControl.heightAnchor.constraint(equalToConstant: 32),
            natScroll.heightAnchor.constraint(equalToConstant: 34),
            filterStack.heightAnchor.constraint(equalToConstant: 36),
        ])
        headerBottom = countLabel.bottomAnchor
    }
    private var headerBottom: NSLayoutYAxisAnchor!

    private func rebuildNatChips() {
        natStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let codes = DataStore.nations.values
            .filter { conf == "전체" || $0.conf == conf }
            .sorted { $0.code < $1.code }
        for n in codes {
            let on = natFilter == n.code
            let b = UIButton(type: .system)
            b.setTitle("  \(n.flag) \(n.name)  ", for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            b.setTitleColor(on ? Theme.text : Theme.sub, for: .normal)
            b.backgroundColor = on ? n.color.withAlphaComponent(0.15) : Theme.card
            b.layer.cornerRadius = 16
            b.layer.borderWidth = 1
            b.layer.borderColor = (on ? n.color : Theme.line).cgColor
            b.heightAnchor.constraint(equalToConstant: 32).isActive = true
            b.tag = codes.firstIndex(where: { $0.code == n.code }) ?? 0
            b.accessibilityIdentifier = n.code
            b.addTarget(self, action: #selector(natTapped(_:)), for: .touchUpInside)
            natStack.addArrangedSubview(b)
        }
    }

    private func rebuildPosFilter() {
        filterStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for f in DataStore.filters {
            let on = posFilter == f
            let col = f == "전체" ? Theme.accent : (PosCat(rawValue: f)?.color ?? Theme.accent)
            let b = UIButton(type: .system)
            b.setTitle(f, for: .normal)
            b.titleLabel?.font = f == "전체" ? .systemFont(ofSize: 13, weight: .bold) : Theme.numFont(14, weight: .bold)
            b.setTitleColor(on ? (f == "전체" ? Theme.accentInk : Theme.bg) : Theme.sub, for: .normal)
            b.backgroundColor = on ? col : Theme.card
            b.layer.cornerRadius = 9
            b.layer.borderWidth = 1
            b.layer.borderColor = (on ? col : Theme.line).cgColor
            b.accessibilityIdentifier = f
            b.addTarget(self, action: #selector(posTapped(_:)), for: .touchUpInside)
            filterStack.addArrangedSubview(b)
        }
    }

    // MARK: 테이블
    private func setupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlayerCell.self, forCellReuseIdentifier: PlayerCell.reuseID)
        tableView.rowHeight = 98
        tableView.contentInset = .init(top: 6, left: 0, bottom: 90, right: 0)
        tableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 90, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerBottom, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    // MARK: 데이터
    @objc private func reload() {
        var list = DataStore.players
        if conf != "전체" { list = list.filter { $0.conf == conf } }
        if let nat = natFilter { list = list.filter { $0.natCode == nat } }
        if posFilter != "전체" { list = list.filter { $0.cat.rawValue == posFilter } }
        let q = search.trimmingCharacters(in: .whitespaces)
        if !q.isEmpty { list = list.filter { $0.name.contains(q) || $0.teamName.contains(q) } }
        switch sort {
        case "name": list.sort { $0.name < $1.name }
        case "no":   list.sort { $0.number < $1.number }
        default:     list.sort { $0.ovr > $1.ovr }
        }
        rows = list
        countLabel.text = "\(rows.count)명"
        tableView.reloadData()
    }

    // MARK: 액션
    @objc private func searchChanged() { search = searchField.text ?? ""; reload() }
    @objc private func confChanged() { conf = DataStore.confs[confControl.selectedSegmentIndex]; natFilter = nil; rebuildNatChips(); reload() }
    @objc private func natTapped(_ b: UIButton) {
        let code = b.accessibilityIdentifier
        natFilter = (natFilter == code) ? nil : code
        rebuildNatChips(); reload()
    }
    @objc private func posTapped(_ b: UIButton) {
        posFilter = b.accessibilityIdentifier ?? "전체"
        rebuildPosFilter(); reload()
    }
    @objc private func openSort() {
        let sheet = UIAlertController(title: "정렬 기준", message: nil, preferredStyle: .actionSheet)
        let opts: [(String,String)] = [("ovr","OVR 높은순"),("name","이름순 (가나다)"),("no","등번호순")]
        for (k, lbl) in opts {
            sheet.addAction(UIAlertAction(title: lbl, style: .default) { [weak self] _ in
                self?.sort = k
                self?.sortButton.setTitle(["ovr":"OVR순","name":"이름순","no":"등번호순"][k], for: .normal)
                self?.reload()
            })
        }
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(sheet, animated: true)
    }

    /// 빈 슬롯 숏컷 등에서 특정 포지션으로 필터해 진입
    func focus(cat: PosCat) {
        posFilter = cat.rawValue; natFilter = nil; conf = "전체"
        confControl.selectedSegmentIndex = 0
        rebuildNatChips(); rebuildPosFilter(); reload()
    }
}

extension PlayersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ t: UITableView, numberOfRowsInSection s: Int) -> Int { rows.count }
    func tableView(_ t: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell = t.dequeueReusableCell(withIdentifier: PlayerCell.reuseID, for: ip) as! PlayerCell
        let p = rows[ip.row]
        cell.configure(p, picked: AppState.shared.isPicked(p.id))
        return cell
    }
    func tableView(_ t: UITableView, didSelectRowAt ip: IndexPath) {
        let vc = PlayerDetailViewController(player: rows[ip.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension PlayersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ tf: UITextField) -> Bool {
        tf.resignFirstResponder()
        return true
    }
}
