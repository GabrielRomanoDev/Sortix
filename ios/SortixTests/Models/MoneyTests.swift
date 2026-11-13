import Foundation
import Testing
@testable import Sortix

struct MoneyTests {
    @Test(arguments: [
        (1, Decimal(string: "0.01")),
        (5_000, Decimal(50)),
        (10_000_000, Decimal(100_000))
    ])
    func amountConvertsCentsToReais(amountMinor: Int, expected: Decimal?) {
        #expect(Money(amountMinor: amountMinor, currencyCode: "BRL").amount == expected)
    }
}
