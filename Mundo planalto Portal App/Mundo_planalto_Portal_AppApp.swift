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
            SplashScreenWithTimer()   // nova view que gerencia o timer
        }
    }
}

// AppDelegate no mesmo arquivo para garantir que o target o compile (evita "Cannot find 'AppDelegate' in scope").
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        requestNotificationAuthorization(application: application)
        // Se já tiver permissão (ex.: segundo launch), registra para push na hora
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    application.registerForRemoteNotifications()
                }
            }
        }
        return true
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
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        #if DEBUG
        print("[Push] Notificação recebida em primeiro plano: \(notification.request.content.title)")
        #endif
        // Exibir banner, som e badge mesmo com app aberto (iOS 14+)
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
        completionHandler()
    }
}

// Nova view que cuida do splash + timer
struct SplashScreenWithTimer: View {
    @State private var isSplashVisible = true
    
    var body: some View {
        if isSplashVisible {
            SplashView()
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
}
