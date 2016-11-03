//
//  ViewController.swift
//  http2Testing
//
//  Created by Hamilton Chapman on 02/11/2016.
//  Copyright © 2016 hc.gg. All rights reserved.
//

import Cocoa

let REALLY_LONG_TIME: Double = 252_460_800

class ViewController: NSViewController, URLSessionDelegate, URLSessionDataDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "localhost"
        urlComponents.port = 10443

        guard let url = urlComponents.url else {
            print("Bad URL, try again")
            return
        }

        var request = URLRequest(url: url.appendingPathComponent("/sub"))
        request.httpMethod = "SUB"
        request.timeoutInterval = REALLY_LONG_TIME

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.timeoutIntervalForResource = REALLY_LONG_TIME
        sessionConfiguration.timeoutIntervalForRequest = REALLY_LONG_TIME

        let session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)

        let task: URLSessionDataTask = session.dataTask(with: request)
        task.resume()
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("Got response: \(response)")
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let dataString = String(data: data, encoding: .utf8)
        print("Received data: \(dataString)")
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Error: \(error)")
    }

    // So it works with self-signed certs (we don't care about TLS etc in this example)
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("URLAuthenticationChallenge")

        guard challenge.previousFailureCount == 0 else {
            challenge.sender?.cancel(challenge)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let allowAllCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, allowAllCredential)
    }

    override var representedObject: Any? {
        didSet {}
    }
}
