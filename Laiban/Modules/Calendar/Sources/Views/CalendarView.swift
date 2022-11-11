//
//  CalendarView.swift
//
//  Created by Tomas Green on 2020-04-21.
//

import SwiftUI
import PublicCalendar

import Assistant
import Analytics

struct TodayView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.locale) var locale
    var day: DayView.Day
    var size: CGFloat
    var body: some View {
        Text(day.isToday ? day.name(in:locale).description : "")
            .foregroundColor(day.textColor)
            .background(Circle().foregroundColor(day.color))
    }
}
struct SelectedDayViewModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.locale) var locale
    var day: DayView.Day
    var selectedDay: DayView.Day
    var name:String {
        return self.horizontalSizeClass == .regular ? self.day.name(in:locale) : self.day.shortName(in:locale)
    }
    var padding:CGFloat {
        return self.horizontalSizeClass == .regular ? 15 : 20
    }
    func body(content:Content) -> some View {
        content.overlay(
            GeometryReader() { proxy in
                LBBadgeView(rimColor: self.day.altColor) { diameter in
                    let s = diameter * 0.15
                    let size =  s < 15 ? 15 : s
                    Text(self.name)
                        .font(.system(size: size, weight: .semibold, design: .rounded))
                        .foregroundColor(self.day.altColor)
                }
                .opacity(self.day == self.selectedDay ? 1 : 0)
                .frame(width: proxy.size.width + self.padding, height: proxy.size.width + self.padding).position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }).frame(alignment: .center)
    }
}

struct DayView: View {
    @EnvironmentObject var assistant:Assistant
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.locale) var locale
    @Environment(\.fullscreenContainerProperties) var properties
    
    @Binding var selectedDay:Day
    
    enum Day : Int,CaseIterable {
        case monday = 1
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        case sunday
        var day: Date {
            switch self {
            case .monday: return Date().startOfWeek!
            case .tuesday: return Date().startOfWeek!.dateOffsetBy(days: 1)!
            case .wednesday: return Date().startOfWeek!.dateOffsetBy(days: 2)!
            case .thursday: return Date().startOfWeek!.dateOffsetBy(days: 3)!
            case .friday: return Date().startOfWeek!.dateOffsetBy(days: 4)!
            case .saturday: return Date().startOfWeek!.dateOffsetBy(days: 5)!
            case .sunday: return Date().startOfWeek!.dateOffsetBy(days: 6)!
            }
        }
   
        private var backgroundColorName:String {
            switch self {
            case .monday: return "CalendarColorMonday"
            case .tuesday: return "CalendarColorTuesday"
            case .wednesday: return "CalendarColorWednesday"
            case .thursday: return "CalendarColorThursday"
            case .friday: return "CalendarColorFriday"
            case .saturday: return "CalendarColorSaturday"
            case .sunday: return "CalendarColorSunday"
            }
        }
        private var altColorName:String {
            switch self {
            case .monday: return "CalendarColorMondayAlt"
            case .tuesday: return "CalendarColorTuesdayAlt"
            case .wednesday: return "CalendarColorWednesdayAlt"
            case .thursday: return "CalendarColorThursdayAlt"
            case .friday: return "CalendarColorFridayAlt"
            case .saturday: return "CalendarColorSaturdayAlt"
            case .sunday: return "CalendarColorSundayAlt"
            }
        }
        var backgroundColor:Color {
            Color(backgroundColorName, bundle:.module)
        }
        var altColor:Color {
            Color(altColorName, bundle:.module)
        }
        var descriptionKey:String {
            switch self {
            case .monday: return "calendar_weekday_monday"
            case .tuesday: return "calendar_weekday_tuesday"
            case .wednesday: return "calendar_weekday_wednesday"
            case .thursday: return "calendar_weekday_thursday"
            case .friday:
                if date.actualWeekDay == rawValue {
                    return "calendar_weekday_friday_today"
                }
                return "calendar_weekday_friday"
            case .saturday: return "calendar_weekday_saturday"
            case .sunday:
                if date.actualWeekDay == rawValue {
                    return "calendar_weekday_sunday_today"
                }
                return "calendar_weekday_sunday"
            }
        }
        func shortName(in locale:Locale) -> String {
            let f = DateFormatter()
            f.locale = locale
            f.dateFormat = "EE"
            return f.string(from: day).capitalized
        }
        func name(in locale:Locale) -> String {
            let f = DateFormatter()
            f.locale = locale
            f.dateFormat = "EEEE"
            return f.string(from: day).capitalized
        }
        private var date:Date {
            return Date()
        }
        var borderColor:Color {
            if date.actualWeekDay > self.rawValue {
                return altColor.opacity(0.2)
            }
            return altColor
        }
        var textColor: Color {
            if date.actualWeekDay > self.rawValue {
                return altColor.opacity(0.5)
            }
            return altColor
        }
        var color: Color {
            if date.actualWeekDay > self.rawValue {
                return backgroundColor.opacity(0.5)
            }
            return backgroundColor
        }
        var isToday:Bool {
            date.actualWeekDay == self.rawValue
        }
        
        private var viewmodel:CalendarViewModel {
            return CalendarViewModel()
        }
        
        func isFree(events:[OtherCalendarEvent]?) -> Bool {
            return events?.contains(where: { $0.date.isSameDay(as: day)}) ?? false
        }
        
        static var current:Day {
            Day(rawValue: Date().actualWeekDay)!
        }
    }
    var padding:CGFloat {
        self.horizontalSizeClass == .regular ? 15 : 10
    }
    var day:Day
    var body: some View {
        Text(self.horizontalSizeClass == .regular ? self.day.name(in: locale) : self.day.shortName(in: locale))
            .underline(day.isToday)
            .padding(EdgeInsets(top: 0, leading: self.padding, bottom: 0, trailing: self.padding))
            .frame(maxHeight: .infinity)
            .lineLimit(1)
            .foregroundColor(self.day.textColor)
            .font(properties.font, ofSize: .xs)
            .frame(alignment:.center)
            .zIndex(day == selectedDay ? 10 : 0)
            .background(DayBG(day: self.day))
            .modifier(SelectedDayViewModifier(day: self.day, selectedDay: self.selectedDay))
    }
}

