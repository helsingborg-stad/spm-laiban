//
//  SwiftUIView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-27.
//

import SwiftUI
import SpriteKit
import Combine

struct MovementBalanceView<Content: View>: View {
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


struct MovementScaleView : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var model:ViewModel
    @State var animate = false
    let lineWidth = CGFloat(2)
    var movementPercentage:CGFloat {
        guard model.totalMovement != 0 else { return 1 }
        
        let percentage = Double(model.movementTime) / Double(model.totalMovement)
        print("Movement time: \(model.movementTime), total: \(model.totalMovement), percentage: \(percentage)")
        return min(max(1 - percentage, 0), 1)
    }
    func animateChanges(deletion:Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (deletion ? 0.01 : 0.4)) {
            withAnimation(.interpolatingSpring(mass: 0.2, stiffness: 2, damping: 0.8, initialVelocity: 2)) {
                self.model.updateMovement()
            }
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: proxy.size.width * 0.15)
                    .strokeBorder(Color("BarBorder",bundle: .module),lineWidth: lineWidth)
                    .background(RoundedRectangle(cornerRadius: proxy.size.width * 0.15).fill(Color("BarBackground",bundle:.module)))
                    .frame(height: proxy.size.height+lineWidth*2)
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: proxy.size.width * 0.13)
                        .fill(Color("BarColor",bundle:.module))
                        .frame(width: (proxy.size.width - lineWidth*2), height: animate ? (proxy.size.height + 0) * movementPercentage : 0, alignment: .bottom)
                        .offset(CGSize(width: 0, height: -lineWidth*2))
                        .onAppear {
                            withAnimation {
                                self.animate = true
                            }
                        }
                }
            }
        }
    }
    
}
extension MovementScaleView {
    class ViewModel : ObservableObject {
        struct Item : Identifiable,Equatable {
            let id: String
            let minutes: Int
            let numMoving: Int
            init(minutes: Int, numMoving: Int) {
                self.id = UUID().uuidString
                self.minutes = minutes
                self.numMoving = numMoving
            }
        }
        // @Published var selection:[BalanceScaleObjects] = []
        @Published var objects:[Item] = []
        @Published var totalMovement: Int = 120
        @Published private(set) var movementTime: Int
        @Published var inBalance: Bool = false
        @Published var toggleStatistics: Bool = false
        init(movementTime: Int) {
            self.movementTime = movementTime
            // TODO: Fill table?
        }
        static func round(_ movementMinutes:Int) -> Int {
            let w = (Double(movementMinutes)/50).rounded(.toNearestOrEven) * 50
            return w < 50 ? 50 : Int(w)
        }
        var calculatedBalance:Bool {
            movementTime == calculatedTotalMovementTime
        }
        var calculatedTotalMovementTime:Int {
            return minutes(from: objects)
        }
        func minutes(from objects:[Item]) -> Int {
            var w:Int = 0
            for o in objects {
                w += o.minutes
            }
            return w
        }
        func reset(to movementTime:Int) {
            self.inBalance = false
            self.movementTime = movementTime
            self.objects = []
            self.totalMovement = 0
        }
        func updateMovement() {
            totalMovement = calculatedTotalMovementTime
            inBalance = movementTime == totalMovement
        }
    }
}
