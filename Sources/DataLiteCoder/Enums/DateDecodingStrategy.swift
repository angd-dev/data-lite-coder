import Foundation

extension RowDecoder {
    /// Strategies to use for decoding `Date` values from SQLite data.
    ///
    /// Use these strategies to specify how `Date` values should be decoded
    /// from various SQLite-compatible representations. This enum supports
    /// deferred decoding, standard formats, custom formatters, and epoch timestamps.
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
    public enum DateDecodingStrategy {
        /// Decode dates by using the implementation of the `SQLiteRawRepresentable` protocol.
        ///
        /// This strategy relies on the type’s conformance to `SQLiteRawRepresentable`
        /// to decode the date value from SQLite data.
        case deferredToDate
        
        /// Decode dates using the provided custom formatter.
        ///
        /// - Parameter formatter: An object conforming to `DateFormatterProtocol`
        ///   used to decode the date string.
        case formatted(any DateFormatterProtocol)
        
        /// Decode dates from an integer representing milliseconds since 1970.
        case millisecondsSince1970Int
        
        /// Decode dates from a double representing milliseconds since 1970.
        case millisecondsSince1970Double
        
        /// Decode dates from an integer representing seconds since 1970.
        case secondsSince1970Int
        
        /// Decode dates from a double representing seconds since 1970.
        case secondsSince1970Double
        
        /// Decode dates using ISO 8601 format.
        ///
        /// This strategy uses `ISO8601DateFormatter` internally.
        public static var iso8601: Self {
            .formatted(ISO8601DateFormatter())
        }
    }
}
