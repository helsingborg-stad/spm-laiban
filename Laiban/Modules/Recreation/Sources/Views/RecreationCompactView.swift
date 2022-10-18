//
//  RecreationCompactView.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-05.
//

import SwiftUI

import Assistant

struct RecreationCompactView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var assistant: Assistant
    @Environment(\.locale) var locale
    let activity: Recreation.Activity?
    let item: Recreation.Inventory.Item?
    
    var body: some View {
        VStack(alignment: .center, spacing: 13) {
            Text(LocalizedStringKey("recreation_nothing_to_do"),bundle: LBBundle)
                .font(properties.font, ofSize: .n, weight: .heavy)
            if activity == nil {
                Text("Vet inte")
            } else {
                Text(activity!.activityDescription(hasObject: item != nil, using: assistant))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .font(properties.font, ofSize: .n)
                    .frame(maxWidth: .infinity, alignment: .center)
                if item?.imageName != nil   {
                    Image(item!.imageName!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:200,height:200)
                        .clipped()
                        .cornerRadius(20)
                        .shadow(radius: 4)
                } else if item?.emoji != nil   {
                    Text(item!.emoji!)
                        .font(Font.system(size: 100))
                        .frame(width:200,height:200)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 4)
                }
                if item != nil   {
                    Text(assistant.string(forKey: item!.itemDescription()))
                }
            }
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .wrap(scrollable: true, overlay: .emoji(activity?.emoji ?? "?", Color("RimColorActivities",bundle:LBBundle)))
    }
}

@available(iOS 15.0, *)
struct RecreationCompactView_Previews: PreviewProvider {
    static let item: Recreation.Inventory.Item = .init(prefix: "en", name: "elefant",emoji:"🐘")
    static let activity: Recreation.Activity = .init(name: "Måla", sentence: "Gå till ateljén tillsammans med en kompis och rita. Ni kanske kan rita...",  emoji: "✏️", isActive: true)
    
    static var previews: some View {
        LBFullscreenContainer { _ in
            RecreationCompactView(activity: activity, item: item)
        }
        .previewDevice("iPod touch (7th generation)")
        .attachPreviewEnvironmentObjects()
    }
}
