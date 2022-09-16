//
//  AdminSharedActivitiesView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-08-30.
//

import SwiftUI
import SharedActivities
import Combine
import SDWebImageSwiftUI

struct SharedActivityTagView : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var image:Image? {
        UNDPGoal.goalFrom(sharedActivityTag: tag)?.icon
    }
    var text:String {
        guard let goal = UNDPGoal.goalFrom(sharedActivityTag: tag) else {
            return tag
        }
        return "Mål \(goal.rawValue)"
    }
    var color:Color {
        UNDPGoal.goalFrom(sharedActivityTag: tag)?.backgroundColor ?? Color.gray
    }
    var tag:String
    var body: some View {
        HStack(spacing:2) {
            image?
                .resizable()
                .aspectRatio(1,contentMode: .fit)
                .frame(height: 20)
            if horizontalSizeClass == .regular {
                Text(text)
            }
        }
        .padding([.top,.bottom], 2)
        .padding([.leading,.trailing],4)
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(3.0)
        .font(.caption)
    }
}
struct SharedActivityTagStack: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var tags:[String]
    var body: some View {
        LBGridView(items: tags.count, columns: horizontalSizeClass == .regular ? 8 : 6, verticalSpacing: 4, horizontalSpacing: 4, verticalAlignment: .top, horizontalAlignment: .leading){ i in
            SharedActivityTagView(tag: tags[i])
        }.frame(maxWidth:.infinity,alignment: .topLeading)
    }
}

struct SharedActivityListItem : View {
    var activity:SharedActivity
    @State var isLoading:Bool = true
    var imageOverlay: some View {
        WebImage(url: activity.coverImage)
            .placeholder {
                LBActivityIndicator(isAnimating: $isLoading, style: .large).foregroundColor(.gray)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
    var body:some View {
        HStack(alignment:.top) {
            // lägg in länkar och övrig media
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray)
                .aspectRatio(1, contentMode: .fit)
                .frame(height:70)
                .overlay(imageOverlay)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment:.leading) {
                Text(activity.title).font(.headline)
                Text("\(activity.participants.description), \(activity.enviroment.description.lowercased())").font(.subheadline)
                SharedActivityTagStack(tags: activity.tags)
            }
        }
    }
}

struct AdminSharedActivitiesView: View {
    /// här väljer vi bland alla aktivities i en modal vy kanske?
    /// Ska vi marknadsföra aktiviteterna på något sätt?
    /// kanske om barn
    @ObservedObject var db:ActivityDatabase
    var action:(Activity) -> Void
    var body: some View {
        List {
            ForEach(db.latest) { activity in
                NavigationLink(
                    destination: AdminSharedActivityView(activity: activity, action:action),
                    label: {
                        SharedActivityListItem(activity: activity)
                    })
            }
            
        }.navigationBarTitle("Aktivitetsdatabasen",displayMode: .inline)
    }
}
struct AdminSharedActivitiesView_Previews: PreviewProvider {
    static var db = ActivityDatabase(previewData:true)
    static var previews: some View {
        Group {
            NavigationView {
                AdminSharedActivitiesView(db: db) { activity in
                    
                }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
