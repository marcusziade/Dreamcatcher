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
    ///   - cornerRadius: The corner radius of the button. If nil, corners won't be rounded. Default is `nil`.
    ///   - action: An optional UIAction to be performed when the button is tapped. Default is `nil`.
    /// - Returns: A configured UIButton instance with the specified parameters and action.
    static func createCustomButton(
        title: String,
        style: UIButton.Configuration = UIButton.Configuration.filled(),
        foregroundColor: UIColor = .white,
        backgroundColor: UIColor = .systemPurple,
        textStyle: UIFont.TextStyle = .headline,
        fontWeight: UIFont.Weight = .regular,
        contentInset: NSDirectionalEdgeInsets = .zero,
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

        if let action {
            button.addAction(action, for: .touchUpInside)
        }

        return button
    }
}
