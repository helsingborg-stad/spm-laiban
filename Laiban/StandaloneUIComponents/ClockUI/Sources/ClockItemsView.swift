import SwiftUI
public typealias ClockItemsCenterSize = CGFloat
public typealias ClockItemsBorderSize = CGFloat
public typealias ClockItemAction = (ClockItem) -> Void

public struct ClockItemsView<CenterContent: View>: View {
    @ObservedObject var viewModel: ClockViewModel
    let center: (ClockItemsCenterSize,ClockItemsBorderSize) -> CenterContent
    var action:ClockItemAction? = nil
    let size:CGFloat
    init(_ viewModel:ClockViewModel ,size:CGFloat, action:ClockItemAction? = nil, @ViewBuilder center: @escaping (ClockItemsCenterSize,ClockItemsBorderSize) -> CenterContent) {
        self.center = center
        self.action = action
        self.size = size
        self.viewModel = viewModel
    }
    private func scale(for item: ClockItem) -> CGFloat {
        let hours = abs(item.date.timeIntervalSinceNow) / ( 60 * 60)
        return CGFloat(max(1 - hours/6 * 0.5,0.5))
    }
    public var body: some View {
        ZStack(alignment: .center) {
            let fontSize:CGFloat = size * 0.055
            let itemSize:CGFloat = fontSize + fontSize * 0.6
            let itemPadding:CGFloat = itemSize * 0.2
            let borderWidth:CGFloat = itemSize * 0.3
            let offset = ((size)/2 - itemSize/2 ) * -1
            ForEach(self.viewModel.items, id: \.id) { item in
                let color = item.color ?? viewModel.itemBorderColor
                Button(action: {
                    self.action?(item)
                }) {
                    Text(item.emoji)
                        .frame(width: itemSize, height: itemSize)
                        .padding(itemPadding)
                        .background(Circle().strokeBorder(color,lineWidth:itemPadding/2))
                        .background(color.opacity(0.2))
                        .background(Color.white)
                        .clipShape(Circle())
                        .font(Font.system(size: fontSize, weight: .semibold, design: .rounded))
                        .shadow(
                            color: item.date > Date() ? Color.black.opacity(0.5) : Color.clear,
                            radius: item.date > Date() ? 3.5 : 0,x: 0, y:0)
                        .scaleEffect(self.scale(for: item))
                }
                .rotationEffect(Angle(degrees: item.angle.degrees * -1))
                .zIndex(10)
                .offset(y:offset)
                .rotationEffect(item.angle)
            }
            let centerSize = (size - itemSize)
            center(centerSize, borderWidth)
                .frame(width: centerSize, height:centerSize)
                .overlay(Circle().stroke(viewModel.itemBorderColor, style: StrokeStyle(lineWidth: borderWidth)))
                .background(Circle().fill(viewModel.faceColor))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct ClockItemsView_Previews: PreviewProvider {
    static var previews: some View {
        HStack() {
            let m = ClockViewModel.dummyModel
            ClockItemsView(m, size: 300, action: { m in
                
            }, center: { centerSize,borderWidth in
                ClockBaseView(m, size: centerSize)
                
            })
            
            
            .frame(width: 500, height: 400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray)
    }
}
