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
            return InfoServices.udService.object(forKey: InfoServices.keys.udAsterKey) ?? 0
        }
        set {
            resetAstersIfNeeded()
            InfoServices.kcService.set(value: newValue < 0 ? 0 : newValue, for: InfoServices.keys.kcAsterKey)
            InfoServices.udService.set(newValue < 0 ? 0 : newValue, forKey: InfoServices.keys.udAsterKey)
            updateSignatureForAsters()
        }
    }

    public static func matchAsters() {
        let udAsters = InfoServices.udService.object(forKey: InfoServices.keys.udAsterKey) ?? 0
        let kcAsters = InfoServices.kcService.value(for: InfoServices.keys.kcAsterKey) ?? 0
        if udAsters == 0, kcAsters > 0 {
            Aster.numberOfAsters = kcAsters
        }
    }

    public static func resetAsters() {
        InfoServices.kcService.remove(key: InfoServices.keys.kcAsterKey)
        InfoServices.udService.deleteValue(forKey: InfoServices.keys.udAsterKey)
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
        InfoServices.getZvezdeService.getZvezde { (result: Result<AsterSeira, NetworkingError>) in
            if case .success(let seira) = result {
                if self.isSeiraSignatureValid(seira) {
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

    static func isSeiraSignatureValid(_ seira: AsterSeira) -> Bool {
        guard let hmacBytes = try? HMAC(key: InfoServices.keys.hamburgerMac,
                                        variant: .sha2(.sha256)).authenticate("\(seira.rank)|\(seira.nonce)".asUInt8Array) else {
                return false
        }
        return seira.signature == Data(hmacBytes).toHexString()
    }

}

public extension Aster {

    static func isSignatureValid() -> Bool {
        let asters: Int = InfoServices.udService.object(forKey: InfoServices.keys.udAsterKey) ?? 0
        let updatedSignature = updateSignatureForAsters()

        let storedSignature: [UInt8]? = InfoServices.udService.object(forKey: InfoServices.keys.udSignatureKey) ?? updatedSignature
        let storedKcSignature: [UInt8]? = InfoServices.kcService.value(for: InfoServices.keys.kcSignatureKey) ?? updatedSignature
        
        let astersSignature = try? HMAC(key: InfoServices.keys.key, variant: .sha2(.sha256)).authenticate("\(asters)".asUInt8Array)

        if astersSignature == storedSignature {
            return true
        } else {
            return astersSignature == storedKcSignature
        }
    }

    @discardableResult static func updateSignatureForAsters() -> [UInt8]? {
        let asters = InfoServices.udService.object(forKey: InfoServices.keys.udAsterKey) ?? 0
        let astersSignature = try? HMAC(key: InfoServices.keys.key, variant: .sha2(.sha256)).authenticate("\(asters)".asUInt8Array)
        InfoServices.udService.set(astersSignature, forKey: InfoServices.keys.udSignatureKey)
        InfoServices.kcService.set(value: astersSignature, for: InfoServices.keys.kcSignatureKey)
        return astersSignature
    }

}
