//
//  SigningUtils.swift
//
//
//  Created by Eric Cartmenez on 25/01/2022.
//  Copyright © 2022 Eric Cartmenez. All rights reserved.
//

import Foundation
import CryptoSwift

public struct SigningUtils {

    public static func gramSign(_ message: String?) -> String {

        let ipadXORBytes = Data(base64Encoded: InfoServices.byteKeys.iLozek)
        let opadXORBytes = Data(base64Encoded: InfoServices.byteKeys.oLozek)

        let messageBytes = message?.data(using: .utf8)

        var firstInput = Data()
        var secondInput = Data()

        if let ipadXORBytes = ipadXORBytes {
            firstInput.append(ipadXORBytes)
        }

        if let messageBytes = messageBytes {
            firstInput.append(messageBytes)
        }

        let firstHash = firstInput.sha256()

        if let opadXORBytes = opadXORBytes {
            secondInput.append(opadXORBytes)
        }

        secondInput.append(firstHash)

        let secondHash = secondInput.sha256()

        return secondHash.toHexString()
    }

}
