//
//  UserView.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/2.
//

import SwiftUI

struct UserView: View {
    @State var username: String
    @State var icon: String
    @State var size: Double
    var body: some View {
        HStack {
            CircularImageView(imageName: icon, size: size)
            VStack {
                Text(username)
                    .font(.title2)
                    .bold()
            }
        }
        .padding(.trailing, 10)
    }
}

#Preview {
    UserView(username: "Voltline", icon: "icon", size: 50)
}
