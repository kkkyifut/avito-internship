import Foundation

protocol EmployeesLoading {
    func loadEmployees(handler: @escaping (Result<Companies, Error>) -> Void)
}

struct EmployeesLoader: EmployeesLoading {
    private let networkClient = NetworkClient()
    private let stringURL = "https://run.mocky.io/v3/1d1cb4ec-73db-4762-8c4b-0b8aa3cecd4c"

    private enum DecodeError: Error {
        case codeError
    }
    
    private var employeesUrl: URL {
        guard let url = URL(string: stringURL) else {
            preconditionFailure("Unable to construct employeesUrl")
        }
        return url
    }
    
    func loadEmployees(handler: @escaping (Result<Companies, Error>) -> Void) {
        networkClient.fetch(url: employeesUrl) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let data):
                let companies = try? JSONDecoder().decode(Companies.self, from: data)
    
                if let companies = companies {
                    handler(.success(companies))
//                    cashService.saveData(companies: [companies.company])
                    print("Successed to parse")
                } else {
                    handler(.failure(DecodeError.codeError))
                    print("Failed to parse: \(DecodeError.codeError)")
                }
            }
        }
    }
}
