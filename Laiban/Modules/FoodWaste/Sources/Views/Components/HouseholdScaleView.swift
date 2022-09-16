//
//  HouseholdScaleView.swift
//
//  Created by Tomas Green on 2021-03-15.
//

import SwiftUI
import Combine

struct HouseholdScaleBodyView<Content: View>: View {
    let content: (GeometryProxy) -> Content
    init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: proxy.size.width * -0.01){
                RoundedRectangle(cornerRadius: proxy.size.width * 0.05)
                    .fill(Color("ScaleBodyColor",bundle:.module))
                    .overlay(RoundedRectangle(cornerRadius: proxy.size.width * 0.05).stroke(Color("ScaleBodyBorderColor",bundle:.module), lineWidth: 1))
                    .zIndex(1)
                    .overlay(content(proxy).frame(maxWidth:.infinity,maxHeight: .infinity).padding(proxy.size.width * 0.05))
                HStack(spacing:0) {
                    RoundedRectangle(cornerRadius: proxy.size.width * 0.01)
                        .fill(Color("ScaleBodyBorderColor",bundle:.module))
                        .frame(width: proxy.size.width * 0.1, height: proxy.size.width * 0.1)
                    Spacer()
                    RoundedRectangle(cornerRadius: proxy.size.width * 0.01)
                        .fill(Color("ScaleBodyBorderColor",bundle:.module))
                        .frame(width: proxy.size.width * 0.1, height: proxy.size.width * 0.1)
                }.padding([.leading,.trailing], proxy.size.width * 0.1)
            }
        }.aspectRatio(1, contentMode: .fit).frame(maxWidth:.infinity)
    }
}
struct HouseholdScaleGuageView : View {
    var percentage:Double
    var guageRotation:Double {
        let val = -90 + percentage * 90
        if val < -90 {
            return -90
        } else if val > 90 {
            return 90
        }
        return val
    }
    var body: some View {
        ZStack() {
            Image("HouseholdScaleGuageBackground", bundle:.module)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(1,contentMode: .fit)
                .frame(maxWidth:.infinity,maxHeight: .infinity)
                .zIndex(1)
            Image("ScaleGuageMeter2", bundle:.module)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(1,contentMode: .fit)
                .frame(maxWidth:.infinity,maxHeight: .infinity)
                .zIndex(2)
                .rotationEffect(Angle(degrees: guageRotation))
                .animation(.interpolatingSpring(mass: 0.2, stiffness: 2, damping: 0.8, initialVelocity: 2))
        }
    }
}


struct HouseholdScaleView: View {
    @ObservedObject var model:ViewModel
    var scaleGlassContainer: some View {
        
        GeometryReader { proxy in
            ZStack(alignment:.bottom) {
                let imageHeight:CGFloat = 212
                let imageWidth:CGFloat = 110
                let vial:CGFloat = imageHeight/imageWidth * proxy.size.width
                let proc = CGFloat(1 - model.percentage * 0.5)
                let diff = (proxy.size.height - vial ) * (proc < 0 ? 0 : proc)
                HouseholdScaleGameContainer(model: model).frame(maxHeight:.infinity,alignment: .bottom)
                    .aspectRatio(imageWidth/imageHeight,contentMode: .fit)
                    
                    .overlay(
                        Image("HouseholdScaleContainer",bundle: .module)
                            .resizable()
                            .aspectRatio(imageWidth/imageHeight,contentMode: .fit)
                    )
                    .offset(y:diff * -1)
                HStack {
                    Rectangle().fill(Color("ScaleBodyBorderColor",bundle: .module)).frame(maxHeight:.infinity).frame(width:proxy.size.width * 0.08)
                }
                .padding([.leading,.trailing],proxy.size.width * 0.3)
                .frame(height:diff,alignment: .bottom)
            }.frame(maxWidth:.infinity, maxHeight:.infinity,alignment: .bottom)
        }.frame(maxWidth:.infinity, maxHeight:.infinity,alignment: .bottom)
    }
    var body: some View {
        VStack(spacing:0) {
            scaleGlassContainer
            HouseholdScaleBodyView { proxy in
                VStack {
                    HouseholdScaleGuageView(percentage:model.percentage)
                    ScaleValueView(value: model.wasteWeight, unit: "g").frame(height: proxy.size.height * 0.3)
                }.frame(maxWidth:.infinity,maxHeight: .infinity)
            }.frame(maxWidth:.infinity)
        }
        .aspectRatio(110/380, contentMode: .fit)
        .onReceive(model.$objects) { value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.interpolatingSpring(mass: 0.2, stiffness: 2, damping: 0.8, initialVelocity: 2)) {
                    self.model.updatePercentage()
                }
            }
        }
    }
}
extension HouseholdScaleView {
    class ViewModel : ObservableObject {
        struct Item : Identifiable,Equatable {
            let id:String
            let emoji:String
            let image:String
            let weight:Double
            let scaleFactor:CGFloat
            init(object:BalanceScaleObjects) {
                self.id = UUID().uuidString
                self.emoji = object.emoji
                self.image = object.image
                self.weight = object.weight
                self.scaleFactor = object.scaleFactor
            }
            init?(_ emoji:String) {
                guard let object = FoodWasteScaleObjects.convert(emoji: emoji) else {
                    return nil
                }
                self.id = UUID().uuidString 
                self.emoji = object.emoji
                self.image = object.image
                self.weight = object.weight
                self.scaleFactor = object.scaleFactor
            }
        }
        @Published var objects:[Item] = []
        private (set) var wasteObjects:[Item] = []
        let wasteWeight:Double
        let baseLine:Double
        @Published private(set) var percentage:Double
        @Published var paused:Bool = false
        init(wasteWeight:Double,baseLine:Double, emojis:String? = nil) {
            self.wasteWeight = wasteWeight
            self.baseLine = baseLine
            self.percentage = 0
            if let emojis = emojis {
                emojis.forEach { c in
                    if let o = HouseholdScaleView.ViewModel.Item(String(c)) {
                        self.wasteObjects.append(o)
                    }
                }
            }
        }
        func reset() {
            self.objects = []
            self.percentage = 0
        }
        private var calculatedTotalWeight:Double {
            var w:Double = 0
            for o in objects {
                w += o.weight
            }
            return w
        }
        func updatePercentage() {
            if self.baseLine == 0 {
                self.percentage = 0
            } else {
                self.percentage = self.calculatedTotalWeight / self.baseLine
            }
        }
        func dropObjects() {
            var t:TimeInterval = 0
            let d = DispatchTime.now()
            for s in wasteObjects {
                DispatchQueue.main.asyncAfter(deadline: d + t) {
                    self.objects.append(s)
                }
                t += 0.2
            }
            DispatchQueue.main.asyncAfter(deadline: d + t + 2) {
                self.paused = true
            }
        }
    }
}


struct HouseholdScaleView_Previews: PreviewProvider {
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
        HouseholdScaleTableView(wasteManager:manager, statistics: statistics) { scale,action in
            
        }
    }
}
