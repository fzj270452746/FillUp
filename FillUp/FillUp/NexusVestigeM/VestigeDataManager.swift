//
//  VestigeDataManager.swift
//  FillUp
//
//  Game data manager for storing and retrieving game records
//

import UIKit
import CoreData

// MARK: - Game Record Model
struct VestigeRecord: Codable {
    let identifier: UUID
    let score: Int
    let roundsCompleted: Int
    let tileType: String
    let duration: Double // in seconds
    let timestamp: Date
    
    init(score: Int, roundsCompleted: Int, tileType: String, duration: Double = 0) {
        self.identifier = UUID()
        self.score = score
        self.roundsCompleted = roundsCompleted
        self.tileType = tileType
        self.duration = duration
        self.timestamp = Date()
    }
}

// MARK: - Data Manager
class VestigeDataManager {
    static let shared = VestigeDataManager()
    
    let context: NSManagedObjectContext
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }
    
    // Save a game record
    func archiveRecord(score: Int, rounds: Int, tileType: String, duration: Double) {
        let entity = NSEntityDescription.entity(forEntityName: "GameRecord", in: context)!
        let record = NSManagedObject(entity: entity, insertInto: context)
        
        record.setValue(UUID(), forKey: "identifier")
        record.setValue(score, forKey: "score")
        record.setValue(rounds, forKey: "rounds")
        record.setValue(tileType, forKey: "tileType")
        record.setValue(duration, forKey: "duration")
        record.setValue(Date(), forKey: "timestamp")
        
        do {
            try context.save()
        } catch {
            print("Failed to save record: \(error)")
        }
    }
    
    // Fetch all records
    func retrieveRecords() -> [VestigeRecord] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameRecord")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { object in
                guard let score = object.value(forKey: "score") as? Int,
                      let rounds = object.value(forKey: "rounds") as? Int,
                      let tileType = object.value(forKey: "tileType") as? String else {
                    return nil
                }
                
                let duration = object.value(forKey: "duration") as? Double ?? 0
                
                return VestigeRecord(score: score, roundsCompleted: rounds, tileType: tileType, duration: duration)
            }
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }
    
    // Delete all records
    func obliterateAllRecords() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GameRecord")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete records: \(error)")
        }
    }
    
    // Delete specific record
    func obliterateRecord(at index: Int) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameRecord")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            if index < results.count {
                context.delete(results[index])
                try context.save()
            }
        } catch {
            print("Failed to delete record: \(error)")
        }
    }
}

// MARK: - Tile Type Definition
enum TileCategoryType: String {
    case fillA = "fillA"
    case fillB = "fillB"
    case fillC = "fillC"
    
    func retrieveImage(for value: Int) -> UIImage? {
        let imageName = "\(self.rawValue) \(value)"
        return UIImage(named: imageName)
    }
    
    var displayName: String {
        switch self {
        case .fillA: return "Bamboo Series"
        case .fillB: return "Character Series"
        case .fillC: return "Circle Series"
        }
    }
}

