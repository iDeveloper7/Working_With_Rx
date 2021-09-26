//
//  ViewController.swift
//  DZ Modul 3
//
//  Created by Vladimir Karsakov on 29.07.2021.

//5. В реактивном виде реализуйте следующие задачи:
//     a) Два текстовых поля. Логин и пароль, под ними лейбл и ниже кнопка «Отправить». В лейбл выводится «некорректная почта», если введённая почта некорректна. Если почта корректна, но пароль меньше шести символов, выводится: «Слишком короткий пароль». В противном случае ничего не выводится. Кнопка «Отправить» активна, если введена корректная почта и пароль не менее шести символов.

import UIKit
import ReactiveKit
import Bond

class OneViewController: UIViewController {
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Логин"
        label.font = UIFont(name: "Helvetica Neue", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Пароль"
        label.font = UIFont(name: "Helvetica Neue", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let loginTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Helvetica Neue", size: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите логин"
        textField.borderStyle = .roundedRect
        return textField
    }()
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Helvetica Neue", size: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите пароль"
        textField.borderStyle = .roundedRect
        return textField
    }()
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 23)
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отправить", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.isEnabled = false
        button.alpha = 0.6
        button.addTarget(self, action: #selector(animatePressButton), for: .touchDown)
        button.addTarget(self, action: #selector(animateReleaseButton), for: .touchUpInside)
        return button
    }()
    private let enterLoginLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 23)
        label.textColor = .green
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var isActiveButton = Property(false)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        self.title = "The first task"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(goToBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(nextVCBarButtonItem))
        
        constraintLoginLabel()
        constraintPasswordLabel()
        constraintLoginTextField()
        constraintPasswordTextField()
        constraintWarningLabel()
        constraintLoginButton()
        constraintEnterLoginLabel()
    
        //проверяю loginTextField на корректность ввода. Если он некорректный - вывожу сообщение в warning label
        loginTextField.reactive.text
            .compactMap { $0 }
            .map { self.isValid($0) || $0.isEmpty ? "" : "некорректная почта" }
            .bind(to: warningLabel.reactive.text)
        
        //проверяю passwordTextField на корректность ввода. Если он некорректный - вывожу сообщение в warning label
        passwordTextField.reactive.text
            .compactMap { $0 }
            .map { $0.count >= 6 || $0.isEmpty ? "" : "слишком короткий пароль" }
            .bind(to: warningLabel.reactive.text)
        
        //проверяю, если логин валидный и пароль больше или равен 6 символам, то кнопка активна
        combineLatest(loginTextField.reactive.text, passwordTextField.reactive.text) { log, pass in
            return self.isValid(log!) && pass!.count >= 6
        }
        .bind(to: loginButton.reactive.isEnabled)
        
        //если лог и пасс валидны, то передаю значение true в переменную, для ее дальнейшего изменения параметра alpha
        combineLatest(loginTextField.reactive.text, passwordTextField.reactive.text)
            .map { self.isValid($0!) && $1!.count >= 6 }
            .bind(to: isActiveButton)
        
//         изменяю прозрачность кнопки, если лог и пасс валидны.
        isActiveButton
            .map { $0 ? 1.0 : 0.6 }
            .bind(to: loginButton.reactive.alpha)
        
        //при нажатии на кнопку, если она активна (она активна только если лог и пасс валидны), то в label выводится текст
        loginButton.reactive.tap.with(latestFrom: isActiveButton)
            .compactMap { $1 }
            .map { $0 ? "Лог и пасс валидны" : ""}
            .bind(to: enterLoginLabel.reactive.text)
        
        //При вводе изменений в текстфилды, значение enterLoginLabel будет пустым
        loginTextField.addTarget(self, action: #selector(editingChangedTextField), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(editingChangedTextField), for: .editingChanged)
    }
    
    @objc private func editingChangedTextField(){
        enterLoginLabel.text = ""
    }
    
    @objc private func animatePressButton(){
        UIView.animate(withDuration: 0.05) {
            self.loginButton.alpha = 0.7
        }
    }
    @objc private func animateReleaseButton(){
        UIView.animate(withDuration: 0.3) {
            self.loginButton.alpha = 1
        }
    }
    
    @objc private func nextVCBarButtonItem(){
        let secondVC = SecondViewController()
        
        navigationController?.pushViewController(secondVC, animated: true)
    }
    
    @objc private func goToBack(){
        dismiss(animated: true, completion: nil)
    }
    
    private func constraintLoginLabel(){
        view.addSubview(loginLabel)
        NSLayoutConstraint.activate([
            loginLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            loginLabel.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            loginLabel.widthAnchor.constraint(equalToConstant: 60),
            loginLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
        
    }
    private func constraintPasswordLabel(){
        view.addSubview(passwordLabel)
        NSLayoutConstraint.activate([
            passwordLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 40),
            passwordLabel.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            passwordLabel.widthAnchor.constraint(equalToConstant: 60),
            passwordLabel.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    private func constraintLoginTextField(){
        view.addSubview(loginTextField)
        NSLayoutConstraint.activate([
            loginTextField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            loginTextField.leftAnchor.constraint(equalTo: loginLabel.rightAnchor, constant: 20),
            loginTextField.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -10),
            loginTextField.heightAnchor.constraint(equalTo: loginLabel.heightAnchor)
        ])
    }
    private func constraintPasswordTextField(){
        view.addSubview(passwordTextField)
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 40),
            passwordTextField.leftAnchor.constraint(equalTo: passwordLabel.rightAnchor, constant: 20),
            passwordTextField.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -10),
            passwordTextField.heightAnchor.constraint(equalTo: passwordLabel.heightAnchor)
        ])
    }
    private func constraintWarningLabel(){
        view.addSubview(warningLabel)
        NSLayoutConstraint.activate([
            warningLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            warningLabel.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 30)
        ])
    }
    private func constraintLoginButton(){
        view.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 40),
            loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func constraintEnterLoginLabel(){
        view.addSubview(enterLoginLabel)
        NSLayoutConstraint.activate([
            enterLoginLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            enterLoginLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
