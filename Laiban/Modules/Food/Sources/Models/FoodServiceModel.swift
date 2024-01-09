//
//  FoodServiceModel.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-06.
//

import Foundation
import Meals

public struct FoodServiceModel: LBServiceModel, Equatable, Decodable, Encodable {
//    var unitCode: String = ""
    public var foodProcessingMethod = FoodProcessingMethod.wordFilter
    public var foodLink: Skolmaten.School? = nil
//    var maxFoodWastePerPerson: Int = 300
//    var maxNumberOfPeoapleEating: Int = 50
    public var showOnDashboard: Bool = false
}
