import XCTest
import DLCCommon

final class RowCodingKeyTests: XCTestCase {
    func testInitWithStringValue() {
        let key = RowCodingKey(stringValue: "testKey")
        
        XCTAssertEqual(key.stringValue, "testKey", "String value does not match the expected value.")
        XCTAssertNil(key.intValue, "Integer value should be nil when initialized with a string.")
    }
    
    func testInitWithIntValue() {
        let key = RowCodingKey(intValue: 5)
        
        XCTAssertEqual(key.stringValue, "Index 5", "String value does not match the expected format.")
        XCTAssertEqual(key.intValue, 5, "Integer value does not match the expected value.")
    }
}
