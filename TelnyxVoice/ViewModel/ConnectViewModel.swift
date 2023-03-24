//
//  ConnectViewModel.swift
//  TelnyxVoice
//
//  Created by Beulah Ana on 3/18/23.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow
import TelnyxRTC
import AVFoundation
import CallKit



class ConnectViewModel : NSObject{
    
    let connectionStatus: BehaviorRelay<ConnectionModel>
    let callStatus: BehaviorRelay<CallClientModel>
    let client:TxClient
    var call:Call?
    let callKitCallController: CXCallController
    var callKitProvider: CXProvider?
    var callKitUUID: UUID?
    
    override init(){
        client = TxClient()
        self.callKitCallController = CXCallController()
        connectionStatus = BehaviorRelay<ConnectionModel>(value: ConnectionModel(buttonAction: "Connect",
                                                                          clientConnectionInfo: "No Connection Setup Enter Username and Password",
                                                                          hideMakeACall: true))
        
        callStatus = BehaviorRelay<CallClientModel>(value: CallClientModel(hideEndCall: true,
                                                                           callStateInfo: "Make or Receive Call"))
        
        super.init()
        self.initCallKit()



    }
    
    deinit {
        // CallKit has an odd API contract where the developer must call invalidate or the CXProvider is leaked.
        if let provider = callKitProvider {
            provider.invalidate()
        }
    }
    /**
     Initialize callkit framework
     */
    func initCallKit() {
        let configuration = CXProviderConfiguration(localizedName: "TelnyxRTC")
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        callKitProvider = CXProvider(configuration: configuration)
        if let provider = callKitProvider {
            provider.setDelegate(self, queue: nil)
        }
    }
    
    
    func connect(username: Observable<String>, password: Observable<String>, didPressButton: Observable<Void>) -> Observable<String>{
        
        let userInputs = Observable.combineLatest(username, password) { (login, password) -> (String, String) in
               return (login, password)
        }
        
        return didPressButton.withLatestFrom(userInputs)
            
            .flatMap { (username,password) in
                return Observable.create { observer -> Disposable in
                    let txConfigUserAndPassowrd = TxConfig(sipUser: username,
                                                           password: password,
                                                           pushDeviceToken: "DEVICE_APNS_TOKEN",
                                                           ringtone: "incoming_call.mp3",
                                                           ringBackTone: "ringback_tone.mp3",
                                                           //You can choose the appropriate verbosity level of the SDK.
                                                           //Logs are disabled by default
                                                           logLevel: .all)
                    
                    do {
                        if(self.client.isConnected()){
                            self.disconnect()
                        }else{
                            self.client.delegate = self
                            try self.client.connect(txConfig: txConfigUserAndPassowrd)
                        }
                        
                       
                        observer.onCompleted()
                    } catch let error {
                        observer.onError(error)
                        print("ViewController:: connect Error \(error)")
                    }
                    
                    return Disposables.create()
                }
                
            }
        
    }
    
    func disconnect(){
        client.disconnect()
        client.delegate = nil
    }
    
    func answerCall(){
        guard let callID = self.call?.callInfo?.callId else { return }
        self.executeAnswerCallAction(uuid: callID)
    }
    
    func makeCall(username: Observable<String>, didPressButton: Observable<Void>) -> Observable<Void>{
        return didPressButton.withLatestFrom(username)
            .flatMap { username in
            return Observable.create { observer -> Disposable in
               
                self.executeCallKitStartCallAction(uuid: UUID.init(), handle: username, observer: observer)
                
                return Disposables.create()
            
            }
        }
    }
    
    func endCall(){
        guard let uuid = self.call?.callInfo?.callId else { return }
        self.call?.hangup()
        executeEndCallAction(uuid: uuid)
        resetCallUI()

    }
    
   
}



// MARK: - Callbacks from the Telnyx RTC SDK
extension ConnectViewModel: TxClientDelegate {
    
    func onPushCall(call: TelnyxRTC.Call) {
        self.call = call
    }
    
    func onSocketConnected() {
        DispatchQueue.main.async {
            self.connectionStatus.accept(ConnectionModel(buttonAction: "Disconnect",
                                                    clientConnectionInfo: "Client Setup Successfully",
                                                    hideMakeACall: false))
        }
      
        
        
    }

    func onSocketDisconnected() {
        print("onSocketDisconnected")
        
        DispatchQueue.main.async {
            self.connectionStatus.accept(ConnectionModel(buttonAction: "Connect",
                                                    clientConnectionInfo: "No Connection Setup Enter Username and Password",
                                                    hideMakeACall: true))
        }
       

    }
    

