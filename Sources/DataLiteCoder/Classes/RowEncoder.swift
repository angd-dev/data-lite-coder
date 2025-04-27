import Foundation
import DataLiteCore

private import DLCEncoder

public final class RowEncoder {
    public func encode<T: Encodable>(_ value: T) throws -> SQLiteRow {
        fatalError()
    }
    
    public func encode<T: Encodable>(_ value: [T]) throws -> [SQLiteRow] {
        fatalError()
    }
}

#if canImport(Combine)
    import Combine
    
    extension RowEncoder: TopLevelEncoder {
        public typealias Output = SQLiteRow
    }
#endif
