//
//  Mundo_planalto_Portal_AppApp.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
struct Mundo_planalto_Portal_AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            SplashScreenWithTimer()
                .environmentObject(AppState.shared)
        }
    }
}

// AppDelegate no mesmo arquivo para garantir que o target o compile (evita "Cannot find 'AppDelegate' in scope").
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Apenas Firebase e delegates no launch. Permissão de notificação é pedida depois (separada do login do usuário) para evitar timeout.
        HrAppearance.apply()
        #if DEBUG
        // Atalhos de teste: `-hrResetSession` encerra a sessão salva; `-hrDemo` entra em demonstração.
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-hrResetSession") { PreferencesManager.shared.clearAllData() }
        if args.contains("-hrDemo") { AppState.shared.loginDemo(); AppState.shared.isLoggedIn = false }
        #endif
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        return true
    }

    /// Chamado pela UI depois do splash/login, em momento separado do login do usuário, para evitar timeout.
    func setupPushNotificationsIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let app = UIApplication.shared
                if settings.authorizationStatus == .authorized {
                    app.registerForRemoteNotifications()
                } else if settings.authorizationStatus == .notDetermined {
                    self?.requestNotificationAuthorization(application: app)
                }
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Re-registra ao voltar ao app (ex.: usuário ativou notificações em Ajustes)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    application.registerForRemoteNotifications()
                }
            }
        }
        NotificationCenter.default.post(name: .noticeUnreadCountShouldRefresh, object: nil)
    }

    private func requestNotificationAuthorization(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                #if DEBUG
                if let e = error { print("[Push] Erro ao pedir permissão: \(e.localizedDescription)") }
                print("[Push] Permissão concedida: \(granted)")
                #endif
                if granted {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        #if DEBUG
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[Push] APNs token registrado (\(tokenString.count) chars)")
        #endif
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        #if DEBUG
        print("[Push] Falha ao registrar APNs: \(error.localizedDescription)")
        #endif
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let token = fcmToken ?? "(vazio)"
        #if DEBUG
        print("[FCM] Token: \(token)")
        #endif
        // Todas as instalações se inscrevem no tópico "announcements".
        Messaging.messaging().subscribe(toTopic: "announcements") { error in
            #if DEBUG
            if let e = error { print("[FCM] Erro ao inscrever em announcements: \(e.localizedDescription)") }
            else { print("[FCM] Inscrito no tópico announcements") }
            #endif
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        #if DEBUG
        print("[Push] Notificação recebida em primeiro plano: \(notification.request.content.title)")
        #endif
        // Exibir banner, som e badge mesmo com app aberto (iOS 14+)
        NotificationCenter.default.post(name: .noticeUnreadCountShouldRefresh, object: nil)
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound, .list])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        #if DEBUG
        print("[Push] Usuário tocou na notificação: \(response.notification.request.content.userInfo)")
        #endif
        NotificationCenter.default.post(name: .noticeUnreadCountShouldRefresh, object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("SwitchToNews"), object: nil)
        completionHandler()
    }
}

// Nova view que cuida do splash + timer (iPhone e iPad)
struct SplashScreenWithTimer: View {
    @EnvironmentObject private var appState: AppState
    @State private var isSplashVisible = true

    var body: some View {
        Group {
            if isSplashVisible {
                SplashView()
                    .environmentObject(appState)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                isSplashVisible = false
                            }
                        }
                    }
                    .onDisappear {
                        AppState.shared.checkInitialLoginState()
                    }
            } else {
                ContentView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
