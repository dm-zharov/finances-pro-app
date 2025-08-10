//
//  MailButton.swift
//  Finances
//
//  Created by Dmitriy Zharov on 28.11.2023.
//

#if os(iOS)
import SwiftUI
import MessageUI

struct MailComposeView: UIViewControllerRepresentable {
    enum Result: Int {
        case cancelled = 0
        case saved = 1
        case sent = 2
        case failed = 3
    }

    let onCompletion: (Result) -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = context.coordinator
        
        viewController.setSubject("Finances")
        viewController.setToRecipients(["contact@zharov.dev"])
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onCompletion: (Result) -> Void
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            switch result {
            case .cancelled:
                onCompletion(.cancelled)
            case .saved:
                onCompletion(.saved)
            case .sent:
                onCompletion(.sent)
            case .failed:
                onCompletion(.failed)
            @unknown default:
                return
            }
        }
        
        init(onCompletion: @escaping (Result) -> Void) {
            self.onCompletion = onCompletion
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onCompletion: onCompletion)
    }
}

struct MailButton: View {
    @State private var sendMail: Bool = false
    
    var body: some View {
        Button {
            sendMail.toggle()
        } label: {
            Label {
                Text("Contact Developer")
            } icon: {
                SettingImage(.envelope)
            }
        }
        .sheet(isPresented: $sendMail) {
            MailComposeView { result in
                sendMail = false
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    List {
        MailButton()
    }
}
#endif
