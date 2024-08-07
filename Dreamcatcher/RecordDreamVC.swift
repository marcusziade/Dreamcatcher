import UIKit
import Combine

final class RecordDreamVC: ViewController {

    init(model: RecordDreamVM) {
        self.viewModel = model
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        renderUI()
        setupBindings()
        setAccessibility()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }

    // MARK: Private

    private let viewModel: RecordDreamVM
    private var cancellables = Set<AnyCancellable>()

    static private let transitionSpeed: CGFloat = 0.2
    static private let instruction = "Describe your dream"

    private let backgroundImageView = UIImageView(image: .dreamBackgroundImage)
        .configure {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.accessibilityLabel = "App background image view"
            $0.isAccessibilityElement = true
            $0.accessibilityTraits = .image
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

            $0.inputAccessoryView = createToolBarView()

            $0.autocorrectionType = .yes
            $0.returnKeyType = .default
            $0.enablesReturnKeyAutomatically = true

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            $0.typingAttributes = [
                .paragraphStyle: paragraphStyle,
                .font: $0.font!,
                .foregroundColor: textColor
            ]

            $0.accessibilityLabel = "Dream description"
            $0.accessibilityHint = "Enter your dream description here"
        }

    private func clearTextView() {
        let alert = UIAlertController(
            title: "Clear Text",
            message: "Are you sure you want to clear the text?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Clear", style: .destructive) { [unowned self] _ in
            viewModel.clearText()
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }

    private lazy var submitButton = UIButton.createCustomButton(
        title: "Submit dream",
        textStyle: .title1,
        fontWeight: .semibold,
        contentInset: .init(top: 16, leading: .zero, bottom: 16, trailing: .zero),
        accessibilityLabel: "Submit dream",
        accessibilityHint: "Tap to submit the dream for analyzis",
        action: UIAction { [unowned self] _ in
            UIImpactFeedbackGenerator(style: .soft, view: view).impactOccurred()
            viewModel.onSubmitTapped.send()
            // start ml processing
        }
    ).configure {
        $0.isHidden = true
    }

    private lazy var editButton = UIButton.createCustomButton(
        title: viewModel.state.value.editButtonTitle,
        foregroundColor: .black,
        backgroundColor: .white,
        textStyle: .title1,
        fontWeight: .semibold,
        contentInset: .init(top: 16, leading: .zero, bottom: 16, trailing: .zero),
        accessibilityLabel: viewModel.state.value.editButtonTitle,
        accessibilityHint: "Tap to start recording your dream",
        action: UIAction { [unowned self] _ in
            UIImpactFeedbackGenerator(style: .soft, view: view).impactOccurred()
            viewModel.onEditButtonTapped.send()
        }
    )

    private lazy var swipeUpButton = UIButton.createCustomButton(
        title: "Swipe up to view your dreams",
        style: .borderless(),
        foregroundColor: .white,
        textStyle: .caption1,
        accessibilityLabel: "View your dreams",
        accessibilityHint: "Double tap to view your recorded dreams",
        animateOnPress: false,
        action: UIAction { [unowned self] _ in
            if viewModel.state.value != .editing {
                presentDreamsListVC()
            }
        }
    )

    private func renderUI() {
        view.addSubview(backgroundImageView)
        let gradientOverlayView = GradientOverlayView()
        view.addSubview(gradientOverlayView)

        let stackView = UIStackView(arrangedSubviews: [submitButton, editButton, swipeUpButton,])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.setCustomSpacing(8, after: submitButton)
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

            submitButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            editButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),

            dreamTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dreamTextView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            dreamTextView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            dreamTextView.bottomAnchor.constraint(equalTo: editButton.bottomAnchor),
        ])
    }

    private func createToolBarView() -> UIView {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let instructionLabel = UILabel()
        instructionLabel.text = Self.instruction
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        instructionLabel.sizeToFit()
        instructionLabel.accessibilityLabel = "Instruction"
        instructionLabel.accessibilityTraits = .header

        let buttons: [UIBarButtonItem] = [
            .init(systemItem: .redo, primaryAction: UIAction { [unowned self] _ in
                clearTextView()
            }),
            .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            .init(customView: instructionLabel),
            .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            .init(systemItem: .done, primaryAction: UIAction { [unowned self] _ in
                view.endEditing(true)
                viewModel.onDoneEditing.send()
            })
        ]
        toolbar.setItems(buttons, animated: true)

        return toolbar
    }

    private func setupBindings() {
        viewModel.state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                updateButtons(forState: state)
                updateTextViewVisibility(forState: state)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(
                for: UITextView.textDidChangeNotification,
                object: dreamTextView
            )
            .compactMap { ($0.object as? UITextView)?.text }
            .assign(to: \.value, on: viewModel.dreamText)
            .store(in: &cancellables)

        viewModel.dreamText
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: dreamTextView)
            .store(in: &cancellables)
    }

    private func updateTextViewVisibility(forState state: RecordDreamVM.State) {
        Task { @MainActor in
            UIView.animate(withDuration: Self.transitionSpeed) {
                self.dreamTextView.alpha = state == .editing ? 1 : 0
            } completion: { _ in
                if state == .editing {
                    self.dreamTextView.becomeFirstResponder()
                    UIAccessibility.post(notification: .screenChanged, argument: self.dreamTextView)
                } else {
                    self.dreamTextView.resignFirstResponder()
                    UIAccessibility.post(notification: .screenChanged, argument: self.editButton)
                }
            }
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .began else { return }
        let velocity = gesture.velocity(in: view)
        if velocity.y < 0 && abs(velocity.y) > abs(velocity.x) {
            if viewModel.state.value != .editing {
                presentDreamsListVC()
            }
        }
    }

    private func presentDreamsListVC() {
        let nc = NavigationController(root: DreamsListVC())
        present(nc, animated: true)
    }

    private func updateButtons(forState state: RecordDreamVM.State) {
        submitButton.isHidden = state != .readyToSubmit
        editButton.isHidden = [.result, .error].contains(state)
        editButton.configuration?.title = state.editButtonTitle
        editButton.isUserInteractionEnabled = state != .analyzing
        setAccessibility()
    }

    private func setAccessibility() {
        submitButton.accessibilityLabel = "Submit dream"
        submitButton.accessibilityHint = "Tap to submit the dream for analyzis"
        submitButton.accessibilityTraits = .button

        editButton.accessibilityLabel = viewModel.state.value.editButtonTitle
        editButton.accessibilityHint = viewModel.state.value.editButtonTitle
        editButton.accessibilityTraits = .button

        swipeUpButton.accessibilityLabel = "View your dreams"
        swipeUpButton.accessibilityHint = "Double tap to view your recorded dreams"
        swipeUpButton.accessibilityTraits = .button

        view.accessibilityElements = [submitButton, editButton, swipeUpButton, dreamTextView]
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
    RecordDreamVC(model: .init(settings: .init()))
}
