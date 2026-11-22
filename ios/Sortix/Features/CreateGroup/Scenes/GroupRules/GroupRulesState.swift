import Foundation

/// Everything the rules screen shows. Values come from the draft, so going back to this step
/// shows what was typed before.
struct GroupRulesState: Equatable {
    var name = ""
    var maxGiftValue: Money?
    /// The event date as a `Date` for the picker, or `nil` while the toggle is off.
    var eventDate: Date?
    var location = ""
    var notes = ""

    var nameError: ValidationError?
    var maxGiftValueError: ValidationError?
    var eventDateError: ValidationError?
    var locationError: ValidationError?
    var notesError: ValidationError?

    var isNextEnabled = false
}
