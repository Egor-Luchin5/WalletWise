//
//  TransactionViewController.swift
//  WalletWise
//
//  Created by Егор Лукин on 10.08.2024.
//

import UIKit
import RealmSwift

class TransactionViewController: UIViewController{
    
    //MARK: - Outlet's
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var noteTextField: UITextField!
    
    let realm = try! Realm()
    var categoryPickerString:String?
    var datePickerString:String?
    var selectedArray:[String] = ManagerAndModel.shared.expenseCategoryArray
    
    let normalAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
    let selectedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextField.delegate = self
        amountTextField.delegate = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self

        datePicker.locale = Locale(identifier: "ru_RU")
        
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.noteTextField.resignFirstResponder()
        self.amountTextField.resignFirstResponder()
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        guard let amountString = amountTextField.text, let amount = Double(amountString) else {return}
        
        let newTransaction = Transaction(value: [amount, segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? "", noteTextField.text ?? "без заметки", categoryPickerString ?? "---", datePickerString ?? formatDate(date: Date())])
        
        // Отправляем уведомление с транзакцией
        NotificationCenter.default.post(name: NSNotification.Name("TransactionAdded"), object: newTransaction)
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedArray = ManagerAndModel.shared.expenseCategoryArray
        case 1:
            selectedArray = ManagerAndModel.shared.incomeCategoryArray
        default:
            break
        }
        categoryPicker.reloadAllComponents()
        
    }
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        datePickerString = formatDate(date: datePicker.date)
    }
    
    func formatDate(date: Date) -> String {
            let today = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "d MMMM, yyyy"

            return dateFormatter.string(from: date)
        }
    
}

//MARK: -  Extensions
extension TransactionViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //        self.HideKeyBoard()
        noteTextField.becomeFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(HideKeyBoard))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleSpace, doneButton]
        textField.inputAccessoryView = toolbar
    }
    
    @objc func HideKeyBoard(){
        noteTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
    }
}

extension TransactionViewController:UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectedArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectedArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedItem = selectedArray[row]
        categoryPickerString = selectedItem
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = selectedArray[row]
        let attributedString = NSAttributedString(string: title, attributes: [
            .foregroundColor: UIColor.black
        ])
        return attributedString
    }
}

