//
//  RecreationRegularView.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-02.
//

import SwiftUI
import SDWebImageSwiftUI
import Assistant

struct RecreationRegularView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var assistant: Assistant
    @Environment(\.locale) var locale
    let activity: Recreation.Activity?
    let item: Recreation.Inventory.Item?
    
    var justText:Bool {
        return item?.imageName == nil && (item?.emoji == nil || item?.emoji == "")
    }
    
    var body: some View {
        VStack (alignment: .center, spacing: 13) {
            
            
            Text(LocalizedStringKey("recreation_nothing_to_do"),bundle: LBBundle)
                .font(properties.font, ofSize: .n, weight: .heavy)
                .padding(.top, properties.spacing[.m])
            GeometryReader() { proxy in
                if activity == nil {
                    Text("Vet inte")
                } else {
                    VStack(spacing: properties.spacing[.m]) {
                        Text( activity!.activityDescription(hasObject: item != nil, using: assistant))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .font(properties.font, ofSize: .n)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        if let unwrappedItem = item, let imageName = unwrappedItem.imageName, let image = Recreation.Activity.imageStorage.image(with: imageName){
                            
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width:proxy.size.height*0.5,height:proxy.size.height*0.5)
                                .clipped()
                                .cornerRadius(20)
                                .shadow(radius: 4)
                            
                        }else if let unwrappedItem = item, let emoji = unwrappedItem.emoji, emoji != "" {
                          
                            Text(emoji)
                                .font(Font.system(size: proxy.size.height*0.3))
                                .frame(width:proxy.size.height*0.5,height:proxy.size.height*0.5)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 4)
                            
                        }else if let imageName = activity?.imageName, let image = Recreation.Activity.imageStorage.image(with: imageName){
                            
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width:proxy.size.height*0.5,height:proxy.size.height*0.5)
                                .clipped()
                                .cornerRadius(20)
                                .shadow(radius: 4)
                            
                            if let imageDescrition = activity?.imageOrEmojiDescription {
                                Text(assistant.string(forKey: imageDescrition))
                                    .font(properties.font, ofSize: .l)
                            }else if let sentence = activity?.objectSentence {
                                Text(assistant.string(forKey: sentence))
                                    .font(properties.font, ofSize: .l)
                            }
                            
                        }else if let activityEmoji = activity?.activityEmoji, activityEmoji != "?" && activityEmoji != ""{
                            
                            Text(activityEmoji)
                                .font(Font.system(size: proxy.size.height*0.3))
                                .frame(width:proxy.size.height*0.5,height:proxy.size.height*0.5)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(radius: 4)
                            
                            if let emojiDescrition = activity?.imageOrEmojiDescription {
                                Text(assistant.string(forKey: emojiDescrition))
                                    .font(properties.font, ofSize: .l)
                            }else if let sentence = activity?.objectSentence {
                                Text(assistant.string(forKey: sentence))
                                    .font(properties.font, ofSize: .l)
                            }
                        }
                        
                        if let unwrappedItem = item  {
                            
                            if self.justText {
                                Text(assistant.string(forKey: unwrappedItem.itemDescription()))
                                    .font(properties.font, ofSize: .n)
                                    .background(Color.white)
                                    .cornerRadius(36)
                                    .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 0)
                            } else {
                                Text(assistant.string(forKey: unwrappedItem.itemDescription()))
                                    .font(properties.font, ofSize: .l)
                            }
                        }
                    }
                    .padding([.leading,.trailing,.top],properties.spacing[.m])
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: self.justText ? .top : .center)
                    .wrap(scrollable: false, overlay: .emoji(activity?.emoji ?? "?", Color("RimColorActivities",bundle:LBBundle)),overlayScale: .small,background: .secondary)
                    .padding(properties.spacing[.m])
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .wrap(overlay: .laibanFace(.wink))
    }
}

struct RecreationRegularView_Previews: PreviewProvider {
    static let item: Recreation.Inventory.Item = .init(prefix: "en", name: "elefant",emoji:"🐘")
//    static let activity: Recreation.Activity = .init(name: "Måla", sentence: "Gå till ateljén tillsammans med en kompis och rita. Ni kanske kan rita...",  emoji: "✏️", isActive: true, imageName: "4210AAE1-4264-477D-AA5B-582EB7744F5F.jpeg",activityEmoji: "" )
    static let activity: Recreation.Activity = .init(name: "Måla", sentence: "Gå till ateljén tillsammans med en kompis och rita. Ni kanske kan rita...",  emoji: "✏️", isActive: true ,activityEmoji: "" )
    
    static var previews: some View {
        LBFullscreenContainer { _ in
            RecreationRegularView(activity: activity, item: nil)
        }
        .attachPreviewEnvironmentObjects()
    }
}
