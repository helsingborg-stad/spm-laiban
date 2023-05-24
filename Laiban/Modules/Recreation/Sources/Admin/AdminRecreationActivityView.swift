//
//  File.swift
//  
//
//  Created by jonatan lidholm jansson on 2022-11-25.
//

import SwiftUI

struct AdminRecreationActivityView:View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var segmentedControlSelection = ActivityContentSelection.image
    @State private var showImagePicker: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @Binding var binding_activity:Recreation.Activity
    
    private var inventoryCategories = InventoryCategory()
    @State var activity: Recreation.Activity
    @State var emoji:String
    @State var name:String
    @State var sentence:String
    @State var objectSentence:String
    @State var activityEmoji:String
    @State var imageName:String?
    @State var imageOrEmojiDescription:String
    @State var inventories:[String]
    @State var isActive:Bool
    
    var onUpdate: (Recreation.Activity) -> Void
    var onDelete: (Recreation.Activity) -> Void
    init(ba: Binding<Recreation.Activity> ,activity:Recreation.Activity?,onUpdate: @escaping (Recreation.Activity) -> Void,onDelete: @escaping (Recreation.Activity) -> Void) {
        
        
        let a = activity ?? Recreation.Activity.init(name: String(), sentence: String(), emoji: String(), isActive: true, activityEmoji: String())
        _activity = State(initialValue: a)
        _name = State(initialValue: a.name)
        _emoji = State(initialValue: a.emoji)
        _isActive = State(initialValue: a.isActive)
        _activityEmoji = State(initialValue: a.activityEmoji)
        _sentence = State(initialValue: a.sentence)
        _objectSentence = State(initialValue: a.objectSentence ?? "")
        _imageName = State(initialValue: a.imageName)
        _imageOrEmojiDescription = State(initialValue: a.imageOrEmojiDescription ?? "")
        _inventories = State(initialValue: a.inventories)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _binding_activity = ba
    }
    
    var ImagePickerView: some View {
        Section{
            Button(action: {
                if let _ = $imageName.wrappedValue {
                    self.activity.deleteImage()
                } else {
                    self.showImagePicker = true
                }
            }) {
                Text($imageName.wrappedValue == nil ? "Välj bild" : "Radera bild").foregroundColor($imageName.wrappedValue == nil ? .accentColor : .red)
            }
            TextField("Beskrivning av bild", text:$imageOrEmojiDescription)
        }footer: {
            Text("Beskriv den valda bilden, till exempel : 'Ett träd'.")
        }
    }
    
    var CategoryPickerView: some View {
        Section {
            List{
                ForEach(inventoryCategories.all) { type in
                    HStack{
                        Text(type.displayName)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .invisible(!$inventories.wrappedValue.contains(where: {$0 == type.id}))
                    }.onTapGesture {
                        if $inventories.wrappedValue.contains(where: {$0 == type.id}){
                            $inventories.wrappedValue.removeAll(where: {$0 == type.id})
                            $activityEmoji.wrappedValue = ""
                        }else{
                            $inventories.wrappedValue.append(type.id)
                            $activityEmoji.wrappedValue = "?"
                        }
                    }
                }
            }
        } footer: {
            Text("Valfritt: Välj vilka typer av föremål som ska vara tillgängliga för aktiviteten. (Ett föremål är de bilder som slumpas fram tillsammans med en aktivitet, till exempel en bil, ett tåg eller en häst.)")
        }
    }
    
    
    var EmojiPickerView: some View {
        
        Section{
            TextField($inventories.wrappedValue.count > 0 ? "Välj emoji" : $activityEmoji.wrappedValue == "" ? "Välj emoji" : $activityEmoji.wrappedValue, text:$activityEmoji)
            TextField("Beskrivning av emoji", text:$imageOrEmojiDescription)
        } footer: {
            Text("Beskriv den valda emojin, till exempel : 'En tärning'.")
        }
    }
    
    
    var ToggleActivityIsActiveView: some View {
        Section{
            HStack{
                Text("Aktiverad").foregroundColor($isActive.wrappedValue ? .black : .gray)
                Spacer()
                Toggle("", isOn: $isActive).onTapGesture {
                    
                    $isActive.wrappedValue.toggle()
                }
            }
        } footer: {
            Text("Välj att aktivera/inaktivera aktiviteten. Om aktiviteten inaktiveras visas den ej för användaren i 'Laiban föreslår aktivitet' - modulen.")
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
                Form {
                    Section{
                        HStack{
                            horizontalSizeClass == .regular ? Spacer(minLength:proxy.size.width*0.3) : nil
                            
                                VStack(spacing: 13) {
                                    Text(LocalizedStringKey("recreation_nothing_to_do"),bundle: LBBundle)
                                        .font(properties.font, ofSize: .xxs, weight: .heavy)
                                        .padding(.top, properties.spacing[.xs])
                                    
                                    Text(sentence).padding(EdgeInsets(top: 0, leading: 10, bottom:0, trailing: 10))
                                    Text(objectSentence).padding(EdgeInsets(top: 0, leading: 10, bottom:0, trailing: 10))
                                    
                                    if let imageName = $imageName.wrappedValue, let image = Recreation.Activity.imageStorage.image(with: imageName){
                                        
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width:proxy.size.height*0.1,height:proxy.size.height*0.1)
                                            .clipped()
                                            .cornerRadius(20)
                                            .shadow(radius: 4)
                                        
                                    }else if $activityEmoji.wrappedValue != "" {
                                        
                                        Text($activityEmoji.wrappedValue)
                                            .font(Font.system(size: proxy.size.height*0.05))
                                            .frame(width:proxy.size.height*0.1,height:proxy.size.height*0.1)
                                            .background(Color.white)
                                            .cornerRadius(20)
                                            .shadow(radius: 4)
                                    }
                                    
                                    Text($imageOrEmojiDescription.wrappedValue).padding(EdgeInsets(top: 0, leading: 10, bottom:0, trailing: 10))
                                    
                                }.frame(maxWidth: proxy.size.width, maxHeight: proxy.size.height)
                                .wrap(scrollable: false, overlay: .emoji($emoji.wrappedValue, Color("RimColorActivities",bundle:LBBundle)))
                            
                            horizontalSizeClass == .regular ? Spacer(minLength:proxy.size.width*0.3) : nil
                            
                        }
                    }
                    .listRowBackground(Color.clear)
                    .frame(height: horizontalSizeClass == .regular ? proxy.size.width*0.5 : proxy.size.width)
                    
                    Section{
                        TextField("Emoji", text:$emoji)
                        TextField("Hitta på något att göra", text:$sentence)
                        $objectSentence.wrappedValue != "" ? TextField($objectSentence.wrappedValue, text: $objectSentence ) : nil
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
                        ImagePickerView
                    case .objects:
                        CategoryPickerView
                    case .emoji:
                        EmojiPickerView
                    }

                    ToggleActivityIsActiveView
                    activity.sentence == "" && activity.emoji == "" ? nil : DeleteActivityView
                    
                }.navigationBarTitle(Text("Lägg till ny 'Laiban föreslår-aktivitet'"))
                    .listStyle(GroupedListStyle())
                .sheet(isPresented: self.$showImagePicker){
                    PhotoCaptureView(showImagePicker: self.$showImagePicker, imageStorage: Recreation.Activity.imageStorage) { asset in
                        print(asset)
                        $imageName.wrappedValue = asset
                    }
                }.alert(isPresented: self.$showDeleteConfirmation, content: {
                    Alert(
                        title: Text("Du är påväg att radera aktiviteten"),
                        message: Text("Vill du fortsätta?"),
                        primaryButton: .destructive(Text("Ja, radera aktivitet.")) {
                            self.onDelete(self.activity)
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel(Text("Avbryt"))
                    )
                }).onDisappear {
                    var a = activity
                    a.imageName = imageName
                    a.objectSentence = objectSentence
                    a.sentence = sentence
                    a.inventories = inventories
                    a.activityEmoji = activityEmoji
                    a.isActive = isActive
                    a.name = name
                    a.imageOrEmojiDescription = imageOrEmojiDescription
                    a.emoji = emoji
                    if activity == a || a.emoji == "" || a.sentence == ""{
                        return
                    }
                    binding_activity = a
                    self.onUpdate(a)
                }
            }
        }
    }
}

