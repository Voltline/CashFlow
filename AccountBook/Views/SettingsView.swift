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
    @State private var useNotification: Bool = UserDefaults.standard.bool(forKey: "UseNotification")
    @State private var notifyHour = UserDefaults.standard.integer(forKey: "NotificationHour")
    @State private var notifyMins = UserDefaults.standard.integer(forKey: "NotificationMins")
    @State private var useFaceID: Bool = UserDefaults.standard.bool(forKey: "UseFaceID")
    @State private var notificationTime = Date()
    @State private var showLicense = false
    @Binding var refreshTrigger: Bool
    @State var showMonthAlert: Bool = false
    @State var showYearAlert: Bool = false
    @State private var ui = UserDefaults.standard.integer(forKey: "DefaultView") == 1 ? "记录" : "主页"
    private let license = ""
    @State private var budget_text = ""
    @State private var lite_mainPage = UserDefaults.standard.bool(forKey: "UseLiteMainPage")
    @State private var useBlurEffect = UserDefaults.standard.bool(forKey: "LockScreenUseBlurEffect")
    @Binding var lockScreenTheme: Int
    @State private var themeDict = ["极光", "AI", "霓虹", "海洋", "冬日", "日出"]
    @State private var themes = [ColorfulPreset.aurora.colors, ColorfulPreset.appleIntelligence.colors, ColorfulPreset.neon.colors, ColorfulPreset.ocean.colors, ColorfulPreset.winter.colors, ColorfulPreset.sunrise.colors]
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
                            .onChange(of: useNotification) { newValue in
                                ToggleUseNotification(to: newValue)
                            }
                    }
                    DatePicker(
                        "选择推送时间",
                        selection: $notificationTime,
                        displayedComponents: [.hourAndMinute]
                    )
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
                } header: {
                } footer: {
                    Text("设置向您发送记账提醒的时间")
                }
                
                Section {
                    HStack {
                        Text("启用生物识别")
                        Spacer()
                        Toggle("", isOn: $useFaceID)
                            .onChange(of: useFaceID) { newValue in
                                useFaceID = newValue
                                UserDefaults.standard.setValue(newValue, forKey: "UseFaceID")
                            }
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
                            Text(String(UserDefaults.standard.integer(forKey: "MonthBudget")))
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
                            Text(String(UserDefaults.standard.integer(forKey: "YearBudget")))
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
                        Button(role: .cancel) {
                            showMonthAlert = false
                        } label: {
                            Text("取消")
                        }
                        Button() {
                            withAnimation {
                                if let new_budget = Double(budget_text) {
                                    UserDefaults.standard.setValue(new_budget, forKey: "MonthBudget")
                                }
                                else {
                                    UserDefaults.standard.setValue(3000, forKey: "MonthBudget")
                                }
                                refreshTrigger.toggle()
                                showMonthAlert = false
                            }
                        } label: {
                            Text("确认")
                        }
                    }
                    .alert("年度预算", isPresented: $showYearAlert) {
                        TextField("输入您的预算", text: $budget_text)
                        Button(role: .cancel) {
                            showYearAlert = false
                        } label: {
                            Text("取消")
                        }
                        Button() {
                            withAnimation {
                                if let new_budget = Double(budget_text) {
                                    UserDefaults.standard.setValue(new_budget, forKey: "YearBudget")
                                }
                                else {
                                    UserDefaults.standard.setValue(100000, forKey: "YearBudget")
                                }
                                refreshTrigger.toggle()
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
                                .onChange(of: lite_mainPage) { newValue in
                                    UserDefaults.standard.setValue(newValue, forKey: "UseLiteMainPage")
                                }
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
                            .onChange(of: useBlurEffect) { newValue in
                                UserDefaults.standard.setValue(newValue, forKey: "LockScreenUseBlurEffect")
                            }
                    }
                    HStack {
                        Text("动态锁定界面主题")
                        Spacer()
                        //lockscreenTheme
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
                .padding(.horizontal, 30)
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
        UserDefaults.standard.setValue(time.0, forKey: "NotificationHour")
        UserDefaults.standard.setValue(time.1, forKey: "NotificationMins")
        notify.scheduleDailyNotification(title: "该记账咯", body: "快来记录一下今天的开销吧", hour: time.0, minute: time.1)
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

struct AsyncTermsAndConditionsView: View {
    @State private var termsText = ""
    
    var body: some View {
        ScrollView {
            if termsText.isEmpty {
                ProgressView("加载中...")
                    .padding()
            } else {
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
        }
        .onAppear {
            loadTermsText()
        }
    }
    
    func loadTermsText() {
        DispatchQueue.global(qos: .userInitiated).async {
            let text = """
               TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

               1. Definitions.

                  "License" shall mean the terms and conditions for use, reproduction,
                  and distribution as defined by Sections 1 through 9 of this document.

                  "Licensor" shall mean the copyright owner or entity authorized by
                  the copyright owner that is granting the License.

                  "Legal Entity" shall mean the union of the acting entity and all
                  other entities that control, are controlled by, or are under common
                  control with that entity. For the purposes of this definition,
                  "control" means (i) the power, direct or indirect, to cause the
                  direction or management of such entity, whether by contract or
                  otherwise, or (ii) ownership of fifty percent (50%) or more of the
                  outstanding shares, or (iii) beneficial ownership of such entity.

                  "You" (or "Your") shall mean an individual or Legal Entity
                  exercising permissions granted by this License.

                  "Source" form shall mean the preferred form for making modifications,
                  including but not limited to software source code, documentation
                  source, and configuration files.

                  "Object" form shall mean any form resulting from mechanical
                  transformation or translation of a Source form, including but
                  not limited to compiled object code, generated documentation,
                  and conversions to other media types.

                  "Work" shall mean the work of authorship, whether in Source or
                  Object form, made available under the License, as indicated by a
                  copyright notice that is included in or attached to the work
                  (an example is provided in the Appendix below).

                  "Derivative Works" shall mean any work, whether in Source or Object
                  form, that is based on (or derived from) the Work and for which the
                  editorial revisions, annotations, elaborations, or other modifications
                  represent, as a whole, an original work of authorship. For the purposes
                  of this License, Derivative Works shall not include works that remain
                  separable from, or merely link (or bind by name) to the interfaces of,
                  the Work and Derivative Works thereof.

                  "Contribution" shall mean any work of authorship, including
                  the original version of the Work and any modifications or additions
                  to that Work or Derivative Works thereof, that is intentionally
                  submitted to Licensor for inclusion in the Work by the copyright owner
                  or by an individual or Legal Entity authorized to submit on behalf of
                  the copyright owner. For the purposes of this definition, "submitted"
                  means any form of electronic, verbal, or written communication sent
                  to the Licensor or its representatives, including but not limited to
                  communication on electronic mailing lists, source code control systems,
                  and issue tracking systems that are managed by, or on behalf of, the
                  Licensor for the purpose of discussing and improving the Work, but
                  excluding communication that is conspicuously marked or otherwise
                  designated in writing by the copyright owner as "Not a Contribution."

                  "Contributor" shall mean Licensor and any individual or Legal Entity
                  on behalf of whom a Contribution has been received by Licensor and
                  subsequently incorporated within the Work.

               2. Grant of Copyright License. Subject to the terms and conditions of
                  this License, each Contributor hereby grants to You a perpetual,
                  worldwide, non-exclusive, no-charge, royalty-free, irrevocable
                  copyright license to reproduce, prepare Derivative Works of,
                  publicly display, publicly perform, sublicense, and distribute the
                  Work and such Derivative Works in Source or Object form.

               3. Grant of Patent License. Subject to the terms and conditions of
                  this License, each Contributor hereby grants to You a perpetual,
                  worldwide, non-exclusive, no-charge, royalty-free, irrevocable
                  (except as stated in this section) patent license to make, have made,
                  use, offer to sell, sell, import, and otherwise transfer the Work,
                  where such license applies only to those patent claims licensable
                  by such Contributor that are necessarily infringed by their
                  Contribution(s) alone or by combination of their Contribution(s)
                  with the Work to which such Contribution(s) was submitted. If You
                  institute patent litigation against any entity (including a
                  cross-claim or counterclaim in a lawsuit) alleging that the Work
                  or a Contribution incorporated within the Work constitutes direct
                  or contributory patent infringement, then any patent licenses
                  granted to You under this License for that Work shall terminate
                  as of the date such litigation is filed.

               4. Redistribution. You may reproduce and distribute copies of the
                  Work or Derivative Works thereof in any medium, with or without
                  modifications, and in Source or Object form, provided that You
                  meet the following conditions:

                  (a) You must give any other recipients of the Work or
                      Derivative Works a copy of this License; and

                  (b) You must cause any modified files to carry prominent notices
                      stating that You changed the files; and

                  (c) You must retain, in the Source form of any Derivative Works
                      that You distribute, all copyright, patent, trademark, and
                      attribution notices from the Source form of the Work,
                      excluding those notices that do not pertain to any part of
                      the Derivative Works; and

                  (d) If the Work includes a "NOTICE" text file as part of its
                      distribution, then any Derivative Works that You distribute must
                      include a readable copy of the attribution notices contained
                      within such NOTICE file, excluding those notices that do not
                      pertain to any part of the Derivative Works, in at least one
                      of the following places: within a NOTICE text file distributed
                      as part of the Derivative Works; within the Source form or
                      documentation, if provided along with the Derivative Works; or,
                      within a display generated by the Derivative Works, if and
                      wherever such third-party notices normally appear. The contents
                      of the NOTICE file are for informational purposes only and
                      do not modify the License. You may add Your own attribution
                      notices within Derivative Works that You distribute, alongside
                      or as an addendum to the NOTICE text from the Work, provided
                      that such additional attribution notices cannot be construed
                      as modifying the License.

                  You may add Your own copyright statement to Your modifications and
                  may provide additional or different license terms and conditions
                  for use, reproduction, or distribution of Your modifications, or
                  for any such Derivative Works as a whole, provided Your use,
                  reproduction, and distribution of the Work otherwise complies with
                  the conditions stated in this License.

               5. Submission of Contributions. Unless You explicitly state otherwise,
                  any Contribution intentionally submitted for inclusion in the Work
                  by You to the Licensor shall be under the terms and conditions of
                  this License, without any additional terms or conditions.
                  Notwithstanding the above, nothing herein shall supersede or modify
                  the terms of any separate license agreement you may have executed
                  with Licensor regarding such Contributions.

               6. Trademarks. This License does not grant permission to use the trade
                  names, trademarks, service marks, or product names of the Licensor,
                  except as required for reasonable and customary use in describing the
                  origin of the Work and reproducing the content of the NOTICE file.

               7. Disclaimer of Warranty. Unless required by applicable law or
                  agreed to in writing, Licensor provides the Work (and each
                  Contributor provides its Contributions) on an "AS IS" BASIS,
                  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
                  implied, including, without limitation, any warranties or conditions
                  of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
                  PARTICULAR PURPOSE. You are solely responsible for determining the
                  appropriateness of using or redistributing the Work and assume any
                  risks associated with Your exercise of permissions under this License.

               8. Limitation of Liability. In no event and under no legal theory,
                  whether in tort (including negligence), contract, or otherwise,
                  unless required by applicable law (such as deliberate and grossly
                  negligent acts) or agreed to in writing, shall any Contributor be
                  liable to You for damages, including any direct, indirect, special,
                  incidental, or consequential damages of any character arising as a
                  result of this License or out of the use or inability to use the
                  Work (including but not limited to damages for loss of goodwill,
                  work stoppage, computer failure or malfunction, or any and all
                  other commercial damages or losses), even if such Contributor
                  has been advised of the possibility of such damages.

               9. Accepting Warranty or Additional Liability. While redistributing
                  the Work or Derivative Works thereof, You may choose to offer,
                  and charge a fee for, acceptance of support, warranty, indemnity,
                  or other liability obligations and/or rights consistent with this
                  License. However, in accepting such obligations, You may act only
                  on Your own behalf and on Your sole responsibility, not on behalf
                  of any other Contributor, and only if You agree to indemnify,
                  defend, and hold each Contributor harmless for any liability
                  incurred by, or claims asserted against, such Contributor by reason
                  of your accepting any such warranty or additional liability.
            """
            
            DispatchQueue.main.async {
                termsText = text
            }
        }
    }
}

#Preview {
    @State var refreshTrigger = false
    @State var lockScreenTheme = 0
    SettingsView(refreshTrigger: $refreshTrigger, lockScreenTheme: $lockScreenTheme)
}
