//
//  InstagramView.swift
//
//  Created by Tomas Green on 2020-06-03.
//

import AVFoundation
import Combine
import Instagram

import SDWebImageSwiftUI
import SwiftUI
import Assistant

public struct InstagramView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant: Assistant
    @ObservedObject var service: InstagramService
    @State var cancellables = Set<AnyCancellable>()
    @State var clickedImage: Instagram.Media?
    @State var loading: Bool = true
    @State var images = [Instagram.Media]()
    @State var sections = [InstagramSection]()
    @State var instagramObserver: AnyCancellable?
    @State var fullscreenPlayer = AVQueuePlayer()
    var columns: Int {
        horizontalSizeClass == .regular ? 2 : 2
    }
    public init(service:InstagramService) {
        self.service = service
    }
    func update() {
        var wayPast = InstagramSection(items: [], title: assistant.string(forKey: "instagram_very_old_title"))
        for image in images {
            if image.mediaType == .album {
                wayPast.items.append(contentsOf: image.children)
            } else {
                wayPast.items.append(image)
            }
        }
        var arr = [InstagramSection]()
        sections = []
        if wayPast.items.count > 0 {
            arr.append(wayPast)
        }
        sections = arr
    }

    func onImageClick(item: Instagram.Media) {
        viewState.actionButtons([.back, .languages], for: .instagram)
        if item.mediaType == .video {
            fullscreenPlayer.insert(AVPlayerItem(url: item.mediaUrl), after: nil)
            fullscreenPlayer.isMuted = false
            if let caption = item.caption {
                assistant.speak(caption).last?.statusPublisher.sink(receiveValue: { status in
                    if status == .finished {
                        fullscreenPlayer.play()
                        viewState.inactivityTimerDisabled(true, for: .instagram)
                    }
                }).store(in: &cancellables)
            } else {
                fullscreenPlayer.play()
                viewState.inactivityTimerDisabled(true, for: .instagram)
            }
        } else if let text = clickedImage?.caption {
            assistant.speak(text)
        }
    }

    var itemIvew: some View {
        VStack {
            if clickedImage?.mediaType == .image {
                WebImage(url: clickedImage!.mediaUrl)
                    .placeholder {
                        LBActivityIndicator(isAnimating: self.$loading, style: .large).foregroundColor(.gray)
                    }
                    .resizable()
                    .transition(.opacity)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                    .id("clickedImage-" + clickedImage!.mediaUrl.absoluteString)
            } else if clickedImage?.mediaType == .video {
                PlayerView(url: clickedImage!.mediaUrl, player: fullscreenPlayer)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .id("clickedImage-" + clickedImage!.mediaUrl.absoluteString)
            }
            if clickedImage?.caption != nil {
                Text(LocalizedStringKey(clickedImage!.caption!), bundle: assistant.translationBundle)
                    .fontWeight(.bold)
                    .font(properties.font, ofSize: .n)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                    .id("clickedImage-" + clickedImage!.mediaUrl.absoluteString)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(clickedImage != nil ? 1 : 0)
        .scaleEffect(clickedImage != nil ? 1 : 0)
        .zIndex(2)
    }
    var gridView: some View {
        LBScrollView {
            ForEach(sections) { section in
                Text(section.title)
                    .fontWeight(.bold)
                    .font(properties.font, ofSize: .n)

                LBGridView(items: section.items.count, columns: self.columns, verticalSpacing: 2, horizontalSpacing: 2) { index in
                    if section.items[index].mediaType == .image {
                        WebImage(url: section.items[index].mediaUrl)
                            .placeholder {
                                LBActivityIndicator(isAnimating: self.$loading, style: .large).foregroundColor(.gray)
                            }
                            .resizable()
                            .transition(.opacity)
                            .aspectRatio(1, contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onTapGesture {
                                LBAnalyticsProxy.shared.log("InstagramMediaPressed", properties: ["MediaId": section.items[index].id])
                                // self.navigation.advance(InstagramFullscreenViewManager(item: section.items[index]))
                                clickedImage = section.items[index]
                                onImageClick(item: clickedImage!)
                            }
                            .id(section.items[index].mediaUrl)
                    } else {
                        PlayerView(url: section.items[index].mediaUrl).aspectRatio(1, contentMode: .fill).frame(maxWidth: .infinity, maxHeight: .infinity).onTapGesture {
                            LBAnalyticsProxy.shared.log("InstagramMediaPressed", properties: ["MediaId": section.items[index].id])
                            // self.navigation.advance(InstagramFullscreenViewManager(item: section.items[index]))
                            clickedImage = section.items[index]
                            onImageClick(item: clickedImage!)
                        }
                        .id(section.items[index].mediaUrl)
                    }
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
        }
        .onOffsetChanged { _ in
            viewState.registerInteraction()
        }
        .opacity(clickedImage == nil ? 1 : 0)
        .scaleEffect(clickedImage == nil ? 1 : 0)
    }

    public var body: some View {
        ZStack {
            if sections.count == 0 {
                LBActivityIndicator(isAnimating: self.$loading, style: .large).foregroundColor(.gray)
            }
            //if clickedImage != nil {
                itemIvew
            //}
            gridView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .onAppear {
            instagramObserver = service.instagram.latest.sink(receiveValue: { media in
                images = media?.sorted(by: { $0.timestamp > $1.timestamp }) ?? []
            })
            update()
            assistant.speak("instagram_very_old_title")
            LBAnalyticsProxy.shared.logPageView(self)
        }
        .onReceive(properties.actionBarNotifier) { action in
            if action == .back {
                clickedImage = nil
                fullscreenPlayer.pause()
                fullscreenPlayer.removeAllItems()
                viewState.actionButtons([.home, .languages], for: .instagram)
                viewState.inactivityTimerDisabled(false, for: .instagram)
            }
        }
        .animation(.spring(), value: clickedImage)
    }
}

struct InstagramView_Previews: PreviewProvider {
    static var service = InstagramService()
    static var previews: some View {
        LBFullscreenContainer { _ in
            InstagramView(service: service)
        }.attachPreviewEnvironmentObjects()
    }
}
