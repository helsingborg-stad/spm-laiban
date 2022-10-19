//
//  SwiftUIView.swift
//  
//
//  Created by jonatan lidholm jansson on 2022-10-19.
//

import SwiftUI

struct AdminRecreationAddInventoryItemView: View {
    var service:RecreationService
    var inventoryType:InventoryType
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var newInventoryItem: Recreation.Inventory.Item = .init()
    @State var emoji:String = String()
    var body: some View {
        Form {
            Section{
                TextField("Inventarie", text:$newInventoryItem.name)
            }header: {
                Text("Lägg till ny Inventarie")
            }footer: {
                Text("Ange en ny inventarie. Exempel: Träd")
            }
            
            Section{
                TextField("Prefix", text:$newInventoryItem.prefix)
            }header: {
                Text("Prefix")
            }footer: {
                Text("Exempel: Ett")
            }
            
            Section{
                TextField("🌳", text:$emoji)
            }header: {
                Text("Emoji (Valfritt)")
            }
        }.navigationBarTitle(Text("Lägg till ny inventarie - \(inventoryType.rawValue)"))
            .listStyle(GroupedListStyle())
            .navigationBarItems(trailing:
                Button(action: {
                    
                if emoji != "" {
                    newInventoryItem.emoji = emoji
                }
                
                service.addInventoryItem(type: inventoryType, inventoryItem: newInventoryItem, callback: {
                    presentationMode.wrappedValue.dismiss()
                })
                                
                }, label: {
                    Text("Spara")
                }).disabled(newInventoryItem.name == "" || newInventoryItem.prefix == "")
            )
    }
}

struct AdminRecreationAddInventoryItemView_Previews: PreviewProvider {
    static var service = RecreationService()
    static var inventoryType:InventoryType = .misc
    static var previews: some View {
        AdminRecreationAddInventoryItemView(service: service, inventoryType: inventoryType)
    }
}
