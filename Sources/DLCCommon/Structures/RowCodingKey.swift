import Foundation

package struct RowCodingKey: CodingKey, Equatable {
    // MARK: - Properties
    
    package let stringValue: String
    package let intValue: Int?
    
    // MARK: - Inits
    
    package init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    package init(intValue: Int) {
        self.stringValue = "Index \(intValue)"
        self.intValue = intValue
    }
}
