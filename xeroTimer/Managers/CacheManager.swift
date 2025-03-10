import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    private let cache = NSCache<NSString, AnyObject>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private let maxMemoryCacheSize = 50 * 1024 * 1024  // 50 MB
    private let maxDiskCacheSize = 100 * 1024 * 1024   // 100 MB
    
    init() {
        cache.totalCostLimit = maxMemoryCacheSize
        
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("XeroTimer")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Clean up old cache files
        cleanDiskCache()
    }
    
    // MARK: - Memory Cache
    
    func cacheInMemory<T: AnyObject>(_ object: T, forKey key: String) {
        cache.setObject(object, forKey: key as NSString)
    }
    
    func getFromMemory<T: AnyObject>(forKey key: String) -> T? {
        return cache.object(forKey: key as NSString) as? T
    }
    
    func removeFromMemory(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    // MARK: - Disk Cache
    
    func cacheOnDisk<T: Encodable>(_ object: T, forKey key: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        let data = try JSONEncoder().encode(object)
        try data.write(to: fileURL)
    }
    
    func getFromDisk<T: Decodable>(forKey key: String) throws -> T {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func removeFromDisk(forKey key: String) throws {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try fileManager.removeItem(at: fileURL)
    }
    
    // MARK: - Cache Management
    
    private func cleanDiskCache() {
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentModificationDateKey, .totalFileAllocatedSizeKey]
        
        guard let fileEnumerator = fileManager.enumerator(
            at: cacheDirectory,
            includingPropertiesForKeys: Array(resourceKeys)
        ) else { return }
        
        var totalSize: UInt64 = 0
        var cacheFiles: [(url: URL, date: Date)] = []
        
        for case let fileURL as URL in fileEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  !resourceValues.isDirectory! else {
                continue
            }
            
            totalSize += UInt64(resourceValues.totalFileAllocatedSize ?? 0)
            if let modificationDate = resourceValues.contentModificationDate {
                cacheFiles.append((fileURL, modificationDate))
            }
        }
        
        if totalSize > maxDiskCacheSize {
            let targetSize = maxDiskCacheSize / 2
            
            let sortedFiles = cacheFiles.sorted { $0.date < $1.date }
            var currentSize = totalSize
            
            for file in sortedFiles {
                try? fileManager.removeItem(at: file.url)
                
                if let fileSize = try? file.url.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize {
                    currentSize -= UInt64(fileSize)
                    if currentSize < targetSize {
                        break
                    }
                }
            }
        }
    }
    
    func clearAll() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
} 