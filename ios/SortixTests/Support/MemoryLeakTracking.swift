import Foundation
import Testing

/// Holds an object without retaining it, to check that it was deallocated.
final class WeakReference {
    weak var object: AnyObject?

    init(_ object: AnyObject) {
        self.object = object
    }
}

/// Fails the test if any object built by `makeObjects` is still alive once the closure returns.
///
/// Typical use: build a scene's ViewController and ViewModel, load the view, return both. A
/// surviving object usually means a closure captured `self` strongly.
@MainActor
func expectDeallocation(
    of makeObjects: () -> [AnyObject],
    sourceLocation: SourceLocation = #_sourceLocation
) {
    var references: [WeakReference] = []
    autoreleasepool {
        references = makeObjects().map(WeakReference.init)
    }
    for reference in references {
        #expect(reference.object == nil, "Possible retain cycle", sourceLocation: sourceLocation)
    }
}
