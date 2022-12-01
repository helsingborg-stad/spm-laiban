//
//  SwiftUIView.swift
//  
//
//  Created by jonatan lidholm jansson on 2022-10-12.
//

import SwiftUI


struct AdminRecreationViews: View {
    @ObservedObject var service:RecreationService
    @State var recreation:Recreation
    
    
    func delete(_ activity:Recreation.Activity) {
        service.delete(activity)
        save()
    }
    
    func update(_ activity:Recreation.Activity) {
        service.update(activity)
        save()
    }
    
    func save() {
        service.save()
    }
    
    var body: some View {

        Section{
            List(){
                AdminRecreationActivityListView(service: service)
                AdminRecreationInventoriesListView(service: service)
            }
        }
        .navigationBarTitle(Text("Laiban föreslår aktivitet"))
        .onDisappear(perform: {
            service.save()
        })
    }
}

struct AdminRecreationActivityListItem:View {
    
    @State var activity: Recreation.Activity
    @ObservedObject var service:RecreationService
    
    func update(_ activity:Recreation.Activity) {
        service.update(activity)
        save()
    }
    
    func delete(_ activity:Recreation.Activity) {
        service.delete(activity)
        save()
    }
    
    func save() {
        service.save()
    }
    
    func toggleIsActiveForActivity(activity:Recreation.Activity){
        
        if let index = service.recreation.activities.firstIndex(where:{$0.id == activity.id}) {
            service.data[0].activities[index].isActive.toggle()
        }
    }
    
    var body:some View {
        
        NavigationLink(destination: AdminRecreationActivityView(ba:$activity, activity: activity) { a in
            update(a)
        } onDelete: {a in
            delete(a)
        }){
          
            HStack(alignment: .center) {
                
                Text(activity.emoji)
                
                VStack(alignment: .leading) {
                    Text(activity.sentence)
                    if let os = activity.objectSentence, os != "" {
                        Text(os)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $activity.isActive).onTapGesture {
                    toggleIsActiveForActivity(activity: activity)
                }

            }.foregroundColor(activity.isActive ? .black : .gray)
        }
    }
}

struct AdminRecreationActivityListView: View {

    @ObservedObject var service:RecreationService

    
    @State var empty_Activity = Recreation.Activity(name: String(), sentence: String(), emoji: String(), isActive: true, activityEmoji: String())
    
    func delete(_ activity:Recreation.Activity) {
        service.delete(activity)
        save()
    }

    func update(_ activity:Recreation.Activity) {
        service.update(activity)
        save()
    }

    func save() {
        service.save()
    }

    var body: some View {
        Section {
            ForEach(service.recreation.activities, id: \.id) { activity in
                AdminRecreationActivityListItem(activity: activity, service: service)
            }.onDelete(perform: service.deleteActivity)
            
        } header: {
            
            VStack(alignment: .leading){
                Text("Välj vilka aktiviteter och föremål du vill ska vara aktiverade för 'Laiban föreslår aktivitet' genom att markera/avmarkera dessa i listorna här nedan. Du kan skapa en ny aktivitet eller lägga till nya föremål genom att klicka på + för respektive lista.")
                Spacer(minLength: 40.0)
                HStack{
                    Text("Aktiviteter")
                    Spacer()
                    
                    NavigationLink(destination: AdminRecreationActivityView(ba: $empty_Activity,activity: nil) { a in
                        update(a)
                    } onDelete: {a in
                        delete(a)
                    }){
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
    
    
    func delete(_ item:Recreation.Inventory.Item,type:InventoryType) {
        service.deleteInventoryItem(itemId: item.id,inventoryType: type)
        save()
    }
    
    func update(_ item:Recreation.Inventory.Item, type:InventoryType) {
        service.update(item,type: type)
        save()
    }
    
    func save() {
        service.save()
    }
    
    var type:InventoryType{
        guard let type  = InventoryType(rawValue: inventory.id) else
        {
            return InventoryType.misc
        }
        return type
    }
    
    var body: some View {
        
        NavigationLink(destination: AdminRecreationInventoryItemView(bi:$item, inventoryItem: item,type: type, onUpdate: {i,t in
            update(i ,type: t)
        }, onDelete: { i,t in
            delete(i,type:t)
        })){
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
    
    @State var empty_item = Recreation.Inventory.Item()
    
    func delete(_ item:Recreation.Inventory.Item,type:InventoryType) {
        service.deleteInventoryItem(itemId: item.id,inventoryType: type)
        save()
    }
    
    func update(_ item:Recreation.Inventory.Item, type: InventoryType) {
        service.update(item,type: type)
        save()
    }
    
    func save() {
        service.save()
    }
    
    var body: some View {
        
        ForEach(service.recreation.inventories, id:\.id){ inventory in
            Section {
                ForEach(inventory.items, id:\.id){ item in
                    InventoryListViewItem(inventory:inventory, item:item, service: service).foregroundColor(item.isActive ? .black : .gray)
                }.onDelete { indexSet in
                    service.deleteInventoryItem(at: indexSet, inventoryType: InventoryType(rawValue: inventory.id)!)
                }
            } header: {

                let type = InventoryType(rawValue: inventory.id) ?? InventoryType.misc
                let item = Recreation.Inventory.Item()
                
                HStack {
                    Text(inventory.name)
                    Spacer()
                    NavigationLink(destination: AdminRecreationInventoryItemView(bi:$empty_item, inventoryItem: item, type: type, onUpdate:{i,t in
                        update(i, type: t)
                    } , onDelete: {i,t in
                        delete(i, type: t)
                    })){
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
                AdminRecreationViews(service: service, recreation: service.recreation)
            }
        }.navigationViewStyle(.stack)
    }
}

