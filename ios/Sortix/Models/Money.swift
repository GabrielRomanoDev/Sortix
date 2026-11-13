import Foundation

/// An amount of money in minor units (cents) plus its ISO 4217 currency code. v1 uses only `BRL`.
struct Money: Equatable, Sendable {
    let amountMinor: Int
    let currencyCode: String

    /// The amount in major units, ready for `.formatted(.currency(code:))`.
    ///
    /// Dividing by 100 assumes a currency with two decimal places, which holds for BRL. Supporting
    /// other currencies means reading their decimal places (e.g. from `NumberFormatter`) here.
    var amount: Decimal {
        Decimal(amountMinor) / 100
    }
}
