//
//  HomeView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/3.
//

import SwiftUI
import Charts

struct HomeView: View {
    @Binding var refreshTrigger: Bool
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                                    .edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
                    VStack(spacing: 10) {
                        ScrollView {
                            HStack {
                                Text("")
                                    .font(.largeTitle)
                                    .bold()
                                Spacer()
                            }
                            .padding(.horizontal, geometry.size.width * 0.032)
                            HStack(spacing: geometry.size.width * 0.015) {
                                if refreshTrigger {
                                    BudgetView(width: geometry.size.width, height: geometry.size.height, month: false)
                                    BudgetView(width: geometry.size.width, height: geometry.size.height)
                                }
                                else {
                                    BudgetView(width: geometry.size.width, height: geometry.size.height, month: false)
                                    BudgetView(width: geometry.size.width, height: geometry.size.height)
                                }
                            }
                            CategoryProportionView(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                    .padding(.vertical, geometry.size.height * 0.01)
                }
            }
        }
    }
}

#Preview {
    @State var refreshTrigger = false
    HomeView(refreshTrigger: $refreshTrigger)
}
