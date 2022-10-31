//
//  MovementTableView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-28.
//

import SwiftUI
import Assistant

extension Animation {
    static func ripple(index: Int) -> Animation {
            Animation.spring(dampingFraction: 0.4)
            .speed(1.5)
            .delay(0.08 * Double(index))
        }
}

struct MovementTableView: View {
    enum Action {
        case didPressScale
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
        var model:MovementScaleView.ViewModel
    }

    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @ObservedObject var movementManager:MovementManager
    var statistics:[ViewModel]
    var userAction:UserAction?
    var body: some View {
        VStack(spacing:0) {
            HStack(spacing: 20) {
                ForEach(statistics) { s in
                    MovementScaleView(model: s.model).frame(maxWidth:.infinity).onTapGesture {
                        userAction?(s,.didPressScale)
                    }.animation(.ripple(index: statistics.firstIndex {$0.id == s.id} ?? 1))
                }
            }.frame(maxHeight:.infinity,alignment: .bottom).padding([.leading,.trailing])
            HStack(spacing: 20) {
                ForEach(statistics) { s in
                    VStack {
                        Text(s.title(using:locale))
                            .font(properties.font, ofSize: .xs)
                            .lineLimit(1)
                            .frame(maxWidth:.infinity)
                        let size:CGFloat = horizontalSizeClass == .regular ? 50 : 40
                        let visible = s.date <= Date().startOfDay!
                        let color = movementManager.isBalanced(for: s.date) ? Color("FeedbackColor4", bundle:.module) : Color("FeedbackColor1", bundle:.module)
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
        arr.append(MovementTableView.ViewModel(date: date, model: MovementScaleView.ViewModel(movementTime: 24)))
        date = date.tomorrow!
        
        arr.append(MovementTableView.ViewModel(date: date, model: MovementScaleView.ViewModel(movementTime: 45)))
        date = date.tomorrow!
        
        arr.append(MovementTableView.ViewModel(date: date, model: MovementScaleView.ViewModel(movementTime: 60)))
        date = date.tomorrow!
        
        arr.append(MovementTableView.ViewModel(date: date, model: MovementScaleView.ViewModel(movementTime: 100)))
        date = date.tomorrow!
        
        arr.append(MovementTableView.ViewModel(date: date, model: MovementScaleView.ViewModel(movementTime: 120)))
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
