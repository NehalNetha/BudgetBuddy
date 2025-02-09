//
//  Utilities.swift
//  NewHomeWorkOne
//
//  Created by NehalNetha on 04/07/24.
//

import Foundation
import UIKit

final class Utilities{
    static let shared = Utilities()
    private init() {}
    
    
    @available(iOS 13.0, *)
        static private func getWindowScene() -> UIWindowScene? {
            return UIApplication.shared.connectedScenes
                .first { $0.activationState == .foregroundActive && $0 is UIWindowScene } as? UIWindowScene
        }
        
        static private func rootViewController() -> UIViewController? {
            if #available(iOS 13.0, *) {
                return getWindowScene()?
                    .windows
                    .first { $0.isKeyWindow }?
                    .rootViewController
            } else {
                return UIApplication.shared.windows
                    .first { $0.isKeyWindow }?
                    .rootViewController
            }
        }
   
        
    @MainActor static func topViewController(controller: UIViewController? = nil) -> UIViewController? {
            let controller = controller ?? rootViewController()
            
            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
                }
            }
            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }
            return controller
        }
        
    
    
}
