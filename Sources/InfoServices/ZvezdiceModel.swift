//
//  File.swift
//  
//
//  Created by Eric Cartmenez on 22/03/2022.
//

public struct AsterSeira: Codable {

    public var rank: String
    public var nonce: String
    public var signature: String

    enum CodingKeys: String, CodingKey {
        case rank
        case nonce
        case signature
    }

}
