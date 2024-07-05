//
//  CustomNavigationBar.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/2.
//

import SwiftUI
import AudioToolbox

struct CustomNavigationBar: View {
    var size: Double
    @Binding var showAddRecordView: Bool
    @ObservedObject var userProfile: UserProfile
    @Binding var refreshTrigger: Bool
    @State private var profileImage: UIImage?
    @State private var showEditProfileView = false
    var body: some View {
        HStack {
            UserView(username: userProfile.username, icon: userProfile.icon, size: size)
                .onTapGesture {
                    showEditProfileView.toggle()
                }
            Spacer()
            HStack {
                Button(action: {
                    withAnimation {
                        showAddRecordView = true
                    }
                    AudioServicesPlaySystemSound(1519)
                }) {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 25, height: 25)
                }
            }
        }
        .padding()
        //.background(AngularGradient(gradient: Gradient(colors: [Color.purple, Color.orange]), center: .center, startAngle: .degrees(0), endAngle: .degrees(360)))
        .background(Color(.systemBackground))
        //.overlay(Divider(), alignment: .bottom)
        .sheet(isPresented: $showEditProfileView) {
            EditProfileView(userProfile: userProfile, refreshTrigger: $refreshTrigger)
                .onDisappear() {
                    withAnimation {
                        refreshTrigger.toggle()
                    }
                }
        }
        
    }
}
/*
#Preview {
    CustomNavigationBar(username: "Voltline", icon: "icon", size: 55, addItem: addItem)
}
*/
