//
//  LoginViewController.swift
//  V2ex-Swift
//
//  Created by huangfeng on 1/22/16.
//  Copyright © 2016 Fin. All rights reserved.
//

import UIKit
import OnePasswordExtension
import Kingfisher
import SVProgressHUD
import Alamofire
import ObjectMapper

import JWTDecode

public typealias LoginSuccessHandel = (String) -> Void

class LoginViewController: UIViewController {

    var successHandel:LoginSuccessHandel?

    let backgroundImageView = UIImageView()
    let frostedView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let userNameTextField = UITextField()
    let passwordTextField = UITextField()
    let codeTextField = UITextField()
    let codeImageView = UIImageView()
    let loginButton = UIButton()
    let cancelButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        //初始化界面
        self.setupView()

        //初始化1Password
        if OnePasswordExtension.shared().isAppExtensionAvailable() {
            let onepasswordButton = UIImageView(image: UIImage(named: "onepassword-button")?.withRenderingMode(.alwaysTemplate))
            onepasswordButton.isUserInteractionEnabled = true
            onepasswordButton.frame = CGRect(x: 0, y: 0, width: 34, height: 22)
            onepasswordButton.contentMode = .scaleAspectFit
            onepasswordButton.tintColor = UIColor.white
            self.passwordTextField.rightView = onepasswordButton
            self.passwordTextField.rightViewMode = .always
            onepasswordButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.findLoginFrom1Password)))
        }

        //绑定事件
        self.loginButton.addTarget(self, action: #selector(LoginViewController.loginClick(_:)), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(LoginViewController.cancelClick), for: .touchUpInside)
    }
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 2, animations: { () -> Void in
            self.backgroundImageView.alpha=1;
        }) 
        UIView.animate(withDuration: 20, animations: { () -> Void in
            self.backgroundImageView.frame = CGRect(x: -1*( 1000 - SCREEN_WIDTH )/2, y: 0, width: SCREEN_HEIGHT+500, height: SCREEN_HEIGHT+500);
        }) 
    }


    @objc func findLoginFrom1Password(){
        OnePasswordExtension.shared().findLogin(forURLString: "v2ex.com", for: self, sender: nil) { (loginDictionary, errpr) -> Void in
            if let count = loginDictionary?.count , count > 0 {
                self.userNameTextField.text = loginDictionary![AppExtensionUsernameKey] as? String
                self.passwordTextField.text = loginDictionary![AppExtensionPasswordKey] as? String

                //密码赋值后，点确认按钮
                self.loginClick(self.loginButton)
            }
        }
    }
    @objc func cancelClick (){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func loginClick(_ sneder:UIButton){
        var userName:String
        var password:String
        if let len = self.userNameTextField.text?.Lenght , len > 0{
            userName = self.userNameTextField.text! ;
        }
        else{
            self.userNameTextField.becomeFirstResponder()
            return;
        }

        if let len =  self.passwordTextField.text?.Lenght , len > 0  {
            password = self.passwordTextField.text!
        }
        else{
            self.passwordTextField.becomeFirstResponder()
            return;
        }
        var code:String
        if let codeText = self.codeTextField.text, codeText.Lenght > 0 {
            code = codeText
        }
        else{
            self.codeTextField.becomeFirstResponder()
            return
        }

        var loginTicket = V2EXSettings.sharedInstance[kUserTicket]!
        
        V2BeginLoadingWithStatus("正在登录")
        UserModel.Login(userName,
                        password: password.md5(),
                        code:code,
                        loginTicket:loginTicket){
            (response:V2ValueResponse<String> , is2FALoggedIn:Bool) -> Void in
            if response.success {
                V2Success("登录成功")
                let res = response.value!
                //保存下用户名
                V2EXSettings.sharedInstance[kUserName] = userName

                //保存token
                var token = res
                V2EXSettings.sharedInstance[kUserToken] = res
                
                var map = [String:String]()
                //解析token
                do{
                let jwt = try decode(jwt: token)
                let name = jwt.body["name"] as! String
                let roles = jwt.body["roles"] as! String
                

                //将用户名密码保存进keychain （安全保存)
                V2UsersKeychain.sharedInstance.addUser(name, roles:roles)

                map["name"] =  name
                map["roles"] = roles}
                catch let exp{
                    print(exp)
                }
//                map["avatar_large"] = avatar
//                map["avatar_normal"] = avatar
                V2User.sharedInstance.user = Mapper<UserModel>().map(JSON: map)
                //调用登录成功回调
                if let handel = self.successHandel {
                    handel(token)
                }

//                let userBooksController = UserBookViewController()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                V2Client.sharedInstance.centerViewController!.navigationController?.present(userBooksController, animated: true, completion: nil);
//                appDelegate.window!.rootViewController = V2Client.sharedInstance.drawerController
                appDelegate.window!.rootViewController = LayoutViewController()

                //获取用户信息
//                UserModel.getUserInfoFromToken(token,completionHandler: nil)
                self.dismiss(animated: true,completion:{
//                    if is2FALoggedIn {
//                        let twoFaViewController = TwoFAViewController()
//                        V2Client.sharedInstance.centerViewController!.navigationController?.present(twoFaViewController, animated: true, completion: nil);
//                    }
//                    let userBooksController = UserBookViewController()
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    V2Client.sharedInstance.centerViewController!.navigationController?.present(userBooksController, animated: true, completion: nil);
//                    appDelegate.window!.rootViewController = V2Client.sharedInstance.centerViewController
                })
            }
            else{
                V2Error(response.message)
                self.refreshCode()
            }
        }
    }
    
    var onceStr:String?
    var usernameStr:String?
    var passwordStr:String?
    var codeStr:String?
    @objc func refreshCode(){

        let codeUrl = API_BASE_URL+"/kaptcha/";

        Alamofire.request(codeUrl, headers: MOBILE_CLIENT_HEADERS).responseJSON{
            response in

            switch response.result {
            case .success(let value):
                let jsonData = value as! Dictionary<String,String>
                self.codeImageView.image = UIImage(data: Data(base64Encoded: jsonData["img"]!, options: .ignoreUnknownCharacters)!)
                //保存ticket
                V2EXSettings.sharedInstance[kUserTicket] = jsonData["ticket"]
            case .failure(let error):
                print(error)
                SVProgressHUD.showError(withStatus: "刷新验证码失败")
            }


        }
    }
}

