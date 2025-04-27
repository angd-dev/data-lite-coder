import Foundation

extension RowDecoder {
    /// Strategies for decoding `Date` values from SQLite data.
    ///
    /// The `DateDecodingStrategy` enum defines different strategies for decoding `Date` values.
    /// These strategies determine how SQLite data is converted to `Date` objects during the decoding process.
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
        /// The default strategy. Decodes the date based on the type of SQLite.
        ///
        /// This strategy attempts to decode the date using the initializer defined
        /// in the `SQLiteRawRepresentable` protocol, which the Date type conforms to.
        ///
        /// Use this strategy when you want to rely on the default conversion
        /// logic provided by the SQLiteRawRepresentable conformance of Date.
        case deferredToDate
        
        /// Decodes the date using a custom `DateFormatter`. Allows for flexible date formats.
        case formatted(any DateFormatterProtocol)
        
        /// Decodes the date as milliseconds since the Unix epoch (`Int`).
        case millisecondsSince1970Int
        
        /// Decodes the date as milliseconds since the Unix epoch (`Double`).
        case millisecondsSince1970Double
        
        /// Decodes the date as seconds since the Unix epoch (`Int`).
        case secondsSince1970Int
        
        /// Decodes the date as seconds since the Unix epoch (`Double`).
        case secondsSince1970Double
        
        /// Decodes the date using the ISO 8601 format (`yyyy-MM-dd'T'HH:mm:ssZ`).
        public static var iso8601: Self {
            .formatted(ISO8601DateFormatter())
        }
    }
}
