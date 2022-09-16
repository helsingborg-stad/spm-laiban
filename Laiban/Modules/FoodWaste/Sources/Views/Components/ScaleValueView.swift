//
//  ScaleValueView.swift
//
//  Created by Tomas Green on 2021-03-15.
//

import SwiftUI

struct ScaleValueView: View {
    var value:Double
    var unit:String
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing:0) {
                Text("\(Int(value))")
                    .frame(width:proxy.size.width * 0.7)
                    .frame(maxHeight:.infinity)
                    .animation(.none)
                Rectangle().fill(Color("ScaleBodyBorderColor",bundle:.module)).frame(width: 1)
                Text(unit).frame(maxWidth:.infinity).animation(.none)
            }
            .font(.system(size: proxy.size.width * 0.12, weight: .bold, design: .rounded))
            .foregroundColor(Color("ScaleBodyBorderColor",bundle:.module))
            .background(Color.white).cornerRadius(proxy.size.width * 0.05)
            .overlay(RoundedRectangle(cornerRadius: proxy.size.width * 0.05).stroke(Color("ScaleBodyBorderColor",bundle:.module), lineWidth: 1))
            .animation(.none)
            .transition(.identity)
        }
    }
}

struct ScaleValueView_Previews: PreviewProvider {
    static var previews: some View {
        ScaleValueView(value: 200, unit: "g")
    }
}
