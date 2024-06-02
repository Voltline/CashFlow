//
//  CircularImageView.swift
//  AccountBook
//
//  Created by 张艺怀 on 2024/6/2.
//

import SwiftUI

struct CircularImageView: View {
    var imageName: String
    var size: Double
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.clear, lineWidth: 1))
            .shadow(radius: 2)
    }
}

#Preview {
    CircularImageView(imageName: "icon", size: 100)
}
