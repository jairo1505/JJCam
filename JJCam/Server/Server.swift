//
//  Server.swift
//  testSwifter
//
//  Created by Jairo Pereira Junior on 01/02/21.
//

import Foundation
import Swifter

protocol ServerDelegate {
    func didConectionDevice(ip: String, details: String)
    func didFinish()
}

class Server {
    public static let shared = Server()
    private let server = HttpServer()
    private var deviceEditJson: String?
    private var deviceEditId: UUID?
    private var token: String = ""
    
    public var delegate: ServerDelegate?
    
    private var deviceConnected = ""
    
    func start() {
        do {
            // MARK: - Get resources
            let html = Bundle.main.path(forResource: "home", ofType: "html")
            let css = Bundle.main.path(forResource: "main", ofType: "css")
            let js = Bundle.main.path(forResource: "main", ofType: "js")
            let materializeCss = Bundle.main.path(forResource: "materialize.min", ofType: "css")
            let jqueryJs = Bundle.main.path(forResource: "jquery.min", ofType: "js")
            
            // MARK: - Convert resourses to string
            let strCss = try String(contentsOfFile: css ?? "")
            let strJs = try String(contentsOfFile: js ?? "")
            let strMaterializeCss = try String(contentsOfFile: materializeCss ?? "")
            let strJqueryJs = try String(contentsOfFile: jqueryJs ?? "")
            var strHtml = try String(contentsOfFile: html ?? "")
            
            // MARK: - Add resources to the site
            strHtml = strHtml.replacingOccurrences(of: "myCSS", with: strCss)
            strHtml = strHtml.replacingOccurrences(of: "myJS", with: strJs)
            strHtml = strHtml.replacingOccurrences(of: "materializeCSS", with: strMaterializeCss)
            strHtml = strHtml.replacingOccurrences(of: "jqueryJS", with: strJqueryJs)
            
            server["/"] = { [self] request in
                if deviceConnected.isEmpty || deviceConnected == request.address {
                    return HttpResponse.ok(.html(strHtml))
                } else {
                    return HttpResponse.unauthorized
                }
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
                if (json.token == self.token) {
                    if self.deviceEditJson?.isEmpty ?? true {
                        DeviceManager.shared.save(json: json)
                    } else {
                        DeviceManager.shared.edit(id: self.deviceEditId ?? UUID(), json: json)
                    }
                    self.delegate?.didFinish()
                    return HttpResponse.ok(.text("{\"status\": 200}"))
                } else {
                    return HttpResponse.badRequest(.text("{\"status\": 400, \"message\": \"Token inválido!\"}"))
                }
            } catch let error {
                print(error.localizedDescription)
                return HttpResponse.badRequest(.text("{\"status\": 400, \"message\": \"Requisição mal formada!\"}"))
            }
        }
        
        server["/api/authenticate"] = { [self] request in
            let data = Data(request.body)
            do {
                let json = try JSONDecoder().decode(DeviceAuthenticate.self, from: data)
                if VerificationCode.shared.verificateCode(code: json.code) {
                    token = UUID().uuidString
                    delegate?.didConectionDevice(ip: request.address ?? "", details: request.headers["user-agent"] ?? "")
                    deviceConnected = request.address ?? ""
                    return HttpResponse.ok(.text("{\"status\": 200, \"token\":\"\(token)\"}"))
                } else {
                    return HttpResponse.badRequest(.text("{\"status\": 400, \"message\": \"Código de verificação inválido!\"}"))
                }
            } catch let error {
                print(error.localizedDescription)
                return HttpResponse.badRequest(.text("{\"status\": 400, \"message\": \"Requisição mal formada!\"}"))
            }
        }
        
        
        server["/api/getDevice"] = { request in
            let data = Data(request.body)
            do {
                let json = try JSONDecoder().decode(DeviceToken.self, from: data)
                if self.token == json.token {
                    return HttpResponse.ok(.text(self.deviceEditJson ?? "{\"status\": 200,\"action\":\"add\"}"))
                } else {
                    return HttpResponse.badRequest(.text("{\"status\": 400, \"message\": \"Token inválido!\"}"))
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
    
    func setDeviceEdit(_ device: Device?) {
        guard let device = device else {
            deviceEditJson = nil
            deviceEditId = nil
            return
        }
        deviceEditJson = "{\"status\": 200,\"action\":\"edit\",\"name\":\"\(device.name)\",\"deviceProtocol\":\"\(device.deviceProtocol.rawValue)\",\"ip\":\"\(device.ip)\",\"port\":\"\(device.port)\",\"user\":\"\(device.user)\",\"password\":\"\(device.password)\",\"channels\":\"\(device.channels)\"}"
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
        deviceConnected = ""
        token = ""
        server.stop()
    }
    
    struct DeviceAuthenticate: Decodable {
        let code: Int
    }
    
    struct DeviceToken: Decodable {
        let token: String
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
    let token: String
    
    func getProtocol(channel: Int, quality: Quality) -> String {
        switch deviceProtocol {
        case .intelbras:
            return "rtsp://\(user):\(password)@\(ip):\(port)/cam/realmonitor?channel=\(channel)&subtype=\(quality.rawValue)"
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

enum Quality: Int {
    case high = 0
    case low = 1
}
