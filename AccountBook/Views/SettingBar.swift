//
//  SettingBar.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/3.
//

import SwiftUI

struct SettingBar: View {
    var body: some View {
        HStack {
            HStack {
                VStack {
                    Text("设置")
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.horizontal, 10)
                CircularImageView(imageName: "", size: 65, hasShadow: false)
            }
            .padding(.trailing, 10)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        //.overlay(Divider(), alignment: .bottom)
    }
}

#Preview {
    SettingBar()
}
