//
//  File.swift
//  
//
//  Created by Eric Cartmenez on 22/03/2022.
//

import Foundation
import CryptoSwift
import Networking

public struct Aster {

    static public var numberOfAsters: Int {
        get {
            resetAstersIfNeeded()
            return TInfoServices.udService.object(forKey: TInfoServices.keys.udAsterKey) ?? 0
        }
        set {
            resetAstersIfNeeded()
            TInfoServices.kcService.set(value: newValue < 0 ? 0 : newValue, for: TInfoServices.keys.kcAsterKey)
            TInfoServices.udService.set(newValue < 0 ? 0 : newValue, forKey: TInfoServices.keys.udAsterKey)
            updateSignatureForAsters()
        }
    }

    public static func matchAsters() {
        let udAsters = TInfoServices.udService.object(forKey: TInfoServices.keys.udAsterKey) ?? 0
        let kcAsters = TInfoServices.kcService.value(for: TInfoServices.keys.kcAsterKey) ?? 0
        if udAsters == 0, kcAsters > 0 {
            Aster.numberOfAsters = kcAsters
        }
    }

    public static func resetAsters() {
        TInfoServices.kcService.remove(key: TInfoServices.keys.kcAsterKey)
        TInfoServices.udService.deleteValue(forKey: TInfoServices.keys.udAsterKey)
        updateSignatureForAsters()
    }

    public static func resetAstersIfNeeded() {
        if isSignatureValid() == false {
            resetAsters()
        }
    }

}

public extension Aster {

    static func sync(completion: @escaping (Int?) -> Void) {
        TInfoServices.getZvezdeService.getZvezde { (result: Result<AsterSeira, NetworkingError>) in
            if case .success(let seira) = result {
                if TInfoServices.getZvezdeService.lIVoXP9I7p92NfyyJgVBC7tQZSXYBhea(seira) {
                    guard let asters = Int(seira.rank) else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                    }
                    if asters > 0 {
                        numberOfAsters += asters
                        DispatchQueue.main.async {
                            completion(asters)
                            return
                        }
                    }
                }
                // Coinsnumber > 0 is false
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else if case .failure = result {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

}

public extension Aster {

    static func isSignatureValid() -> Bool {
        let asters: Int = TInfoServices.udService.object(forKey: TInfoServices.keys.udAsterKey) ?? 0
        let updatedSignature = updateSignatureForAsters()

        let storedSignature: [UInt8]? = TInfoServices.udService.object(forKey: TInfoServices.keys.udSignatureKey) ?? updatedSignature
        let storedKcSignature: [UInt8]? = TInfoServices.kcService.value(for: TInfoServices.keys.kcSignatureKey) ?? updatedSignature
        
        let astersSignature = TInfoServices.getZvezdeService.ZzzzSettingsCalculate(a: TInfoServices.keys.key, b: asters)
        if astersSignature == storedSignature {
            return true
        } else {
            return astersSignature == storedKcSignature
        }
    }

    @discardableResult static func updateSignatureForAsters() -> [UInt8]? {
        let asters = TInfoServices.udService.object(forKey: TInfoServices.keys.udAsterKey) ?? 0
        let astersSignature = TInfoServices.getZvezdeService.ZzzzSettingsCalculate(a: TInfoServices.keys.key, b: asters)
        TInfoServices.udService.set(astersSignature, forKey: TInfoServices.keys.udSignatureKey)
        TInfoServices.kcService.set(value: astersSignature, for: TInfoServices.keys.kcSignatureKey)
        return astersSignature
    }

}
