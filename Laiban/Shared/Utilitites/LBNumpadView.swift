//
//  NumpadView.swift
//
//  Created by Tomas Green on 2021-03-04.
//

import SwiftUI

public struct LBNumpadView: View {
    @Environment(\.isEnabled) var isEnabled
    var maxLength:Int? = nil
    var maxNum:Int? = nil
    var textColor = Color("DefaultTextColor",bundle:.module)
    @State var attempts:Int = 0
    @Binding var string:String
    func row1(buttonSize:CGFloat, buttonSpacing:CGFloat) -> some View {
        HStack(alignment:.center,spacing: buttonSpacing) {
            ForEach(1..<4) { i in
                button(i, buttonSize: buttonSize)
            }
        }
    }
    func row2(buttonSize:CGFloat, buttonSpacing:CGFloat) -> some View {
        HStack(alignment:.center,spacing: buttonSpacing) {
            ForEach(4..<7) { i in
                button(i, buttonSize: buttonSize)
            }
        }
    }
    func row3(buttonSize:CGFloat, buttonSpacing:CGFloat) -> some View {
        HStack(alignment:.center,spacing: buttonSpacing) {
            ForEach(7..<10) { i in
                button(i, buttonSize: buttonSize)
            }
        }
    }
    func row4(buttonSize:CGFloat, buttonSpacing:CGFloat) -> some View {
        HStack(alignment:.center, spacing: buttonSpacing) {
            Color.clear.frame(width: buttonSize, height: buttonSize, alignment: .center)
            button(0, buttonSize: buttonSize)
            Button(action: {
                if string.count > 0 {
                    string.removeLast()
                }
            }, label: {
                Image(systemName: "delete.left.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonSize * 0.8, height: buttonSize * 0.8, alignment: .center)
            }).frame(width: buttonSize, height: buttonSize, alignment: .center)
            .disabled(string.count < 1)
            .accentColor(.red)
            .foregroundColor(string.count < 1 ? .gray : .red)
            .shadow(color: Color.black.opacity(isEnabled ? 0.3 : 0), radius: buttonSize * 0.08, x: 0, y: 0)
        }
    }
    public init(maxLength:Int? = nil, maxNum:Int? = nil, textColor:Color = Color("DefaultTextColor", bundle:LBBundle), string:Binding<String>) {
        self.maxLength = maxLength
        self.maxNum = maxNum
        self.textColor = textColor
        _string = string
    }
    public var body:some View {
        GeometryReader { proxy in
            let buttonSpacing:CGFloat = proxy.size.height * 0.08
            let buttonSize:CGFloat = (proxy.size.height - buttonSpacing * 5)/4
            VStack(spacing: buttonSpacing) {
                row1(buttonSize: buttonSize, buttonSpacing: buttonSpacing)
                row2(buttonSize: buttonSize, buttonSpacing: buttonSpacing)
                row3(buttonSize: buttonSize, buttonSpacing: buttonSpacing)
                row4(buttonSize: buttonSize, buttonSpacing: buttonSpacing)
            }
            .padding(buttonSpacing)
            
            .position(x: proxy.size.width/2, y: proxy.size.height/2)
            .modifier(Shake(animatableData: CGFloat(attempts)))
        }
        .aspectRatio(3/4, contentMode: .fit)
    }
    func button(_ i: Int, buttonSize:CGFloat) -> some View {
        Button(action: {
            if i == 0 && string.count > 0 || i != 0 {
                if let m = maxLength, string.count >= m {
                    withAnimation(.default) {
                        self.attempts += 1
                    }
                    return
                }
                let s = string + "\(i)"
                if let i = Int(s), let m = maxNum, i > m {
                    withAnimation(.default) {
                        self.attempts += 1
                    }
                    return
                }
                string = s
            }
        }, label: {
            Image(systemName: "\(i).circle.fill")
                .resizable()
                .frame(width: buttonSize, height: buttonSize, alignment: .center)
                .background(Circle().fill(textColor).padding(2))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(isEnabled ? 0.3 : 0), radius: buttonSize * 0.04, x: 0, y: 0)
        })
    }
}

struct NumpadView_Previews_Container: View {
    @State var string:String = ""
    var body: some View {
        VStack {
            Text(string)
            LBNumpadView(maxLength: 4, maxNum: 250, string: $string)
        }
    }
}
struct NumpadView_Previews: PreviewProvider {
    @State static var string:String = ""
    static var previews: some View {
        NumpadView_Previews_Container()
    }
}
