import Testing
import UIKit
@testable import Sortix

@MainActor
struct PrimaryButtonTests {
    @Test func tapCallsAction() {
        var tapCount = 0
        let button = PrimaryButton(title: "Title") { tapCount += 1 }

        button.sendActions(for: .primaryActionTriggered)

        #expect(tapCount == 1)
    }

    @Test func activityIndicatorBlocksTaps() {
        let button = PrimaryButton(title: "Title") {}

        button.showsActivityIndicator = true
        #expect(!button.isUserInteractionEnabled)

        button.showsActivityIndicator = false
        #expect(button.isUserInteractionEnabled)
    }
}
