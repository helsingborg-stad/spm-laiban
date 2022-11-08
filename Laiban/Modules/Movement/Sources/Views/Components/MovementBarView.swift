//
//  SwiftUIView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-27.
//

import SwiftUI
import SpriteKit
import Combine

struct MovementBarView : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var model:ViewModel
    @State var animate = false
    let lineWidth = CGFloat(2)

    var movementPercentage:CGFloat {
        guard model.settings.maxMetersPerDay != 0 else { return 1 }
        
        let percentage = Double(model.movementMeters) / Double(model.settings.maxMetersPerDay)

        return min(max(percentage, 0), 1)
    }
    /*func animateChanges(deletion:Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + (deletion ? 0.01 : 0.4)) {
            withAnimation(.interpolatingSpring(mass: 0.2, stiffness: 2, damping: 0.8, initialVelocity: 2)) {

            }
        }
    }*/

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
                        .frame(width: (proxy.size.width - lineWidth*2), height: animate ? proxy.size.height * movementPercentage : 0, alignment: .bottom)
                        .offset(CGSize(width: 0, height: -lineWidth-(1*(movementPercentage))))
                        
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
extension MovementBarView {
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
        @Published var settings = MovementSettings()
        @Published private(set) var movementMeters: Int
        @Published var inBalance: Bool = false
        @Published var toggleStatistics: Bool = false
        init(movementMeters: Int, settings: MovementSettings) {
            self.movementMeters = movementMeters
            self.settings = settings
            // TODO: Fill table?
        }
        static func round(_ movementMinutes:Int) -> Int {
            let w = (Double(movementMinutes)/50).rounded(.toNearestOrEven) * 50
            return w < 50 ? 50 : Int(w)
        }
        var calculatedBalance:Bool {
            movementMeters == calculatedTotalMovementTime
        }
        var calculatedTotalMovementTime:Int {
            return meters(from: objects)
        }
        func meters(from objects:[Item]) -> Int {
            var w:Int = 0
            for o in objects {
                w += Int(Double(o.minutes * settings.stepsPerMinute) * settings.stepLength)
            }
            return w
        }
        func reset(to movementTime:Int) {
            self.inBalance = false
            self.movementMeters = movementTime
            self.objects = []
        }
    }
}
