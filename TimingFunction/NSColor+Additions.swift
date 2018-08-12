//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import Cocoa

extension NSColor {

  enum Color: String {
    case keyword = "Keyword"
    case dot = "Dot"
    case previewBackground = "Preview Background"
    case shadowActive = "Shadow Active"
    case shadowInactive = "Shadow Inactive"
  }

  convenience init(named color: Color) {
    self.init(named: color.rawValue)!
  }

}

