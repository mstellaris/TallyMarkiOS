import AppKit
import CoreGraphics

// Draws a five-mark tally group (four strokes plus a slash) on a 1024 canvas.
func render(to path: String, background: [CGColor]?, markColor: CGColor) {
    let size = 1024
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                        space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    if let background {
        if background.count == 1 {
            ctx.setFillColor(background[0]); ctx.fill(rect)
        } else {
            let gradient = CGGradient(colorsSpace: space, colors: background as CFArray, locations: [0, 1])!
            ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 1024), end: CGPoint(x: 1024, y: 0), options: [])
        }
    }
    ctx.setStrokeColor(markColor)
    ctx.setLineCap(.round)
    ctx.setLineWidth(56)
    let xs: [CGFloat] = [332, 452, 572, 692]
    for x in xs {
        ctx.move(to: CGPoint(x: x, y: 292)); ctx.addLine(to: CGPoint(x: x, y: 732))
    }
    ctx.strokePath()
    ctx.setLineWidth(60)
    ctx.move(to: CGPoint(x: 252, y: 352)); ctx.addLine(to: CGPoint(x: 772, y: 672))
    ctx.strokePath()
    let image = ctx.makeImage()!
    let rep = NSBitmapImageRep(cgImage: image)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

let out = CommandLine.arguments[1]
let green = CGColor(srgbRed: 0.20, green: 0.78, blue: 0.40, alpha: 1)
let teal = CGColor(srgbRed: 0.05, green: 0.55, blue: 0.55, alpha: 1)
render(to: "\(out)/AppIcon.png", background: [green, teal], markColor: .white)
render(to: "\(out)/AppIcon-Dark.png", background: [CGColor(srgbRed: 0.07, green: 0.09, blue: 0.09, alpha: 1)], markColor: green)
render(to: "\(out)/AppIcon-Tinted.png", background: [CGColor(gray: 0, alpha: 1)], markColor: CGColor(gray: 1, alpha: 1))
