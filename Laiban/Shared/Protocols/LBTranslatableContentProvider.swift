//
//  Created by Tomas Green on 2022-05-11.
//

import Foundation
import Combine

public protocol LBTranslatableContentProvider {
    var stringsToTranslatePublisher:AnyPublisher<[String],Never> { get }
    var stringsToTranslate:[String] { get }
}
