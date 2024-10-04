//
//  ManageCategoryViewController.swift
//  WalletWise
//
//  Created by Егор Лукин on 23.08.2024.
//

import UIKit

class ManageCategoryViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var filteredArrayOfCategories:[String] = ManagerAndModel.shared.expenseCategoryArray
    private let normalAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
    private let selectedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        
    }
    @IBAction func closeAndSaveCategoryButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        filteredCategories()
        
    }
    @IBAction func AddNewCategory(_ sender: UIButton) {
        addAlert()
    }
    
    private func filteredCategories(){
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            filteredArrayOfCategories = ManagerAndModel.shared.expenseCategoryArray
        case 1:
            filteredArrayOfCategories = ManagerAndModel.shared.incomeCategoryArray
        default:
            break
        }
        tableView.reloadData()
    }
    
    //MARK: - Alert
    private func addAlert(){
        let alert = UIAlertController(title: "Добавить", message: "новую категорию", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Введите"
        }

        let OkAlertButton = UIAlertAction(title: "Добавить", style: .default) { _ in
            let textField = alert.textFields![0] as UITextField
            if self.segmentedControl.selectedSegmentIndex == 0 {
                ManagerAndModel.shared.expenseCategoryArray.insert(textField.text ?? "", at: 1)
                self.filteredArrayOfCategories = ManagerAndModel.shared.expenseCategoryArray
            }else if self.segmentedControl.selectedSegmentIndex == 1 {
                ManagerAndModel.shared.incomeCategoryArray.insert(textField.text ?? "", at: 1)
                self.filteredArrayOfCategories = ManagerAndModel.shared.incomeCategoryArray
            }
            
            self.tableView.reloadData()
        }

        let cancelButton = UIAlertAction(title: "Назад", style: .cancel) { _ in
            print("Cancel")
        }
        alert.addAction(OkAlertButton)
        alert.addAction(cancelButton)

        present(alert, animated: true, completion: nil)
    }
    
}

extension ManageCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArrayOfCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableViewCell", for: indexPath) as! CategoriesTableViewCell
        cell.CategoryLabelCell.text = filteredArrayOfCategories[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction
        = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return}
            do {
                if segmentedControl.selectedSegmentIndex == 0 {
                    filteredArrayOfCategories.remove(at: indexPath.row)
                    ManagerAndModel.shared.expenseCategoryArray.remove(at: indexPath.row)
                }else if segmentedControl.selectedSegmentIndex == 1 {
                    filteredArrayOfCategories.remove(at: indexPath.row)
                    ManagerAndModel.shared.incomeCategoryArray.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            } catch {
                // Обработка ошибки
                print("Ошибка при удалении записи: \(error)")
                completionHandler(false)
            }
        }
        
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash.fill")
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
        
    }
}
