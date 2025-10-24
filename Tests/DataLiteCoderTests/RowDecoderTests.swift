import XCTest
import DataLiteCore
import DataLiteCoder

final class RowDecoderTests: XCTestCase {
    // MARK: - Decode SQLiteRow
    
    func testDecodeRowWithAllTypes() throws {
        let decoder = RowDecoder(
            userInfo: [:],
            dateDecodingStrategy: .deferredToDate
        )
        
        let model = StandardModel(
            id: 123,
            type: .simple,
            name: "John Doe",
            age: 34,
            isActive: true,
            score: 3.1415,
            createdAt: Date(timeIntervalSince1970: 12345),
            payload: "payload".data(using: .utf8)!
        )
        
        var row = SQLiteRow()
        row["id"] = model.id.sqliteValue
        row["type"] = model.type.rawValue.sqliteValue
        row["name"] = model.name.sqliteValue
        row["age"] = model.age.sqliteValue
        row["isActive"] = model.isActive.sqliteValue
        row["score"] = model.score.sqliteValue
        row["createdAt"] = model.createdAt.sqliteValue
        row["payload"] = model.payload.sqliteValue
        
        let decoded = try decoder.decode(
            StandardModel.self,
            from: row
        )
        
        XCTAssertEqual(decoded, model)
    }
    
    func testDecodeRowWithOptionalValues() throws {
        let decoder = RowDecoder(
            userInfo: [:],
            dateDecodingStrategy: .deferredToDate
        )
        
        let model = OptionalModel(
            id: 123,
            type: .multiple,
            name: "Jane Doe",
            createdAt: Date(timeIntervalSince1970: 11000),
            payload: "payload".data(using: .utf8)!
        )
        
        var row = SQLiteRow()
        row["id"] = model.id!.sqliteValue
        row["type"] = model.type!.rawValue.sqliteValue
        row["name"] = model.name!.sqliteValue
        row["createdAt"] = model.createdAt!.sqliteValue
        row["payload"] = model.payload!.sqliteValue
        
        let decoded = try decoder.decode(
            OptionalModel.self,
            from: row
        )
        
        let empty = try decoder.decode(
            OptionalModel.self,
            from: SQLiteRow()
        )
        
        XCTAssertEqual(decoded, model)
        XCTAssertEqual(empty, OptionalModel())
    }
    
    func testDecodeRowAsArray() throws {
        let decoder = RowDecoder(
            userInfo: [:],
            dateDecodingStrategy: .deferredToDate
        )
        
        let dates = [
            Date(timeIntervalSince1970: 1234),
            Date(timeIntervalSince1970: 31415),
            Date(timeIntervalSince1970: 123456789)
        ]
        
        var row = SQLiteRow()
        row["key0"] = dates[0].sqliteValue
        row["key1"] = dates[1].sqliteValue
        row["key2"] = dates[2].sqliteValue
        
        let decoded = try decoder.decode([Date].self, from: row)
        
        XCTAssertEqual(decoded, dates)
    }
    
    func testDecodeRowMissingRequiredField() {
        let decoder = RowDecoder(
            userInfo: [:],
            dateDecodingStrategy: .deferredToDate
        )
        
        var row = SQLiteRow()
        row["id"] = 1.sqliteValue
        
        XCTAssertThrowsError(
            try decoder.decode(SimpleModel.self, from: row)
        ) { error in
            guard case DecodingError.keyNotFound = error else {
                return XCTFail("Expected DecodingError.keyNotFound, but got: \(error)")
            }
        }
    }
    
    func testDecodeRowWrongType() {
        let decoder = RowDecoder(
            userInfo: [:],
            dateDecodingStrategy: .deferredToDate
        )
        
        var row = SQLiteRow()
        row["id"] = "not an int".sqliteValue
        row["name"] = "test".sqliteValue
        
        XCTAssertThrowsError(
            try decoder.decode(SimpleModel.self, from: row)
        ) { error in
            guard case DecodingError.typeMismatch = error else {
                return XCTFail("Expected DecodingError.typeMismatch, but got: \(error)")
            }
        }
    }
    
    // MARK: - Decode array of SQLiteRow
    
