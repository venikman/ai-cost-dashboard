import Foundation

public actor DiskCache {
    private let directory: URL

    public init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        directory = appSupport.appendingPathComponent("AICostDashboard/Cache", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    public func save(_ data: Data, key: String) {
        let file = directory.appendingPathComponent(key)
        try? data.write(to: file)
    }

    public func load(key: String) -> Data? {
        let file = directory.appendingPathComponent(key)
        return try? Data(contentsOf: file)
    }

    public func saveModels(_ models: [AIModel], key: String) {
        guard let data = try? JSONEncoder().encode(models) else { return }
        save(data, key: key)
    }

    public func loadModels(key: String) -> [AIModel]? {
        guard let data = load(key: key),
              let models = try? JSONDecoder().decode([AIModel].self, from: data) else { return nil }
        return models
    }

    public func cacheAge(key: String) -> TimeInterval? {
        let file = directory.appendingPathComponent(key)
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: file.path),
              let date = attrs[.modificationDate] as? Date else { return nil }
        return Date().timeIntervalSince(date)
    }
}
