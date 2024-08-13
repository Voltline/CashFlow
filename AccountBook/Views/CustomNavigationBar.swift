//
//  CustomNavigationBar.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/2.
//

import SwiftUI
import AudioToolbox

struct CustomNavigationBar: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.record_date, ascending: false)],
        animation: .default)
    private var records: FetchedResults<Record>
    var size: Double
    @Binding var showAddRecordView: Bool
    @ObservedObject var userProfile: UserProfile
    @Binding var refreshTrigger: Bool
    @State private var profileImage: UIImage?
    @State private var showEditProfileView = false
    @State private var enterEditMode = false
    @Binding var recordViewSp: Int
    @Binding var editMode: EditMode  // 用于控制编辑模式
    @Binding var selectedRecords: Set<Record>
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
                            deleteItems()
                        } label: {
                            Text("删除")
                        }
                        .disabled(selectedRecords.isEmpty)
                    }
                    EditButton()
                        .environment(\.editMode, $editMode)
                }
                
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
        .background(Color(.systemBackground))
        .sheet(isPresented: $showEditProfileView) {
            EditProfileView(userProfile: userProfile, refreshTrigger: $refreshTrigger)
                .onDisappear() {
                    withAnimation {
                        refreshTrigger.toggle()
                    }
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
