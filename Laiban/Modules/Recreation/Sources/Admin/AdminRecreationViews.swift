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
                AdminRecreationInventoriesListView(service: service)
            }
        }.navigationBarTitle(Text("Laiban föreslår aktivitet"))
    }
}

struct AdminRecreationActivityListItem:View {
    
    @State var activity: Recreation.Activity
    @ObservedObject var service:RecreationService
    
    var body:some View {
        NavigationLink(destination: AdminRecreationAddActivityView(service: service, activity: activity, workingActivity: .init(service: service, activity: activity))){
            HStack(alignment: .center) {
                
        
                Text(activity.emoji)
                
                VStack(alignment: .leading) {
                    Text(activity.sentence)
                    activity.objectSentence != nil ? Text(activity.objectSentence ?? "") : nil
                }
                
                Spacer()
             
                Toggle("", isOn: $activity.isActive).onTapGesture {
                    service.toggleEnabledFlag(type: .Activity, inventoryType: activity.name, id: activity.id)
                }
            }.foregroundColor(activity.isActive ? .black : .gray)
        }
    }
}

struct AdminRecreationActivityListView: View {
    
    @State private var showingSheet = false

    @ObservedObject var service:RecreationService
    var body: some View {
        Section {
            ForEach(service.data[0].activities, id: \.self) { activity in
                AdminRecreationActivityListItem(activity: activity, service: service)
            }.onDelete(perform: service.deleteActivity)
        } header: {
            
            VStack(alignment: .leading){
                
                Text("Välj vilka aktiviteter och föremål du vill ska vara aktiverade för 'Laiban föreslår aktivitet' genom att markera/avmarkera dessa i listorna här nedan. Du kan skapa en ny aktivitet eller lägga till nya föremål genom att klicka på + för respektive lista.")
                Spacer(minLength: 40.0)
                HStack{
                    Text("Aktiviteter")
                    Spacer()
                    NavigationLink(destination: AdminRecreationAddActivityView(service: service, activity: .init(name: "", sentence: "", emoji: "", isActive: true, activityEmoji: ""), workingActivity: .init(service: service, activity: Recreation.Activity.init(name: "", sentence: "", emoji: "", isActive: true, activityEmoji: "") ))){
                        Image(systemName: "plus")
                            .resizable()
                            .padding(6)
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct InventoryListViewItem: View {
    let inventory:Recreation.Inventory
    @State var item: Recreation.Inventory.Item
    @ObservedObject var service:RecreationService
    var body: some View {
        NavigationLink(destination: AdminRecreationAddInventoryItemView(service: service, inventoryType: InventoryType(rawValue: inventory.id)!, inventoryCategory: InventoryCategory().all.first(where: {$0.displayName == inventory.name})!, inventoryItem: item, workingItem: .init(inventoryItem: item, service: service, inventoryType: InventoryType(rawValue: inventory.id)!))){
            HStack{
                if let emoji = item.emoji, emoji != "" {
                    Text(emoji)
                }else if let imageName = item.imageName, imageName != "" {
                    Image(systemName: "photo")
                }
                Text(item.itemDescription())
                Spacer()
                Toggle("", isOn: $item.isActive).onTapGesture {
                    service.toggleEnabledFlag(type: .Inventory, inventoryType: inventory.id, id: item.id)
                }
            }.foregroundColor(item.isActive ? .black : .gray)
        }
    }
}
struct AdminRecreationInventoriesListView: View {
    
    @ObservedObject var service:RecreationService
    
    var body: some View {
        
        ForEach(service.data[0].inventories, id:\.self){ inventory in
            Section {
                ForEach(inventory.items, id:\.self){ item in
                    InventoryListViewItem(inventory:inventory, item:item, service: service)
                        .foregroundColor(item.isActive ? .black : .gray)
                }.onDelete { indexSet in
                    service.deleteInventoryItem(at: indexSet, inventoryType: InventoryType(rawValue: inventory.id)!)
                }
            } header: {

                HStack {
                    Text(inventory.name)
                    Spacer()
                    NavigationLink(destination: AdminRecreationAddInventoryItemView(service: service, inventoryType: InventoryType(rawValue: inventory.id)!, inventoryCategory: InventoryCategory().all.first(where: {$0.displayName == inventory.name})!, inventoryItem: .init(),  workingItem: .init(inventoryItem: .init(), service: service, inventoryType: InventoryType(rawValue: inventory.id)!))){
                        Image(systemName: "plus")
                            .resizable()
                            .padding(6)
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                            .foregroundColor(.blue)
                    }
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

