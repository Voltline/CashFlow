//
//  PrimaryButtonView.swift
//  AccountBook
//
//  Created by Voltline on 2024/10/22.
//

import SwiftUI

struct PrimaryButton: View {
    var image: String?
    var showImage = true
    var text: String
    @State private var backgroundState: ColorScheme = .dark
    @State var useBlurEffect = UserDefaults.standard.bool(forKey: "LockScreenUseBlurEffect")
    
    var body: some View {
        if useBlurEffect {
            ZStack {
                // 胶囊形状背景
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: 200, height: 50)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                // HStack内容
                HStack {
                    if showImage {
                        Image(systemName: image ?? "person.fill")
                    }
                    Text(text)
                }
                .foregroundStyle(Color.white)
                .padding()
                .padding(.horizontal)
            }
            .environment(\.colorScheme, backgroundState)
            .background(Color.clear)
            .padding(.horizontal) // 可选的整体布局调整
        }
        else {
            HStack {
                if showImage {
                    Image(systemName: image ?? "person.fill")
                }
                Text(text)
            }
            .padding()
            .padding(.horizontal)
            .background(.white)
            .cornerRadius(30)
            .shadow(radius: 10)
        }
    }
}
