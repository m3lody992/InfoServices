//
//  File.swift
//  
//
//  Created by Eric Cartmenez on 22/03/2022.
//

import Foundation

public extension String {

    var asUInt8Array: [UInt8] {
        Array(utf8)
    }

}
