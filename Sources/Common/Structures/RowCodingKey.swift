import Foundation

struct RowCodingKey: CodingKey, Equatable {
    // MARK: - Properties
    
    let stringValue: String
    let intValue: Int?
    
    // MARK: - Inits
    
    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init(intValue: Int) {
        self.stringValue = "Index \(intValue)"
        self.intValue = intValue
    }
}
