import Foundation

struct Authentication: Decodable {
    let userId: String
    let email: String
    let accessToken: String

    static func decode(_ data: Data) throws -> Authentication {
        let json = try data.asJson()
        return Authentication(
            userId: "",
            email: "",
            accessToken: ""
        )
    }
}