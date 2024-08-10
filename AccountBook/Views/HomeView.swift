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
    @State private var showAlert: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                                    .edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
                    VStack(spacing: 20) {
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
                            if UIDevice.current.userInterfaceIdiom == .phone && showAlert {
                            }
                            else {
                                CategoryProportionView(width: geometry.size.width, height: geometry.size.height)
                                    .padding(.top, geometry.size.height * 0.01)
                            }
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
