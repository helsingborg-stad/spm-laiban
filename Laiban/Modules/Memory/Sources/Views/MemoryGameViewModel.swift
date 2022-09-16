import SwiftUI
import Combine


public protocol MemoryObject {
    typealias ID = String
    var id:ID { get }
    var color:Color { get }
    static func randomize(_ num:Int) -> [MemoryObject]
}
public protocol ImageMemoryObject : MemoryObject {
    var image:Image { get }
}
public protocol PhotoMemoryObject : MemoryObject {
    var image:Image { get }
}
public protocol EmojiMemoryObject : MemoryObject {
    var emoji:String { get }
}

public class MemoryGameViewModel: ObservableObject {
    public enum GameStatus {
        case new
        case ongoing
        case done
    }
    public enum CardLayout {
        case small
        case medium
        case mediumWide
        case large
        case largeSquare
        public var numValues:Int {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .mediumWide: return 6
            case .large: return 8
            case .largeSquare: return 8
            }
        }
        public var columns:Int {
            switch self {
            case .small: return 3
            case .medium: return 4
            case .mediumWide: return 6
            case .large: return 6
            case .largeSquare: return 4
            }
        }
    }
    @Published public var selectedIndexes = [Int]()
    @Published public var found = [String]() {
        didSet {
            if let f = found.last {
                lastFound = values.first(where: { $0.id == f })
            } else {
                lastFound = nil
            }
            updateStatus()
        }
    }
    @Published public var values:[MemoryObject] = [MemoryObject]()
    @Published public var cardLayout:CardLayout
    @Published public var lastFound:MemoryObject? = nil
    @Published public var status:GameStatus = .new
    public func reset(with values:[MemoryObject]) {
        self.values = values
        self.selectedIndexes = []
        self.found = []
        self.lastFound = nil
        self.status = .new
    }
    public init(layout:CardLayout = .large) {
        self.cardLayout = layout
    }
    func updateStatus() {
        if found.count == cardLayout.numValues {
            status = .done
        } else if lastFound != nil {
            status = .ongoing
        } else {
            status = .new
        }

    }
    func select(_ index:Int) {
        if status == .done {
            return
        }
        if found.contains(value(for: index).id) {
            return
        }
        if selectedIndexes.contains(index) {
            if selectedIndexes.count > 1 {
                selectedIndexes = []
            }
            return
        }
        if selectedIndexes.count == 2 {
            selectedIndexes = []
            return
        }
        selectedIndexes.append(index)
        if selectedIndexes.count != 2 {
            return
        }
        let g1 = value(for:selectedIndexes[0])
        let g2 = value(for:selectedIndexes[1])
        if g1.id == g2.id {
            found.append(g1.id)
            selectedIndexes = []
        }
    }
    func value(for index:Int) -> MemoryObject {
        return values[index]
    }
    func isFinished(_ value:MemoryObject) -> Bool {
        found.contains(value.id)
    }
    func isSelected(_ index:Int) -> Bool {
        selectedIndexes.contains(index)
    }
}
