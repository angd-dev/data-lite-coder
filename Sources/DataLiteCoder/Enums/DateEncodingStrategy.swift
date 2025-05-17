import Foundation

extension RowEncoder {
    /// Strategies for encoding `Date` values for storage in SQLite.
    ///
    /// The `DateEncodingStrategy` enum defines how `Date` values are converted
    /// to a supported SQLite type during the encoding process.
    ///
    /// ## Topics
    ///
    /// ### Default Formats
    ///
    /// - ``deferredToDate``
    ///
    /// ### Standard Formats
    ///
    /// - ``iso8601``
    ///
    /// ### Custom Formats
    ///
    /// - ``formatted(_:)``
    ///
    /// ### Epoch Formats
    ///
    /// - ``millisecondsSince1970Int``
    /// - ``millisecondsSince1970Double``
    /// - ``secondsSince1970Int``
    /// - ``secondsSince1970Double``
    public enum DateEncodingStrategy {
        /// The default strategy. Encodes the date using the type’s `SQLiteRawValue` representation.
        ///
        /// This strategy relies on the `SQLiteRawRepresentable` conformance of `Date`.
        /// Use this when the default serialization logic implemented by `Date` should be used.
        case deferredToDate

        /// Encodes the date using a custom `DateFormatter`.
        ///
        /// This strategy allows full control over the string format used to represent dates.
        /// The formatted string will be written to the SQLite database.
        ///
        /// - Parameter formatter: A custom formatter conforming to `DateFormatterProtocol`.
        case formatted(any DateFormatterProtocol)

        /// Encodes the date as the number of milliseconds since the Unix epoch (`Int`).
        ///
        /// Suitable for compact and precise date representation as integer timestamps.
        case millisecondsSince1970Int

        /// Encodes the date as the number of milliseconds since the Unix epoch (`Double`).
        ///
        /// Useful when sub-millisecond precision is needed in floating-point representation.
        case millisecondsSince1970Double

        /// Encodes the date as the number of seconds since the Unix epoch (`Int`).
        ///
        /// This format is common in many systems that represent timestamps as whole seconds.
        case secondsSince1970Int

        /// Encodes the date as the number of seconds since the Unix epoch (`Double`).
        ///
        /// Use this strategy when you require sub-second precision but prefer seconds over milliseconds.
        case secondsSince1970Double

        /// Encodes the date using the ISO 8601 format (`yyyy-MM-dd'T'HH:mm:ssZ`).
        ///
        /// This strategy uses `ISO8601DateFormatter` to convert the date into a standardized string
        /// format. It is widely used for text-based date representations and ensures interoperability.
        public static var iso8601: Self {
            .formatted(ISO8601DateFormatter())
        }
    }
}
