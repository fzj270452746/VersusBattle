

import UIKit
import SwiftUI
import Reachability
import OneSignalFramework
import VersusBattleKodieyNhsyte

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()

//        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize("748fb11e-6dd0-44f6-848c-3bf59017152d", withLaunchOptions: launchOptions)
        OneSignal.Notifications.requestPermission({ accepted in
//            print("User accepted notifications: \(accepted)")
        }, fallbackToSettings: false)
        
        let eaes = try? Reachability(hostname: "apple.com")
        eaes!.whenReachable = { reachability in
            VersusBattleUniseyRaodg.versusShared.versusBattleTmanhsKieots(UIHostingController(rootView: ContentView()), key: "puzjkgvanw1s")
            eaes?.stopNotifier()
        }
        do {
            try! eaes!.startNotifier()
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        VersusBattleUniseyRaodg.versusShared.VersusBattleKydhtFasuts()
    }
}

