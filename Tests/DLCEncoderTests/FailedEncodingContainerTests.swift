import XCTest
import DLCCommon

@testable import DLCEncoder

final class FailedEncodingContainerTests: XCTestCase {
    func testEncodeNil() {
        let path = [RowCodingKey(intValue: 1)]
        let container = FailedEncodingContainer<RowCodingKey>(
            codingPath: path
        )
        
        XCTAssertThrowsError(
            try container.encodeNil()
        ) { error in
            guard case let EncodingError.invalidValue(_, context) = error else {
                return XCTFail()
            }
            XCTAssertEqual(context.codingPath as? [RowCodingKey], path)
            XCTAssertEqual(
                context.debugDescription,
                "encodeNil() is not supported for this encoding path."
            )
        }
    }
    
    func testEncodeNilForKey() {
        let path = [RowCodingKey(intValue: 1)]
        let key = RowCodingKey(intValue: 2)
        let container = FailedEncodingContainer<RowCodingKey>(
            codingPath: path
        )
        
        XCTAssertThrowsError(
            try container.encodeNil(forKey: key)
        ) { error in
            guard case let EncodingError.invalidValue(_, context) = error else {
                return XCTFail()
            }
            XCTAssertEqual(context.codingPath as? [RowCodingKey], path + [key])
            XCTAssertEqual(
                context.debugDescription,
                "encodeNil(forKey:) is not supported for this encoding path."
            )
        }
    }
    
    func testEncodeValue() {
        let path = [RowCodingKey(intValue: 1)]
        let container = FailedEncodingContainer<RowCodingKey>(
            codingPath: path
        )
        
        XCTAssertThrowsError(
            try container.encode(123)
        ) { error in
            guard case let EncodingError.invalidValue(_, context) = error else {
                return XCTFail()
            }
            XCTAssertEqual(context.codingPath as? [RowCodingKey], path)
            XCTAssertEqual(
                context.debugDescription,
                "encode(_:) is not supported for this encoding path."
            )
        }
    }
    
    func testEncodeValueForKey() {
        let path = [RowCodingKey(intValue: 1)]
        let key = RowCodingKey(intValue: 2)
        let container = FailedEncodingContainer<RowCodingKey>(
            codingPath: path
        )
        
        XCTAssertThrowsError(
            try container.encode(123, forKey: key)
        ) { error in
            guard case let EncodingError.invalidValue(_, context) = error else {
                return XCTFail()
            }
            XCTAssertEqual(context.codingPath as? [RowCodingKey], path + [key])
            XCTAssertEqual(
                context.debugDescription,
                "encode(_:forKey:) is not supported for this encoding path."
            )
        }
    }
    
    func testNestedKeyedContainer() {
        let path = [RowCodingKey(intValue: 1)]
        let container = FailedEncodingContainer<RowCodingKey>(
            codingPath: path
        )
        let nestedContainer = container.nestedContainer(
            keyedBy: RowCodingKey.self
        )
        XCTAssertEqual(nestedContainer.codingPath as? [RowCodingKey], path)
    }
    
    func testNestedKeyedContainerForKey() {
        let path = [RowCodingKey(intValue: 1)]
        let key = RowCodingKey(intValue: 2)
        let container = FailedEncodingContainer<RowCodingKey>(
            codingPath: path
        )
        let nestedContainer = container.nestedContainer(
            keyedBy: RowCodingKey.self, forKey: key
        )
        XCTAssertEqual(nestedContainer.codingPath as? [RowCodingKey], path + [key])
    }
    
    func testNestedUnkeyedContainer() {
        let path = [RowCodingKey(intValue: 1)]
        let container = FailedEncodingContainer<RowCodingKey>(
            codingPath: path
        )
        let nestedContainer = container.nestedUnkeyedContainer()
        XCTAssertTrue(nestedContainer is FailedEncodingContainer<RowCodingKey>)
        XCTAssertEqual(nestedContainer.codingPath as? [RowCodingKey], path)
    }
    
    func testNestedUnkeyedContainerForKey() {
        let path = [RowCodingKey(intValue: 1)]
        let key = RowCodingKey(intValue: 2)
        let container = FailedEncodingContainer<RowCodingKey>(
            codingPath: path
        )
        let nestedContainer = container.nestedUnkeyedContainer(forKey: key)
        XCTAssertTrue(nestedContainer is FailedEncodingContainer<RowCodingKey>)
        XCTAssertEqual(nestedContainer.codingPath as? [RowCodingKey], path + [key])
    }
    
    func testSuperEncoder() {
        let path = [RowCodingKey(intValue: 1)]
        let container = FailedEncodingContainer<RowCodingKey>(
            codingPath: path
        )
        let encoder = container.superEncoder()
        XCTAssertTrue(encoder is FailedEncoder)
        XCTAssertEqual(encoder.codingPath as? [RowCodingKey], path)
    }
    
    func testSuperEncoderForKey() {
        let path = [RowCodingKey(intValue: 1)]
        let key = RowCodingKey(intValue: 2)
        let container = FailedEncodingContainer<RowCodingKey>(
            codingPath: path
        )
        let encoder = container.superEncoder(forKey: key)
        XCTAssertTrue(encoder is FailedEncoder)
        XCTAssertEqual(encoder.codingPath as? [RowCodingKey], path + [key])
    }
}
