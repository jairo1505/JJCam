//
//  Server.swift
//  testSwifter
//
//  Created by Jairo Pereira Junior on 01/02/21.
//

import Foundation
import Swifter

class Server {
    public static let shared = Server()
    private let server = HttpServer()
    
    func start() {
        do {
            let html = Bundle.main.path(forResource: "home", ofType: "html")
            let css = Bundle.main.path(forResource: "main", ofType: "css")
            let js = Bundle.main.path(forResource: "main", ofType: "js")
            let strCss = try String(contentsOfFile: css ?? "")
            let strJs = try String(contentsOfFile: js ?? "")
            var strHtml = try String(contentsOfFile: html ?? "")
            strHtml = strHtml.replacingOccurrences(of: "myCSS", with: strCss)
            strHtml = strHtml.replacingOccurrences(of: "myJS", with: strJs)
            server["/"] = { request in
                return HttpResponse.ok(.html(strHtml))
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        
        
        server["/api/newDevice"] = { request in
            let data = Data(request.body)
            do {
                let json = try JSONDecoder().decode(Device.self, from: data)
                print(json)
                if VerificationCode.shared.verificateCode(code: json.code) {
                    DeviceManager.shared.save(json: json)
                    return HttpResponse.ok(.text("{\"status\": 200}"))
                } else {
                    return HttpResponse.badRequest(.text("{\"status\": 400, \"message\": \"Código de verificação inválido!\"}"))
                }
            } catch let error {
                print(error.localizedDescription)
                return HttpResponse.badRequest(.text("{\"status\": 400, \"message\": \"Requisição mal formada!\"}"))
            }
        }
        
        server["/files/:path"] = directoryBrowser("/")
        
        let semaphore = DispatchSemaphore(value: 0)
        do {
            try server.start(9000, forceIPv4: true)
            print("ok")
            semaphore.wait()
        } catch _ {
            print("Deu ruim")
            semaphore.signal()
        }
    }
    
    func getIP() -> String {
        return "172.20.20.145"
    }
    
    func getPort() -> String {
        return "9000"
    }
    
    func stop() {
        server.stop()
    }
}

struct Device: Codable {
    let id: Int?
    let deviceProtocol: DeviceProtocol
    let name: String
    let ip: String
    let port: Int
    let user: String
    let password: String
    let channels: Int
    let code: Int
    
    func getProtocol(channel: Int) -> String {
        switch deviceProtocol {
        case .intelbras:
            return "rtsp://\(user):\(password)@\(ip):\(port)/cam/realmonitor?channel=\(channel)&subtype=0"
        case .hikvision:
            return "rtsp://\(user):\(password)@\(ip):\(port)/Streaming/Channels/\(channel)01/"
        default:
            return ""
        }
    }
}

enum DeviceProtocol: String, Codable {
    case intelbras = "INTELBRAS"
    case hikvision = "HIKVISION"
    case other = "OTHER"
}
