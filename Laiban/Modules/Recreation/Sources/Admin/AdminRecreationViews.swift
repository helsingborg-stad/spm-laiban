//
//  SwiftUIView.swift
//  
//
//  Created by jonatan lidholm jansson on 2022-10-12.
//

import SwiftUI


struct AdminRecreationViews: View {
    @ObservedObject var service:RecreationService
    
    var body: some View {

        Section{
            List(){
                AdminRecreationActivityListView(service: service)
                AdminRecreationIventoriesListView(service: service)
            }
        }
        .navigationBarTitle(Text("Jag har tråkigt"))
    }
}

struct AdminRecreationActivityListItem:View {
    
    var activity: Recreation.Activity
    
    var body:some View {
        HStack {
            Text(activity.emoji)
            Text(activity.sentence)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundColor(.blue)
                .invisible(!activity.isActive)
        }.foregroundColor(activity.isActive ? .black : .gray)
    }
}

struct AdminRecreationActivityListView: View {
    
    
    @ObservedObject var service:RecreationService
    var body: some View {
        Section {
            ForEach(service.data[0].activities, id: \.self) { activity in
                AdminRecreationActivityListItem( activity: activity)
                    .onTapGesture {
                        service.toggleEnabledFlag(type: .Activity, id: activity.id)
                    }
            }
        } header: {
            VStack(alignment: .leading){
                Text("Välj vilka aktiviteter och föremål du vill ska vara aktiverade för 'Jag har tråkigt' genom att markera/avmarkera dessa i listorna här nedan.")
                //Text("Välj vilka aktiviteter och föremål du vill ska vara aktiverade för 'Jag har tråkigt' genom att markera/avmarkera dessa i listorna här nedan. Du kan skapa en ny aktivitet eller lägga till nya föremål genom att klicka på + för respektive lista.")
                Spacer(minLength: 40.0)
                HStack{
                    Text("Aktiviteter")
//                    Spacer()
//                    Button(
//                        action: {
//                            service.addActivity()
//                            print("button pressed")
//                        }
//                    ) {
//                        Image(systemName: "plus")
//                            .resizable()
//                            .padding(6)
//                            .frame(width: 24, height: 24)
//                            .clipShape(Circle())
//                            .foregroundColor(.blue)
//                    }
                }
            }
        }
    }
}

struct InventoryListViewItem: View {
    let item: Recreation.Inventory.Item
    var body: some View {
        HStack{
            Text((item.emoji ?? item.emoji) ?? "")
            Text(item.name)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundColor(.blue)
                .invisible(!item.isActive)
        }
    }
}

struct AdminRecreationIventoriesListView: View {
    
    @ObservedObject var service:RecreationService
    
    var body: some View {
        
        ForEach(service.data[0].inventories, id:\.self){ inventory in
            Section {
                ForEach(inventory.items, id:\.self){ item in
                    InventoryListViewItem(item:item )
                        .onTapGesture {
                            service.toggleEnabledFlag(type: .Inventory, inventoryType: inventory.name, id: item.id)
                        }
                        .foregroundColor(item.isActive ? .black : .gray)
                }
            } header: {

                HStack {
                    Text(inventory.name)
                    Spacer()
//                    Button(
//                        action: {
//                            let newItem:Recreation.Inventory.Item =
//                                .init(id:"Test\(service.data[0].inventories[0].items.count)",prefix: "Ett",name: "Test\(service.data[0].inventories[0].items.count)",emoji: "🌳",isActive: true)
//                            service.addInventoryItem(type: .songs, inventoryItem: newItem)
//                        }
//                    ) {
//                        Image(systemName: "plus")
//                            .resizable()
//                            .padding(6)
//                            .frame(width: 24, height: 24)
//                            .clipShape(Circle())
//                            .foregroundColor(.blue)
//                    }
                }
            }
        }
    }
}

struct AdminRecreationView_Previews: PreviewProvider {
    static var service = RecreationService()
    static var previews: some View {
        NavigationView {
            Form {
                AdminRecreationViews(service: service)
            }
        }.navigationViewStyle(.stack)
    }
}

