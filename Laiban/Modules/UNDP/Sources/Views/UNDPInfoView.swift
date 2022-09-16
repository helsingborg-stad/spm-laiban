//
//  UNDPInfoView.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-02.
//


import SwiftUI
import Assistant

struct UNDPInfoRegularView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    var item: UNDPGoal
    var body: some View {
        GeometryReader { p in
            HStack(alignment: .center, spacing: 20) {
                VStack(spacing: 10) {
                    Text(LocalizedStringKey(item.titleKey),bundle: LBBundle)
                        .font(properties.font, ofSize: .l)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    Text(LocalizedStringKey(item.descriptionKey),bundle: LBBundle)
                        .font(properties.font, ofSize: .n)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .lineLimit(nil)
                }.frame(maxWidth: .infinity)

                UNDPCircleView(goal: item, size: (p.size.width) * 0.20)
                    .shadow(radius: 5)
            }
            .padding(properties.spacing[.m])
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

struct UNDPInfoBubbleView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var item: UNDPGoal
    var body: some View {
        if horizontalSizeClass == .regular {
            UNDPInfoRegularView(item: item)
        } else {
            UNDPInfoCompactView(item: item)
        }
    }
}

struct UNDPInfoCompactView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    var item: UNDPGoal
    var body: some View {
        GeometryReader { p in
            HStack(alignment: .top, spacing: p.size.width * 0.03) {
                VStack(alignment: .leading) {
                    Text(LocalizedStringKey(item.titleKey),bundle: LBBundle)
                        .font(properties.font, ofSize: .l)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    Text(LocalizedStringKey(item.descriptionKey),bundle: LBBundle)
                        .font(properties.font, ofSize: .n)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .lineLimit(nil)
                }
                UNDPCircleView(goal: item, size: (p.size.width) * 0.23)
                    .shadow(radius: 5)

            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow()
    }
}

public struct UNDPInfoView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant: Assistant
    @State var items: [UNDPGoal] = UNDPGoal.allCases
    @State var selectedItem: UNDPGoal? {
        didSet {
            if let item = selectedItem {
                assistant.speak([
                    item.titleKey,
                    item.descriptionKey,
                ])
            }
        }
    }
    public init() {
        
    }
    public var body: some View {
        let spacing: CGFloat = horizontalSizeClass == .regular ? 20 : 5
        VStack {
            LBGridView(items: items.count, columns: 6, verticalSpacing: spacing, horizontalSpacing: spacing, verticalAlignment: .top, horizontalAlignment: .center) { index in
                Button(action: {
                    selectedItem = items[index]
                    LBAnalyticsProxy.shared.logContentImpression("UNDPGoalInfo", piece: "\(items[index].rawValue)")
                }, label: {
                    UNDPCircleView(goal: items[index], size: (properties.contentSize.width / 6) * 0.5)
                        .shadow(radius: assistant.isSpeaking ? 0 : 5)
                })
            }
            .frame(maxWidth: .infinity)
            .padding(.top, properties.contentSize.height * 0.03)
            if selectedItem != nil {
                UNDPInfoBubbleView(item: selectedItem!)
                    .padding(.top, properties.contentSize.height * 0.03)
            } else {
                Text(LocalizedStringKey("undp_press_to_learn_more"),bundle: LBBundle)
                    .font(properties.font, ofSize: .l)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .onAppear {
            assistant.speak([
                ("undp_press_to_learn_more", "undp_press_to_learn_more"),
            ])
            LBAnalyticsProxy.shared.logPageView(self)
        }
    }
}

struct UNDPInfoView_Previews: PreviewProvider {
    static var previews: some View {
        LBFullscreenContainer { _ in
            UNDPInfoView()
        }.attachPreviewEnvironmentObjects()
    }
}
