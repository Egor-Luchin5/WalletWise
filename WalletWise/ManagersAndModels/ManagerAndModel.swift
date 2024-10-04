//
//  Category.swift
//  WalletWise
//
//  Created by Егор Лукин on 10.08.2024.
//

import Foundation
import RealmSwift

//MARK: - Модель транзакции
class Transaction: Object {
    @objc dynamic var amount:Double = 0.0
    @objc dynamic var type:String = ""
    @objc dynamic var note:String? = ""
    @objc dynamic var category:String = ""
    @objc dynamic var date: String = ""
}

class ManagerAndModel{
    static let shared = ManagerAndModel()
    private init(){}
    
    var currency = ["£","$","€","₸","₽","lei","¥"]
    
    var incomeCategoryArray: [String] {
        get {
            if let savedIncomesArray = UserDefaults.standard.stringArray(forKey: "IncomesArray") {
                return savedIncomesArray
            } else {
                return ["---","Девиденты","Заработная плата","Подработка","Подарки","Биржа","Аренда","Проценты по счётам","Социальный выплаты","Продажа","Инвестиции"]
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "IncomesArray")
        }
    }
    
    var expenseCategoryArray: [String] {
        get {
            if let savedexpenseArray = UserDefaults.standard.stringArray(forKey: "ExpenseArray") {
                return savedexpenseArray
            } else {
                return ["---","Автомобиль","Еда вне дома","Подарки","Здоровье","Банк","Квартира","Дом","Передвижение","Отдых и развлечения","Самообразование","Благотворительность","Кредит","Дети","Образование","Одежда и обувь","Услуги","Благотворительность","Государство","Домашние животные","Мобильная связь","Красота"]
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ExpenseArray")
        }
    }
    
}
//New user or not
final class Core {
    static let shared = Core()
    
    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setISNotUser(){
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
}

