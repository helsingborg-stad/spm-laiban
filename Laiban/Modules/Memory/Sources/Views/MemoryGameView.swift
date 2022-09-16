import SwiftUI
import Combine

struct GridStack<Content: View>: View {
    let grid: [ClosedRange<Int>]
    let content: (Int) -> Content
    let verticalSpacing:CGFloat
    let horizontalSpacing:CGFloat
    let horizontalAlignment :HorizontalAlignment
    let verticalAlignment :VerticalAlignment
    
    var body: some View {
        VStack(alignment: horizontalAlignment, spacing: verticalSpacing) {
            ForEach(grid, id: \.self) { range in
                HStack(alignment: self.verticalAlignment, spacing: self.horizontalSpacing) {
                    ForEach(range, id: \.self) { index in
                        self.content(index)
                    }
                }
            }
        }
    }
    
    init(items: Int, columns: Int, verticalSpacing:CGFloat = 0, horizontalSpacing:CGFloat = 0, verticalAlignment:VerticalAlignment = .center, horizontalAlignment:HorizontalAlignment = .center, @ViewBuilder content: @escaping (Int) -> Content) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.grid = items.ranges(seperatedInto: columns)
        self.content = content
    }
}


private struct PlayButtonView: View {
    struct ButtonIconCircle: View {
        var color: Color
        var body: some View {
            Circle().foregroundColor(color).overlay(
                Circle()
                    .stroke(Color.clear, lineWidth: 5)
                    .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 0)
                    .clipShape(
                        Circle()
                )
            )
        }
    }
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var size: CGFloat
    var color: Color
    var body: some View {
        ZStack() {
            ButtonIconCircle(color: color).shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 0)
            Image(systemName: "play.fill")
                .resizable()
                .foregroundColor(.white)
                .aspectRatio(contentMode: .fit)
                .frame(width:size * 0.4,height:size * 0.4).offset(x: 3, y: 0)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 2)
        }.frame(width:size,height:size)
    }
}
struct EmmojiBrick : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isEnabled) var isEnabled: Bool
    var value:EmojiMemoryObject
    var selected:Bool
    var finished:Bool
    var angle:Angle {
        return selected ? Angle(degrees: 0) : Angle(degrees: 180)
    }
    var lineWidth:CGFloat {
        horizontalSizeClass == .regular ? 10 : 5
    }
    var overlay: some View {
        Image("MemoryBrick", bundle: .module).resizable().aspectRatio(1,contentMode: .fill).background(Color("MemoryGameColor2", bundle: .module)).opacity(selected ? 0 : 1)
    }
    var border: some View {
        Image("MemoryBorderOverlay", bundle: .module)
            .resizable()
            .aspectRatio(1,contentMode: .fill)
            .opacity(isEnabled || finished ? 1 : 0.5)
    }
   var body: some View {
        GeometryReader { proxy in
            Text(value.emoji)
                .font(.system(size: proxy.size.width * 0.5))
                .frame(maxWidth:.infinity,maxHeight: .infinity)
                .padding(lineWidth)
                .background(value.color)
                .disabled(selected)
                .overlay(overlay)
                .overlay(border)
                .rotation3DEffect(angle, axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                .animation(.default)
                .scaleEffect(finished ? 0.9 : 1)
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
    }
}
struct ImageBrick : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isEnabled) var isEnabled: Bool
    
    var value:ImageMemoryObject
    var selected:Bool
    var finished:Bool
    var angle:Angle {
        return selected ? Angle(degrees: 0) : Angle(degrees: 180)
    }
    var lineWidth:CGFloat {
        horizontalSizeClass == .regular ? 10 : 5
    }
    var overlayImage: some View {
        Image(systemName: "photo.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
            .foregroundColor(.black)
            .opacity(0.1)
    }
    var image: some View {
        value.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .overlay(border.rotation3DEffect(Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0))))
    }
    var overlay: some View {
        Image("MemoryBrick", bundle: .module)
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .background(Color("MemoryGameColor2", bundle: .module))
            .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
            .overlay(border.rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0))))
            .opacity(selected ? 0 : 1)
    }
    var border: some View {
        Image("MemoryBorderOverlay", bundle: .module)
            .resizable()
            .aspectRatio(1,contentMode: .fill)
            .opacity(isEnabled || finished ? 1 : 0.5)
    }
    var body: some View {
        Rectangle().fill(Color.clear)
            .padding(lineWidth)
            .background(value.color)
            .overlay(image)
            .disabled(selected)
            .overlay(overlay)
            .rotation3DEffect(angle, axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
            .animation(.default)
            .scaleEffect(finished ? 0.9 : 1)
            .aspectRatio(1, contentMode: .fill)
            .clipped()
    }
}
struct PhotoBrick : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.isEnabled) var isEnabled: Bool
    var value:PhotoMemoryObject
    var selected:Bool
    var finished:Bool
    var angle:Angle {
        return selected ? Angle(degrees: 0) : Angle(degrees: 180)
    }
    var lineWidth:CGFloat {
        horizontalSizeClass == .regular ? 10 : 5
    }
    var image: some View {
        value.image.centerCropped()
            .overlay(border.rotation3DEffect(Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0))))
    }
    var overlay: some View {
        Image("MemoryBrick", bundle: .module)
            .resizable()
            .aspectRatio(1,contentMode: .fill)
            .background(Color("MemoryGameColor2", bundle: .module))
            .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
            .overlay(border.rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0))))
            .opacity(selected ? 0 : 1)
    }
    var border: some View {
        Image("MemoryBorderOverlay", bundle: .module).resizable().aspectRatio(1,contentMode: .fill).opacity(isEnabled || finished ? 1 : 0.5)
    }
    var body: some View {
        Rectangle()
            .padding(lineWidth)
            .overlay(image)
            .background(value.color)
            .disabled(selected)
            .overlay(overlay)
            .rotation3DEffect(angle, axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
            .animation(.default)
            .scaleEffect(finished ? 0.9 : 1)
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            
    }
}
public struct MemoryGameView<BrickType: MemoryObject>: View {
    //public typealias Reset = (MemoryGameViewModel) -> [MemoryObject]
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    
    @ObservedObject var model:MemoryGameViewModel
    var verticalAlignment:VerticalAlignment
    public init(model:MemoryGameViewModel = MemoryGameViewModel(),verticalAlignment: VerticalAlignment = .bottom) {
        self.model = model
        self.verticalAlignment = verticalAlignment
    }
    func reset () {
        self.model.reset(with: BrickType.randomize(model.cardLayout.numValues))
        //self.model.found = self.model.values.map({ m in m.id})
    }
    var overlay: some View {
        Button(action: {
            reset()
        }) {
            PlayButtonView(size: horizontalSizeClass == .regular ? 120 : 80, color: Color("MemoryGameColor1", bundle: .module))
        }
        .padding(20)
        .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.center)
        .background(colorScheme == .light ? Color.white.opacity(0.5): Color.black.opacity(0.5))
        .disabled(model.status != .done)
        .opacity(model.status == .done ? 1 : 0)
    }
    var alignment:Alignment {
        if verticalAlignment == .bottom {
            return .bottom
        }
        if verticalAlignment == .top {
            return .top
        }
        return .center
    }
    func getsize(using proxy:GeometryProxy) -> CGFloat {
        return (proxy.size.width - CGFloat((model.cardLayout.columns - 1) * 6) ) / CGFloat(model.cardLayout.columns)
    }
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: alignment) {
                let size = getsize(using: proxy)
                GridStack(items: self.model.values.count, columns: model.cardLayout.columns, verticalSpacing: 6, horizontalSpacing: 6,horizontalAlignment:.center) { index in
                    let value = self.model.values[index]
                    let o = (self.model.isSelected(index) || self.model.isFinished(value))
                    if let v = value as? ImageMemoryObject {
                        ImageBrick(value: v, selected: o, finished: self.model.isFinished(value))
                            .frame(width: size, height: size)
                            .clipped()
                            .onTapGesture {
                                self.model.select(index)
                            }
                    } else if let v = value as? EmojiMemoryObject {
                        EmmojiBrick(value: v, selected: o, finished: self.model.isFinished(value))
                            .frame(width: size, height: size)
                            .clipped()
                            .onTapGesture {
                                self.model.select(index)
                            }
                    } else if let v = value as? PhotoMemoryObject {
                        PhotoBrick(value: v, selected: o, finished: self.model.isFinished(value))
                            .frame(width: size, height: size)
                            .clipped()
                            .onTapGesture {
                                self.model.select(index)
                            }
                    }
                }.overlay(overlay)
            }
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment: alignment)
            
            .onAppear {
                reset()
            }
        }
    }
}

