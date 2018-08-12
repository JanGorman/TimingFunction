//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import Cocoa
import QuartzCore

final class PreviewView: NSView {
  
  private var trackingArea: NSTrackingArea!
  private var isMouseIn = false
  private var dot: CALayer!
  
  var timingFunction: CAMediaTimingFunction!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    updateTrackingAreas()
    layer = CALayer()
    wantsLayer = true
    layer?.backgroundColor = NSColor(named: .previewBackground).cgColor
    layer?.borderWidth = 1
    layer?.borderColor = NSColor.gray.cgColor
    
    dot = CALayer()
    dot.frame = CGRect(x: bounds.midX, y: bounds.midY, width: 16, height: 16)
    dot.cornerRadius = 8
    dot.backgroundColor = NSColor(named: .dot).cgColor
    dot.shadowColor = NSColor.black.cgColor
    dot.shadowOffset = CGSize(width: 0, height: -1)
    dot.shadowOpacity = 0.1
    layer?.addSublayer(dot)
  }
  
  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    
    if trackingArea != nil {
      self.removeTrackingArea(trackingArea)
      trackingArea = nil
    }
    
    let options: NSTrackingArea.Options = [.inVisibleRect, .mouseEnteredAndExited, .activeAlways]
    trackingArea = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
    addTrackingArea(trackingArea)
  }
  
  func animate(withTimingFunction timingFunction: CAMediaTimingFunction) {
    dot.removeAllAnimations()
    
    self.timingFunction = timingFunction
    
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    dot.frame = CGRect(x: bounds.minX + 10, y: bounds.minY + 10, width: 16, height: 16)
    CATransaction.commit()
    
    let animation = CABasicAnimation(keyPath: "position")
    animation.fromValue = NSValue(point: dot.frame.origin)
    animation.toValue = NSValue(point: CGPoint(x: bounds.maxX - 20, y: bounds.maxY - 20))
    animation.timingFunction = timingFunction
    animation.duration = isMouseIn ? 5 : 1
    animation.repeatCount = .greatestFiniteMagnitude
    
    dot.add(animation, forKey: "position")
  }
  
  override func mouseEntered(with event: NSEvent) {
    isMouseIn = true
    layer?.backgroundColor = NSColor.white.cgColor
    guard let timingFunction = timingFunction else { return }
    animate(withTimingFunction: timingFunction)
  }
  
  override func mouseExited(with event: NSEvent) {
    isMouseIn = false
    layer?.backgroundColor = NSColor(named: .previewBackground).cgColor
    guard let timingFunction = timingFunction else { return }
    animate(withTimingFunction: timingFunction)
  }
  
}
