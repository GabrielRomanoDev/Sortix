import UIKit

@MainActor
extension UINavigationItem {
    /// A bar with the screen's own background and no hairline, so it blends with the
    /// `ScreenHeaderView` below it. The bar title is small and secondary, such as "Etapa 1 de 3":
    /// the screen title lives in the header.
    func applyPlainAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ColorToken.background
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: TypographyToken.subheadline,
            .foregroundColor: ColorToken.textSecondary
        ]
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
        compactAppearance = appearance
        largeTitleDisplayMode = .never
    }
}
