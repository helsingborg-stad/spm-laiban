//
//  SwiftUIView.swift
//  
//
//  Created by jonatan lidholm jansson on 2022-10-13.
//

import SwiftUI

struct AdminRecreationAddActivityView: View {
    @State var test:String = ""
    var body: some View {
        Form{
            AddActivitySentence()
        }
    }
}

struct AddActivitySentence: View{
    @State var test:String = ""
    var body: some View {
        Section{
            TextField("test", text:$test)
        }header: {
            Text("Titel")
        }footer: {
            Text("Lorem ipsum bla bla bla")
        }
    }
}


struct AdminRecreationAddActivityView_Previews: PreviewProvider {
    static var previews: some View {
        AdminRecreationAddActivityView()
    }
}