    func onClientError(error: Error) {
        print("onClientError")
        
        DispatchQueue.main.async {
            self.connectionStatus.accept(ConnectionModel(buttonAction: "Connect",
                                                    clientConnectionInfo: "An error occurred during connection",
                                                    hideMakeACall: false))
            self.callStatus.accept(CallClientModel(hideEndCall: true,
                                                   hideAcceptCall: true,
                                                   hideMakeCall: false,callStateInfo: ""))
        }
        
    }

    func onClientReady() {
        print("onClientReady")
      
            
        DispatchQueue.main.async {
            self.connectionStatus.accept(ConnectionModel(buttonAction: "Disconnect",
                                                    clientConnectionInfo: "You are ready to make calls or Accept calls",
                                                    hideMakeACall: false))
            
            
            self.callStatus.accept(CallClientModel(hideEndCall: true,hideAcceptCall: true,
                                                   hideMakeCall: false,callStateInfo: "CONNECTED"))
        }
       
        

    }

    func onSessionUpdated(sessionId: String) {
        print("onSessionUpdated")
    }

    func onCallStateUpdated(callState: CallState, callId: UUID) {
        DispatchQueue.main.async {
            // handle the new call state
            switch (callState) {
                 case .CONNECTING:
                self.callStatus.accept(CallClientModel(hideEndCall: false,hideAcceptCall: true,
                                                       hideMakeCall: true,callStateInfo: "CONNECTING"))
                     break
                 case .RINGING:
                self.callStatus.accept(CallClientModel(hideEndCall: false,hideAcceptCall: true,
                                                       hideMakeCall: true,callStateInfo: "RINGING"))
                     break
                 case .NEW:
                self.callStatus.accept(CallClientModel(hideEndCall: false,hideAcceptCall: false,
                                                       hideMakeCall: true,callStateInfo: "NEW"))
                     break
                 case .ACTIVE:
                self.callStatus.accept(CallClientModel(hideEndCall: false,
                                                       hideAcceptCall: true,
                                                       hideMakeCall: true,
                                                       callStateInfo: "Call ongoing..."))
                     break
                 case .DONE:
                    self.resetCallUI()
                     break
                 case .HELD:
                self.callStatus.accept(CallClientModel(hideEndCall: false,
                                                       hideAcceptCall: true,
                                                       hideMakeCall: true,
                                                       callStateInfo: "HELD"
                                                      ))
                     break
            }
        }
          
          
        
    }

    // This method will be fired when receiving a call while the client is connected
    func onIncomingCall(call: Call) {
        guard let _ = call.callInfo?.callId else {
            print("Unknwon incoming call..")
            return
        }

        if let _ = self.call?.callInfo?.callId {
            //Hangup the previous call if there's one active
            self.endCall()
        }

        self.call = call
        
        guard let provider = callKitProvider else {
            print("AppDelegate:: CallKit provider not available")
            return
        }

        // Get the caller information
        let calleer = self.call?.callInfo?.callerName ?? self.call?.callInfo?.callerNumber ?? "Unknown"
        
        if let uuid = self.call?.callInfo?.callId{
            let callHandle = CXHandle(type: .generic, value: calleer)
            let callUpdate = CXCallUpdate()
            callUpdate.remoteHandle = callHandle
            callUpdate.hasVideo = false

            provider.reportNewIncomingCall(with: uuid, update: callUpdate) { error in
                if let error = error {
                    print("AppDelegate:: Failed to report incoming call: \(error.localizedDescription).")
                } else {
                    print("AppDelegate:: Incoming call successfully reported.")
                }
            }
        }
        
        

            
            
            DispatchQueue.main.async {
                self.callStatus.accept(CallClientModel(hideEndCall: false,
                                                       hideAcceptCall: false,
                                                      hideMakeCall: true,
                                                       callStateInfo: "Incoming call : \(calleer)"))
                
                self.connectionStatus.accept(ConnectionModel(buttonAction: "Disconnect",
                                                        clientConnectionInfo: "Incoming call : \(calleer)",
                                                        hideMakeACall: true,hideAcceptCall: false,hideEndCall: true))
            }
        
        
        
        

    }

    func onRemoteCallEnded(callId: UUID) {
        resetCallUI()
        executeEndCallAction(uuid: callId)
    }
    
