//
//  BalanceScaleView.swift
//
//  Created by Tomas Green on 2021-03-03.
//

import SwiftUI
import SpriteKit
import Combine

struct BalanceScaleBodyView<Content: View>: View {
    let content: (GeometryProxy) -> Content
    init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }
    var ratio:CGFloat = 100/400
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: proxy.size.width * -0.01){
                RoundedRectangle(cornerRadius: proxy.size.width * 0.02)
                    .fill(Color("ScaleBodyColor",bundle:.module))
                    .overlay(RoundedRectangle(cornerRadius: proxy.size.width * 0.02).stroke(Color("ScaleBodyBorderColor",bundle:.module), lineWidth: 1))
                    .zIndex(1)
                    .overlay(content(proxy).frame(maxWidth:.infinity,maxHeight: .infinity).padding(proxy.size.width * 0.05))
                HStack(spacing:0) {
                    RoundedRectangle(cornerRadius: proxy.size.width * 0.01).frame(width: proxy.size.width * 0.05, height: proxy.size.width * 0.03)
                    Spacer()
                    RoundedRectangle(cornerRadius: proxy.size.width * 0.01).frame(width: proxy.size.width * 0.05, height: proxy.size.width * 0.03)
                }.padding([.leading,.trailing], proxy.size.width * 0.03)
            }
        }.aspectRatio(400/100, contentMode: .fit).frame(maxWidth:.infinity)
    }
}
struct BalanceScaleArmView<Content: View> : View {
    let content: () -> Content
    let percentage:CGFloat
    let physics:Bool
    init(percentage:CGFloat, physics:Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.percentage = percentage
        self.physics = physics
    }
    func height(minHeight:CGFloat, maxHeight:CGFloat) -> CGFloat {
        return percentage * (maxHeight - minHeight) / 2
    }
    var body: some View {
        GeometryReader { proxy in
            let bottomHeight:CGFloat = 30/295 * proxy.size.width
            let contentHeight = proxy.size.height * 0.7
            
            let maxHeight = proxy.size.height - bottomHeight
            let minHeight = contentHeight
            let h = height(minHeight:minHeight,maxHeight: maxHeight)
            ZStack(alignment:.bottom) {
                content()
                    
                    .frame(maxWidth:.infinity,maxHeight: .infinity)
                    .frame(height: minHeight)
                    .offset(y: (proxy.size.height - h - minHeight - (physics ? bottomHeight : 0)) * -1)
                Image("BalanceScaleArmTop", bundle:.module)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(295/30, contentMode: .fit)
                    .frame(width: proxy.size.width)
                    .foregroundColor(Color("ScaleBodyBorderColor", bundle:.module))
                    .offset(y: (proxy.size.height - h - minHeight - bottomHeight) * -1)
                Rectangle()
                    .fill(Color("ScaleBodyBorderColor", bundle:.module))
                    .frame(width:proxy.size.width * 0.04,height:proxy.size.height - h - minHeight)
            }
            .frame(maxWidth:.infinity,maxHeight: .infinity, alignment:.bottom)
        }.frame(maxWidth:.infinity,maxHeight: .infinity, alignment:.bottom)
    }
}