//MARK: - 点击文本框外收回键盘
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - 初始化界面
//extension LoginViewController {
//    func setupView(){
//        self.view.backgroundColor = UIColor.black
//
//        self.backgroundImageView.image = UIImage(named: "32.jpg")
//        self.backgroundImageView.frame = self.view.frame
//        self.backgroundImageView.contentMode = .scaleToFill
//        self.view.addSubview(self.backgroundImageView)
//        backgroundImageView.alpha = 0
//
//        self.frostedView.frame = self.view.frame
//        self.view.addSubview(self.frostedView)
//
//        let vibrancy = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
//        let vibrancyView = UIVisualEffectView(effect: vibrancy)
//        vibrancyView.isUserInteractionEnabled = true
//        vibrancyView.frame = self.frostedView.frame
//        self.frostedView.contentView.addSubview(vibrancyView)
//
//        let v2exLabel = UILabel()
//        v2exLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)!;
//        v2exLabel.text = "Explore"
//        vibrancyView.contentView.addSubview(v2exLabel);
//        v2exLabel.snp.makeConstraints{ (make) -> Void in
//            make.centerX.equalTo(vibrancyView)
//            make.top.equalTo(vibrancyView).offset(40)
//        }
//
//        let v2exSummaryLabel = UILabel()
//        v2exSummaryLabel.font = v2Font(13);
//        v2exSummaryLabel.text = "创意者的工作社区"
//        vibrancyView.contentView.addSubview(v2exSummaryLabel);
//        v2exSummaryLabel.snp.makeConstraints{ (make) -> Void in
//            make.centerX.equalTo(vibrancyView)
//            make.top.equalTo(v2exLabel.snp.bottom).offset(2)
//        }
//
//        self.userNameTextField.autocorrectionType = UITextAutocorrectionType.no
//        self.userNameTextField.autocapitalizationType = UITextAutocapitalizationType.none
//
//        self.userNameTextField.textColor = UIColor.white
//        self.userNameTextField.backgroundColor = UIColor(white: 1, alpha: 0.1);
//        self.userNameTextField.font = v2Font(15)
//        self.userNameTextField.layer.cornerRadius = 3;
//        self.userNameTextField.layer.borderWidth = 0.5
//        self.userNameTextField.keyboardType = .asciiCapable
//        self.userNameTextField.layer.borderColor = UIColor(white: 1, alpha: 0.8).cgColor;
//        self.userNameTextField.placeholder = "用户名"
//        self.userNameTextField.clearButtonMode = .always
//
//        let userNameIconImageView = UIImageView(image: UIImage(named: "ic_account_circle")!.withRenderingMode(.alwaysTemplate));
//        userNameIconImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 22)
//        userNameIconImageView.tintColor = UIColor.white
//        userNameIconImageView.contentMode = .scaleAspectFit
//        self.userNameTextField.leftView = userNameIconImageView
//        self.userNameTextField.leftViewMode = .always
//
//        vibrancyView.contentView.addSubview(self.userNameTextField);
//
//        self.userNameTextField.snp.makeConstraints{ (make) -> Void in
//            make.top.equalTo(v2exSummaryLabel.snp.bottom).offset(25)
//            make.centerX.equalTo(vibrancyView)
//            make.width.equalTo(300)
//            make.height.equalTo(38)
//        }
//
//        self.passwordTextField.textColor = UIColor.white
//        self.passwordTextField.backgroundColor = UIColor(white: 1, alpha: 0.1);
//        self.passwordTextField.font = v2Font(15)
//        self.passwordTextField.layer.cornerRadius = 3;
//        self.passwordTextField.layer.borderWidth = 0.5
//        self.passwordTextField.keyboardType = .asciiCapable
//        self.passwordTextField.isSecureTextEntry = true
//        self.passwordTextField.layer.borderColor = UIColor(white: 1, alpha: 0.8).cgColor;
//        self.passwordTextField.placeholder = "密码"
//        self.passwordTextField.clearButtonMode = .always
//
//        let passwordIconImageView = UIImageView(image: UIImage(named: "ic_lock")!.withRenderingMode(.alwaysTemplate));
//        passwordIconImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 22)
//        passwordIconImageView.contentMode = .scaleAspectFit
//        userNameIconImageView.tintColor = UIColor.white
//        self.passwordTextField.leftView = passwordIconImageView
//        self.passwordTextField.leftViewMode = .always
//
//        vibrancyView.contentView.addSubview(self.passwordTextField);
//
//        self.passwordTextField.snp.makeConstraints{ (make) -> Void in
//            make.top.equalTo(self.userNameTextField.snp.bottom).offset(15)
//            make.centerX.equalTo(vibrancyView)
//            make.width.equalTo(300)
//            make.height.equalTo(38)
//        }
//
//
//        self.codeTextField.textColor = UIColor.white
//        self.codeTextField.backgroundColor = UIColor(white: 1, alpha: 0.1);
//        self.codeTextField.font = v2Font(15)
//        self.codeTextField.layer.cornerRadius = 3;
//        self.codeTextField.layer.borderWidth = 0.5
//        self.codeTextField.keyboardType = .asciiCapable
//        self.codeTextField.layer.borderColor = UIColor(white: 1, alpha: 0.8).cgColor;
//        self.codeTextField.placeholder = "验证码"
//        self.codeTextField.clearButtonMode = .always
//
//        let codeTextFieldImageView = UIImageView(image: UIImage(named: "ic_vpn_key")!.withRenderingMode(.alwaysTemplate));
//        codeTextFieldImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 22)
//        codeTextFieldImageView.contentMode = .scaleAspectFit
//        codeTextFieldImageView.tintColor = UIColor.white
//        self.codeTextField.leftView = codeTextFieldImageView
//        self.codeTextField.leftViewMode = .always
//
//        vibrancyView.contentView.addSubview(self.codeTextField)
//
//        self.codeTextField.snp.makeConstraints { (make) in
//            make.top.equalTo(self.passwordTextField.snp.bottom).offset(15)
//            make.left.equalTo(passwordTextField)
//            make.width.equalTo(180)
//            make.height.equalTo(38)
//        }
//
//        self.codeImageView.backgroundColor = UIColor.white
//        self.codeImageView.layer.cornerRadius = 3;
//        self.codeImageView.clipsToBounds = true
//        self.codeImageView.isUserInteractionEnabled = true
//        vibrancyView.contentView.addSubview(self.codeImageView)
//        self.codeImageView.snp.makeConstraints { (make) in
//            make.top.bottom.equalTo(self.codeTextField)
//            make.left.equalTo(self.codeTextField.snp.right).offset(-5)
//            make.right.equalTo(self.passwordTextField)
//        }
//        self.codeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(refreshCode)))
//
//        self.loginButton.setTitle("登  录", for: UIControlState())
//        self.loginButton.titleLabel!.font = v2Font(20)
//        self.loginButton.layer.cornerRadius = 3;
//        self.loginButton.layer.borderWidth = 0.5
//        self.loginButton.layer.borderColor = UIColor(white: 1, alpha: 0.8).cgColor;
//        vibrancyView.contentView.addSubview(self.loginButton);
//
//        self.loginButton.snp.makeConstraints{ (make) -> Void in
//            make.top.equalTo(self.codeTextField.snp.bottom).offset(20)
//            make.centerX.equalTo(vibrancyView)
//            make.width.equalTo(300)
//            make.height.equalTo(38)
//        }
//        let codeProblem = UILabel()
//        codeProblem.alpha = 0.5
//        codeProblem.font = v2Font(12)
//        codeProblem.text = "验证码不显示?"
//        codeProblem.isUserInteractionEnabled = true
//        codeProblem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(codeProblemClick)))
//        vibrancyView.contentView.addSubview(codeProblem);
//
//        codeProblem.snp.makeConstraints{ (make) -> Void in
//            make.top.equalTo(self.loginButton.snp.bottom).offset(14)
//            make.right.equalTo(self.loginButton)
//        }
//
//        let footLabel = UILabel()
//        footLabel.alpha = 0.5
//        footLabel.font = v2Font(12)
//        footLabel.text = "© 2018 Fin"
//
//        vibrancyView.contentView.addSubview(footLabel);
//
//        footLabel.snp.makeConstraints{ (make) -> Void in
//            make.bottom.equalTo(vibrancyView).offset(-20)
//            make.centerX.equalTo(vibrancyView)
//        }
//
//        self.cancelButton.contentMode = .center
//        cancelButton .setImage(UIImage(named: "ic_cancel")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
//        vibrancyView.contentView.addSubview(cancelButton)
//        cancelButton.snp.makeConstraints{ (make) -> Void in
//            make.centerY.equalTo(footLabel)
//            make.right.equalTo(vibrancyView).offset(-5)
//            make.width.height.equalTo(40)
//        }
//
//        refreshCode()
//    }
//
//    @objc func codeProblemClick(){
//        UIAlertView(title: "验证码不显示？", message: "如果验证码输错次数过多，V2EX将暂时禁止你的登录。", delegate: nil, cancelButtonTitle: "知道了").show()
//    }
//}

