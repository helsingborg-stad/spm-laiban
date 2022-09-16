//
//  AdminFoodProcessingMethod.swift
//
//  Created by Tomas Green on 2020-11-02.
//

import Combine
import Meals
import SwiftUI


struct AdminFoodProcessingMethodView: View {
    @ObservedObject var service: FoodService
    @State var strings: [String] = []
    @State var showAcknowledgments = false
    @State var cancellables = Set<AnyCancellable>()
    var meal = Meal(description: "Italiensk korvgryta på svensk köttråvara, serveras med pasta och grönsaksbuffé", date: Date())
    func updateStrings(using type: FoodProcessingMethod) {
        process(food: [meal], with: type)
    }

    func process(food: [Meal], with type: FoodProcessingMethod) {
        type.process(food.compactMap { $0.description }).sink(receiveValue: { strings in
            self.strings = strings.compactMap { $0.processed }
        }).store(in: &cancellables)
    }

    var footer: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Matsedelns utformning kan variera en hel del och vi vill såklart att den ska vara så anpassad till barnens förutsättningar som möjligt.")
            if service.data.foodProcessingMethod == FoodProcessingMethod.none {
                Text("Du har valt att inte visa en oförändrad version av texten. Ett expemle på hur det ser ut i appen hittar du nedan")
            } else if service.data.foodProcessingMethod == FoodProcessingMethod.wordFilter {
                Text("Du har valt ordfilrering. Med denna metod tar laiban bort vissa ord och gör texten så kort som möjligt. Denna metod kan ibland visa en hel del felaktigheter.")
            } else if service.data.foodProcessingMethod == FoodProcessingMethod.grammaticalAnalysis {
                Text("Du har valt grammatisk filtrerning/analys. Denna metod försöker med så stor träffsäkerhet som möjligt att ta bort ord som inte behövs, tex alla adjektiv.")
                Button {
                    self.showAcknowledgments = true
                } label: {
                    Text("Tillkännagivanden UDPIPE2").foregroundColor(Color.blue)
                }.sheet(isPresented: self.$showAcknowledgments) {
                    SafariView(url: URL(string: "http://ufal.mff.cuni.cz/udpipe/2#udpipe2_acknowledgements")!)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                ForEach(self.strings, id: \.self) { string in
                    Text(string).frame(maxWidth: .infinity, alignment: .leading)
                }
            }.frame(maxWidth: .infinity).padding().background(Color.gray.opacity(0.2)).cornerRadius(15)
        }.frame(maxWidth: .infinity)
    }

    var body: some View {
        Form {
            Section(footer: self.footer) {
                ForEach(FoodProcessingMethod.allCases, id: \.rawValue) { method in
                    Button(action: {
                        service.data.foodProcessingMethod = method
                    }, label: {
                        HStack {
                            Text(method.title)
                            Spacer()
                            if service.data.foodProcessingMethod == method {
                                Image(systemName: "checkmark")
                            }
                        }.foregroundColor(.black)
                    })
                }
            }
        }
        .onReceive(service.$data) { v in
            self.updateStrings(using: v.foodProcessingMethod)
        }
        .onAppear {
            self.updateStrings(using: service.data.foodProcessingMethod)
        }.navigationBarTitle("Förenkling av matsedel")
    }
}

struct AdminFoodProcessingMethod_Previews: PreviewProvider {
    static var service = FoodService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    AdminFoodProcessingMethodView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
