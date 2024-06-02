//
//  CustomNavigationBar.swift
//  AccountBook
//
//  Created by 张艺怀 on 2024/6/2.
//

import SwiftUI

struct CustomNavigationBar: View {
    var username: String
    var icon: String
    var size: Double
    var addItem: () -> Void
    var body: some View {
        HStack {
            UserView(username: username, icon: icon, size: size)
            Spacer()
            HStack {
                Button(action: addItem) {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 25, height: 25)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        //.overlay(Divider(), alignment: .bottom)
    }
}

func addItem() {
    
}

#Preview {
    CustomNavigationBar(username: "Voltline", icon: "icon", size: 55, addItem: addItem)
}
