import Foundation
import DataLiteCore

private import DLCEncoder

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
/// - ``dateEncodingStrategy-swift.property``
/// - ``DateEncodingStrategy-swift.enum``
public final class RowEncoder {
    // MARK: - Properties
    
    public var userInfo: [CodingUserInfoKey: Any]
    
    public var dateEncodingStrategy: DateEncodingStrategy
    
    // MARK: - Inits
    
    public init(
        userInfo: [CodingUserInfoKey: Any] = [:],
        dateEncodingStrategy: DateEncodingStrategy = .deferredToDate
    ) {
        self.userInfo = userInfo
        self.dateEncodingStrategy = dateEncodingStrategy
    }
    
    // MARK: - Methods
    
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
        public typealias Output = SQLiteRow
    }
#endif
