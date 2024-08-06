import UIKit

final class DreamsListVC: ViewController {

    enum Section: Hashable {
        case main
    }
    
    struct Dream: Hashable {
        let id = UUID()
        let title: String
        let date: Date
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: Dream, rhs: Dream) -> Bool {
            return lhs.id == rhs.id
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dreams"
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close)
        view.addSubview(tableView)
        applyInitialSnapshot()
    }

    // MARK: Private

    private lazy var dataSource: UITableViewDiffableDataSource<
        Section,
        Dream
    > = .init(tableView: tableView) { tableView, indexPath, dream in
        let cell = tableView.dequeueCell(UITableViewCell.self, forIndexPath: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = dream.title
        content.textProperties.color = .white
        content.secondaryText = DateFormatter.localizedString(
            from: dream.date,
            dateStyle: .medium,
            timeStyle: .short
        )
        content.secondaryTextProperties.color = .white
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        return cell
    }

    private lazy var tableView = UITableView(frame: view.bounds, style: .plain)
        .configure {
            $0.backgroundColor = .clear
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.registerCell(UITableViewCell.self)
        }

    private func applyInitialSnapshot() {
        let dreams = [
            Dream(title: "Flying over mountains", date: Date().addingTimeInterval(-86400)),
            Dream(title: "Underwater city", date: Date().addingTimeInterval(-172800)),
            Dream(title: "Time travel adventure", date: Date().addingTimeInterval(-259200)),
            Dream(title: "Flying over mountains", date: Date().addingTimeInterval(-86400)),
            Dream(title: "Underwater city", date: Date().addingTimeInterval(-172800)),
            Dream(title: "Time travel adventure", date: Date().addingTimeInterval(-259200)),
            Dream(title: "Flying over mountains", date: Date().addingTimeInterval(-86400)),
            Dream(title: "Underwater city", date: Date().addingTimeInterval(-172800)),
            Dream(title: "Time travel adventure", date: Date().addingTimeInterval(-259200)),
            Dream(title: "Flying over mountains", date: Date().addingTimeInterval(-86400)),
            Dream(title: "Underwater city", date: Date().addingTimeInterval(-172800)),
            Dream(title: "Time travel adventure", date: Date().addingTimeInterval(-259200)),
            Dream(title: "Flying over mountains", date: Date().addingTimeInterval(-86400)),
            Dream(title: "Underwater city", date: Date().addingTimeInterval(-172800)),
            Dream(title: "Time travel adventure", date: Date().addingTimeInterval(-259200)),

        ]
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Dream>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dreams)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

#Preview {
    DreamsListVC()
}
