//
//  SchoolsLinksView.swift
//
//  Created by Tomas Green on 2020-04-01.
//

import Combine
import Meals
import SwiftUI
import Analytics

private struct AdminSkolmatenSelectionView: View {
    @State var rootVisible: Bool = false
    var body: some View {
        NavigationView {
            NavigationLink(
                destination: AdminSkolmatenCountyListView(rootVisible: $rootVisible) { _ in
                    rootVisible = false
                },
                isActive: $rootVisible,
                label: {
                    Text("Navigate")
                })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AdminSkolmatenSchoolListView: View {
    @Binding var rootVisible: Bool
    @State var items = [Skolmaten.School]()
    var municipality: Skolmaten.Municipality
    var schoolSelected: (Skolmaten.School) -> Void
    @State var cancellable: AnyCancellable? = nil
    @State var errorMessage: String? = nil
    @State var isLoading: Bool = false
    var errorOverlay: some View {
        Group {
            if errorMessage != nil {
                Text(errorMessage!)
            }
        }
    }

    var isLoadingOveray: some View {
        LBActivityIndicator(isAnimating: $isLoading, style: .medium).opacity(isLoading ? 1 : 0).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var body: some View {
        List(items) { i in
            Button(i.title) {
                schoolSelected(i)
            }
        }
        .id(UUID())
        .listStyle(GroupedListStyle())
        .overlay(errorOverlay)
        .overlay(isLoadingOveray)
        .onAppear {
            isLoading = true
            cancellable = municipality.fetchSchoolsPublisher.sink(receiveCompletion: { compl in
                if case let .failure(error) = compl {
                    self.errorMessage = error.localizedDescription
                }
                isLoading = false
            }, receiveValue: { items in
                self.errorMessage = nil
                self.items = items
                isLoading = false
            })
            AnalyticsService.shared.logPageView(self)
        }
        .navigationBarTitle("Välj skola")
    }
}

struct AdminSkolmatenMunicipalityListView: View {
    @Binding var rootVisible: Bool
    @State var items = [Skolmaten.Municipality]()
    var county: Skolmaten.County
    var schoolSelected: (Skolmaten.School) -> Void
    @State var cancellable: AnyCancellable? = nil
    @State var errorMessage: String? = nil
    @State var isLoading: Bool = false
    var errorOverlay: some View {
        Group {
            if errorMessage != nil {
                Text(errorMessage!)
            }
        }
    }

    var isLoadingOveray: some View {
        LBActivityIndicator(isAnimating: $isLoading, style: .medium).opacity(isLoading ? 1 : 0).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var body: some View {
        List(items) { i in
            NavigationLink(i.title, destination: AdminSkolmatenSchoolListView(rootVisible: $rootVisible, municipality: i, schoolSelected: schoolSelected))
        }
        .id(UUID())
        .listStyle(GroupedListStyle())
        .onAppear {
            isLoading = true
            cancellable = county.fetchMunicipalitiesPublisher.sink(receiveCompletion: { compl in
                if case let .failure(error) = compl {
                    self.errorMessage = error.localizedDescription
                }
                isLoading = false
            }, receiveValue: { items in
                self.errorMessage = nil
                self.items = items
                isLoading = false
            })
            AnalyticsService.shared.logPageView(self)
        }.navigationBarTitle("Välj kommun")
    }
}

struct AdminSkolmatenCountyListView: View {
    @Binding var rootVisible: Bool
    @State var items = [Skolmaten.County]()
    var schoolSelected: (Skolmaten.School) -> Void
    @State var cancellable: AnyCancellable? = nil
    @State var errorMessage: String? = nil
    @State var isLoading: Bool = false
    var errorOverlay: some View {
        Group {
            if errorMessage != nil {
                Text(errorMessage!)
            }
        }
    }

    var isLoadingOveray: some View {
        LBActivityIndicator(isAnimating: $isLoading, style: .medium).opacity(isLoading ? 1 : 0).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var body: some View {
        List(items) { i in
            NavigationLink(i.title, destination: AdminSkolmatenMunicipalityListView(rootVisible: $rootVisible, county: i, schoolSelected: schoolSelected))
        }
        .id(UUID())
        .listStyle(GroupedListStyle())
        .overlay(errorOverlay)
        .overlay(isLoadingOveray)
        .onAppear {
            isLoading = true
            cancellable = Skolmaten.County.fetchCountiesPublisher.sink(receiveCompletion: { compl in
                if case let .failure(error) = compl {
                    self.errorMessage = error.localizedDescription
                }
                isLoading = false
            }, receiveValue: { items in
                self.errorMessage = nil
                self.items = items
                isLoading = false
            })
            AnalyticsService.shared.logPageView(self)
        }.navigationBarTitle("Välj län")
    }
}

struct AdminSkolmaten_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    AdminSkolmatenSelectionView()
                }
            }
        }.navigationViewStyle(.stack)
    }
}
