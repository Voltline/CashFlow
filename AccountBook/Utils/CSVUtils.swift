//
//  CSVUtils.swift
//  AccountBook
//
//  Created by Voltline on 2024/10/29.
//

import Foundation
import SwiftUI
import CoreData

func generateCSVString(records: FetchedResults<Record>) -> String {
    // 创建 DateFormatter
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 定义日期格式
    dateFormatter.timeZone = TimeZone.current       // 使用当前时区（本地时区）

    // CSV 头部
    var csv = "number,record_date,record_name,record_type\n"
    
    for record in records {
        // 将 record_date 转换为字符串，如果为空则使用当前时间
        let date = record.record_date ?? Date()
        let formattedDate = dateFormatter.string(from: date)
        
        // 拼接每行数据
        csv.append("\(record.number),\(formattedDate),\(record.record_name ?? "其他"),\(record.record_type ?? "其他")\n")
    }
    return csv
}

func parseAndInsertCSV(csv: String, context: NSManagedObjectContext) {
    // 分割 CSV 行
    let rows = csv.split(separator: "\n").map { String($0) }
    
    // 跳过头部
    guard rows.count > 1 else { return }
    let dataRows = rows.dropFirst()
    
    // DateFormatter 用于解析日期
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone.current // 设置时区
    
    for row in dataRows {
        let columns = row.split(separator: ",").map { String($0) }
        guard columns.count == 4 else { continue } // 确保列数正确
        
        // 安全解析每列
        guard let number = Double(columns[0]), // 解析 Double 类型的 number
              let date = dateFormatter.date(from: columns[1]) else {
            print("Skipping row due to parsing error: \(row)")
            continue
        }
        
        let recordName = columns[2]
        let recordType = columns[3]
        
        // 根据 recordType 判断 positive 值（示例逻辑）
        let isPositive = recordType == "收入" // 收入时 positive 为 true，支出为 false
        
        // 创建 Core Data 实体
        let record = Record(context: context)
        record.number = number
        record.record_date = date
        record.record_name = recordName
        record.record_type = recordType
        record.positive = isPositive
    }
    
    // 保存上下文
    do {
        try context.save()
        print("CSV data successfully saved to Core Data.")
    } catch {
        print("Failed to save Core Data: \(error)")
    }
}
