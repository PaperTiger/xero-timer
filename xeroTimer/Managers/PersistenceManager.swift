import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let defaults = UserDefaults.standard
    private let activeTimerKey = "activeTimer"
    private let timersKey = "savedTimers"
    
    private init() {}
    
    func saveActiveTimer(_ timer: XeroTimeEntry) {
        if let encoded = try? JSONEncoder().encode(timer) {
            defaults.set(encoded, forKey: activeTimerKey)
        }
    }
    
    func loadActiveTimer() -> XeroTimeEntry? {
        guard let data = defaults.data(forKey: activeTimerKey),
              let timer = try? JSONDecoder().decode(XeroTimeEntry.self, from: data)
        else {
            return nil
        }
        return timer
    }
    
    func clearActiveTimer() {
        defaults.removeObject(forKey: activeTimerKey)
    }
    
    func saveTimers(_ timers: [XeroTimeEntry]) {
        if let encoded = try? JSONEncoder().encode(timers) {
            defaults.set(encoded, forKey: timersKey)
        }
    }
    
    func loadTimers() -> [XeroTimeEntry] {
        guard let data = defaults.data(forKey: timersKey),
              let timers = try? JSONDecoder().decode([XeroTimeEntry].self, from: data)
        else {
            return []
        }
        return timers
    }
} 