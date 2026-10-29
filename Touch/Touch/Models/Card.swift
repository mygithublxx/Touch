import CoreGraphics
import Foundation

// MARK: - 花色

enum Suit: Int, CaseIterable, Codable {
    case spades
    case hearts
    case clubs
    case diamonds

    var glyph: String {
        switch self {
        case .spades: return "♠"
        case .hearts: return "♥"
        case .clubs: return "♣"
        case .diamonds: return "♦"
        }
    }

    var name: String {
        switch self {
        case .spades: return "黑桃"
        case .hearts: return "红桃"
        case .clubs: return "梅花"
        case .diamonds: return "方块"
        }
    }

    var isRed: Bool { self == .hearts || self == .diamonds }
}

// MARK: - 点数

enum Rank: Int, CaseIterable, Codable {
    case ace = 1
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king

    /// 1 → A, 11 → J, 12 → Q, 13 → K
    var label: String {
        switch self {
        case .ace: return "A"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        default: return String(rawValue)
        }
    }
}

// MARK: - 一张牌

struct Card: Equatable {
    var rank: Rank
    var suit: Suit

    var displayName: String { "\(suit.name)\(rank.label)" }

    static let placeholder = Card(rank: .ace, suit: .spades)
}

// MARK: - 屏幕网格 → 牌

/// 屏幕分成 5 行 3 列：
///
///     ┌────┬────┬────┐
///     │ 1  │ 2  │ 3  │
///     │ 4  │ 5  │ 6  │
///     │ 7  │ 8  │ 9  │
///     │ 10 │ 11 │ 12 │
///     │      K        │
///     └────┴────┴────┘
///
/// 点数看**手指落点**所在格子，花色看**滑动方向**。
enum DeckGrid {
    static let rows = 5
    static let columns = 3

    /// 一次滑动能否被识别为一次选牌的最低位移。
    static let minimumTravel: CGFloat = 34

    static func card(
        start: CGPoint,
        translation: CGVector,
        boardSize: CGSize,
        minimumTravel: CGFloat = DeckGrid.minimumTravel
    ) -> Card? {
        guard boardSize.width > 0, boardSize.height > 0 else { return nil }
        guard hypot(translation.dx, translation.dy) >= minimumTravel else { return nil }

        let cellWidth = boardSize.width / CGFloat(columns)
        let cellHeight = boardSize.height / CGFloat(rows)

        let column = min(columns - 1, max(0, Int(start.x / cellWidth)))
        let row = min(rows - 1, max(0, Int(start.y / cellHeight)))

        let rank: Rank
        if row == rows - 1 {
            // 最后一行整行都是 K
            rank = .king
        } else {
            guard let value = Rank(rawValue: row * columns + column + 1) else { return nil }
            rank = value
        }

        // 右下 → 左上 黑桃 / 左下 → 右上 红桃 / 右上 → 左下 方块 / 左上 → 右下 梅花
        let suit: Suit
        switch (translation.dx < 0, translation.dy < 0) {
        case (true, true): suit = .spades
        case (false, true): suit = .hearts
        case (false, false): suit = .diamonds
        case (true, false): suit = .clubs
        }

        return Card(rank: rank, suit: suit)
    }

    /// 调试用：格子的中心点（归一化 0…1）。
    static func cellCenter(row: Int, column: Int) -> CGPoint {
        CGPoint(
            x: (CGFloat(column) + 0.5) / CGFloat(columns),
            y: (CGFloat(row) + 0.5) / CGFloat(rows)
        )
    }
}