//
//  HouseholdScaleScene.swift
//
//  Created by Tomas Green on 2021-03-17.
//

import SwiftUI
import SpriteKit
import Combine

//https://www.hackingwithswift.com/articles/184/tips-to-optimize-your-spritekit-game
//https://www.hackingwithswift.com/read/11/5/collision-detection-skphysicscontactdelegate
class HouseholdScaleGameScene: SKScene {
    class ScaleObject : SKSpriteNode { }
    weak var model: HouseholdScaleView.ViewModel?
    let sprite = SKSpriteNode(texture: .init(image: UIImage(named: "HouseholdScaleContainerPhysics", in: .module, with: nil)!))
    var prevSize:CGSize = .zero
    static var physicsBodies = [String:SKPhysicsBody]()
    override func didMove(to view: SKView) {
        addContainer()
    }
    func addContainer() {
        guard prevSize != frame.size else {
            return
        }
        prevSize = frame.size
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, alphaThreshold: 0, size: frame.size)
        sprite.physicsBody?.pinned = true
        sprite.physicsBody?.allowsRotation = false
        sprite.physicsBody?.restitution = 0
        sprite.physicsBody?.isDynamic = false
        sprite.alpha = 0
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        sprite.removeFromParent()
        sprite.blendMode = .replace
        sprite.physicsBody?.usesPreciseCollisionDetection = false
        addChild(sprite)
    }
    func addObject(object:HouseholdScaleView.ViewModel.Item) {
        if self.childNode(withName: object.id) != nil {
            return
        }
        addContainer()
        let w = frame.size.width / 3
        let obj = ScaleObject(texture: SKTexture(image: UIImage(named: object.image, in: .module, with: nil)!))
        let act = (frame.size.width / 3)
        let ratio = act / obj.size.width
        let newHeight = obj.size.height * ratio
        let newWidth = obj.size.width * ratio
        obj.size = CGSize(
            width: newWidth * object.scaleFactor,
            height: newHeight * object.scaleFactor)
        obj.position = CGPoint(x: frame.midX - CGFloat.random(in: (w * -1)...w), y: frame.height)
        obj.name = object.id
        if let p = Self.physicsBodies[object.image] {
            obj.physicsBody = p.copy() as? SKPhysicsBody
        } else {
            let t = SKTexture(image: UIImage(named: object.image + "Physics", in: .module, with: nil)!)
            let s = t.size()
            let r = act / s.width
            let p = SKPhysicsBody(
                texture: t,
                size: CGSize(width: s.width * r * object.scaleFactor * 0.9, height: s.height * r * object.scaleFactor * 0.9))
            p.restitution = 0
            p.mass = CGFloat(object.weight)
            p.usesPreciseCollisionDetection = false
            Self.physicsBodies[object.image] = p
            obj.physicsBody = p
        }
        addChild(obj)
    }
}
struct HouseholdScaleGameContainer: UIViewRepresentable {
    typealias UIViewType = SKView
    var scene = HouseholdScaleGameScene()
    var model: HouseholdScaleView.ViewModel
    init(model: HouseholdScaleView.ViewModel) {
        self.model = model
        self.scene.model = model
    }
    class Coordinator: NSObject {
        var scene: HouseholdScaleGameScene?
        var listeners:[AnyCancellable] = []
    }
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        self.scene.scaleMode = .resizeFill
        self.scene.anchorPoint = CGPoint(x: 0, y: 0)
        self.scene.backgroundColor = .clear
        coordinator.scene = self.scene
        let l1 = self.model.$objects.sink { value in
            guard let last = value.last else {
                return
            }
            coordinator.scene?.addObject(object: last)
        }
        coordinator.listeners.removeAll()
        coordinator.listeners.append(l1)
        return coordinator
    }
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.preferredFramesPerSecond = 60
        view.showsPhysics = false
        //view.showsDrawCount = true
        view.ignoresSiblingOrder = true
        view.backgroundColor = .clear
        view.isOpaque = true
        //view.allowsTransparency = false
        return view
    }
    
    func updateUIView(_ view: SKView, context: Context) {
        view.presentScene(context.coordinator.scene)
    }
}
