//
//  EditProfileView.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/6.
//

import SwiftUI
import AudioToolbox
import UserNotifications

struct EditProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.colorScheme) var colorScheme
    @State private var newUsername: String = ""
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @Binding var refreshTrigger: Bool
    @State var isShowInfo: Bool = false
    @State private var useNotification: Bool = UserDefaults.standard.bool(forKey: "UseNotification")
    @State private var notifyHour = UserDefaults.standard.integer(forKey: "NotificationHour")
    @State private var notifyMins = UserDefaults.standard.integer(forKey: "NotificationMins")
    @State private var notificationTime = Date()
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    HStack(spacing: 3) {
                        Button() {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName:"chevron.left")
                                Text("返回")
                            }
                        }
                        .foregroundStyle(Color.blue)
                        Spacer()
                    }
                    .padding(.top, geometry.size.height * 0.015)
                    .padding()
                    VStack {
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
                    }
                    Divider()
                    VStack {
                        HStack {
                            Text("定时通知")
                                .font(.title2)
                            Spacer()
                            Toggle("", isOn: $useNotification)
                                .onChange(of: useNotification) { newValue in
                                    ToggleUseNotification(to: newValue)
                                }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                        DatePicker(
                            "选择推送时间",
                            selection: $notificationTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .onChange(of: notificationTime) { new in
                            let useNotification = UserDefaults.standard.bool(forKey: "UseNotification")
                            let hasNotification = UserDefaults.standard.bool(forKey: "HasNotification")
                            if useNotification && hasNotification {
                                setNotificationTime()
                            }
                        }
                        .onAppear() {
                            notificationTime = createDateFromString(dateString: "\(notifyHour):\(notifyMins)")
                        }
                        Button(action: RemoveAllNotifications) {
                            Text("移除所有提醒")
                                .bold()
                                .foregroundColor(Color.red)
                        }
                    }
                    .padding(.vertical, geometry.size.height * 0.01)
                    /*.padding(.horizontal, geometry.size.width * 0.025)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray, lineWidth: 1)
                            .padding(.horizontal, geometry.size.width * 0.02)
                    )*/
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
    
    private func createDateFormatter() -> DateFormatter {
        var dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        return dateformatter
    }
    
    private func getHoursAndMinsFromDate(from: Date) -> (Int, Int) {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        var hour = Int(dateFormatter.string(from: from))
        dateFormatter.dateFormat = "mm"
        var mins = Int(dateFormatter.string(from: from))
        return (hour ?? 16, mins ?? 0)
    }
    
    private func createDateFromString(dateString: String) -> Date {
        let dateFormatter = createDateFormatter()
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    private func createStringFromDate(date: Date) -> String {
        let dateFormatter = createDateFormatter()
        return dateFormatter.string(from: date)
    }
    
    private func setNotificationTime() {
        let notify = NotificationHandler()
        notify.cancelAllNotifications()
        var time = getHoursAndMinsFromDate(from: notificationTime)
        UserDefaults.standard.setValue(time.0, forKey: "NotificationHour")
        UserDefaults.standard.setValue(time.1, forKey: "NotificationMins")
        notify.scheduleDailyNotification(title: "该记账咯", body: "快来记录一下今天的开销吧", hour: time.0, minute: time.1)
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
    
    private func NotificationForAllow() {
        let time = createStringFromDate(date: notificationTime)
        let notify = NotificationHandler()
        notify.sendNotification(title: "记账提醒开启", body: "CashFlow会每天\(time)提醒您哦", uuid: UUID().uuidString, timeInterval: 5)
    }
    
    private func RemoveAllNotifications() {
        let notify = NotificationHandler()
        notify.cancelAllNotifications()
        UserDefaults.standard.setValue(false, forKey: "UseNotification")
        useNotification = false
    }
    
    private func ToggleUseNotification(to newValue: Bool) {
        UserDefaults.standard.setValue(newValue, forKey: "UseNotification")
        // print("点击Toggle按钮")
        if !newValue {
            self.RemoveAllNotifications()
        }
        let useNotification = UserDefaults.standard.bool(forKey: "UseNotification")
        let hasNotification = UserDefaults.standard.bool(forKey: "HasNotification")
        if useNotification && hasNotification {
            NotificationForAllow()
            setNotificationTime()
        }
    }
}

/*
#Preview {
    EditProfileView()
}
*/
