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
    var inventoryCategory:InventoryCategoryType
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var inventoryItem: Recreation.Inventory.Item
    @State var emoji:String = String()
    @State private var segmentedControlSelection = ActivityContentSelection.emoji
    @State private var showImagePicker: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var isEditigMode: Bool = false
    @State var workingItem:WorkingItem
    
    struct WorkingItem{
        var prefix:String{
            didSet{
                self.inventoryItem.prefix = prefix
            }
        }
        var name:String{
            didSet{
                self.inventoryItem.name = name
            }
        }
        var imageName:String{
            didSet{
                self.inventoryItem.imageName = imageName == "" ? nil : imageName
            }
        }
        var emoji:String{
            didSet{
                self.inventoryItem.emoji = emoji == "" ? nil : emoji
            }
        }
        
        var inventoryItem:Recreation.Inventory.Item {
            didSet{
                save()
            }
        }
        
        var service:RecreationService
        var inventoryType:InventoryType
        
        init(inventoryItem:Recreation.Inventory.Item, service:RecreationService, inventoryType:InventoryType){
           
            self.inventoryType = inventoryType
            self.service = service
            self.inventoryItem = inventoryItem
            self.imageName = inventoryItem.imageName ?? ""
            self.emoji = inventoryItem.emoji ?? ""
            self.prefix = inventoryItem.prefix
            self.name = inventoryItem.name
        }
        
        mutating func save(){
            self.service.saveInventoryItem(type: self.inventoryType, inventoryItem: self.inventoryItem)
            print("SAVE INVENTORY ITEM")
        }
    }
    
    var ImagePicker: some View {
        Section{
            Button(action: {
                if workingItem.imageName == "" {
                    self.showImagePicker = true
                } else {
                    workingItem.imageName = ""
                }
            }) {
                Text(workingItem.imageName == "" ? "Välj bild" : "Radera bild").foregroundColor(workingItem.imageName == "" ? .accentColor : .red)
            }
        }
    }
    
    var EmojiPicker: some View {
        TextField("Välj emoji", text:$workingItem.emoji)
    }
    
    var ToggleActivityIsActiveView: some View {
        Section{
            HStack{
                Text("Aktiverad").foregroundColor(inventoryItem.isActive ? .black : .gray)
                Spacer()
                Toggle("", isOn: $inventoryItem.isActive).onTapGesture {
                    service.toggleEnabledFlag(type: .Inventory, inventoryType: inventoryCategory.id, id: inventoryItem.id)
                }
            }
        } footer: {
            Text("Välj att aktivera/inaktivera föremålet/objektet. Om föremålet/objektet inaktiveras visas den ej för användaren i 'Laiban föreslår aktivitet' - modulen.")
        }
    }
    
    var DeleteInventoryView:some View {
        Section{
            Button(action: {
                self.showDeleteConfirmation = true
            }) {
                Text("Radera")
                    .foregroundColor(.red)
            }
        }
    }
    
    
    var body: some View {
        
        GeometryReader() { proxy in
            
            VStack{
                Form{
                    Section{
                             VStack(alignment: .center, spacing: 13) {
                                
                                if let imageName = workingItem.imageName, let image = Recreation.Activity.imageStorage.image(with: imageName){
                                    
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill )
                                        .frame(width:proxy.size.height*0.1,height:proxy.size.height*0.1)
                                        .cornerRadius(20)
                                        .shadow(radius: 4)
                                    
                                }else if let activityEmoji = workingItem.emoji {
                                    
                                    Text(activityEmoji)
                                        .font(Font.system(size: proxy.size.height*0.05))
                                        .frame(width:proxy.size.height*0.1,height:proxy.size.height*0.1)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .shadow(radius: 4)
                                    
                                }
                                    
                                Text(workingItem.prefix + " " + workingItem.name)
                                
                            }.frame(width: proxy.size.width, alignment: .center)
                    }.frame(alignment: .center)
                    .listRowBackground(Color.clear)
                    
                    
                    
                    Section{
                        TextField("Objekt/Föremål", text:$workingItem.name)
                    }header: {
                        Text("Lägg till nytt föremål")
                    }footer: {
                        Text("Ange ett nytt föremål. Exempel: Träd")
                    }
                    
                    Section{
                        TextField("Prefix", text:$workingItem.prefix)
                    }header: {
                        Text("Prefix")
                    }footer: {
                        Text("Exempel: Ett")
                    }
                    
                    
                    Section{
                    
                        VStack {
                            Picker("", selection: $segmentedControlSelection) {
                                Text(ActivityContentSelection.emoji.rawValue).tag(ActivityContentSelection.emoji)
                                Text(ActivityContentSelection.image.rawValue).tag(ActivityContentSelection.image)
                                
                            }.pickerStyle(.segmented)

                        }.listRowBackground(Color.clear)
                        
                    }footer:{
                        Text("Valfritt: Välj en bild eller emoji.")
                    }
                
                    switch (segmentedControlSelection){
                        case .image:
                            ImagePicker
                        default:
                            EmojiPicker
                    }
                    ToggleActivityIsActiveView
                    isEditigMode ? DeleteInventoryView : nil
                }
            }
            .navigationBarTitle(Text( isEditigMode ? "Redigera föremål/Objekt - \(inventoryCategory.displayName)" : "Lägg till nytt föremål - \(inventoryCategory.displayName)"))
            .listStyle(GroupedListStyle())
            .navigationBarItems(trailing:
                Button(action: {
                        
                    inventoryItem.prefix = workingItem.prefix
                    inventoryItem.name = workingItem.name
                    inventoryItem.imageName = workingItem.imageName
                    inventoryItem.emoji = workingItem.emoji
                    
                    service.addInventoryItem(type: inventoryType, inventoryItem: inventoryItem, callback: {
                        presentationMode.wrappedValue.dismiss()
                    })
                                    
                    }, label: {
                        isEditigMode ? nil : Text("Lägg till")
                    }).disabled(workingItem.name == "" || workingItem.prefix == "")
                )
            .sheet(isPresented: self.$showImagePicker){
                PhotoCaptureView(showImagePicker: self.$showImagePicker, imageStorage: Recreation.Activity.imageStorage) { asset in
                    workingItem.imageName = asset
                }
            }
            
        }.onAppear(perform: {
            self.isEditigMode = inventoryItem.prefix != "" && inventoryItem.name != ""
            self.workingItem = .init(inventoryItem: self.inventoryItem, service: self.service, inventoryType: self.inventoryType)
        })
    }
}

struct AdminRecreationAddInventoryItemView_Previews: PreviewProvider {
    static var service = RecreationService()
    static var inventoryType:InventoryType = .misc
    static var inventoryCategory:InventoryCategoryType = InventoryCategory().all[0]
    static var inventoryItem = Recreation.Inventory.Item(id: "",prefix: "", name: "",imageName: "",emoji: "", isActive: true )
    static var previews: some View {
        AdminRecreationAddInventoryItemView(service: service, inventoryType: inventoryType, inventoryCategory: inventoryCategory, inventoryItem: .init(), workingItem: .init(inventoryItem: inventoryItem, service: service, inventoryType: inventoryType))
    }
}
