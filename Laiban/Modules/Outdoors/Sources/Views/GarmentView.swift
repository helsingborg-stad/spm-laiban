//
//  GarmentsView.swift
//
//  Created by Tomas Green on 2019-12-04.
//

import SwiftUI
import Combine

import Assistant

struct GarmentView: View {
    @EnvironmentObject var assistant:Assistant
    var garment:Garment
    var action:((Garment) -> Void)
    var body: some View {
        GeometryReader { proxy in
            Button(action: {
                self.action(self.garment)
            }) {
                VStack(alignment: .center,spacing: 10) {
                    LBImageBadgeView(image: Image(garment.imageName, bundle: .module), rimColor: Color("RimColorClothes", bundle: LBBundle))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height:proxy.size.width * 0.6)
                    Text(assistant.string(forKey: garment.localizationKey).uppercased())
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("DefaultTextColor", bundle:.module))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
struct SelectableGarmentView: View {
    @EnvironmentObject var assistant:Assistant
    var garment:Garment
    var selected:Bool = false
    var dimmed:Bool = false
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center,spacing: 10) {
                if selected {
                    LBImageBadgeView(image:Image(garment.imageName, bundle: .module), rimColor: Color("RimColorClothes", bundle: .module))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height:proxy.size.height * 0.6)
                } else {
                    GeometryReader { proxy2 in
                        Image(garment.imageName,bundle: .module)
                            .renderingMode(.original)
                            .resizable()
                            .frame(width:proxy2.size.width * 0.5,height:proxy2.size.width * 0.5)
                            .frame(maxWidth:.infinity,maxHeight:.infinity)
                            .padding(proxy2.size.width * 0.04)
                            .frame(width: proxy2.size.width, height: proxy2.size.width)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(height:proxy.size.height * 0.6)
                }
                Text(assistant.string(forKey: garment.localizationKey + "_description").description.uppercased())
                    .font(.system(size: proxy.size.height * 0.11, weight: .medium, design: .rounded))
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("DefaultTextColor", bundle:.module))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.black)
                    .fixedSize(horizontal: false, vertical: true)
            }.opacity(dimmed && !selected ? 0.5 : 1)
        }
    }
}
//struct GarmentView_Previews: PreviewProvider {
//    static var previews: some View {
//        HStack() {
//            GarmentView(model: GarmentViewModel.init(garment: Garment.shoes)) { model in
//
//            }.background(Color.red)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.gray)
//        .edgesIgnoringSafeArea(.all)
//        .modifier(PreviewDeviceCategory(category: .largePad))
//        .environmentObject(Localization(.swedish))
//    }
//}
