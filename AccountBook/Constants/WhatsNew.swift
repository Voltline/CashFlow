//
//  WhatsNew.swift
//  AccountBook
//
//  Created by Voltline on 2024/10/22.
//

import WhatsNewKit

var versionWhatsNew: WhatsNew? = WhatsNew(
    title: "CashFlow的新功能",
    features: [
        .init(
            image: .init(systemName: "calendar", foregroundColor: .cyan),
            title: "修改账目时间",
            subtitle: "您可在增加或修改账目时快捷地修改对应的记账日期与时间。"
        ),
        .init(
            image: .init(systemName: "app.badge", foregroundColor: .red.opacity(0.9)),
            title: "全新通知形式",
            subtitle: "全新的实时活动与灵动岛通知使得您可以便捷地查看当日开销与收入。"
        ),
        .init(image: .init(systemName: "chart.bar.doc.horizontal", foregroundColor: .orange),
              title: "每周财务报告",
              subtitle: "未来的几个版本中，将会上线更加关注您每周财务状况的财务报告。"
         ),
        .init(image: .init(systemName: "paintpalette", foregroundColor: .green.opacity(0.8)),
              title: "视觉元素更新",
              subtitle: "部分文本与视觉元素均进行了调整，以更好传达视觉效果"
         ),
    ],
    primaryAction: .init(
        title: "好的"
    )
)
