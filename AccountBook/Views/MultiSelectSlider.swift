//
//  MultiSelectSlider.swift
//  AccountBook
//
//  Created by Voltline on 2024/7/6.
//

import SwiftUI
import AudioToolbox

struct CapsuleButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.title3)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

struct MultiSelectSlider: View {
    @Binding var selectedIndex: Int
    @Environment(\.colorScheme) var colorScheme
    let options: [String]

    var body: some View {
        GeometryReader { geometry in
            let padding: CGFloat = 6
            let totalSpacing: CGFloat = CGFloat(options.count - 1) * 8
            let capsuleWidth: CGFloat = (geometry.size.width - totalSpacing - 2 * padding) / CGFloat(options.count)
            let capsuleHeight: CGFloat = geometry.size.height - 1.8 * padding
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.blue)
                    .frame(width: capsuleWidth, height: capsuleHeight)
                    .offset(x: CGFloat(selectedIndex) * (capsuleWidth + 8))
                    .animation(.spring, value: selectedIndex)
                
                HStack(spacing: 8) {
                    ForEach(options.indices, id: \.self) { index in
                        CapsuleButton(text: options[index], isSelected: selectedIndex == index) {
                            withAnimation(.spring) {
                                AudioServicesPlaySystemSound(1519)
                                selectedIndex = index
                                UserDefaults.standard.setValue(index, forKey: "RecordListViewMode")
                            }
                        }
                        .frame(width: capsuleWidth, height: capsuleHeight)
                        .background(selectedIndex == index ? Color.clear : Color.primary.opacity(0.2))
                        .cornerRadius(20)
                    }
                }
            }
            .padding(padding)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .frame(height: 50)
        .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
    }
}

#Preview {
    @State var selectedIndex = 0
    MultiSelectSlider(selectedIndex: $selectedIndex, options: ["日", "周", "月", "年"])
}
