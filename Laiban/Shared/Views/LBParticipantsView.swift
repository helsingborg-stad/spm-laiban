//
//  SwiftUIView.swift
//
//
//  Created by Ehsan Zilaei on 2022-09-22.
//

import SwiftUI
import Combine

struct LBParticipantsView: View {
    @Binding var allParticipants: [String]
    var selectedParticipants: [String]? = nil
    var updateParticipant: ((String, UpdateParticipantAction) -> Void)
    
    @State private var newParticipantName: String = ""
    @State private var showAlertParticipantExist = false
    
    var body: some View {
        Form {
            Section() {
                createNewParticipant
            }
            
            Section(footer: Text("Observera att raderad deltagare även tas bort från alla aktiviteter.")
                .padding(.top, 7)
                .foregroundColor(.red)
                .font(.system(size: 16))) {
                    listParticipants
                }
        }
        .navigationBarTitle(Text("Deltagare"))
    }
}

struct LBParticipantsView_Previews: PreviewProvider {
    @State static var allParticipants = ["TSimon", "TLisa"]
    static var selectedParticipants = ["TLisa"]
    
    static var previews: some View {
        Group {
            LBParticipantsView(allParticipants: $allParticipants) { a, b  in }
                .previewDisplayName("Select participants disabled")
            
            LBParticipantsView(allParticipants: $allParticipants, selectedParticipants: []) { a, b  in }
                .previewDisplayName("Select participants enabled")
            
            LBParticipantsView(allParticipants: $allParticipants, selectedParticipants: selectedParticipants) { a, b  in }
                .previewDisplayName("Select participants enabled and selected")
        }
    }
}

extension LBParticipantsView {
    private var createNewParticipant: some View {
        HStack {
            TextField("Skapa ny deltagare", text: $newParticipantName)
                .disableAutocorrection(true)
            Button(action: {
                if allParticipants.contains(newParticipantName) {
                    showAlertParticipantExist = true
                    
                    return
                }
                
                withAnimation {
                    updateParticipant(newParticipantName, .add)
                    newParticipantName = ""
                }                
            }) {
                Image(systemName: "plus.circle.fill")
            }
            .disabled(newParticipantName.isEmpty)
            .alert(isPresented: $showAlertParticipantExist) {
                Alert(title: Text("Deltagare finns redan"))
            }
        }
    }
    
    private var listParticipants: some View {
        ForEach($allParticipants, id:\.self) { $participant in
            HStack {
                if (selectedParticipants != nil) {
                    Image(systemName: (selectedParticipants?.contains(participant))! ? "checkmark.circle.fill" : "circle")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                }
                
                Text(participant)
            }
        }
        .onDelete { indices in
            for i in indices {
                withAnimation {
                    updateParticipant(allParticipants[i], .remove)
                }
            }
        }
    }
}
