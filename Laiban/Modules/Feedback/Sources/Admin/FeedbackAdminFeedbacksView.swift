//
//  FeedbackAdminFeedbacksView.swift
//  
//
//  Created by Ehsan Zilaei on 2022-07-06.
//

import SwiftUI

struct FeedbackAdminFeedbacksView: View {
    @ObservedObject var service: FeedbackService
    var category: FeedbackCategory
    
    var body: some View {
        List() {
            ForEach(service.values(in: category)) { value in
                Section(header: Text(FeedbackValue.string(for: value.date).capitalizingFirstLetter())) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(value.value.capitalizingFirstLetter())
                        LBBarGraphView(data: FeedbackValue.graphData(from: value))
                    }
                    .multilineTextAlignment(.leading)
                    .padding(.top, 5)
                }
            }
        }
    }
}
