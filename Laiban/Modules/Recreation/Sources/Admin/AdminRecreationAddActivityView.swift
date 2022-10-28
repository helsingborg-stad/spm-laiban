//
//  SwiftUIView.swift
//  
//
//  Created by jonatan lidholm jansson on 2022-10-13.
//

import SwiftUI

struct AdminRecreationAddActivityView: View {
    
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var service:RecreationService
    @State var newActivity:Recreation.Activity = .init(name: "", sentence: "", emoji: "", isActive: true, activityEmoji: "")
    @State var imageOrEmojiDescription:String = String()
    @State private var showImagePicker: Bool = false
    var inventoryCategories = InventoryCategory()

    @State private var segmentedControlSelection = ActivityContentSelection.image

    enum ActivityContentSelection: String, CaseIterable, Hashable {
        case image = "Bild", emoji = "Emoji", objects = "Objekt/Föremål"
        public var id: Self { self }
    }
    
    var imagePickerView: some View {
        
        Section{
            Button(action: {
                if newActivity.imageName == nil {
                    self.showImagePicker = true
                } else {
                    newActivity.deleteImage()
                }
            }) {
                Text(newActivity.imageName == nil ? "Välj bild" : "Radera bild").foregroundColor(newActivity.imageName == nil ? .accentColor : .red)
            }
            TextField("Beskrivning av bild", text:$imageOrEmojiDescription)
        }footer: {
            Text("Beskriv den valda bilden, till exempel : 'Ett träd'.")
        }
    }
    
    
    var categoryPickerView: some View {
        
        Section {
            List{
                ForEach(inventoryCategories.all) { type in
                    HStack{
                        Text(type.displayName)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .invisible(!newActivity.inventories.contains(where: {$0 == type.id}))
                    }.onTapGesture {
                        if newActivity.inventories.contains(where: {$0 == type.id}){
                            newActivity.inventories.removeAll(where: {$0 == type.id})
                            newActivity.activityEmoji = ""
                        }else{
                            
                            newActivity.inventories.append(type.id)
                            if let emoji = service.randomInventoryItemFor(inventoryType: InventoryType(rawValue: type.id)!)?.emoji {
                                newActivity.activityEmoji = emoji
                            }
                        }
                    }
                }
            }
        } footer: {
            Text("Valfritt: Välj vilka typer av föremål som ska vara tillgängliga för aktiviteten. (Ett föremål är de bilder som slumpas fram tillsammans med en aktivitet, till exempel en bil, ett tåg eller en häst.)")
        }
    }
    
    
    var emojiPickerView: some View {
        
        Section{
            TextField(newActivity.inventories.count > 0 ? "Välj emoji" : newActivity.activityEmoji == "" ? "Välj emoji" : newActivity.activityEmoji, text:$newActivity.activityEmoji)
            TextField("Beskrivning av emoji", text:$imageOrEmojiDescription)
        } footer: {
            Text("Beskriv den valda emojin, till exempel : 'En tärning'.")
        }
    }
    
    
    var body: some View {
        
        GeometryReader() { proxy in
            
            VStack {
                Form {
                    Section{
                        HStack{
                            Spacer(minLength: proxy.size.width*0.33)
                            VStack(spacing: 13) {
                                
                                Text(LocalizedStringKey("recreation_nothing_to_do"),bundle: LBBundle)
                                    .font(properties.font, ofSize: .xxs, weight: .heavy)
                                    .padding(.top, properties.spacing[.xs])
                                
                                Text(newActivity.sentence)
                                
                                if let imageName = newActivity.imageName, let image = Recreation.Activity.imageStorage.image(with: imageName){
                                    
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width:proxy.size.height*0.1,height:proxy.size.height*0.1)
                                        .clipped()
                                        .cornerRadius(20)
                                        .shadow(radius: 4)
                                    
                                }else if let activityEmoji = newActivity.activityEmoji, activityEmoji != ""{
                                    
                                    Text(activityEmoji)
                                        .font(Font.system(size: proxy.size.height*0.05))
                                        .frame(width:proxy.size.height*0.1,height:proxy.size.height*0.1)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .shadow(radius: 4)
                                    
                                }
                                
                                Text(imageOrEmojiDescription)
                                
                            }.frame(maxWidth:proxy.size.width*0.33 ,maxHeight: proxy.size.height, alignment: .center)
                                .wrap(scrollable: false, overlay: .emoji(newActivity.emoji, Color("RimColorActivities",bundle:LBBundle)))
                        }
                    }
                    .listRowBackground(Color.clear)
                    .frame(width: proxy.size.width,height: proxy.size.height*0.3)
                        
                    Section{
                        TextField("Emoji", text:$newActivity.emoji)
                        TextField("Hitta på något att göra", text:$newActivity.sentence)
                    }header: {
                        Text("Ny aktivitet")
                    }footer: {
                        Text("Exempel: Gå och spela ett spel tillsammans med en kompis.")
                    }

                    Section{
                        VStack {
                            Picker("", selection: $segmentedControlSelection) {
                                
                                Text(ActivityContentSelection.image.rawValue).tag(ActivityContentSelection.image)
                                Text(ActivityContentSelection.emoji.rawValue).tag(ActivityContentSelection.emoji)
                                Text(ActivityContentSelection.objects.rawValue).tag(ActivityContentSelection.objects)
                                
                            }.pickerStyle(.segmented)

                        }.listRowBackground(Color.clear)
                    } header: {
                        Text("Välj en bild, emoji alternativt en eller flera kategorier av objekt/föremål som ska visas tillsammans med den nya aktiviteten. OBSERVERA att det ej går att kombinera bild, emoji och kategorier för samma aktivitet. ")
                    }
                    
                    switch (segmentedControlSelection){
                    case .image:
                        imagePickerView
                    case .objects:
                        categoryPickerView
                    case .emoji:
                        emojiPickerView
                    }
                    
                }.navigationBarTitle(Text("Lägg till ny 'Laiban föreslår-aktivitet'"))
                    .listStyle(GroupedListStyle())
                    .navigationBarItems(trailing:
                    Button(action: {
                        
                
                        switch (segmentedControlSelection){
                            case .emoji:
                                newActivity.inventories = []
                            case .objects:
                                newActivity.activityEmoji = ""
                            default:
                            break
                        }
                        
                        
                    if imageOrEmojiDescription != "" {
                        newActivity.imageOrEmojiDescription = imageOrEmojiDescription
                    }
                    
                    service.addActivity(newActivity: newActivity, callback: {
                        presentationMode.wrappedValue.dismiss()
                    })
                    
                    }, label: {
                        Text("Spara")
                    }).disabled(newActivity.sentence == "" || newActivity.emoji == "")
                )
                .sheet(isPresented: self.$showImagePicker){
                    PhotoCaptureView(showImagePicker: self.$showImagePicker, imageStorage: Recreation.Activity.imageStorage) { asset in
                        print(asset)
                        newActivity.imageName = asset
                    }
                }
            }
        }
    }
}

struct AdminRecreationAddActivityView_Previews: PreviewProvider {
    static var service = RecreationService()
    static var previews: some View {
        AdminRecreationAddActivityView(service: service)
    }
}
