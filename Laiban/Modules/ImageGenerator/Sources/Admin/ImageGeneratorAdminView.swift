//
//  ImageGeneratorAdminView.swift
//
//
//  Created by Kenth Ljung on 2023-10-20.
//

import Foundation
import SwiftUI

@available(iOS 17, *)
struct ImageGeneratorAdminView: View {
    @ObservedObject var service: ImageGeneratorService
    @State var savedImageCount: Int = 0
    
    var group: some View {
        let serviceNotEnabled = [.Initializing, .Generating].contains(service.manager.status)
        return Group {
            NavigationLink(destination: InstructionsAdminView()) {
                Text("Lärarhandledning")
            }.id("ImageGeneratornInstructions")

            NavigationLink(destination: SettingsAdminView(service: service)) {
                Text("Bildgenerering")
            }.id("ImageGeneratorSettings")
            
            Button("Rensa sparade bilder (\(savedImageCount) st)") {
                ImageGeneratorUtils.clearSavedImages()
                savedImageCount = ImageGeneratorUtils.getSavedImageFilenames().count
            }.disabled(savedImageCount == 0)
        }
        .onAppear {
            savedImageCount = ImageGeneratorUtils.getSavedImageFilenames().count
        }
    }

    var body: some View {
        group.onChange(of: service.data) { newValue in
            service.save()
        }
    }
}


@available(iOS 17, *)
struct ImageGeneratorAdminView_Previews: PreviewProvider {
    static var service = ImageGeneratorService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    service.adminView()
                }
            }
        }.navigationViewStyle(.stack)
    }
}
