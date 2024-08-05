import UIKit

final class RecordDreamVC: ViewController {

    init(colors: [UIColor], settings: Settings) {
        self.gradientColors = colors
        self.settings = settings
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        renderUI()
    }

    // MARK: Private

    private let gradientColors: [UIColor]
    private let settings: Settings

    private var recordButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Record your dream"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemPurple
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var swipeUpButton: UIButton = {
        var config = UIButton.Configuration.borderless()
        config.title = "Swipe up to view your dreams"
        config.baseForegroundColor = .white
        let button = UIButton(configuration: config)
        button.addAction(
            UIAction { [unowned self] _ in
                let nc = NavigationController(root: DreamsListVC())
                present(nc, animated: true)
            },
            for: .touchUpInside
        )
        return button
    }()

    private func renderUI() {
        let stackView = UIStackView(arrangedSubviews: [recordButton, swipeUpButton,])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 69
        stackView.alignment = .center
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 2),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 2),

            recordButton.heightAnchor.constraint(equalToConstant: 60),
            recordButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ])
    }
}

#Preview {
    RecordDreamVC(colors: [.black, .purple], settings: .init())
}
