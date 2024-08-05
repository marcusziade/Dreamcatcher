import UIKit

final class DreamsListVC: UIViewController {

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
    
    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Section, Dream>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureDataSource()
        applyInitialSnapshot()
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.backgroundColor = .clear
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        tableView.registerCell(UITableViewCell.self)
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Dream>(tableView: tableView) { (tableView, indexPath, dream) -> UITableViewCell? in
            let cell = tableView.dequeueCell(UITableViewCell.self, forIndexPath: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = dream.title
            content.secondaryText = DateFormatter.localizedString(from: dream.date, dateStyle: .medium, timeStyle: .short)
            cell.contentConfiguration = content
            return cell
        }
    }
    
    private func applyInitialSnapshot() {
        let dreams = [
            Dream(title: "Flying over mountains", date: Date().addingTimeInterval(-86400)),
            Dream(title: "Underwater city", date: Date().addingTimeInterval(-172800)),
            Dream(title: "Time travel adventure", date: Date().addingTimeInterval(-259200))
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