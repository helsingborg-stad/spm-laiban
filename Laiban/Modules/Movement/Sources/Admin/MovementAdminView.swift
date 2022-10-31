//
//  ActivityAdminView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-25.
//

import SwiftUI

struct MovementAdminView: View {
    @ObservedObject var service: MovementService
    
    var body: some View {
        
        Text("Hello there")
    }
}

struct MovementAdminView_Previews: PreviewProvider {
    static var service = MovementService()
    
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    MovementAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
