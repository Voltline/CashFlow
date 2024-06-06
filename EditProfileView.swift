//
//  EditProfileView.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/6.
//

import SwiftUI
import AudioToolbox

struct EditProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.colorScheme) var colorScheme
    @State private var newUsername: String = ""
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @Binding var refreshTrigger: Bool
    @State var isShowInfo: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    HStack(spacing: 3) {
                        Button() {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName:"arrow.backward")
                            Text("返回")
                        }
                        .foregroundStyle(Color.blue)
                        Spacer()
                    }
                    .padding(.top, geometry.size.height * 0.015)
                    .padding()
                    Button {
                        showImagePicker.toggle()
                    } label: {
                        if refreshTrigger {
                            CircularImageView(imageName: userProfile.icon, size: geometry.size.width * 0.5)
                        }
                        else {
                            CircularImageView(imageName: userProfile.icon, size: geometry.size.width * 0.5)
                        }
                    }
                    .alert("提示", isPresented: $isShowInfo) {
                        Button("好", role: .cancel) {}
                    } message: {
                        Text("头像更换后此处不会直接显示，退出后会立即更新")
                    }
                    Text("点击更换头像")
                    Spacer(minLength: geometry.size.height * 0.08)
                    Text(userProfile.username)
                        .font(.largeTitle)
                    HStack(spacing: 5) {
                        TextField("在此输入新用户名", text: $newUsername)
                            .padding()
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.title3)
                            .keyboardType(.default)
                            .textFieldStyle(.roundedBorder)
                        Button() {
                            AudioServicesPlaySystemSound(1519)
                            userProfile.updateUsername(newUsername.isEmpty ? userProfile.username : newUsername)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName:"checkmark")
                                .bold()
                                .font(.title2)
                                .frame(width: geometry.size.width * 0.03, height: geometry.size.width * 0.015)
                                .padding()
                        }
                        .background(colorScheme != .dark ? Color(hex: "#B0B0B0", opacity: 0.2) : Color(hex: "#505050", opacity: 0.5))
                        .foregroundColor(.green)
                        .controlSize(.large)
                        .cornerRadius(30)
                    }
                    .padding(.horizontal, geometry.size.width * 0.03)
                    Spacer(minLength: geometry.size.height * 0.4)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                saveImage(image: image)
                userProfile.updateIcon("custom_icon")
                isShowInfo.toggle()
            }
        }
    }
    
    private func saveImage(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        let filename = getDocumentsDirectory().appendingPathComponent("profile.png")
        try? data.write(to: filename)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

/*
#Preview {
    EditProfileView()
}
*/
