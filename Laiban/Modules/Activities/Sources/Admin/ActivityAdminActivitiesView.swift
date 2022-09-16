//
//  ActivityAdminActivitiesView.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-06.
//

import SwiftUI
import Combine

struct ActivityAdminActivitiesView: View {
    struct ItemView : View {
        var item:Activity
        
        func string(from date:Date) -> String {
            let df = DateFormatter()
            df.timeStyle = .none
            df.dateStyle = .medium
            df.doesRelativeDateFormatting = true
            return df.string(from: date)
        }
        
        var body: some View {
            HStack {
                VStack(alignment:.leading) {
                    Text(item.formattedContent()).lineLimit(1)
                    if item.sharedActivity != nil {
                        SharedActivityTagStack(tags: item.sharedActivity?.tags ?? [])
                    }
                }
                Spacer()
                Text(self.string(from: item.date)).foregroundColor(.blue)
            }
        }
    }
    @ObservedObject var service: ActivityService
    @State var showSharedActivities = false
    @State private var selection: String? = nil
    
    func handleActivity(newActivity: Activity, oldActivity: Activity) -> Void {
        if newActivity.content == "" {
            service.remove(newActivity)
            service.save()
            
            LBAnalyticsProxy.shared.log("AdminAction", properties: ["Action":"Remove","ObjectType":"Activity"])
        } else if newActivity != oldActivity {
            if service.contains(newActivity) {
                service.update(newActivity)

                LBAnalyticsProxy.shared.log("AdminAction",properties: ["Action":"Update","ObjectType":"Activity"])
            } else {
                service.add(newActivity)
                
                LBAnalyticsProxy.shared.log("AdminAction",properties: ["Action":"Add","ObjectType":"Activity"])
            }
            
            service.save()
        }
    }
    
    func editItemView(for activity: Activity? = nil) -> some View {
        if activity != nil {
            return ActivityAdminActivityView(item: .init(activity: activity!), service: service, onUpdate: handleActivity)
        } else {
            return ActivityAdminActivityView(service: service, onUpdate: handleActivity)
        }
    }
    
    var body: some View {
        Form {
            Section {
                NavigationLink(destination: editItemView()) {
                    Text("Lägg till aktivitet").foregroundColor(Color.accentColor)
                }
                .id("create new activity")
            }
            Section(header: Text("Alla aktiviteter")) {
                if service.data.count == 0 {
                    Text("Inga aktiviteter").foregroundColor(.gray)
                }
                
                ForEach(service.data) { item in
                    NavigationLink(
                        destination: editItemView(for: item),
                        tag: item.id,
                        selection: $selection) {
                            ItemView(item: item).contextMenu {
                                Button(action: {
                                    service.add(item.copy)
                                    service.save()
                                }) {
                                    Text("Duplicera")
                                }
                            }
                        }.id(item.id)
                }.onDelete { (indexSet) in
                    indexSet.forEach { (i) in
                        Activity.imageStorage.delete(image: service.data[i].image)
                    }
                    service.data.remove(atOffsets: indexSet)
                    service.save()
                    LBAnalyticsProxy.shared.log("AdminAction",properties: ["Action":"Delete","ObjectType":"Activity"])
                }
            }
        }
        .navigationBarTitle(Text("Aktivitet"))
    }
}

struct ActivityAdminActivitiesView_Previews: PreviewProvider {
    static var service = ActivityService()
    
    static var previews: some View {
        NavigationView {
            ActivityAdminActivitiesView(service: service)
        }
        .navigationViewStyle(.stack)
    }
}
