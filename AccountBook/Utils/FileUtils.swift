//
//  FileUtils.swift
//  AccountBook
//
//  Created by 张艺怀 on 2024/12/18.
//

import Foundation
import CoreData

func readCSVFileToInsert(result: Result<[URL], any Error>, context: NSManagedObjectContext) {
    switch result {
    case .success(let urls):
        guard let selectedFileURL = urls.first else { return }
        // 激活安全范围书签
        if selectedFileURL.startAccessingSecurityScopedResource() {
            defer { selectedFileURL.stopAccessingSecurityScopedResource() } // 确保结束访问
            // 请求上传链接
            do {
                let fileData = try Data(contentsOf: selectedFileURL)
                if let csvFileString = String(data: fileData, encoding: .utf8) {
                    parseAndInsertCSV(csv: csvFileString, context: context)
                } else {
                    print("数据转换为字符串失败")
                }
            } catch {
                print("无法读取文件数据: \(error.localizedDescription)")
            }
        } else {
            print("无法访问选中的文件")
        }
    case .failure(let error):
        print("文件选择失败: \(error.localizedDescription)")
    }
}
