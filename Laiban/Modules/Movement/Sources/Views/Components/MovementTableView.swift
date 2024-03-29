//
//  MovementTableView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-28.
//

import SwiftUI
import Assistant

extension Animation {
    static func ripple(index: Int, damping: Double = 0.5, speed: Double = 1.2) -> Animation {
            Animation.spring(dampingFraction: damping)
            .speed(speed)
            .delay(0.15 * Double(index))
        }
}

struct MovementTableView: View {
    enum Action {
        case didPressBar
        case didPressIcon
    }
    typealias UserAction = (MovementTableView.ViewModel, Action) -> Void
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
        var model:MovementBarView.ViewModel
    }

    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @Environment(\.isEnabled) var isEnabled
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @ObservedObject var movementManager:MovementManager
    var statistics:[ViewModel]
    var userAction:UserAction?
    var body: some View {
        VStack(spacing:0) {
            HStack(spacing: 20) {
                ForEach(statistics) { s in
                    MovementBarView(model: s.model).frame(maxWidth:.infinity).onTapGesture {
                        userAction?(s,.didPressBar)
                    }.animation(.ripple(index: statistics.firstIndex {$0.id == s.id} ?? 1))
                        .opacity(isEnabled ? 1 : 0.8)
                }
            }.frame(maxHeight:.infinity,alignment: .bottom).padding([.leading,.trailing])
            HStack(spacing: 20) {
                ForEach(statistics) { s in
                    VStack {
                        Text(s.title(using:locale))
                            .font(properties.font, ofSize: .xs)
                            .lineLimit(1)
                            .frame(maxWidth:.infinity)
                            .padding([.leading,.trailing],0)
                        let size:CGFloat = horizontalSizeClass == .regular ? (LBDevice.isIpad ? 40 : 30) : 30
                        let visible = s.date <= Date().startOfDay!
                        let color = Color.black
                        Button {
                            userAction?(s,.didPressIcon)
                        } label: {
                            LBEmojiBadgeView(emoji: "🏃‍♀️", rimColor: color).frame(width:size,height:size).onTapGesture {
                                userAction?(s,.didPressIcon)
                            }
                        }
                        .opacity(visible ? 1 : 0)
                        .disabled(!visible)
                    }.frame(maxWidth:.infinity)
                }
            }
            .frame(maxWidth:.infinity).padding([.top]).padding([.leading,.trailing])
        }.padding(20)
    }
}

struct MovementTableView_Previews: PreviewProvider {
    static var manager = MovementManager()
    static var statistics: [MovementTableView.ViewModel] {
        var arr = [MovementTableView.ViewModel]()
        var date = Date().startOfWeek!
        arr.append(MovementTableView.ViewModel(date: date, model: MovementBarView.ViewModel(movementMeters: 24, settings: MovementSettings())))
        date = date.tomorrow!
        
        arr.append(MovementTableView.ViewModel(date: date, model: MovementBarView.ViewModel(movementMeters: 60, settings: MovementSettings())))
        date = date.tomorrow!
        
        arr.append(MovementTableView.ViewModel(date: date, model: MovementBarView.ViewModel(movementMeters: 45, settings: MovementSettings())))
        date = date.tomorrow!
        
        arr.append(MovementTableView.ViewModel(date: date, model: MovementBarView.ViewModel(movementMeters: 100, settings: MovementSettings())))
        date = date.tomorrow!
        
        arr.append(MovementTableView.ViewModel(date: date, model: MovementBarView.ViewModel(movementMeters: 120, settings: MovementSettings())))
        date = date.tomorrow!
        
        return arr
    }
    
    static var previews: some View {
        LBFullscreenContainer { _ in
            MovementTableView(movementManager:manager, statistics: statistics) { scale,action in
                
            }
        }.attachPreviewEnvironmentObjects()
    }
}
