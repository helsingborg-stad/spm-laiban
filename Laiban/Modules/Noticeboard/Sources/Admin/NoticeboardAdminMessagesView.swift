//
//  NoticeboardAdminMessagesView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-09.
//

import SwiftUI
import Combine
import Analytics

struct NoticeboardAdminMessagesView: View {
    @ObservedObject var service:NoticeboardService
    @State var resetAlertVisible = false
    func update(_ message:Message) {
        guard let index = service.data.firstIndex(where: { $0.id == message.id }) else {
            service.data.append(message)
            save()
            
            return
        }
        
        service.data[index] = message
        save()
    }
    func save() {
        service.save()
    }
    func remove(_ message:Message) {
        service.data.removeAll { $0.id == message.id }
        save()
    }
    func editItemView(for message:Message? = nil) -> some View {
        NoticeboardAdminMessageView(message: message) { m in
            update(m)
        }
    }
    func section(for category: MessageCategory) -> some View {
        Section(header: Text(category.name)) {
            let messages = service.data.filter { $0.category == category }
            ForEach(messages) { message in
                NavigationLink(
                    destination: editItemView(for: message),
                    label: {
                        Text(message.emoji)
                        Text(message.name).frame(maxWidth:.infinity,alignment: .leading)
                        if message.active && message.automated {
                            Image(systemName: "gearshape.2.fill")
                        }
                        LBToggleView(isOn: message.active) { b in
                            var m = message
                            m.active.toggle()
                            update(m)
                        }
                    }).id(message.id).buttonStyle(PlainButtonStyle())
            }.onDelete(perform: { indexSet in
                indexSet.forEach { i in
                    if !messages[i].systemDefault {
                        remove(messages[i])
                    }
                }
            })
        }.id("messages-\(category.rawValue)-section")
    }
    var body: some View {
        Form {
            Section {
                NavigationLink(destination: editItemView()) {
                    Text("Lägg till meddelande").foregroundColor(Color.accentColor)
                }
            }
            if service.data.contains(where: { $0.category == .disease }) == true {
                section(for: .disease)
            }
            if service.data.contains(where: { $0.category == .reminder }) == true {
                section(for: .reminder)
            }
            if service.data.contains(where: { $0.category == .info }) == true {
                section(for: .info)
            }
            Section(footer:
                HStack {
                    Image(systemName: "gearshape.2.fill")
                    Text("Symbolen betyder att meddelandet är automatiserat och att Laiban kommer välja när det är lämpligt att visa.")
                }
            ) {
                EmptyView()
            }
        }
        .navigationBarTitle(Text("Meddelanden"))
        .listStyle(GroupedListStyle())
        .navigationBarItems(trailing: Button(action: {
            resetAlertVisible = true
        }, label: {
            Text("Återställ")
        })).alert(isPresented: $resetAlertVisible) {
            Alert(
                title: Text("Återställ standardmeddelanden"),
                message: Text("Denna åtgärd återställer standardmeddelanden till sina orginalinställningar. Dina egna meddelanden påverkas inte."),
                primaryButton: Alert.Button.destructive(Text("Återställ"), action: {
                    service.resetToDefaults()
                }),
                secondaryButton: Alert.Button.cancel())
        }
        .onAppear {
            AnalyticsService.shared.logPageView(self)
        }
    }
}

struct NoticeboardAdminMessagesView_Previews: PreviewProvider {
    static var service = NoticeboardService()
    static var previews: some View {
        NavigationView {
            NoticeboardAdminMessagesView(service: service)
        }.navigationViewStyle(.stack)
    }
}
