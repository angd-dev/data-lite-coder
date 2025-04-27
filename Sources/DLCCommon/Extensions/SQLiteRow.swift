import Foundation
import DataLiteCore

public extension SQLiteRow {
    func contains(_ key: CodingKey) -> Bool {
        if let index = key.intValue {
            0..<count ~= index
        } else {
            contains(key.stringValue)
        }
    }
    
    subscript(key: CodingKey) -> Value? {
        if let index = key.intValue {
            self[index].value
        } else {
            self[key.stringValue]
        }
    }
}
