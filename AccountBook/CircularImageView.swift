//
//  CircularImageView.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/2.
//

import SwiftUI

struct CircularImageView: View {
    var imageName: String
    var size: Double
    var body: some View {
        if imageName == "custom_icon", let savedImage = loadImage() {
            Image(uiImage: savedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 1.5))
                .shadow(radius: 3)
        }
        else {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
                .shadow(radius: 1)
        }
    }
    
    private func loadImage() -> UIImage? {
        let filename = getDocumentsDirectory().appendingPathComponent("profile.png")
        if let data = try? Data(contentsOf: filename) {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

#Preview {
    CircularImageView(imageName: "icon", size: 100)
}
