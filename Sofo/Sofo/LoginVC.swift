//
//  ViewController.swift
//  Sofo
//
//  Created by Gurudeeksha  L on 28/11/17.
//  Copyright © 2017 Twixt. All rights reserved.
//

import UIKit
import GoogleSignIn
import Alamofire
//import TwitterKit

class LoginVC: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Singleton.sharedInstance.loginVC = self
        
        loginButton.layer.cornerRadius = 30
        
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        loginButton.layer.shadowRadius = 4
        loginButton.layer.masksToBounds = false
        loginButton.layer.shadowOpacity = 0.2
                // Do any additional setup after loading the view, typically from a nib.
        
        let usernamePlaceholder = NSAttributedString(string: "Username", attributes: [ NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.7) ])
        userNameField.attributedPlaceholder = usernamePlaceholder
        
        let passwordPlaceholder = NSAttributedString(string: "Password", attributes: [ NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.7) ])
        passwordField.attributedPlaceholder = passwordPlaceholder
        
        
        
        
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        let notificationName = Notification.Name("GoogleLogin")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.googleLoginNotification(_:)), name: notificationName, object: nil)
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //
    @IBAction func loginAction(_ sender: UIButton) {
        
        if self.userNameField.text != nil && self.passwordField.text != nil {       //validation to avoid null pointer exception
            let strURL = "https://sofo.demosrv.co/api/v1/oauth/token"               //url to get token
            let url = URL.init(string: strURL as String)
            let strParameters = NSString.init(format: "username=%@%password=%@", userNameField.text!, passwordField.text!)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"                                             //request method type
            request.httpBody = strParameters.data(using: String.Encoding.utf8.rawValue)
            //api call for getting token -> authorization
            Alamofire.request(request).responseJSON(completionHandler: { (response: DataResponse<Any>) in
                switch(response.result){
                case .success(_):
                    print("success")
                    self.callAfterSuccessfulLogIn() //function call after successful authorization.
                    break
                case .failure(_):
                    print("failed")
                    break

                }
            })
    
       // self.startLoading()
        }
        
        /*
         what error is showing "JSON could not be serialized because of error:\nThe data couldn’t be read because it isn’t in the correct format"
         if you read the last statement of this sentence which means that I am not sending correct format
         now there is a application named as "Postman"
         I think we need to verify API
         I am not receiving any kind of data except for this error.
         i am just receiving this error "JSON could not be serialized because of error:\nThe data couldn’t be read because it isn’t in the correct format"
         */
        
    }
    
    private func callAfterSuccessfulLogIn() {
        let ws = WebServices()
        ws.getHistoryKeys(searchterm: "") { (result) in
        switch result {
            case .success(let dict) :
                print(dict)
        
                let sb = UIStoryboard(name: "LoggedIn", bundle: nil)
                let vc : DashboardVC = sb.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
                self.pushToViewControllerFadeOut(controller: vc)
        
            break
            case .failure() :
            break
        }
    
    }
    }
    
    @IBAction func registerAction(_ sender: UIButton) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc : RegisterVC = sb.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        self.pushToViewController(controller: vc, direction: .rightToLeft)
        
    }
    
    
    @IBAction func forgotAction(_ sender: UIButton) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc : Forgot1VC = sb.instantiateViewController(withIdentifier: "Forgot1VC") as! Forgot1VC
        self.pushToViewController(controller: vc, direction: .bottomToTop)
        
    }
    
    
    @IBAction func fbLoginAction(_ sender: UIButton) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                print(result?.isCancelled)
                
                if(result?.isCancelled)!
                {
                    
                }
                else {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        
                    }
                    self.getFBUserData()
                }
            }
        }
        
        
    }
    
    
    @IBAction func gpLoginAction(_ sender: UIButton) {
        
        GIDSignIn.sharedInstance().signIn()
        
    }
    @IBAction func twLoginAction(_ sender: UIButton) {
        
//        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
//            if (session != nil) {
//                let sb = UIStoryboard(name: "LoggedIn", bundle: nil)
//                let vc : DashboardVC = sb.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
//                self.navigationController?.pushViewController(vc, animated: true)
//                print("signed in as \(session?.userName)");
//            } else {
//                print("error: \(error?.localizedDescription)");
//            }
//        })
        
    }
    
    
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, cover"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    print(result)
                    
                    let dict : NSDictionary = (result as? NSDictionary)!
                    let fbId : String = dict.object(forKey: "id") as! String
                    
                    
                    let sb = UIStoryboard(name: "LoggedIn", bundle: nil)
                    let vc : DashboardVC = sb.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
                    self.pushToViewController(controller: vc, direction: .rightToLeft)

                    
                    
                    
                    //                    self.loaginWithFaceBookDetails(dict: result as! NSDictionary)
                }
            })
        }
    }
    
    
    func googleLoginNotification(_ notification: Notification) {
        
        let sb = UIStoryboard(name: "LoggedIn", bundle: nil)
        let vc : DashboardVC = sb.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardVC
        self.pushToViewController(controller: vc, direction: .rightToLeft)

        
    }


}

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using:.utf8,allowLossyConversion: false)
        return request
    }
}

