//
//  MovementDailyStatisticsView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-02.
//

import SwiftUI
import Assistant
import Combine

struct MovementDailyStatisticsView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isEnabled) var isEnabled
    @EnvironmentObject var assistant:Assistant
    @EnvironmentObject var viewState:LBViewState
    @State private var animating = false
    @State private var showSheet = false
    @ObservedObject var service:MovementService

    var date:Date
    var infoTitle:String? = nil
    var infoDescription:String? = nil
    var infoEmoji:String? = nil
    
    func setShowSheet() {
        showSheet = true
    }
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        return GeometryReader { proxy in
            let model = MovementBarView.ViewModel(movementMeters: service.movementManager.movementMeters(for: date), settings: service.data.settings)
            ZStack {
                VStack {
                    VStack(spacing: 20) {
                        Text(service.viewModel.title!.display)
                            .font(properties.font, ofSize: .n)
                            .multilineTextAlignment(.center)
                            .padding(.top,10)
                        HStack(spacing: 50) {
                            MovementBarView(model: model).frame(maxWidth:.infinity).onTapGesture {
                                animating = true
                            }
                            .animation(.ripple(index: 1))
                            .frame(maxWidth: proxy.size.width * 0.25, maxHeight:.infinity,alignment: .bottom)
                            .padding([.trailing],0)
                            .padding([.top, .bottom], 50)
                            .padding(.leading, 50)
                            
                            MovementFootsteps()
                                .padding([.trailing],50)
                                .padding([.top, .bottom], 50)
                                .padding(.leading, 0)
                        }
                        .frame(maxWidth: .infinity, maxHeight:.infinity,alignment: .bottom)
                        
                    }.frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .top)
                        .padding(.top, 80)
                    Spacer()
                    HStack {
                        Spacer()
                        withAnimation {
                            Button(action: setShowSheet, label: {
                                Text(assistant.string(forKey: "movement_statistics_how_far"))
                                    .padding([.top,.bottom])
                                    .font(properties.font, ofSize: .n,color: .white)
                                    .frame(maxWidth: 250)
                                    .background(Capsule().fill(Color("DefaultTextColor",bundle:.module)))
                                    .shadow(enabled: true)
                                    .opacity(isEnabled ? 1 : 0.5)
                            })
                        }
                    }
                }
            }
        }.onAppear() {
            animating = true
            
        }
        .sheet(isPresented: $showSheet, content: {
            let meters = service.movementManager.movementMeters(for: date)
            
            withAnimation {
                DailyStatisticsSheet(showSheet: $showSheet, meters: meters, service: service)
                    .onAppear {
                        var title = assistant.formattedString(forKey: "movement_statistics_see_distance", String(meters))
                        if let cities = service.movementManager.getCities(), let startName = cities.first(where: {$0.start})?.name, let destinationName = cities.first(where: {$0.destination})?.name {
                            let cityTitle = assistant.formattedString(forKey: "movement_statistics_cities", startName, destinationName)
                            title =  "\(title).\r\n\(cityTitle)"
                        }
                        assistant.speak(title)
                    }
            }
        })
    }
}

struct DailyStatisticsSheet: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.isEnabled) var isEnabled
    @EnvironmentObject var assistant:Assistant
    @Binding var showSheet: Bool
    @State private var animate = false
    @State private var title: String = ""
    @State private var cancellables = Set<AnyCancellable>()

    let meters: Int
    @ObservedObject var service: MovementService
    
    private func getTitle() -> String {
        var title = assistant.formattedString(forKey: "movement_statistics_see_distance", String(meters))
        if let cities = service.movementManager.getCities(), let startName = cities.first(where: {$0.start})?.name, let destinationName = cities.first(where: {$0.destination})?.name {
            let cityTitle = assistant.formattedString(forKey: "movement_statistics_cities", startName, destinationName)
            title =  "\(title).\r\n\(cityTitle)"
        }
        return title
    }
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack {
                        Text(title)
                            .font(properties.font, ofSize: .n)
                            .multilineTextAlignment(.center)
                            .padding(.top,10)
                        Text("🌍")
                            .font(.system(size: 160))
                            .shadow(radius: 25, x: -15, y: 15)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                            .animation(.ripple(index: 2, damping: 0.4, speed: 0.8), value: animate)
                            .offset(.init(width: 0, height: animate ? 0 : -700))
                    }
                }.padding(.vertical, 40)
                Spacer()
                Button(action: {
                    self.showSheet = false
                    assistant.speak("", interrupt: true)
                }) {
                    Text(assistant.string(forKey: "movement_close"))
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding([.leading, .trailing], 80)
                        .padding([.top, .bottom], 20)
                        .background(Color("DefaultTextColor",bundle:.module))
                        .cornerRadius(26)
                        .opacity(isEnabled ? 1 : 0.5)
                        .shadow(color: Color.gray.opacity(0.5), radius: 8)
                }
            }.padding(.vertical)
                .onAppear {
                    animate = true
                    service.movementManager.$cities.sink { value in
                        title = getTitle()
                    }.store(in: &cancellables)
                }
        }
        .padding(50)
        .background(Color("SecondaryContainerBackgroundColor", bundle: .module).edgesIgnoringSafeArea(.all))
    }
}
