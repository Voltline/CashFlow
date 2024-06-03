//  AddRecordView.swift
//  AccountBook

import SwiftUI
import AudioToolbox

struct AddRecordView: View {
    @EnvironmentObject var cates: Categories
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory: String = ""
    @State private var highlightCategory: String = ""
    @State private var accountName: String = ""
    @State private var accountBalance: String = "0"
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                HStack(alignment: .center) {
                    Spacer(minLength: 10)
                    Text("账目信息")
                        .font(.largeTitle)
                        .bold()
                    Spacer(minLength: 228)
                }.padding(.top, 20)
                HStack {
                    VStack(spacing: 10) {
                        Image(systemName: "dollarsign.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Text("现金")
                    }
                    .frame(height:60)
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName:"yensign")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Text(String(accountBalance))
                        //.font(.largeTitle)
                            .font(.system(size: 45))
                    }
                    .frame(height: 30)
                }
                .frame(height: 110)
                .padding(.horizontal, 30)
                .background(Color(hex: "#E0E0E0", opacity: 1))
                HStack(alignment: .center) {
                    Spacer(minLength: 10)
                    Text("类别")
                        .font(.title)
                    Spacer(minLength: 310)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center) {
                        Spacer()
                        ForEach(Array(cates.cate_dict.values.sorted(by: { $0.name < $1.name } ))) { cate in
                            CategoryView(name: cate.name, icon: cate.icon, isSelected: cate.name == highlightCategory)
                                .environmentObject(cates)
                                .onTapGesture {
                                    AudioServicesPlaySystemSound(1519)
                                    withAnimation(.spring(duration: 0.15)) {
                                        selectedCategory = cate.name
                                        highlightCategory = cate.name
                                        print("Selected category: \(selectedCategory)")
                                    }
                                }
                            //.hoverEffect(.automatic)
                        }
                        Spacer(minLength: 10)
                        //CustomNumberPad(value: $accountBalance)
                    }
                }
                .onAppear {
                    if let firstCategory = cates.cate_dict.values.sorted(by: { $0.name < $1.name }).first {
                        selectedCategory = firstCategory.name
                        highlightCategory = firstCategory.name
                    }
                }
                HStack(spacing: 10) {
                    Image(systemName: "wallet.pass")
                    TextField("例如:公交", text: $accountName)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.title3)
                        .keyboardType(.default)
                        .textFieldStyle(.roundedBorder)
                    Button() {
                        presentationMode.wrappedValue.dismiss()
                        AudioServicesPlaySystemSound(1519)
                    } label: {
                        Image(systemName:"checkmark")
                            .bold()
                            .font(.title2)
                            .frame(width: 20, height: 10)
                            .padding()
                    }
                    
                    .background(Color(hex: "#B0B0B0", opacity: 0.2))
                    .controlSize(.large)
                    .cornerRadius(30)
                }
                .padding(.horizontal, 20)
                CustomNumberPad(value: $accountBalance)
            }
        }
    }
    
    private func confirmButton() {
        
    }
}

#Preview {
    AddRecordView().environmentObject(Categories())
}
