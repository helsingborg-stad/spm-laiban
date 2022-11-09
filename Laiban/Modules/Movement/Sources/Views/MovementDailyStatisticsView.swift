//
//  MovementDailyStatisticsView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-02.
//

import SwiftUI
import Assistant

struct MovementDailyStatisticsView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant:Assistant
    @EnvironmentObject var viewState:LBViewState
    @State private var animating = false
    @State private var showSheet = false
    
    @ObservedObject var service:MovementService
    
    var title:String {
        let str:String
        let a = Int(Date().timeIntervalSince(date) / 60 / 60 / 24)
        if a == 0 {
            str = "movement_statistics_title_today"
        } else if a == 1 {
            str = "movement_statistics_title_yesterday"
        } else {
            str = "movement_statistics_title_weekday_\(date.actualWeekDay)"
        }
        return assistant.formattedString(forKey: str, String(Int(service.movementManager.movementSteps(for: date))), String(service.movementManager.movementMeters(for: date)))
    }

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
                        Text(title)
                            .font(properties.font, ofSize: .n)
                            .multilineTextAlignment(.center)
                            .padding(.top,10)
                        HStack(spacing: 50) {
                            MovementBarView(model: model).frame(maxWidth:.infinity).onTapGesture {
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
                                Text("Hur långt är det?")
                                    .padding([.top,.bottom])
                                    .font(properties.font, ofSize: .n,color: .white)
                                    .frame(maxWidth: 250)
                                    .background(Capsule().fill(Color("DefaultTextColor",bundle:.module)))
                                    .shadow(enabled: true)
                                    .opacity(animating ? 1 : 0)
                            })
                        }
                    }
                }
            }
        }.onAppear {
            animating = true
        }
        .sheet(isPresented: $showSheet, content: {
            let meters = service.movementManager.movementMeters(for: date)
            withAnimation {
                DailyStatisticsSheet(showSheet: $showSheet, meters: meters)
            }
        })
    }
}

struct DailyStatisticsSheet: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Binding var showSheet: Bool
    @State private var animate = false
    let meters: Int
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack {
                        Text("Be en pedagog hämta en annan iPad och titta tillsammans hur långt ni kommer när ni går \(meters) m")
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
                }) {
                    Text("Stäng")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding([.leading, .trailing], 80)
                        .padding([.top, .bottom], 20)
                        .background(Color("DefaultTextColor",bundle:.module))
                        .cornerRadius(26)
                        .shadow(color: Color.gray.opacity(0.5), radius: 8)
                }
            }.padding(.vertical)
                .onAppear {
                    animate = true
                }
        }
        .padding(50)
        .background(Color("SecondaryContainerBackgroundColor", bundle: .module).edgesIgnoringSafeArea(.all))
    }
}
