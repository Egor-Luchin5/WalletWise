//
//  ViewController.swift
//  WalletWise
//
//  Created by Егор Лукин on 10.08.2024.
//

import UIKit
import RealmSwift
import AVFoundation

class ViewController: UIViewController{
    //MARK: - Outlet's
    @IBOutlet weak var addTransactionButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceCountLabel: UILabel!
    @IBOutlet weak var middleconsumptionCountLabel: UILabel!
    @IBOutlet weak var expenseCountLabel: UILabel!
    @IBOutlet weak var incomeCountLabel: UILabel!

    let realm = try! Realm()
    lazy var generator = UIImpactFeedbackGenerator(style: .medium)
    
    //MARK: - Переменные
    private var totalExpense: Double = 0.0
    private var totalIncome:Double = 0.0
    private var totalBalance:Double = 0.0
    private var totalMiddle:Int = 0
    private var currency = "$"
    
    private var switchVibration = false
    
    var allTransactions:Results<Transaction>!
    var filteredTransactions:Results<Transaction>!
    
    private let normalAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
    private let selectedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
    
    //Проверка нового пользователя
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser(){
            let vc = storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 60, right: 16)
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        allTransactions = realm.objects(Transaction.self)
        filteredTransactions = allTransactions
        currency = UserDefaults.standard.string(forKey: "currency") ?? "$"
        
        switchVibration = UserDefaults.standard.bool(forKey: "SwitchIsOn")
        
        calculateTotals(for: allTransactions)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleTransaction), name: NSNotification.Name("TransactionAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(currency(_:)), name: NSNotification.Name("Currency"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchVibration(_:)), name: NSNotification.Name("SwitchIsOn"), object: nil)
    }

    //функция для добавления новой транзакции
    @objc func handleTransaction(_ notification: Notification) {
        guard let newTransaction = notification.object as? Transaction else {return}
        try! self.realm.write({
            realm.add(newTransaction)
        })
        
        tableView.reloadData()
        calculateTotals(for: allTransactions)
    }
    
    //функция для вибрации
    @objc func switchVibration(_ notification: Notification) {
        switchVibration = notification.object as! Bool
        UserDefaults.standard.set(switchVibration, forKey: "SwitchIsOn")
    }
    
    //функция для валюты
    @objc func currency(_ notification: Notification) {
        currency = notification.object as! String
        UserDefaults.standard.set(currency, forKey: "currency")
        tableView.reloadData()
        calculateTotals(for: allTransactions)
    }
    
    //MARK: - @IBActions
    @IBAction func segmentControllValueChanged(_ sender: UISegmentedControl) {
        filterTransactions()
        calculateTotals(for: allTransactions)
        checkSwitchOn()
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        guard let settingController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController else {return}
        checkSwitchOn()
        settingController.modalPresentationStyle = .fullScreen
        self.present(settingController, animated: true)
    }
    
    @IBAction func addTransactionButtonPressed(_ sender: UIButton) {
        guard let transactionController = self.storyboard?.instantiateViewController(withIdentifier: "TransactionViewController") as? TransactionViewController else {return}
        
        checkSwitchOn()
        
        UIView.animate(withDuration: 0.2) {
            self.addTransactionButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.addTransactionButton.transform = .identity
                self.present(transactionController, animated: true)
                
            }
        }
        
//        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
//        scaleAnimation.fromValue = 1.0
//        scaleAnimation.toValue = 0.5 //0.9
//        scaleAnimation.duration
//        = 0.2
//        scaleAnimation.autoreverses = true
//        
//        self.present(transactionController, animated: true)
//        addTransactionButton.layer.add(scaleAnimation, forKey: nil)


    }
    
    
    
    //MARK: - Functions
    
    private func calculateTotals(for transactions: Results<Transaction>) {
        totalExpense = 0
        totalIncome = 0
        totalBalance = 0
        totalMiddle = 0
        var expensecount = 0
        for transaction in allTransactions {
            if transaction.type == "Расход" {
                totalExpense += transaction.amount
                expensecount += 1
            } else if transaction.type == "Доход" {
                totalIncome += transaction.amount
            }
        }
        
        totalMiddle = Int(totalExpense > 0 ? totalExpense / Double(expensecount) : 0)
        totalBalance = totalIncome - totalExpense
        
        middleconsumptionCountLabel.text = "\(NumberFormatterManager.shared.formatNumber(Double(totalMiddle))) \(currency)"
        
        balanceCountLabel.text = "\(NumberFormatterManager.shared.formatNumber(totalBalance)) \(currency)"
        
        incomeCountLabel.text = "\(NumberFormatterManager.shared.formatNumber(totalIncome)) \(currency)"
        
        if totalExpense == 0 {
            expenseCountLabel.text = "\(NumberFormatterManager.shared.formatNumber(totalExpense)) \(currency)"
        }else {
            expenseCountLabel.text = "-\(NumberFormatterManager.shared.formatNumber(totalExpense)) \(currency)"
        }

    }
    
    private func filterTransactions() {
      switch segmentedControl.selectedSegmentIndex {
      case 0: // Все
        filteredTransactions = allTransactions
      case 1: // Расходы
          filteredTransactions = realm.objects(Transaction.self).filter("type == 'Расход'")
      case 2: // Доходы
        filteredTransactions = realm.objects(Transaction.self).filter("type == 'Доход'")
      default:
        filteredTransactions = allTransactions
      }
      tableView.reloadData()
    }
    
    private func checkSwitchOn(){
        if switchVibration == true {
            generator.impactOccurred(intensity: 100)
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        guard let transaction = filteredTransactions?[indexPath.row] else { return cell }
        
        cell.amountLabelCell.text = "\(transaction.amount) \(currency)"
        cell.categoryLabelCell.text = transaction.category
        
        switch transaction.type {
        case "Расход":
            cell.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
        case "Доход":
            cell.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 0.1)
        default:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction
        = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return}
            let transaction = self.realm.objects(Transaction.self)[indexPath.row]
            
            do {
                try self.realm.write {
                    self.realm.delete(transaction)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                checkSwitchOn()
                calculateTotals(for: allTransactions)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedTransactionController = self.storyboard?.instantiateViewController(withIdentifier: "SelectedTransactionViewController") as? SelectedTransactionViewController else {return}
        tableView.deselectRow(at: indexPath, animated: true)
        selectedTransactionController.transaction = filteredTransactions?[indexPath.row]
        
        if let sheet = selectedTransactionController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 40
        }
        present(selectedTransactionController, animated: true)
        
    }
}
