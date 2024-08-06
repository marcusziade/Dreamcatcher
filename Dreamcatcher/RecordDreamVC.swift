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
    static private let transitionSpeed: CGFloat = 0.2

    private let backgroundImageView = UIImageView(image: .dreamBackgroundImage)
        .configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

    private lazy var dreamTextView = UITextView()
        .configure {
            let backgroundColor = UIColor(red: 0.99, green: 0.96, blue: 0.89, alpha: 1.0)
            let textColor = UIColor(red: 0.40, green: 0.48, blue: 0.51, alpha: 1.0)
            $0.backgroundColor = backgroundColor
            $0.textColor = textColor
            $0.font = UIFont.preferredFont(forTextStyle: .body).withSize(18)
            let textPadding: CGFloat = 12
            $0.textContainerInset = .init(
                top: textPadding,
                left: textPadding,
                bottom: textPadding,
                right: textPadding
            )

            $0.alpha = .zero
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true

            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.delegate = self

            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let buttons: [UIBarButtonItem] = [
                .init(systemItem: .redo, primaryAction: UIAction { [unowned self] _ in
                    clearTextView()
                }),
                .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                .init(systemItem: .done, primaryAction: UIAction { [unowned self] _ in
                    endEditing()
                })
            ]
            toolbar.setItems(buttons, animated: true)
            $0.inputAccessoryView = toolbar

            $0.autocorrectionType = .no
            $0.returnKeyType = .default
            $0.enablesReturnKeyAutomatically = true

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            $0.typingAttributes = [
                .paragraphStyle: paragraphStyle,
                .font: $0.font!,
                .foregroundColor: textColor
            ]

            setupTextViewContent($0)
        }

    private func clearTextView() {
        let alert = UIAlertController(
            title: "Clear Text",
            message: "Are you sure you want to clear the text?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Clear", style: .destructive) { [unowned self] _ in
            setupTextViewContent(dreamTextView)
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }

    private lazy var recordButton = UIButton.createCustomButton(
        title: "Record your dream",
        foregroundColor: .black,
        backgroundColor: .white,
        textStyle: .title1,
        fontWeight: .semibold,
        contentInset: .init(top: 16, leading: .zero, bottom: 16, trailing: .zero),
        action: UIAction { [unowned self] _ in
            Task { @MainActor in
                UIView.animate(withDuration: Self.transitionSpeed) {
                    self.dreamTextView.alpha = 1
                } completion: { _ in
                    self.dreamTextView.becomeFirstResponder()
                }
            }
        }
    )

    private lazy var swipeUpButton = UIButton.createCustomButton(
        title: "Swipe up to view your dreams",
        style: .borderless(),
        foregroundColor: .white,
        textStyle: .caption1,
        action: UIAction { [unowned self] _ in
            if !dreamTextView.isFirstResponder {
                presentDreamsListVC()
            }
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
        view.addSubview(dreamTextView)
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

            dreamTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dreamTextView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            dreamTextView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            dreamTextView.bottomAnchor.constraint(equalTo: recordButton.bottomAnchor),
        ])
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .began else { return }
        let velocity = gesture.velocity(in: view)
        if velocity.y < 0 && abs(velocity.y) > abs(velocity.x) {
            if !dreamTextView.isFirstResponder {
                presentDreamsListVC()
            }
        }
    }

    private func endEditing() {
        view.endEditing(true)

        Task { @MainActor in
            UIView.animate(withDuration: Self.transitionSpeed) { [self] in
                dreamTextView.alpha = .zero
            }
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

extension RecordDreamVC: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard let attributedText = textView.attributedText else { return true }

        let proposedText = (attributedText.string as NSString).replacingCharacters(
            in: range,
            with: text
        )
        let instructions = [
            "Describe the setting:",
            "Describe the main character:",
            "Describe the plot:",
            "Describe the ending:"
        ]

        // Check if the proposed change would modify any instruction
        for instruction in instructions {
            if !proposedText.contains(instruction) {
                return false
            }
        }

        return true
    }

    private func setupTextViewContent(_ textView: UITextView) {
        let attributedString = NSMutableAttributedString()

        let instructions = [
            "Describe the setting:\n",
            "Describe the main character:\n",
            "Describe the plot:\n",
            "Describe the ending:\n"
        ]

        for (index, instruction) in instructions.enumerated() {
            let instructionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.gray
            ]
            attributedString.append(NSAttributedString(string: instruction, attributes: instructionAttributes))

            // Add editable placeholder if it's not the last instruction
            if index < instructions.count - 1 {
                attributedString.append(
                    NSAttributedString(
                        string: "\n\n",
                        attributes: [.font: UIFont.systemFont(ofSize: 16)]
                    )
                )
            }
        }

        textView.attributedText = attributedString
    }
}

#Preview {
    RecordDreamVC(colors: [.black, .purple], settings: .init())
}
