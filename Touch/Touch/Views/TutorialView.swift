import SwiftUI

// MARK: - 教学页

struct TutorialView: View {
    var onClose: () -> Void

    private let hair = Color.white.opacity(0.10)

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 44) {
                    header
                    gridSection
                    directionSection
                    flowSection
                    tipsSection
                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 26)
                .padding(.top, 8)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            topBar
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
    }

    // MARK: 顶栏

    private var topBar: some View {
        HStack {
            Text("教学")
                .font(.system(size: 15, weight: .semibold))
                .tracking(6)
                .foregroundStyle(.white.opacity(0.55))
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(0.07)))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("closeTutorial")
        }
        .padding(.horizontal, 26)
        .padding(.top, 6)
        .padding(.bottom, 14)
        .background(
            LinearGradient(colors: [.black, .black.opacity(0)], startPoint: .top, endPoint: .bottom)
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TOUCH")
                .font(.system(size: 10, weight: .semibold))
                .tracking(7)
                .foregroundStyle(.white.opacity(0.25))
            Text("在黑屏上划一下，\n就是一张牌。")
                .font(.system(size: 26, weight: .semibold))
                .lineSpacing(6)
                .foregroundStyle(.white)
        }
    }

    // MARK: 一、分区

    private var gridSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("01", "手指落点 = 点数")

            HStack(alignment: .top, spacing: 22) {
                GridDiagram()
                    .frame(width: 150, height: 300)

                VStack(alignment: .leading, spacing: 14) {
                    Text("屏幕均分成 5 行 3 列。")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.85))

                    Text("手指按下的位置落在哪一格，点数就是几。最后一行整行都算 K。")
                        .font(.system(size: 13))
                        .lineSpacing(5)
                        .foregroundStyle(.white.opacity(0.5))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("1 = A    11 = J")
                        Text("12 = Q   13 = K")
                    }
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.35))
                }
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: 二、方向

    private var directionSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("02", "滑动方向 = 花色")

            VStack(spacing: 0) {
                directionRow("arrow.up.left", "右下 → 左上", "黑桃", "♠", isRed: false)
                divider
                directionRow("arrow.up.right", "左下 → 右上", "红桃", "♥", isRed: true)
                divider
                directionRow("arrow.down.left", "右上 → 左下", "梅花", "♣", isRed: false)
                divider
                directionRow("arrow.down.right", "左上 → 右下", "方块", "♦", isRed: true)
            }
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white.opacity(0.04)))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(hair, lineWidth: 1))

            Text("13 个点位 × 4 个花色 = 52 张，全部划得出来。")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.35))
        }
    }

    private var divider: some View {
        Rectangle().fill(hair).frame(height: 1).padding(.leading, 62)
    }

    private func directionRow(_ symbol: String, _ path: String, _ name: String, _ glyph: String, isRed: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
                .frame(width: 34, height: 34)
                .background(Circle().fill(Color.white.opacity(0.06)))

            Text(path)
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))

            Spacer(minLength: 8)

            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))

            Text(glyph)
                .font(.system(size: 17))
                .foregroundStyle(isRed ? Color(red: 0.85, green: 0.24, blue: 0.28) : Color.white.opacity(0.9))
                .frame(width: 22)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    // MARK: 三、流程

    private var flowSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("03", "完整流程")

            VStack(alignment: .leading, spacing: 22) {
                step("1", "点「开始」", "屏幕立刻变成全黑，什么也看不到。")
                step("2", "划一条对角线", "落点定点数，方向定花色。划完立刻锁定。")
                step("3", "手掌盖住手机顶部", "听筒那一片，挡一下再松开。这一下是解锁，观众看来只是随手一挡。")
                step("4", "牌直接出现在中央", "松手亮屏的那一刻，一张牌背朝上的牌已经摆在屏幕中间。")
                step("5", "点一下翻牌", "牌翻过来，正是刚才划出的那张。")
                step("6", "再点一下，回到黑屏", "可以直接开始下一轮，不用退出。")
            }
        }
    }

    private func step(_ number: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(number)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.3))
                .frame(width: 18, height: 18)
                .overlay(Circle().strokeBorder(hair, lineWidth: 1))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.92))
                Text(detail)
                    .font(.system(size: 13))
                    .lineSpacing(5)
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
    }

    // MARK: 贴士

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("04", "几个要点")

            VStack(alignment: .leading, spacing: 12) {
                tip("划太短（少于 34pt）会被忽略，可以再划一次 —— 屏幕全黑，观众看不到你划了几次。")
                tip("黑屏阶段没有任何提示音、震动或画面变化，零反馈就是零破绽。")
                tip("盲定位靠肌肉记忆，建议先用亮屏的网格图对着练几遍，记住每个格子在屏幕上的相对位置。")
                tip("表演中途想退出：长按牌面 1.6 秒，回到首页。")
            }
        }
    }

    private func tip(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 4, height: 4)
                .padding(.top, 7)
            Text(text)
                .font(.system(size: 13))
                .lineSpacing(5)
                .foregroundStyle(.white.opacity(0.45))
        }
    }

    private func sectionTitle(_ number: String, _ title: String) -> some View {
        HStack(spacing: 10) {
            Text(number)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.22))
            Rectangle().fill(hair).frame(width: 18, height: 1)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .tracking(3)
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - 屏幕分区图

struct GridDiagram: View {
    private let hair = Color.white.opacity(0.12)
    private let dashHair = Color.white.opacity(0.10)

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { column in
                        Text("\(row * 3 + column + 1)")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        if column < 2 {
                            Rectangle().fill(dashHair).frame(width: 1)
                        }
                    }
                }
                .frame(maxHeight: .infinity)

                Rectangle().fill(dashHair).frame(height: 1)
            }

            Text("K")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.85))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.035))
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(hair, lineWidth: 1)
        )
    }
}