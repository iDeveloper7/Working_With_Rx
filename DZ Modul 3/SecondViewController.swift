//
//  SecondViewController.swift
//  DZ Modul 3
//
//  Created by Vladimir Karsakov on 03.08.2021.
//
//5. В реактивном виде реализуйте следующие задачи:
//     b) Текстовое поле для ввода поисковой строки. Реализуйте симуляцию «отложенного» серверного запроса при вводе текста: если не было внесено никаких изменений в текстовое поле в течение 0,5 секунд, то в лэйбл должно выводиться: «Отправка запроса для <введенный текст в текстовое поле>».

import UIKit
import ReactiveKit
import Bond

class SecondViewController: UIViewController {
    
    private let searchController = UISearchController()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .blue
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var currentTextSearchBar = Property("")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController

        view.backgroundColor = .white
        
        self.title = "The second task"
        
        printText()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(goToBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(goToNextVC))
        
        constraintTextLabel()
    }
    
    @objc private func goToNextVC(){
        let thirdVC = ThirdViewController()
        
        navigationController?.pushViewController(thirdVC, animated: true)
    }
    
    @objc private func goToBack(){
        dismiss(animated: true, completion: nil)
    }
    
    private func printText(){
        searchController.searchBar.reactive.text
            .compactMap { $0 }
            .debounce(for: 0.5)
            .map { $0.isEmpty ? "" : "Отправка запроса для \($0)" }
            .bind(to: textLabel.reactive.text)
    }
    
    private func constraintTextLabel(){
        view.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}
