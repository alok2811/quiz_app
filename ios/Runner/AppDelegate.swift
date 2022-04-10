import UIKit
import Flutter
import Firebase
import Photos
import CallKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var callObserver: CXCallObserver!
    
    let preventAnnounceView = UIView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    override func application( _ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        GeneratedPluginRegistrant.register(with: self)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(hideScreen(notification:)), name: UIScreen.capturedDidChangeNotification, object: nil)
           
        callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil) 
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    override func applicationDidBecomeActive(_ application: UIApplication) {
        self.window.isHidden = false
    }
    override func applicationWillResignActive(_ application: UIApplication) {
        self.window.isHidden = true
    }
    
    @objc private func hideScreen(notification:Notification) -> Void {
        configurePreventView()
        if UIScreen.main.isCaptured {
            window?.addSubview(preventAnnounceView)
        } else {
            preventAnnounceView.removeFromSuperview()
        }
    }
    
    private func configurePreventView() {
        preventAnnounceView.backgroundColor = .black
        let preventAnnounceLabel = configurePreventAnnounceLabel()
        preventAnnounceView.addSubview(preventAnnounceLabel)
    }
    
    private func configurePreventAnnounceLabel() -> UILabel {
        let preventAnnounceLabel = UILabel()
        preventAnnounceLabel.text = "Can't record screen"
        preventAnnounceLabel.font = .boldSystemFont(ofSize: 30)
        preventAnnounceLabel.numberOfLines = 0
        preventAnnounceLabel.textColor = .white
        preventAnnounceLabel.textAlignment = .center
        preventAnnounceLabel.sizeToFit()
        preventAnnounceLabel.center.x = self.preventAnnounceView.center.x
        preventAnnounceLabel.center.y = self.preventAnnounceView.center.y
        
        return preventAnnounceLabel
    }
}
extension AppDelegate: CXCallObserverDelegate {
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Call Disconnected")
        }
        
        if call.isOutgoing == true && call.hasConnected == false {
            print("call Dialing")
        }
        
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("call Incoming")
        }
        
        if call.hasConnected == true && call.hasEnded == false {
            print("Call Connected")
        }
    }
}
