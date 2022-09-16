//
//  LaibanFaceView.swift
//
//  Created by Tomas Green on 2020-03-16.
//

import SwiftUI

public struct LaibanExpression : Equatable {
    struct PixelPoint : Identifiable, Equatable {
        var id:String
        let row:Int
        let index:Int
    }
    private var numberOfRows:Int = 0
    private var numberOfColums:Int = 0
    let pixels:[PixelPoint]
    func width(pixelSize:CGFloat) -> CGFloat{
        guard numberOfColums > 2 else {
            return 0
        }
        return CGFloat(numberOfColums) * pixelSize + CGFloat(numberOfColums-1) * pixelSize/3
    }
    func height(pixelSize:CGFloat) -> CGFloat{
        guard numberOfRows > 2 else {
            return 0
        }
        return CGFloat(numberOfRows) * pixelSize + CGFloat(numberOfRows-1) * pixelSize/3
    }
    func position(pixel:PixelPoint,pixelSize:CGFloat) -> CGSize {
        return CGSize(width: xOffset(pixel: pixel, pixelSize:pixelSize), height: yOffset(pixel: pixel, pixelSize:pixelSize))
    }
    func xOffset(pixel:PixelPoint,pixelSize:CGFloat) -> CGFloat {
        return CGFloat(pixel.index) * pixelSize + CGFloat(pixel.index) * (pixelSize/3)
    }
    func yOffset(pixel:PixelPoint,pixelSize:CGFloat) -> CGFloat {
        return CGFloat(pixel.row) * pixelSize + CGFloat(pixel.row) * (pixelSize/3)
    }
    
    public init(_ string:String) {
        var points = [PixelPoint]()
        let arrayRow = string.split(separator: "\n")
        self.numberOfRows = arrayRow.count
        var rowIds = [Int:Int]()
        for (index,row) in arrayRow.enumerated() {
            self.numberOfColums = row.count
            for (colIndex,col) in row.enumerated() {
                if col == "0" {
                    if rowIds[colIndex] == nil {
                       rowIds[colIndex] = 0
                    }
                    points.append(PixelPoint(id:"col\(colIndex)-\(rowIds[colIndex]!)",row:index,index:colIndex))
                    rowIds[colIndex] = rowIds[colIndex]! + 1
                }
            }
        }
        self.pixels = points
    }
    public static let smile = LaibanExpression(
"""
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
---------0000--------0000---------
--------000000------000000--------
--------0----0------0----0--------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
--------------00--00--------------
---------------0000---------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
""")
    public static let wink = LaibanExpression(
"""
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
-----------------------0000-------
----------------------000000------
----------------------000000------
----------------------000000------
----------------------000000------
----------------------000000------
------000000----------000000------
-------0000------------0000-------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------0------------0----------
----------0-00--00--00-0----------
-----------00-00--00-00-----------
----------------------------------
""")
    public static let suspicious = LaibanExpression(
"""
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
------000000----------000000------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
--------------000000--------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
""")
    public static let surprised = LaibanExpression(
"""
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
----------------------------------
-------0000------------0000-------
------000000----------000000------
------000000----------000000------
------000000----------000000------
------000000----------000000------
------000000----------000000------
------000000----------000000------
-------0000------------0000-------
----------------------------------
----------------------------------
----------------------------------
--------------000000--------------
-------------0------0-------------
-------------0------0-------------
--------------000000--------------
----------------------------------
""")
    public static var expressions:[LaibanExpression] {
        [smile,wink,surprised,suspicious]
    }
}

public struct LaibanFaceView: View {
    @State var timer = Timer.publish(every: 10, on: .current, in: .common).autoconnect()
    @State var expression:LaibanExpression
    var expressions:[LaibanExpression]
    var showImage:Bool
    var animated:Bool
    let width:CGFloat = 192
    let height:CGFloat = 141
    let pixelSize:CGFloat = 3.5
    init(
        expression:LaibanExpression = .smile,
        expressions:[LaibanExpression] = LaibanExpression.expressions,
        showImage:Bool = false,
        animated:Bool = true
    ) {
        self._expression = State(initialValue: .smile)
        self.expressions = expressions
        self.showImage = showImage
        self.animated = animated
    }
    public var body: some View {
        GeometryReader() { proxy in
            ZStack(alignment: .center) {
                ZStack(alignment: .topLeading) {
                    ForEach(expression.pixels) { pixel in
                        Circle().fill(Color.white.opacity(0.7))
                            .frame(width: pixelSize, height: pixelSize)
                            .animation(.easeIn(duration: 0.15),value: expression)
                            .offset(expression.position(pixel: pixel, pixelSize: pixelSize))
                    }
                }
                .frame(width: expression.width(pixelSize: pixelSize), height: expression.height(pixelSize: pixelSize),alignment:.topLeading)
                .scaleEffect(proxy.size.width/width)
                .offset(x: 0, y: 10 * proxy.size.height/width)
            }
            .frame(width:proxy.size.width, height: proxy.size.height, alignment: .center)
            .background(Image("LaibanFaceOnly", bundle:.module).resizable().frame(width:proxy.size.width, height:proxy.size.height).opacity(self.showImage ? 1 : 0))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeIn(duration: 0.15), value:expression)
        }
        .aspectRatio(width/height, contentMode: .fit)
        .onReceive(timer) { timer in
            if animated == false {
                return
            }
            if Bool.random() {
                return
            }
            let f = expression
            withAnimation {
                expression = LaibanExpression.expressions.randomElement() ?? f
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double.random(in: 1...3)) {
                withAnimation {
                    expression = f
                }
            }
        }
    }
}

struct LaibanFaceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            LaibanFaceView().frame(width: 100).background(Color.black)
            LaibanFaceView().frame(width: 192).background(Color.black)
            LaibanFaceView().frame(width: 300).background(Color.black)
            LaibanFaceView().frame(maxWidth: .infinity).background(Color.black)
            Spacer()
        }
    }
}
