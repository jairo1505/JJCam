//
//  AboutViewController.swift
//  testSwifter
//
//  Created by Jairo Pereira Junior on 16/02/21.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var textBody: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let textAbout = "Este aplicativo é destinado para a visualização em tempo real de câmeras\nde circuito interno de televisão através do protocolo RTSP.\n\nCriado por Jairo Pereira Junior ✌🏻\nEngenharia de Software 💻\nCentro Universitário Católica de Santa Catarina\n\nCopyright © 2021."
        
        textBody.text = textAbout
    }

}
