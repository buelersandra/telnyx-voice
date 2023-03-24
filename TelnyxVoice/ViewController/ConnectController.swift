//
//  ConnectController.swift
//  TelnyxVoice
//
//  Created by Beulah Ana on 3/18/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow



class ConnectController: UIViewController, Stepper {
    
    let steps = PublishRelay<Step>()
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        
    let viewModel: ConnectViewModel
    let disposeBag = DisposeBag()
    
    init(viewModel: ConnectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    lazy var connectionStateLabel:UILabel = {
        let view = UILabel()
        view.font = UIFont(name: view.font.fontName, size: 15)
        view.textColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        return view
    }()
    
    lazy var connectClientBtn:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont(name: view.titleLabel?.font.fontName ?? "", size: 20)
        return view
    }()
    
    lazy var makeCallBtn:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont(name: view.titleLabel?.font.fontName ?? "", size: 20)
        view.setTitle( "Make a call", for: .normal)
        return view
    }()
    
    lazy var acceptCallBtn:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont(name: view.titleLabel?.font.fontName ?? "", size: 20)
        view.setTitle( "Accept Call", for: .normal)
        return view
    }()
    
    lazy var usernameLbl:UILabel = {
        let view = UILabel()
        view.font = UIFont(name: view.font.fontName, size: 15)
        view.textColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.text = "Username"
        return view
    }()
    
    lazy var passwordLbl:UILabel = {
        let view = UILabel()
        view.font = UIFont(name: view.font.fontName, size: 15)
        view.textColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.text = "Password"
        return view
    }()
    
    lazy var usernameField:UITextField = {
        let view = UITextField()
        view.placeholder = "Username"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.borderStyle = .line
        view.backgroundColor = .white
        view.font = UIFont(name: view.font?.fontName ?? "", size: 20)
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.text = ""
        return view
    }()
    
    lazy var passwordField:UITextField = {
        let view = UITextField()
        view.placeholder = "Password"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.borderStyle = .line
        view.backgroundColor = .white
        view.font = UIFont(name: view.font?.fontName ?? "", size: 20)
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.text = ""
        return view
    }()
    
    lazy var stackView:UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fillEqually
        view.spacing = 10
        return view;
    }()
    
    lazy var endCallBtn:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("End Call", for: .normal)
        view.backgroundColor = .red
        view.setTitleColor(.white, for: .normal)
        return view
    }()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindView()
    }
    
    func bindView(){
        
        
        viewModel.connect(username: usernameField.rx.text.orEmpty.asObservable(), password: passwordField.rx.text.orEmpty.asObservable(), didPressButton: connectClientBtn.rx.tap.asObservable())
            .subscribe { error in
                print(error)
            }.disposed(by: disposeBag)
        
        viewModel.connectionStatus.bind { model in
            self.connectClientBtn.setTitle( model.buttonAction, for: .normal)
        }.disposed(by: disposeBag)
        
       
        viewModel.connectionStatus.bind { model in
            self.connectionStateLabel.text = model.clientConnectionInfo
        }.disposed(by: disposeBag)
        
        viewModel.connectionStatus.bind { model in
            self.makeCallBtn.isHidden = model.hideMakeACall ?? true
        }.disposed(by: disposeBag)
        
        viewModel.connectionStatus.bind { model in
            self.acceptCallBtn.isHidden = model.hideAcceptCall
        }.disposed(by: disposeBag)
        
        viewModel.connectionStatus.bind { model in
            self.endCallBtn.isHidden = model.hideEndCall
        }.disposed(by: disposeBag)
        
        
        makeCallBtn.rx.tap
            .map{
                AppStep.clientMakesCall
            }
            .bind(to: self.steps)
            .disposed(by: disposeBag)
        
        self.acceptCallBtn.rx.tap.bind { _ in
            self.viewModel.answerCall()
        }.disposed(by: disposeBag)
        
        self.endCallBtn.rx.tap.bind { _ in
            self.viewModel.endCall()
        }.disposed(by: disposeBag)
        
        
    }
    
    
    func setupView(){
        self.view.backgroundColor = .white
        self.view.addSubview(stackView)
        
        stackView.addArrangedSubview(connectionStateLabel)
        stackView.addArrangedSubview(usernameLbl)
        stackView.addArrangedSubview(usernameField)
        stackView.addArrangedSubview(passwordLbl)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(connectClientBtn)
        stackView.addArrangedSubview(makeCallBtn)
        stackView.addArrangedSubview(acceptCallBtn)
        stackView.addArrangedSubview(endCallBtn)
        
        stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 16).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,constant: -16).isActive = true
        
    }
    
    @objc func connectClient(){
        
    }
    
   

}
