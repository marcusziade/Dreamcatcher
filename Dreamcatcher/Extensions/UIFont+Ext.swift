import Foundation
import UIKit

extension UIFont {

    /// Returns a new font with the specified weight while maintaining other attributes.
    /// - Parameter weight: The desired weight for the new font.
    /// - Returns: A new UIFont instance with the specified weight.
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.traits] = traits
        let descriptor = fontDescriptor.addingAttributes(attributes)

        return UIFont(descriptor: descriptor, size: 0)
    }
}
