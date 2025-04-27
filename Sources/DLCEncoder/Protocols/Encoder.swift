import Foundation

public protocol Encoder: Swift.Encoder {
    associatedtype SQLiteData
    
    var dateEncoder: any DateEncoder { get }
    var sqliteData: SQLiteData { get }
}
