//
//  AlertView.swift
//  MRZ
//
//  Created by Kirill G on 9/12/19.
//  Copyright © 2019 k-ios. All rights reserved.
//

import Foundation
import UIKit


class AlertView {
  
  enum Result {
    case success
    case failure(ALRTError)
  }
  
  enum ALRTError: Error {
    case alertControllerNil
    case popoverNotSet
    case sourceViewControllerNil
  }
  
  var alert: UIAlertController?
  
  fileprivate init() {}
  
  fileprivate init(title: String?, message: String?, preferredStyle: UIAlertController.Style) {
    self.alert = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: preferredStyle)
    
    let action = UIAlertAction(title: "OK", style: .destructive) { action in
      self.alert = nil
    }
    
    self.alert?.addAction(action)
  }
  
  open class func create(_ style: UIAlertController.Style,
                         title: String? = nil,
                         message: String? = nil) -> AlertView {
    
    return AlertView(title: title, message: message, preferredStyle: style)
  }
  
  
  open func show(_ viewControllerToPresent: UIViewController? = nil,
                 animated: Bool = true,
                 completion: @escaping ((AlertView.Result) -> Void) = { _ in } ) {
    
    guard let alert = self.alert else {
      completion(.failure(.alertControllerNil))
      return
    }
    
    if UIDevice.current.userInterfaceIdiom == .pad &&
      alert.preferredStyle == .actionSheet &&
      alert.popoverPresentationController?.sourceView == nil &&
      alert.popoverPresentationController?.barButtonItem == nil {
      completion(.failure(.popoverNotSet))
      return
    }
    
    let sourceViewController: UIViewController? = {
      let viewController = viewControllerToPresent ?? UIApplication.shared.topMostViewController()
      if let navigationController = viewController as? UINavigationController {
        return navigationController.visibleViewController
      }
      return viewController
    }()
    
    if let sourceViewController = sourceViewController {
      DispatchQueue.main.async {
        sourceViewController.present(alert, animated: animated) {
          completion(.success)
        }
      }
      
    } else {
      completion(.failure(.sourceViewControllerNil))
    }
  }
  
}

private extension UIViewController {
  func topMostViewController() -> UIViewController {
    
    if let presented = self.presentedViewController {
      return presented.topMostViewController()
    }
    
    if let navigation = self as? UINavigationController {
      return navigation.visibleViewController?.topMostViewController() ?? navigation
    }
    
    if let tab = self as? UITabBarController {
      return tab.selectedViewController?.topMostViewController() ?? tab
    }
    
    return self
  }
}

private extension UIApplication {
  func topMostViewController() -> UIViewController? {
    guard let keyWindow = windows.last else {
      return nil
    }
    return keyWindow.rootViewController?.topMostViewController()
  }
}
