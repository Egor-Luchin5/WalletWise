//
//  NumberFormatterManager.swift
//  WalletWise
//
//  Created by Егор Лукин on 11.08.2024.
//

import Foundation
class NumberFormatterManager {
    static let shared = NumberFormatterManager()
    private init(){}
    
    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}
