//
//  ThermometerView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-10-13.
//

import SwiftUI

extension UIColor {
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }
            
            return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
                           green: CGFloat(g1 + (g2 - g1) * percentage),
                           blue: CGFloat(b1 + (b2 - b1) * percentage),
                           alpha: CGFloat(a1 + (a2 - a1) * percentage))
        }
    }
    
}

public struct ThermometerView: View {
    func center(_ proxy:GeometryProxy,maxHeight:CGFloat = 0.5) -> some View {
        let max = proxy.size.height - proxy.size.width * 0.5
        let min = proxy.size.width * 0.5 + proxy.size.height * 0.02
        let val = min + (max - min) * maxHeight
        return adjustedColor
            .mask(
                ZStack(alignment:.bottom) {
                    RoundedRectangle(cornerRadius: proxy.size.width/2)
                        .frame(width: proxy.size.width*0.1, height:val)
                    Circle()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width:proxy.size.width * 0.5)
                }
                    .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
                    .padding(proxy.size.width * 0.25)
            )
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
        
    }
    func currentTempText(_ proxy:GeometryProxy,temperature:Double = -20) -> some View {
        Text("\(Int(temperature))°")
            .foregroundColor(.white)
            .aspectRatio(1, contentMode: .fit)
            .frame(width:proxy.size.width,height:proxy.size.width)
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
            .font(.system(size: proxy.size.width * 0.15, weight:.bold, design: .rounded))
        
    }
    func tics(_ proxy:GeometryProxy) -> some View {
        let min = proxy.size.width * 0.5 + proxy.size.height * 0.02
        let max = proxy.size.height - proxy.size.width * 0.5
        return Color.black.opacity(0.4)
            .mask(
                VStack(alignment:.center) {
                    ForEach(0...10, id:\.self) { i in
                        if i != 0 {
                            Spacer()
                        }
                        if i == 5 {
                            RoundedRectangle(cornerRadius: 1.5).frame(width:proxy.size.width*0.3, height: 3)
                                .id("rect-\(i)").frame(maxWidth:.infinity,alignment: .center)
                        } else {
                            RoundedRectangle(cornerRadius: 1).frame(width:proxy.size.width*0.2, height: 1)
                                .id("rect-\(i)").frame(maxWidth:.infinity,alignment: .center)
                        }
                        
                    }
                }
                    .padding(.bottom, min)
                    .frame(height: max, alignment: .bottom)
                    .frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .bottom)
                    .padding(proxy.size.width * 0.25)
                
            )
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
        
    }
    func text(_ proxy:GeometryProxy) -> some View {
        let min = proxy.size.width * 0.5 + proxy.size.height * 0.02
        let max = proxy.size.height - proxy.size.width * 0.5
        return Color.black.opacity(0.4)
            .mask(
                VStack(alignment:.center) {
                    ForEach(0...10, id:\.self) { i in
                        if i != 0 {
                            Spacer()
                        }

                        Text("\((5-i) * 10)°")
                            .font(.system(size: proxy.size.width * 0.1, weight:.bold, design: .rounded))
                            .opacity(i != 10 ? 1 :0)
                            .id("text-\(i)")
                            .frame(width:proxy.size.width * 0.26,alignment: .trailing)
                            .frame(maxWidth:.infinity,alignment: .leading)
                    }
                }
                .padding(.bottom, min)
                .frame(height: max + proxy.size.width * 0.1, alignment: .bottom)
                .frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .bottom)
                .padding([.top,.bottom], proxy.size.width * 0.25)
                
            )
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
        
    }
    func background(_ proxy:GeometryProxy,percentage:CGFloat) -> some View {
        adjustedColor.mask(
            ZStack(alignment:.bottom) {
                RoundedRectangle(cornerRadius: proxy.size.width/2)
                    .frame(width:proxy.size.width * 0.42)
                Circle()
                    .aspectRatio(1, contentMode: .fit)
            }.frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
        ).frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
    }
    func background2(_ proxy:GeometryProxy,percentage:CGFloat) -> some View {
        gradient.opacity(0.4).background(Color.white)
            .mask(
                ZStack(alignment:.bottom) {
                    RoundedRectangle(cornerRadius: proxy.size.width/2)
                        .padding(proxy.size.width * 0.03)
                        .frame(width: proxy.size.width*0.42)
                    Circle()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(proxy.size.width * 0.03)
                    
                }.frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
            ).frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
    }
    var gradient = LinearGradient(colors: [Color("ThermometerMax",bundle:.module),Color("ThermometerMin",bundle:.module)], startPoint: .top, endPoint: .bottom)
    var adjustedColor:Color {
        if adjustColorToTemperature == false {
            return Color("ThermometerMax",bundle:.module)
        }
        return Color(UIColor(named: "ThermometerMin",in:Bundle.module, compatibleWith: nil)!.toColor(UIColor(named: "ThermometerMax",in:Bundle.module,compatibleWith: nil)!, percentage: percentage))
    }
    var shadowColor:Color {
        if adjustColorToTemperature {
            return adjustedColor.opacity(isEnabled ? 1 : 0)
        }
        return Color.black.opacity(isEnabled ? 0.3 : 0)
    }
    var temperature:Double
    var minTemperature:Double = -50
    var maxTemperature:Double = 50
    var percentage:CGFloat {
        let tot = abs(minTemperature) + abs(maxTemperature)
        let adjusted = temperature + abs(minTemperature)
        return adjusted / tot
    }
    var showTics:Bool = true
    var showText:Bool = true
    var adjustColorToTemperature: Bool = true
    @Environment(\.isEnabled) var isEnabled: Bool
    public init(temperature:Double) {
        self.temperature = temperature
    }

    public var body: some View {
        GeometryReader { proxy in
            
            background(proxy,percentage:percentage)
                .shadow(color: shadowColor, radius: 4, x: 0, y: 0)
            background2(proxy,percentage:percentage)
            if showTics {
                tics(proxy)
            }
            if showText {
                text(proxy)
            }
            center(proxy,maxHeight: percentage)
            currentTempText(proxy,temperature: temperature)

        }
        .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
        //.aspectRatio(250/1300, contentMode: .fit)
    }
}
public struct HorizontalThermometerView: View {
    func center(_ proxy:GeometryProxy,size:CGFloat = 0.5) -> some View {
        let max = proxy.size.width - proxy.size.height * 0.5
        let min = proxy.size.height * 0.5 + proxy.size.width * 0.02
        let val = min + (max - min) * size
        return adjustedColor
            .mask(
                ZStack(alignment:.leading) {
                    RoundedRectangle(cornerRadius: proxy.size.height/2)
                        .frame(width: val, height:proxy.size.height*0.1)
                    Circle()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height:proxy.size.height * 0.5)
                }
                    .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.leading)
                    .padding(proxy.size.height * 0.25)
            )
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.leading)
        
    }
    func currentTempText(_ proxy:GeometryProxy,temperature:Double = -20) -> some View {
        Text("\(Int(temperature))°")
            .foregroundColor(.white)
            .aspectRatio(1, contentMode: .fit)
            .frame(width:proxy.size.height,height:proxy.size.height)
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.leading)
            .font(.system(size: proxy.size.height * 0.15, weight:.bold, design: .rounded))
        
    }
    func tics(_ proxy:GeometryProxy) -> some View {
        let max = proxy.size.width - proxy.size.height * 0.5
        let min = proxy.size.height * 0.5 + proxy.size.width * 0.02
        return Color.black.opacity(0.4)
            .mask(
                HStack(alignment:.top) {
                    ForEach(0...10, id:\.self) { i in
                        if i != 0 {
                            Spacer()
                        }
                        if i == 5 {
                            RoundedRectangle(cornerRadius: 1.5).frame(width:3, height: proxy.size.height*0.3)
                                .id("rect-\(i)").frame(maxHeight:.infinity,alignment: .center)
                        } else {
                            RoundedRectangle(cornerRadius: 1).frame(width:1, height: proxy.size.height*0.2)
                                .id("rect-\(i)").frame(maxHeight:.infinity,alignment: .center)
                        }
                        
                    }
                }
                .padding(.leading, min)
                .frame(width: max, alignment: .leading)
                .frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .leading)
                .padding(proxy.size.height * 0.25)
                
            )
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.leading)
        
    }
    func text(_ proxy:GeometryProxy) -> some View {
        let max = proxy.size.width - proxy.size.height * 0.5
        let min = proxy.size.height * 0.5 + proxy.size.width * 0.02
        return Color.black.opacity(0.4)
            .mask(
                HStack(alignment:.top) {
                    ForEach(0...10, id:\.self) { i in
                        if i != 0 {
                            Spacer()
                        }

                        Text("\((5-i) * -10)°")
                            .font(.system(size: proxy.size.height * 0.1, weight:.bold, design: .rounded))
                            .opacity(i != 0 ? 1 :0)
                            .id("text-\(i)")
                            .frame(height:proxy.size.height * 0.26,alignment: .center)
                            .frame(maxWidth:.infinity,alignment: .center)
                    }
                }
                .padding(.leading, min)
                    .frame(width: max + proxy.size.height * 0.1 * 2.5, alignment: .topLeading)
                .frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .topLeading)
                .padding([.leading,.trailing], proxy.size.height * 0.25)
            )
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.topLeading)
    }
    func background(_ proxy:GeometryProxy,percentage:CGFloat) -> some View {
        adjustedColor.mask(
            ZStack(alignment:.leading) {
                RoundedRectangle(cornerRadius: proxy.size.height * 0.42/2)
                    .frame(height:proxy.size.height * 0.42)
                Circle()
                    .aspectRatio(1, contentMode: .fit)
            }.frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
        ).frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
    }
    func background2(_ proxy:GeometryProxy,percentage:CGFloat) -> some View {
        gradient.opacity(0.4).background(Color.white)
            .mask(
                ZStack(alignment:.leading) {
                    RoundedRectangle(cornerRadius: proxy.size.height/2)
                        .padding(proxy.size.height * 0.03)
                        .frame(height: proxy.size.height*0.42)
                    Circle()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(proxy.size.height * 0.03)
                    
                }.frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
            ).frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
    }
    var gradient = LinearGradient(colors: [Color("ThermometerMax",bundle:.module),Color("ThermometerMin",bundle:.module)], startPoint: .trailing, endPoint: .leading)
    var adjustedColor:Color {
        if adjustColorToTemperature == false {
            return Color("ThermometerMax",bundle:.module)
        }
        return Color(UIColor(named: "ThermometerMin",in:Bundle.module, compatibleWith: nil)!.toColor(UIColor(named: "ThermometerMax",in:Bundle.module,compatibleWith: nil)!, percentage: percentage))
    }
    var shadowColor:Color {
        if adjustColorToTemperature {
            return adjustedColor.opacity(isEnabled ? 1 : 0)
        }
        return Color.black.opacity(isEnabled ? 0.3 : 0)
    }
    var temperature:Double
    var minTemperature:Double = -50
    var maxTemperature:Double = 50
    var percentage:CGFloat {
        let tot = abs(minTemperature) + abs(maxTemperature)
        let adjusted = temperature + abs(minTemperature)
        return adjusted / tot
    }
    var showTics:Bool = true
    var showText:Bool = true
    var adjustColorToTemperature: Bool = true
    @Environment(\.isEnabled) var isEnabled: Bool
    public init(temperature:Double,showText:Bool = true) {
        self.temperature = temperature
        self.showText = showText
    }
    public var body: some View {
        GeometryReader { proxy in
            background(proxy,percentage:percentage)
                .shadow(color: shadowColor, radius: 4, x: 0, y: 0)
            background2(proxy,percentage:percentage)
            if showTics {
                tics(proxy)
            }
            if showText {
                text(proxy)
            }
            center(proxy,size: percentage)
            currentTempText(proxy,temperature: temperature)

        }
        .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.bottom)
        //.aspectRatio(250/1300, contentMode: .fit)
    }
}

struct ThermometerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                HorizontalThermometerView(temperature: 50)
                HorizontalThermometerView(temperature: 0)
                HorizontalThermometerView(temperature: 15)
                HorizontalThermometerView(temperature: -15.4)
                HorizontalThermometerView(temperature: -50)
            }
            HStack {
                ThermometerView(temperature: 50)
                ThermometerView(temperature: 0)
                ThermometerView(temperature: 15)
                ThermometerView(temperature: -15)
                ThermometerView(temperature: -50)
            }
            
        }
        .previewLayout(PreviewLayout.fixed(width: 500, height: 500))
        .padding()
        .previewDisplayName("Default preview")
    }
}
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
