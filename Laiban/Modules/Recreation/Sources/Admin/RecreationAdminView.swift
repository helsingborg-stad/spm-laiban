//
//  SwiftUIView.swift
//  
//
//  Created by jonatan lidholm jansson on 2022-10-12.
//

import SwiftUI

struct RecreationAdminView: View {
    @ObservedObject var service:RecreationService
    @State var showAdminView = false
    var body: some View {
        NavigationLink(
            destination:AdminRecreationViews(service: service ,recreation: service.recreation),
            label: {
                Text("Laiban föreslår aktivitet")
            }
        )
    }
}

struct RecreationAdminView_Previews: PreviewProvider {
    static var service = RecreationService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    RecreationAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
