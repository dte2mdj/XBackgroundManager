//
//  XBackgroundManager.swift
//  Pods-XBackgroundManager_Example
//
//  Created by Xwg on 2020/3/31.
//

import Foundation
import MapKit

public class XBackgroundManager: NSObject {
    /// 管理者
    public static let shared = XBackgroundManager()
    /// 是否启用（默认：false）
    public var enabled: Bool = false {
        didSet {
            // 过虑相同值
            guard enabled != oldValue else { return }
            
            if enabled {
                // 检测配置
                guard isValidConfig else {
                    enabled = false
                    return
                }
                // 创建 locationManager
                locationManager = _makeLocationManager()
                // 增加生命周期监听
                _addAppLifeCircleNotification()
            } else {
                // 销毁 locationManager
                locationManager?.stopUpdatingLocation()
                locationManager = nil
                // 移除通知监听
                _removeAppLifeCircleNotification()
            }
        }
    }
    /// 是否开启日志（默认：true）
    public var isShowLog: Bool = true
    /// 系统版本
    public let systemVersion: Float = (UIDevice.current.systemVersion as NSString).floatValue
    
    /// CLLocationManager
    private var locationManager: CLLocationManager?
    /// 配置是否有效
    private var isValidConfig: Bool {
        
        if let info = Bundle.main.infoDictionary,
            info.keys.contains("NSLocationAlwaysAndWhenInUseUsageDescription"),
            info.keys.contains("NSLocationWhenInUseUsageDescription"),
            let bgModels = info["UIBackgroundModes"] as? [String],
            bgModels.contains("fetch"),
            bgModels.contains("location") {
            
            return true
        }
        
        log(
            """
            ******************* XBackgroundManager *******************
            *                    请检查 info 中配置
            *
            * <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
            * <string>AlwaysAndWhenInUseUsage描述</string>
            *     <key>NSLocationWhenInUseUsageDescription</key>
            * <string>InUseUsage描述</string>
            * <key>UIBackgroundModes</key>
            * <array>
            *     <string>fetch</string>
            *     <string>location</string>
            * </array>
            *
            **********************************************************
            """
        )
        
        return false
    }
    /// 是否授权后台
    private var isAuthBackground: Bool {
        // 是否已经启用
        guard enabled else { return false }
        // 是否已经授权
        let status = CLLocationManager.authorizationStatus()
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    private override init() {}
}

private extension XBackgroundManager {
    /// 开始
    func start() {
        guard isAuthBackground else { return }
        // 更新位置
        locationManager?.startUpdatingLocation()
    }
    /// 停止
    func stop() {
        guard isAuthBackground else { return }
        locationManager?.stopUpdatingLocation()
    }
    /// 打印日志
    func log(_ msg: String) {
        #if DEBUG
        if isShowLog { print(msg) }
        #endif
    }
    /// 创建 CLLocationManager
    func _makeLocationManager() -> CLLocationManager {
        // 创建定位管理对象
        let mgr = CLLocationManager()
        // 实时更新定位位置
        mgr.distanceFilter = kCLDistanceFilterNone
        // 位精确度
        mgr.desiredAccuracy = kCLLocationAccuracyBest
        // 设置代理
        mgr.delegate = self

        // 该模式是抵抗程序在后台被杀，申明不能够被暂停
        mgr.pausesLocationUpdatesAutomatically = false
        
        if #available(iOS 8.0, *) {
            /*
             有这么一种说法
             如果两个请求授权的方法都执行了，会出现以下情况
             1、requestWhenInUseAuthorization写在前面，第一次打开程序时请求授权，如果勾选了后台模式，进入后台会出现蓝条提示正在定位。
             当程序退出，第二次打开程序时requestAlwaysAuthorization 会再次请求授权。之后进入后台就不会出现蓝色状态栏。
             2、requestAlwaysAuthorization写在前面, requestWhenInUseAuthorization写在后面，只会在第一次打开程序时请求授权，
             因为requestAlwaysAuthorization得到的授权大于requestWhenInUseAuthorization得到的授权
             */
            mgr.requestAlwaysAuthorization()
            mgr.requestWhenInUseAuthorization()
        }
        
