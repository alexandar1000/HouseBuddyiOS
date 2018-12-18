//
//  AppDelegate.swift
//  HouseBuddy
//
//  Created by A.S. Janjanin on 22/11/2018.
//  Copyright © 2018 HouseBuddy. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
	var currentUser: User?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		FirebaseApp.configure()
		
		GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
		GIDSignIn.sharedInstance().delegate = self
		return true
	}	
	
	@available(iOS 9.0, *)
	func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
		-> Bool {
			return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
	}
	
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
	}
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
		// ...
		if let error = error {
			print("Error occurred \(error.localizedDescription)")
			return
		}
		
		guard let authentication = user.authentication else {
			return
		}
		let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
		// ...
		Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
			if let error = error {
				print("Error occurred \(error.localizedDescription)")
				return
			}
			
			self.currentUser = Auth.auth().currentUser
			
			// Access the storyboard and fetch an instance of the view controller
			let storyboard = UIStoryboard(name: "Main", bundle: nil);
			let viewController: HomeViewController = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController;
			
			// Then push that view controller onto the navigation stack
			let rootViewController = self.window!.rootViewController as! UINavigationController;
			rootViewController.pushViewController(viewController, animated: true);

//			if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home") as? HomeViewController {
//				if let window = self.window, let rootViewController = window.rootViewController {
//					var currentController = rootViewController
//					while let presentedController = currentController.presentedViewController {
//						currentController = presentedController
//					}
//					currentController.present(controller, animated: true, completion: nil)
//					self.performSegue(withIdentifier: "alreadyLoggedIn", sender: self)
//				}
//			}
		}
	}
	
	func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
		// Perform any operations when the user disconnects from app here.
		// ...
	}

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// Closes the keyboard when pressed anywhere. If deleting the class, move the following code to another class
extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}
