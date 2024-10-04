//
//  SelectedTransactionViewController.swift
//  WalletWise
//
//  Created by Егор Лукин on 12.08.2024.
//

import UIKit

class SelectedTransactionViewController: UIViewController{
    @IBOutlet weak var amountOfransactionLabel: UILabel!
    @IBOutlet weak var viewFromLabelTypeView: UIView!
    @IBOutlet weak var dateTransactionLabel: UILabel!
    @IBOutlet weak var categoryTransactionLabel: UILabel!
    @IBOutlet weak var typeOfTransactionLabel: UILabel!
    @IBOutlet weak var noteTransactionTextView: UITextView!
    
    weak var transaction: Transaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAllDetailOfTransaction()
        noteTransactionTextView.isEditable = false
        
    }
    
    private func addAllDetailOfTransaction(){
        guard let transaction = transaction else {return}
        dateTransactionLabel.text = transaction.date
        categoryTransactionLabel.text = transaction.category
        viewFromLabelTypeView.alpha = 0.5
        noteTransactionTextView.text = transaction.note
        switch transaction.type {
        case "Расход":
            typeOfTransactionLabel.text = "Расход"
            viewFromLabelTypeView.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.7)
            amountOfransactionLabel.text = "-\(transaction.amount)"
        case "Доход":
            typeOfTransactionLabel.text = "Доход"
            viewFromLabelTypeView.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.7)
            amountOfransactionLabel.text = "\(transaction.amount)"
        default:
            break
        }
    }

    @IBAction func closeTransactionButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
