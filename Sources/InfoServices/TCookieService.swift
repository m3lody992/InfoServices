//
//  File.swift
//  
//
//  Created by Eric Cartmenez on 21/04/2022.
//

import WebKit

public extension WKWebView {

    func storeAndApplyWebViewCookies(for domainName: String, completion: (() -> Void)? = nil) { // "tiktok"
        DispatchQueue.main.async {
            TCookieService.storeWebViewCookies(for: domainName) { _ in
                for cookie in CookieService.cookies {
                    self.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
                }
                completion?()
            }
        }
    }

    func applyWebViewCookies() {
        DispatchQueue.main.async {
            for cookie in TCookieService.cookies {
                self.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
        }
    }

    func removeWebViewCookies(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let cookieStore = self.configuration.websiteDataStore.httpCookieStore
            let dispatchGroup = DispatchGroup()
            cookieStore.getAllCookies { cookies in
                for cookie in cookies {
                    dispatchGroup.enter()
                    cookieStore.delete(cookie) {
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.configuration.processPool = WKProcessPool()
                completion?()
            }
        }
    }

}

public struct TCookie: Codable, Equatable {

    public var domain: String
    public var path: String
    public var name: String
    public var value: String
    public var isSecure: Bool
    public var expiresDate: Date?

    public init(cookie: HTTPCookie) {
        domain = cookie.domain
        path = cookie.path
        name = cookie.name
        value = cookie.value
        isSecure = cookie.isSecure
        expiresDate = cookie.expiresDate
    }

    public var asHTTPCookie: HTTPCookie? {
        HTTPCookie(properties: [
            .domain: domain,
            .path: path,
            .name: name,
            .value: value,
            .secure: isSecure,
            .expires: expiresDate
        ])
    }
}

public struct TCookieService {
    
    public static var cookies: [HTTPCookie] {
        get { (TInfoServices.udService.object(forKey: InfoServices.keys.udCookies) ?? [TCookie]()).compactMap { $0.asHTTPCookie } }
        set { TInfoServices.udService.set(newValue.compactMap { TCookie(cookie: $0) }, forKey: TInfoServices.keys.udCookies) }
    }

    public static func update(withCookies freshCookies: [HTTPCookie]) {
        // We add missing cookies
        var mutableCookies = Array(Set(cookies + freshCookies))

        // Iterate through the array and update cookies with new ones.
        for (index, cookie) in mutableCookies.enumerated() {
            if let freshCookie = freshCookies.first(where: { $0.name == cookie.name && ($0.expiresDate ?? Date() > cookie.expiresDate ?? Date() || $0.version > cookie.version) }) {
                mutableCookies[index] = freshCookie
            }
        }
        cookies = Array(Set(mutableCookies))
    }

    public static func areCookiesExpired(for domain: String) -> Bool { // "tiktok"
        guard let mainCookie = cookies.first(where: { $0.name == TInfoServices.cn && $0.domain.contains(domain) }),
              let mainCookieExpiresDate = mainCookie.expiresDate else {
            return true
        }
        return Date() > mainCookieExpiresDate
    }

    public static func storeWebViewCookies(for domain: String?, completion: (([HTTPCookie]) -> Void)? = nil) { // "tiktok"
        DispatchQueue.main.async {
            getWebViewCookies(for: domain) { fetchedCookies in
                update(withCookies: fetchedCookies)
                completion?(cookies)
            }
        }
    }

    public static func getWebViewCookies(for domain: String?, completion: @escaping ([HTTPCookie]) -> ()) { // "tiktok"
        var myCookies = [HTTPCookie]()
        DispatchQueue.main.async {
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
    }

    public static func cleanAllCookies(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            cookies.removeAll()
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records) {
                    completion?()
                }
            }
        }
    }

}
