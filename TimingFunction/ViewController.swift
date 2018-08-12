//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

  @IBOutlet var drawingView: DrawingView!
  @IBOutlet var previewView: PreviewView!
  @IBOutlet var textView: NSTextView!

  override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    registerDefaults()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    registerDefaults()
  }

  private func registerDefaults() {
    let defaults: [UserDefaults.Key: Any] = [
      .controlPoint1: NSStringFromPoint(NSPoint(x: 75, y: 280)),
      .controlPoint2: NSStringFromPoint(NSPoint(x: 290, y: 160))
    ]
    UserDefaults.standard.register(defaults: defaults)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    drawingView.delegate = self
  }

}

extension ViewController: DrawingViewDelegate {

  func drawingView(_ drawingView: DrawingView, draggingPoint point1: NSPoint, point2: NSPoint) {
    let keywordAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor(named: .keyword)]
    let paramsAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.blue]

    let string = NSMutableAttributedString()
    string.append(NSAttributedString(string: "CAMediaTimingFunction", attributes: keywordAttribute))
    string.append(NSAttributedString(string: "(controlPoints: "))
    string.append(NSAttributedString(string: formattedControlPoint(point1.x), attributes: paramsAttribute))
    string.append(NSAttributedString(string: ", "))
    string.append(NSAttributedString(string: formattedControlPoint(point1.y), attributes: paramsAttribute))
    string.append(NSAttributedString(string: ", "))
    string.append(NSAttributedString(string: formattedControlPoint(point2.x), attributes: paramsAttribute))
    string.append(NSAttributedString(string: ", "))
    string.append(NSAttributedString(string: formattedControlPoint(point1.y), attributes: paramsAttribute))
    string.append(NSAttributedString(string: ")"))

    textView.textStorage?.setAttributedString(string)
  }

  private func formattedControlPoint(_ point: CGFloat) -> String {
    return String(format: "%.2f", point)
  }

  func drawingView(_ drawingView: DrawingView, commitedPoint point1: NSPoint, point2: NSPoint) {
    let timingFunction = CAMediaTimingFunction(controlPoints: Float(point1.x), Float(point1.y), Float(point2.x), Float(point2.y))
    previewView.animate(withTimingFunction: timingFunction)
  }


}