    func testDecodeRowArrayWithAllTypes() throws {
        let decoder = RowDecoder(
            userInfo: [:],
            dateDecodingStrategy: .deferredToDate
        )
        
        let models = [
            StandardModel(
                id: 123,
                type: .simple,
                name: "John Doe",
                age: 34,
                isActive: true,
                score: 3.1415,
                createdAt: Date(timeIntervalSince1970: 12345),
                payload: "payload".data(using: .utf8)!
            ),
            StandardModel(
                id: 456,
                type: .multiple,
                name: "Jane Doe",
                age: 28,
                isActive: false,
                score: 2.7182,
                createdAt: Date(timeIntervalSince1970: 67890),
                payload: "another payload".data(using: .utf8)!
            )
        ]
        
        let rows: [SQLiteRow] = models.map { model in
            var row = SQLiteRow()
            row["id"] = model.id.sqliteValue
            row["type"] = model.type.rawValue.sqliteValue
            row["name"] = model.name.sqliteValue
            row["age"] = model.age.sqliteValue
            row["isActive"] = model.isActive.sqliteValue
            row["score"] = model.score.sqliteValue
            row["createdAt"] = model.createdAt.sqliteValue
            row["payload"] = model.payload.sqliteValue
            return row
        }

        let decoded = try decoder.decode([StandardModel].self, from: rows)
        
        XCTAssertEqual(decoded, models)
    }
    
    func testDecodeRowArrayWithOptionalValues() throws {
        let decoder = RowDecoder(
            userInfo: [:],
            dateDecodingStrategy: .deferredToDate
        )
        
        let models = [
            OptionalModel(
                id: 123,
                type: .multiple,
                name: "Jane Doe",
                createdAt: Date(timeIntervalSince1970: 11000),
                payload: "payload".data(using: .utf8)!
            ),
            OptionalModel(
                id: nil,
                type: nil,
                name: "John Doe",
                createdAt: nil,
                payload: nil
            )
        ]
        
        let rows: [SQLiteRow] = models.map { model in
            var row = SQLiteRow()
            row["id"] = model.id?.sqliteValue
            row["type"] = model.type?.rawValue.sqliteValue
            row["name"] = model.name?.sqliteValue
            row["createdAt"] = model.createdAt?.sqliteValue
            row["payload"] = model.payload?.sqliteValue
            return row
        }

        let decoded = try decoder.decode([OptionalModel].self, from: rows)
        
        XCTAssertEqual(decoded, models)
    }
    
    func testDecodeRowArrayAsDates() throws {
        let decoder = RowDecoder(
            userInfo: [:],
            dateDecodingStrategy: .deferredToDate
        )
        
        let dates = [
            [
                Date(timeIntervalSince1970: 1234),
                Date(timeIntervalSince1970: 31415),
                Date(timeIntervalSince1970: 12345679)
            ],
            [
                Date(timeIntervalSince1970: 1234),
                Date(timeIntervalSince1970: 31415),
                Date(timeIntervalSince1970: 12345679)
            ]
        ]
        
        let rows: [SQLiteRow] = dates.map { dates in
            var row = SQLiteRow()
            row["key0"] = dates[0].sqliteValue
            row["key1"] = dates[1].sqliteValue
            row["key2"] = dates[2].sqliteValue
            return row
        }

        let decoded = try decoder.decode([[Date]].self, from: rows)
        
        XCTAssertEqual(decoded, dates)
    }
    
    func testDecodeRowArrayMissingRequiredField() {
        let decoder = RowDecoder(
            userInfo: [:],
            dateDecodingStrategy: .deferredToDate
        )
        
        var row = SQLiteRow()
        row["id"] = 1.sqliteValue
        
        XCTAssertThrowsError(
            try decoder.decode([SimpleModel].self, from: [row])
        ) { error in
            guard case DecodingError.keyNotFound = error else {
                return XCTFail("Expected DecodingError.keyNotFound, but got: \(error)")
            }
        }
    }
    
    func testDecodeRowArrayWrongType() {
        let decoder = RowDecoder(
            userInfo: [:],
            dateDecodingStrategy: .deferredToDate
        )
        
        var row = SQLiteRow()
        row["id"] = "not an int".sqliteValue
        row["name"] = "test".sqliteValue
        
        XCTAssertThrowsError(
            try decoder.decode([SimpleModel].self, from: [row])
        ) { error in
            guard case DecodingError.typeMismatch = error else {
                return XCTFail("Expected DecodingError.typeMismatch, but got: \(error)")
            }
        }
    }
}

private extension RowDecoderTests {
    enum `Type`: String, Decodable, Equatable {
        case simple
        case multiple
    }
    
    struct StandardModel: Decodable, Equatable {
        let id: Int
        let type: `Type`
        let name: String
        let age: Int
        let isActive: Bool
        let score: Double
        let createdAt: Date
        let payload: Data
    }
    
    struct OptionalModel: Decodable, Equatable {
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
    }
    
    struct SimpleModel: Decodable, Equatable {
        let id: Int
        let name: String
    }
}
