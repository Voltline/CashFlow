//
//  CustomNavigationBar.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/2.
//

import SwiftUI
import AudioToolbox
import ActivityKit
import CoreData

struct CustomNavigationBar: View {
    var size: Double
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_type, ascending: true)],
        animation: .default)
    private var records: FetchedResults<Record>
    @State private var profileImage: UIImage?
    @State private var showEditProfileView = false
    @State private var enterEditMode = false
    @Binding var recordViewSp: Int
    @Binding var editMode: EditMode         // 用于控制编辑模式
    @Binding var refreshTrigger: Bool
    @Binding var showAddRecordView: Bool
    @Binding var selectedRecords: Set<Record>
    @ObservedObject var userProfile: UserProfile
    var body: some View {
        HStack {
            UserView(username: userProfile.username, icon: userProfile.icon, size: size)
                .onTapGesture {
                    showEditProfileView.toggle()
                }
            Spacer()
            HStack(spacing: 15) {
                if recordViewSp == 1 {
                    if $editMode.wrappedValue.isEditing {
                        Button(role: .destructive) {
                            withAnimation(.spring) {
                                editMode = .inactive
                            }
                            AudioServicesPlaySystemSound(1520)
                            deleteItems()
                        } label: {
                            Image(systemName: "trash")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 25, height: 25)
                        }
                        .disabled(selectedRecords.isEmpty)
                    }
                    Button(action: {
                        withAnimation {
                            if editMode == .inactive {
                                editMode = .active
                            }
                            else {
                                editMode = .inactive
                            }
                        }
                        AudioServicesPlaySystemSound(1520)
                    }) {
                        if editMode == .inactive {
                            Image(systemName: "rectangle.stack")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 25, height: 25)
                        }
                        else {
                            Image(systemName: "checkmark.rectangle.stack")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 25, height: 25)
                        }
                    }
                }
                
                Button(action: {
                    withAnimation {
                        showAddRecordView = true
                        editMode = .inactive
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
        .background(Color(.systemBackground))
        .sheet(isPresented: $showEditProfileView) {
            EditProfileView(userProfile: userProfile, refreshTrigger: $refreshTrigger)
                .onDisappear() {
                    withAnimation {
                        refreshTrigger.toggle()
                    }
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToAddRecord)) {_ in
            withAnimation {
                showAddRecordView = true
                editMode = .inactive
            }
        }
    }
    
    private func deleteItems() {
        for item in selectedRecords {
            withAnimation(.spring) {
                deleteItem(offsets: IndexSet(integer: records.firstIndex(of: item)!))
                selectedRecords.remove(item)
            }
        }
    }
    
    private func deleteItem(offsets: IndexSet) {
        withAnimation {
            offsets.map { records[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
                refreshTrigger.toggle()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
/*
#Preview {
    CustomNavigationBar(username: "Voltline", icon: "icon", size: 55, addItem: addItem)
}
*/
