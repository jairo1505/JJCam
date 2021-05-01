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
    
    // MARK: - Devices
    func save(json: Device) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Devices", in: context)
            let newUser = NSManagedObject(entity: entity!, insertInto: context)
            newUser.setValue(UUID(), forKey: "id")
            newUser.setValue(json.deviceProtocol.rawValue, forKey: "deviceProtocol")
            newUser.setValue(json.name, forKey: "name")
            newUser.setValue(json.ip, forKey: "ip")
            newUser.setValue(json.port, forKey: "port")
            newUser.setValue(json.user, forKey: "user")
            newUser.setValue(json.password, forKey: "password")
            newUser.setValue(json.channels, forKey: "channels")
            do {
                try context.save()
            } catch {
                print("Falha ao Inserir o dispositivo")
            }
        }
    }
    
    func edit(id: UUID, json: Device) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Devices")
            request.predicate = NSPredicate(format: "id == \"\(id)\"")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                let data = result[0] as! NSManagedObject
                data.setValue(json.deviceProtocol.rawValue, forKey: "deviceProtocol")
                data.setValue(json.name, forKey: "name")
                data.setValue(json.ip, forKey: "ip")
                data.setValue(json.port, forKey: "port")
                data.setValue(json.user, forKey: "user")
                data.setValue(json.password, forKey: "password")
                data.setValue(json.channels, forKey: "channels")
                try context.save()
            } catch {
                print("Falha ao Editar o dispositivo")
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
                    let device = Device(id: data.value(forKey: "id") as? UUID ?? UUID(),
                                        deviceProtocol: DeviceProtocol.init(rawValue: data.value(forKey: "deviceProtocol") as? String ?? "OTHER")!,
                                        name: data.value(forKey: "name") as? String ?? "",
                                        ip: data.value(forKey: "ip") as? String ?? "",
                                        port: data.value(forKey: "port") as? Int ?? 0,
                                        user: data.value(forKey: "user") as? String ?? "",
                                        password: data.value(forKey: "password") as? String ?? "",
                                        channels: data.value(forKey: "channels") as? Int ?? 0,
                                        token: "")
                    self.devices.append(device)
                }
                completion()
            } catch {
                print("Falha ao listar dispositivos")
            }
        }
    }
    
    func remove(id: UUID, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Devices")
            request.predicate = NSPredicate(format: "id == \"\(id)\"")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    context.delete(data)
                    try context.save()
                    self.removeAllViews(deviceId: id)
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
                    self.removeAllViews(deviceId: data.value(forKey: "id") as? UUID ?? UUID())
                    context.delete(data)
                    try context.save()
                }
                self.get {
                    completion?()
                }
            } catch {
                print("Falha ao excluir tudo")
            }
        }
    }
    
    // MARK: - Views
    func newView(name: String, deviceId: UUID, cameras: [Int]) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Views", in: context)
            let newUser = NSManagedObject(entity: entity!, insertInto: context)
            let uuid = UUID()
            newUser.setValue(uuid, forKey: "id")
            newUser.setValue(name, forKey: "name")
            newUser.setValue(deviceId, forKey: "deviceId")
            do {
                try context.save()
                self.newCameras(viewId: uuid, cameras: cameras)
            } catch {
                print("Falha ao Inserir o dispositivo")
            }
        }
    }
    
    func getViews(deviceId: UUID, completion: @escaping (_ views: [DeviceView]) -> Void) {
        DispatchQueue.main.async {
            var views: [DeviceView] = []
            let group = DispatchGroup()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Views")
            request.predicate = NSPredicate(format: "deviceId == \"\(deviceId)\"")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    group.enter()
                    self.getCameras(viewId: data.value(forKey: "id") as? UUID ?? UUID()) { cameras in
                        let deviceView = DeviceView(id: data.value(forKey: "id") as? UUID ?? UUID(),
                                            deviceId: data.value(forKey: "deviceId") as? UUID ?? UUID(),
                                            name: data.value(forKey: "name") as? String ?? "",
                                            cameras: cameras)
                        views.append(deviceView)
                        group.leave()
                    }
                }
            } catch {
                print("Falha ao listar dispositivos")
            }
            group.notify(queue: .main) {
                completion(views)
            }

        }
    }
    
    func removeView(id: UUID, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Views")
            request.predicate = NSPredicate(format: "id == \"\(id)\"")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    context.delete(data)
                    try context.save()
                    completion()
                }
            } catch {
                print("Falha ao excluir id: \(id)")
            }
        }
    }
    
    func removeAllViews(deviceId: UUID) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Views")
            request.predicate = NSPredicate(format: "deviceId == \"\(deviceId)\"")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    context.delete(data)
                    try context.save()
                }
            } catch {
                print("Falha ao excluir id: \(deviceId)")
            }
        }
    }
    
    func newCameras(viewId: UUID, cameras: [Int]) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "CamerasView", in: context)
            cameras.forEach {
                let newUser = NSManagedObject(entity: entity!, insertInto: context)
                
                newUser.setValue(UUID(), forKey: "id")
                newUser.setValue(viewId, forKey: "viewId")
                newUser.setValue($0, forKey: "number")
                do {
                    try context.save()
                } catch {
                    print("Falha ao Inserir o dispositivo")
                }
            }
        }
    }
    
    func getCameras(viewId: UUID, completion: @escaping (_ cameras: [Int]) -> Void) {
        DispatchQueue.main.async {
            var cameras: [Int] = []
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CamerasView")
            request.predicate = NSPredicate(format: "viewId == \"\(viewId)\"")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    cameras.append(data.value(forKey: "number") as? Int ?? 0)
                }
                completion(cameras)
            } catch {
                print("Falha ao listar dispositivos")
            }
        }
    }
    
    func removeCameras(viewId: UUID, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CamerasView")
            request.predicate = NSPredicate(format: "viewId == \"\(viewId)\"")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    context.delete(data)
                    try context.save()
                }
                completion()
            } catch {
                print("Falha ao excluir id: \(viewId)")
            }
        }
    }

    struct DeviceView {
        let id: UUID
        let deviceId: UUID
        let name: String
        let cameras: [Int]
    }
}
