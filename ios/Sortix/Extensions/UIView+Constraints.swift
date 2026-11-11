import UIKit

@MainActor
extension UIView {
    /// Adds the views as subviews and turns off their autoresizing masks for Auto Layout.
    func addSubviewsForAutoLayout(_ views: UIView...) {
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }

    /// Returns constraints that pin the view's edges to another view. The caller activates them.
    func constraintsPinningEdges(
        to view: UIView,
        insets: NSDirectionalEdgeInsets = .zero
    ) -> [NSLayoutConstraint] {
        [
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.leading),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.trailing),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ]
    }

    /// Returns constraints that pin the view's edges to a layout guide. The caller activates them.
    func constraintsPinningEdges(
        to guide: UILayoutGuide,
        insets: NSDirectionalEdgeInsets = .zero
    ) -> [NSLayoutConstraint] {
        [
            topAnchor.constraint(equalTo: guide.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: insets.leading),
            trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -insets.trailing),
            bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -insets.bottom)
        ]
    }
}
