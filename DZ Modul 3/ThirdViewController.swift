//
//  ThirdViewController.swift
//  DZ Modul 3
//
//  Created by Vladimir Karsakov on 04.08.2021.
//
//5. В реактивном виде реализуйте следующие задачи:
//     c) UITableView с выводом 20 разных имён людей и две кнопки. Одна кнопка добавляет новое случайное имя в начало списка, вторая — удаляет последнее имя. Список реактивно связан с UITableView. Добавьте поисковую строку. При вводе текста в поисковой строке, если текст не изменялся в течение двух секунд, выполните фильтрацию имён по введённой поисковой строке. Такой подход применяется в реальных приложениях при поиске, который отправляет поисковый запрос на сервер, — чтобы не перегружать сервер и поисковая строка отправлялась на сервер, только когда пользователь закончит ввод (или сделает паузу во вводе).

import UIKit
import ReactiveKit
import Bond

class ThirdViewController: UIViewController {
    
    private let addRandomNameButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Добавить", for: .normal)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(touchDownAddButton), for: .touchDown)
        button.addTarget(self, action: #selector(touchUpInsideAddButton), for: .touchUpInside)
        return button
    }()
    private let deleteLastNameButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 6
        button.addTarget(self, action: #selector(touchDownDeleteButton), for: .touchDown)
        button.addTarget(self, action: #selector(touchUpInsideDeleteButton), for: .touchUpInside)
        return button
    }()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 10
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        return tableView
    }()
    
    private let searchController: UISearchController = {
        let searchCont = UISearchController(searchResultsController: nil)
        searchCont.searchBar.placeholder = "Введите имя"
        searchCont.obscuresBackgroundDuringPresentation = false
        return searchCont
    }()
    
    private let originalNamesArray = ["Vova", "Kolya", "Petya", "Dima", "Katya", "Dasha", "Masha", "Olya", "Vika", "Veronika", "Alla", "Masha", "Marina", "Diana", "Ulya", "Nastya", "Ksusha", "Rita", "Natasha", "Sveta"]
    private var namesArray = MutableObservableArray(["Vova", "Kolya", "Petya", "Dima", "Katya", "Dasha", "Masha", "Olya", "Vika", "Veronika", "Alla", "Masha", "Marina", "Diana", "Ulya", "Nastya", "Ksusha", "Rita", "Natasha", "Sveta"])
    private var filteredNames = MutableObservableArray([""])
    
    private let isActiveDeleteButtons = Property(true)
            
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = #colorLiteral(red: 0.6499652863, green: 1, blue: 0.6309222579, alpha: 1)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(goToBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(goToNext))
        
        self.title = "The third task"
        
        navigationItem.searchController = searchController
        setupSearchBarCustomization()
        
        constraintAddRandomButton()
        constraintDeleteLastNameButton()
        constraintTableView()
        
        tableView.delegate = self
        searchController.searchBar.delegate = self
        
        settingsButtons()
        
        createAndFilteredTableView()
    }
    
    //создаем таблицу с текстом из массива + фильтруем ее исходя из текста, введенного пользователем в search bar
    private func createAndFilteredTableView() {
        
        filteredNames.bind(to: tableView) { (dataSource, indexPath, tableView) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell")!
            cell.textLabel?.text = dataSource[indexPath.row]
            return cell
        }
        
        searchController.searchBar.reactive.text
            .ignoreNils()
            .debounce(for: 0.3)
//            .throttle(for: 0.3)
            .observeNext { [self] query in
                if !query.isEmpty{
                    namesArray.filterCollection{($0.lowercased().contains(query.lowercased()))}
                        .bind(to: filteredNames)
                } else {
                    namesArray.bind(to: filteredNames)
                }
            }
            .dispose(in: reactive.bag)
    }
    
    private func settingsButtons() {
        //если массив пустой, то передаем bool значение в переменную
        filteredNames
            .map { $0.collection.isEmpty ? false : true }
            .bind(to: isActiveDeleteButtons)
        
        //если массив пустой и значение isActiveDeleteButtons = false, то кнопка deleteLastNameButton не активна
        isActiveDeleteButtons
            .bind(to: deleteLastNameButton.reactive.isEnabled)
        
        //если массив пустой и значение isActiveDeleteButtons = false, то значение alpha у кнопки deleteLastNameButton = 0.7
        isActiveDeleteButtons
            .map { $0 == true ? 1 : 0.7 }
            .bind(to: deleteLastNameButton.reactive.alpha)
    }
    
    @objc private func goToNext(){
        let fourthVC = FourthViewController()
        navigationController?.pushViewController(fourthVC, animated: true)
    }
    
    @objc private func goToBack(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func touchDownAddButton(){
        UIView.animate(withDuration: 0.05) {
            self.addRandomNameButton.alpha = 0.7
        }
    }
    
    @objc private func touchUpInsideAddButton(){
        UIView.animate(withDuration: 0.3) {
            self.addRandomNameButton.alpha = 1
        }
        //Беру имена из оригинального списка и добавляю новое рандомное имя из этого списка в изменяемый массив в начало списка
        guard let randomName = originalNamesArray.randomElement() else { return }
        filteredNames.insert(randomName, at: 0)
    }
    
    @objc private func touchDownDeleteButton(){
        UIView.animate(withDuration: 0.05) {
            self.deleteLastNameButton.alpha = 0.7
        }
    }
    
    @objc private func touchUpInsideDeleteButton(){
        UIView.animate(withDuration: 0.3) {
            self.deleteLastNameButton.alpha = 1
        }
        //удаляю последнее имя из списка
        self.filteredNames.removeLast()
    }
    
    private func setupSearchBarCustomization(){
        let textField = searchController.searchBar.searchTextField
        textField.backgroundColor = .white
    }
    
    private func constraintAddRandomButton(){
        view.addSubview(addRandomNameButton)
        NSLayoutConstraint.activate([
            addRandomNameButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            addRandomNameButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            addRandomNameButton.widthAnchor.constraint(equalToConstant: view.bounds.size.width / 2 - 50),
            addRandomNameButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    private func constraintDeleteLastNameButton(){
        view.addSubview(deleteLastNameButton)
        NSLayoutConstraint.activate([
            deleteLastNameButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            deleteLastNameButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            deleteLastNameButton.leftAnchor.constraint(equalTo: addRandomNameButton.rightAnchor, constant: 10),
            deleteLastNameButton.widthAnchor.constraint(equalTo: addRandomNameButton.widthAnchor),
            deleteLastNameButton.heightAnchor.constraint(equalTo: addRandomNameButton.heightAnchor)
        ])
    }
    private func constraintTableView(){
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: addRandomNameButton.bottomAnchor, constant: 20),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -5),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
    }
}

extension ThirdViewController: UITableViewDelegate, UISearchBarDelegate{
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 22
    }
    //MARK: - UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        namesArray.bind(to: filteredNames)
        print("Cancel push")
    }
}
