//
//  TeacherMessageView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-15.
//

import SwiftUI

import Assistant

struct DetailedMessageView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant:Assistant
    var message:Message
    @State var isSpeakingText:Bool = false
    @State var isSpeakingTitle:Bool = false
    var body: some View {
        HStack(alignment:message.text.isEmpty ? .center : .top) {
            VStack(alignment:.leading,spacing: 10) {
                Text(assistant.string(forKey: message.title))
                    .underline(isSpeakingTitle)
                    .font(properties.font, ofSize: .n,weight: .bold)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                if !message.text.isEmpty {
                    Text(assistant.string(forKey: message.text))
                        .underline(isSpeakingText)
                        .font(properties.font, ofSize: .n,weight: .regular)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer()
            Text(message.emoji).font(properties.font, ofSize: .xl)
        }
        .frame(maxWidth:.infinity)
        .fixedSize(horizontal: false, vertical: true)
        .transition(.scale)
        .contentShape(Rectangle())
        .onTapGesture {
            assistant.speak([
                (message.title,message.title),
                (message.text,message.text)
            ], interrupt: true)
        }
        .id(message.id)
        .onReceive(assistant.$currentlySpeaking) { utterance in
            withAnimation {
                guard let utterance = utterance else {
                    isSpeakingTitle = false
                    isSpeakingText = false
                    return
                }
                isSpeakingTitle = message.title == utterance.tag
                isSpeakingText = message.text == utterance.tag
            }
        }
    }
}
struct SimpleMessageView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var assistant:Assistant
    var message:Message
    var body: some View {
        HStack(alignment:.center,spacing: properties.spacing[.m]) {
            Text(message.emoji)
                .font(properties.font, ofSize: .xl)
            Text(assistant.string(forKey: message.title))
                .font(properties.font, ofSize: .n,weight: .bold)
            Spacer()
        }
        .id(message.id)
    }
}
struct MessagesBubbleView<Content: View>: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.isEnabled) var isEnabled
    var category:MessageCategory = .info
    let content: () -> Content
    init(category: MessageCategory = .info, @ViewBuilder content: @escaping () -> Content) {
        self.category = category
        self.content = content
    }
    @ViewBuilder var categoryBackground: some View {
        if category == .disease {
            Color.white.overlay(Color.yellow.opacity(0.5))
        } else {
            Color.white
        }
    }
    var body: some View {
        content()
            .multilineTextAlignment(.leading)
            .padding(properties.spacing[.m])
            .background(categoryBackground)
            .cornerRadius(15)
            .shadow(enabled: isEnabled)
            .padding(4)
            .animation(.none)
    }
}
struct MessagesListView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var messages:[Message]
    var category:MessageCategory = .info
    var detailed:Bool = false
    var body: some View {
        MessagesBubbleView(category:category) {
            VStack(spacing: properties.spacing[.m]) {
                let last = messages.last
                ForEach(messages) { d in
                    if detailed {
                        DetailedMessageView(message: d)
                    } else {
                        SimpleMessageView(message: d)
                    }
                    if d.id != last?.id {
                        Divider()
                    }
                }
            }
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var array = [
        Message(category: .disease, name:"Covid-19", title: "Nu går Covid-19 på skolan!", text: "Testa er omedelbart, mer information finns på www.1177.se", emoji:"🦠"),
        Message(name:"Semester", title: "Förskolan tar ledigt", text: "Från och med fredagn den 15 Juni så är förskolorna stängda. Kom ihåg att ta med er alla kläder och leksaker med er hem inför semestern!", emoji:"🌞")
    ]
    static var previews: some View {
        ScrollView {
            VStack {
                MessagesListView(messages: array)
                MessagesListView(messages: array,detailed:true)
            }
            .padding()
        }.attachPreviewEnvironmentObjects()
    }
}
