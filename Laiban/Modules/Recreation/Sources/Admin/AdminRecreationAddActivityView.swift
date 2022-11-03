//
//  SwiftUIView.swift
//  
//
//  Created by jonatan lidholm jansson on 2022-10-13.
//

import SwiftUI

enum ActivityContentSelection: String, CaseIterable, Hashable {
    case image = "Bild", emoji = "Emoji", objects = "Objekt/Föremål"
    public var id: Self { self }
}

struct WorkingActivity {
    
    let id:String
    var emoji:String {
        didSet{
            self.currentActivity.emoji = emoji
        }
    }
    var name:String{
        didSet{
            self.currentActivity.name = name
        }
    }
    
    var sentence:String {
        didSet{
            self.currentActivity.sentence = sentence
        }
    }
    
    var objectSentence:String {
        didSet{
            self.currentActivity.objectSentence = objectSentence
        }
    }
    var activityEmoji:String {
        didSet{
            self.currentActivity.activityEmoji = activityEmoji
        }
    }
    var imageName:String {
        didSet{
            self.currentActivity.imageName = imageName
        }
    }
    var imageOrEmojiDescription:String {
        didSet{
            self.currentActivity.imageOrEmojiDescription = imageOrEmojiDescription
        }
    }
    var inventories:[String]{
        didSet{
            self.currentActivity.inventories = inventories
        }
    }
    
    var isActive:Bool{
        didSet{
            self.currentActivity.isActive = isActive
        }
    }
    
    var service:RecreationService
    var currentActivity:Recreation.Activity {
        didSet{
            save()
        }
    }
    
    func save(){
        service.saveActivity(activity: currentActivity)
    }
    
    init(service:RecreationService, activity:Recreation.Activity){
        self.id = activity.id
        self.service = service
        self.currentActivity = activity
        self.name = activity.name
        self.emoji = activity.emoji
        self.isActive = activity.isActive
        self.activityEmoji = activity.activityEmoji
        self.sentence = activity.sentence
        self.objectSentence = activity.objectSentence ?? ""
        self.imageName = activity.imageName ?? ""
        self.imageOrEmojiDescription = activity.imageOrEmojiDescription ?? ""
        self.inventories = activity.inventories
    }
}


