import SwiftUI

// MARK: - 待机

struct IdleStageView: View {
    var onStart: () -> Void

    @State private var showTutorial = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Button(action: onStart) {
                Text("开始")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .tracking(10)
                    .foregroundStyle(.white.opacity(0.92))
                    .frame(width: 196, height: 58)
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.30), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("startButton")

            Button {
                showTutorial = true
            } label: {
                Text("教学")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .tracking(6)
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.top, 18)
            .accessibilityIdentifier("tutorialButton")

            Spacer()

            Text("TOUCH")
                .font(.system(size: 10, weight: .semibold))
                .tracking(7)
                .foregroundStyle(.white.opacity(0.16))
                .padding(.bottom, 44)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView { showTutorial = false }
        }
    }
}

// MARK: - 黑屏选牌

struct SelectionStageView: View {
    var onSelect: (CGPoint, CGVector, CGSize) -> Void

    var body: some View {
        GeometryReader { geo in
            Color.black
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 6)
                        .onEnded { value in
                            onSelect(
                                value.startLocation,
                                CGVector(dx: value.translation.width, dy: value.translation.height),
                                geo.size
                            )
                        }
                )
        }
        .ignoresSafeArea()
        .accessibilityIdentifier("selectionStage")
    }
}

// MARK: - 锁定

struct LockedStageView: View {
    var onSimulateCover: () -> Void

    var body: some View {
        #if DEBUG
        stage.onLongPressGesture(minimumDuration: 1.6) {
            onSimulateCover()
        }
        #else
        stage
        #endif
    }

    private var stage: some View {
        Color.black
            .ignoresSafeArea()
            .accessibilityIdentifier("lockedStage")
    }
}