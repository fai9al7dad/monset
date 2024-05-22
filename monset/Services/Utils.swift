//
//  Utils.swift
//  monset
//
//  Created by faisal haddad on 14/11/1445 AH.
//

import Foundation

func isRunningOnSimulator() -> Bool {
    #if targetEnvironment(simulator)
        return true
    #else
        return false
    #endif
}
