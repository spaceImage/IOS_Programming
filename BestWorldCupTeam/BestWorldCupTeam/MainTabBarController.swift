import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let home = nav(HomeViewController(), "홈", "house.fill")
        let players = nav(PlayersViewController(), "선수", "person.2.fill")
        let team = nav(DreamTeamViewController(), "드림팀", "sportscourt.fill")
        let done = nav(CompleteViewController(), "완성", "trophy.fill")
        viewControllers = [home, players, team, done]

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(white: 0.055, alpha: 0.92)
        appearance.stackedLayoutAppearance.selected.iconColor = Theme.accent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: Theme.accent]
        appearance.stackedLayoutAppearance.normal.iconColor = Theme.faint
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: Theme.faint]
        tabBar.standardAppearance = appearance

        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: .dreamTeamChanged, object: nil)
        updateBadge()
    }

    @objc private func updateBadge() {
        let c = AppState.shared.count
        viewControllers?[3].tabBarItem.badgeValue = c > 0 ? "\(c)" : nil
        viewControllers?[3].tabBarItem.badgeColor = Theme.accent
    }

    private func nav(_ vc: UIViewController, _ title: String, _ icon: String) -> UINavigationController {
        let n = UINavigationController(rootViewController: vc)
        n.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), selectedImage: UIImage(systemName: icon))
        let a = UINavigationBarAppearance()
        a.configureWithOpaqueBackground()
        a.backgroundColor = Theme.bg
        a.titleTextAttributes = [.foregroundColor: Theme.text]
        a.largeTitleTextAttributes = [.foregroundColor: Theme.text]
        n.navigationBar.standardAppearance = a
        n.navigationBar.scrollEdgeAppearance = a
        n.navigationBar.tintColor = Theme.accent
        return n
    }
}
