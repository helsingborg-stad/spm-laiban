//
//  AdminRootView.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-27.
//

import SwiftUI

public enum ListOrderPriority: Equatable, Hashable {
    case basic
    case content
    case information
    case custom(Int)
    public var value:Int {
        switch self {
        case .basic: return 1
        case .content: return 500
        case .information: return 1000
        case .custom(let val) : return val
        }
    }
    public var after: Self {
        switch self {
        case .basic: return .custom(value + 1)
        case .content: return .custom(value + 1)
        case .information: return .custom(value + 1)
        case .custom(let val) : return .custom(val + 1)
        }
    }
    public var before: Self {
        switch self {
        case .basic: return .custom(value - 1)
        case .content: return .custom(value - 1)
        case .information: return .custom(value - 1)
        case .custom(let val) : return .custom(val - 1)
        }
    }
}

public struct LBAdminListViewSection: Identifiable, Equatable, Hashable{
    public let id:String
    public let title:String
    public let listOrderPriority:ListOrderPriority
    public static let basic = LBAdminListViewSection(id: "LBAdminCategoryBasic", title: "Övergripande inställningar", listOrderPriority: .basic)
    public static let content = LBAdminListViewSection(id: "LBAdminCategoryContent", title: "Innehåll", listOrderPriority: .content)
    public static let information = LBAdminListViewSection(id: "LBAdminCategoryInformation", title: "Information", listOrderPriority: .information)
    public init(id:String, title:String, listOrderPriority: ListOrderPriority) {
        self.id = id
        self.title = title
        self.listOrderPriority = listOrderPriority
    }
}
public protocol LBAdminService {
    var id:String { get }
    var listOrderPriority:Int { get }
    var listViewSection:LBAdminListViewSection { get }
    func resetToDefaults()
    func delete()
    func adminView() -> AnyView
}
public struct LBAdminView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var services: [LBAdminService]
    var categories: [LBAdminListViewSection]
    var data: [LBAdminListViewSection:[LBAdminService]]
    public init(services:[LBAdminService]) {
        self.categories = Array(Set(services.map { $0.listViewSection}))
            .sorted(by: { $0.title < $1.title })
            .sorted(by: { $0.listOrderPriority.value < $1.listOrderPriority.value })
        self.services = services
        var data = [LBAdminListViewSection:[LBAdminService]]()
        for category in categories {
            data[category] = services.filter({ $0.listViewSection == category })
                .sorted(by: { $0.listOrderPriority < $1.listOrderPriority })
        }
        self.data = data
    }
    var list: some View {
        List {
            ForEach(categories) { category in
                Section(header:Text(category.title)) {
                    ForEach(data[category] ?? [], id:\.id) { service in
                        service.adminView()
                    }
                }
            }
            Section {
                Button {
                    services.forEach { s in
                        s.resetToDefaults()
                    }
                } label: {
                    Text("Återställ till standardinställningar").foregroundColor(.red)
                }
                Button {
                    services.forEach { s in
                        s.delete()
                    }
                } label: {
                    Text("Radera inställningar").foregroundColor(.red)
                }
            }
        }
        .navigationBarTitle("Inställningar")
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Stäng")
        })
    }
    public var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                list.listStyle(.insetGrouped)
            } else {
                list.listStyle(.grouped)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.locale, Locale(identifier: "sv_SE"))
    }
}
