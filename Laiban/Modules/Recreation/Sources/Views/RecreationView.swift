//
//  RecreationView.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-02.
//

import SwiftUI

import Assistant

public struct RecreationView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant: Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @State var activity: Recreation.Activity?
    @State var item: Recreation.Inventory.Item?
    @EnvironmentObject var viewState:LBViewState
    let recreations = Recreation.standard
    public init() {
        
    }
    public var body: some View {
        Group() {
            if horizontalSizeClass == .regular {
                RecreationRegularView(activity: activity, item: item)
            } else {
                RecreationCompactView(activity: activity, item: item)
            }
        }
        .onAppear {
            if let act = recreations.activities.randomElement() {
                activity = act
                if let inv = activity?.inventories.randomElement(), let inventory = recreations.inventories.first(where: { i in i.id == inv }) {
                    item = inventory.items.randomElement()
                } else {
                    item = nil
                }
                
                var sentences: [(String, String)] = []
                sentences.append(("recreation_nothing_to_do", "recreation_nothing_to_do"))

                if (activity != nil) {
                    let activitySentence = activity!.activityDescription(hasObject: item != nil, using: assistant)
                    sentences.append((activitySentence, activitySentence))
                }
                
                if (item != nil) {
                    let itemSentence = item!.itemDescription()
                    sentences.append((itemSentence, itemSentence))
                }
                viewState.characterHidden(true, for: .recreation)
                assistant.speak(sentences)
            }
            
            LBAnalyticsProxy.shared.logPageView(self)
        }
    }
}

struct RecreationView_Previews: PreviewProvider {
    static var contentProvider = 1
    
    static var previews: some View {
        LBFullscreenContainer { _ in 
            RecreationView()
        }
        .attachPreviewEnvironmentObjects()
    }
}
