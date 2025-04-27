import Foundation

public struct RowCodingKey: CodingKey, Equatable {
    // MARK: - Properties
    
    public let stringValue: String
    public let intValue: Int?
    
    // MARK: - Inits
    
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init(intValue: Int) {
        self.stringValue = "Index \(intValue)"
        self.intValue = intValue
    }
}
