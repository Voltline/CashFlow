//
//  BudgetTotal.swift
//  AccountBook
//
//  Created by Voltline on 2024/10/22.
//

import Foundation
import SwiftUI

struct BudgetTotal: Identifiable {
    var id = UUID()
    var amount: Double
    var origin_amount: Double
    var color: Color
    var ratio: Double = 0
    var over: Bool = false
    
    var formattedAmount: String {
        String(format: "%.2f", amount)
    }
}
