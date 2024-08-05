import Foundation
import UIKit

extension UIView {

    /// Convenience interface for adding views to a view.
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { addSubview($0) }
    }

    /// Shorthand for `translatesAutoresizingMaskIntoConstraints = false`.
    func forAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    /// Fades a view in linearly with a given duration.
    func fadeIn(duration: TimeInterval) {
        UIViewPropertyAnimator(duration: duration, curve: .linear) {
            alpha = 1
        }
        .startAnimation()
    }

    /// Fades a view out linearly with a given duration.
    func fadeOut(duration: TimeInterval) {
        UIViewPropertyAnimator(duration: duration, curve: .linear) {
            alpha = .zero
        }
        .startAnimation()
    }
}
