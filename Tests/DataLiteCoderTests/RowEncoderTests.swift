import XCTest
import DataLiteCore
import DataLiteCoder

final class RowEncoderTests: XCTestCase {
    // MARK: - Encode to SQLiteRow
    
    func testEncodeToRowWithAllTypes() throws {
        let createdAt = Date(timeIntervalSince1970: 12345)
        let payload = "payload".data(using: .utf8)!
        
        let model = StandardModel(
            id: 123456,
            type: .simple,
            name: "John Doe",
            age: 34,
            isActive: true,
            score: 3.1415,
            createdAt: createdAt,
            payload: payload
        )
        let row = try RowEncoder(
            userInfo: [:],
            dateEncodingStrategy: .deferredToDate
        ).encode(model)
        
        XCTAssertEqual(row.count, 8)
        XCTAssertEqual(row["id"], .int(123456))
        XCTAssertEqual(row["type"], .text("simple"))
        XCTAssertEqual(row["name"], .text("John Doe"))
        XCTAssertEqual(row["age"], .int(34))
        XCTAssertEqual(row["isActive"], .int(1))
        XCTAssertEqual(row["score"], .real(3.1415))
        XCTAssertEqual(row["createdAt"], createdAt.sqliteRawValue)
        XCTAssertEqual(row["payload"], .blob(payload))
    }
    
    func testEncodeToRowWithOptionalValues() throws {
        let createdAt = Date(timeIntervalSince1970: 12345)
        let payload = "payload".data(using: .utf8)!
        
        let model = OptionalModel(
            id: 123456,
            type: .multiple,
            name: "Jane Doe",
            createdAt: createdAt,
            payload: payload
        )
        let row = try RowEncoder(
            userInfo: [:],
            dateEncodingStrategy: .deferredToDate
        ).encode(model)
        
        XCTAssertEqual(row.count, 5)
        XCTAssertEqual(row["id"], .int(123456))
        XCTAssertEqual(row["type"], .text("multiple"))
        XCTAssertEqual(row["name"], .text("Jane Doe"))
        XCTAssertEqual(row["createdAt"], createdAt.sqliteRawValue)
        XCTAssertEqual(row["payload"], .blob(payload))
    }
    
    func testEncodeToRowWithOptionalNilValues() throws {
        let row = try RowEncoder(
            userInfo: [:],
            dateEncodingStrategy: .deferredToDate
        ).encode(OptionalModel())
        
        XCTAssertEqual(row.count, 5)
        XCTAssertEqual(row["id"], .null)
        XCTAssertEqual(row["type"], .null)
        XCTAssertEqual(row["name"], .null)
        XCTAssertEqual(row["createdAt"], .null)
        XCTAssertEqual(row["payload"], .null)
    }
    
    // MARK: - Encode to Array of SQLiteRow
    
    func testEncodeToRowArrayWithAllTypes() throws {
        let createdAt = Date(timeIntervalSince1970: 12345)
        let payload = "payload".data(using: .utf8)!
        
        let models = [
            StandardModel(
                id: 123456,
                type: .simple,
                name: "John Doe",
                age: 34,
                isActive: true,
                score: 3.1415,
                createdAt: createdAt,
                payload: payload
            ),
            StandardModel(
                id: 456,
                type: .multiple,
                name: "Jane Doe",
                age: 28,
                isActive: false,
                score: 2.7182,
                createdAt: createdAt,
                payload: payload
            )
        ]
        let rows = try RowEncoder(
            userInfo: [:],
            dateEncodingStrategy: .deferredToDate
        ).encode(models)
        
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[0].count, 8)
        XCTAssertEqual(rows[1].count, 8)
        
        XCTAssertEqual(rows[0]["id"], .int(123456))
        XCTAssertEqual(rows[0]["type"], .text("simple"))
        XCTAssertEqual(rows[0]["name"], .text("John Doe"))
        XCTAssertEqual(rows[0]["age"], .int(34))
        XCTAssertEqual(rows[0]["isActive"], .int(1))
        XCTAssertEqual(rows[0]["score"], .real(3.1415))
        XCTAssertEqual(rows[0]["createdAt"], createdAt.sqliteRawValue)
        XCTAssertEqual(rows[0]["payload"], .blob(payload))
        
        XCTAssertEqual(rows[1]["id"], .int(456))
        XCTAssertEqual(rows[1]["type"], .text("multiple"))
        XCTAssertEqual(rows[1]["name"], .text("Jane Doe"))
        XCTAssertEqual(rows[1]["age"], .int(28))
        XCTAssertEqual(rows[1]["isActive"], .int(0))
        XCTAssertEqual(rows[1]["score"], .real(2.7182))
        XCTAssertEqual(rows[1]["createdAt"], createdAt.sqliteRawValue)
        XCTAssertEqual(rows[1]["payload"], .blob(payload))
    }
    
    func testEncodeToRowArrayWithOptionalValues() throws {
        let createdAt = Date(timeIntervalSince1970: 12345)
        let payload = "payload".data(using: .utf8)!
        
        let models = [
            OptionalModel(
                id: 123,
                type: .multiple,
                name: "Jane Doe",
                createdAt: createdAt,
                payload: payload
            ),
            OptionalModel(
                id: nil,
                type: nil,
                name: "John Doe",
                createdAt: nil,
                payload: nil
            )
        ]
        
        let rows = try RowEncoder(
            userInfo: [:],
            dateEncodingStrategy: .deferredToDate
        ).encode(models)
        
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[0].count, 5)
        XCTAssertEqual(rows[1].count, 5)
        
        XCTAssertEqual(rows[0]["id"], .int(123))
        XCTAssertEqual(rows[0]["type"], .text("multiple"))
        XCTAssertEqual(rows[0]["name"], .text("Jane Doe"))
        XCTAssertEqual(rows[0]["createdAt"], createdAt.sqliteRawValue)
        XCTAssertEqual(rows[0]["payload"], .blob(payload))
        
        XCTAssertEqual(rows[1]["id"], .null)
        XCTAssertEqual(rows[1]["type"], .null)
        XCTAssertEqual(rows[1]["name"], .text("John Doe"))
        XCTAssertEqual(rows[1]["createdAt"], .null)
        XCTAssertEqual(rows[1]["payload"], .null)
    }
}

private extension RowEncoderTests {
    enum `Type`: String, Encodable, Equatable {
        case simple
        case multiple
    }
    
    struct StandardModel: Encodable, Equatable {
        let id: Int
        let type: `Type`
        let name: String
        let age: Int
        let isActive: Bool
        let score: Double
        let createdAt: Date
        let payload: Data
    }
    
    struct OptionalModel: Encodable, Equatable {
        let id: Int?
        let type: `Type`?
        let name: String?
        let createdAt: Date?
        let payload: Data?
        
        init(
            id: Int? = nil,
            type: `Type`? = nil,
            name: String? = nil,
            createdAt: Date? = nil,
            payload: Data? = nil
        ) {
            self.id = id
            self.type = type
            self.name = name
            self.createdAt = createdAt
            self.payload = payload
        }
        
        enum CodingKeys: CodingKey {
            case id
            case type
            case name
            case createdAt
            case payload
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(self.id, forKey: .id)
            try container.encodeIfPresent(self.type, forKey: .type)
            try container.encodeIfPresent(self.name, forKey: .name)
            try container.encodeIfPresent(self.createdAt, forKey: .createdAt)
            try container.encodeIfPresent(self.payload, forKey: .payload)
        }
    }
}
