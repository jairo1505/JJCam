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
        
        DispatchQueue.global().async {
            self.server.start()
        }
        
        lbInfo.text = "ou digite: http://\(server.getIP()):\(server.getPort())/\n\nCódigo de verificação: \(VerificationCode.shared.generateCode())"
        let image = generateQRCode(from: "http://\(server.getIP()):\(server.getPort())/")
        img_qrcode.image = image
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
