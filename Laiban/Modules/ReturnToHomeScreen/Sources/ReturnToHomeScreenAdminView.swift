//
//  ReturnToHomeScreenAdminView.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-29.
//

import SwiftUI


struct ReturnToHomeScreenAdminView : View {
    @ObservedObject var service:ReturnToHomeScreenService
    var picker: some View {
        LBNonOptionalPicker(title: "Återgå till hemskärmen efter", items: ReturnToHomeScreen.allCases, selection: $service.data) { time in
            Text(time.title)
        }
    }
    var body: some View {
        if #available(iOS 14.0, *) {
            picker.onChange(of: service.data) { newValue in
                service.save()
            }
        } else {
            picker.onDisappear {
                service.save()
            }
        }
    }
}

struct ReturnToHomeScreenAdminView_Previews: PreviewProvider {
    static var service = ReturnToHomeScreenService()
    static var previews: some View {
        NavigationView {
            Form {
                ReturnToHomeScreenAdminView(service:service)
            }
        }.navigationViewStyle(.stack)
    }
}
