//
//  KeyboardViewController.swift
//  BondKeyboard
//
//  Created by Gani Rahmon on 5/01/19.
//  Copyright © 2019 Aminjoni Abdullozoda. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    

    var capButton: KeyboardButton!
    var numericButton: KeyboardButton!
    var deleteButton: KeyboardButton!
    var nextKeyboardButton: KeyboardButton!
    var returnButton: KeyboardButton!
    var spaceButton: KeyboardButton!
    
    var keyboardTopView: UIView!
    
    var isCapitalsShowing = false
    
    var areSymbolsShowing = false
    
    var areLettersShowing = true {
        
        didSet{
            
            if areLettersShowing {
                for view in mainStackView.arrangedSubviews {
                    view.removeFromSuperview()
                }
                
                keyboardTopView.removeFromSuperview()
                
                self.addKeyboardButtons()
                
            }else{
                displayNumericKeys()
            }
            
        }
        
    }
    
    var isContainerShowing = false {
        
        didSet{
            if isContainerShowing {
                self.childVCsNotif()
            }else {
                NotificationCenter.default.removeObserver(self, name: .childVCInformation, object: nil)
            }
        }
        
    }
    
    var allTextButtons = [CYRKeyboardButton]()
    
    var keyboardHeight: CGFloat = 216 + 64
    var KeyboardVCHeightConstraint: NSLayoutConstraint!
    var containerViewHeight: CGFloat = 0
    
    var leftRightMargin: CGFloat = 5
    
    var userLexicon: UILexicon?
    
    var mainStackView: UIStackView!
    
    var notificationDictionary = [String: Any]()
    
    var containerText: String = "" {
        
        didSet{
            self.notificationDictionary["txt"] = self.containerText
            NotificationCenter.default.post(name: .textProxyForContainer, object: nil, userInfo: self.notificationDictionary)
        }
        
    }
    
    
    var currentWord: String? {
        var lastWord: String?
        // 1
        if let stringBeforeCursor = textDocumentProxy.documentContextBeforeInput {
            // 2
            stringBeforeCursor.enumerateSubstrings(in: stringBeforeCursor.startIndex...,
                                                   options: .byWords)
            { word, _, _, _ in
                // 3
                if let word = word {
                    lastWord = word
                }
            }
        }
        return lastWord
    }
    
    var isNumberPadNeeded: Bool = false {
        
        didSet{
            
            if isNumberPadNeeded {
                // Show Number Pad
                self.showNumberPad()
            }else {
                // Show Default Keyboard
                for view in mainStackView.arrangedSubviews {
                    view.removeFromSuperview()
                }
                
                keyboardTopView.removeFromSuperview()
                
                self.addKeyboardButtons()
            }
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addKeyboardButtons()
        self.setNextKeyboardVisible(needsInputModeSwitchKey)
        self.KeyboardVCHeightConstraint = NSLayoutConstraint(item: self.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: keyboardHeight+containerViewHeight)
        self.view.addConstraint(self.KeyboardVCHeightConstraint)
        self.requestSupplementaryLexicon { (lexicon) in
            self.userLexicon = lexicon
        }
        self.createObeservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.removeConstraint(KeyboardVCHeightConstraint)
        self.view.addConstraint(self.KeyboardVCHeightConstraint)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Show Default Keyboard
        for view in mainStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        keyboardTopView.removeFromSuperview()
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            self.leftRightMargin = 30
            self.addKeyboardButtons()
        } else {
            self.leftRightMargin = 5
            self.addKeyboardButtons()
        }
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        setSchemeColor()
        
        //Sets return key title on keyboard...
        if let returnTitle = self.textDocumentProxy.returnKeyType {
            let type = UIReturnKeyType(rawValue: returnTitle.rawValue)
            guard let retTitle = type?.get(rawValue: (type?.rawValue)!) else {return}
            self.returnButton.setTitle(retTitle, for: .normal)
        }
    }
    
    func setSchemeColor() {
        let colorScheme: TajikColorScheme
        if textDocumentProxy.keyboardAppearance == .dark {
            colorScheme = .dark
        } else {
            colorScheme = .light
        }
        
        setColorScheme(colorScheme)
    }
    
    //Handles NextKeyBoard Button Appearance..
    
    func setNextKeyboardVisible(_ visible: Bool) {
        nextKeyboardButton.isHidden = !visible
    }
    
    //Set color scheme For keyboard appearance...
    func setColorScheme(_ colorScheme: TajikColorScheme) {
        let colorScheme = TajikColors(colorScheme: colorScheme)
        
        for view in keyboardTopView.subviews {
            if let stackView = view as? UIStackView {
                for sView in stackView.arrangedSubviews {
                    if let button = sView as? UIButton {
                         button.setTitleColor(colorScheme.buttonTextColor, for: [])
                    }
                }
            }
        }
        
        for button in allTextButtons {
            button.keyColor = colorScheme.buttonBackgroundColor
            button.keyTextColor = colorScheme.buttonTextColor
        }
    
        nextKeyboardButton.defaultBackgroundColor = colorScheme.buttonHighlightColor
        nextKeyboardButton.highlightBackgroundColor = colorScheme.buttonBackgroundColor
        nextKeyboardButton.setTitleColor(colorScheme.buttonTextColor, for: [])
        nextKeyboardButton.tintColor = colorScheme.buttonTextColor
        
        deleteButton.defaultBackgroundColor = colorScheme.buttonHighlightColor
        deleteButton.highlightBackgroundColor = colorScheme.buttonBackgroundColor
        deleteButton.setTitleColor(colorScheme.buttonTextColor, for: [])
        deleteButton.tintColor = colorScheme.buttonTextColor
        
        returnButton.defaultBackgroundColor = colorScheme.buttonHighlightColor
        returnButton.highlightBackgroundColor = colorScheme.buttonBackgroundColor
        returnButton.setTitleColor(colorScheme.buttonTextColor, for: [])
        returnButton.tintColor = colorScheme.buttonTextColor
        
        capButton.defaultBackgroundColor = colorScheme.buttonHighlightColor
        capButton.highlightBackgroundColor = colorScheme.buttonBackgroundColor
        capButton.setTitleColor(colorScheme.buttonTextColor, for: [])
        capButton.tintColor = colorScheme.buttonTextColor
        
        numericButton.defaultBackgroundColor = colorScheme.buttonHighlightColor
        numericButton.highlightBackgroundColor = colorScheme.buttonBackgroundColor
        numericButton.setTitleColor(colorScheme.buttonTextColor, for: [])
        numericButton.tintColor = colorScheme.buttonTextColor
        
        spaceButton.defaultBackgroundColor = colorScheme.buttonBackgroundColor
        spaceButton.highlightBackgroundColor = colorScheme.buttonHighlightColor
        spaceButton.setTitleColor(colorScheme.buttonTextColor, for: [])
        spaceButton.tintColor = colorScheme.buttonTextColor
    }
      
    private func addKeyboardButtons() {
        //My Custom Keys...
        //let zeroRowView = addRowsOnKeyboard(kbKeys: [,,])
        let firstRowView = addRowsOnKeyboard(kbKeys: ["й", "у", "к", "е", "н", "г", "ш", "з", "х","ъ"])
        let secondRowView = addRowsOnKeyboard(kbKeys: ["ф", "в", "а", "п", "р", "о", "л", "д", "ж", "э"])
        let thirdRowkeysView = addRowsOnKeyboard(kbKeys: ["я", "ч", "с", "м", "и","т", "б", "ю"])
        
        let (thirdRowSV,fourthRowSV) = serveiceKeys(midRow: thirdRowkeysView)
        
        // Add Row Views on Keyboard View... With a Single Stack View..
        
        self.mainStackView = UIStackView(arrangedSubviews: [firstRowView,secondRowView,thirdRowSV,fourthRowSV])
        mainStackView.axis = .vertical
        mainStackView.spacing = 10.0
        mainStackView.distribution = .fillEqually
        mainStackView.alignment = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leftRightMargin).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -leftRightMargin).isActive = true
        //mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        mainStackView.heightAnchor.constraint(equalToConstant: keyboardHeight).isActive = true
        
        addKeyboardTopView()
        
        setSchemeColor()
    }
    
    func addKeyboardTopView() {
        keyboardTopView = UIView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: 64))
        
        let topHelper = topTextButtons()
        topHelper.backgroundColor = keyboardTopView.backgroundColor
        topHelper.frame = CGRect(x: 0, y: 12, width: UIScreen.main.bounds.width, height: 40)
        keyboardTopView.addSubview(topHelper)
        
        view.addSubview(keyboardTopView)
        
        keyboardTopView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leftRightMargin).isActive = true
        keyboardTopView.bottomAnchor.constraint(equalTo: mainStackView.topAnchor, constant: -5).isActive = true
        keyboardTopView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -leftRightMargin).isActive = true
        keyboardTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        keyboardTopView.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    func serveiceKeys(midRow: UIView)->(UIStackView, UIStackView) {
        self.capButton = accessoryButtons(title: areLettersShowing ? nil : areSymbolsShowing ? "123" : "#+=", img: areLettersShowing ? #imageLiteral(resourceName: "captial1") : nil, tag: 1)
        self.deleteButton = accessoryButtons(title: nil, img: UIImage(named: "remove"), tag: 2)
        
        let thirdRowSV = UIStackView(arrangedSubviews: [self.capButton, midRow, self.deleteButton])
        thirdRowSV.distribution = .fillProportionally
        thirdRowSV.spacing = 5
        
        self.numericButton = accessoryButtons(title: areLettersShowing ? "123" : "АБВ", img: nil, tag: 3)
        self.nextKeyboardButton = accessoryButtons(title: nil, img: UIImage(named: "land"), tag: 4)
        self.spaceButton = accessoryButtons(title: "фосила", img: nil, tag: 6)
        self.returnButton = accessoryButtons(title: "return", img: nil, tag: 7)
        
        let fourthRowSV = UIStackView(arrangedSubviews: [self.numericButton,self.nextKeyboardButton,self.spaceButton,self.returnButton])
        fourthRowSV.distribution = .fillProportionally
        fourthRowSV.spacing = 8
        
        return (thirdRowSV,fourthRowSV)
    }
    
    func topTextButtons() -> UIStackView {
        
        let helloBtn = UIButton(frame: CGRect(x:0, y:0, width: 80, height: 40))
        helloBtn.titleLabel?.numberOfLines = 0
        helloBtn.titleLabel?.textAlignment = .center
        helloBtn.setTitleColor(.black, for: [])
        helloBtn.setTitle("Салом", for: .normal)
        helloBtn.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        
        let separatorHelloBtn = UIView(frame: CGRect(x:0, y:0, width: 1, height: 40))
        separatorHelloBtn.backgroundColor = .lightGray
        separatorHelloBtn.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        let byeBtn = UIButton(frame: CGRect(x:0, y:0, width: 80, height: 40))
        byeBtn.titleLabel?.numberOfLines = 0
        byeBtn.setTitleColor(.black, for: [])
        byeBtn.titleLabel?.textAlignment = .center
        byeBtn.setTitle("Хай", for: .normal)
        byeBtn.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        
        let separatorByeBtn = UIView(frame: CGRect(x:0, y:0, width: 1, height: 40))
        separatorByeBtn.backgroundColor = .lightGray
        separatorByeBtn.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        let thanksBtn = UIButton(frame: CGRect(x:0, y:0, width: 80, height: 40))
        thanksBtn.titleLabel?.numberOfLines = 0
        thanksBtn.titleLabel?.textAlignment = .center
        thanksBtn.setTitleColor(.black, for: [])
        thanksBtn.setTitle("Раҳмат", for: .normal)
        thanksBtn.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        
        let separatorThanksBtn = UIView(frame: CGRect(x:0, y:0, width: 1, height: 40))
        separatorThanksBtn.backgroundColor = .lightGray
        separatorThanksBtn.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        let okBtn = UIButton(frame: CGRect(x:0, y:0, width: 80, height: 40))
        okBtn.titleLabel?.numberOfLines = 0
        okBtn.titleLabel?.textAlignment = .center
        okBtn.setTitleColor(.black, for: [])
        okBtn.setTitle("Хуб", for: .normal)
        okBtn.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        
        let topSV = UIStackView(arrangedSubviews: [helloBtn, separatorHelloBtn, byeBtn, separatorByeBtn, thanksBtn, separatorThanksBtn, okBtn])
        topSV.distribution = .fillProportionally
        topSV.spacing = 5
        
        return topSV
    }
    
    
    // Adding Keys on UIView with UIStack View..
    func addRowsOnKeyboard(kbKeys: [String]) -> UIView {
        
        let RowStackView = UIStackView.init()
        RowStackView.spacing = 5
        RowStackView.axis = .horizontal
        RowStackView.alignment = .fill
        RowStackView.distribution = .fillEqually
        
        for key in kbKeys {
            RowStackView.addArrangedSubview(createButtonWithTitle(title: key))
        }
        
        let keysView = UIView()
        keysView.backgroundColor = .clear
        keysView.addSubview(RowStackView)
        keysView.addConstraintsWithFormatString(formate: "H:|[v0]|", views: RowStackView)
        keysView.addConstraintsWithFormatString(formate: "V:|[v0]|", views: RowStackView)
        return keysView
    }

    // Creates Buttons on Keyboard...
    func createButtonWithTitle(title: String) -> CYRKeyboardButton {
        
        let button = CYRKeyboardButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.input = title
        button.textDocumentProxy = self.textDocumentProxy
        
        switch title{
        case "и":
            button.inputOptions = ["и","ӣ"]
        case "е":
            button.inputOptions = ["е", "ё"]
        case "х":
            button.inputOptions = ["х", "ҳ"]
        case "г":
            button.inputOptions = ["г", "ғ"]
        case "у":
            button.inputOptions = ["у", "ӯ"]
        case "ч":
            button.inputOptions = ["ч", "ҷ"]
        case "к":
            button.inputOptions = ["к", "қ"]
        default:
            print("Default")
        }
        
        allTextButtons.append(button)
        
        return button
    }
    
    // Accesory Buttons On Keyboard...
    
    func accessoryButtons(title: String?, img: UIImage?, tag: Int) -> KeyboardButton {
        
        let button = KeyboardButton.init(type: .system)
        
        if let buttonTitle = title {
            button.setTitle(buttonTitle, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        }
        
        if let buttonImage = img {
            button.setImage(buttonImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
       
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = tag
        
        //For Capitals...
        if button.tag == 1 {
            button.addTarget(self, action: #selector(handleCapitalsAndLowerCase(sender:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            return button
        }
        //For BackDelete Key // Install Once Only..
        if button.tag == 2 {
            let longPrssRcngr = UILongPressGestureRecognizer.init(target: self, action: #selector(onLongPressOfBackSpaceKey(longGestr:)))
            
            //if !(button.gestureRecognizers?.contains(longPrssRcngr))! {
            longPrssRcngr.minimumPressDuration = 0.5
            longPrssRcngr.numberOfTouchesRequired = 1
            longPrssRcngr.allowableMovement = 0.1
            button.addGestureRecognizer(longPrssRcngr)
            //}
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }
        //Switch to and From Letters & Numeric Keys
        if button.tag == 3 {
            button.addTarget(self, action: #selector(handleSwitchingNumericsAndLetters(sender:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.setTitleColor(.black, for: .normal)

            return button
        }
        //Next Keyboard Button... Globe Button Usually...
        if button.tag == 4 {
            button.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true

            return button
        }

        //White Space Button...
        if button.tag == 6 {

            button.addTarget(self, action: #selector(insertWhiteSpace), for: .touchUpInside)
            //button.widthAnchor.constraint(equalToConstant: 120).isActive = true

            return button
        }
        //Handle return Button...//Usually depends on Texyfiled'd return Type...
        if button.tag == 7 {
            button.addTarget(self, action: #selector(handleReturnKey(sender:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 80).isActive = true
            button.setTitleColor(.black, for: .normal)
            return button
        }
        //Else Case... For Others
        button.addTarget(self, action: #selector(manualAction(sender:)), for: .touchUpInside)
        return button
        
    }
    
    @objc func didTapButton(sender: UIButton) {
        
        let button = sender as UIButton
        //        self.manageShadowsOnKeys(button: button, isShadowsNeeded: false)
        guard let title = button.titleLabel?.text else { return }
        let proxy = self.textDocumentProxy
        
        UIView.animate(withDuration: 0.25, animations: {
            button.transform = CGAffineTransform(scaleX: 1.20, y: 1.20)
            self.inputView?.playInputClick​()
            if self.isContainerShowing {
                self.containerText = self.containerText + title
                
            }else{
                if !self.isContainerShowing {
                    proxy.insertText(title)
                }
            }
            
        }) { (_) in
            UIView.animate(withDuration: 0.10, animations: {
                button.transform = CGAffineTransform.identity
                //                self.manageShadowsOnKeys(button: button, isShadowsNeeded: true)
            })
        }
        
    }
    
    @objc func onLongPressOfBackSpaceKey(longGestr: UILongPressGestureRecognizer) {
        
        switch longGestr.state {
        case .began:
            if isContainerShowing {
                
                self.containerText = String.init((self.containerText.dropLast()))
                
            } else {
                self.textDocumentProxy.deleteBackward()
               // deleteLastWord()
            }
            
        case .ended:
            print("Ended")
            return
        default:
            self.textDocumentProxy.deleteBackward()
            //deleteLastWord()
        }
        
    }
    
    @objc func handleCapitalsAndLowerCase(sender: UIButton) {
        
        if areLettersShowing {
            areSymbolsShowing = false
            for button in allTextButtons {
                if let title = button.input {
                    button.input = isCapitalsShowing ? title.lowercased() : title.uppercased()
                    
                    switch title{
                    case "и", "И":
                        button.inputOptions = isCapitalsShowing ? ["и",  "ӣ"] : ["И","Ӣ"]
                    case "е", "Е":
                        button.inputOptions = isCapitalsShowing ? ["е", "ё"] : ["Е", "Ё"]
                    case "х", "Х":
                        button.inputOptions = isCapitalsShowing ? ["х", "ҳ"] : ["Х", "Ҳ"]
                    case "г", "Г":
                        button.inputOptions = isCapitalsShowing ? ["г", "ғ"] : ["Г", "Ғ"]
                    case "у", "У":
                        button.inputOptions = isCapitalsShowing ? ["у", "ӯ"] : ["У", "Ӯ"]
                    case "ч", "Ч":
                        button.inputOptions = isCapitalsShowing ? ["ч", "ҷ"] : ["Ч", "Ҷ"]
                    case "к", "К":
                        button.inputOptions = isCapitalsShowing ? ["к", "қ"] : ["К", "Қ"]
                    default:
                        print("Default")
                    }
                }
            }
            
            isCapitalsShowing = !isCapitalsShowing
        } else {
            if areSymbolsShowing {
                areSymbolsShowing = false
                displayNumericKeys()
                
            } else {
                areSymbolsShowing = true
                displaySymbolKeys()
            }
        }
    }
    
    @objc func handleSwitchingNumericsAndLetters(sender: UIButton) {
        areLettersShowing = !areLettersShowing
        areSymbolsShowing = false
    }
    
    @objc func HandlePaymentContainer() {
        isContainerShowing = !isContainerShowing
        self.handleContainerDisplay()
    }
    
    @objc func insertWhiteSpace() {
        
        attemptToReplaceCurrentWord()
        let proxy = self.textDocumentProxy
        proxy.insertText(" ")
        print("white space")
    }
    
    @objc func handleReturnKey(sender: UIButton) {
//        if let _ = self.textDocumentProxy.documentContextBeforeInput {
             self.textDocumentProxy.insertText("\n")
//        }
       
       // print("Return Type is handled here...")
    }
    
    
    @objc func manualAction(sender: UIButton) {
        let proxy = self.textDocumentProxy
        
        if isContainerShowing {
            
            self.containerText = String.init((self.containerText.dropLast()))
            
        } else {
            proxy.deleteBackward()
        }
        print("Else Case... Remaining Keys")
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func createObeservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotifs(notf:)), name: .containerShowAndHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotifs(notf:)), name: .textProxyNilNotification, object: nil)
    }
    
    
    @objc func handleNotifs(notf: Notification) {
        if notf.name == .textProxyNilNotification {
            self.containerText = ""
            return
        }
        if notf.name == .containerShowAndHideNotification {
            resignFirstResponder()
            self.HandlePaymentContainer()
            
            OperationQueue.current?.addOperation {
                self.textDocumentProxy.insertText("The amount Rs.100 has been credited to your wallet...")
            }
            //self.textDocumentProxy.insertText("The amount Rs.100 has been credited to your wallet...")
        }
    }
    
    //Show Payments Container as needed...
    func handleContainerDisplay() {
        self.KeyboardVCHeightConstraint.isActive = false
        
        UIView.animate(withDuration: 0.35) {
            self.KeyboardVCHeightConstraint.isActive = true
            
            if self.isContainerShowing {
                self.containerViewHeight = 150
                self.KeyboardVCHeightConstraint.constant = self.keyboardHeight+self.containerViewHeight
                self.presentContainerVC()
                return
            } else {
                self.isNumberPadNeeded = false
                self.containerViewHeight = 0
                self.KeyboardVCHeightConstraint.constant = self.keyboardHeight
                if self.view.subviews.contains(self.mainVC.view) {
                    self.removeViewControllerAsChildViewController(childViewController: self.mainVC)
                }
                return
            }
        }
        self.view.layoutIfNeeded()

    }
    
    
    // Add Child VC as container...
    
    lazy var mainVC: MainVC = {
        var viewController = MainVC()
        return viewController
    }()
    
    func presentContainerVC() {
        self.addViewControllerAsChildViewController(childViewController: mainVC)
    }
    
    
    private func addViewControllerAsChildViewController(childViewController: UIViewController) {
        
        addChildViewController(childViewController)
        view.addSubview(childViewController.view)
        childViewController.view.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-keyboardHeight)
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childViewController.didMove(toParentViewController: self)
        
    }
    
    private func removeViewControllerAsChildViewController(childViewController: UIViewController) {
        
        childViewController.willMove(toParentViewController: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
        
    }
    
    func childVCsNotif() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleChildVCNotifs(notf:)), name: .childVCInformation, object: nil)
        
    }
    
    @objc func handleChildVCNotifs(notf: Notification) {
        
        if let _ = notf.object as? ProcessVC {
           // Show Number Pad on View
            isNumberPadNeeded = true
            return
        }
        
        if let _ = notf.object as? ResultVC {
            // Show Number Pad on View
            isNumberPadNeeded = true
            return
        }
        
        isNumberPadNeeded = false
        
    }
    
    
    func showNumberPad() {
        
        for view in mainStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        let firstRow = [".","0"]
        let secRow = ["1","2","3"]
        let thirdRow = ["4","5","6"]
        let fourthRow = ["7","8","9"]
        
        self.deleteButton = accessoryButtons(title: nil, img: #imageLiteral(resourceName: "backspace"), tag: 2)

        let first = addRowsOnKeyboard(kbKeys: firstRow)
        let second = addRowsOnKeyboard(kbKeys: secRow)
        let third = addRowsOnKeyboard(kbKeys: thirdRow)
        let fourth = addRowsOnKeyboard(kbKeys: fourthRow)
        
        let fsv = UIStackView(arrangedSubviews: [first, deleteButton])
        fsv.alignment = .fill
        fsv.distribution = .fill
        fsv.spacing = 5
        
        deleteButton.widthAnchor.constraint(equalTo: fsv.widthAnchor, multiplier: 1.0/3.0, constant: -5.0).isActive = true

        mainStackView.addArrangedSubview(fourth)
        mainStackView.addArrangedSubview(third)
        mainStackView.addArrangedSubview(second)
        mainStackView.addArrangedSubview(fsv)

    }
    
    func displayNumericKeys() {
        
        for view in mainStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        let nums = ["1","2","3","4","5","6","7","8","9","0"]
        let splChars1 = ["-","/",":",";","(",")","$","&","@","*"]
        let splChars2 = [".",",","?","!","’"]
        
        let numsRow = self.addRowsOnKeyboard(kbKeys: nums)
        let splChars1Row = self.addRowsOnKeyboard(kbKeys: splChars1)
        let splChars2Row = self.addRowsOnKeyboard(kbKeys: splChars2)

         let (thirdRowSV,fourthRowSV) = serveiceKeys(midRow: splChars2Row)
        
        mainStackView.addArrangedSubview(numsRow)
        mainStackView.addArrangedSubview(splChars1Row)
        mainStackView.addArrangedSubview(thirdRowSV)
        mainStackView.addArrangedSubview(fourthRowSV)
        
        setSchemeColor()
    }
    
    func displaySymbolKeys() {
        
        for view in mainStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        let nums = ["[","]","{","}","#","%","ˆ","*","+","="]
        let splChars1 = ["_","\\","|","~","<",">","€","£","¥","•"]
        let splChars2 = [".",",","?","!","’"]
        
        let numsRow = self.addRowsOnKeyboard(kbKeys: nums)
        let splChars1Row = self.addRowsOnKeyboard(kbKeys: splChars1)
        let splChars2Row = self.addRowsOnKeyboard(kbKeys: splChars2)
        
        let (thirdRowSV,fourthRowSV) = serveiceKeys(midRow: splChars2Row)
        
        mainStackView.addArrangedSubview(numsRow)
        mainStackView.addArrangedSubview(splChars1Row)
        mainStackView.addArrangedSubview(thirdRowSV)
        mainStackView.addArrangedSubview(fourthRowSV)
        
        setSchemeColor()
    }
}


private extension KeyboardViewController {
    func attemptToReplaceCurrentWord() {
        // 1
        guard let entries = userLexicon?.entries,
            let currentWord = currentWord?.lowercased() else {
                return
        }
        
        // 2
        let replacementEntries = entries.filter {
            $0.userInput.lowercased() == currentWord
        }
        
        if let replacement = replacementEntries.first {
            // 3
            for _ in 0..<currentWord.count {
                textDocumentProxy.deleteBackward()
            }
            
            // 4
            textDocumentProxy.insertText(replacement.documentText)
        }
    }
}
