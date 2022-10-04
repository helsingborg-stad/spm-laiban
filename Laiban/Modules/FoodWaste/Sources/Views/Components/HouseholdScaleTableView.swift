//
//  HouseholdScaleTableView.swift
//
//  Created by Tomas Green on 2021-03-17.
//

import SwiftUI

import Assistant

struct HouseholdScaleTableView: View {
    enum Action {
        case didPressScale
        case didPressIcon
    }
    typealias UserAction = (HouseholdScaleTableView.ViewModel,Action) -> Void
    struct ViewModel: Identifiable {
        let id:String = UUID().uuidString
        var date:Date
        func capitalizingFirstLetter(_ string:String) -> String {
            return string.prefix(1).capitalized + string.dropFirst()
        }
        func title(using locale:Locale) -> String {
            let d = DateFormatter()
            d.dateFormat = "EEEE"
            d.locale = locale
            return capitalizingFirstLetter(d.string(from: date))
        }
        var model:HouseholdScaleView.ViewModel
    }
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @ObservedObject var wasteManager:FoodWasteManager
    var statistics:[ViewModel]
    var userAction:UserAction
    var body: some View {
        VStack(spacing:0) {
            HStack(spacing: 20) {
                ForEach(statistics) { s in
                    HouseholdScaleView(model: s.model).frame(maxWidth:.infinity).onTapGesture {
                        userAction(s,.didPressScale)
                    }
                }
            }.frame(maxHeight:.infinity,alignment: .bottom).padding([.leading,.trailing])
            RoundedRectangle(cornerRadius: 2)
                .fill(Color("ScaleTabelColor",bundle:.module))
                .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color("ScaleTabelBorderColor",bundle:.module), lineWidth: 1))
                .frame(height:10).frame(maxWidth:.infinity)
            HStack(spacing: 20) {
                ForEach(statistics) { s in
                    VStack {
                        Text(s.title(using:locale))
                            .font(properties.font, ofSize: .s)
                            .lineLimit(1)
                            .frame(maxWidth:.infinity)
                        let size:CGFloat = horizontalSizeClass == .regular ? 50 : 40
                        let visible = s.date <= Date().startOfDay!
                        let color = wasteManager.isBalanced(for: s.date) ? Color("FeedbackColor4", bundle:.module) : Color("FeedbackColor1", bundle:.module)
                        Button {
                            userAction(s,.didPressIcon)
                        } label: {
                            LBEmojiBadgeView(emoji: "⚖️", rimColor: color).frame(width:size,height:size).onTapGesture {
                                userAction(s,.didPressIcon)
                            }
                        }
                        .opacity(visible ? 1 : 0)
                        .disabled(!visible)
                    }.frame(maxWidth:.infinity)
                }
            }
            .frame(maxWidth:.infinity).padding([.top]).padding([.leading,.trailing])
        }
    }
}
struct HouseholdScaleTableView_Previews: PreviewProvider {
    static var manager = FoodWasteManager()
    static var statistics:[HouseholdScaleTableView.ViewModel] {
        var arr = [HouseholdScaleTableView.ViewModel]()
        var date = Date().startOfWeek!
        arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: 200, baseLine: 1250,emojis: "🍏🍏🍓")))
        date = date.tomorrow!
        arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: 300, baseLine: 1250,emojis: "🍏🍗🍌🍏🍈🍈")))
        date = date.tomorrow!
        arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: 1800, baseLine: 1250,emojis: "🍓🥩🥕🥝🥩🥕🥝🍏🍏🍈🍈🍓🥩🥕🥝🥩🥕🥝🍏🍏🍈🍈")))
        date = date.tomorrow!
        arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: 0, baseLine: 1250)))
        date = date.tomorrow!
        arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: 0, baseLine: 1250)))
        return arr
    }
    static var previews: some View {
        LBFullscreenContainer { _ in
            HouseholdScaleTableView(wasteManager:manager, statistics: statistics) { scale,action in
                
            }
        }.attachPreviewEnvironmentObjects()
    }
}
