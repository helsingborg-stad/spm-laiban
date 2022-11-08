//
//  MovementAdminViews.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-08.
//

import Foundation
import SwiftUI


struct MovementAdminViews: View {
    @ObservedObject var service:MovementService

    var body: some View {

        Section{
            List(){
                MovementActivityListView(service: service)
            }
        }.navigationBarTitle(Text("Rörelse"))
    }
}

struct MovementActivityListItem:View {

    @State var activity: MovementActivity
    @ObservedObject var service:MovementService

    var body:some View {
        NavigationLink(destination: MovementAdminEditActivityView(service: service, activity: activity, workingActivity: .init(service: service, activity: activity))){
            HStack(alignment: .center) {


                Text(activity.emoji)

                VStack(alignment: .leading) {
                    Text(activity.title)
                }

                Spacer()

                Toggle("", isOn: $activity.isActive).onTapGesture {
                    service.toggleEnabled(activity: activity)
                }
            }.foregroundColor(activity.isActive ? .black : .gray)
        }
    }
}
struct MovementActivityListView: View {

    @State private var showingSheet = false

    @ObservedObject var service:MovementService
    var body: some View {
        Section {
            ForEach(service.data.activities, id: \.self) { activity in
                MovementActivityListItem(activity: activity, service: service)
            }.onDelete(perform: service.deleteActivity)
        } header: {

            VStack(alignment: .leading){

                Text("")
                Spacer(minLength: 40.0)
                HStack{
                    Text("Aktiviteter")
                    Spacer()
                    NavigationLink(destination: MovementAdminEditActivityView(service: service, activity: .init(id: UUID().uuidString, colorString: MovementActivity.colorStrings.randomElement()!, title: "", emoji: ""), workingActivity: .init(service: service, activity: .init(id: UUID().uuidString, colorString: MovementActivity.colorStrings.randomElement()!, title: "", emoji: "") ))){
                        Image(systemName: "plus")
                            .resizable()
                            .padding(6)
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct MovementAdminViews_Previews: PreviewProvider {
    static var service = MovementService()
    static var previews: some View {
        NavigationView {
            Form {
                MovementAdminViews(service: service)
            }
        }.navigationViewStyle(.stack)
    }
}
