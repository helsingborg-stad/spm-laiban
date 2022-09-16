//
//  OutdoorClothesSelectorView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-11-23.
//

import SwiftUI


struct GarmentGroupView : View {
    @Binding var selection:[Garment]
    var geometry:GeometryProxy
    var group:GarmentGroup
    func isSelected(garment:Garment) -> Bool {
        return selection.contains(garment)
    }
    func dimmed(garment:Garment) -> Bool {
        return selection.contains { garment.incompatibles.contains($0) }
    }
    func select(garment:Garment) {
        withAnimation {
            if selection.contains(garment) {
                selection.removeAll { $0 == garment }
            } else {
                selection.removeAll { garment.incompatibles.contains($0) }
                selection.append(garment)
            }
        }
    }
    var body: some View {
        HStack(spacing:0) {
            ForEach(group.garments) { garment in
                SelectableGarmentView(garment:garment, selected: isSelected(garment: garment),dimmed: dimmed(garment:garment)).frame(
                    width: geometry.size.width/4,
                    height:geometry.size.height/CGFloat(Garment.groups.count+1)
                )
                    .animation(.default)
                    .onTapGesture {
                        select(garment:garment)
                    }
            }
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.leading)
    }
}

struct OutdoorClothesSelectorView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var viewState:LBViewState
    @ObservedObject var viewModel:OutdoorsView.OutdoorsViewModel
    @State var status:LBParentalGateStatus? = LBDevice.isPreview ? .passed : .undetermined
    @State var selection = [Garment]()
    var done:([Garment]) -> Void

    var body: some View {
        VStack(alignment:.center, spacing:0) {
            Text(LocalizedStringKey("outdoors_feedback_change_title"),bundle: LBBundle)
                .font(properties.font, ofSize: .l)
                .multilineTextAlignment(.center)
            GeometryReader { proxy in
                VStack(alignment:.leading, spacing:0) {
                    ForEach(Garment.groups,id:\.name) { group in
                        GarmentGroupView(selection: $selection, geometry: proxy, group: group)
                    }.frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.leading)
                }
                .padding([.top,.bottom],properties.spacing[.m])
                .tertieryContainerBackground()
                .padding([.top,.bottom],properties.spacing[.m])
            }.frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .leading)
            Button(action: {
                done(selection)
            }) {
                Text(LocalizedStringKey("word_done"),bundle: LBBundle)
                    .padding()
                    .frame(maxWidth: 300)
                    .font(properties.font, ofSize: .l, color:.white)
                    .clipShape(Capsule())
                    .background(Capsule().fill(Color("DefaultTextColor", bundle: .module)))
                    .shadow(enabled: true)
            }
        }
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .parentalGate(properties: properties, status: $status)
        .onStatusChanged({ status in
            if status == .cancelled {
                viewModel.viewSection = .clothes
            }
        })
        .onAppear {
            viewState.inactivityTimerDisabled(true, for: .outdoors)
            viewState.actionButtons([.languages,.back], for: .outdoors)
        }.onDisappear {
            viewState.inactivityTimerDisabled(false,for: .outdoors)
        }
    }
}

struct OutdoorClothesSelectorView_Previews: PreviewProvider {
    static var viewState = LBViewState()
    static var service = OutdoorsService()
    static var previews: some View {
        LBFullscreenContainer { _ in
            OutdoorClothesSelectorView(viewModel: OutdoorsView.OutdoorsViewModel(service)) { garments in
                print(garments)
            }
        }
        .attachPreviewEnvironmentObjects()
        .environmentObject(viewState)
    }
}
