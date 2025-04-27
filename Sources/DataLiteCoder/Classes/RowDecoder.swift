import Foundation
import DataLiteCore

private import DLCDecoder

/// Decoder for converting SQLite data into Swift types conforming to the `Decodable` protocol.
///
/// ## Overview
///
/// `RowDecoder` allows decoding data from SQLite into Swift types that conform to the `Decodable` protocol.
/// It works with rows and arrays of rows, providing flexibility for various use cases.
///
/// ### Decoding a Row Into an Object
///
/// In this example, an SQLite row is decoded into a Swift object (struct or class) conforming to `Decodable`.
/// This is useful for working with query results that return a single row.
///
/// ```swift
/// import SQLiteCoder
/// import SQLiteSwift
///
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
/// ### Decoding a Row Into an Array
///
/// If an SQLite row contains homogeneous data (e.g., multiple numeric values), it can be decoded into a Swift array.
///
/// ```swift
/// import SQLiteCoder
/// import SQLiteSwift
///
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
/// ### Decoding an Array of Rows
///
/// This example shows how to decode an array of SQLite rows into an array of Swift objects.
/// This is useful when working with query results that return multiple rows.
///
/// ```swift
/// import SQLiteCoder
/// import SQLiteSwift
///
/// do {
///     let rows: [SQLiteRow] = fetchRows() // Example function to fetch rows
///     let decoder = RowDecoder()
///     let users = try decoder.decode([User].self, from: rows)
/// } catch {
///     print("Decoding error:", error)
/// }
/// ```
///
/// ### Custom User Info
///
/// You can pass additional data via ``userInfo`` to be used during the decoding process.
/// This can be useful for passing context or settings that influence the decoding process.
///
/// This example demonstrates how to use ``userInfo`` to pass context during decoding:
///
/// ```swift
/// import SQLiteCoder
/// import SQLiteSwift
///
/// extension CodingUserInfoKey {
///     static let isAdmin = CodingUserInfoKey(rawValue: "isAdmin")!
/// }
///
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
///         // Using userInfo to retrieve additional data
///         let userInfo = decoder.userInfo
///         if let isAdmin = userInfo[.isAdmin] as? Bool {
///             self.isAdmin = isAdmin
///         } else {
///             self.isAdmin = false
///         }
///     }
/// }
///
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
/// You can change the decoding strategy for `Date` values using the ``dateDecodingStrategy-swift.property`` property.
///
/// ```swift
/// import SQLiteCoder
/// import SQLiteSwift
///
/// let decoder = RowDecoder()
/// decoder.dateDecodingStrategy = .secondsSince1970Int
///
/// var row: SQLiteRow = .init()
/// row["timestamp"] = .int(1_700_000_000)
///
/// do {
///     let date = try decoder.decode(Date.self, from: row["timestamp"]!)
///     print("Decoded date:", date)
/// } catch {
///     print("Decoding error:", error)
/// }
/// ```
///
/// For more detailed information, see ``DateDecodingStrategy-swift.enum``.
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
/// - ``dateDecodingStrategy-swift.property``
/// - ``DateDecodingStrategy-swift.enum``
public final class RowDecoder {
    // MARK: - Properties
    
    /// A dictionary containing user-defined information that is available during decoding.
    ///
    /// You can use this dictionary to pass additional context or settings that influence the decoding process.
    /// The values stored in `userInfo` can be accessed inside a custom `Decodable` implementation
    /// via the `Decoder`'s `userInfo` property.
    public var userInfo: [CodingUserInfoKey: Any]
    
    /// The strategy used for decoding `Date` values from SQLite data.
    ///
    /// This property determines how `Date` values are decoded from SQLite storage. Different strategies
    /// allow handling various date formats, including timestamps and custom formats.
    public var dateDecodingStrategy: DateDecodingStrategy
    
    // MARK: - Inits
    
    /// Creates a new decoder configuration with optional settings.
    ///
    /// This initializer allows customizing the decoder's behavior by providing a `userInfo` dictionary
    /// and a `dateDecodingStrategy`. If not specified, default values are used.
    ///
    /// - Parameters:
    ///   - userInfo: A dictionary containing user-defined information that is available during decoding.
    ///   - dateDecodingStrategy: The strategy for decoding `Date` values. Defaults to `.deferredToDate`.
    public init(
        userInfo: [CodingUserInfoKey: Any] = [:],
        dateDecodingStrategy: DateDecodingStrategy = .deferredToDate
    ) {
        self.userInfo = userInfo
        self.dateDecodingStrategy = dateDecodingStrategy
    }
    
    // MARK: - Methods
    
    /// Decodes an SQLite row into the specified type.
    ///
    /// This method converts an `SQLiteRow` into a Swift type conforming to `Decodable`.
    /// It is useful for decoding entire rows from an SQLite query result. If decoding fails,
    /// this method throws the corresponding error.
    ///
    /// - Parameters:
    ///   - type: The type to decode the row into.
    ///   - row: The SQLite row to decode.
    /// - Returns: A decoded instance of the specified type.
    public func decode<T: Decodable>(
        _ type: T.Type,
        from row: SQLiteRow
    ) throws -> T {
        let dateDecoder = DateDecoder(
            strategy: dateDecodingStrategy
        )
        let decoder = SingleRowDecoder(
            dateDecoder: dateDecoder,
            sqliteData: row,
            codingPath: [],
            userInfo: userInfo
        )
        return try T(from: decoder)
    }
    
    /// Decodes an array of SQLite rows into an array of values of the specified type.
    ///
    /// Each `SQLiteRow` in the provided array is decoded into an instance of the
    /// specified `Decodable` type. This method is useful for decoding the results
    /// of SQL queries that return multiple rows.
    ///
    /// - Parameters:
    ///   - type: The array type containing the element type to decode.
    ///   - rows: The array of SQLite rows to decode.
    /// - Returns: An array of decoded instances of the specified type.
    public func decode<T: Decodable>(
        _ type: [T].Type,
        from rows: [SQLiteRow]
    ) throws -> [T] {
        let dateDecoder = DateDecoder(
            strategy: dateDecodingStrategy
        )
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
        /// The input data type expected by this decoder.
        ///
        /// Defines the type of data this decoder accepts when used as a `TopLevelDecoder`.
        /// For compatibility with Combine's `decode(_:decoder:)` operator, this is a single
        /// `SQLiteRow`, even though bulk decoding can be done manually using arrays.
        public typealias Input = SQLiteRow
    }
#endif
