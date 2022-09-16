//
//  InstagramSection.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-04.
//

import Foundation
import Instagram
import SwiftUI

struct InstagramSection: Identifiable {
    let id: String = UUID().uuidString
    var items: [Instagram.Media]
    var title: String
}
