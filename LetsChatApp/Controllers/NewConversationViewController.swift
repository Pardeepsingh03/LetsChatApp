//
//  NewConversationViewController.swift
//  LetsChatApp
//
//  Created by MBA-0019 on 27/07/23.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    let spinner = JGProgressHUD()
    public var completion: (([String:String]) -> (Void))?
    private var userData = [[String:String]]()
    private var results = [[String:String]]()
    private var fetchDetails: Bool = false
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noconversation: UILabel = {
        let noconvo = UILabel()
        noconvo.text = "No Profiles!"
        noconvo.textColor = .gray
        noconvo.textAlignment = .center
        noconvo.font = .systemFont(ofSize: 21,weight: .medium)
        noconvo.isHidden = true
        return noconvo
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noconversation)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissView))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noconversation.frame = CGRect(x: view.frame.width/4, y: (view.frame.height-200)/2, width: view.frame.width/2, height: 200)
    }
    
    @objc private func dismissView(){
        dismiss(animated: true)
    }
}

extension NewConversationViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUser = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUser)
          
        }
       
    }
    
    
}

extension NewConversationViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,!text.replacingOccurrences(of: " ", with: "").isEmpty else {return}
        results.removeAll()
        searchBar.resignFirstResponder()
        spinner.show(in: view)
        self.searchUsers(query:text)
    }
    
    func searchUsers(query: String){
        if fetchDetails{
            searchUser(with: query)
        }
        else{
            DatabaseManager.shared.fetchAllData {[weak self] results in
                guard let strongSelf = self else {return}
                switch results{
                case .success(let collections):
                    strongSelf.userData.append(contentsOf: collections)
                    strongSelf.fetchDetails = true
                    strongSelf.searchUser(with: query)
                case .failure(let error):
                    print("Error in fetching details : \(error)")
                }
            }
        }
        
    }
    
    func searchUser(with: String){
        guard fetchDetails else {
            return
        }
        self.spinner.dismiss()
        let results: [[String:String]] = self.userData.filter {
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(with.lowercased())
        }
        self.results = results
        updateUI()
        
    }
    
    func updateUI(){
        if results.isEmpty{
            self.noconversation.isHidden = false
            self.tableView.isHidden = true
        }
        else{
            self.noconversation.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
