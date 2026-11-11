import Testing
import UIKit
@testable import Sortix

@MainActor
struct TextFieldListCellTests {
    @Test func reuseClearsClosures() {
        let cell = TextFieldListCell(frame: .zero)
        cell.onTextChange = { _ in }
        cell.onReturn = { true }

        cell.prepareForReuse()

        #expect(cell.onTextChange == nil)
        #expect(cell.onReturn == nil)
    }

    @Test func returnKeepsFocusOnlyWhenRequested() {
        let cell = TextFieldListCell(frame: .zero)
        var returnCount = 0
        cell.onReturn = {
            returnCount += 1
            return true
        }

        let shouldInsertNewline = cell.textFieldShouldReturn(cell.textField)

        #expect(returnCount == 1)
        #expect(!shouldInsertNewline)
    }
}
