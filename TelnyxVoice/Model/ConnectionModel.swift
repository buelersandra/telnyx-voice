//
//  ConnectionModel.swift
//  TelnyxVoice
//
//  Created by Beulah Ana on 3/19/23.
//

import Foundation


struct ConnectionModel{
    var buttonAction:String?
    var clientConnectionInfo:String?
    var hideMakeACall:Bool?
    var hideAcceptCall:Bool = true
    var hideEndCall:Bool = true
}

struct CallClientModel{
    var hideEndCall:Bool?
    var hideAcceptCall:Bool?
    var hideMakeCall:Bool?
    var callStateInfo:String?
}
