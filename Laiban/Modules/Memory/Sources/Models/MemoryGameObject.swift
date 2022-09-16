//
//  MemoryGameBrickViews.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-29.
//

import SwiftUI

struct MemoryUNDPGoal : ImageMemoryObject {
    var id:MemoryObject.ID {
        return "\(goal)"
    }
    let goal:UNDPGoal
    let color:Color
    let image:Image
    let title:String
    let decription:String
    init (_ goal:UNDPGoal) {
        self.goal = goal
        self.color = goal.backgroundColor
        self.image = goal.icon
        self.title = goal.titleKey
        self.decription = goal.descriptionKey
    }
    static func randomize(_ num: Int) -> [MemoryObject] {
        var arr = [Int]()
        func randomGoal() -> Int {
            let g = Int.random(in: 1...17)
            if arr.contains(g) {
                return randomGoal()
            }
            return g
        }
        for _ in 1...num {
            let g = randomGoal()
            arr.append(g)
            arr.append(g)
        }
        arr.shuffle()
        return arr.map { i  in MemoryUNDPGoal(UNDPGoal(rawValue: i)!) }
    }
}
struct MonsterMemory : ImageMemoryObject {
    var id:MemoryObject.ID {
        return monster.name
    }
    let monster:Monster
    let color:Color = .white
    let image:Image
    let title:String
    let decription:String
    init (_ monster:Monster) {
        self.monster = monster
        self.image = monster.memoryImage
        self.title = monster.name
        self.decription = monster.descriptionKey
    }
    static func randomize(_ num: Int) -> [MemoryObject] {
        var arr = [Monster]()
        let selection = Monster.loadSync()
        if selection.isEmpty {
            return []
        }
        func randomMonster() -> Monster {
            guard let e = selection.randomElement() else {
                fatalError("No monsters?")
            }
            if arr.contains(e) {
                return randomMonster()
            }
            return e
        }
        for _ in 1...num {
            let e = randomMonster()
            arr.append(e)
            arr.append(e)
        }
        return arr.map { i  in MonsterMemory(i) }.shuffled()
    }
}
