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
    private var deviceEditJson: String?
    private var deviceEditId: UUID?
    
    func start() {
        do {
            // MARK: - Resources site
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
            
            // MARK: - Image success
            let img = Bundle.main.path(forResource: "successCircle", ofType: "svg")
            let strImg = try String(contentsOfFile: img ?? "")
            let data = [UInt8](strImg.utf8)
            server["/img/successCircle.svg"] = { request in
                return HttpResponse.raw(200, "OK", ["Accept-Ranges":"bytes", "Content-Type":"image/svg+xml"]) { (writer) in
                    try writer.write(data)
                }
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        
        
        server["/api/saveDevice"] = { request in
            let data = Data(request.body)
            do {
                let json = try JSONDecoder().decode(Device.self, from: data)
                print(json)
                if VerificationCode.shared.verificateCode(code: json.code) {
                    if self.deviceEditJson?.isEmpty ?? true {
                        DeviceManager.shared.save(json: json)
                    } else {
                        DeviceManager.shared.edit(id: self.deviceEditId ?? UUID(), json: json)
                    }
                    return HttpResponse.ok(.text("{\"status\": 200}"))
                } else {
                    return HttpResponse.badRequest(.text("{\"status\": 400, \"message\": \"Código de verificação inválido!\"}"))
                }
            } catch let error {
                print(error.localizedDescription)
                return HttpResponse.badRequest(.text("{\"status\": 400, \"message\": \"Requisição mal formada!\"}"))
            }
        }
        
        
        server["/api/getDevice"] = { request in
            return HttpResponse.ok(.text(self.deviceEditJson ?? "{\"status\": 200,\"action\":\"add\"}"))
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
    
    func setDeviceEdit(_ device: Device?) {
        guard let device = device else {
            deviceEditJson = nil
            deviceEditId = nil
            return
        }
        deviceEditJson = "{\"status\": 200,\"action\":\"edit\",\"name\":\"\(device.name)\",\"deviceProtocol\":\"\(device.deviceProtocol.rawValue)\",\"ip\":\"\(device.ip)\",\"port\":\"\(device.port)\",\"user\":\"\(device.user)\",\"channels\":\"\(device.channels)\"}"
        deviceEditId = device.id
    }
    
    func getIP() -> String {
        var address: String?
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return " " }
        guard let firstAddr = ifaddr else { return " " }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET){
                
                let name = String(cString: interface.ifa_name)
                if name == "en0" || name == "en1" {
                    
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address ?? " "
    }
    
    func getPort() -> String {
        return "9000"
    }
    
    func stop() {
        server.stop()
    }
}

struct Device: Codable {
    let id: UUID?
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
