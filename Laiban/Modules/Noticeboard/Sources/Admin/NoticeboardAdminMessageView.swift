//
//  NoticeboardAdminMessageView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-09.
//

import SwiftUI


struct NoticeboardAdminMessageView: View {
    @State var message:Message
    @State var name:String
    @State var title:String
    @State var emoji:String
    @State var text:String
    @State var automated:Bool
    @State var category:MessageCategory
    var onUpdate: (Message) -> Void
    init(message:Message?,onUpdate: @escaping (Message) -> Void) {
        let m = message ?? Message()
        _message = State(initialValue: m)
        _name = State(initialValue: m.name)
        _title = State(initialValue: m.title)
        _emoji = State(initialValue: m.emoji)
        _text = State(initialValue: m.text)
        _category = State(initialValue: m.category)
        _automated = State(initialValue: m.automated)
        self.onUpdate = onUpdate
    }
    var body: some View {
        Form {
            Section {
                TextField("Namn", text: $name).disabled(message.systemDefault).opacity(message.systemDefault ? 0.7 : 1)
                TextField("Emoji", text: $emoji).disabled(message.systemDefault).opacity(message.systemDefault ? 0.7 : 1)
                LBTextView("Titel", text: $title).disabled(message.systemDefault).opacity(message.systemDefault ? 0.7 : 1)
                LBTextView("Meddelande", text: $text)
                LBNonOptionalPicker(title: "Kategori", items: MessageCategory.allCases, selection: $category) { cat in
                    Text(cat.name).foregroundColor(Color(.label))
                }.disabled(message.systemDefault).opacity(message.systemDefault ? 0.7 : 1)
                if self.message.automatable {
                    HStack {
                        Text("Visa automatiskt vid lämpligt tillfälle")
                        Spacer()
                        LBToggleView(isOn: automated) { b in
                            self.automated = b
                        }
                    }
                }
            }
        }.onDisappear {
            var m = message
            m.name = name
            m.emoji = emoji
            m.title = title
            m.text = text
            m.automated = automated
            m.category = category
            if message == m {
                return
            }
            self.onUpdate(m)
        }
        .navigationBarTitle(Text("Meddelande"))
    }
}
struct NoticeboardAdminMessageView_Previews: PreviewProvider {
    @State static var message = Message(category: .info, name: "Testing", title: "This is a title", text: "This is text", emoji: "", active: true)
    static var previews: some View {
        NoticeboardAdminMessageView(message: message) { message in
            print("updated message")
        }
    }
}
