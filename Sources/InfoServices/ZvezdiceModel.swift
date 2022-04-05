//
//  File.swift
//  
//
//  Created by Eric Cartmenez on 22/03/2022.
//

public struct AsterSeira: Codable {

    var rank: String
    var nonce: String
    var signature: String

    enum CodingKeys: String, CodingKey {
        case rank
        case nonce
        case signature
    }

}
