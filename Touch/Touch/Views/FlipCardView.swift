import SwiftUI

/// 绕 Y 轴翻转。
private struct FlipRotation: GeometryEffect {
    var angle: Double

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        var transform = CATransform3DIdentity
        transform.m34 = -1 / 900
        // GeometryEffect 以左上角为原点，先平移到中心再旋转
        transform = CATransform3DTranslate(transform, size.width / 2, size.height / 2, 0)
        transform = CATransform3DRotate(transform, CGFloat(angle * .pi / 180), 0, 1, 0)
        transform = CATransform3DTranslate(transform, -size.width / 2, -size.height / 2, 0)
        return ProjectionTransform(transform)
    }
}

/// 只在翻过 90° 之后才显示某一面，避免镜像穿透。
private struct HalfVisibility: AnimatableModifier {
    var angle: Double
    var visibleUnder90: Bool

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func body(content: Content) -> some View {
        content.opacity(visibleUnder90 ? (angle < 90 ? 1 : 0) : (angle >= 90 ? 1 : 0))
    }
}

struct FlipCardView: View {
    var card: Card
    var faceUp: Bool
    var size: CGSize

    private var angle: Double { faceUp ? 180 : 0 }

    var body: some View {
        ZStack {
            CardBackView()
                .frame(width: size.width, height: size.height)
                .modifier(HalfVisibility(angle: angle, visibleUnder90: true))

            CardFaceView(card: card)
                .frame(width: size.width, height: size.height)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .modifier(HalfVisibility(angle: angle, visibleUnder90: false))
        }
        .modifier(FlipRotation(angle: angle))
        .frame(width: size.width, height: size.height)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(faceUp ? "cardFace" : "cardBack")
        .accessibilityLabel(faceUp ? card.displayName : "牌背")
    }
}