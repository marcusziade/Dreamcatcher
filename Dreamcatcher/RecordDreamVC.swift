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

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }

    // MARK: Private

    private let gradientColors: [UIColor]
    private let settings: Settings

    private let backgroundImageView = UIImageView(image: .dreamBackgroundImage)
        .configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

    private lazy var recordButton = UIButton.createCustomButton(
        title: "Record your dream",
        foregroundColor: .black,
        backgroundColor: .white,
        textStyle: .title1,
        fontWeight: .semibold,
        contentInset: .init(top: 16, leading: .zero, bottom: 16, trailing: .zero),
        action: UIAction { [unowned self] _ in
            print("Record button tapped!")
        }
    )

    private lazy var swipeUpButton = UIButton.createCustomButton(
        title: "Swipe up to view your dreams",
        style: .borderless(),
        foregroundColor: .white,
        textStyle: .caption1,
        action: UIAction { [unowned self] _ in
            presentDreamsListVC()
        }
    )

    private func renderUI() {
        view.addSubview(backgroundImageView)
        let gradientOverlayView = GradientOverlayView()
        view.addSubview(gradientOverlayView)
        let stackView = UIStackView(arrangedSubviews: [recordButton, swipeUpButton,])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.alignment = .center
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            gradientOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 2),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 8),

            recordButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ])
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .began else { return }
        let velocity = gesture.velocity(in: view)
        if velocity.y < 0 && abs(velocity.y) > abs(velocity.x) {
            presentDreamsListVC()
        }
    }

    private func presentDreamsListVC() {
        let nc = NavigationController(root: DreamsListVC())
        present(nc, animated: true)
    }
}

extension RecordDreamVC: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: view)
            // Check if it's primarily an upward swipe
            return velocity.y < 0 && abs(velocity.y) > abs(velocity.x)
        }
        return false
    }
}

#Preview {
    RecordDreamVC(colors: [.black, .purple], settings: .init())
}
