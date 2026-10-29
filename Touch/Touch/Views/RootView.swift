import SwiftUI
import UIKit

struct RootView: View {
    @StateObject private var model = AppModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            content
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle:
            IdleStageView(onStart: model.start)
                .transition(.opacity)

        case .arming:
            SelectionStageView(onSelect: model.commitSelection)
                .transition(.opacity)

        case .locked, .unlocking:
            LockedStageView(onSimulateCover: model.simulateCover)
                .transition(.opacity)

        case .revealed, .flipped:
            RevealStageView(
                card: model.card,
                faceUp: model.phase == .flipped,
                onTap: {
                    if model.phase == .revealed {
                        model.flip()
                    } else {
                        model.nextRound()
                    }
                },
                onLongPress: model.backToIdle
            )
            .transition(.opacity)
        }
    }
}

// MARK: - 牌背 / 牌面

struct RevealStageView: View {
    var card: Card
    var faceUp: Bool
    var onTap: () -> Void
    var onLongPress: () -> Void

    var body: some View {
        GeometryReader { geo in
            let size = CardLayout.size(in: geo.size)
            ZStack {
                Color.black

                FlipCardView(card: card, faceUp: faceUp, size: size)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
        }
        .ignoresSafeArea()
        .onLongPressGesture(minimumDuration: 1.6, perform: onLongPress)
    }
}