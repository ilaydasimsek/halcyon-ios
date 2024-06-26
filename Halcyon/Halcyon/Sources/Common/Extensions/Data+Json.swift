import SwiftyJSON
import Foundation

protocol Decodable {

    static func decodeFromJson(_ json: JSON) throws -> Self
}

extension Data {

    @discardableResult
    func asJson() throws -> JSON {
        guard let json = try? JSON(data: self) else {
            throw RequestError.decodeError
        }
        return json
    }
}
