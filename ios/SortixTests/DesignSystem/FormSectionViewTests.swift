import Testing
import UIKit
@testable import Sortix

@MainActor
struct FormSectionViewTests {
    @Test func addRowCountsRows() {
        let section = FormSectionView(header: "Header")

        section.addRow(UIView())
        section.addRow(UIView())

        #expect(section.rowCount == 2)
    }
}
