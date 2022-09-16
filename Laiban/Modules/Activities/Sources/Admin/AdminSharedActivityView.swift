//
//  AdminSharedActivityView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-08-31.
//

import SwiftUI
import Combine
import SharedActivities
import SDWebImageSwiftUI


struct AdminSharedActivityView: View {
    @State var isLoading:Bool = true
    @State var publishers = Set<AnyCancellable>()
    var activity:SharedActivity
    var action:(Activity) -> Void
    var imageOverlay: some View {
        WebImage(url: activity.coverImage)
            .placeholder {
                LBActivityIndicator(isAnimating: $isLoading, style: .large).foregroundColor(.gray)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
    @State var copying:Bool = false
    var buttonOverlay: some View {
        Button(action: {
            copying = true
            URLSession.shared.dataTaskPublisher(for: activity.coverImage).tryMap({$0.data}).map({UIImage(data: $0)}).receive(on: DispatchQueue.main).replaceError(with: nil).sink { image in
                if let image = image {
                    let id = Activity.imageStorage.write(image: image)
                    action(Activity(activity, imageId: id))
                } else {
                    action(Activity(activity, imageId: nil))
                }
                copying = false
            }.store(in: &publishers)
        }, label: {
            Text("Lägg till som aktivitet")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth:.infinity)
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
        })
    }
    func imageRectangle(using proxy:GeometryProxy) -> some View {
        Rectangle()
            .frame(height: proxy.size.height * 0.3)
            .overlay(imageOverlay)
            .clipped()
    }
    var media: some View {
        Group {
            ForEach(activity.otherMedia, id:\.url) { media in
                NavigationLink(media.title ?? media.url.host ?? "Media", destination: SafariView(url: media.url).allowAutoDismiss { true })
                    .lineLimit(1).foregroundColor(.blue)
                Divider()
            }
        }
    }
    var topInfo : some View {
        Group {
            Text(activity.title).font(.headline)
            Text("Lämplig för").font(.headline).padding(.top, 15)
            Text("\(activity.participants.description), \(activity.enviroment.description.lowercased())")
                .font(.body)
            SharedActivityTagStack(tags: activity.tags)
            Text("Syfte").font(.headline).padding(.top, 15)
            Text(activity.purpose)
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            Text("Beskrivning").font(.headline).padding(.top, 15)
            Text(activity.description)
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
        }
    }
    var info: some View {
        VStack(alignment:.leading) {
            
            topInfo
            Text("Media och information").font(.headline).padding(.top, 15)
            Divider()
            if activity.link != nil {
                NavigationLink(activity.link!.title ?? "Mer info", destination: SafariView(url: activity.link!.url).allowAutoDismiss { true })
                Divider()
            }
            media
        }.padding()
    }
    var body: some View {
        GeometryReader { proxy in
            VStack {
                ScrollView {
                    imageRectangle(using: proxy)
                    info
                }
                .frame(maxWidth:.infinity,maxHeight:.infinity)
                buttonOverlay.background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.bottom)).shadow(radius: 5)
            }
        }
        .navigationBarTitle(Text(activity.title), displayMode: .inline).disabled(copying)
    }
}
extension URL : Identifiable {
    public var id:String {
        return self.absoluteString
    }
}
struct AdminSharedActivityInfoSectionView: View {
    var activity:SharedActivity
    @State var url:URL? = nil
    var body: some View {
        Section(header:Text("Info från aktivitetsdatabasen")) {
            VStack(alignment:.leading, spacing:8) {
                Text(activity.title).font(.headline).padding(.top, 10)
                Text("Lämplig för").font(.headline).padding(.top, 15)
                Text("\(activity.participants.description), \(activity.enviroment.description.lowercased())")
                    .font(.body)
                SharedActivityTagStack(tags: activity.tags)
                Text("Syfte").font(.headline).padding(.top, 15)
                Text(activity.purpose)
                    .font(.body)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Text("Beskrivning").font(.headline).padding(.top, 15)
                Text(activity.description)
                    .font(.body)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }.sheet(item: $url) { url in
                SafariView(url: url).allowAutoDismiss { true }
            }
            if activity.link != nil {
                Button(action: {
                    self.url = activity.link!.url
                }, label: {
                    Text(activity.link!.title ?? "Mer information")
                })
            }
            ForEach(activity.otherMedia, id:\.url) { media in
                Button(action: {
                    self.url = media.url
                }, label: {
                    Text(media.title ?? media.url.host ?? "Media")
                })
            }
        }
    }
}
struct AdminSharedActivityView_Previews: PreviewProvider {
    static var arr = SharedActivity.previewData
    static var previews: some View {
        Group {
            NavigationView {
                AdminSharedActivityView(activity: arr[1]) { activity in
                    
                }
            }.navigationViewStyle(StackNavigationViewStyle())
            List {
                AdminSharedActivityInfoSectionView(activity: arr[1])
            }
        }
    }
}

