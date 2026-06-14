import UIKit

final class FormationPickerViewController: UIViewController {
    private let current: String
    private let onPick: (String) -> Void

    init(current: String, onPick: @escaping (String) -> Void) {
        self.current = current; self.onPick = onPick
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bgRaised

        let title = UILabel()
        title.text = "포메이션 선택"
        title.font = .systemFont(ofSize: 17, weight: .bold)
        title.textColor = Theme.text
        title.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(title)

        let grid = UIStackView()
        grid.axis = .vertical; grid.spacing = 12; grid.distribution = .fillEqually
        grid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(grid)

        let forms = DataStore.formationOrder
        for rowForms in stride(from: 0, to: forms.count, by: 3).map({ Array(forms[$0..<min($0+3, forms.count)]) }) {
            let row = UIStackView(); row.axis = .horizontal; row.spacing = 12; row.distribution = .fillEqually
            for f in rowForms { row.addArrangedSubview(makeCell(f)) }
            grid.addArrangedSubview(row)
        }

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            grid.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            grid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            grid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
        ])
    }

    private func makeCell(_ f: String) -> UIView {
        let on = f == current
        let container = UIView()
        let mini = MiniPitchView(slots: DataStore.formations[f] ?? [], active: on)
        mini.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = f
        label.font = Theme.numFont(14, weight: .bold)
        label.textColor = on ? Theme.accent : Theme.sub
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(mini); container.addSubview(label)
        NSLayoutConstraint.activate([
            mini.topAnchor.constraint(equalTo: container.topAnchor),
            mini.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mini.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            mini.heightAnchor.constraint(equalTo: mini.widthAnchor, multiplier: 1.22),
            label.topAnchor.constraint(equalTo: mini.bottomAnchor, constant: 7),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        container.addGestureRecognizer(tap)
        container.accessibilityIdentifier = f
        return container
    }

    @objc private func cellTapped(_ g: UITapGestureRecognizer) {
        guard let f = g.view?.accessibilityIdentifier else { return }
        onPick(f)
        dismiss(animated: true)
    }
}

/// 포메이션 미니 다이어그램
final class MiniPitchView: UIView {
    private let slots: [Slot]
    private let active: Bool
    init(slots: [Slot], active: Bool) {
        self.slots = slots; self.active = active
        super.init(frame: .zero)
        layer.cornerRadius = 10
        layer.borderWidth = 1.5
        layer.borderColor = (active ? Theme.accent : Theme.line2).cgColor
        backgroundColor = active ? UIColor(hex: "#142B1D") : UIColor(hex: "#1B1F25")
    }
    required init?(coder: NSCoder) { fatalError() }
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        let line = (active ? Theme.accent.withAlphaComponent(0.22) : UIColor(white: 1, alpha: 0.12))
        ctx?.setStrokeColor(line.cgColor); ctx?.setLineWidth(0.8)
        ctx?.move(to: CGPoint(x: 0, y: rect.height*0.5)); ctx?.addLine(to: CGPoint(x: rect.width, y: rect.height*0.5)); ctx?.strokePath()
        let dotColor = active ? Theme.accent : UIColor(white: 1, alpha: 0.5)
        for s in slots {
            let c = s.cat == .GK ? Theme.gold : dotColor
            c.setFill()
            let r: CGFloat = rect.width * 0.045
            let x = rect.width * s.x/100, y = rect.height * (s.y*0.81/100 + 0.01)
            UIBezierPath(ovalIn: CGRect(x: x-r, y: y-r, width: r*2, height: r*2)).fill()
        }
    }
}
