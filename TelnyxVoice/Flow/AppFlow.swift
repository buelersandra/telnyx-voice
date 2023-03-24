//
//  AppFlow.swift
//  TelnyxVoice
//
//  Created by Beulah Ana on 3/20/23.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa

enum AppStep: Step {
    case clientIsDisconnected
    case clientMakesCall
}


class AppFlow: Flow {

    var root: Presentable {
           return self.rootWindow
       }

       private let rootWindow: UIWindow

    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        UINavigationBar.appearance().tintColor = .black
        viewController.setNavigationBarHidden(false, animated: false)
        return viewController
    }()

    private let services: AppService

    init(withWindow window: UIWindow,services: AppService) {
        self.rootWindow = window
        self.services = services
    }

    deinit {
        print("\(type(of: self)): \(#function)")
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .clientIsDisconnected:
            return navigationToConnectionScreen()
        
        default:
            return .none
        }
    }

    private func navigationToConnectionScreen() -> FlowContributors {
        //let callStepper = CallStepper()

        let callFlow = CallFlow(withServices: self.services, root: rootViewController)

        Flows.use(callFlow, when: .created) { [unowned self] (root) in
            self.rootWindow.rootViewController = root
            rootWindow.makeKeyAndVisible()
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: callFlow,
                                                 withNextStepper: OneStepper(withSingleStep: AppStep.clientIsDisconnected)))

    }

   

    private func dismissOnboarding() -> FlowContributors {
        if let onboardingViewController = self.rootViewController.presentedViewController {
            onboardingViewController.dismiss(animated: true)
        }
        return .none
    }
}

class AppStepper: Stepper {

    let steps = PublishRelay<Step>()
    private let appServices: AppService
    private let disposeBag = DisposeBag()

    init(withServices services: AppService) {
        self.appServices = services
    }

    var initialStep: Step {
        return AppStep.clientIsDisconnected  
    }

//    /// callback used to emit steps once the FlowCoordinator is ready to listen to them to contribute to the Flow
//    func readyToEmitSteps() {
//        self.appServices
//            .preferencesService.rx
//            .isOnboarded
//            .map { $0 ? DemoStep.onboardingIsComplete : DemoStep.onboardingIsRequired }
//            .bind(to: self.steps)
//            .disposed(by: self.disposeBag)
//    }
}
