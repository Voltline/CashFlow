//
//  SettingsView.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/3.
//

import SwiftUI
import MetalKit
import ColorfulX

struct SettingsView: View {
    @AppStorage("NotificationHour") private var notifyHour = 0
    @AppStorage("NotificationMins") private var notifyMins = 0
    @AppStorage("MonthBudget") private var MonthlyBudget = 3000.0
    @AppStorage("YearBudget") private var YearlyBudget = 100000.0
    @AppStorage("LockScreenTheme") private var lockScreenTheme = 0
    @AppStorage("UseFaceID") private var useFaceID: Bool = false
    @AppStorage("UseLiteMainPage") private var lite_mainPage = false
    @AppStorage("LockScreenUseBlurEffect") private var useBlurEffect = false
    @AppStorage("UseNotification") private var useNotification: Bool = false
    @State private var notificationTime = Date()
    @State private var showLicense = false
    @State private var showMonthAlert: Bool = false
    @State private var showYearAlert: Bool = false
    @State private var budget_text = ""
    @State private var themes = all_themes
    @State private var ui = UserDefaults.standard.integer(forKey: "DefaultView") == 1 ? "记录" : "主页"
    @State private var csvURL: URL?
    @State private var isShowFileImporter: Bool = false
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_date, ascending: true)],
        animation: .default)
    private var records: FetchedResults<Record>
    var body: some View {
        NavigationStack {
            HStack {
                Text("设置")
                    .font(.title3)
                    .bold()
            }
            .padding(.top, 8)
            Form {
                Section {
                    HStack {
                        Text("定时通知")
                        Spacer()
                        Toggle("", isOn: $useNotification)
                    }
                    DatePicker(
                        "选择推送时间",
                        selection: $notificationTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .onChange(of: notificationTime) { new in
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
                } header: {
                } footer: {
                    Text("设置向您发送记账提醒的时间")
                }
                
                Section {
                    HStack {
                        Text("启用生物识别")
                        Spacer()
                        Toggle("", isOn: $useFaceID)
                    }
                } header: {
                } footer: {
                    Text("设置是否启用生物识别解锁")
                }
                
                Section {
                    HStack {
                        Text("启动时默认转到")
                        Spacer()
                        Menu(ui) {
                            Button("主页", action: {
                                UserDefaults.standard.set(0, forKey: "DefaultView")
                                ui = "主页"
                            })
                            Button("记录", action: {
                                UserDefaults.standard.set(1, forKey: "DefaultView")
                                ui = "记录"
                            })

                        }
                    }
                } header: {
                } footer: {
                    Text("设置您启动时的默认界面")
                }
                
                Section {
                    HStack {
                        Text("月度预算")
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "yensign")
                                .font(.caption)
                            Text(String(format: "%.2f", MonthlyBudget))
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            budget_text = ""
                            showMonthAlert = true
                        }
                    }
                    
                    HStack {
                        Text("年度预算")
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "yensign")
                                .font(.caption)
                            Text(String(format: "%.2f", YearlyBudget))
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            budget_text = ""
                            showYearAlert = true
                        }
                    }
                    .alert("月度预算", isPresented: $showMonthAlert) {
                        TextField("输入您的预算", text: $budget_text)
                            .keyboardType(.decimalPad)
                        Button(role: .cancel) {
                            showMonthAlert = false
                        } label: {
                            Text("取消")
                        }
                        Button() {
                            withAnimation {
                                if let new_budget = Double(budget_text) {
                                    MonthlyBudget = new_budget
                                }
                                else {
                                    MonthlyBudget = 3000.0
                                }
                                showMonthAlert = false
                            }
                        } label: {
                            Text("确认")
                        }
                    }
                    .alert("年度预算", isPresented: $showYearAlert) {
                        TextField("输入您的预算", text: $budget_text)
                            .keyboardType(.decimalPad)
                        Button(role: .cancel) {
                            showYearAlert = false
                        } label: {
                            Text("取消")
                        }
                        Button() {
                            withAnimation {
                                if let new_budget = Double(budget_text) {
                                    YearlyBudget = new_budget
                                }
                                else {
                                    YearlyBudget = 100000.0
                                }
                                showYearAlert = false
                            }
                        } label: {
                            Text("确认")
                        }
                    }
                    
                } header: {
                } footer: {
                    Text("查看您当前的预算设置，点击预算数字可以设定预算额度")
                }
                
                if #available(iOS 17.0, *) {
                    Section {
                        HStack {
                            Text("使用简洁主页")
                            Spacer()
                            Toggle("", isOn: $lite_mainPage)
                        }
                    } header: {
                    } footer: {
                        Text("当您使用iOS 17及以上版本时，除了全功能主页外观，还可以使用简洁版外观")
                    }
                }
                
                Section {
                    HStack {
                        Text("验证按钮毛玻璃效果")
                        Spacer()
                        Toggle("", isOn: $useBlurEffect)
                    }
                    HStack {
                        Text("动态锁定界面主题")
                        Spacer()
                        Menu(themeDict[lockScreenTheme]) {
                            ForEach(themeDict.indices, id: \.self) { index in
                                Button(themeDict[index], action: {
                                    UserDefaults.standard.set(index, forKey: "LockScreenTheme")
                                    lockScreenTheme = index
                                })
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        ColorfulView(color: $themes[lockScreenTheme])
                            .frame(width: 330, height: 130)
                            .scaledToFit()

                        Spacer()
                    }
                } header: {
                } footer: {
                    Text("设置锁定界面的视觉效果")
                }
                
                Section {
                    ShareLink(item: exportCSV() ?? URL(filePath: "./")!) {
                        Text("导出为CSV文件")
                    }
                    Button {
                        isShowFileImporter.toggle()
                    } label: {
                        Text("导入文件")
                    }
                } header: {
                } footer: {
                    Text("导入账目的格式需要为：金额,日期,账目名称,类型，并且第一行会被忽略")
                }
                .fileImporter(isPresented: $isShowFileImporter, allowedContentTypes: [.data],
                              allowsMultipleSelection: false) { result in
                    readCSVFileToInsert(result: result, context: PersistenceController.shared.container.viewContext)
                }
                
                Section {
                    Button(action: {
                        showLicense = true
                    }) {
                        Text("开源许可证")
                            .foregroundColor(Color.blue)
                    }
                    Link(destination: URL(string: "https://github.com/Voltline/CashFlow")!) {
                            Text("GitHub页面")
                    }
                } header: {
                } footer: {
                    Text("CashFlow基于MIT协议开源")
                }
                
                Section {
                    Text("CashFlow版本: " + version)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .sheet(isPresented: $showLicense) {
                HStack {
                    Button(action: {
                        showLicense = false
                    }) {
                        Image(systemName: "chevron.left")
                        Text("返回")
                    }
                    .foregroundStyle(Color.blue)
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.leading, 20)
                AsyncTermsAndConditionsView()
                .padding(.top, 15)
                .padding(.bottom, 30)
            }
        }
    }
    
    private func createDateFormatter() -> DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        return dateformatter
    }
    
    private func getHoursAndMinsFromDate(from: Date) -> (Int, Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hour = Int(dateFormatter.string(from: from))
        dateFormatter.dateFormat = "mm"
        let mins = Int(dateFormatter.string(from: from))
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
        let time = getHoursAndMinsFromDate(from: notificationTime)
        notifyHour = time.0
        notifyMins = time.1
        notify.scheduleDailyNotification(title: "该记账咯", body: "快来记录一下今天的开销吧", hour: time.0, minute: time.1)
    }
    
    private func NotificationForAllow() {
        let time = createStringFromDate(date: notificationTime)
        let notify = NotificationHandler()
        notify.sendNotification(title: "记账提醒开启", body: "CashFlow会每天\(time)提醒您哦", uuid: UUID().uuidString, timeInterval: 30)
    }
    
    private func RemoveAllNotifications() {
        let notify = NotificationHandler()
        notify.cancelAllNotifications()
        UserDefaults.standard.setValue(false, forKey: "UseNotification")
        useNotification = false
    }
    
    private func ToggleUseNotification(to newValue: Bool) {
        UserDefaults.standard.setValue(newValue, forKey: "UseNotification")
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
    
    private func exportCSV() -> URL? {
        let csvString = generateCSVString(records: records)
        
        // 定义文件路径
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("expenses.csv")
        
        // 写入 CSV 文件
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("写入文件失败：\(error)")
            return nil
        }
    }
}

struct AsyncTermsAndConditionsView: View {
    @State private var termsText = ""
    
    var body: some View {
        ScrollView {
            if termsText.isEmpty {
                ProgressView("加载中...")
                    .padding()
            } else {
                VStack {
                    Text("Apache License")
                        .font(.headline)
                        .padding(.top, 10)
                    Text("Version 2.0, January 2004")
                        .font(.headline)
                    Text("http://www.apache.org/licenses/")
                        .font(.headline)
                    Text(termsText)
                        .font(.subheadline)
                }
                .padding(.horizontal, 30)
                HStack {
                    Spacer()
                }
            }
        }
        .onAppear {
            loadTermsText()
        }
    }
    
    func loadTermsText() {
        DispatchQueue.global(qos: .userInitiated).async {
            let text = license_text
            DispatchQueue.main.async {
                termsText = text
            }
        }
    }
}

#Preview {
    SettingsView()
}
