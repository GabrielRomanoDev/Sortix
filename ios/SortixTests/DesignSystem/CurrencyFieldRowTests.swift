import Foundation
import Testing
import UIKit
@testable import Sortix

@MainActor
struct CurrencyFieldRowTests {
    private func makeRow() -> CurrencyFieldRow {
        CurrencyFieldRow(title: "Valor", placeholder: nil, currencyCode: "BRL", locale: Locale(identifier: "pt_BR"))
    }

    private func type(_ text: String, in row: CurrencyFieldRow) {
        row.textField.text = text
        row.textField.sendActions(for: .editingChanged)
    }

    @Test func digitsFillTheCentsFromTheRight() {
        let row = makeRow()
        var amounts: [Int?] = []
        row.onAmountChange = { amounts.append($0) }

        type("5", in: row)
        type((row.textField.text ?? "") + "0", in: row)

        #expect(amounts == [5, 50])
        #expect(row.textField.text?.filter(\.isNumber) == "050")
    }

    @Test func onlyZerosClearTheField() {
        let row = makeRow()
        var amounts: [Int?] = []
        row.onAmountChange = { amounts.append($0) }

        type("R$ 0,0", in: row)

        #expect(amounts == [nil])
        #expect(row.textField.text == "")
    }
}
