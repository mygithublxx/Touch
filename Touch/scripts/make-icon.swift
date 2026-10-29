import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let S: CGFloat = 1024
let cs = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(data: nil, width: Int(S), height: Int(S),
                          bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    exit(1)
}

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: r, green: g, blue: b, alpha: a)
}

// 背景
ctx.setFillColor(rgb(0, 0, 0))
ctx.fill(CGRect(x: 0, y: 0, width: S, height: S))

if let g = CGGradient(colorsSpace: cs,
                      colors: [rgb(0.10, 0.10, 0.125), rgb(0, 0, 0)] as CFArray,
                      locations: [0, 1]) {
    ctx.drawRadialGradient(g,
                           startCenter: CGPoint(x: S * 0.5, y: S * 0.52), startRadius: 0,
                           endCenter: CGPoint(x: S * 0.5, y: S * 0.52), endRadius: S * 0.72,
                           options: [])
}

// 卡片（倾斜）
ctx.saveGState()
ctx.translateBy(x: S * 0.5, y: S * 0.5)
ctx.rotate(by: -12 * .pi / 180)

let cardW: CGFloat = 490
let cardH: CGFloat = 690
let cardRect = CGRect(x: -cardW / 2, y: -cardH / 2, width: cardW, height: cardH)
let cardPath = CGPath(roundedRect: cardRect, cornerWidth: 64, cornerHeight: 64, transform: nil)

// 卡片外发光
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 70, color: rgb(1, 1, 1, 0.07))
ctx.addPath(cardPath)
ctx.setFillColor(rgb(0.08, 0.08, 0.10))
ctx.fillPath()
ctx.restoreGState()

// 卡片渐变填充
ctx.saveGState()
ctx.addPath(cardPath)
ctx.clip()
if let g = CGGradient(colorsSpace: cs,
                      colors: [rgb(0.20, 0.205, 0.235), rgb(0.055, 0.055, 0.070)] as CFArray,
                      locations: [0, 1]) {
    ctx.drawLinearGradient(g,
                           start: CGPoint(x: -cardW / 2, y: cardH / 2),
                           end: CGPoint(x: cardW / 2, y: -cardH / 2),
                           options: [])
}
ctx.restoreGState()

// 卡片描边
ctx.addPath(cardPath)
ctx.setStrokeColor(rgb(1, 1, 1, 0.22))
ctx.setLineWidth(3)
ctx.strokePath()

// 内描边
let innerRect = cardRect.insetBy(dx: 26, dy: 26)
ctx.addPath(CGPath(roundedRect: innerRect, cornerWidth: 44, cornerHeight: 44, transform: nil))
ctx.setStrokeColor(rgb(1, 1, 1, 0.07))
ctx.setLineWidth(2)
ctx.strokePath()

// 刮痕：从右下到左上的一道光
let start = CGPoint(x: 196, y: -252)
let end = CGPoint(x: -196, y: 252)
let baseWidth: CGFloat = 96

let line = CGMutablePath()
line.move(to: start)
line.addLine(to: end)

// 光晕（用真实高斯阴影，避免同心圆环）
let core = line.copy(strokingWithWidth: baseWidth, lineCap: .round, lineJoin: .round, miterLimit: 10)
ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 120, color: rgb(1, 1, 1, 0.45))
ctx.addPath(core)
ctx.setFillColor(rgb(1, 1, 1, 0.035))
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.setShadow(offset: .zero, blur: 40, color: rgb(1, 1, 1, 0.35))
ctx.addPath(core)
ctx.setFillColor(rgb(1, 1, 1, 0.02))
ctx.fillPath()
ctx.restoreGState()
ctx.saveGState()
ctx.addPath(core)
ctx.clip()
if let g = CGGradient(colorsSpace: cs,
                      colors: [rgb(1, 1, 1, 0.0), rgb(1, 1, 1, 0.92), rgb(1, 1, 1, 0.72), rgb(1, 1, 1, 0.0)] as CFArray,
                      locations: [0, 0.32, 0.68, 1]) {
    ctx.drawLinearGradient(g,
                           start: CGPoint(x: start.x + 60, y: start.y - 60),
                           end: CGPoint(x: end.x - 60, y: end.y + 60),
                           options: [])
}
ctx.restoreGState()

// 细碎刮痕（限制在光带范围里）
ctx.saveGState()
ctx.addPath(core)
ctx.clip()
for offset in [-34.0, -14.0, 18.0, 40.0] {
    let a = CGPoint(x: start.x + offset * 0.4, y: start.y + offset)
    let b = CGPoint(x: end.x + offset * 0.4, y: end.y + offset)
    let p = CGMutablePath()
    p.move(to: a)
    p.addLine(to: b)
    ctx.addPath(p.copy(strokingWithWidth: 3, lineCap: .round, lineJoin: .round, miterLimit: 10))
    ctx.setFillColor(rgb(1, 1, 1, 0.13))
    ctx.fillPath()
}
ctx.restoreGState()

ctx.restoreGState()

guard let image = ctx.makeImage() else { exit(1) }
let out = URL(fileURLWithPath: CommandLine.arguments[1])
guard let dest = CGImageDestinationCreateWithURL(out as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    exit(1)
}
CGImageDestinationAddImage(dest, image, nil)
CGImageDestinationFinalize(dest)
print("wrote \(out.path)")