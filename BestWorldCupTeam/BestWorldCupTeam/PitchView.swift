import UIKit

protocol PitchViewDelegate: AnyObject {
    func pitch(_ pitch: PitchView, didTapPlayer id: String)
    func pitch(_ pitch: PitchView, didTapEmpty slot: Slot)
    func pitch(_ pitch: PitchView, didSwap from: String, to: String)
}

final class PitchView: UIView {
    weak var delegate: PitchViewDelegate?
    private var slots: [Slot] = []
    private var slotViews: [String: UIView] = [:]
    private let markings = CAShapeLayer()
    private let stripes = CALayer()

    // 드래그 상태
    private var dragChip: PlayerChipView?
    private var dragSlotID: String?
    private var ghost: PlayerChipView?
    private var highlight: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = Theme.line.cgColor
        backgroundColor = UIColor(hex: "#11221A")
        stripes.backgroundColor = UIColor.clear.cgColor
        layer.addSublayer(stripes)
        markings.strokeColor = UIColor(white: 1, alpha: 0.16).cgColor
        markings.fillColor = UIColor.clear.cgColor
        markings.lineWidth = 1
        layer.addSublayer(markings)

        let g = CAGradientLayer()
        g.colors = [UIColor(hex: "#14271A").cgColor, UIColor(hex: "#0F2014").cgColor]
        g.startPoint = CGPoint(x: 0, y: 0); g.endPoint = CGPoint(x: 1, y: 1)
        g.frame = bounds
        layer.insertSublayer(g, at: 0)
        self.bgGradient = g
    }
    required init?(coder: NSCoder) { fatalError() }
    private var bgGradient: CAGradientLayer?

    func configure(slots: [Slot]) {
        self.slots = slots
        rebuild()
    }

    private func rebuild() {
        slotViews.values.forEach { $0.removeFromSuperview() }
        slotViews.removeAll()
        for slot in slots {
            let v: UIView
            if let p = AppState.shared.player(inSlot: slot.id) {
                let chip = PlayerChipView(player: p)
                let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                chip.addGestureRecognizer(pan)
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                chip.addGestureRecognizer(tap)
                chip.slotID = slot.id
                v = chip
            } else {
                let empty = EmptySlotView(slot: slot)
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleEmptyTap(_:)))
                empty.addGestureRecognizer(tap)
                empty.slotID = slot.id
                v = empty
            }
            addSubview(v)
            slotViews[slot.id] = v
        }
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgGradient?.frame = bounds
        stripes.frame = bounds
        drawMarkings()
        drawStripes()
        for slot in slots {
            guard let v = slotViews[slot.id] else { continue }
            v.sizeToFit()
            let size = v.intrinsicContentSize
            v.bounds = CGRect(origin: .zero, size: size)
            v.center = CGPoint(x: bounds.width * slot.x / 100, y: bounds.height * slot.y / 100)
        }
    }

    private func drawMarkings() {
        let w = bounds.width, h = bounds.height
        func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: w*x/100, y: h*y/100) }
        let path = UIBezierPath()
        path.append(UIBezierPath(roundedRect: CGRect(x: w*0.03, y: h*0.02, width: w*0.94, height: h*0.96), cornerRadius: 2))
        path.move(to: P(3,50)); path.addLine(to: P(97,50))
        path.append(UIBezierPath(arcCenter: P(50,50), radius: w*0.16, startAngle: 0, endAngle: .pi*2, clockwise: true))
        path.append(UIBezierPath(rect: CGRect(x: w*0.26, y: h*0.02, width: w*0.48, height: h*0.14)))
        path.append(UIBezierPath(rect: CGRect(x: w*0.26, y: h*0.84, width: w*0.48, height: h*0.14)))
        markings.path = path.cgPath
    }
    private func drawStripes() {
        stripes.sublayers?.forEach { $0.removeFromSuperlayer() }
        let n = 6
        for i in 0..<n where i % 2 == 0 {
            let s = CALayer()
            s.frame = CGRect(x: 0, y: bounds.height * CGFloat(i)/CGFloat(n), width: bounds.width, height: bounds.height/CGFloat(n))
            s.backgroundColor = UIColor(white: 1, alpha: 0.022).cgColor
            stripes.addSublayer(s)
        }
    }

    // MARK: 탭
    @objc private func handleTap(_ g: UITapGestureRecognizer) {
        guard let chip = g.view as? PlayerChipView, let id = chip.player?.id else { return }
        delegate?.pitch(self, didTapPlayer: id)
    }
    @objc private func handleEmptyTap(_ g: UITapGestureRecognizer) {
        guard let v = g.view as? EmptySlotView, let slot = v.slot else { return }
        delegate?.pitch(self, didTapEmpty: slot)
    }

    // MARK: 드래그 교체
    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        guard let chip = g.view as? PlayerChipView, let slotID = chip.slotID else { return }
        let loc = g.location(in: self)
        switch g.state {
        case .began:
            dragChip = chip; dragSlotID = slotID
            chip.alpha = 0.25
            let ghost = PlayerChipView(player: chip.player!)
            ghost.isUserInteractionEnabled = false
            ghost.bounds = CGRect(origin: .zero, size: ghost.intrinsicContentSize)
            ghost.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            ghost.center = loc
            addSubview(ghost); self.ghost = ghost
        case .changed:
            ghost?.center = loc
            updateHighlight(nearest: nearestSlot(to: loc))
        case .ended, .cancelled:
            let target = nearestSlot(to: loc)
            chip.alpha = 1
            ghost?.removeFromSuperview(); ghost = nil
            removeHighlight()
            if let target = target, target != slotID {
                delegate?.pitch(self, didSwap: slotID, to: target)
            }
            dragChip = nil; dragSlotID = nil
        default: break
        }
    }

    private func nearestSlot(to point: CGPoint) -> String? {
        var best: String? = nil; var bestD: CGFloat = 46
        for slot in slots {
            let c = CGPoint(x: bounds.width*slot.x/100, y: bounds.height*slot.y/100)
            let d = hypot(point.x - c.x, point.y - c.y)
            if d < bestD { bestD = d; best = slot.id }
        }
        return best
    }
    private func updateHighlight(nearest: String?) {
        removeHighlight()
        guard let id = nearest, id != dragSlotID, let slot = slots.first(where: { $0.id == id }) else { return }
        let ring = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        ring.center = CGPoint(x: bounds.width*slot.x/100, y: bounds.height*slot.y/100 - 4)
        ring.layer.cornerRadius = 25
        ring.backgroundColor = Theme.accent.withAlphaComponent(0.2)
        ring.layer.borderWidth = 2
        ring.layer.borderColor = Theme.accent.cgColor
        ring.isUserInteractionEnabled = false
        insertSubview(ring, at: 1)
        highlight = ring
    }
    private func removeHighlight() { highlight?.removeFromSuperview(); highlight = nil }
}
