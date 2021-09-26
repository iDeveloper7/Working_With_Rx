//
//  FourthViewController.swift
//  DZ Modul 3
//
//  Created by Vladimir Karsakov on 04.08.2021.
//
//5. В реактивном виде реализуйте следующие задачи:
//d) Лейбл и кнопку. В лейбле выводится значение counter (по умолчанию 0), при нажатии counter увеличивается на 1.

import UIKit
import ReactiveKit
import Bond

class FourthViewController: UIViewController {
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.text = String(0)
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 25)
        label.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let counterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Press", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.textColor = #colorLiteral(red: 1, green: 0.8306267262, blue: 0.7752806544, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pressButton), for: .touchDown)
        button.addTarget(self, action: #selector(unPressButton), for: .touchUpInside)
        return button
    }()
    //создаем переменную с изначальным значением 0
    private var counter = Property(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(goToBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(goToNext))
        
        self.title = "The fourth task"
        
        //переводим значение переменной из Int в String и передаем его в label
        counter.map { "\($0)" }
            .bind(to: counterLabel.reactive.text)
        
        view.backgroundColor = #colorLiteral(red: 1, green: 0.8510241508, blue: 0.7654248476, alpha: 1)
        
        constraintsCounterLabel()
        constraintsCounterButton()
    }
    
    @objc private func goToBack(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func goToNext(){
        let fifthVC = FifthViewController()
        navigationController?.pushViewController(fifthVC, animated: true)
    }
    
    @objc private func pressButton(){
        UIView.animate(withDuration: 0.05) {
            self.counterButton.alpha = 0.7
        }
    }
    @objc private func unPressButton(){
        UIView.animate(withDuration: 0.3) {
            self.counterButton.alpha = 1
        }
        //при нажатии на кнопку, значение переменной увеличивается на 1
        counter.value += 1
    }
    
    private func constraintsCounterLabel(){
        view.addSubview(counterLabel)
        NSLayoutConstraint.activate([
            counterLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            counterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterLabel.widthAnchor.constraint(equalToConstant: view.bounds.size.width - 30),
            counterLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    private func constraintsCounterButton(){
        view.addSubview(counterButton)
        NSLayoutConstraint.activate([
            counterButton.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 50),
            counterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterButton.widthAnchor.constraint(equalToConstant: 120),
            counterButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
}
