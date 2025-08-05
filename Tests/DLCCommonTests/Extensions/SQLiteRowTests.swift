import XCTest
import DataLiteCore
import DLCCommon

final class SQLiteRowTests: XCTestCase {
    func testContainsKey() {
        var row = SQLiteRow()
        row["key1"] = .text("value1")
        row["key2"] = .int(42)
        
        XCTAssertTrue(row.contains(DummyKey(stringValue: "key1")))
        XCTAssertFalse(row.contains(DummyKey(stringValue: "key3")))
        
        XCTAssertTrue(row.contains(DummyKey(intValue: 0)))
        XCTAssertFalse(row.contains(DummyKey(intValue: 2)))
    }
    
    func testSubscriptWithKey() {
        var row = SQLiteRow()
        row["key1"] = .text("value")
        
        XCTAssertEqual(row[DummyKey(stringValue: "key1")], .text("value"))
        XCTAssertNil(row[DummyKey(stringValue: "key2")])
        
        XCTAssertEqual(row[DummyKey(intValue: 0)], .text("value"))
        
        row[DummyKey(stringValue: "key1")] = .int(42)
        XCTAssertEqual(row[DummyKey(stringValue: "key1")], .int(42))
        
        row[DummyKey(intValue: 0)] = .real(3.14)
        XCTAssertEqual(row[DummyKey(intValue: 0)], .real(3.14))
    }
}

private extension SQLiteRowTests {
    struct DummyKey: CodingKey, Equatable {
        var stringValue: String
        var intValue: Int?
        
        init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
}
