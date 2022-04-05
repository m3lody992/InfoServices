//
//  CookieService.swift
// 
//
//  Created by Eric Cartmenez on 02/10/2020.
//  Copyright © 2020 Eric Cartmenez. All rights reserved.
//

import WebKit
import Networking

public extension Array where Element == HTTPCookie {
    
    var csrf: HTTPCookie? {
        first(where: { $0.name == InfoServices.serviceKeys.csrfCookieString })
    }

    var sessionID: HTTPCookie? {
        first(where: { $0.name == InfoServices.serviceKeys.sessionCookieString })
    }

    var mid: HTTPCookie? {
        first(where: { $0.name == InfoServices.serviceKeys.midCookieString })
    }
}

public struct CookieService {

    public static var cookies: [HTTPCookie] {
        get { (InfoServices.udService.object(forKey: InfoServices.keys.udCookies) ?? [Cookie]()).compactMap { $0.asHTTPCookie } }
        set { InfoServices.udService.set(newValue.compactMap { Cookie(cookie: $0) }, forKey: InfoServices.keys.udCookies) }
    }

    public static func update(withCookies freshCookies: [HTTPCookie]) {
        // We add missing cookies
        var mutableCookies = Array(Set(cookies + freshCookies))

        // Iterate through the array and update cookies with new ones.
        for (index, cookie) in mutableCookies.enumerated() {
            if let freshCookie = freshCookies.first(where: { $0.name == cookie.name && $0.expiresDate ?? Date() > cookie.expiresDate ?? Date() }) {
                mutableCookies[index] = freshCookie
            }
        }
        cookies = mutableCookies
    }

    public static func areCookiesExpired(for domain: String) -> Bool { // "instagram"
        guard let mainCookie = cookies.first(where: { $0.name == InfoServices.serviceKeys.dsUserIDCookieString && $0.domain.contains(domain) }),
              let mainCookieExpiresDate = mainCookie.expiresDate else {
            return true
        }
        return Date() > mainCookieExpiresDate
    }

    public static func storeWebViewCookies(for domain: String?, completion: (([HTTPCookie]) -> Void)? = nil) { // "instagram"
        getWebViewCookies(for: domain) { fetchedCookies in
            update(withCookies: fetchedCookies)
            completion?(fetchedCookies)
        }
    }

    public static func getWebViewCookies(for domain: String?, completion: @escaping ([HTTPCookie]) -> ()) { // "instagram"
        var myCookies = [HTTPCookie]()
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        myCookies.append(cookie)
                    }
                } else {
                    myCookies.append(cookie)
                }
            }
            completion(myCookies)
        }
    }

    public static func cleanAllCookies(completion: (() -> Void)? = nil) {
        cookies.removeAll()
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
            completion?()
        }
    }

}
