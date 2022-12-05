//
//  NotificationsService.swift
//  TODOList
//
//  Created by Dmytro Hetman on 29.11.2022.
//

import UserNotifications
import UIKit

final class NotificationsService: NSObject {
    
    enum Error: Swift.Error {
        case invalidKey
    }
    
    enum NotificationType {
        case remote
        case local
    }
    
    class Handler {
        
        var key: String
        var handler: (Any) -> Void
        
        init(for key: String, _ handler: @escaping (Any) -> Void) {
            self.key = key
            self.handler = handler
        }
        
    }
    
    private lazy var mapOfSubscribers: NSMapTable<AnyObject, Handler> = .weakToStrongObjects()
    
    static var shared: NotificationsService = .init()
    
    private var center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
    }
    
    func authorize(_ options: UNAuthorizationOptions, for type: NotificationType, completion: ((Bool) -> Void)?) {
        center.requestAuthorization(options: options) { granted, error in
            if type == .remote && granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            self.center.delegate = self
            completion?(granted)
        }
    }
    
    func showLocal(_ userInfo: [AnyHashable: Any]) {
        let emptyLocalNotification = (userInfo["aps"] as? [String: Any])?["alert"] as? [String: String]
        
        let content = UNMutableNotificationContent()
        content.title = emptyLocalNotification?["title"] ?? ""
        content.subtitle = "Subtitle"
//        content.subtitle = emptyLocalNotification?["subtitle"] ?? ""
        content.body = emptyLocalNotification?["body"] ?? ""
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        
        let request = UNNotificationRequest.init(identifier: "notification", content: content, trigger: trigger)
        center.add(request) {
            error in
            print(error?.localizedDescription ?? "untitled error!")
        }
    }
    
    @discardableResult
    func decode<T: Codable>(_ type: T.Type, by key: String, from userInfo: [AnyHashable: Any]) throws -> T {
        if let object = userInfo[key] {
            let data = try JSONSerialization.data(withJSONObject: object)
            let result = try JSONDecoder().decode(type, from: data)
            
            (mapOfSubscribers.objectEnumerator()?.allObjects.first(where: { ($0 as? Handler)?.key == key }) as? Handler)?.handler(result)
            
            return result
        }
        throw Error.invalidKey
    }
    
    func addListener(_ listener: AnyObject, for key: String, handler: @escaping (Any) -> Void ) {
        mapOfSubscribers.setObject(Handler(for: key, handler), forKey: listener)
    }
    
}

extension NotificationsService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let aps = (notification.request.content.userInfo["aps"] as? [String: Any]) else { return }
        guard let threadId = aps["thread-id"] as? String else { return }
        if threadId == "addTaskRemotely" {
            _ = try? NotificationsService.shared.decode(TaskFromNotification.self, by: "task", from: notification.request.content.userInfo)
            completionHandler([.banner, .sound, .badge])
        } else {
            showLocal(notification.request.content.userInfo)
            completionHandler([.banner, .badge])
        }
    }
    
}
