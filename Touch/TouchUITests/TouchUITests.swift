import XCTest

final class TouchUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func snap(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// 跑完整一轮：开始 → 黑屏划 → 模拟遮挡 → 牌背出现 → 翻牌 → 断言牌名。
    private func runRoutine(
        from: CGVector,
        to: CGVector,
        expected: String,
        snapPrefix: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let app = XCUIApplication()
        app.launch()

        let startButton = app.buttons["startButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 10), "启动后应看到「开始」按钮", file: file, line: line)
        startButton.tap()
        Thread.sleep(forTimeInterval: 0.5)
        snap("\(snapPrefix)-01-arming")

        let a = app.coordinate(withNormalizedOffset: from)
        let b = app.coordinate(withNormalizedOffset: to)
        a.press(forDuration: 0.12, thenDragTo: b)
        Thread.sleep(forTimeInterval: 0.6)

        // 模拟「手挡住顶部」（真机上是距离传感器）
        let center = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        center.press(forDuration: 2.2)
        // 遮挡解锁后，牌应当直接出现（牌背朝上）
        XCTAssertTrue(app.otherElements["cardBack"].waitForExistence(timeout: 4), "松手后应直接出现牌背", file: file, line: line)
        snap("\(snapPrefix)-02-back")

        center.tap()
        Thread.sleep(forTimeInterval: 1.2)
        snap("\(snapPrefix)-03-face")

        let face = app.otherElements["cardFace"]
        XCTAssertTrue(face.waitForExistence(timeout: 3), "翻牌后应显示牌面", file: file, line: line)
        XCTAssertEqual(face.label, expected, "翻出来的应该就是刚才划出的牌", file: file, line: line)
    }

    /// 第 3 行第 1 列 + 右下→左上 = 黑桃 7
    func testSpades() {
        runRoutine(
            from: CGVector(dx: 0.24, dy: 0.52),
            to: CGVector(dx: 0.03, dy: 0.28),
            expected: "黑桃7",
            snapPrefix: "A"
        )
    }

    /// 第 2 行第 3 列 + 右上→左下 = 梅花 6
    func testClubs() {
        runRoutine(
            from: CGVector(dx: 0.76, dy: 0.28),
            to: CGVector(dx: 0.24, dy: 0.62),
            expected: "梅花6",
            snapPrefix: "B"
        )
    }

    /// 第 2 行第 1 列 + 左上→右下 = 方块 4
    func testDiamonds() {
        runRoutine(
            from: CGVector(dx: 0.24, dy: 0.28),
            to: CGVector(dx: 0.76, dy: 0.62),
            expected: "方块4",
            snapPrefix: "C"
        )
    }

    /// 教学页：打开、滚到底、关闭。
    func testTutorialPages() {
        let app = XCUIApplication()
        app.launch()

        let tutorial = app.buttons["tutorialButton"]
        XCTAssertTrue(tutorial.waitForExistence(timeout: 10))
        tutorial.tap()
        Thread.sleep(forTimeInterval: 0.8)
        snap("10-tutorial-top")

        for index in 0..<3 {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75))
                .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2)))
            Thread.sleep(forTimeInterval: 0.6)
            snap("11-tutorial-scroll-\(index + 1)")
        }

        let close = app.buttons["closeTutorial"]
        XCTAssertTrue(close.exists)
        close.tap()
        Thread.sleep(forTimeInterval: 0.6)
        XCTAssertTrue(app.buttons["startButton"].waitForExistence(timeout: 3))
    }
}