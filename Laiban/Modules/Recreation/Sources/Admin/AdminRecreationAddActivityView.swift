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
    @State var newActivity:Recreation.Activity = .init(name: "", sentence: "", emoji: "", isActive: true)
    @State var imageOrEmojiDescription:String = String()
    @State private var showImagePicker: Bool = false
        
    var body: some View {
        
        GeometryReader() { proxy in
            
            VStack {
                Form{
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
                                        .frame(width:100,height:100)
                                        .clipped()
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
                        TextField("🎲", text:$newActivity.emoji)
                    }
                    
                    Section{
                        TextField("Lägg till en ny aktivitet", text:$newActivity.sentence)
                    }header: {
                        Text("Aktivitet")
                    }footer: {
                        Text("Exempel: Gå och spela ett spel tillsammans med en kompis.")
                    }

                
                    Section{
                        Button(action: {
        //                    if self.item.image == nil {
                                self.showImagePicker = true
            //                } else {
            //                    self.item.deleteImage()
            //                }
                        }) {
            //                Text(self.item.image == nil ? "Lägg till bild" : "Radera bild").foregroundColor(self.item.image == nil ? .accentColor : .red)
                            Text("Välj bild")
                        }
                        TextField("Bildbeskrivning", text:$imageOrEmojiDescription)
                    }header: {
                        Text("Lägg till bild")
                    }
                    
                    Section {
                        List{
                            ForEach(InventoryType.allCases) { type in
                                HStack{
                                    Text(type.rawValue)
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .invisible(!newActivity.inventories.contains(where: {$0 == type.rawValue}))
                                }.onTapGesture {
                                    if newActivity.inventories.contains(where: {$0 == type.rawValue}){
                                        newActivity.inventories.removeAll(where: {$0 == type.rawValue})
                                    }else{
                                        newActivity.inventories.append(type.rawValue)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Inventarier")
                    } footer: {
                        Text("Valfritt: Välj vilka typer av föremål som ska vara tillgängliga för aktiviteten. (Ett föremål är de bilder som slumpas fram tillsammans med en aktivitet, till exempel en bil, ett tåg eller en häst.)")
                    }
                }.navigationBarTitle(Text("Lägg till ny 'Laiban föreslår-aktivitet'"))
                    .listStyle(GroupedListStyle())
                    .navigationBarItems(trailing:
                    Button(action: {
                        
                   
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
