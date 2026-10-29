import SwiftUI

/// 牌的统一尺寸：最大 72% 屏高、86% 屏宽，宽高比 0.70（接近 2.5 : 3.5）。
enum CardLayout {
    static let aspect: CGFloat = 0.70

    static func size(in board: CGSize) -> CGSize {
        let maxHeight = board.height * 0.72
        let maxWidth = board.width * 0.86
        let height = min(maxHeight, maxWidth / aspect)
        return CGSize(width: height * aspect, height: height)
    }
}

/// 牌背：深蓝黑渐变 + 鳞纹 + 中央徽记 + 双层描边。
struct CardBackView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let corner = w * 0.055
            let shape = RoundedRectangle(cornerRadius: corner, style: .continuous)

            ZStack {
                // 底
                shape.fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.125, green: 0.140, blue: 0.185),
                            Color(red: 0.045, green: 0.050, blue: 0.070),
                            Color(red: 0.015, green: 0.018, blue: 0.026)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                // 鳞纹（交错圆弧）
                Canvas { ctx, size in
                    let step = size.width / 5.2
                    let radius = step * 0.58
                    var row = 0
                    var y = -radius
                    while y < size.height + radius {
                        var x: CGFloat = row.isMultiple(of: 2) ? -radius : -radius + step / 2
                        while x < size.width + radius {
                            let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                            ctx.stroke(Path(ellipseIn: rect), with: .color(.white.opacity(0.048)), lineWidth: 1)
                            let dot = CGRect(x: x - 1.1, y: y - 1.1, width: 2.2, height: 2.2)
                            ctx.fill(Path(ellipseIn: dot), with: .color(.white.opacity(0.07)))
                            x += step
                        }
                        y += step * 0.58
                        row += 1
                    }
                }
                .clipShape(shape)

                // 左上柔光
                shape.fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.075), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )

                // 中央徽记
                medallion(width: w)
                    .position(x: w / 2, y: h / 2)

                // 内框
                RoundedRectangle(cornerRadius: corner * 0.72, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.085), lineWidth: 1)
                    .padding(w * 0.045)

                // 外框
                shape.strokeBorder(Color.white.opacity(0.17), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.7), radius: w * 0.075, y: w * 0.035)
        }
    }

    private func medallion(width w: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.075, green: 0.085, blue: 0.115),
                            Color(red: 0.012, green: 0.014, blue: 0.020)
                        ],
                        center: UnitPoint(x: 0.38, y: 0.32),
                        startRadius: 0,
                        endRadius: w * 0.22
                    )
                )
                .frame(width: w * 0.40, height: w * 0.40)

            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), Color.white.opacity(0.07)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .frame(width: w * 0.40, height: w * 0.40)

            Circle()
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                .frame(width: w * 0.315, height: w * 0.315)

            Path { path in
                let r = w * 0.062
                path.move(to: CGPoint(x: 0, y: -r))
                path.addLine(to: CGPoint(x: r * 0.74, y: 0))
                path.addLine(to: CGPoint(x: 0, y: r))
                path.addLine(to: CGPoint(x: -r * 0.74, y: 0))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.30), Color.white.opacity(0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: w * 0.13, height: w * 0.13)
        }
    }
}

/// 牌面：点数 + 花色，2–10 用经典点位排布。
struct CardFaceView: View {
    var card: Card

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let corner = width * 0.055
            let ink: Color = card.suit.isRed
                ? Color(red: 0.76, green: 0.10, blue: 0.16)
                : Color(red: 0.07, green: 0.07, blue: 0.09)

