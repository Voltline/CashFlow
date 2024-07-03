//  AddRecordView.swift
//  AccountBook

import SwiftUI
import AudioToolbox

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
    @State private var positive: Bool = false
    @State private var isShowingNoZeroDialog = false;
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
                        .frame(height: geometry.size.height * 0.08)
                        Spacer()
                        HStack(spacing: 5) {
                            Image(systemName:"yensign")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(colorScheme != .dark ? .black : .white)
                            Text(String(accountBalance))
                                .font(.system(size: geometry.size.height * 0.08))
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
                    .onAppear {
                        if let firstCategory = cates.cate_dict.values.sorted(by: { $0.prio < $1.prio }).first {
                            selectedCategory = firstCategory.name
                            highlightCategory = firstCategory.name
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
                                presentationMode.wrappedValue.dismiss()
                            }
                        } label: {
                            Image(systemName:"checkmark")
                                .bold()
                                .font(.title2)
                                .frame(width: geometry.size.width * 0.03, height: geometry.size.width * 0.015)
                                .padding()
                        }
                        .alert("提示", isPresented: $isShowingNoZeroDialog) {
                            Button("好", role: .cancel) {}
                        } message: {
                            Text("金额不能为0")
                        }
                        .background(colorScheme != .dark ? Color(hex: "#B0B0B0", opacity: 0.2) : Color(hex: "#505050", opacity: 0.5))
                        .foregroundColor(.green)
                        .controlSize(.large)
                        .cornerRadius(30)
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
            AudioServicesPlaySystemSound(1519)
            let newItem = Record(context: viewContext)
            newItem.record_type = selectedCategory
            newItem.positive = positive
            newItem.record_date = Date()
            newItem.record_name = accountName == "" ? selectedCategory : accountName
            newItem.number = Double(accountBalance) ?? 0.0
            
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

#Preview {
    AddRecordView().environmentObject(Categories())
}
