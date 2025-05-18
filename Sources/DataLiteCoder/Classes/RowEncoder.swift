import Foundation
import DataLiteCore

private import DLCEncoder

/// Encoder that encodes instances of `Encodable` types into `SQLiteRow` or an array of `SQLiteRow`.
///
/// ## Overview
///
/// Use `RowEncoder` to convert `Encodable` objects into a single `SQLiteRow` or an array of `SQLiteRow`.
///
/// ### Encode a Single Object
///
/// Use ``encode(_:)->SQLiteRow`` to encode a single `Encodable` value into a `SQLiteRow`.
///
/// ```swift
/// struct User: Encodable {
///     let id: Int
///     let name: String
/// }
///
/// do {
///     let user = User(id: 1, name: "John Doe")
///     let encoder = RowEncoder()
///     let row = try encoder.encode(user)
/// } catch {
///     print("Encoding error: ", error)
/// }
/// ```
///
/// ### Encode an Array of Objects
///
/// Use ``encode(_:)->[SQLiteRow]`` to encode an array of `Encodable` values into an array of `SQLiteRow`.
///
/// ```swift
/// struct User: Encodable {
///     let id: Int
///     let name: String
/// }
///
/// do {
///     let users = [
///         User(id: 1, name: "John Doe"),
///         User(id: 2, name: "Jane Smith")
///     ]
///     let encoder = RowEncoder()
///     let rows = try encoder.encode(users)
/// } catch {
///     print("Encoding error: ", error)
/// }
/// ```
///
/// ### Customize Encoding Behavior
///
/// Use the ``userInfo`` property to pass additional data that can affect encoding logic.
///
/// First, define a custom key:
///
/// ```swift
/// extension CodingUserInfoKey {
///     static let lowercased = CodingUserInfoKey(
///         rawValue: "lowercased"
///     )!
/// }
/// ```
///
/// Then pass a value using this key:
///
/// ```swift
/// do {
///     let user = User(id: 1, name: "John Doe")
///     let encoder = RowEncoder()
///     encoder.userInfo[.lowercased] = true
///
///     let row = try encoder.encode(user)
/// } catch {
///     print("Encoding error: ", error)
/// }
/// ```
///
/// Access this value inside your custom `encode(to:)` method:
///
/// ```swift
/// struct User: Encodable {
///     enum CodingKeys: CodingKey {
///         case id, name
///     }
///
///     let id: Int
///     let name: String
///
///     func encode(to encoder: any Encoder) throws {
///         var container = encoder.container(keyedBy: CodingKeys.self)
///         try container.encode(self.id, forKey: .id)
///
///         if (encoder.userInfo[.lowercased] as? Bool) ?? false {
///             try container.encode(self.name.lowercased(), forKey: .name)
///         } else {
///             try container.encode(self.name.capitalized, forKey: .name)
///         }
///     }
/// }
/// ```
///
/// ### Date Encoding Strategy
///
/// Use the ``dateEncodingStrategy`` property to control how `Date` values are encoded into SQLite.
///
/// ```swift
/// struct Log: Encodable {
///     let timestamp: Date
/// }
///
/// do {
///     let encoder = RowEncoder(
///         dateEncodingStrategy: .iso8601
///     )
///
///     let log = Log(timestamp: Date())
///     let row = try encoder.encode(log)
/// } catch {
///     print("Encoding error: ", error)
/// }
/// ```
///
/// For more detailed information, see ``DateEncodingStrategy``.
///
/// ## Topics
///
/// ### Creating an Encoder
///
/// - ``init(userInfo:dateEncodingStrategy:)``
///
/// ### Encoding
///
/// - ``encode(_:)->SQLiteRow``
/// - ``encode(_:)->[SQLiteRow]``
///
/// ### Customizing Encoding
///
/// - ``userInfo``
///
/// ### Encoding Dates
///
/// - ``dateEncodingStrategy``
/// - ``DateEncodingStrategy``
public final class RowEncoder {
    // MARK: - Properties
    
    /// A dictionary you use to customize encoding behavior.
    ///
    /// Use this dictionary to pass additional contextual information to the encoded type's `encode(to:)`
    /// implementation. You can define your own keys by extending `CodingUserInfoKey`.
    ///
    /// This can be useful when encoding needs to consider external state, such as user roles,
    /// environment settings, or formatting preferences.
    public var userInfo: [CodingUserInfoKey: Any]
    
    /// The strategy to use for encoding `Date` values.
    ///
    /// Use this property to control how `Date` values are encoded into SQLite-compatible types.
    /// By default, the `.deferredToDate` strategy is used.
    ///
    /// You can change the strategy to encode dates as timestamps, ISO 8601 strings,
    /// or using a custom formatter.
    ///
    /// For details on available strategies, see ``DateEncodingStrategy``.
    public var dateEncodingStrategy: DateEncodingStrategy
    
    // MARK: - Inits
    
    /// Creates a new instance of `RowEncoder`.
    ///
    /// - Parameters:
    ///   - userInfo: A dictionary you can use to customize the encoding process by passing
    ///     additional contextual information. The default value is an empty dictionary.
    ///   - dateEncodingStrategy: The strategy to use for encoding `Date` values.
    ///     The default value is `.deferredToDate`.
    public init(
        userInfo: [CodingUserInfoKey: Any] = [:],
        dateEncodingStrategy: DateEncodingStrategy = .deferredToDate
    ) {
        self.userInfo = userInfo
        self.dateEncodingStrategy = dateEncodingStrategy
    }
    
    // MARK: - Methods
    
    /// Encodes a single value of a type that conforms to `Encodable` into a `SQLiteRow`.
    ///
    /// - Parameter value: The value to encode.
    /// - Returns: A `SQLiteRow` containing the encoded data of the provided value.
    /// - Throws: An error if any value throws an error during encoding.
    public func encode<T: Encodable>(_ value: T) throws -> SQLiteRow {
        let dateEncoder = DateEncoder(
            strategy: dateEncodingStrategy
        )
        let encoder = SingleRowEncoder(
            dateEncoder: dateEncoder,
            codingPath: [],
            userInfo: userInfo
        )
        try value.encode(to: encoder)
        return encoder.sqliteData
    }
    
    /// Encodes an array of values conforming to `Encodable` into an array of `SQLiteRow`.
    ///
    /// - Parameter value: The array of values to encode.
    /// - Returns: An array of `SQLiteRow` objects containing the encoded data.
    /// - Throws: An error if any value throws an error during encoding.
    public func encode<T: Encodable>(_ value: [T]) throws -> [SQLiteRow] {
        let dateEncoder = DateEncoder(
            strategy: dateEncodingStrategy
        )
        let encoder = MultiRowEncoder(
            dateEncoder: dateEncoder,
            codingPath: [],
            userInfo: userInfo
        )
        try value.encode(to: encoder)
        return encoder.sqliteData
    }
}

#if canImport(Combine)
    import Combine
    
    // MARK: - TopLevelEncoder
    
    extension RowEncoder: TopLevelEncoder {
        /// The output type produced by the encoder.
        public typealias Output = SQLiteRow
    }
#endif