    func resetCallUI(){
        DispatchQueue.main.async {
            self.callStatus.accept(CallClientModel(hideEndCall: true,
                                                   hideAcceptCall: true,
                                                   hideMakeCall: false,
                                                   callStateInfo: "You are ready to make calls or Accept calls"))
            
            self.connectionStatus.accept(ConnectionModel(buttonAction: "Disconnect",
                                                    clientConnectionInfo: "You are ready to make calls or Accept calls",
                                                    hideMakeACall: false, hideAcceptCall: true,hideEndCall: true))

        }
        
       
        
    }
    
    func executeAnswerCallAction(uuid:UUID) {
        print("AppDelegate:: execute ANSWER call action: callKitUUID [\(String(describing: self.callKitUUID))] uuid [\(uuid)]")
        var endUUID = uuid
        if let callkitUUID = self.callKitUUID {
            endUUID = callkitUUID
        }
        let answerCallAction = CXAnswerCallAction(call: endUUID)
        let transaction = CXTransaction(action: answerCallAction)
        callKitCallController.request(transaction) { error in
            if let error = error {
                print("AppDelegate:: AnswerCallAction transaction request failed: \(error.localizedDescription).")
            } else {
                print("AppDelegate:: AnswerCallAction transaction request successful")
            }
        }
        
    }
    
    func executeEndCallAction(uuid: UUID) {
        print("AppDelegate:: execute END call action: callKitUUID [\(String(describing: self.callKitUUID))] uuid [\(uuid)]")

        var endUUID = uuid
        if let callkitUUID = self.callKitUUID {
            endUUID = callkitUUID
        }

        let endCallAction = CXEndCallAction(call: endUUID)
        let transaction = CXTransaction(action: endCallAction)

        callKitCallController.request(transaction) { error in
            if let error = error {
                
                print("AppDelegate:: EndCallAction transaction request failed: \(error.localizedDescription).")
            } else {
                print("AppDelegate:: EndCallAction transaction request successful")
            }
            self.callKitUUID = nil
            
        }
        
    }
   
    
    
}


extension ConnectViewModel : CXProviderDelegate{
    func providerDidBegin(_ provider: CXProvider) {
        print("providerDidBegin")
    }
    func providerDidReset(_ provider: CXProvider) {
        print("providerDidReset:")
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("AppDelegate:: ANSWER call action: callKitUUID [\(String(describing: self.callKitUUID))] action [\(action.callUUID)]")
        self.call?.answer()
        action.fulfill()
    }
  
    // MARK: - CXProviderDelegate -
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("AppDelegate:: START call action: callKitUUID [\(String(describing: self.callKitUUID))] action [\(action.callUUID)]")
        self.callKitUUID = action.callUUID
        
        self.executeTelnyxStartCallAction(username: action.handle.value, uuid: action.callUUID){ call in
            self.call = call
            if call != nil {
                print("AppDelegate:: performVoiceCall() successful")
                provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
            } else {
                print("AppDelegate:: performVoiceCall() failed")
            }
        }
        action.fulfill()
        
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("AppDelegate:: END call action: callKitUUID [\(String(describing: self.callKitUUID))] action [\(action.callUUID)]")
        self.call?.hangup()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        self.client.isAudioDeviceEnabled = true
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        self.client.isAudioDeviceEnabled = false
    }
}


extension ConnectViewModel {
    func executeCallKitStartCallAction(uuid: UUID, handle: String, observer:AnyObserver<Void>){
        guard let provider = callKitProvider else {
            print("CallKit provider not available")
            return
        }

        let callHandle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: uuid, handle: callHandle)
        let transaction = CXTransaction(action: startCallAction)

        callKitCallController.request(transaction) { error in
            if let error = error {
                print("StartCallAction transaction request failed: \(error.localizedDescription)")
                observer.onError(error)
                return
            }

            print("StartCallAction transaction request successful")

            let callUpdate = CXCallUpdate()

            callUpdate.remoteHandle = callHandle
            callUpdate.supportsDTMF = true
            callUpdate.supportsHolding = true
            callUpdate.supportsGrouping = false
            callUpdate.supportsUngrouping = false
            callUpdate.hasVideo = false
            provider.reportCall(with: uuid, updated: callUpdate)
            observer.onCompleted()
        }
    }
    
    
    func executeTelnyxStartCallAction(username:String, uuid:UUID, complete:(Call?)->Void){
        do {
            let call = try self.client.newCall(callerName: "",
                                            callerNumber: "",
                                            destinationNumber: username,
                                            callId: uuid)
            
            complete(call)
        }catch let error{
            complete(nil)
            print("ViewController:: connect Error \(error)")
        }
    }
}
