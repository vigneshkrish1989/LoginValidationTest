//
//  ViewController.swift
//  LoginValidationTest
//
//  Created by Vignesh Krishnamurthy on 24/03/21.
//  Copyright © 2021 vignesh. All rights reserved.
//

extension String {
    
    var isValidEmail: Bool {
       let regularExpressionForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let testEmail = NSPredicate(format:"SELF MATCHES %@", regularExpressionForEmail)
       return testEmail.evaluate(with: self)
    }
    var isValidPassword: Bool {
       let regularExpressionForPassword = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}"
       let testPhone = NSPredicate(format:"SELF MATCHES %@", regularExpressionForPassword)
       return testPhone.evaluate(with: self)
    }
    
}

import UIKit
import RxSwift
import RxCocoa
import CoreData

// ViewModel
class LoginViewModel{

    let emailTxt = PublishSubject<String>()
    let passwordTxt = PublishSubject<String>()
    
    func loginValid() -> Observable<Bool> {
        return Observable.combineLatest(emailTxt.asObservable().startWith(""), passwordTxt.asObservable().startWith("")).map({email, password in
             
            return email.isValidEmail && password.isValidPassword
            }).startWith(false)
    }
    
}

class ViewController: UIViewController {
    

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var passwordValidateLbl: UILabel!
    @IBOutlet weak var emailValidateLbl: UILabel!
    let viewModel = LoginViewModel()
    
    var created_at = String()
    var userId = Int()
    var userName = String()
    
    private let disposeBag = DisposeBag()
     var trackedLocData = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        emailTxtField.becomeFirstResponder()
        emailTxtField.delegate = self
        passwordTxtField.delegate = self
        
        emailTxtField.rx.text.map{$0 ?? ""}.bind(to: viewModel.emailTxt).disposed(by: disposeBag)
        passwordTxtField.rx.text.map{$0 ?? ""}.bind(to: viewModel.passwordTxt).disposed(by: disposeBag)
        
        viewModel.loginValid().bind(to: loginBtn.rx.isEnabled).disposed(by: disposeBag)
        viewModel.loginValid().map {$0 ? 1 : 0.1}.bind(to: loginBtn.rx.alpha).disposed(by: disposeBag)
    
        
        
      /*  let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                      do{
                          let locValue = try PersistenceService.context.fetch(fetchRequest)
                          self.trackedLocData = locValue
                        let username = trackedLocData.map { $0.username }
                        print("username",username)
                      }catch{}
 */
        
    
    }
 
    @IBAction func loginTap(_ sender: UIButton) {
        
        
        
        if emailTxtField.text == "test@imaginato.com" && passwordTxtField.text == "Imaginato2020"
        {
            
            // prepare json data
            let json: [String: Any] = ["email": "\(emailTxtField.text!)",
                "password": "\(passwordTxtField.text!)"]

            let jsonData = try? JSONSerialization.data(withJSONObject: json)

            // create post request
            let url = URL(string: "http://imaginato.mocklab.io/login")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            // insert json data to the request
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    let data = responseJSON["data"] as? [String: Any]
                    let user = data?["user"] as? [String: Any]
                    print("User is",user!)
                    
                    
                    let saveUserValue = User(context: PersistenceService.context)
                    self.userName = user?["userName"] as? String ?? ""
                    saveUserValue.username = self.userName
                    
                    self.userId = user?["userId"] as? Int ?? 0
                    saveUserValue.userID = Int32(self.userId)
                    
                    self.created_at = user?["created_at"] as? String ?? ""
                    
                  // Convert Date string to Date?
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    let date = dateFormatter.date(from:self.created_at)!
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
                    let finalDate = calendar.date(from:components)
                    saveUserValue.created_date = finalDate
                    
                    PersistenceService.saveContext()
                    
                    DispatchQueue.main.async {
                         let alert = UIAlertController(title: "Login Success", message: nil, preferredStyle: UIAlertController.Style.alert)
                                                      alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                           self.present(alert, animated: true, completion: nil)
                    }
     
                }
            }

            task.resume()
        }
        else
        {
            let alert = UIAlertController(title: "Login Failed", message: "Please enter your registered email and password!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
 
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         
         if textField == emailTxtField{
             emailValidateLbl.isHidden = false
             if textField.text!.isValidEmail
             {
                 emailValidateLbl.text = "Valid"
             }
             else
             {
                 emailValidateLbl.text = "This is a invalid email"
             }
         }
             
         else if textField == passwordTxtField{
             passwordValidateLbl.isHidden = false
             if passwordTxtField.text!.isValidPassword{
                 print("not valid")
                 passwordValidateLbl.text = "Valid"
                 
             }
             else
             {
                 passwordValidateLbl.text = "Passwords require at least 1 uppercase, 1 lowercase, and 1 number"
                 print("valid")
             }
         }
         return true
     }
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
       }
    
}
