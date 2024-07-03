//
//  HomeView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/3.
//

import SwiftUI
import Charts

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                                    .edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
                    VStack(spacing: 20) {
                        HStack {
                            Text("摘要")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .padding(.top, geometry.size.height * 0.04)
                        CategoryProportionView(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
