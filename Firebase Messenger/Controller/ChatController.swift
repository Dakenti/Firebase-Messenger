//
//  ChatController.swift
//  Firebase Messenger
//
//  Created by Dake Aga on 2/6/19.
//  Copyright © 2019 Dake Aga. All rights reserved.
//

import UIKit
import Firebase

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    let cellId = "cellId"
    
    var messages = [Message]()
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    var user: User? {
        didSet{
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Type Your Message Here"
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.title = "Chat Log Controller"
        
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.backgroundColor = .white
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.keyboardDismissMode = .interactive
//        setupChatController()
//
//        setupKeyboardObserver()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        NotificationCenter.default.removeObserver(self)
//    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendButtonPress), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        seperatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        
        containerView.addSubview(seperatorLineView)
        
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
//    func setupKeyboardObserver(){
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    @objc func handleKeyboardWillShow(notification: Notification){
//        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else { fatalError() }
//
//        guard let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue  else { fatalError() }
//
//        self.containerViewBottomAnchor?.constant = -keyboardFrame.height
//        UIView.animate(withDuration: duration) {
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    @objc func handleKeyboardWillHide(notification: Notification){
//        guard let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { fatalError() }
//
//        containerViewBottomAnchor?.constant = 0
//        UIView.animate(withDuration: duration) {
//            self.view.layoutIfNeeded()
//        }
//    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else { fatalError() }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messagesRef = Database.database().reference().child("messages").child(snapshot.key)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : AnyObject] else { fatalError() }
                let message = Message(dictionary: dictionary)
                
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
                
            }, withCancel: nil)

        }, withCancel: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButtonPress()
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        cell.bubleViewWidthAnchor?.constant = estimatedFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        guard let imageUrl = user?.loginImage else { fatalError() }
        cell.profileImageView.loadImagesUsingCacheWithURL(urlString: imageUrl)
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubleViewRightAnchor?.isActive = true
            cell.bubleViewLeftAnchor?.isActive = false
        } else {
            cell.bubleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.bubleViewRightAnchor?.isActive = false
            cell.bubleViewLeftAnchor?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        height = estimatedFrameForText(text: messages[indexPath.item].text!).height
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height + 20)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
//    func setupChatController(){
//        let containerView = UIView()
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.backgroundColor = .white
//
//        view.addSubview(containerView)
//
//        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        containerViewBottomAnchor?.isActive = true
//
//        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//
//        let sendButton = UIButton(type: .system)
//        sendButton.setTitle("Send", for: .normal)
//        sendButton.translatesAutoresizingMaskIntoConstraints = false
//        sendButton.addTarget(self, action: #selector(handleSendButtonPress), for: .touchUpInside)
//
//        containerView.addSubview(sendButton)
//
//        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//
//
//        containerView.addSubview(inputTextField)
//
//        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 16).isActive = true
//        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
//        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//
//        let seperatorLineView = UIView()
//        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
//        seperatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
//
//        containerView.addSubview(seperatorLineView)
//
//        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
//        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
//        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
//    }
    
    @objc func handleSendButtonPress(){
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let values = ["text":inputTextField.text!, "toId":toId, "fromId":fromId, "timestamp":timestamp] as [String : Any]
//        childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error ?? "")
                return
            }
            
            guard let messageId = childRef.key else { fatalError() }
            
            let senderMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            senderMessagesRef.updateChildValues([messageId:1])
            
            let recipientMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientMessagesRef.updateChildValues([messageId:1])
        }
       
        
    }
    
}
