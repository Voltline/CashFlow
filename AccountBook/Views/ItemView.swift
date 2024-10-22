//
//  ItemView.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/4.
//

import SwiftUI

struct ItemView: View {
    @ObservedObject var record: Record
    @State var item_name: String
    @State var item_date: Date
    @State var item_type: String
    @State var item_num: Double
    init(record: Record) {
        self.record = record
        item_name = record.record_name!
        item_date = record.record_date!
        item_type = record.record_type!
        item_num = record.number
    }
    
    var body: some View {
        HStack {
            VStack {
                HStack(spacing: 2) {
                    Text(item_name)
                        .bold()
                        .font(.title2)
                    Spacer()
                    Image(systemName: "yensign")
                        .font(.title3)
                    Text(String(format: "%.2f", item_num))
                        .font(.title3)
                }
                HStack {
                    Text(item_type)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                HStack {
                    Text(dateformat(date: item_date))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                
            }
            Spacer()
        }
    }
                             
     private func dateformat(date: Date) -> String {
         let df = DateFormatter()
         df.dateFormat = "yyyy-MM-dd HH:mm:ss"
         return df.string(from: date)
    }
}
