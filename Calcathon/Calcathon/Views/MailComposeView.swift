//
//  MailComposeView.swift
//  Calcathon
//
//  Native Mail compose sheet for "Report a Problem". Falls back to a mailto:
//  link (opening whatever mail client is installed) when the device has no
//  Mail account configured, since MFMailComposeViewController requires one.
//

import SwiftUI
import MessageUI
import UIKit

struct MailComposeView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String
    var onFinish: () -> Void = {}

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.setToRecipients([recipient])
        controller.setSubject(subject)
        controller.setMessageBody(body, isHTML: false)
        controller.mailComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onFinish: onFinish) }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onFinish: () -> Void
        init(onFinish: @escaping () -> Void) { self.onFinish = onFinish }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: onFinish)
        }
    }
}

enum IssueReport {
    static let recipient = "jeet.oza.trioza@outlook.com"
    static let subject = "Calcathon Problem Report"

    /// Pre-filled diagnostics so reports are actionable without back-and-forth.
    static func body(uid: String?) -> String {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return """


        ---
        Describe the issue above this line.

        App version: \(appVersion) (\(buildNumber))
        iOS version: \(UIDevice.current.systemVersion)
        Device: \(UIDevice.current.model)
        Account ID: \(uid ?? "not signed in")
        """
    }

    /// Opens the system Mail app pre-addressed, for devices with no Mail
    /// account configured (where MFMailComposeViewController can't be used).
    static func mailtoURL(uid: String?) -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = recipient
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body(uid: uid)),
        ]
        return components.url
    }
}
