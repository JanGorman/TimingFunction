//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import Cocoa

protocol DrawingViewDelegate: AnyObject {

  func drawingView(_ drawingView: DrawingView, draggingPoint point1: NSPoint, point2: NSPoint)
  func drawingView(_ drawingView: DrawingView, commitedPoint point1: NSPoint, point2: NSPoint)

}

@objc private class LastPoint: NSObject {

  enum Target: Int {
    case first, second
  }

  let target: Target
  let point: NSPoint

  init(target: Target, point: NSPoint) {
    self.target = target
    self.point = point
    super.init()
  }

}

final class DrawingView: NSView {

  private static let margin: CGFloat = 40

  private var trackingArea: NSTrackingArea!
  private var draggable: ControlPoint?
  private var targetStartFrame: NSRect!
  private var mouseDownStartingPoint: NSPoint!

  private var draggableControlPoint1: ControlPoint!
  private var draggableControlPoint2: ControlPoint!

  private let startPoint = NSPoint(x: DrawingView.margin, y: DrawingView.margin)

  private lazy var endPoint = NSPoint(x: bounds.maxX - DrawingView.margin, y: bounds.maxY - DrawingView.margin)

  private var controlPoint1: NSPoint {
    let x = abs(draggableControlPoint1.frame.origin.x - startPoint.x) / abs(startPoint.x - endPoint.x)
    let y = abs(draggableControlPoint1.frame.origin.y - startPoint.y) / abs(startPoint.y - endPoint.y)
    return NSPoint(x: x, y: y)
  }

  private var controlPoint2: NSPoint {
    let x = abs(draggableControlPoint2.frame.origin.x - startPoint.x) / abs(startPoint.x - endPoint.x)
    let y = abs(draggableControlPoint2.frame.origin.y - startPoint.y) / abs(startPoint.y - endPoint.y)
    return NSPoint(x: x, y: y)
  }

  weak var delegate: DrawingViewDelegate?

  override func awakeFromNib() {
    updateTrackingAreas()

    draggableControlPoint1 = ControlPoint(frame: NSRect(x: 30, y: 30, width: 20, height: 20))
    draggableControlPoint2 = ControlPoint(frame: NSRect(x: 200, y: 200, width: 20, height: 20))

    draggableControlPoint1.setFrameOrigin(UserDefaults.standard.controlPoint1)
    draggableControlPoint2.setFrameOrigin(UserDefaults.standard.controlPoint2)

    if !NSPointInRect(draggableControlPoint1.frame.origin, bounds) {
      UserDefaults.standard.removeObject(forKey: .controlPoint1)
    }
    if !NSPointInRect(draggableControlPoint2.frame.origin, bounds) {
      UserDefaults.standard.removeObject(forKey: .controlPoint2)
    }

    addSubview(draggableControlPoint1)
    addSubview(draggableControlPoint2)
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()

    if trackingArea != nil {
      removeTrackingArea(trackingArea)
      trackingArea = nil
    }

    let options: NSTrackingArea.Options = [.mouseMoved, .inVisibleRect, .mouseEnteredAndExited, .activeAlways]
    trackingArea = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
    addTrackingArea(trackingArea)
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    NSColor.gray.setFill()
    NSInsetRect(bounds, 0, 0).fill()
    NSColor.init(deviceWhite: 0.97, alpha: 1).setFill()
    NSInsetRect(bounds, 1, 1).fill()

    let point1 = NSPoint(x: draggableControlPoint1.frame.midX, y: draggableControlPoint1.frame.midY)
    let point2 = NSPoint(x: draggableControlPoint2.frame.midX, y: draggableControlPoint2.frame.midY)

    drawYAxis()
    drawXAxis()
    drawLineToFirstControlPoint(point1)
    drawLineToSecondControlPoint(point2)
    drawBezier(controlPoint1: point1, controlPoint2: point2)
  }

  private func drawYAxis() {
    NSColor.lightGray.setStroke()
    let line = NSBezierPath()
    line.lineCapStyle = .square
    line.lineWidth = 3
    line.move(to: NSPoint(x: startPoint.x, y: endPoint.y - 20))
    line.move(to: NSPoint(x: startPoint.x, y: endPoint.y))
    line.stroke()
  }

  private func drawXAxis() {
    NSColor.lightGray.setStroke()
    let line = NSBezierPath()
    line.lineCapStyle = .square
    line.lineWidth = 3
    line.move(to: NSPoint(x: startPoint.x - 20, y: startPoint.y))
    line.move(to: NSPoint(x: endPoint.x, y: endPoint.y))
    line.stroke()
  }

  private func drawLineToFirstControlPoint(_ point: NSPoint) {
    NSColor.gray.setStroke()
    let line = NSBezierPath()
    line.lineCapStyle = .square
    line.lineWidth = 2
    line.move(to: startPoint)
    line.line(to: point)
    line.stroke()
  }