struct DayBG : View {
    var day:DayView.Day
    var body: some View {
        HStack(spacing:0) {
            if self.day == .monday {
                Rectangle().frame(width: 2).background(self.day.borderColor)
            }
            VStack(spacing:0) {
                Rectangle().frame(height: 2).background(self.day.borderColor)
                Spacer()
                Rectangle().frame(height: 2).background(self.day.borderColor)
            }
            if self.day.rawValue + 1 != Date().actualWeekDay {
                Rectangle().frame(width: 2).background(self.day.borderColor)
            }
        }
        .background(day.color)
        .foregroundColor(day.borderColor)
        .zIndex(day.isToday ? 10 : 0)
    }
}

public struct CalendarView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @State var calendarEvent:CalendarEvent?
    @StateObject var viewModel = CalendarViewModel()
    @ObservedObject var service:CalendarService
    
    var contentProvider:CalendarContentProvider?
    public init(service:CalendarService, contentProvider:CalendarContentProvider?) {
        self.service = service
        self.contentProvider = contentProvider
    }
    public var body: some View {
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: self.horizontalSizeClass == .regular ? 40 : 20) {
                Text(self.viewModel.title)
                    .font(properties.font, ofSize: .n, weight: .heavy)
                VStack {
                    Text(LocalizedStringKey(self.viewModel.selectedDay.descriptionKey), bundle: .module)
                }.lineLimit(nil)
                
                HStack(spacing: 0) {
                    ForEach(DayView.Day.allCases, id: \.self) { day in
                        DayView(selectedDay:$viewModel.selectedDay, day: day).onTapGesture {
                            print(day.descriptionKey)
                            self.calendarEvent = service.calendarEvents(on: day.day ).first
                            self.viewModel.didTap(day: day)
                        }
                    }
                }
                .frame(height: 44)
                .padding(.top, 20)
                
                if let selectedItem = calendarEvent {
                    GeometryReader() { proxy in
                        VStack() {
                            Text(selectedItem.icon ?? "").font(Font.system(size: proxy.size.height * 0.3)).padding(.bottom, self.horizontalSizeClass == .regular ? 30 : 10)
                            Text(selectedItem.content)
                            if self.viewModel.selectedDay.isFree(events: self.viewModel.otherEvents) {
                                Text(LocalizedStringKey("calendar_free_day"), bundle: .module)
                            }
                        }
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, maxHeight:.infinity)
                        .padding(self.horizontalSizeClass == .regular ? 30 : 20)
                        .background(Color.white)
                        .cornerRadius(36)
                        .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 0)
                        .padding(properties.spacing[.m])
                    }
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .padding(.top, 10)
                    
                } else {
                    Spacer()
                }
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 30) {
                        Spacer()
                        ForEach(self.viewModel.todaysEvents, id:\.id) { item in
                            Button(action: {
                                calendarEvent = item
//                                assistant.speak(item.title)
                            }) {
                                
                                if let icon = item.icon {
                                    EmojiCircleSimpleView(emoji: icon, disabled:assistant.isSpeaking)
                                }
                            }
                            .frame(width: geometry.size.height * 0.1 * properties.windowRatio, height: geometry.size.height * 0.1 * properties.windowRatio)
                            .scaleEffect(item.id == calendarEvent?.id ? 1.3 : 1)
                            .animation(.easeInOut(duration: 0.2))
                            .disabled(assistant.isSpeaking)
                        }
                        Spacer()
                    }
                    .frame(minWidth:geometry.size.width,alignment: .center)
                    .frame(height: properties.windowRatio * geometry.size.height * 0.2)
                }
                .frame(maxWidth:.infinity,alignment: .center)
                .frame(height: properties.windowRatio * geometry.size.height * 0.2)
                .onAppear(perform: {
                    self.calendarEvent = self.viewModel.todaysEvents.first ?? nil
                })
                
                
            }.font(properties.font, ofSize: .n)
                .padding(properties.spacing[.m])
                .frame(maxWidth: .infinity, maxHeight:.infinity)
                .multilineTextAlignment(.center)
                .wrap(overlay: .emoji("🗓", Color("RimColorCalendar",bundle: .module)))
                .transition(.opacity.combined(with: .scale))
                .onAppear {
                    AnalyticsService.shared.logPageView(self)
                    viewModel.initiate(with: service, and: assistant,contentProvider: contentProvider)
                }
                .onReceive(assistant.$translationBundle) { _ in
                    viewModel.update()
                }
        }
    }
}


struct CalendarView_Previews: PreviewProvider {
    static var service: CalendarService = {
        let service = CalendarService()
        service.data = [CalendarEvent(date: Date(), content: "A is test event 1 A is test event 1 A is test event 1 A is test event 1 A is test event 1 A is test event 1 A is test event 1 A is test event 1 A is test event 1", icon: "🗓"),CalendarEvent(date: Date(), content: "A is test event 2", icon: "🗓"),CalendarEvent(date: Date(), content: "A is test event 3", icon: "🗓"),CalendarEvent(date: Date().tomorrow!, content: "A is test event 4", icon: "🗓")]
        return service
    }()
    static var previews: some View {
        LBFullscreenContainer { _ in
            CalendarView(service: service, contentProvider: nil)
        }.attachPreviewEnvironmentObjects()
    }
}
