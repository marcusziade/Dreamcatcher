import UIKit

extension UITableView {
    
    final func registerCell<T: UITableViewCell>(_ cell: T.Type) {
        register(cell, forCellReuseIdentifier: NSStringFromClass(cell))
    }
    
    final func registerHeaderFooterView<T: UITableViewHeaderFooterView>(_ view: T.Type) {
        register(view, forHeaderFooterViewReuseIdentifier: NSStringFromClass(view))
    }
    
    final func dequeueCell<T: UITableViewCell>(_ cell: T.Type, forIndexPath indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: NSStringFromClass(cell), for: indexPath) as! T
    }
    
    final func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>(_ view: T.Type) -> T {
        dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(view)) as! T
    }
}

extension UITableView {
    
    enum SupplementaryViewKind: String {
        case sectionHeader
        case sectionFooter
        case custom
    }
    
    final func registerSupplementaryView<T: UIView>(_ view: T.Type, kind: SupplementaryViewKind) {
        let identifier = "\(NSStringFromClass(view))_\(kind.rawValue)"
        register(view, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    final func dequeueSupplementaryView<T: UIView>(_ view: T.Type, kind: SupplementaryViewKind) -> T {
        let identifier = "\(NSStringFromClass(view))_\(kind.rawValue)"
        return dequeueReusableHeaderFooterView(withIdentifier: identifier) as! T
    }
}
