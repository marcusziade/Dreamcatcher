import UIKit

final class MainVC: ViewController {

    enum Section {
        case main
    }

    init(colors: [UIColor], settings: Settings) {
        self.gradientColors = colors
        self.settings = settings
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        renderBackground()
        view.addSubview(collectionView)

        let items = [recordDreamVC, dreamsListVC]
        diffableDataSource.apply(Self.snapshot(for: items), animatingDifferences: false)
        scrollToBottom(animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // This code fullscreens the collectionview for a more pleasing UI.
        let safeArea = view.safeAreaInsets
        collectionView.frame = CGRect(
            x: safeArea.left,
            y: safeArea.top,
            width: view.bounds.width - safeArea.left - safeArea.right,
            height: view.bounds.height - safeArea.top - safeArea.bottom
        )
    }

    // MARK: Private

    private let gradientColors: [UIColor]
    private let settings: Settings

    private lazy var diffableDataSource: UICollectionViewDiffableDataSource<
        Section,
        UIViewController
    > = .init(collectionView: collectionView) { collectionView, indexPath, item in
        collectionView.dequeueCell(PageCell.self, forIndexPath: indexPath)
            .configure { $0.configure(with: item) }
    }

    private let recordDreamVC = RecordDreamVC()
    private let dreamsListVC = DreamsListVC()

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: Self.createLayout()
    ).configure {
        $0.backgroundColor = .clear
        $0.registerCell(PageCell.self)
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
    }

    private func renderBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: .zero)
    }

    private func scrollToBottom(animated: Bool) {
        guard collectionView.numberOfSections > 0 else { return }
        let lastSection = collectionView.numberOfSections - 1
        let lastItemIndex = collectionView.numberOfItems(inSection: lastSection) - 1
        guard lastItemIndex >= 0 else { return }
        let indexPath = IndexPath(item: lastItemIndex, section: lastSection)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
    }

    static private func snapshot(
        for items: [UIViewController]
    ) -> NSDiffableDataSourceSnapshot<MainVC.Section, UIViewController> {
        var snapshot = NSDiffableDataSourceSnapshot<MainVC.Section, UIViewController>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        return snapshot
    }

    static func createLayout() -> UICollectionViewLayout {
        let size = 1.0
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(size),
            heightDimension: .fractionalHeight(size)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(size),
            heightDimension: .fractionalHeight(size)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        return layout
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    let s = Settings()
    return MainVC(colors: [.black, .purple], settings: s)
}
