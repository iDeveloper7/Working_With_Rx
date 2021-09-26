//
//  FifthViewController.swift
//  DZ Modul 3
//
//  Created by Vladimir Karsakov on 10.08.2021.
//
//5. В реактивном виде реализуйте следующие задачи:
//     e) Две кнопки и лейбл. Когда на каждую кнопку нажали хотя бы один раз, в лейбл выводится: «Ракета запущена».

import UIKit
import ReactiveKit
import Bond

class FifthViewController: UIViewController {
    
    private let rocketLabel: UILabel = {
        let label = UILabel()
        label.text = "Ракета запущена"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Helvetica Neue", size: 40)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        return label
    }()
    private let oneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go, rocket!", for: .normal)
        button.titleLabel?.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        button.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(pressOneButton), for: .touchDown)
        button.addTarget(self, action: #selector(unPressOneButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var secondButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go, rocket!", for: .normal)
        button.titleLabel?.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        button.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(pressSecondButton), for: .touchDown)
        button.addTarget(self, action: #selector(unPressSecondButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isPushOneButton = Property(false)
    private var isPushSecondButton = Property(false)
    private var isActiveButtons = Property(false)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        constrainsRocketLabel()
        constrainsOneButton()
        constrainsSecondButton()
        
        self.title = "The fifth task"
        
        //если значение isPushOneButton == true и isPushSecondButton == true, передаем значение true в переменную isActiveButtons
        combineLatest(isPushOneButton, isPushSecondButton)
            .map { $0 && $1 }
            .bind(to: isActiveButtons)
        
        //если значение isActiveButtons == true, то rocketLabel будет не скрыт
        isActiveButtons
            .map { $0 ? false : true }
            .bind(to: rocketLabel.reactive.isHidden)
        
    }
    
    @objc private func pressOneButton(){
        UIView.animate(withDuration: 0.05) {
            self.oneButton.alpha = 0.7
        }
    }
    @objc private func unPressOneButton(){
        UIView.animate(withDuration: 0.3) {
            self.oneButton.alpha = 1
        }
        //если кнопка нажата, то меняем значение
        isPushOneButton.value = true
        print("Первая кнопка нажата, \(isPushOneButton.value)")
    }
    @objc private func pressSecondButton(){
        UIView.animate(withDuration: 0.05) {
            self.secondButton.alpha = 0.7
        }
    }
    @objc private func unPressSecondButton(){
        UIView.animate(withDuration: 0.3) {
            self.secondButton.alpha = 1
        }
        //если кнопка нажата, то меняем значение
        isPushSecondButton.value = true
        print("Вторая кнопка нажата, \(isPushSecondButton.value)")
    }
    
    private func constrainsRocketLabel(){
        view.addSubview(rocketLabel)
        NSLayoutConstraint.activate([
            rocketLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            rocketLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rocketLabel.widthAnchor.constraint(equalToConstant: view.bounds.size.width - 20),
            rocketLabel.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    private func constrainsOneButton(){
        view.addSubview(oneButton)
        NSLayoutConstraint.activate([
            oneButton.topAnchor.constraint(equalTo: rocketLabel.bottomAnchor, constant: 40),
            oneButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            oneButton.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 2 - 50),
            oneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    private func constrainsSecondButton(){
        view.addSubview(secondButton)
        NSLayoutConstraint.activate([
            secondButton.centerYAnchor.constraint(equalTo: oneButton.centerYAnchor),
            secondButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            secondButton.widthAnchor.constraint(equalTo: oneButton.widthAnchor),
            secondButton.heightAnchor.constraint(equalTo: oneButton.heightAnchor)
        ])
    }

}
