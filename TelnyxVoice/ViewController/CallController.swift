//
//  ViewController.swift
//  TelnyxVoice
//
//  Created by Beulah Ana on 3/18/23.
//

import UIKit
import TelnyxRTC
import RxSwift

class CallController: UIViewController {
    
    var disposeBag = DisposeBag()
    let viewModel:ConnectViewModel
    
    init(viewModel: ConnectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var callStateLabel:UILabel = {
        let view = UILabel()
        view.font = UIFont(name: view.font.fontName, size: 16)
        view.textColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Make a call"
        view.numberOfLines = 0
        return view
    }()
    
    lazy var usernameLabel:UILabel = {
        let view = UILabel()
        view.font = UIFont(name: view.font.fontName, size: 16)
        view.textColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Username or Number"
        return view
    }()
    
    lazy var callerIdField:UITextField = {
        let view = UITextField()
        view.placeholder = "Username or Number"
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
    
  
    lazy var acceptCallBtn:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Accept Call", for: .normal)
        view.backgroundColor = .green
        view.setTitleColor(.white, for: .normal)
        return view
    }()
    
    lazy var callBtn:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Call", for: .normal)
        view.backgroundColor = .darkGray
        view.setTitleColor(.white, for: .normal)

        return view
    }()
    
    lazy var endCallBtn:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("End Call", for: .normal)
        view.backgroundColor = .red
        view.setTitleColor(.white, for: .normal)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        initView()
        bindView()
    }
    
   
    
    func initView(){
        self.view.addSubview(stackView)
        self.stackView.addArrangedSubview(callStateLabel)
        self.stackView.addArrangedSubview(usernameLabel)
        self.stackView.addArrangedSubview(callerIdField)
        
        self.stackView.addArrangedSubview(callBtn)
        
        self.stackView.addArrangedSubview(acceptCallBtn)
        self.stackView.addArrangedSubview(endCallBtn)
        
        stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 16).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,constant: -16).isActive = true
    }
    
    func bindView(){
        viewModel.callStatus.bind { model in
            self.callStateLabel.text = model.callStateInfo
        }.disposed(by: disposeBag)
        
        viewModel.callStatus.bind { model in
            self.endCallBtn.isHidden = model.hideEndCall ?? true
        }.disposed(by: disposeBag)
        
        viewModel.callStatus.bind { model in
            self.callBtn.isHidden = model.hideMakeCall ?? true
        }.disposed(by: disposeBag)
        
        viewModel.callStatus.bind { model in
            self.acceptCallBtn.isHidden = model.hideAcceptCall ?? true
        }.disposed(by: disposeBag)
    
        
        viewModel.makeCall(username: callerIdField.rx.text.orEmpty.asObservable(),
                           didPressButton: callBtn.rx.tap.asObservable())
        .subscribe()
        .disposed(by: disposeBag)
        
        
        self.endCallBtn.rx.tap.bind { _ in
            self.viewModel.endCall()
        }.disposed(by: disposeBag)
        
        self.acceptCallBtn.rx.tap.bind { _ in
            self.viewModel.answerCall()
        }.disposed(by: disposeBag)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       
        
        
    }
    
    
    
    
    
   
    

    
   
    
   
    


}




