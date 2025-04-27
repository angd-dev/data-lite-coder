import Foundation

/// A common interface for formatting and parsing `Date` values.
///
/// The `DateFormatterProtocol` abstracts the interface of date formatters, allowing
/// interchangeable use of `DateFormatter` and `ISO8601DateFormatter` when encoding or decoding
/// date values.
public protocol DateFormatterProtocol {
    /// Returns a string representation of the specified date.
    ///
    /// - Parameter date: The `Date` to format.
    /// - Returns: A string that represents the formatted date.
    func string(from date: Date) -> String
    
    /// Converts the specified string into a `Date` object.
    ///
    /// - Parameter string: The date string to parse.
    /// - Returns: A `Date` object if the string could be parsed, or `nil` otherwise.
    func date(from string: String) -> Date?
}

extension ISO8601DateFormatter: DateFormatterProtocol {}

extension DateFormatter: DateFormatterProtocol {}
