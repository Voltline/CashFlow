//  AddRecordView.swift
//  AccountBook

import SwiftUI

extension Color {
    init(hex: String, opacity: Double) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // 跳过'#'字符
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0xFF00) >> 8) / 255.0
        let b = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b, opacity: opacity)
    }
}

class Category: Identifiable, Codable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name && lhs.icon == rhs.icon && lhs.positive == rhs.positive
    }
    var name: String
    var icon: String
    var positive: Bool
    var prio: Int
    
    private enum CodingKeys: String, CodingKey {
        case name, icon, positive, prio
    }
    
    init(name: String, icon: String, prio: Int, positive: Bool = false) {
        self.name = name
        self.icon = icon
        self.positive = positive
        self.prio = prio
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.positive = try container.decode(Bool.self, forKey: .positive)
        self.prio = try container.decode(Int.self, forKey: .prio)
    }
}

let builtInCategories = [
    Category(name: "收入", icon: "icon_bonus", prio: 5, positive: true),
    Category(name: "商务", icon: "icon_business", prio: 9),
    Category(name: "服装", icon: "icon_clothes", prio: 4),
    Category(name: "日常", icon: "icon_daily", prio: 4),
    Category(name: "娱乐", icon: "icon_entertainment", prio: 3),
    Category(name: "食物", icon: "icon_food", prio: 1),
    Category(name: "医药", icon: "icon_medicine", prio: 10),
    Category(name: "话费", icon: "icon_phone", prio: 8),
    Category(name: "购物", icon: "icon_shopping", prio: 3),
    Category(name: "学习", icon: "icon_study", prio: 7),
    Category(name: "交通", icon: "icon_traffic", prio: 6)
]

class Categories: Codable, ObservableObject, Identifiable {
    var cate_dict: [String: Category]
    var cates: [Category]
    private enum CodingKeys: String, CodingKey {
        case cate_dict
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cate_dict = try container.decode([String: Category].self, forKey: .cate_dict)
        self.cates = Array(self.cate_dict.values)
    }
    init() {
        self.cates = builtInCategories
        self.cate_dict = [:]
        for each_cate in cates {
            cate_dict[each_cate.name] = each_cate
        }
    }
}

struct CategoryView: View {
    var name: String
    var icon: String
    var isSelected: Bool = false
    var size: Double
    @EnvironmentObject var cate: Categories
    var body: some View {
        VStack(spacing: 10) {
            CircularImageView(imageName: icon, size: size)
            Text(name)
        }
        .padding()
        .background(isSelected ?  Color(hex: "#E0E0E2", opacity: 1) : Color.clear)
        .cornerRadius(10)
    }
}

#Preview {
    CategoryView(name: "商务", icon: "icon_business", size: 100)
}
