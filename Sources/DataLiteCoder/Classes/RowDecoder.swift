import Foundation
import DataLiteCore

private import DLCDecoder

/// Decoder that decodes SQLite values into Swift types conforming to the `Decodable` protocol.
///
/// ## Overview
///
/// Use `RowDecoder` to convert `SQLiteRow` or an array of `SQLiteRow` into Swift types that conform
/// to the `Decodable` protocol.
///
/// ### Decode a Single Row
///
/// Use ``decode(_:from:)->T`` to decode a single `SQLiteRow` into a `Decodable` value.
///
/// ```swift
/// struct User: Decodable {
///     var id: Int
///     var name: String
/// }
///
/// do {
///     var row: SQLiteRow = .init()
///     row["id"] = .int(1)
///     row["name"] = .text("John Doe")
///
///     let decoder = RowDecoder()
///     let user = try decoder.decode(User.self, from: row)
/// } catch {
///     print("Decoding error:", error)
/// }
/// ```
///
/// ### Decode a Row into an Array
///
/// Use ``decode(_:from:)->T`` to decode a row containing homogeneous values
/// into an array of Swift values.
///
/// ```swift
/// do {
///     var row: SQLiteRow = .init()
///     row["a"] = .int(10)
///     row["b"] = .int(20)
///
///     let decoder = RowDecoder()
///     let numbers = try decoder.decode([Int].self, from: row)
/// } catch {
///     print("Decoding error:", error)
/// }
/// ```
///
/// ### Decode Multiple Rows
///
/// Use ``decode(_:from:)->[T]`` to decode an array of `SQLiteRow` into an array of `Decodable` values.
///
/// ```swift
/// struct User: Decodable {
///     var id: Int
///     var name: String
/// }
///
/// do {
///     let rows: [SQLiteRow] = fetchRows() // Fetch rows from a database
///     let decoder = RowDecoder()
///     let users = try decoder.decode([User].self, from: rows)
/// } catch {
///     print("Decoding error:", error)
/// }
/// ```
///
/// ### Customize Decoding with User Info
///
/// Use the ``userInfo`` property to pass context or flags to decoding logic.
///
/// First, define a custom key:
///
/// ```swift
/// extension CodingUserInfoKey {
///     static let isAdmin = CodingUserInfoKey(
///         rawValue: "isAdmin"
///     )!
/// }
/// ```
///
/// Then access it inside your model:
///
/// ```swift
/// struct User: Decodable {
///     enum CodingKeys: String, CodingKey {
///         case id, name
///     }
///
///     var id: Int
///     var name: String
///     var isAdmin: Bool
///
///     init(from decoder: Decoder) throws {
///         let container = try decoder.container(keyedBy: CodingKeys.self)
///         id = try container.decode(Int.self, forKey: .id)
///         name = try container.decode(String.self, forKey: .name)
///
///         isAdmin = (decoder.userInfo[.isAdmin] as? Bool) ?? false
///     }
/// }
/// ```
///
/// Pass the value before decoding:
///
/// ```swift
/// do {
///     var row: SQLiteRow = .init()
///     row["id"] = .int(1)
///     row["name"] = .text("John Doe")
///
///     let decoder = RowDecoder()
///     decoder.userInfo[.isAdmin] = true
///
///     let user = try decoder.decode(User.self, from: row)
/// } catch {
///     print("Decoding error:", error)
/// }
/// ```
///
/// ### Date Decoding Strategy
///
/// Use the ``dateDecodingStrategy`` property to customize how `Date` values are decoded.
///
/// ```swift
/// struct Log: Decodable {
///     let timestamp: Date
/// }
///
/// do {
///     var row: SQLiteRow = .init()
///     row["timestamp"] = .int(1_700_000_000)
///
///     let decoder = RowDecoder()
///     decoder.dateDecodingStrategy = .secondsSince1970Int
///
///     let log = try decoder.decode(Log.self, from: row)
/// } catch {
///     print("Decoding error:", error)
/// }
/// ```
///
/// For more detailed information, see ``DateDecodingStrategy``.
///
/// ## Topics
///
/// ### Creating a Decoder
///
/// - ``init(userInfo:dateDecodingStrategy:)``
///
/// ### Decoding
///
/// - ``decode(_:from:)->T``
/// - ``decode(_:from:)->[T]``
///
/// ### Customizing Decoding
///
/// - ``userInfo``
///
/// ### Decoding Dates
///
/// - ``dateDecodingStrategy``
/// - ``DateDecodingStrategy``
public final class RowDecoder {
    // MARK: - Properties
    
    /// A dictionary containing user-defined information accessible during decoding.
    ///
    /// This dictionary allows passing additional context or settings that can influence
    /// the decoding process. Values stored here are accessible inside custom `Decodable`
    /// implementations through the `Decoder`'s `userInfo` property.
    public var userInfo: [CodingUserInfoKey: Any]
    
    /// The strategy used to decode `Date` values from SQLite data.
    ///
    /// Determines how `Date` values are decoded from SQLite storage, supporting
    /// different formats such as timestamps or custom representations.
    public var dateDecodingStrategy: DateDecodingStrategy
    
    // MARK: - Initialization
    
    /// Initializes a new `RowDecoder` instance with optional configuration.
    ///
    /// - Parameters:
    ///   - userInfo: A dictionary with user-defined information accessible during decoding.
    ///   - dateDecodingStrategy: The strategy to decode `Date` values. Default is `.deferredToDate`.
    public init(
        userInfo: [CodingUserInfoKey: Any] = [:],
        dateDecodingStrategy: DateDecodingStrategy = .deferredToDate
    ) {
        self.userInfo = userInfo
        self.dateDecodingStrategy = dateDecodingStrategy
    }
    
    // MARK: - Decoding Methods
    
    /// Decodes a single `SQLiteRow` into an instance of the specified `Decodable` type.
    ///
    /// - Parameters:
    ///   - type: The target type conforming to `Decodable`.
    ///   - row: The SQLite row to decode.
    /// - Returns: An instance of the specified type decoded from the row.
    /// - Throws: An error if decoding fails.
    public func decode<T: Decodable>(
        _ type: T.Type,
        from row: SQLiteRow
    ) throws -> T {
        let dateDecoder = DateDecoder(strategy: dateDecodingStrategy)
        let decoder = SingleRowDecoder(
            dateDecoder: dateDecoder,
            sqliteData: row,
            codingPath: [],
            userInfo: userInfo
        )
        return try T(from: decoder)
    }
    
    /// Decodes an array of `SQLiteRow` values into an array of the specified `Decodable` type.
    ///
    /// - Parameters:
    ///   - type: The array type containing the element type to decode.
    ///   - rows: The array of SQLite rows to decode.
    /// - Returns: An array of decoded instances.
    /// - Throws: An error if decoding any row fails.
    public func decode<T: Decodable>(
        _ type: [T].Type,
        from rows: [SQLiteRow]
    ) throws -> [T] {
        let dateDecoder = DateDecoder(strategy: dateDecodingStrategy)
        let decoder = MultiRowDecoder(
            dateDecoder: dateDecoder,
            sqliteData: rows,
            codingPath: [],
            userInfo: userInfo
        )
        return try [T](from: decoder)
    }
}

#if canImport(Combine)
import Combine

// MARK: - TopLevelDecoder

extension RowDecoder: TopLevelDecoder {
    /// The type of input data expected by this decoder when used as a `TopLevelDecoder`.
    public typealias Input = SQLiteRow
}
#endif
