//
//  CashFlowWidgetBundle.swift
//  CashFlowWidget
//
//  Created by Voltline on 2024/7/2.
//

import WidgetKit
import SwiftUI

@main
struct CashFlowWidgetBundle: WidgetBundle {
    var body: some Widget {
        CashFlowWidget()
        CashFlowWidgetControl()
        CashFlowWidgetLiveActivity()
    }
}
