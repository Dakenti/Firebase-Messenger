//
//  ViewController.swift
//  Firebase Messenger
//
//  Created by Dake Aga on 1/12/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {
    
    var messages = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessages))
        
        checkIfUserIsLoggedIn()
        
        observeMessages()
        
    }
    
    func observeMessages(){
        let ref = Database.database().reference().child("Messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:Any]{
                let message = Message(dictionary: dictionary)
                self.messages.append(message)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.fromId
        cell.detailTextLabel?.text = message.text
        
        return cell
    }
    
    @objc func handleNewMessages(){
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserIsLoggedIn()
        }
    }
    
    func fetchUserIsLoggedIn() {
        guard let uid = Auth.auth().currentUser?.uid else { fatalError() }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
//                self.navigationItem.title = dictionary["name"] as? String
                let user = User(dictionary: dictionary)
                self.setupCustomNavbar(user: user)
            }
        }, withCancel: nil)
    }
    
    func setupCustomNavbar(user: User){
        let titleView = UIView()
//        titleView.backgroundColor = UIColor.red
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)

        let currentUserPicture : UIImageView = {
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.layer.cornerRadius = 20
            iv.layer.masksToBounds = true
            iv.contentMode = .scaleAspectFill
            return iv
        }()

        let userName: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

        guard let userPictureStringUrl = user.loginImage else {fatalError()}
        currentUserPicture.loadImagesUsingCacheWithURL(urlString: userPictureStringUrl)
        titleView.addSubview(currentUserPicture)

        currentUserPicture.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        currentUserPicture.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        currentUserPicture.widthAnchor.constraint(equalToConstant: 40).isActive = true
        currentUserPicture.heightAnchor.constraint(equalToConstant: 40).isActive = true

        guard let currentUserName = user.name else {fatalError()}
        userName.text = currentUserName
        titleView.addSubview(userName)

        userName.leftAnchor.constraint(equalTo: currentUserPicture.rightAnchor).isActive = true
        userName.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        userName.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        userName.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
//        let button = UIButton(type: .system)
//
//        button.setTitle(user.name, for: .normal)
        self.navigationItem.titleView = titleView
//        button.addTarget(self, action: #selector(showChatLogControllerMessages), for: .touchUpInside)

    }
    
    func showChatLogControllerMessages(user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    @objc func handleLogout() {
        
        do{
            try Auth.auth().signOut()
        } catch let loginError{
            print(loginError)
        }
        
        let loginViewController = LoginViewController()
        loginViewController.messageController = self
        present(loginViewController, animated: true, completion: nil)
    }

}

