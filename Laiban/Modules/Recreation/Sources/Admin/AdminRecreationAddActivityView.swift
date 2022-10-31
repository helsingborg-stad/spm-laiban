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
    @State var activity:Recreation.Activity
    @State var imageOrEmojiDescription:String = String()
    @State var objectSentence:String = String()
    @State private var showImagePicker: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    var inventoryCategories = InventoryCategory()

    @State private var segmentedControlSelection = ActivityContentSelection.image

    enum ActivityContentSelection: String, CaseIterable, Hashable {
        case image = "Bild", emoji = "Emoji", objects = "Objekt/Föremål"
        public var id: Self { self }
    }
    
    var imagePickerView: some View {
        
        Section{
            Button(action: {
                if activity.imageName == nil {
                    self.showImagePicker = true
                } else {
                    activity.deleteImage()
                }
            }) {
                Text(activity.imageName == nil ? "Välj bild" : "Radera bild").foregroundColor(activity.imageName == nil ? .accentColor : .red)
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
                            .invisible(!activity.inventories.contains(where: {$0 == type.id}))
                    }.onTapGesture {
                        if activity.inventories.contains(where: {$0 == type.id}){
                            activity.inventories.removeAll(where: {$0 == type.id})
                            activity.activityEmoji = ""
                        }else{
                            
                            activity.inventories.append(type.id)
                            activity.activityEmoji = "?"
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
            TextField(activity.inventories.count > 0 ? "Välj emoji" : activity.activityEmoji == "" ? "Välj emoji" : activity.activityEmoji, text:$activity.activityEmoji)
            TextField("Beskrivning av emoji", text:$imageOrEmojiDescription)
        } footer: {
            Text("Beskriv den valda emojin, till exempel : 'En tärning'.")
        }
    }
    
    
    var deleteActivityView:some View {
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
                Form {
                    Section{
                        HStack{
                            Spacer(minLength: proxy.size.width*0.33)
                            VStack(spacing: 13) {
                                
                                Text(LocalizedStringKey("recreation_nothing_to_do"),bundle: LBBundle)
                                    .font(properties.font, ofSize: .xxs, weight: .heavy)
                                    .padding(.top, properties.spacing[.xs])
                                
                                Text(activity.sentence)
                                activity.objectSentence != nil ? Text(activity.objectSentence ?? "") : nil
                                
                                if let imageName = activity.imageName, let image = Recreation.Activity.imageStorage.image(with: imageName){
                                    
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width:proxy.size.height*0.1,height:proxy.size.height*0.1)
                                        .clipped()
                                        .cornerRadius(20)
                                        .shadow(radius: 4)
                                    
                                }else if let activityEmoji = activity.activityEmoji, activityEmoji != ""{
                                    
                                    Text(activityEmoji)
                                        .font(Font.system(size: proxy.size.height*0.05))
                                        .frame(width:proxy.size.height*0.1,height:proxy.size.height*0.1)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .shadow(radius: 4)
                                    
                                }
                                
                                
                                Text(imageOrEmojiDescription)
                                
                            }.frame(maxWidth:proxy.size.width*0.33 ,maxHeight: proxy.size.height, alignment: .center)
                                .wrap(scrollable: false, overlay: .emoji(activity.emoji, Color("RimColorActivities",bundle:LBBundle)))
                        }
                    }
                    .listRowBackground(Color.clear)
                    .frame(width: proxy.size.width,height: proxy.size.height*0.3)
                        
                    Section{
                        TextField("Emoji", text:$activity.emoji)
                        TextField("Hitta på något att göra", text:$activity.sentence)
                        activity.objectSentence != nil ? TextField(activity.objectSentence ?? "", text: $objectSentence ).onAppear(perform: {
                            objectSentence = activity.objectSentence ?? ""
                        }) : nil
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
                    
                    
                    deleteActivityView
                    
                }.navigationBarTitle(Text("Lägg till ny 'Laiban föreslår-aktivitet'"))
                    .listStyle(GroupedListStyle())
                    .navigationBarItems(trailing:
                    Button(action: {
                        
                        switch (segmentedControlSelection){
                            case .emoji:
                                activity.inventories = []
                            case .objects:
                                activity.activityEmoji = ""
                            default:
                            break
                        }
                        
                        if imageOrEmojiDescription != "" {
                            activity.imageOrEmojiDescription = imageOrEmojiDescription
                        }
                    
                        activity.objectSentence = objectSentence == "" ? nil : objectSentence
                    
                        service.saveActivity(activity: activity, callback: {
                            presentationMode.wrappedValue.dismiss()
                        })
                    
                    }, label: {
                        Text("Spara")
                    }).disabled(activity.sentence == "" || activity.emoji == "")
                )
                .sheet(isPresented: self.$showImagePicker){
                    PhotoCaptureView(showImagePicker: self.$showImagePicker, imageStorage: Recreation.Activity.imageStorage) { asset in
                        print(asset)
                        activity.imageName = asset
                    }
                }.alert(isPresented: self.$showDeleteConfirmation, content: {
                    Alert(
                        title: Text("Du är påväg att radera aktiviteten"),
                        message: Text("Vill du fortsätta?"),
                        primaryButton: .destructive(Text("Ja, radera aktivitet.")) {
                            service.deleteActivity(activity: self.activity, callback: {
                                presentationMode.wrappedValue.dismiss()
                            })
                        },
                        secondaryButton: .cancel(Text("Avbryt"))
                    )
                }).onAppear(perform: {
                    segmentedControlSelection = activity.inventories.count > 0 ? .objects : activity.activityEmoji != "" ? .emoji : .image
                    
                    if segmentedControlSelection == .objects {
                        if let inventoryType = activity.inventories.first, let item = service.randomInventoryItemFor(inventoryType: InventoryType(rawValue: inventoryType)! ), let emoji = item.emoji {
                            activity.activityEmoji = emoji
                        }
                    }
                })
            }
        }
    }
}

struct AdminRecreationAddActivityView_Previews: PreviewProvider {
    static var service = RecreationService()
    static var activity:Recreation.Activity = .init(name: "", sentence: "", emoji: "", isActive: true, activityEmoji: "")
    static var previews: some View {
        AdminRecreationAddActivityView(service: service, activity: activity )
    }
}