            ZStack {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(Color(red: 0.985, green: 0.978, blue: 0.962))

                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.10), lineWidth: 1)

                cornerIndex(ink: ink, width: width)
                    .position(x: width * 0.135, y: height * 0.095)

                cornerIndex(ink: ink, width: width)
                    .rotationEffect(.degrees(180))
                    .position(x: width * 0.865, y: height * 0.905)

                centerContent(ink: ink, width: width, height: height)
            }
            .shadow(color: .black.opacity(0.5), radius: width * 0.06, y: width * 0.03)
        }
    }

    // MARK: 角标

    private func cornerIndex(ink: Color, width: CGFloat) -> some View {
        VStack(spacing: -width * 0.012) {
            Text(card.rank.label)
                .font(.system(size: width * 0.145, weight: .semibold, design: .serif))
            Text(card.suit.glyph)
                .font(.system(size: width * 0.115))
        }
        .foregroundStyle(ink)
        .lineLimit(1)
    }

    // MARK: 中央

    @ViewBuilder
    private func centerContent(ink: Color, width: CGFloat, height: CGFloat) -> some View {
        switch card.rank {
        case .ace:
            Text(card.suit.glyph)
                .font(.system(size: width * 0.46))
                .foregroundStyle(ink)
                .frame(width: width * 0.74, height: height * 0.62)
        case .jack, .queen, .king:
            VStack(spacing: -width * 0.01) {
                Text(card.rank.label)
                    .font(.system(size: width * 0.34, weight: .bold, design: .serif))
                Text(card.suit.glyph)
                    .font(.system(size: width * 0.17))
            }
            .foregroundStyle(ink)
            .frame(width: width * 0.74, height: height * 0.62)
        default:
            pips(ink: ink, width: width, height: height)
        }
    }

    private func pips(ink: Color, width: CGFloat, height: CGFloat) -> some View {
        let points = pipPoints(for: card.rank)
        let box = CGSize(width: width * 0.54, height: height * 0.58)
        return ZStack {
            ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                Text(card.suit.glyph)
                    .font(.system(size: width * 0.135))
                    .foregroundStyle(ink)
                    .rotationEffect(.degrees(point.y > 0.5 ? 180 : 0))
                    .position(x: box.width * point.x, y: box.height * point.y)
            }
        }
        .frame(width: box.width, height: box.height)
    }

    private func pipPoints(for rank: Rank) -> [CGPoint] {
        switch rank {
        case .two:
            return [.init(x: 0.5, y: 0.06), .init(x: 0.5, y: 0.94)]
        case .three:
            return [.init(x: 0.5, y: 0.06), .init(x: 0.5, y: 0.5), .init(x: 0.5, y: 0.94)]
        case .four:
            return [.init(x: 0.22, y: 0.06), .init(x: 0.78, y: 0.06),
                    .init(x: 0.22, y: 0.94), .init(x: 0.78, y: 0.94)]
        case .five:
            return [.init(x: 0.22, y: 0.06), .init(x: 0.78, y: 0.06),
                    .init(x: 0.5, y: 0.5),
                    .init(x: 0.22, y: 0.94), .init(x: 0.78, y: 0.94)]
        case .six:
            return [.init(x: 0.22, y: 0.06), .init(x: 0.78, y: 0.06),
                    .init(x: 0.22, y: 0.5), .init(x: 0.78, y: 0.5),
                    .init(x: 0.22, y: 0.94), .init(x: 0.78, y: 0.94)]
        case .seven:
            return [.init(x: 0.22, y: 0.06), .init(x: 0.78, y: 0.06),
                    .init(x: 0.5, y: 0.28),
                    .init(x: 0.22, y: 0.5), .init(x: 0.78, y: 0.5),
                    .init(x: 0.22, y: 0.94), .init(x: 0.78, y: 0.94)]
        case .eight:
            return [.init(x: 0.22, y: 0.06), .init(x: 0.78, y: 0.06),
                    .init(x: 0.5, y: 0.28),
                    .init(x: 0.22, y: 0.5), .init(x: 0.78, y: 0.5),
                    .init(x: 0.5, y: 0.72),
                    .init(x: 0.22, y: 0.94), .init(x: 0.78, y: 0.94)]
        case .nine:
            return [.init(x: 0.22, y: 0.04), .init(x: 0.78, y: 0.04),
                    .init(x: 0.22, y: 0.27), .init(x: 0.78, y: 0.27),
                    .init(x: 0.5, y: 0.5),
                    .init(x: 0.22, y: 0.73), .init(x: 0.78, y: 0.73),
                    .init(x: 0.22, y: 0.96), .init(x: 0.78, y: 0.96)]
        case .ten:
            return [.init(x: 0.22, y: 0.02), .init(x: 0.78, y: 0.02),
                    .init(x: 0.5, y: 0.2),
                    .init(x: 0.22, y: 0.38), .init(x: 0.78, y: 0.38),
                    .init(x: 0.22, y: 0.62), .init(x: 0.78, y: 0.62),
                    .init(x: 0.5, y: 0.8),
                    .init(x: 0.22, y: 0.98), .init(x: 0.78, y: 0.98)]
        default:
            return []
        }
    }
}