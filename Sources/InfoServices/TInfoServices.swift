//
//  File.swift
//  
//
//  Created by Eric Cartmenez on 21/04/2022.
//

import Foundation

public struct TInfoServices {
    
    internal static var shared = TInfoServices()
    
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
    
    internal var cn: String!
    internal static var cn: String {
        shared.cn
    }

    public static func configure(udService: UDInterface, kcService: KCInterface, keys: PersistenceKeys, byteKeys: ByteProtocol, serviceKeys: ServiceKeys, getZvezdeService: GetZvezdeProtocol, cn: String) {
        shared.udService = udService
        shared.kcService = kcService
        shared.keys = keys
        shared.getZvezdeService = getZvezdeService
        shared.cn = cn
    }
    
}
