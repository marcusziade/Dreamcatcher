import UIKit

final class PageCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
    }

    func configure(with viewController: UIViewController) {
        if let previousViewController = hostedViewController {
            previousViewController.willMove(toParent: nil)
            previousViewController.view.removeFromSuperview()
            previousViewController.removeFromParent()
        }

        contentView.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        viewController.didMove(toParent: nil)

        hostedViewController = viewController
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let hostedViewController = hostedViewController {
            hostedViewController.willMove(toParent: nil)
            hostedViewController.view.removeFromSuperview()
            hostedViewController.removeFromParent()
            self.hostedViewController = nil
        }
    }

    // MARK: Private

    private var hostedViewController: UIViewController?

    required init?(coder: NSCoder) { super.init(coder: coder) }
}

#Preview {
    let cell = PageCell()
    cell.configure(with: RecordDreamVC())
    return cell
}
