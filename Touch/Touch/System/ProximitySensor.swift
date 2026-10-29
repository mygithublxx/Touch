import UIKit

/// 距离传感器：手盖住手机顶部（听筒/前置摄像头一带）时触发。
/// 不开摄像头、没有相机权限弹窗、没有绿点。
final class ProximitySensor {
    var onChange: ((Bool) -> Void)?

    private var observer: NSObjectProtocol?
    private var active = false

    func start() {
        guard !active else { return }
        active = true

        observer = NotificationCenter.default.addObserver(
            forName: UIDevice.proximityStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onChange?(UIDevice.current.proximityState)
        }

        UIDevice.current.isProximityMonitoringEnabled = true
    }

    func stop() {
        guard active else { return }
        active = false

        UIDevice.current.isProximityMonitoringEnabled = false
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}