  private func drawLineToSecondControlPoint(_ point: NSPoint) {
    NSColor.gray.setStroke()
    let line = NSBezierPath()
    line.lineCapStyle = .square
    line.lineWidth = 2
    line.move(to: endPoint)
    line.line(to: point)
    line.stroke()
  }

  private func drawBezier(controlPoint1 point1: NSPoint, controlPoint2 point2: NSPoint) {
    NSColor.blue.setFill()
    let line = NSBezierPath()
    line.lineWidth = 3
    line.move(to: startPoint)
    line.curve(to: endPoint, controlPoint1: point1, controlPoint2: point2)
    line.stroke()
  }

  override func mouseDown(with event: NSEvent) {
    draggable = nil
    let point = convert(event.locationInWindow, from: nil)
    guard let view = draggableHitTest(point) as? ControlPoint else { return }

    draggable = view
    draggable?.isMouseDown = true
    mouseDownStartingPoint = point
    targetStartFrame = draggable!.frame
    draggable?.needsDisplay = true
    needsDisplay = true
  }

  private func draggableHitTest(_ point: NSPoint) -> NSView? {
    for view in subviews {
      if !view.isHidden && NSPointInRect(point, view.frame) {
        return view
      }
    }
    return nil
  }

  override func mouseUp(with event: NSEvent) {
    guard let draggable = draggable else { return }

    let point = clampPoint(convert(event.locationInWindow, from: nil))
    draggable.isMouseDown = false
    draggable.setFrameOrigin(point)
    draggable.needsDisplay = true

    if draggable === draggableControlPoint1 {
      UserDefaults.standard.controlPoint1 = draggable.frame.origin
    } else {
      UserDefaults.standard.controlPoint2 = draggable.frame.origin
    }

    needsDisplay = true

    delegate?.drawingView(self, draggingPoint: controlPoint1, point2: controlPoint2)
    delegate?.drawingView(self, commitedPoint: controlPoint1, point2: controlPoint2)

    storeLastPoint(LastPoint(target: draggable === draggableControlPoint1 ? .first : .second, point: targetStartFrame.origin))

    self.draggable = nil
  }

  private func clampPoint(_ point: NSPoint) -> NSPoint {
    let x = (targetStartFrame.origin.x + (point.x - mouseDownStartingPoint.x)).clamped(min: 0, max: bounds.maxX - 20)
    let y = (targetStartFrame.origin.y + (point.y - mouseDownStartingPoint.y)).clamped(min: 0, max: bounds.maxY - 20)
    return NSPoint(x: x, y: y)
  }

  private func storeLastPoint(_ point: LastPoint) {
    undoManager?.registerUndo(withTarget: self, selector: #selector(restoreLastPoint), object: point)
  }

  @objc private func restoreLastPoint(_ point: LastPoint) {
    switch point.target {
    case .first:
      draggableControlPoint1.setFrameOrigin(point.point)
      UserDefaults.standard.controlPoint1 = point.point
    case .second:
      draggableControlPoint2.setFrameOrigin(point.point)
      UserDefaults.standard.controlPoint2 = point.point
    }

    needsDisplay = true

    delegate?.drawingView(self, draggingPoint: controlPoint1, point2: controlPoint2)
    delegate?.drawingView(self, commitedPoint: controlPoint1, point2: controlPoint2)
  }

  override func mouseDragged(with event: NSEvent) {
    guard let draggable = draggable else { return }

    let point = clampPoint(convert(event.locationInWindow, from: nil))
    draggable.setFrameOrigin(point)
    needsDisplay = true

    delegate?.drawingView(self, draggingPoint: controlPoint1, point2: controlPoint2)
  }

}

final class ControlPoint: NSView {

  fileprivate(set) var isMouseDown = false

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    NSGraphicsContext.current?.saveGraphicsState()

    let shadow = NSShadow()
    if isMouseDown {
      shadow.shadowColor = NSColor(named: .shadowActive)
      shadow.shadowOffset = NSSize(width: 0, height: -2)
      shadow.shadowBlurRadius = 2
    } else {
      shadow.shadowColor = NSColor(named: .shadowInactive)
      shadow.shadowOffset = NSSize(width: 0, height: -1)
      shadow.shadowBlurRadius = 1
    }
    shadow.set()

    let margin: CGFloat = isMouseDown ? 2 : 3

    var dot = NSBezierPath(ovalIn: NSInsetRect(bounds, margin, margin))
    NSColor.gray.setFill()
    dot.fill()

    NSGraphicsContext.current?.restoreGraphicsState()

    dot = NSBezierPath(ovalIn: NSInsetRect(bounds, margin + 1, margin + 1))
    NSColor.white.setFill()
    dot.fill()
  }

}