struct AdminRecreationAddActivityView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var service:RecreationService
    @State var activity:Recreation.Activity

    var inventoryCategories = InventoryCategory()
    @State private var segmentedControlSelection = ActivityContentSelection.image
    @State private var showImagePicker: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    @State var workingActivity:WorkingActivity
    @State private var isEditigMode: Bool = false
    
    
    var ImagePickerView: some View {
        
        Section{
            
            Button(action: {
                
                if workingActivity.imageName == "" {
                    self.showImagePicker = true
                } else {
                    self.activity.deleteImage()
                }
                
            }) {
                Text(workingActivity.imageName == "" ? "Välj bild" : "Radera bild").foregroundColor(workingActivity.imageName == "" ? .accentColor : .red)
            }
            TextField("Beskrivning av bild", text:$workingActivity.imageOrEmojiDescription)
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
                            .invisible(!workingActivity.inventories.contains(where: {$0 == type.id}))
                    }.onTapGesture {
                        if workingActivity.inventories.contains(where: {$0 == type.id}){
                            workingActivity.inventories.removeAll(where: {$0 == type.id})
                            workingActivity.activityEmoji = ""
                        }else{
                            
                            workingActivity.inventories.append(type.id)
                            workingActivity.activityEmoji = "?"
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
            TextField(workingActivity.inventories.count > 0 ? "Välj emoji" : workingActivity.activityEmoji == "" ? "Välj emoji" : workingActivity.activityEmoji, text:$workingActivity.activityEmoji)
            TextField("Beskrivning av emoji", text:$workingActivity.imageOrEmojiDescription)
        } footer: {
            Text("Beskriv den valda emojin, till exempel : 'En tärning'.")
        }
    }
    
    
    var ToggleActivityIsActiveView: some View {
        Section{
            HStack{
                Text("Aktiverad").foregroundColor(workingActivity.isActive ? .black : .gray)
                Spacer()
                Toggle("", isOn: $workingActivity.isActive)
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
                                    
                                    Text(workingActivity.sentence)
                                    workingActivity.objectSentence != "" ? Text(workingActivity.objectSentence) : nil
                                    
                                    if  workingActivity.imageName != "" , let image = Recreation.Activity.imageStorage.image(with: workingActivity.imageName){
                                        
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width:proxy.size.height*0.1,height:proxy.size.height*0.1)
                                            .clipped()
                                            .cornerRadius(20)
                                            .shadow(radius: 4)
                                        
                                    }else if let activityEmoji = workingActivity.activityEmoji, activityEmoji != ""{
                                        
                                        Text(activityEmoji)
                                            .font(Font.system(size: proxy.size.height*0.05))
                                            .frame(width:proxy.size.height*0.1,height:proxy.size.height*0.1)
                                            .background(Color.white)
                                            .cornerRadius(20)
                                            .shadow(radius: 4)
                                    }
                                    
                                    Text(workingActivity.imageOrEmojiDescription)
                                    
                                }.frame(maxWidth: proxy.size.width, maxHeight: proxy.size.height)
                                    .wrap(scrollable: false, overlay: .emoji(workingActivity.emoji, Color("RimColorActivities",bundle:LBBundle)))
                            
                            horizontalSizeClass == .regular ? Spacer(minLength:proxy.size.width*0.3) : nil
                        }
                    }
                    .listRowBackground(Color.clear)
                    .frame(height: horizontalSizeClass == .regular ? proxy.size.width*0.5 : proxy.size.width)
                        
                    Section{
                        TextField("Emoji", text:$workingActivity.emoji)
                        TextField("Hitta på något att göra", text:$workingActivity.sentence)
                        workingActivity.objectSentence != "" ? TextField(workingActivity.objectSentence, text: $workingActivity.objectSentence ) : nil
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
                    DeleteActivityView
                    
                }.navigationBarTitle(Text("Lägg till ny 'Laiban föreslår-aktivitet'"))
                    .listStyle(GroupedListStyle())
                    .navigationBarItems(trailing:
                    Button(action: {
                        
                        switch (segmentedControlSelection){
                            case .emoji:
                                workingActivity.inventories = []
                            case .objects:
                                workingActivity.activityEmoji = ""
                            default:
                            break
                        }
                       
                        service.addActivity(newActivity: self.workingActivity.currentActivity, callback: {
                            presentationMode.wrappedValue.dismiss()
                        })
                    
                    }, label: {
                        Text("Lägg till")
                    }).disabled(workingActivity.sentence == "" || workingActivity.emoji == "").invisible(isEditigMode)
                )
                .sheet(isPresented: self.$showImagePicker){
                    PhotoCaptureView(showImagePicker: self.$showImagePicker, imageStorage: Recreation.Activity.imageStorage) { asset in
                        print(asset)
                        workingActivity.imageName = asset
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
                    self.isEditigMode = activity.emoji != "" && activity.sentence != ""
                    
                    segmentedControlSelection = workingActivity.inventories.count > 0 ? .objects : workingActivity.activityEmoji != "" ? .emoji : .image
                })
            }
        }
    }
}

struct AdminRecreationAddActivityView_Previews: PreviewProvider {
    static var service = RecreationService()
    static var activity:Recreation.Activity = .init(name: "", sentence: "", emoji: "", isActive: true, activityEmoji: "")
    
    static var workingActivity:WorkingActivity = WorkingActivity(service:service, activity: activity)
    static var previews: some View {
        AdminRecreationAddActivityView(service: service, activity: activity, workingActivity: workingActivity )
    }
}
