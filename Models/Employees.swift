import Foundation

struct Companies: Codable {
    let company: Сompany
}

struct Сompany: Codable {
    let name: String
    let employees: [Employee]
}

struct Employee: Codable {
    let name: String
    let phone_number: String
    let skills: [String]
}