        if #available(iOS 9.0, *) {
            /*
            allowsBackgroundLocationUpdates：是否允许后台定位，默认为NO，只在iOS9.0之后起作用。
            设为YES时，必须保证Background Modes 中的Location updates处于选中状态，否则会抛出异常。
            在用户选择仅在使用应用期间获取位置权限的情况下，当应用进入后台，手机桌面顶部是否出现蓝条，这句代码起着关键性作用。
            首先，这句代码仅在requestWhenInUseAuthorization状态下才起作用，否则不起作用。
            当设为YES，就是允许在requestWhenInUseAuthorization此状态下，即使App进入后台，但是没杀死，那么就依然可以后台定位。
            并且顶部给个蓝条闪烁，目的是在于实时提醒用户：你这个App一直在获取你的位置信息哟，如果你感到不需要继续获取了，就杀死该App吧！所以一直蓝条闪烁。
            当设置为NO，就是在requestWhenInUseAuthorization状态下，App进入后台，立即停止后台定位。
            */
            mgr.allowsBackgroundLocationUpdates = true
        }
        
        return mgr
    }
    /// 增加 app 生命周期通知监听
    func _addAppLifeCircleNotification() {
        
        #if swift(>=4.2)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(app_willTerminateNotification),
                                               name: UIApplication.willTerminateNotification,
                                               object: UIApplication.shared)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(app_applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: UIApplication.shared)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(app_willEnterForegroundNotification),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: UIApplication.shared)
        #else
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(app_willTerminateNotification),
                                               name: .UIApplicationWillTerminate,
                                               object: UIApplication.shared)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(app_applicationDidEnterBackground),
                                               name: .UIApplicationDidEnterBackground,
                                               object: UIApplication.shared)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(app_willEnterForegroundNotification),
                                               name: .UIApplicationWillEnterForeground,
                                               object: UIApplication.shared)
        #endif
    }
    /// 移除 app 生命周期通知监听
    func _removeAppLifeCircleNotification() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension XBackgroundManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            
        case .notDetermined:
            log("未处理")
            manager.requestWhenInUseAuthorization()
        case .restricted:
            log("受限制")
            manager.requestWhenInUseAuthorization()
        case .denied:
            log("用户拒绝")
        case .authorizedAlways:
            log("前后台均可使用")
        case .authorizedWhenInUse:
            log("前台可用")
        @unknown default:
            log("未知")
        }
    }
}

// MARK: - App LifeCircle
extension XBackgroundManager {
    /// 将要被挂起H
    @objc func app_willTerminateNotification() {
        guard isAuthBackground else { return }
        // 打印日志
        log("app_willTerminateNotification")
        // 应用进入后台执行定位 保证进程不被系统kill
        UIApplication.shared.beginReceivingRemoteControlEvents()
        // 开始
        start()
    }
    
    /// 进入后台
    @objc func app_applicationDidEnterBackground() {
        guard isAuthBackground else { return }
        // 打印日志
        log("app_willEnterForegroundNotification")
        // 开始后台任务
        var bgTask: UIBackgroundTaskIdentifier?
        bgTask = UIApplication.shared.beginBackgroundTask {
            DispatchQueue.main.async {
                #if swift(>=4.2)
                if let task = bgTask, task != .invalid { bgTask = .invalid }
                #else
                if let task = bgTask, task != UIBackgroundTaskInvalid { bgTask = UIBackgroundTaskInvalid }
                #endif
            }
        }
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                #if swift(>=4.2)
                if let task = bgTask, task != .invalid { bgTask = .invalid }
                #else
                if let task = bgTask, task != UIBackgroundTaskInvalid { bgTask = UIBackgroundTaskInvalid }
                #endif
            }
        }
        // 开始
        start()
    }
    
    /// 进入前台
    @objc func app_willEnterForegroundNotification() {
        guard isAuthBackground else { return }
        // 打印日志
        log("app_willEnterForegroundNotification")
        // 停止
        stop()
    }
}
