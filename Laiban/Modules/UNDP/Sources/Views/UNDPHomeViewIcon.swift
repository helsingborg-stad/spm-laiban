
import SwiftUI

public struct UNDPHomeViewIcon : View {
    public var body:some View {
        LBBadgeView(rimColor: UNDPGoal.allCases.map({ $0.backgroundColor })) { diameter in
            Image("undp17globalgoals_logo",bundle: .module)
                .renderingMode(.original)
                .resizable()
                .frame(width:diameter * 0.5,height:diameter * 0.5)
        }
    }
    public init() {
        
    }
}
