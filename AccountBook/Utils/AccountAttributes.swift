//
//  AccountAttributes.swift
//  AccountBook
//
//  Created by Voltline on 2024/9/15.
//

import Foundation
import ActivityKit

struct AccountAttributes: ActivityAttributes {
    public typealias AccountStatus = ContentState
    public struct ContentState: Codable, Hashable {
        var Outcome: Double
        var Income: Double
        var MonthlyBudget: Double
        var MonthlyOutcome: Double
    }
}
