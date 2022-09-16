//
//  FeedbackAdminView.swift
//  
//
//  Created by Ehsan Zilaei on 2022-06-30.
//

import SwiftUI

struct FeedbackAdminView: View {
    @ObservedObject var service: FeedbackService
    
    var body: some View {
        NavigationLink(destination: FeedbackAdminFeedbacksView(service: service, category: .activity)) {
            HStack {
                Text("Aktiviteter")
            }
        }
    }
}

struct FeedbackAdminView_Previews: PreviewProvider {
    static var service = FeedbackService()
    
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    FeedbackAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}


