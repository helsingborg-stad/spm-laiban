//
//  LBParentalGateView.swift
//
//  Created by Tomas Green on 2020-12-07.
//

import SwiftUI

public enum LBParentalGateStatus : String {
    case undetermined
    case passed
    case failed
    case cancelled
}
public typealias LBParentalGateStatusChanged = ((LBParentalGateStatus) -> Void)

public struct LBParentalGateContainer<Content: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var status:LBParentalGateStatus?
    @State var actionStatus:LBParentalGateStatus = .undetermined
    var active:Bool = true
    let content: () -> Content
    let statusChanged: LBParentalGateStatusChanged?
    let properties:LBFullscreenContainerProperties
    public init(active:Bool = true, properties: LBFullscreenContainerProperties?, status:Binding<LBParentalGateStatus?>? = nil, statusChanged:LBParentalGateStatusChanged? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.active = active
        self.properties = properties ?? .default
        self.statusChanged = statusChanged
        self._status = status ?? Binding.constant(nil)
    }
    public var body: some View {
        if active == false || status == .passed || actionStatus == .passed {
            content()
        } else {
            LBParentalGateView(properties: properties) { res in
                withAnimation {
                    status = res
                    actionStatus = res
                    statusChanged?(res)
                }
            }
        }
    }
    public func onStatusChanged(_ statusChanged:@escaping LBParentalGateStatusChanged) -> Self {
        LBParentalGateContainer(active:active, properties: self.properties, status: self.$status, statusChanged: statusChanged, content: self.content)
    }
}

struct LBParentalGateView: View {
    struct Gate {
        var numbers:[Int] = []
        var function:MathFunction = MathFunction.random
        init() {
            function = MathFunction.random
            numbers = function.randomNumbers
        }
        func isValid(value:Int) -> Bool  {
            return function.evaluate(numbers: numbers) == value
        }
        var description:String {
            switch function {
            case .plus: return numbers.map({ i in "\(i)"}).joined(separator: " + ")
            case .minus: return numbers.map({ i in "\(i)"}).joined(separator: " - ")
            case .multiply: return numbers.map({ i in "\(i)"}).joined(separator: " * ")
            }
        }
    }
    enum MathFunction : Int {
        case plus
        case minus
        case multiply
        
        func evaluate(numbers:[Int]) -> Int {
            switch self {
            case .plus: return numbers.reduce(0, +)
            case .minus: return (numbers.first ?? 0) - (numbers.last ?? 0)
            case .multiply: return numbers.reduce(1, *)
            }
        }
        var randomNumbers:[Int] {
            switch self {
            case .plus: return [Int.random(in: 2..<30),Int.random(in: 1..<30)]
            case .minus: return [Int.random(in: 15..<30),Int.random(in: 1..<15)]
            case .multiply: return [Int.random(in: 2..<16),Int.random(in: 2..<4)]
            }
        }
        static var random:Self {
            return MathFunction.init(rawValue: Int.random(in: 0..<3))!
        }
    }
 
    let properties:LBFullscreenContainerProperties
    @State var status: (LBParentalGateStatus) -> Void
    @State var gate = Gate()
    @State var string:String = ""
    
    func isValid(value:Int) -> Bool  {
        return gate.isValid(value: value)
    }
    func eval() {
        guard let int = Int(string), gate.isValid(value: int)else {
            if self.attempts > 5 {
                self.status(.failed)
                return
            }
            self.string = ""
            self.gate = Gate()
            withAnimation(.default) {
                self.attempts += 1
            }
            return
        }
        self.status(.passed)
    }
    @State var attempts = 0
    var buttons: some View {
        VStack {
            Button(action: eval, label: {
                Text("Klar")
                    .padding([.top,.bottom])
                    .font(properties.font, ofSize: .l,color: .white)
                    .frame(maxWidth:.infinity)
                    .background(Capsule().fill(Color("DefaultTextColor",bundle:.module)))
                    .shadow(enabled: true)
            })
            Button(action: {
                status(.cancelled)
            }, label: {
                Text("Avbryt")
                    .padding([.top,.bottom])
                    .frame(maxWidth:.infinity)
                    .font(properties.font, ofSize: .l)
            })
        }
    }
    var numpad: some View {
        LBNumpadView(string: $string)
            .modifier(Shake(animatableData: CGFloat(attempts)))
    }
    var info: some View {
        VStack {
            Text("\(gate.description)\n =")
                .font(properties.font, ofSize: .xl)
                .multilineTextAlignment(.center)
            Text(string.count > 0 ? string : "Ange svar")
                .foregroundColor(string.count > 0 ? Color("DefaultTextColor",bundle:.module) : .gray)
                .font(properties.font, ofSize: .l)
        }

    }
    var portrait: some View {
        let padd = properties.spacing.ofAmount(.m)
        return VStack(spacing:padd) {
            Spacer()
            info
                .frame(maxWidth:.infinity)
                .padding(padd)
            numpad
                .secondaryContainerBackground()
            buttons
                .padding(padd)
                
            Spacer()
        }
        .frame(width: properties.horizontalSizeClass == .regular ? properties.contentSize.width * 0.4 : properties.contentSize.width * 0.7)
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .primaryContainerBackground()
    }
    var landscape: some View {
        let padd = properties.spacing.ofAmount(.m)
        return HStack(spacing:padd) {
            numpad
                .primaryContainerBackground()
            VStack {
                info
                    .padding(padd)
                    .frame(maxWidth:.infinity,maxHeight: .infinity)
                    .secondaryContainerBackground()
                    .padding(padd)
                Spacer()
                buttons.padding(padd)
            }
            .aspectRatio(3/4,contentMode: .fit)
            .primaryContainerBackground()
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
    }
    func cancel() {
        status(.cancelled)
    }
    var body: some View {
        if properties.layout == .portrait {
            self.portrait
        } else {
            self.landscape
        }
    }
}
public extension View {
    func parentalGate(active:Bool = true, properties:LBFullscreenContainerProperties?, status:Binding<LBParentalGateStatus?>? = nil) -> LBParentalGateContainer<Self> {
        LBParentalGateContainer(active:active,  properties: properties, status: status) {
            self
        }
    }
}
@available(iOS 15.0, *) struct LBParentalGateView_Previews: PreviewProvider {
    @State static var res = LBParentalGateStatus.undetermined
    static var previews: some View {
        Group {
            LBFullscreenContainer { props in
                LBParentalGateView(properties: props) { res in
                    self.res = res
                }
                .opacity(res == .cancelled ? 0 : 1)
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .center)
            }
            LBFullscreenContainer { props in
                LBParentalGateView(properties: props) { res in
                    self.res = res
                }
                .opacity(res == .cancelled ? 0 : 1)
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .center)
            }
            .previewInterfaceOrientation(.landscapeLeft)
            LBFullscreenContainer { props in
                LBParentalGateView(properties: props) { res in
                    self.res = res
                }
                .opacity(res == .cancelled ? 0 : 1)
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .center)
            }
            .previewDevice("iPhone 13 Pro Max")
            LBFullscreenContainer { props in
                LBParentalGateView(properties: props) { res in
                    self.res = res
                }
                .opacity(res == .cancelled ? 0 : 1)
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .center)
            }
            .previewInterfaceOrientation(.landscapeRight)
            .previewDevice("iPhone 13 Pro Max")
        }.attachPreviewEnvironmentObjects(ttsDisabled: true)
    }
}
