//
//  NoticeboardAdminViewItem.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-27.
//

import SwiftUI

struct NoticeboardAdminView : View {
    @ObservedObject var service:NoticeboardService
    @State var active:Int = 0
    var body: some View {
        NavigationLink(destination: NoticeboardAdminMessagesView(service:service)) {
            HStack {
                Text("Meddelanden")
                Spacer()
                Text("\((service.data).filter({$0.active}).count)")
            }
        }
    }
}
struct NoticeboardAdminView_Previews: PreviewProvider {
    static var service = NoticeboardService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    NoticeboardAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
