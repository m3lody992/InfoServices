//
//  File.swift
//  
//
//  Created by Eric Cartmenez on 22/03/2022.
//

import Foundation
import CryptoSwift
import Networking

public protocol UDInterface {
    func set<T: Codable>(_ value: T?, forKey key: String)
    func object<T>(forKey key: String) -> T? where T: Any, T: Codable
    func deleteValue(forKey key: String)
}

public protocol KCInterface {
    func set<T: Codable>(value: T, for key: String)
    func value<T: Codable>(for key: String) -> T?
    func remove(key: String)
}

public protocol PersistenceKeys {
    var key: String { get }
    var hamburgerMac: String { get }
    var udAsterKey: String { get }
    var kcAsterKey: String { get }
    var udSignatureKey: String { get }
    var kcSignatureKey: String { get }
    var udCookies: String { get }
}

public protocol ServiceKeys {
    var dsUserIDCookieString: String { get }
    var csrfCookieString: String { get }
    var sessionCookieString: String { get }
    var midCookieString: String { get }
}

public protocol ByteProtocol {
    var oLozek: String { get }
    var iLozek: String { get }
}

public protocol GetZvezdeProtocol {
    func getZvezde(completion: @escaping (Result<AsterSeira, NetworkingError>) -> Void)
}

public struct InfoServices {
    
    internal static var shared = InfoServices()
    
    internal var udService: UDInterface!
    internal static var udService: UDInterface {
        shared.udService
    }
    
    internal var kcService: KCInterface!
    internal static var kcService: KCInterface {
        shared.kcService
    }
    
    internal var keys: PersistenceKeys!
    internal static var keys: PersistenceKeys {
        shared.keys
    }
    
    internal var getZvezdeService: GetZvezdeProtocol!
    internal static var getZvezdeService: GetZvezdeProtocol {
        shared.getZvezdeService
    }
    
    internal var byteKeys: ByteProtocol!
    internal static var byteKeys: ByteProtocol {
        shared.byteKeys
    }
    
    internal var serviceKeys: ServiceKeys!
    internal static var serviceKeys: ServiceKeys {
        shared.serviceKeys
    }

    public static func configure(udService: UDInterface, kcService: KCInterface, keys: PersistenceKeys, byteKeys: ByteProtocol, serviceKeys: ServiceKeys, getZvezdeService: GetZvezdeProtocol) {
        shared.udService = udService
        shared.kcService = kcService
        shared.keys = keys
        shared.getZvezdeService = getZvezdeService
        shared.byteKeys = byteKeys
        shared.serviceKeys = serviceKeys
    }
    
}
