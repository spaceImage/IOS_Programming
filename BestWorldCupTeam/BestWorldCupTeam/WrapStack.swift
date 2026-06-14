import UIKit

final class WrapStack: UIView {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 6
    private var items: [UIView] = []

    func addArrangedSubview(_ v: UIView) {
        v.translatesAutoresizingMaskIntoConstraints = false
        items.append(v)
        addSubview(v)
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maxW = bounds.width
        var x: CGFloat = 0, y: CGFloat = 0, lineH: CGFloat = 0
        for v in items {
            let size = v.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if x + size.width > maxW, x > 0 {
                x = 0; y += lineH + lineSpacing; lineH = 0
            }
            v.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            x += size.width + spacing
            lineH = max(lineH, size.height)
        }
        lastHeight = y + lineH
        if abs(lastHeight - intrinsicHeight) > 0.5 { invalidateIntrinsicContentSize() }
    }

    private var lastHeight: CGFloat = 0
    private var intrinsicHeight: CGFloat = 0

    override var intrinsicContentSize: CGSize {
        intrinsicHeight = lastHeight
        return CGSize(width: UIView.noIntrinsicMetric, height: max(lastHeight, 26))
    }
}
