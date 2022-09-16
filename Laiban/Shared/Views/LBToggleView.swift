//
//  CustomToggleView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-23.
//

import SwiftUI

public struct LBToggleView: View {
    @State private var isOnState:Bool = false
    var isOn:Bool = false
    public init(isOn:Bool,changed:@escaping (Bool) -> Void) {
        self.isOn = isOn
        _isOnState = State(initialValue: isOn)
        self.changed = changed
    }
    var changed:(Bool) -> Void
    var overlay: some View {
        Image(systemName: "circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment: isOn ? .trailing : .leading)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            .padding(2)
            .animation(.easeInOut(duration: 0.2))
    }
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(isOn ? .green : Color(.systemGray5))
                .overlay(overlay)
        }
        .frame(width: 50,height:31)
        .onTapGesture {
            withAnimation {
                //isOnState.toggle()
                changed(!isOn)
            }
        }
    }
}

struct CustomToggleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                Text("Label")
                Spacer()
                LBToggleView(isOn: true) { b in
                    
                }
            }
            HStack {
                Text("Label")
                Spacer()
                LBToggleView(isOn: false) { b in
                }
            }
            Toggle(isOn: .constant(true), label: {
                Text("Label")
            })
            Toggle(isOn: .constant(false), label: {
                Text("Label")
            })
        }
    }
}
