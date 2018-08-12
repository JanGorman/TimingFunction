//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import Cocoa

extension UserDefaults {

  enum Key: String {
    case controlPoint1 = "controlPoint1"
    case controlPoint2 = "controlPoint2"
  }

  var controlPoint1: NSPoint {
    get {
      let str = string(forKey: Key.controlPoint1.rawValue)!
      return NSPointFromString(str)
    }
    set {
      set(NSStringFromPoint(newValue), forKey: Key.controlPoint1.rawValue)
    }
  }

  var controlPoint2: NSPoint {
    get {
      let str = string(forKey: Key.controlPoint2.rawValue)!
      return NSPointFromString(str)
    }
    set {
      set(NSStringFromPoint(newValue), forKey: Key.controlPoint2.rawValue)
    }
  }

  func removeObject(forKey key: Key) {
    removeObject(forKey: key.rawValue)
  }

  func register(defaults: [Key: Any]) {
    let mapped = Dictionary(uniqueKeysWithValues: defaults.map { key, value in
      (key.rawValue, value)
    })
    register(defaults: mapped)
    NSUserDefaultsController.shared.initialValues = mapped
  }

}