struct BalanceScaleGuageView : View {
    var left:Double
    var right:Double
    var guageRotation:Double {
        let proc:Double
        if left == 0 {
            proc = right != 0 ? 0 : 1
        } else {
            proc = right/left
        }
        let val = proc * 90 - 90
        if val > 90 {
            return 90
        }
        if val < -90 {
            return -90
        }
        return val
    }
    var body: some View {
        
        ZStack() {
            Image("BalanceScaleGuageBackground", bundle:.module)
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
protocol BalanceScaleObjects {
    var id:String { get }
    var emoji:String { get }
    var image:String { get }
    var weight:Double { get }
    var scaleFactor:CGFloat { get }
}
extension String {
    func image(_ size:CGFloat) -> UIImage? {
        let size = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: size.height * 0.9)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
struct BalanceScaleView : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var model:ViewModel
    func weightDistribution(left:Double,right:Double) -> Double {
        let left:Double = Double(left)
        let right:Double = Double(right)
        let proc = right/left
        let maxWeight = left * 2
        let val = proc * maxWeight - maxWeight
        if val > maxWeight {
            return maxWeight
        }
        if val < maxWeight * -1 {
            return maxWeight * -1
        }
        return val
    }
    var valuePercentage:CGFloat {
        if model.wasteWeight == 0 {
            return model.totalWeight == 0 ? 0.5 : 0
        }
        let w = weightDistribution(left: model.wasteWeight, right: model.totalWeight) / (model.wasteWeight * 2) + 1
        return CGFloat(w)
    }
    var trashPercentage:CGFloat {
        if model.wasteWeight == 0 {
            return model.totalWeight == 0 ? 0.5 : 2
        }
        let w = weightDistribution(left: model.wasteWeight, right: model.totalWeight) / (model.wasteWeight * 2) + 1
        return 1 + (1 - CGFloat(w))
    }
    func animateChanges(deletion:Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (deletion ? 0.01 : 0.4)) {
            withAnimation(.interpolatingSpring(mass: 0.2, stiffness: 2, damping: 0.8, initialVelocity: 2)) {
                self.model.updateWeight()
            }
        }
    }
    var trashImage:Image? {
        if model.wasteWeight == 0 {
            return nil
        }
        if model.wasteWeight < 500 {
            return Image("BalanceScaleTrashSmall", bundle:.module)
        }
        if model.wasteWeight < 1000 {
            return Image("BalanceScaleTrashMedium", bundle:.module)
        }
        return Image("BalanceScaleTrashLarge", bundle:.module)
    }
    var body: some View {
        GeometryReader { p1 in
            VStack(spacing:0) {
                VStack {
                    HStack(alignment:.bottom,spacing: 20) {
                        BalanceScaleArmView(percentage:trashPercentage) {
                            trashImage?.resizable().aspectRatio(217/61,contentMode: .fit)
                                .frame(maxHeight:.infinity,alignment: .bottom)
                        }
                        .frame(maxHeight:.infinity)
                        .id("left")
                        BalanceScaleArmView(percentage:valuePercentage,physics:true) {
                            SpriteKitContainer(model: model).frame(maxHeight:.infinity,alignment: .bottom)
                        }
                        .id("right")
                    }
                    .frame(maxHeight: .infinity,alignment: .bottom)
                }.frame(maxHeight: .infinity,alignment: .bottom)
                BalanceScaleBodyView { proxy in
                    HStack {
                        ScaleValueView(value: model.wasteWeight, unit: "g")
                            .frame(height: proxy.size.height * 0.3)
                        Spacer()
                        BalanceScaleGuageView(left: model.wasteWeight, right: model.totalWeight)
                        Spacer()
                        ScaleValueView(value: model.totalWeight, unit: "g")
                            .frame(height: proxy.size.height * 0.3)
                    }.frame(maxWidth:.infinity,maxHeight: .infinity)
                }
                .frame(width: p1.size.width * 0.85)
            }
        }
        .aspectRatio(400/280, contentMode: .fit)
        .onReceive(model.$objects) { value in
            animateChanges(deletion: value.count < model.objects.count)
        }
    }
}
extension BalanceScaleView {
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
        @Published var selection:[BalanceScaleObjects] = []
        @Published var objects:[Item] = []
        @Published var totalWeight:Double = 0
        @Published private(set) var wasteWeight:Double
        @Published var inBalance:Bool = false
        @Published var toggleStatistics:Bool = false
        init(wasteWeight:Double) {
            self.wasteWeight = wasteWeight
            if wasteWeight < 200 {
                self.selection = FoodWasteScaleObjects.convert(emojis: "🍓🍏🍌🍈")
            } else if wasteWeight < 500 {
                self.selection = FoodWasteScaleObjects.convert(emojis: "🍓🍏🍌🐟🥩🍈")
            } else {
                self.selection = FoodWasteScaleObjects.convert(emojis: "🍓🍏🍊🍌🐟🥩🍈")
            }
        }
        static func round(_ wasteWeight:Double) -> Double {
            let w = (wasteWeight/50).rounded(.toNearestOrEven) * 50
            return w < 50 ? 50 : w
        }
        var calculatedBalance:Bool {
            wasteWeight == calculatedTotalWeight
        }
        var calculatedTotalWeight:Double {
            return weight(from: objects)
        }
        func weight(from objects:[Item]) -> Double {
            var w:Double = 0
            for o in objects {
                w += o.weight
            }
            return w
        }
        func reset(to wasteWeight:Double) {
            self.inBalance = false
            self.wasteWeight = wasteWeight
            self.objects = []
            self.totalWeight = 0
        }
        func updateWeight() {
            totalWeight = calculatedTotalWeight
            inBalance = wasteWeight == totalWeight
        }
    }
}

//struct BalanceScaleView_Previews: PreviewProvider {
//    static var wm = FoodWasteManager()
//    static var model:BalanceScaleView.ViewModel {
//        let m = BalanceScaleView.ViewModel(wasteWeight: 300)
//        m.objects.append(contentsOf:FoodWasteScaleObjects.default.map(BalanceScaleView.ViewModel.Item.init))
//        m.updateWeight()
//        return m
//    }
//    static var previews: some View {
//        BalanceScaleTableView(model: model, foodWasteManager:wm)
//    }
//}
