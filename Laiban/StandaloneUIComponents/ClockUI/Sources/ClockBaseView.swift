import SwiftUI
import Combine


public struct ClockBaseView: View {
    @ObservedObject var viewModel:ClockViewModel
    @State var angle:ClockAngle
    let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
    var hours:[Int] {
        self.viewModel.militaryTime && Date().hour > 11 ? (13...24).reversed() : (1...12).reversed()
    }
    var size:CGFloat
    init(_ viewModel:ClockViewModel, size:CGFloat) {
        self.size = size
        self.angle = viewModel.currentAngle
        self.viewModel = viewModel
    }
    public var body: some View {
        ZStack() {
            let textOffset = (size/2 - size * 0.05 * 2.3) * -1

            let textSize = size * 0.05
            let handSize = size - textSize
            if self.viewModel.showClockHourText {
                ForEach(self.hours, id: \.self) {
                    Text("\($0)")
                        .font(Font.system(size: textSize, weight: .bold, design: .rounded))
                        .rotationEffect(Angle(degrees: Double($0) * 30) * -1)
                        .foregroundColor(self.viewModel.timeTextColor)
                        .offset(x: 0, y: textOffset)
                        .rotationEffect(Angle(degrees: Double($0) * 30))
                        .zIndex(2)
                }
            }
            if self.viewModel.showClockMarkings {
                let markingOffset = (size/2 - size * 0.05) * -1
                let markingSize = size * 0.02
                ForEach(1...60, id: \.self) { val in
                    let b = val.isMultiple(of: 5)
                    let s:CGFloat = b ? markingSize : markingSize / 2
                    Circle()
                        .fill(self.viewModel.markingsColor)
                        .frame(width:s, height:s)
                        .offset(x: 0, y: markingOffset)
                        .rotationEffect(Angle(degrees: Double(val) * 6))
                        .zIndex(2)
                        .opacity(b ? 1 : 0.3)
                }
            }
            self.viewModel.hoursHandImage
                .resizable()
                .zIndex(3)
                .rotationEffect(self.angle.hour)
                .foregroundColor(self.viewModel.hoursHandColor)
                .frame(width:handSize, height:handSize)
            self.viewModel.minutesHandImage
                .resizable()
                .zIndex(4)
                .rotationEffect(self.angle.minute)
                .foregroundColor(self.viewModel.minutesHandColor)
                .frame(width:handSize, height:handSize)
            if self.viewModel.showClockSeconds {
                self.viewModel.secondsHandImage
                    .resizable()
                    .zIndex(5)
                    .rotationEffect(self.angle.second)
                    .foregroundColor(self.viewModel.secondsHandColor)
                    .frame(width:handSize, height:handSize)
            }
        }
        .background(Circle().fill(self.viewModel.faceColor))
        
        .aspectRatio(1, contentMode: .fit)
        .onReceive(timer) { _ in
            if viewModel.timeLock != nil {
                return
            }
            angle = viewModel.currentAngle
        }.onReceive(viewModel.$timeLock) { lock in
            withAnimation {
                angle = viewModel.currentAngle
            }
        }
    }
}

struct WatchView_Previews: PreviewProvider {
    static var previews: some View {
        ClockBaseView(ClockViewModel(),size:375)
    }
}
