import SwiftUI

/// 一次表演的完整状态机。
enum Phase: Equatable {
    case idle        // 待机，显示「开始」
    case arming      // 全黑，等待选牌
    case locked      // 已记录牌，触摸无响应
    case unlocking   // 手挡住顶部（系统熄屏），松手即出牌
    case revealed    // 牌背朝上
    case flipped     // 牌面朝上
}

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var card: Card = .placeholder

    private let proximity = ProximitySensor()

    init() {
        #if DEBUG
        applyDemoLaunchArgument()
        #endif
    }

    #if DEBUG
    /// 仅用于截图预览：`-demoPhase idle|arming|back|face`
    private func applyDemoLaunchArgument() {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-demoPhase"),
              index + 1 < arguments.count else { return }

        card = Card(rank: .seven, suit: .spades)
        switch arguments[index + 1] {
        case "arming": phase = .arming
        case "back": phase = .revealed
        case "face": phase = .flipped
        default: phase = .idle
        }
    }
    #endif

    // MARK: - 流程

    func start() {
        card = .placeholder
        withAnimation(.easeInOut(duration: 0.22)) { phase = .arming }
    }

    func commitSelection(start: CGPoint, translation: CGVector, boardSize: CGSize) {
        guard phase == .arming else { return }
        guard let picked = DeckGrid.card(start: start, translation: translation, boardSize: boardSize) else {
            // 太短或方向不成立：忽略，允许再划一次（屏幕全黑，观众看不到）
            return
        }
        card = picked
        withAnimation(.easeInOut(duration: 0.18)) { phase = .locked }
        beginWatchingProximity()
    }

    func flip() {
        guard phase == .revealed else { return }
        withAnimation(.spring(response: 0.62, dampingFraction: 0.84)) { phase = .flipped }
    }

    func nextRound() {
        guard phase == .flipped else { return }
        start()
    }

    func backToIdle() {
        proximity.stop()
        withAnimation(.easeInOut(duration: 0.22)) { phase = .idle }
    }

    // MARK: - 遮挡解锁

    private func beginWatchingProximity() {
        proximity.onChange = { [weak self] covered in
            self?.handleProximity(covered)
        }
        proximity.start()
    }

    private func handleProximity(_ covered: Bool) {
        switch (phase, covered) {
        case (.locked, true):
            // 手盖住顶部：系统会立刻熄屏，这里只改状态，画面本来就是黑的
            phase = .unlocking
        case (.unlocking, false):
            // 手移开：系统亮屏，牌直接出现在屏幕中央
            proximity.stop()
            withAnimation(.easeOut(duration: 0.28)) { phase = .revealed }
        default:
            break
        }
    }

    /// 仅调试用：模拟「手挡住顶部」。模拟器没有距离传感器。
    func simulateCover() {
        #if DEBUG
        guard phase == .locked else { return }
        handleProximity(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            self?.handleProximity(false)
        }
        #endif
    }
}