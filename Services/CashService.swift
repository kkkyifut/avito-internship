import Foundation

protocol CashService {
    func saveData(employees: [Employee]) -> Void
    func isCash() -> Bool
    var cash: [Employee] { get }
}

class CashServiceImplementation: CashService {
    private let userDefaults = UserDefaults.standard
    private let key = "savingData"
    var cash: [Employee] = []
    var view = ViewController()
    
    func isCash() -> Bool {
//        if userDefaults.array(forKey: key) == nil {
        if cash.isEmpty {
            return false
        } else {
            return true
        }
    }

    func saveData(employees: [Employee]) {
        cash = employees
        userDefaults.set(cash, forKey: key)
        savindData()
    }

    func savindData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.userDefaults.set(nil, forKey: self.key)
            self.cash.removeAll()
        }
    }
}
