import UIKit

class ViewController: UIViewController {
    private var employeesLoader = EmployeesLoader()
    private var cashService: CashService?
    private var companies: [Сompany] = []
    var employees: [Employee] = []
    private enum EmployeesNotFound: Error {
        case codeError
    }
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var labelCompany: UILabel!
    
    @IBAction func loadNewData(_ sender: Any) {
        if (cashService?.isCash() == true) {
            employees = cashService!.cash
            print("старые данные")
        } else {
            loadData()
            print("новые данные")
        }
        sortingEmployees()
        labelCompany.text = companies[0].name
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func sortingEmployees() {
        employees = companies[0].employees
        employees = employees.sorted(by: { $0.name < $1.name })
        print(employees.map {$0.name})
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showLoadingIndicator(_ available: Bool) {
        activityIndicator.isHidden = !available
        available ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        let alertController = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)
        let confirmAction = UIAlertAction(
            title: "Повторить ещё раз", style: .default) { (action) in
                self.loadData()
            }
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func loadData() {
        showLoadingIndicator(true)
        employeesLoader.loadEmployees { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let companies):
                    if [companies.company].isEmpty {
                        self.didFailToLoadData(with: EmployeesNotFound.codeError)
                    } else {
                        self.companies = [companies.company]
                        self.cashService?.saveData(employees: self.employees)
                    }
                case .failure(let error):
                    self.didFailToLoadData(with: error)
                }
                self.showLoadingIndicator(false)
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.isEmpty ? 0 : employees.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "MyCell") {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "MyCell")
        }
        configure(cell: &cell, for: indexPath)
        return cell
    }

    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {

        if #available(iOS 14.0, *) {
            var configuration = cell.defaultContentConfiguration()
            configuration.text = "\(employees[indexPath.row].name)"
            var listOfSkills = "Phone:\t\(employees[indexPath.row].phone_number)\nSkills:\t"
            for skill in employees[indexPath.row].skills {
                listOfSkills += "\(skill), "
            }
            listOfSkills = listOfSkills.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
            configuration.secondaryText = listOfSkills
            cell.contentConfiguration = configuration
        } else {
            var listOfSkills = ""
            for skill in employees[indexPath.row].skills {
                listOfSkills += "\(skill), "
            }
            listOfSkills = listOfSkills.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
            cell.textLabel?.text = "\(employees[indexPath.row].name)\t (\(employees[indexPath.row].phone_number))"
            cell.detailTextLabel?.text = listOfSkills
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("Определяем доступные действия для строки с индексом \(indexPath.row)")
        let actionDelete = UIContextualAction(style: .destructive, title: "Удалить") { _,_,_ in
            self.employees.remove(at: indexPath.row)
            tableView.reloadData()
        }
        let actions = UISwipeActionsConfiguration(actions: [actionDelete])
        return actions
    }
}
