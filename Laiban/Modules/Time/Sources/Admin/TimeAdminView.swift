//
//  WeatherAdminView.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-12.
//

import SwiftUI
import Combine


struct TimePicker: View {
    class TimePickerModel : ObservableObject {
        var subject = PassthroughSubject<String,Never>()
        @Published var date:Date = Date() {
            didSet {
                subject.send(timeStringfrom(date: date))
            }
        }
    }
    @StateObject var model = TimePickerModel()
    var onUpdate: (String) -> Void
    var title:String
    private var original:String
    init(title:String, time:String, onUpdate:@escaping (String) -> Void ) {
        self.title = title
        self.original = time
        self.onUpdate = onUpdate
    }
    var body: some View {
        DatePicker(selection: $model.date, displayedComponents: .hourAndMinute) {
            Text(title)
        }
        .onReceive(model.subject) { value in
            if value != original {
                onUpdate(value)
            }
        }
        .onAppear {
            self.model.date = relativeDateFrom(time: original)
        }
    }
}

struct TimeAdminView: View {
    @ObservedObject var service: TimeService
    var body: some View {
        Group {
            TimePicker(title: "Dagen startar", time: service.data.dayStarts) { value in
                service.data.dayStarts = value
                service.save()
            }
            TimePicker(title: "Dagen slutar",time: service.data.dayEnds) { value in
                service.data.dayEnds = value
                service.save()
            }
            NavigationLink(destination: AdminClockEventsView(service: service)) {
                Text("Händelser")
                Spacer()
                Text("\(self.service.data.events.count)")
            }.id("Clock events")
        }
    }
}

struct TimeAdminView_Previews: PreviewProvider {
    static var service = TimeService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    TimeAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
