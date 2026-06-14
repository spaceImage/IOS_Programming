import UIKit

final class HelpViewController: UIViewController {

    // (아이콘, 제목, 본문)
    private let tips: [(String, String, String)] = [
        ("square.grid.3x3.fill", "포메이션부터 정하기",
         "공격적으로 가려면 4-3-3·3-4-3, 안정적으로 가려면 4-4-2·5-3-2가 좋아요. 우측 상단 포메이션 버튼에서 12종 중 선택할 수 있어요."),
        ("star.fill", "등급(S/A/B/C/D)을 활용",
         "선수 카드의 색 배지가 OVR 등급이에요. S(90+, 골드)·A(80~89, 실버)·B(70~79, 브론즈)·C(60~69, 그레이)·D(59↓, 다크그레이) 순서로, 핵심 포지션엔 S·A 등급을 우선 배치하세요."),
        ("arrow.left.arrow.right", "드래그로 자리 바꾸기",
         "피치에서 선수를 길게 눌러 다른 자리로 끌면 두 선수의 위치가 바뀌어요. 같은 계열 포지션끼리 배치하면 밸런스가 좋아져요."),
        ("globe.asia.australia.fill", "국가·클럽 조합 보기",
         "선수 목록에서 국가와 소속 클럽을 함께 볼 수 있어요. 같은 리그·클럽 선수를 모으면 손발이 맞는 팀 느낌을 줄 수 있어요."),
        ("shield.lefthalf.filled", "수비-미드-공격 균형",
         "GK 1명은 필수, 수비 3~5명, 미드필더 3~5명, 공격수 1~3명으로 11명을 채우면 빈 자리 없이 완성돼요. 한 쪽에만 S등급을 몰지 말고 고르게 분배하세요."),
        ("checkmark.seal.fill", "완성 후 저장",
         "11명을 모두 채우면 완성 탭에서 최종 라인업을 저장할 수 있어요. 언제든 다시 수정할 수 있으니 여러 조합을 시도해보세요."),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.bg
        title = "팀 구성 도움말"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        // 안내 헤더
        let intro = UILabel()
        intro.text = "나만의 베스트 11을 만드는 팁이에요. 천천히 따라 해보세요!"
        intro.font = .systemFont(ofSize: 14)
        intro.textColor = Theme.sub
        intro.numberOfLines = 0
        stack.addArrangedSubview(intro)

        for (icon, head, body) in tips {
            stack.addArrangedSubview(card(icon: icon, head: head, body: body))
        }

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -22),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -44),
        ])
    }

    private func card(icon: String, head: String, body: String) -> UIView {
        let v = UIView()
        v.backgroundColor = Theme.card
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = Theme.line.cgColor

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = Theme.accent
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let headLabel = UILabel()
        headLabel.text = head
        headLabel.font = .systemFont(ofSize: 16, weight: .bold)
        headLabel.textColor = Theme.text
        headLabel.numberOfLines = 0

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 13.5)
        bodyLabel.textColor = Theme.sub
        bodyLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [headLabel, bodyLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        v.addSubview(iconView)
        v.addSubview(textStack)
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: v.topAnchor, constant: 18),
            iconView.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            textStack.topAnchor.constraint(equalTo: v.topAnchor, constant: 16),
            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -16),
        ])
        return v
    }

    @objc private func close() { dismiss(animated: true) }
}
