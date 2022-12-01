//
//  SwiftUIView.swift
//  
//
//  Created by jonatan lidholm jansson on 2022-11-25.
//

import SwiftUI

struct AdminRecreationInventoryItemView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var segmentedControlSelection = ActivityContentSelection.image
    @State private var showImagePicker: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    @Binding var binding_inventory_item:Recreation.Inventory.Item
    
    private var inventoryCategories = InventoryCategory()
    private var type:InventoryType
    
    
    @State var item: Recreation.Inventory.Item
    @State var prefix:String
    @State var name:String
    @State var imageName:String
    @State var emoji:String
    @State var isActive:Bool
    
    var onUpdate: (Recreation.Inventory.Item,InventoryType) -> Void
    var onDelete: (Recreation.Inventory.Item,InventoryType) -> Void
    init(bi:Binding<Recreation.Inventory.Item>, inventoryItem:Recreation.Inventory.Item?,type:InventoryType ,onUpdate: @escaping (Recreation.Inventory.Item, InventoryType) -> Void,onDelete: @escaping (Recreation.Inventory.Item, InventoryType) -> Void) {
        
        let i = inventoryItem ?? Recreation.Inventory.Item()
        _item = State(initialValue: i)
        _prefix = State(initialValue: i.prefix)
        _name = State(initialValue: i.name)
        _emoji = State(initialValue: i.emoji ?? "")
        _isActive = State(initialValue: i.isActive)
        _imageName = State(initialValue: i.imageName ?? "")
        self.type = type
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _binding_inventory_item = bi
    }
    
    
    var ImagePicker: some View {
        Section{
            Button(action: {
                if $imageName.wrappedValue == "" {
                    self.showImagePicker = true
                } else {
                    $imageName.wrappedValue = ""
                }
            }) {
                Text($imageName.wrappedValue == "" ? "Välj bild" : "Radera bild").foregroundColor($imageName.wrappedValue == "" ? .accentColor : .red)
            }
        }
    }
    
    var EmojiPicker: some View {
        TextField("Välj emoji", text:$emoji)
    }
    
    var ToggleInventoryIsActiveView: some View {
        Section{
            HStack{
                Text("Aktiverad").foregroundColor($isActive.wrappedValue ? .black : .gray)
                Spacer()
                Toggle("", isOn: $isActive).onTapGesture {
                    
                    $isActive.wrappedValue.toggle()
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
                        HStack{
                            Spacer()
                            VStack(){
                               
                                if let imageName = $imageName.wrappedValue, let image = Recreation.Activity.imageStorage.image(with: imageName){
                                   
                                   image.resizable()
                                       .aspectRatio(contentMode: .fill )
                                       .frame(width:proxy.size.height*0.2,height:proxy.size.height*0.2)
                                       .cornerRadius(20)
                                       .shadow(radius: 4)
                                   
                               }else if let activityEmoji = $emoji.wrappedValue, activityEmoji != "" {
                                   
                                   Text(activityEmoji)
                                       .font(Font.system(size: proxy.size.height*0.1))
                                       .frame(width:proxy.size.height*0.2,height:proxy.size.height*0.2)
                                       .background(Color.white)
                                       .cornerRadius(20)
                                       .shadow(radius: 4)
                               }
                                   
                                Text($prefix.wrappedValue + " " + $name.wrappedValue)
                            }
                            Spacer()
                        }
                    }.listRowBackground(Color.clear)
                    
                    Section{
                        TextField("Objekt/Föremål", text:$name)
                    }header: {
                        Text("Lägg till nytt föremål")
                    }footer: {
                        Text("Ange ett nytt föremål. Exempel: Träd")
                    }
                    
                    Section{
                        TextField("Prefix", text:$prefix)
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
                    ToggleInventoryIsActiveView
                    DeleteInventoryView
                }
            }
            .listStyle(GroupedListStyle())
            .sheet(isPresented: self.$showImagePicker){
                    PhotoCaptureView(showImagePicker: self.$showImagePicker, imageStorage: Recreation.Activity.imageStorage) { asset in
                        $imageName.wrappedValue = asset
                    }
                }
            .alert(isPresented: self.$showDeleteConfirmation, content: {
                    Alert(
                        title: Text("Du är påväg att radera föremålet/objektet."),
                        message: Text("Vill du fortsätta?"),
                        primaryButton: .destructive(Text("Ja, radera föremål/objekt.")) {
                            
                            self.onDelete(self.item,self.type)
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel(Text("Avbryt"))
                    )
                })
        }.onDisappear {
            var i = item
            i.imageName = imageName
            i.isActive = isActive
            i.name = name
            i.emoji = emoji
            if item == i || i.name == ""{
                return
            }
            binding_inventory_item = i
            self.onUpdate(i,type)
        }
    }
}