extension LoginViewController {
    func setupView(){
        self.view.backgroundColor = UIColor.white
        
//        self.backgroundImageView.image = UIImage(named: "32.jpg")
//        self.backgroundImageView.frame = self.view.frame
//        self.backgroundImageView.contentMode = .scaleToFill
//        self.view.addSubview(self.backgroundImageView)
//        backgroundImageView.alpha = 0
        
//        self.frostedView.frame = self.view.frame
//        self.view.addSubview(self.frostedView)
//
//        let vibrancy = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
//        let vibrancyView = UIVisualEffectView(effect: vibrancy)
//        vibrancyView.isUserInteractionEnabled = true
//        vibrancyView.frame = self.frostedView.frame
//        self.frostedView.contentView.addSubview(vibrancyView)
        
        let v2exLabel = UILabel()
        v2exLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)!;
        v2exLabel.text = "AVA"
        self.view.addSubview(v2exLabel);
        v2exLabel.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).offset(40)
        }
        
        let v2exSummaryLabel = UILabel()
        v2exSummaryLabel.font = v2Font(13);
        v2exSummaryLabel.text = "leading your way"
        self.view.addSubview(v2exSummaryLabel);
        v2exSummaryLabel.snp.makeConstraints{ (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(v2exLabel.snp.bottom).offset(2)
        }
        
        self.userNameTextField.autocorrectionType = UITextAutocorrectionType.no
        self.userNameTextField.autocapitalizationType = UITextAutocapitalizationType.none
        
        self.userNameTextField.textColor = UIColor.gray
        self.userNameTextField.backgroundColor = UIColor(white: 1, alpha: 0.1);
        self.userNameTextField.font = v2Font(15)
        self.userNameTextField.layer.cornerRadius = 3;
        self.userNameTextField.layer.borderWidth = 0.5
        self.userNameTextField.keyboardType = .asciiCapable
        self.userNameTextField.layer.borderColor = UIColor(white: 0.5, alpha: 0.8).cgColor;
        self.userNameTextField.placeholder = "用户名"
        self.userNameTextField.clearButtonMode = .always
        
        let userNameIconImageView = UIImageView(image: UIImage(named: "ic_account_circle")!.withRenderingMode(.alwaysTemplate));
        userNameIconImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 22)
        userNameIconImageView.tintColor = UIColor.white
        userNameIconImageView.contentMode = .scaleAspectFit
        userNameIconImageView.tintColor = UIColor.gray
        self.userNameTextField.leftView = userNameIconImageView
        self.userNameTextField.leftViewMode = .always
        
        self.view.addSubview(self.userNameTextField);
        
        self.userNameTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(v2exSummaryLabel.snp.bottom).offset(25)
            make.centerX.equalTo(self.view)
            make.width.equalTo(300)
            make.height.equalTo(38)
        }
        
        self.passwordTextField.textColor = UIColor.gray
        self.passwordTextField.backgroundColor = UIColor(white: 1, alpha: 0.1);
        self.passwordTextField.font = v2Font(15)
        self.passwordTextField.layer.cornerRadius = 3;
        self.passwordTextField.layer.borderWidth = 0.5
        self.passwordTextField.keyboardType = .asciiCapable
        self.passwordTextField.isSecureTextEntry = true
        self.passwordTextField.layer.borderColor = UIColor(white: 0.5, alpha: 0.8).cgColor;
        self.passwordTextField.placeholder = "密码"
        self.passwordTextField.clearButtonMode = .always
        
        let passwordIconImageView = UIImageView(image: UIImage(named: "ic_lock")!.withRenderingMode(.alwaysTemplate));
        passwordIconImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 22)
        passwordIconImageView.contentMode = .scaleAspectFit
        passwordIconImageView.tintColor = UIColor.gray
        self.passwordTextField.leftView = passwordIconImageView
        self.passwordTextField.leftViewMode = .always
        
        self.view.addSubview(self.passwordTextField);
        
        self.passwordTextField.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.userNameTextField.snp.bottom).offset(15)
            make.centerX.equalTo(self.view)
            make.width.equalTo(300)
            make.height.equalTo(38)
        }
        
        
        self.codeTextField.textColor = UIColor.gray
        self.codeTextField.backgroundColor = UIColor(white: 1, alpha: 0.1);
        self.codeTextField.font = v2Font(15)
        self.codeTextField.layer.cornerRadius = 3;
        self.codeTextField.layer.borderWidth = 0.5
        self.codeTextField.keyboardType = .asciiCapable
        self.codeTextField.layer.borderColor = UIColor(white: 0.5, alpha: 0.8).cgColor;
        self.codeTextField.placeholder = "验证码"
        self.codeTextField.clearButtonMode = .always
        
        let codeTextFieldImageView = UIImageView(image: UIImage(named: "ic_vpn_key")!.withRenderingMode(.alwaysTemplate));
        codeTextFieldImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 22)
        codeTextFieldImageView.contentMode = .scaleAspectFit
        codeTextFieldImageView.tintColor = UIColor.gray
        self.codeTextField.leftView = codeTextFieldImageView
        self.codeTextField.leftViewMode = .always
        
        self.view.addSubview(self.codeTextField)
        
        self.codeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(15)
            make.left.equalTo(passwordTextField)
            make.width.equalTo(180)
            make.height.equalTo(38)
        }
        
        self.codeImageView.backgroundColor = UIColor.white
        self.codeImageView.layer.cornerRadius = 3;
        self.codeImageView.clipsToBounds = true
        self.codeImageView.isUserInteractionEnabled = true
        self.view.addSubview(self.codeImageView)
        self.codeImageView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self.codeTextField)
            make.left.equalTo(self.codeTextField.snp.right).offset(5)
            make.right.equalTo(self.passwordTextField)
        }
        self.codeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(refreshCode)))
        
        self.loginButton.setTitle("登  录", for: UIControlState())
        self.loginButton.setTitleColor(UIColor(white: 0.2, alpha: 0.9), for: UIControlState())
        self.loginButton.titleLabel!.font = v2Font(20)
        self.loginButton.layer.cornerRadius = 3;
        self.loginButton.layer.borderWidth = 0.5
        self.loginButton.layer.borderColor = UIColor(white: 0.5, alpha: 0.8).cgColor;
        self.view.addSubview(self.loginButton);
        
        self.loginButton.snp.makeConstraints{ (make) -> Void in
            make.top.equalTo(self.codeTextField.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(300)
            make.height.equalTo(38)
        }
//        self.codeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(login)))

//        let codeProblem = UILabel()
//        codeProblem.alpha = 0.5
//        codeProblem.font = v2Font(12)
//        codeProblem.text = "验证码不显示?"
//        codeProblem.isUserInteractionEnabled = true
//        codeProblem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(codeProblemClick)))
//        self.view.addSubview(codeProblem);
//
//        codeProblem.snp.makeConstraints{ (make) -> Void in
//            make.top.equalTo(self.loginButton.snp.bottom).offset(14)
//            make.right.equalTo(self.loginButton)
//        }
        
        let footLabel = UILabel()
        footLabel.alpha = 0.5
        footLabel.font = v2Font(12)
        footLabel.text = "© acxca.com"
        
        self.view.addSubview(footLabel);
        
        footLabel.snp.makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.view).offset(-20)
            make.centerX.equalTo(self.view)
        }
        
//        self.cancelButton.contentMode = .center
//        cancelButton .setImage(UIImage(named: "ic_cancel")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
//        self.view.addSubview(cancelButton)
//        cancelButton.snp.makeConstraints{ (make) -> Void in
//            make.centerY.equalTo(footLabel)
//            make.right.equalTo(self.view).offset(-5)
//            make.width.height.equalTo(40)
//        }
        
        refreshCode()
    }
    
    @objc func codeProblemClick(){
        UIAlertView(title: "验证码不显示？", message: "如果验证码输错次数过多，V2EX将暂时禁止你的登录。", delegate: nil, cancelButtonTitle: "知道了").show()
    }
}
