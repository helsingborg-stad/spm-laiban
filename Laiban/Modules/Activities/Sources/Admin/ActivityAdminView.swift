//
//  ActivityAdminView.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-06.
//

import SwiftUI

struct ActivityAdminView: View {
    @ObservedObject var service: ActivityService
    
    var body: some View {
        NavigationLink(destination: ActivityAdminActivitiesView(service: service)) {
            HStack {
                Text("Aktiviteter")
                Spacer()
                Text("\((service.data).count)")
            }
        }
    }
}

struct ActivityAdminView_Previews: PreviewProvider {
    static var service = ActivityService()
    
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    ActivityAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
