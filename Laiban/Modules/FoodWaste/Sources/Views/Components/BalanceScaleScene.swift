//
//  BalanceScaleScene.swift
//
//  Created by Tomas Green on 2021-03-15.
//

import SwiftUI
import SpriteKit
import Combine

class BalanceScaleScene: SKScene {
    class ScaleObject : SKSpriteNode { }
    weak var model: BalanceScaleView.ViewModel?
    let sprite = SKSpriteNode(texture: .init(image: UIImage(named: "BalanceScalePhysicsBody", in: .module, with: nil)!))
    var prevSize:CGSize = .zero
    var physicsBodies = [String:SKPhysicsBody]()
    
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
        addChild(sprite)
    }
    func addObject(object:BalanceScaleView.ViewModel.Item) {
        if self.childNode(withName: object.id) != nil {
            return
        }
        let w = frame.size.width / 5
        let obj = ScaleObject(texture: .init(image: UIImage(named: object.image, in: .module, with: nil)!))
        let act = (frame.size.width / 5.5)
        let ratio = act / obj.size.width
        
        let newHeight = obj.size.height * ratio
        let newWidth = obj.size.width * ratio

        obj.size = CGSize(
            width: newWidth * object.scaleFactor,
            height: newHeight * object.scaleFactor)
        let radius = obj.size.width / 2
        obj.position = CGPoint(x: frame.midX - CGFloat.random(in: (w * -1)...w), y: frame.height - radius)
        obj.name = object.id
        if let p = physicsBodies[object.image] {
            obj.physicsBody = p.copy() as? SKPhysicsBody
        } else {
            let t = SKTexture(image: UIImage(named: object.image + "Physics", in: .module, with: nil)!)
            let s = t.size()
            let r = act / s.width
            let p = SKPhysicsBody(
                texture: t,
                size: CGSize(width: s.width * r * object.scaleFactor * 0.9, height: s.height * r * object.scaleFactor * 0.9))
                //size: CGSize(width: obj.size.width * 0.9, height: obj.size.height * 0.9))
            p.restitution = 0
            p.mass = CGFloat(object.weight)
            physicsBodies[object.image] = p
            obj.physicsBody = p
        }
        addChild(obj)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard self.model?.inBalance == false else {
            return
        }
        guard let position = touches.first?.location(in: self) else {
            return
        }
        guard let tappedObjects = nodes(at: position).first(where: { $0 is ScaleObject}) as? ScaleObject else {
            return
        }
        tappedObjects.removeFromParent()
        self.model?.objects.removeAll { i in tappedObjects.name == i.id }
    }
    override func update(_ currentTime: TimeInterval) {

    }
}


struct SpriteKitContainer: UIViewRepresentable {
    typealias UIViewType = SKView
    var scene = BalanceScaleScene()
    var model: BalanceScaleView.ViewModel
    init(model: BalanceScaleView.ViewModel) {
        self.model = model
        self.scene.model = model
    }
    class Coordinator: NSObject {
        var scene: BalanceScaleScene?
        var listener:AnyCancellable?
    }
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        self.scene.scaleMode = .resizeFill
        self.scene.anchorPoint = CGPoint(x: 0, y: 0)
        self.scene.backgroundColor = .clear
        coordinator.scene = self.scene
        coordinator.listener = self.model.$objects.sink { value in
            guard let last = value.last else {
                return
            }
            coordinator.scene?.addObject(object: last)
        }
        return coordinator
    }
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.preferredFramesPerSecond = 60
        view.showsPhysics = false
        view.ignoresSiblingOrder = true
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ view: SKView, context: Context) {
        view.presentScene(context.coordinator.scene)
    }
}
