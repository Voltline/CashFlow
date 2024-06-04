//
//  ItemView.swift
//  AccountBook
//
//  Created by Voltline on 2024/6/4.
//

import SwiftUI

struct ItemView: View {
    @State var item_name: String
    @State var item_date: Date
    @State var item_type: String
    @State var item_num: Double
    var body: some View {
            HStack {
                VStack {
                    HStack(spacing: 2) {
                        Text(item_name)
                            .bold()
                            .font(.title)
                        Spacer()
                        Image(systemName: "yensign")
                            .font(.title3)
                        Text(String(format: "%.2f", item_num))
                            .font(.title2)
                    }
                    HStack {
                        Text(item_type)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    HStack {
                        Text(dateformat(date: item_date))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    
                }
                Spacer()
            }
            //.padding()
    }
                             
     private func dateformat(date: Date) -> String {
         let df = DateFormatter()
         df.dateFormat = "yyyy-MM-dd HH:mm:ss"
         return df.string(from: date)
    }
}

#Preview {
    ItemView(item_name: "打车", item_date: Date(), item_type: "交通", item_num: 67.23)
}
