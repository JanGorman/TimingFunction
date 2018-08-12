//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import Foundation

protocol Clampable {
  func clamped(min lower: Self, max upper: Self) -> Self
}

extension Clampable where Self: Comparable {

  func clamped(min lower: Self, max upper: Self) -> Self {
    return min(max(self, lower), upper)
  }

}

extension IntegerLiteralType: Clampable {}
extension FloatLiteralType: Clampable {}
extension CGFloat: Clampable {}