@available(iOS 15.0, *)
struct MemoryGameView_Previews: PreviewProvider {
    @ObservedObject static var model = MemoryGameViewModel(layout: .mediumWide)
    static var previews: some View {
        Group {
            VStack {
                Text(model.status == .done ? "done" : "not done")
                Spacer()
                MemoryGameView<EmojiMemory>(model:model).padding()
            }
            .onReceive(model.$lastFound) { object in
                
            }
            .onReceive(model.$status) { object in
                
            }
            .preferredColorScheme(.light)
        }
    }
}
struct EmojiMemory : EmojiMemoryObject {
    static let emojis = ["🌾","🍏","🍣","🎂","🍩","🥧","🥕","🌶","🍓","🥑","🍋","🥐","🦐","🍅"]
    var id:String {
        return emoji
    }
    let color:Color
    let emoji:String
    init (_ emoji:String, color:Color = .white) {
        self.color = color
        self.emoji = emoji
    }
    static func randomize(_ num: Int) -> [MemoryObject] {
        var arr = [String]()
        func randomEmoji() -> String {
            let g = emojis.randomElement()!
            if arr.contains(g) {
                return randomEmoji()
            }
            return g
        }
        for _ in 1...num {
            let g = randomEmoji()
            arr.append(g)
            arr.append(g)
        }
        arr.shuffle()
        return arr.map { i  in EmojiMemory(i) }
    }
}
