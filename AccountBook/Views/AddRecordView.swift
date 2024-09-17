//  AddRecordView.swift
//  AccountBook

import ActivityKit
import SwiftUI
import AudioToolbox
import AlertToast
import AlertKit

struct AddRecordView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var cates: Categories
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedCategory: String = ""
    @State private var highlightCategory: String = ""
    @State private var accountName: String = ""
    @State private var accountBalance: String = "0"
    private var accountBalanceCount: Int {
        return accountBalance.count
    }
    private var fontSizeScale: CGFloat {
        return CGFloat(accountBalanceCount < 7 ? 1.0 : pow(0.93, CGFloat(accountBalanceCount) - 6))
    }
    @State private var positive: Bool = false
    @State private var isShowingNoZeroDialog = false;
    @Binding var refreshTrigger: Bool
    @State private var selectedDate = Date()
    @State private var newDate = Date()
    @State private var showCalenderSelect = false
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: geometry.size.height * 0.009) {
                    HStack(alignment: .center) {
                        //Spacer(minLength: geometry.size.width * 0.01)
                        Text("账目信息")
                            .font(.largeTitle)
                            .bold()
                        //Spacer(minLength: geometry.size.width * 0.58)
                    }
                    .padding(.leading, -geometry.size.width * 0.46)
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
                        .frame(height: max(geometry.size.height * 0.08, 55))
                        Spacer()
                        HStack(spacing: 5) {
                            Image(systemName:"yensign")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(colorScheme != .dark ? .black : .white)
                                .frame(height: max(geometry.size.height * 0.055, 36) * fontSizeScale)
                                
                            Text(accountBalance)
                                .font(.system(size: max(geometry.size.height * 0.08, 55) * fontSizeScale))
                                .foregroundColor(colorScheme != .dark ? .black : .white)
                        }
                        .frame(height: max(geometry.size.height * 0.05, 36))
                    }
                    .frame(height: max(geometry.size.height * 0.16, 115))
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .background(colorScheme != .dark ? Color(hex: "#E0E0E0", opacity: 1) : Color(hex: "#505050", opacity: 1))
                    HStack(alignment: .center) {
                        Text("类别")
                            .font(.title)
                    }
                    .padding(.leading, -geometry.size.width * 0.46)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center) {
                            Spacer()
                            ForEach(Array(cates.cate_dict.values.sorted(by: { $0.prio < $1.prio } ))) { cate in
                                CategoryView(name: cate.name, icon: cate.icon, isSelected: cate.name == highlightCategory, size: max(geometry.size.height * 0.08, 55))
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
                            Spacer(minLength: 10)
                        }
                    }
                    .padding(.vertical, 10)
                    .onAppear {
                        if let firstCategory = cates.cate_dict.values.sorted(by: { $0.prio < $1.prio }).first {
                            selectedCategory = firstCategory.name
                            highlightCategory = firstCategory.name
                        }
                    }
                    if !isTextFieldFocused {
                        Spacer()
                    }
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
                            NavigationView {
                                List {
                                    Section {
                                        HStack {
                                            Text("原始时间")
                                            Spacer()
                                            Text(dateFormatter.string(from: selectedDate))
                                                .foregroundStyle(Color.gray.opacity(0.5))
                                        }
                                        HStack {
                                            Text("调整后")
                                            Spacer()
                                            Text(dateFormatter.string(from: newDate))
                                        }
                                    } header: {
                                    } footer: {
                                    }
                            
                                    Section {
                                        DatePicker(" ", selection: $newDate, displayedComponents: [.date, .hourAndMinute])
                                            .datePickerStyle(GraphicalDatePickerStyle())
                                        Button() {
                                            AudioServicesPlaySystemSound(1519)
                                            newDate = selectedDate
                                        } label: {
                                            Text("还原为调整前")
                                                .foregroundStyle(Color.blue)
                                        }
                                        Button() {
                                            AudioServicesPlaySystemSound(1519)
                                            newDate = Date()
                                        } label: {
                                            Text("选择当前时间")
                                                .foregroundStyle(Color.blue)
                                        }
                                    } header: {
                                    } footer: {
                                    }
                                }
                                    .navigationBarItems(leading: Button("返回") {
                                        showCalenderSelect = false
                                    })
                                    .navigationBarItems(trailing: Button("调整") {
                                        selectedDate = newDate
                                        showCalenderSelect = false
                                    })
                                    .navigationBarTitle("修改日期与时间", displayMode: .inline)
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
                                //print(Double(accountBalance)!)
                                confirmButton()
                                AlertKitAPI.present(
                                    title: "添加成功",
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
                    if !isTextFieldFocused {
                        Spacer()
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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 HH:mm:ss"
        return formatter
    }
    
    private func confirmButton() {
        withAnimation {
            AudioServicesPlaySystemSound(1519)
            let newItem = Record(context: viewContext)
            newItem.record_type = selectedCategory
            newItem.positive = positive
            newItem.record_date = selectedDate
            newItem.record_name = accountName == "" ? selectedCategory : accountName
            newItem.number = Double(accountBalance) ?? 0.0
            
            do {
                try viewContext.save()
                refreshTrigger.toggle()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    @State var refreshTrigger: Bool = false
    AddRecordView(refreshTrigger: $refreshTrigger).environmentObject(Categories())
}
