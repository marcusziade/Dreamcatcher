import Foundation
import UIKit

extension UIButton {
    /// Creates a custom UIButton with specified parameters, accessibility support, and an optional action.
    /// - Parameters:
    ///   - title: The title text for the button.
    ///   - style: The button configuration style. Default is `.filled`.
    ///   - foregroundColor: The color of the button's title. Default is `.white`.
    ///   - backgroundColor: The background color of the button. Default is `.systemPurple`.
    ///   - textStyle: The text style for dynamic type. Default is `.headline`.
    ///   - fontWeight: The weight of the font. Default is `.regular`.
    ///   - contentInset: The content insets for the button. Default is `.zero`.
    ///   - accessibilityLabel: The accessibility label for the button. If nil, the title will be used.
    ///   - accessibilityHint: The accessibility hint for the button. Default is nil.
    ///   - action: An optional UIAction to be performed when the button is tapped. Default is `nil`.
    /// - Returns: A configured UIButton instance with the specified parameters, accessibility support, and action.
    static func createCustomButton(
        title: String,
        style: UIButton.Configuration = UIButton.Configuration.filled(),
        foregroundColor: UIColor = .white,
        backgroundColor: UIColor = .systemPurple,
        textStyle: UIFont.TextStyle = .headline,
        fontWeight: UIFont.Weight = .regular,
        contentInset: NSDirectionalEdgeInsets = .zero,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: UIAction? = nil
    ) -> UIButton {
        var config = style
        config.baseForegroundColor = foregroundColor
        config.baseBackgroundColor = backgroundColor
        config.contentInsets = contentInset

        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            let font = UIFont.preferredFont(forTextStyle: textStyle)
            outgoing.font = font.withWeight(fontWeight)
            return outgoing
        }

        config.title = title

        let button = UIButton(configuration: config)
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        // Set accessibility properties
        button.accessibilityLabel = accessibilityLabel ?? title
        button.accessibilityHint = accessibilityHint
        button.accessibilityTraits = .button

        if let action {
            button.addAction(action, for: .touchUpInside)
        }

        return button
    }
}
