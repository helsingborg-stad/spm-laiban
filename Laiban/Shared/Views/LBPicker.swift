//
//  CustomPicker.swift
//  speechtranslator
//
//  Created by Tomas Green on 2021-03-26.
//

import SwiftUI

public struct LBNonOptionalPicker<Content: View, Item>: View where Item: Hashable {
    var content: (Item) -> Content
    var title: String
    var items: [Item]
    @Binding var selection: Item
    public init(title: String, items: [Item], selection: Binding<Item>, @ViewBuilder content: @escaping (Item) -> Content) {
        self.content = content
        self.title = title
        self.items = items
        self._selection = selection
    }
    var list: some View {
        LBNonOptionalPickerList(title: title, items: items, selection: $selection, content: content)
    }
    public var body: some View {
        NavigationLink(destination: list) {
            HStack {
                Text(title)
                Spacer()
                content(selection).fixedSize(horizontal: true, vertical: false)
            }
        }
    }
}

struct LBNonOptionalPickerList<Content: View, Item>: View where Item: Hashable {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var content: (Item) -> Content
    var title: String
    var items: [Item]
    @Binding var selection: Item
    public init(title: String, items: [Item], selection: Binding<Item>, @ViewBuilder content: @escaping (Item) -> Content) {
        self.content = content
        self.title = title
        self.items = items
        self._selection = selection
    }
    @State var searchBarActive: Bool = false
    @State var searchString: String = ""
    var filtered: [Item] {
        //if searchString.isEmpty {
        return items
        //}
    }
    public var body: some View {
        Form {
            
            ForEach(filtered, id: \.self) { item in
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                    self.selection = item
                } label: {
                    HStack {
                        content(item)
                        if item == selection {
                            Spacer()
                            Image(systemName: "checkmark").foregroundColor(Color.accentColor)
                        }
                    }
                }.foregroundColor(Color(.label))
            }
        }
        .navigationBarTitle(title)
    }
}

public struct OptionalPicker<Content: View, Item>: View where Item: Hashable {
    var content: (Item) -> Content
    var title: String
    var items: [Item]
    @Binding var selection: Item?
    public init(title: String, items: [Item], selection: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content) {
        self.content = content
        self.title = title
        self.items = items
        self._selection = selection
    }
    var list: some View {
        OptionalPickerList(title: title, items: items, selection: $selection, content: content)
    }
    public var body: some View {
        NavigationLink(destination: list) {
            HStack {
                Text(title)
                Spacer()
                if selection != nil {
                    content(selection!).fixedSize(horizontal: true, vertical: false)
                }
            }
        }
    }
}

struct OptionalPickerList<Content: View, Item>: View where Item: Hashable {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var content: (Item) -> Content
    var title: String
    var items: [Item]
    @Binding var selection: Item?
    public init(title: String, items: [Item], selection: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content) {
        self.content = content
        self.title = title
        self.items = items
        self._selection = selection
    }
    public var body: some View {
        Form {
            ForEach(items, id: \.self) { item in
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                    self.selection = item
                } label: {
                    HStack {
                        content(item)
                        if item == selection {
                            Spacer()
                            Image(systemName: "checkmark").foregroundColor(Color.accentColor)
                        }
                    }
                }.foregroundColor(Color(.label))
            }
        }.navigationBarTitle(title)
    }
}
