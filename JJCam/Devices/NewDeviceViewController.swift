//
//  NewDeviceViewController.swift
//  testSwifter
//
//  Created by Jairo Pereira Junior on 15/02/21.
//

import UIKit

class NewDeviceViewController: UIViewController {
    private let server = Server.shared
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var lbInfo: UILabel!
    @IBOutlet weak var img_qrcode: UIImageView!
    @IBOutlet weak var tokenView: UIView!
    @IBOutlet weak var viewWaitingConnection: UIView!
    @IBOutlet weak var viewDeviceConnected: UIView!
    @IBOutlet weak var infoImg: UIImageView!
    @IBOutlet weak var infoDevice: UILabel!
    
    private var circularView: CircularProgressView!
    
    public var device: Device?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let device = device {
            navigationBar.topItem?.title = "Editar \(device.name)"
            server.setDeviceEdit(device)
        } else {
            navigationBar.topItem?.title = "Adicionar Dispositivo"
            server.setDeviceEdit(nil)
        }
        
        server.delegate = self
        
        DispatchQueue.global().async {
            self.server.start()
        }
        
        lbInfo.text = "ou digite: http://\(server.getIP()):\(server.getPort())/"
        let image = generateQRCode(from: "http://\(server.getIP()):\(server.getPort())/")
        img_qrcode.image = image
    }
    
    override func viewDidAppear(_ animated: Bool) {
        circularView = CircularProgressView(frame: CGRect(x: view.frame.origin.x/2, y: view.frame.origin.y/2, width: view.frame.size.width/2, height: view.frame.size.height-120))
        circularView.delegate = self
        tokenView.addSubview(circularView)
        circularView.setText("\(VerificationCode.shared.generateCode())")
        circularView.progressAnimation(duration: 30)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        circularView = nil
        server.stop()
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
}

extension NewDeviceViewController: CircularProgressViewDelegate {
    func didFinishAnimation() {
        if circularView != nil {
            circularView.setText("\(VerificationCode.shared.generateCode())")
            circularView.progressAnimation(duration: 30)
        }
    }
}

extension NewDeviceViewController: ServerDelegate {
    func didConectionDevice(ip: String, details: String) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1) { [self] in
                viewWaitingConnection.alpha = .zero
            } completion: { [self] _ in
                circularView = nil
                infoDevice.text = "IP \(ip) conectado à Apple TV\n\nDescrição: \(details)"
                UIView.animate(withDuration: 1) { [self] in
                    viewDeviceConnected.alpha = 1
                } completion: { _ in
                    
                }
                
            }
        }
    }
    
    func didFinish() {
        DispatchQueue.main.async {
            self.server.stop()
            UIView.animate(withDuration: 1) { [self] in
                viewDeviceConnected.alpha = .zero
            } completion: { [self] _ in
                infoImg.image = UIImage(systemName: "checkmark.circle")
                infoDevice.text = "Dispositivo salvo com sucesso!\n\nEsta página irá fechar automáticamente em 10 segundos"
                UIView.animate(withDuration: 1) { [self] in
                    viewDeviceConnected.alpha = 1
                } completion: { _ in
                    var index = 9
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                        infoDevice.text = "Dispositivo salvo com sucesso!\n\nEsta página irá fechar automáticamente em \(index) segundos"
                        if index == 0 {
                            timer.invalidate()
                            self.dismiss(animated: true, completion: nil)
                        }
                        index -= 1
                    }
                }
            }

        }
    }
}
