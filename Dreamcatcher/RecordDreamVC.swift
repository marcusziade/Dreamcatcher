import UIKit

final class RecordDreamVC: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let stackView = UIStackView(arrangedSubviews: [recordButton, swipeUpLabel,])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 69
        stackView.alignment = .center
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 2),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 2),
        ])
    }

    // MARK: Private

    private var recordButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Record your dream"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemPurple
        let vPadding: CGFloat = 16
        let hPadding: CGFloat = 32
        config.contentInsets = .init(
            top: vPadding,
            leading: hPadding,
            bottom: vPadding,
            trailing: hPadding
        )

        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()

    private var swipeUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Swipe up to view your dreams"
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
}

#Preview {
    RecordDreamVC()
}
