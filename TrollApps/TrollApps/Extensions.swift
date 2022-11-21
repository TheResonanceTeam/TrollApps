//
//  Extensions.swift
//  TrollApps
//
//  Created by Анохин Юрий on 11.11.2022.
//

import SwiftUI
import CoreServices
import Foundation

public struct appstorestyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.semibold))
            .foregroundColor(Color.accentColor)
            .padding(.vertical, 12)
            .frame(width: 70, height: 29, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .fill(Color.gray)
                    .opacity(0.2)
            )
            .opacity(configuration.isPressed ? 0.2 : 1.0)
    }
}

public struct somebuttonstyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.body.weight(.medium))
            .foregroundColor(Color.accentColor)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14.0, style: .continuous)
                    .fill(Color.gray)
                    .opacity(0.2)
                )
            .opacity(configuration.isPressed ? 0.2 : 1.0)
    }
}

func GetApps() -> [String] {
    var apps: [String] = []
    for app in LSApplicationWorkspace().allInstalledApplications() as! [LSApplicationProxy] {
        apps.append((NSDictionary(contentsOfFile: "\(app.bundleURL.path)/Info.plist")?.value(forKey: "CFBundleIdentifier") ?? "Unknown") as! String)
    }
    return apps
}

func IsAppInstalled(_ BundleID: String) -> Bool {
    return GetApps().contains(BundleID)
}

func OpenApp(_ BundleID: String) {
    guard let obj = objc_getClass("LSApplicationWorkspace") as? NSObject else { return }
    let workspace = obj.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject
    workspace?.perform(Selector(("openApplicationWithBundleID:")), with: BundleID)
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

var currentUIAlertController: UIAlertController?

extension UIApplication {
    func dismissAlert(animated: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController?.dismiss(animated: animated)
        }
    }
    func alert(title: String = "Aler", body: String, animated: Bool = true, withButton: Bool = true) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if withButton { currentUIAlertController?.addAction(.init(title: "OK", style: .cancel)) }
            self.present(alert: currentUIAlertController!)
        }
    }
    func confirmAlert(title: String = "Alert", body: String, onOK: @escaping () -> (), noCancel: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if !noCancel {
                currentUIAlertController?.addAction(.init(title: "Cancel", style: .cancel))
            }
            currentUIAlertController?.addAction(.init(title: "OK", style: noCancel ? .cancel : .default, handler: { _ in
                onOK()
            }))
            self.present(alert: currentUIAlertController!)
        }
    }
    func change(title: String = "Alert", body: String) {
        DispatchQueue.main.async {
            currentUIAlertController?.title = title
            currentUIAlertController?.message = body
        }
    }
    
    func present(alert: UIAlertController) {
        if var topController = self.windows[0].rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alert, animated: true)
        }
    }
}
