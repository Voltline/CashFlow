//
//  Expense.swift
//  AccountBook
//
//  Created by Voltline on 2024/10/22.
//

import SwiftUI

struct Expense: Identifiable {
    var id = UUID()
    var category: String
    var amount: Double
    var color: Color
    var ratio: Double = 0
    
    var formattedAmount: String {
        String(format: "%.2f", amount)
    }
}
