//
//  ActivityAdminActivityView.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-08.
//

import SwiftUI

struct ActivityAdminActivityView: View {
    struct Item {
        let activity: Activity
        var id:String {
            return activity.id
        }
        var date: Date = relativeDateFrom(time: "00:00") {
            didSet {
                adjustDates()
            }
        }
        var emoji:String = ""
        var content:String = ""
        var contentPast:String = ""
        var contentFuture:String = ""
        var imageName:String? = nil {
            didSet {
                self.populateImage()
            }
        }
        var activityParticipants: [String] = []
        var starts:Date/* {
            didSet {
                if starts > ends {
                    let s = ends.timeIntervalSince(oldValue)
                    ends = starts.addingTimeInterval(s)
                }
            }
        }*/
        var ends:Date/* {
            didSet {
                if ends < starts {
                    let s = starts.timeIntervalSince(oldValue)
                    starts = ends.addingTimeInterval(s * -1)
                }
            }
        }*/
        var hasTimeRange = false
        var image:Image?
        init(activity:Activity) {
            self.activity = activity
            self.date = activity.date
            self.content = activity.content
            self.emoji = activity.emoji ?? ""
            self.contentPast = activity.contentPast ?? ""
            self.contentFuture = activity.contentFuture ?? ""
            self.imageName = activity.image
            self.activityParticipants = activity.participants.sorted()
            if let starts = activity.starts, let ends = activity.ends {
                hasTimeRange = true
                self.starts = starts
                self.ends = ends
            } else {
                self.starts = relativeDateFrom(time: "09:00", date: activity.date)
                self.ends = relativeDateFrom(time: "11:00", date: activity.date)
            }
        }
        
        init() {
            self.activity = Activity()
            self.starts = relativeDateFrom(time: "09:00", date: activity.date)
            self.ends = relativeDateFrom(time: "11:00", date: activity.date)
        }
        var updatedActivity:Activity {
            var activity = self.activity
            activity.date = self.date
            activity.content = self.content
            activity.emoji = self.emoji
            activity.contentPast = self.contentPast == "" ? nil : self.contentPast
            activity.contentFuture = self.contentFuture == "" ? nil : self.contentFuture
            activity.image = self.imageName
            activity.participants = Set(self.activityParticipants)
            if hasTimeRange {
                activity.starts = self.starts
                activity.ends = self.ends
            } else {
                activity.starts = nil
                activity.ends = nil
            }
            return activity
        }
        mutating func adjustDates() {
            let s = timeStringfrom(date: starts)
            let e = timeStringfrom(date: ends)
            self.starts = relativeDateFrom(time: s, date: date)
            self.ends = relativeDateFrom(time: e, date: date)
        }
        mutating func populateImage() {
            image = Activity.imageStorage.image(with: imageName)
        }
        mutating  func deleteImage() {
            Activity.imageStorage.delete(image: self.imageName)
            imageName = nil
            image = nil
        }
        var formattedContent:Text? {
            content == "" ? nil : Text(Activity.string(participants: activityParticipants, content: content))
        }
        var formattedContentPast:Text? {
            contentPast == "" ? nil : Text(Activity.string(participants: activityParticipants, content: contentPast))
        }
        var formattedContentFuture:Text? {
            contentFuture == "" ? nil : Text(Activity.string(participants: activityParticipants, content: contentFuture))
        }
    }
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    static var item:Item?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showImagePicker: Bool = false
    @State var item = Item()
    @State var firstResponder:Bool = false
    @State var isActive = false
    @State var textViewHeight:CGFloat = 20
    var service: ActivityService
    
    var onUpdate: (Activity, Activity) -> Void
    
    func save() {
        var item = self.item
        item.adjustDates()
        let activity = item.updatedActivity
        onUpdate(activity, item.activity)
    }
    var header: some View {
        VStack() {
            self.item.image?.resizable().aspectRatio(contentMode: .fill).frame(width: 150, height: 150).clipped().cornerRadius(10).shadow(radius: 5).padding(.bottom, 10)
            self.item.formattedContent?.multilineTextAlignment(.center)
            self.item.formattedContentPast?.multilineTextAlignment(.center)
            self.item.formattedContentFuture?.multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).padding(30)
    }
    
    var body: some View {
        Form() {
            Section(header: horizontalSizeClass == .regular ? header : nil) {
                LBTextView("Beskrivning (presens, nutid)", text: self.$item.content)
                LBTextView("Beskrivning (perfekt, dåtid)", text: self.$item.contentPast)
                LBTextView("Beskrivning (futurum, framtid)", text: self.$item.contentFuture)
                TextField("Emoji", text: self.$item.emoji)
                Button(action: {
                    if self.item.image == nil {
                        self.showImagePicker = true
                    } else {
                        self.item.deleteImage()
                    }
                }) {
                    Text(self.item.image == nil ? "Lägg till bild" : "Radera bild").foregroundColor(self.item.image == nil ? .accentColor : .red)
                }
            }
            Section(header: Text("Datum och tid")) {
                DatePicker(selection: $item.date, /*in: relativeDateFrom(time: "00:00")...,*/ displayedComponents: .date) {
                    Text("Datum")
                }
                Toggle("På en tid", isOn: $item.hasTimeRange)
                if item.hasTimeRange {
                    DatePicker(selection: $item.starts, /*in: item.date...,*/ displayedComponents: .hourAndMinute) {
                        Text("Startar")
                    }
                    DatePicker(selection: $item.ends, /*in: item.starts...,*/ displayedComponents: .hourAndMinute) {
                        Text("Slutar")
                    }
                }
            }
            Section(header: Text("Deltagare")) {
                ForEach(self.item.activityParticipants, id: \.self) { participant in
                    Text(participant)
                }
                NavigationLink(destination: AdminParticipantsView(activityParticipants: item.activityParticipants, service: service) { activityParticipants in
                    item.activityParticipants = activityParticipants
                }) {
                    Text("Lägg till deltagare")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .sheet(isPresented: self.$showImagePicker){
            PhotoCaptureView(showImagePicker: self.$showImagePicker, imageStorage: Activity.imageStorage) { asset in
                self.item.imageName = asset
            }
        }
        .onDisappear {
            self.save()
        }
    }
}
