import Foundation

extension RowEncoder {
    /// Strategies to use for encoding `Date` values into SQLite-compatible types.
    ///
    /// Use these strategies to specify how `Date` values should be encoded
    /// into SQLite-compatible representations. This enum supports deferred encoding,
    /// standard formats, custom formatters, and epoch timestamps.
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
        /// Encode dates by using the implementation of the `SQLiteRawRepresentable` protocol.
        ///
        /// This strategy relies on the type’s conformance to `SQLiteRawRepresentable`
        /// to encode the date value into a SQLite-compatible representation.
        case deferredToDate
        
        /// Encode dates using the provided custom formatter.
        ///
        /// - Parameter formatter: An object conforming to `DateFormatterProtocol`
        ///   used to encode the date string.
        case formatted(any DateFormatterProtocol)
        
        /// Encode dates as an integer representing milliseconds since 1970.
        case millisecondsSince1970Int
        
        /// Encode dates as a double representing milliseconds since 1970.
        case millisecondsSince1970Double
        
        /// Encode dates as an integer representing seconds since 1970.
        case secondsSince1970Int
        
        /// Encode dates as a double representing seconds since 1970.
        case secondsSince1970Double
        
        /// Encode dates using ISO 8601 format.
        ///
        /// This strategy uses `ISO8601DateFormatter` internally.
        public static var iso8601: Self {
            .formatted(ISO8601DateFormatter())
        }
    }
}
