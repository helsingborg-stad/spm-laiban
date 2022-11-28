//
//  MovementAdminEditActivityView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-08.
//

import Foundation
import SwiftUI

struct MovementAdminEditActivityView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var service:MovementService
    @Binding var activity:MovementActivity
    @State private var showDeleteConfirmation: Bool = false
    @State private var isEditingMode: Bool = false

    var EmojiPickerView: some View {
        Section{
            TextField(activity.emoji == "" ? "Välj emoji" : activity.emoji, text:$activity.emoji)
        }
    }

    var ToggleActivityIsActiveView: some View {
        Section{
            HStack{
                Text("Aktiverad").foregroundColor(activity.isActive ? .black : .gray)
                Spacer()
                Toggle("", isOn: $activity.isActive)
            }
        }
    }

    var DeleteActivityView:some View {
        Section{
            Button(action: {
                self.showDeleteConfirmation = true
            }) {
                Text("Radera aktivitet")
                    .foregroundColor(.red)
            }
        }
    }

    var body: some View {
        GeometryReader() { proxy in
            VStack {
                    VStack(alignment: .center,spacing: 10) {
                        LBEmojiBadgeView(emoji: activity.emoji, rimColor: Color(activity.colorString, bundle: .module))
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width:proxy.size.width * 0.2, height: proxy.size.width * 0.2)
                        Text(activity.title.uppercased())
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("DefaultTextColor", bundle:.module))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color.black)
                            .fixedSize(horizontal: false, vertical: true)
                        }

                Divider()
                
                Section{
                    HStack{
                        Text("Emoji:")
                        TextField("Emoji", text:$activity.emoji)
                    }
                    HStack{
                        Text("Namn:")
                        TextField("Aktivitetens namn", text:$activity.title)
                    }
                    
                }header: {
                    Text(isEditingMode ? "Redigera aktivitet" : "Ny aktivitet")
                }

                ToggleActivityIsActiveView
                DeleteActivityView

            }.navigationBarTitle(Text(isEditingMode ? "Spara aktivitet" : "Lägg till aktivitet"))
                .listStyle(GroupedListStyle())
                .navigationBarItems(trailing:
                Button(action: {

                    service.saveActivity(activity: self.activity, callback: {
                        DispatchQueue.main.async {
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                }, label: {
                    Text("Lägg till")
                }).disabled(activity.title == "" || activity.emoji == "").invisible(isEditingMode)
            )
            .alert(isPresented: self.$showDeleteConfirmation, content: {
                Alert(
                    title: Text("Du är påväg att radera aktiviteten"),
                    message: Text("Vill du fortsätta?"),
                    primaryButton: .destructive(Text("Ja, radera aktivitet.")) {
                        service.deleteActivity(activity: self.activity, callback: {
                            DispatchQueue.main.async {
                                presentationMode.wrappedValue.dismiss()
                            }
                        })
                    },
                    secondaryButton: .cancel(Text("Avbryt"))
                )
            }).onAppear(perform: {
                self.isEditingMode = activity.emoji != "" && activity.title != ""
            })
            .onDisappear(perform: {
                service.saveActivity(activity: activity)
            })
            .padding([.leading, .trailing, .top, .bottom], 50)
        }
    }
}

struct MovementAdminEditActivityView_Previews: PreviewProvider {
    static var service = MovementService()
    @State static var activity:MovementActivity = .init(id: UUID().uuidString, colorString: MovementActivity.colorStrings.randomElement()!, title: "Aktivitet 1", emoji: "🧗")

    static var previews: some View {
        MovementAdminEditActivityView(service: service, activity: $activity)
    }
}
