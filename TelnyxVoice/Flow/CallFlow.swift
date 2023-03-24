//
//  CallFlow.swift
//  TelnyxVoice
//
//  Created by Beulah Ana on 3/20/23.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa




class CallFlow : Flow{
        var root: Presentable {
            return self.rootViewController
        }

     let rootViewController: UINavigationController
    let viewModel: ConnectViewModel
      
    
        private let services: AppService

    
    init(withServices services: AppService, root: UINavigationController) {
        self.services = services
        self.rootViewController = root
        self.viewModel = ConnectViewModel()
    }

        func navigate(to step: Step) -> FlowContributors {

            guard let step = step as? AppStep else { return .none }

            switch step {
            case .clientIsDisconnected:
                return navigationToConnectionScreen()
            case .clientMakesCall:
                return navigateToCall()
                
            }
        }
    
    private func navigationToConnectionScreen() -> FlowContributors {
        
        let viewController = ConnectController(viewModel : self.viewModel)
        
        self.rootViewController.pushViewController(viewController, animated: false)
        return .one(flowContributor: .contribute(withNext: viewController))
       
    }
    
    
    
    private func navigateToCall () -> FlowContributors {
        let viewController = CallController(viewModel: self.viewModel)
        self.rootViewController.pushViewController(viewController, animated: false)
        return .none
        
    }
   
    
}



class CallStepper: Stepper {

    let steps = PublishRelay<Step>()

    var initialStep: Step {
        return AppStep.clientMakesCall
    }

    func settingsDone() {
        self.steps.accept(AppStep.clientMakesCall)
    }
}
