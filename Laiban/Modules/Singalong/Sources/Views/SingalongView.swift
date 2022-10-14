//
//  SingalongView.swift
//
//  Created by Tomas Green on 2020-03-23.
//

import SwiftUI
import UIKit
import Analytics
import Assistant

struct AttributedText: UIViewRepresentable {
    var maxSize:CGFloat
    var text:NSAttributedString
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = maxSize
        label.attributedText = text
        label.textAlignment = .center
        return label
    }
    func updateUIView(_ view: UILabel, context: Context) {
        view.attributedText = text
    }
}
private struct PlayButtonView: View {
    struct ButtonIconCircle: View {
        var color: Color
        var body: some View {
            Circle().foregroundColor(color).overlay(
                Circle()
                    .stroke(Color.clear, lineWidth: 5)
                    .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 0)
                    .clipShape(
                        Circle()
                    )
            )
        }
    }
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var size: CGFloat
    var color: Color
    var body: some View {
        ZStack() {
            ButtonIconCircle(color: color).shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 0)
            Image(systemName: "play.fill")
                .resizable()
                .foregroundColor(.white)
                .aspectRatio(contentMode: .fit)
                .frame(width:size * 0.4,height:size * 0.4).offset(x: 3, y: 0)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 2)
        }.frame(width:size,height:size)
    }
}

public struct SingalongView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant: Assistant
    @StateObject var viewModel = SingalongViewModel()
    public init() {
        
    }
    public var body: some View {
        GeometryReader() { proxy in
            if !self.viewModel.completedStages.contains(.singing) || self.viewModel.completedStages.contains(.done) {
                VStack() {
                    Text(LocalizedStringKey(self.viewModel.text),bundle: LBBundle)
                        .lineLimit(nil).fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .font(properties.font, ofSize: .l)
                        .padding(EdgeInsets(
                            top: 0,
                            leading: self.horizontalSizeClass == .regular ? 40 : 0,
                            bottom: 0,
                            trailing: self.horizontalSizeClass == .regular ? 40 : 0
                        ))
                    
                    if self.viewModel.enabled {
                        Button(action: {
                            self.viewModel.play()
                            AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"PlaySingalong"])
                        }) {
                            PlayButtonView(size: proxy.size.width * 0.2, color: Color("RimColorSingalong",bundle:LBBundle))
                        }.opacity(self.viewModel.completedStages.contains(.waiting) ? 1 : 0)
                    }
                }.frame(maxWidth: .infinity, maxHeight:.infinity)
            } else {
                AttributedText(maxSize: proxy.size.width * 0.8, text: self.viewModel.currentText)
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .font(properties.font, ofSize: .n)
            }
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .wrap(overlay: .emoji("🤲", Color("RimColorSingalong",bundle:LBBundle)), onTapOverlayAction: {
            viewModel.resetSinger()
            viewModel.play()
        })
        .onAppear {
            viewModel.initiate(using: assistant)
            AnalyticsService.shared.logPageView(self)
        }
        .onReceive(viewModel.$completedStages) { stages in 
            if stages.contains(.done) || stages.contains(.waiting) {
                viewState.inactivityTimerDisabled(false, for: .singalong)
            } else if stages.contains(.singing) {
                viewState.inactivityTimerDisabled(true, for: .singalong)
            }
        }
    }
}

struct SingalongView_PreviewLargePad: PreviewProvider {
    static var previews: some View {
        LBFullscreenContainer { _ in
            SingalongView()
        }
        .attachPreviewEnvironmentObjects()
        .environmentObject(LBViewState())
    }
}
