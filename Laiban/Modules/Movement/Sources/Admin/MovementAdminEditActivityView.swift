//
//  MovementAdminEditActivityView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-08.
//

import Foundation
import SwiftUI

struct MovementTempActivity {

    let id:String
    var emoji:String {
        didSet{
            self.currentActivity.emoji = emoji
        }
    }
    var title:String{
        didSet{
            self.currentActivity.title = title
        }
    }
    var color: String {
        didSet{
            self.currentActivity.colorString = color
        }
    }
    var isActive:Bool{
        didSet {
            self.currentActivity.isActive = isActive
        }
    }

    var service:MovementService
    var currentActivity:MovementActivity {
        didSet{
            save()
        }
    }

    func save(){
        service.saveActivity(activity: currentActivity)
    }

    init(service:MovementService, activity:MovementActivity){
        self.currentActivity = activity
        self.service = service
        self.title = activity.title
        self.emoji = activity.emoji
        self.isActive = activity.isActive
        self.color = activity.colorString
        self.id = UUID().uuidString
    }
}


struct MovementAdminEditActivityView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var service:MovementService
    @State var activity:MovementActivity

    @State private var showDeleteConfirmation: Bool = false

    @State var workingActivity:MovementTempActivity
    @State private var isEditingMode: Bool = false

    var EmojiPickerView: some View {
        Section{
            TextField(workingActivity.emoji == "" ? "Välj emoji" : workingActivity.emoji, text:$workingActivity.emoji)
        }
    }


    var ToggleActivityIsActiveView: some View {
        Section{
            HStack{
                Text("Aktiverad").foregroundColor(workingActivity.isActive ? .black : .gray)
                Spacer()
                Toggle("", isOn: $workingActivity.isActive)
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
                        LBEmojiBadgeView(emoji: workingActivity.emoji, rimColor: Color(workingActivity.color, bundle: .module))
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width:proxy.size.width * 0.2, height: proxy.size.width * 0.2)
                        Text(workingActivity.title.uppercased())
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
                        TextField("Emoji", text:$workingActivity.emoji)
                    }
                    HStack{
                        Text("Namn:")
                        TextField("Aktivitetens namn", text:$workingActivity.title)
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

                    service.saveActivity(activity: self.workingActivity.currentActivity, callback: {
                        DispatchQueue.main.async {
                            presentationMode.wrappedValue.dismiss()
                        }
                    })

                }, label: {
                    Text("Lägg till")
                }).disabled(workingActivity.title == "" || workingActivity.emoji == "").invisible(isEditingMode)
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
            .padding([.leading, .trailing, .top, .bottom], 50)
        }
    }
    
}

struct MovementAdminEditActivityView_Previews: PreviewProvider {
    static var service = MovementService()
    static var activity:MovementActivity = .init(id: UUID().uuidString, colorString: MovementActivity.colorStrings.randomElement()!, title: "Aktivitet 1", emoji: "🧗")

    static var workingActivity:MovementTempActivity = MovementTempActivity(service:service, activity: activity)
    static var previews: some View {
        MovementAdminEditActivityView(service: service, activity: activity, workingActivity: workingActivity)
    }
}
