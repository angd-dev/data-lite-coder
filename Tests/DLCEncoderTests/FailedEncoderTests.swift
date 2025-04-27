import XCTest
import DLCCommon

@testable import DLCEncoder

final class FailedEncoderTests: XCTestCase {
    func testKeyedContainer() {
        let path = [RowCodingKey(intValue: 1), RowCodingKey(intValue: 2)]
        let encoder = FailedEncoder(codingPath: path)
        let container = encoder.container(keyedBy: RowCodingKey.self)
        XCTAssertEqual(container.codingPath as? [RowCodingKey], path)
    }
    
    func testUnkeyedContainer() {
        let path = [RowCodingKey(intValue: 1), RowCodingKey(intValue: 2)]
        let encoder = FailedEncoder(codingPath: path)
        let container = encoder.unkeyedContainer()
        XCTAssertTrue(container is FailedEncodingContainer<RowCodingKey>)
        XCTAssertEqual(container.codingPath as? [RowCodingKey], path)
    }
    
    func testSingleValueContainer() {
        let path = [RowCodingKey(intValue: 1), RowCodingKey(intValue: 2)]
        let encoder = FailedEncoder(codingPath: path)
        let container = encoder.singleValueContainer()
        XCTAssertTrue(container is FailedEncodingContainer<RowCodingKey>)
        XCTAssertEqual(container.codingPath as? [RowCodingKey], path)
    }
}
