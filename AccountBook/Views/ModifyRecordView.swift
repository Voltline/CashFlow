//
//  ModifyRecordView.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/6.
//

import SwiftUI
import AudioToolbox
import AlertToast
import AlertKit

struct ModifyRecordView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var cates: Categories
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var newDate: Date
    @State private var positive: Bool
    @State private var selectedDate: Date
    @State private var accountName: String
    @State private var accountBalance: String
    @State private var selectedCategory: String
    @State private var highlightCategory: String
    @State private var showCalenderSelect = false
    @State private var isShowingNoZeroDialog = false;
    @FocusState private var isTextFieldFocused: Bool
    @Binding var refreshTrigger: Bool
    @ObservedObject var in_record: Record
    private var accountBalanceCount: Int {
        return accountBalance.count
    }
    private var fontSizeScale: CGFloat {
        return CGFloat(accountBalanceCount < 7 ? 1.0 : pow(0.93, CGFloat(accountBalanceCount) - 6))
    }
    init(record: Record, refreshTrigger: Binding<Bool>) {
        self._refreshTrigger = refreshTrigger
        in_record = record
        selectedCategory = record.record_type!
        highlightCategory = record.record_type!
        accountName = record.record_name!
        selectedDate = record.record_date!
        newDate = record.record_date!
        let tmp_num = String(record.number)
        if tmp_num.contains(".") {
            let str_arr = tmp_num.split(separator: ".")
            if Int(str_arr[1]) == 0 {
                accountBalance = String(str_arr[0])
            }
            else {
                accountBalance = tmp_num
            }
        }
        else {
            accountBalance = tmp_num
        }
        positive = record.positive
    }
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: geometry.size.height * 0.009) {
                        HStack(alignment: .center) {
                            Text("修改账目信息")
                                .font(.largeTitle)
                                .bold()
                        }
                        .padding()
                        HStack {
                            VStack(spacing: 10) {
                                Image(systemName: "dollarsign.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(colorScheme != .dark ? .black : .white)
                                Text("现金")
                                    .foregroundColor(colorScheme != .dark ? .black : .white)
                            }
                            
                            .frame(height: 70)
                            Spacer()
                            HStack(spacing: 5) {
                                Image(systemName:"yensign")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(colorScheme != .dark ? .black : .white)
                                    .frame(height: 38 * fontSizeScale)
                                    
                                Text(accountBalance)
                                    .font(.system(size: 65 * fontSizeScale))
                                    .foregroundColor(colorScheme != .dark ? .black : .white)
                            }
                            .frame(height: max(geometry.size.height * 0.05, 36))
                        }
                        .frame(height: 130)
                        .padding(.horizontal)
                        .background(colorScheme != .dark ? Color(hex: "#E0E0E0", opacity: 1) : Color(hex: "#505050", opacity: 1))
                        HStack(alignment: .center) {
                            Text("类别")
                                .font(.title)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .center, spacing: 5) {
                                //Spacer()
                                ForEach(Array(cates.cate_dict.values.sorted(by: { $0.prio < $1.prio } ))) { cate in
                                    CategoryView(name: cate.name, icon: cate.icon, isSelected: cate.name == highlightCategory, size: 70)
                                        .environmentObject(cates)
                                        .onTapGesture {
                                            AudioServicesPlaySystemSound(1519)
                                            withAnimation(.spring(duration: 0.15)) {
                                                selectedCategory = cate.name
                                                highlightCategory = cate.name
                                                positive = cate.positive
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 20)
                        HStack(spacing: 10) {
                            Button() {
                                AudioServicesPlaySystemSound(1519)
                                showCalenderSelect.toggle()
                            } label: {
                                Image(systemName:"calendar")
                                    .bold()
                                    .font(.title2)
                                    .frame(width: geometry.size.width * 0.03, height: geometry.size.width * 0.015)
                                    .padding()
                            }
                            .background(colorScheme != .dark ? Color(hex: "#B0B0B0", opacity: 0.2) : Color(hex: "#505050", opacity: 0.5))
                            .foregroundColor(.blue)
                            .controlSize(.large)
                            .cornerRadius(15)
                            .popover(isPresented: $showCalenderSelect) {
                                CalenderModifyView(selectedDate: $selectedDate, newDate: $newDate) {
                                    showCalenderSelect = false
                                }
                            }
                            TextField("例如:公交", text: $accountName)
                                .focused($isTextFieldFocused)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .font(.title3)
                                .keyboardType(.default)
                                .textFieldStyle(.roundedBorder)
                            Button() {
                                AudioServicesPlaySystemSound(1519)
                                if Double(accountBalance) == 0 {
                                    isShowingNoZeroDialog.toggle()
                                }
                                else {
                                    confirmButton()
                                    AlertKitAPI.present(
                                        title: "修改成功",
                                        icon: .done,
                                        style: .iOS17AppleMusic,
                                        haptic: .success
                                    )
                                    presentationMode.wrappedValue.dismiss()
                                }
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
                            .cornerRadius(15)
                        }
                        .toast(isPresenting: $isShowingNoZeroDialog, duration: 1.6) {
                            AlertToast(displayMode: .hud, type: .error(Color.red), title: "错误", subTitle: "金额不能为0")
                        }
                        .padding(.horizontal, geometry.size.width * 0.03)
                        Spacer()
                        if !isTextFieldFocused {
                            CustomNumberPad(value: $accountBalance)
                                .frame(height: geometry.size.height * 0.35)
                                .transition(.opacity)
                                .animation(.default, value: isTextFieldFocused)
                        }
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 HH:mm:ss"
        return formatter
    }
    
    private func confirmButton() {
        withAnimation { 
            // TODO:暂时没有解决同步问题，因此此时采取先删后加的策略
            // TODO:为了避免忘了，问题是：这里直接通过in_record.修改属性之后，数据库内变更了，但是外面的List没有触发刷新，等重新启动后才触发
            AudioServicesPlaySystemSound(1519)// Modified
            let modifiedItem = Record(context: viewContext)
            modifiedItem.record_type = selectedCategory
            modifiedItem.positive = positive
            modifiedItem.record_date = selectedDate
            modifiedItem.record_name = accountName == "" ? selectedCategory : accountName
            modifiedItem.number = Double(accountBalance) ?? 0.0
            viewContext.delete(in_record)
            
            do {
                try viewContext.save()
                refreshTrigger.toggle()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
