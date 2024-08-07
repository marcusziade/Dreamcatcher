import UIKit

final class DreamImageTagView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupCollectionView()
    }

    func setImages(_ images: [UIImage]) {
        for (index, image) in images.enumerated() where index < imageViews.count {
            imageViews[index].image = image
        }
    }

    func setTags(_ newTags: [String]) {
        tags = newTags
        tagCollectionView.reloadData()
    }

    // MARK: Private

    private var imageViews: [UIImageView] = []
    private var tags: [String] = []

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
        addSubview(imageStackView)
        addSubview(tagCollectionView)

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
    }

    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageStackView.topAnchor.constraint(equalTo: topAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8),

            tagCollectionView.topAnchor.constraint(equalTo: imageStackView.bottomAnchor, constant: 10),
            tagCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tagCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupCollectionView() {
        tagCollectionView.registerCell(TagCell.self)
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DreamImageTagView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return tags.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        collectionView.dequeueCell(TagCell.self, forIndexPath: indexPath)
            .configure { $0.configure(with: tags[indexPath.item]) }
    }
}
