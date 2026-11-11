import Testing
import UIKit
@testable import Sortix

@MainActor
struct TextFieldRowTests {
    @Test func editingForwardsText() {
        let row = TextFieldRow(title: "Title")
        var received: [String] = []
        row.onTextChange = { received.append($0) }

        row.textField.text = "Ana"
        row.textField.sendActions(for: .editingChanged)

        #expect(received == ["Ana"])
    }

    @Test func configureDoesNotReportAChange() {
        let row = TextFieldRow(placeholder: "Placeholder")
        var changeCount = 0
        row.onTextChange = { _ in changeCount += 1 }

        row.configure(with: TextFieldRow.Model(text: "Bruno", errorMessage: nil))

        #expect(row.textField.text == "Bruno")
        #expect(changeCount == 0)
    }

    @Test func accessibilityLabelFallsBackToTitle() {
        let row = TextFieldRow(title: "Title", placeholder: "Placeholder")

        #expect(row.textField.accessibilityLabel == "Title")
    }
}
