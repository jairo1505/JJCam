//
//  DeviceManager.swift
//  testSwifter
//
//  Created by Jairo Pereira Junior on 15/02/21.
//

import UIKit
import CoreData

class DeviceManager {
    static let shared = DeviceManager()
    private(set) var devices: [Device] = []
    private(set) var maxID = 0
    
    func save(json: Device) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Devices", in: context)
            let newUser = NSManagedObject(entity: entity!, insertInto: context)
            newUser.setValue(self.maxID, forKey: "id")
            newUser.setValue(json.deviceProtocol.rawValue, forKey: "deviceProtocol")
            newUser.setValue(json.name, forKey: "name")
            newUser.setValue(json.ip, forKey: "ip")
            newUser.setValue(json.port, forKey: "port")
            newUser.setValue(json.user, forKey: "user")
            newUser.setValue(json.password, forKey: "password")
            newUser.setValue(json.channels, forKey: "channels")
            do {
                try context.save()
                self.maxID += 1
            } catch {
                print("Falha ao Inserir o usuário")
            }
        }
    }
    
    func get(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.devices.removeAll()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Devices")
            //request.predicate = NSPredicate(format: "id == 0")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    let device = Device(id: data.value(forKey: "id") as? Int ?? 0,
                                        deviceProtocol: DeviceProtocol.init(rawValue: data.value(forKey: "deviceProtocol") as? String ?? "OTHER")!,
                                        name: data.value(forKey: "name") as? String ?? "",
                                        ip: data.value(forKey: "ip") as? String ?? "",
                                        port: data.value(forKey: "port") as? Int ?? 0,
                                        user: data.value(forKey: "user") as? String ?? "",
                                        password: data.value(forKey: "password") as? String ?? "",
                                        channels: data.value(forKey: "channels") as? Int ?? 0,
                                        code: 0)
                    self.maxID = data.value(forKey: "id") as? Int ?? 0
                    self.devices.append(device)
                }
                self.maxID += 1
                completion()
            } catch {
                print("Falha ao Excluir Usuário")
            }
        }
    }
    
    func remove(id: Int, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Devices")
            request.predicate = NSPredicate(format: "id == \(id)")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    context.delete(data)
                    try context.save()
                    self.get {
                        completion()
                    }
                }
            } catch {
                print("Falha ao excluir id: \(id)")
            }
        }
    }
    
    func removeAll(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Devices")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    context.delete(data)
                    try context.save()
                    self.get {
                        completion?()
                    }
                }
            } catch {
                print("Falha ao excluir tudo")
            }
        }
    }
}
