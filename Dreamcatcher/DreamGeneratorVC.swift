import UIKit

final class DreamGeneratorVC: ViewController {

    init(viewModel: DreamGeneratorVM) {
        self.viewModel = viewModel
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupCollectionView()
        bindViewModel()
    }

    // MARK: Private

    private let viewModel: DreamGeneratorVM

    private let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let horizontalStackView1: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()

    private let horizontalStackView2: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()

    private var imageViews: [UIImageView] = []

    private let generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generate Dream Images", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let tagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private func setupUI() {
        view.backgroundColor = .brown
        view.addSubview(imageStackView)
        view.addSubview(generateButton)
        view.addSubview(activityIndicator)
        view.addSubview(tagCollectionView)

        for _ in 0..<4 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = .lightGray
            imageView.isUserInteractionEnabled = true
            imageViews.append(imageView)
        }

        horizontalStackView1.addArrangedSubview(imageViews[0])
        horizontalStackView1.addArrangedSubview(imageViews[1])
        horizontalStackView2.addArrangedSubview(imageViews[2])
        horizontalStackView2.addArrangedSubview(imageViews[3])

        imageStackView.addArrangedSubview(horizontalStackView1)
        imageStackView.addArrangedSubview(horizontalStackView2)

        generateButton.addTarget(self, action: #selector(generateImagesAndTags), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),

            tagCollectionView.topAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: 10),
            tagCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tagCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tagCollectionView.heightAnchor.constraint(equalToConstant: 50),

            generateButton.topAnchor.constraint(equalTo: tagCollectionView.bottomAnchor, constant: 20),
            generateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupCollectionView() {
        tagCollectionView.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
    }

    private func bindViewModel() {
        Task {
            for await state in viewModel.stateStream {
                updateUI(with: state)
            }
        }
    }

    private func updateUI(with state: DreamGeneratorState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
            generateButton.isEnabled = true
        case .loading:
            activityIndicator.startAnimating()
            generateButton.isEnabled = false
        case .tagsLoaded(_):
            tagCollectionView.reloadData()
        case .imageLoaded(let index, let image):
            imageViews[index].image = image
        case .error(let error):
            showAlert(message: error.localizedDescription)
        case .completed:
            activityIndicator.stopAnimating()
            generateButton.isEnabled = true
        }
    }

    @objc private func generateImagesAndTags() {
        Task {
            await viewModel.generateImagesAndTags()
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension DreamGeneratorVC: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.configure(with: viewModel.tags[indexPath.item])
        return cell
    }
}
