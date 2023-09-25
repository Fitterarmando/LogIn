//
//  HomeVC.swift
//  LogIn
//
//  Created by Juan Armando Frías Ramírez on 22/09/23.
//

import UIKit
import Resolver

class LogInVC: UIViewController {
    @Injected var viewModel: LoginViewModel
    
    @IBOutlet var user: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var forgotPassword: UIButton!
    @IBAction func procesandoLogin(_ sender: Any) {
        
        guard let user = user.text, let password = password.text  else {
            return
        }
        viewModel.login(username: user , password: password)
    }
    @IBOutlet var error: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var notvalid: UILabel!
    @IBOutlet var scrollLogIn: UIScrollView!
    
    var activeTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextFields()
        configureTagGesture()
        
        viewModel.loading.bind { loading in
            if loading {
                // showLoading
                self.activityIndicator.startAnimating()
                self.activityIndicator.isHidden = false
            } else {
                // hide loading
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
        viewModel.isDataValid.bind { isDataValid in
            if isDataValid == nil || isDataValid! {
                // hide error
                self.notvalid.isHidden = true
            } else {
                // show error
                self.notvalid.isHidden = false
            }
        }
        
        self.viewModel.loginSuccess.bind { loginSuccess in
            if loginSuccess {
                self.navigationController?.pushViewController(InicioVC(), animated: true)
            }
        }
        
        self.viewModel.loginError.bind { loginError in
            if loginError {
                self.error.isHidden = false
            } else {
                self.error.isHidden = true
            }
            
        }
        
        
    }
    
    private func configureTagGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LogInVC.handleTap))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    private func configureTextFields() {
        user.delegate = self
        password.delegate = self
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification){
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardY = self.view.frame.size.height - keyboardSize.height
        
        let editingTextFieldY: CGFloat! = self.activeTextField?.frame.origin.y
        
        if self.view.frame.origin.y >= 0 {
            
            if editingTextFieldY > keyboardY - 350 {
                UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.view.frame = CGRect(x: 0, y: self.view.frame.origin.y - (editingTextFieldY! - (keyboardY - 350)) , width: self.view.bounds.width, height: self.view.bounds.height)
                }, completion:  nil)
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification){
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
}

extension LogInVC : UITextFieldDelegate{
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification: )), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification: )), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
}

class LoginViewModel {
    @Injected var loginRepository: LoginRepository

    init() {}
    
    let isDataValid = Box<Bool?>(nil)
    let loading = Box<Bool>(false)
    let loginSuccess = Box<Bool>(false)
    let loginError = Box<Bool>(false)
    
    func login(username: String, password: String) {
        if (username.isEmpty || password.isEmpty) {
            isDataValid.value = true
            return
        }

        loading.value = true
        
        loginRepository.login(username: username, password: password) { result in
            self.loading.value = false
            switch result {
            case .success(_):
                self.loginSuccess.value = true
                self.loginError.value = false
            case .failure(_):
                self.loginSuccess.value = false
                self.loginError.value = true
            }
        }
    }
    
}

protocol LoginRepository {
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class LoginRepositoryImpl: LoginRepository {
    
    init() {}
    
    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completion(.success(()))
        }
    }
    
}

