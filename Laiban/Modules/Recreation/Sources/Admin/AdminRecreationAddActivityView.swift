//
//  SwiftUIView.swift
//  
//
//  Created by jonatan lidholm jansson on 2022-10-13.
//

import SwiftUI

struct AdminRecreationAddActivityView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var service:RecreationService
    @State var newActivity:Recreation.Activity = .init(name: "", sentence: "", emoji: "", isActive: true)
    @State var objectSentence:String = String()
    
    var body: some View {
        
        Form{
            Section{
                TextField("Namn", text:$newActivity.name)
            }header: {
                Text("Namn")
            }footer: {
                Text("Ange ett förklarande namn för aktiviteten. Exempel: Spela")
            }
            
            Section{
                TextField("Lägg till en ny aktivitet", text:$newActivity.sentence)
            }header: {
                Text("Aktivitet")
            }footer: {
                Text("Exempel: Gå och spela ett spel tillsammans med en kompis.")
            }
            
            Section{
                TextField("Lägg till nytt förslag", text:$objectSentence)
            }header: {
                Text("Förslag (Valfritt)")
            }footer: {
                Text("Exempel: Till exempel kan ni spela...")
            }
            
            Section{
                TextField("🎲", text:$newActivity.emoji)
            }header: {
                Text("Emoji")
            }
            
            Section {
                List{
                    ForEach(InventoryType.allCases) { type in
                        HStack{
                            Text(type.rawValue)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .invisible(!newActivity.inventories.contains(where: {$0 == type.rawValue}))
                        }.onTapGesture {
                            if newActivity.inventories.contains(where: {$0 == type.rawValue}){
                                newActivity.inventories.removeAll(where: {$0 == type.rawValue})
                            }else{
                                newActivity.inventories.append(type.rawValue)
                            }
                        }
                    }
                }
            } header: {
                Text("Inventarier")
            } footer: {
                Text("Valfritt: Välj vilka typer av inventarier som ska vara tillgängliga för aktiviteten. (En inventarie är de bilder/föremål som slumpas fram tillsammans med en aktivitet, till exempel en bil, ett tåg eller en häst.)")
            }
        }
        .navigationBarTitle(Text("Lägg till ny 'Jag har tråkigt'-aktivitet"))
        .listStyle(GroupedListStyle())
        .navigationBarItems(trailing:
            Button(action: {
                
            if objectSentence != "" {
                newActivity.objectSentence = objectSentence
            }
            
            service.addActivity(newActivity: newActivity, callback: {
                presentationMode.wrappedValue.dismiss()
            })
            
            }, label: {
                Text("Spara")
            }).disabled(newActivity.name == "" || newActivity.sentence == "" || newActivity.emoji == "")
        )
    }
}

struct AdminRecreationAddActivityView_Previews: PreviewProvider {
    static var service = RecreationService()
    static var previews: some View {
        AdminRecreationAddActivityView(service: service)
    }
}
