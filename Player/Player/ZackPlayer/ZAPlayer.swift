//
//  ZAPlayer.swift
//  Player
//
//  Created by kong on 2021/6/14.
//

import UIKit

enum ZAPlayerEventCode {
    case Success
    case FormateError
    case playCompleted
}

protocol ZAPlayerListener: AnyObject {
    func onEvent(_ code: ZAPlayerEventCode)
}

class ZAPlayer: NSObject {

    public weak var listener: ZAPlayerListener?

    let fileURL: URL

    init(url: URL) {
        fileURL = url
        super.init()
    }

    func play() {

    }

    func stop() {

    }

}
