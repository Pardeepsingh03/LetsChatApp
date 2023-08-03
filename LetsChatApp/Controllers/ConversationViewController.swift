
struct Conversation {
    var id: String
    var name: String
    var otherUserEmail: String
    var lastesMessage: LatestMessage
}

struct LatestMessage {
    var date: String
    var text: String
    var isRead: Bool
}

import UIKit
import FirebaseAuth
import JGProgressHUD
class ConversationViewController: UIViewController {
    
    private var conversation = [Conversation]()
    private let spinner = JGProgressHUD(style: .dark)
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    private let noconversation: UILabel = {
        let noconvo = UILabel()
        noconvo.text = "No conversations!"
        noconvo.textColor = .gray
        noconvo.textAlignment = .center
        noconvo.font = .systemFont(ofSize: 21,weight: .medium)
        noconvo.isHidden = true
        return noconvo
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(showNewConvo))
        view.addSubview(tableView)
        view.addSubview(noconversation)
        fetchAllConversation()
        startListeningForConversations()
    }
    
    private func startListeningForConversations(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return}
        let safeEmail = DatabaseManager.safeEmail(email: email)
        DatabaseManager.shared.getAllConversation(email: safeEmail) {[weak self] results in
            switch results {
            case .success(let response):
                guard !response.isEmpty else {
                    return
                }
                self?.conversation = response
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error in fetching the details : \(error)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
       isUserValidate()
    }
    
    private func isUserValidate(){
        if Auth.auth().currentUser == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchAllConversation(){
        tableView.isHidden = false
        
    }
    @objc private func showNewConvo(){
        let vc = NewConversationViewController()
        vc.completion = {[weak self] resultss in
            print(resultss)
            self?.createNewConversation(with: resultss)
        }
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    func createNewConversation(with results: [String:String]){
        guard let name = results["name"], let email = results["email"] else {return}
        let vc = ChatViewController(other: email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ConversationViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversation[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController(other: conversation[indexPath.row].otherUserEmail, id: conversation[indexPath.row].id)
        vc.title = conversation[indexPath.row].name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
}
