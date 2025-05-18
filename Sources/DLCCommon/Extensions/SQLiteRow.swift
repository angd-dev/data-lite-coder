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
        get {
            if let index = key.intValue {
                self[index].value
            } else {
                self[key.stringValue]
            }
        }
        set {
            if let index = key.intValue {
                self[self[index].column] = newValue
            } else {
                self[key.stringValue] = newValue
            }
        }
    }
}
