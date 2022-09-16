//
//  AdminGarmentReportsView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-11-26.
//

import SwiftUI
import Weather

struct AdminGarmentReportsView: View {
    @ObservedObject var garmentStore: GarmentStore
    func string(for condition: WeatherCondition) -> String {
        switch condition {
        case .unknown: return "Okänt"
        case .rainy: return "Regnigt"
        case .cold: return "Kallt"
        case .coldAndRainy: return "Kallt och regnigt"
        case .cool: return "Svalt"
        case .coolAndRainy: return "Svalt och regningt"
        case .warmish: return "Ganska varmt"
        case .warm: return "Varmt"
        case .hot: return "Riktigt varmt"
        }
    }

    var body: some View {
        let data = garmentStore.data.records.sorted { $0.date > $1.date }
        let df = DateFormatter()
        df.doesRelativeDateFormatting = true
        df.dateStyle = .medium
        df.timeStyle = .short
        return List {
            Section {
                Text("Här kan du se de ändringar i kläder och väder som ni har gjort. Dessa ändringar kommer tillsvidare att lagras lokalt i Laiban men kommer vid ett senare tillfälle skickas upp för analys. Vänligen radera endast felaktiga kläd-justeringar.")
                    .padding([.top, .bottom], 6)
            }
            Section(header: Text("Ändringar av kläder efter väder")) {
                ForEach(data) { record in
                    let feedback = garmentStore.feedback(for: record)
                    let pos = feedback.filter { $0.rating == GarmentStore.Rating.good.rawValue }.count
                    let neg = feedback.filter { $0.rating == GarmentStore.Rating.bad.rawValue }.count
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text(df.string(from: record.date)).fontWeight(.bold)
                            Text("Väder: " + string(for: record.conditions))
                        }
                        Spacer()
                        ForEach(record.garments.sorted { $0.sortPriority < $1.sortPriority }) { g in
                            Image(g.imageName, bundle: .module).resizable().aspectRatio(1, contentMode: .fit).frame(width: 20, height: 20)
                        }
                        VStack {
                            Text("😃")
                            Text("\(pos)").fontWeight(.bold).foregroundColor(.green)
                        }.padding(.leading, 20)
                        VStack {
                            Text("🙁")
                            Text("\(neg)").fontWeight(.bold).foregroundColor(.red)
                        }
                    }.padding([.top, .bottom], 6)
                }.onDelete { indexSet in
                    var records = [GarmentStore.Record]()
                    for i in indexSet {
                        records.append(data[i])
                    }
                    garmentStore.delete(records: records)
                }
            }
        }
        .navigationBarTitle("Justeringar av kläder efter väder")
    }
}

struct AdminGarmentReportsView_Previews: PreviewProvider {
    static var store: GarmentStore {
        GarmentStore.purge()
        let g = GarmentStore()
        let g1 = GarmentStore.Record(garments: [.shoes, .cap], contitions: .hot, date: Date())
        let g2 = GarmentStore.Record(garments: Garment.allCases, contitions: .hot, date: Date())
        g.addRecord(g1)
        g.addRecord(g2)
        g.rate(.good, tag: .system, record: g1)
        g.rate(.good, tag: .child, record: g1)
        g.rate(.bad, tag: .teacher, record: g1)
        return g
    }

    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    AdminGarmentReportsView(garmentStore: store)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
