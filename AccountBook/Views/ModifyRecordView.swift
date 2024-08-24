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
    @FocusState private var isTextFieldFocused: Bool
    @ObservedObject var in_record: Record
    @State private var selectedCategory: String
    @State private var highlightCategory: String
    @State private var accountName: String
    @State private var accountBalance: String
    private var accountBalanceCount: Int {
        return accountBalance.count
    }
    private var fontSizeScale: CGFloat {
        return CGFloat(accountBalanceCount < 7 ? 1.0 : pow(0.93, CGFloat(accountBalanceCount) - 6))
    }
    @State private var positive: Bool
    @State private var isShowingNoZeroDialog = false;
    
    init(record: Record) {
        in_record = record
        selectedCategory = record.record_type!
        highlightCategory = record.record_type!
        accountName = record.record_name!
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
                VStack(spacing: geometry.size.height * 0.009) {
                    HStack(alignment: .center) {
                        //Spacer(minLength: geometry.size.width * 0.01)
                        Text("修改账目信息")
                            .font(.largeTitle)
                            .bold()
                        //Spacer(minLength: geometry.size.width * 0.58)
                    }
                    .padding(.leading, -geometry.size.width * 0.38)
                    .padding(.top, geometry.size.height * 0.02)
                    HStack {
                        VStack(spacing: 10) {
                            Image(systemName: "dollarsign.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(colorScheme != .dark ? .black : .white)
                            Text("现金")
                                .foregroundColor(colorScheme != .dark ? .black : .white)
                        }
                        .frame(height: geometry.size.height * 0.08)
                        Spacer()
                        HStack(spacing: 5) {
                            Image(systemName:"yensign")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(colorScheme != .dark ? .black : .white)
                                .frame(height: geometry.size.height * 0.055 * fontSizeScale)
                                
                            Text(accountBalance)
                                .font(.system(size: geometry.size.height * 0.08 * fontSizeScale))
                                .foregroundColor(colorScheme != .dark ? .black : .white)
                        }
                        .frame(height: geometry.size.height * 0.05)
                    }
                    .frame(height: geometry.size.height * 0.16)
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .background(colorScheme != .dark ? Color(hex: "#E0E0E0", opacity: 1) : Color(hex: "#505050", opacity: 1))
                    HStack(alignment: .center) {
                        //Spacer(minLength: geometry.size.width * 0.05)
                        Text("类别")
                            .font(.title)
                        //Spacer(minLength: geometry.size.width * 0.8)
                    }
                    .padding(.leading, -geometry.size.width * 0.46)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center) {
                            Spacer()
                            ForEach(Array(cates.cate_dict.values.sorted(by: { $0.prio < $1.prio } ))) { cate in
                                CategoryView(name: cate.name, icon: cate.icon, isSelected: cate.name == highlightCategory, size: geometry.size.height * 0.08)
                                    .environmentObject(cates)
                                    .onTapGesture {
                                        AudioServicesPlaySystemSound(1519)
                                        withAnimation(.spring(duration: 0.15)) {
                                            selectedCategory = cate.name
                                            highlightCategory = cate.name
                                            positive = cate.positive
                                            // print("Selected category: \(selectedCategory)")
                                        }
                                    }
                                //.hoverEffect(.automatic)
                            }
                            Spacer(minLength: 10)
                            //CustomNumberPad(value: $accountBalance)
                        }
                    }
                    Spacer()
                    HStack(spacing: 10) {
                        Image(systemName: "wallet.pass")
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
                                //print(Double(accountBalance)!)
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
                        /*
                        .alert("提示", isPresented: $isShowingNoZeroDialog) {
                            Button("好", role: .cancel) {}
                        } message: {
                            Text("金额不能为0")
                        }
                         */
                        .background(colorScheme != .dark ? Color(hex: "#B0B0B0", opacity: 0.2) : Color(hex: "#505050", opacity: 0.5))
                        .foregroundColor(.green)
                        .controlSize(.large)
                        .cornerRadius(30)
                    }
                    .toast(isPresenting: $isShowingNoZeroDialog, duration: 1.6) {
                        AlertToast(displayMode: .hud, type: .error(Color.red), title: "错误", subTitle: "金额不能为0")
                    }
                    .padding(.horizontal, geometry.size.width * 0.03)
                    Spacer()
                    if !isTextFieldFocused {
                        CustomNumberPad(value: $accountBalance, width: geometry.size.width * 0.28, height: geometry.size.height * 0.075)
                            .transition(.opacity)
                            .animation(.default, value: isTextFieldFocused)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                        Text("返回")
                    }
                }
            }
        }
    }
    
    private func confirmButton() {
        withAnimation { 
            // TODO:暂时没有解决同步问题，因此此时采取先删后加的策略
            // TODO:为了避免忘了，问题是：这里直接通过in_record.修改属性之后，数据库内变更了，但是外面的List没有触发刷新，等重新启动后才触发
            AudioServicesPlaySystemSound(1519)// Modified
            let modifiedItem = Record(context: viewContext)
            modifiedItem.record_type = selectedCategory
            modifiedItem.positive = positive
            modifiedItem.record_date = in_record.record_date
            modifiedItem.record_name = accountName == "" ? selectedCategory : accountName
            modifiedItem.number = Double(accountBalance) ?? 0.0
            viewContext.delete(in_record)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
/*
#Preview {
    ModifyRecordView(record: Record()).environmentObject(Categories())
}
*/
