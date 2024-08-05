import UIKit

final class NavigationController: UINavigationController {

    init(root: ViewController) {
        super.init(rootViewController: root)
    }

    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    override func viewDidLoad() {
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.prefersLargeTitles = true
        navigationBar.tintColor = .white
        navigationBar.barTintColor = .purple
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.largeTitleTextAttributes = [ .foregroundColor: UIColor.white]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
