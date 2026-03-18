import Foundation
import Testing
@testable import AICostDashboard

// MARK: - 6. Cache Tests

@Suite("DiskCache")
struct CacheTests {

    private static let testModels = [
        AIModel(
            id: "test-model",
            name: "Test Model",
            family: "Test",
            providers: [ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 15.0)],
            contextWindow: 200_000,
            maxOutput: 64_000,
            speed: 78.0
        )
    ]

    // 6.1
    @Test("Save and load models round-trips correctly")
    func testCacheSaveAndLoad() async {
        let cache = DiskCache()
        let key = "test_cache_\(UUID().uuidString).json"

        await cache.saveModels(CacheTests.testModels, key: key)
        let loaded = await cache.loadModels(key: key)

        #expect(loaded != nil)
        #expect(loaded?.count == 1)
        #expect(loaded?.first?.name == "Test Model")
        #expect(loaded?.first?.providers.first?.provider == .anthropic)
        #expect(loaded?.first?.providers.first?.outputPer1M == 15.0)
        #expect(loaded?.first?.contextWindow == 200_000)
    }

    // 6.2
    @Test("Loading nonexistent key returns nil")
    func testCacheMissReturnsNil() async {
        let cache = DiskCache()
        let loaded = await cache.loadModels(key: "nonexistent_key_\(UUID().uuidString).json")
        #expect(loaded == nil)
    }

    @Test("Raw data save and load")
    func testRawDataSaveLoad() async {
        let cache = DiskCache()
        let key = "test_raw_\(UUID().uuidString).dat"
        let data = "hello world".data(using: .utf8)!

        await cache.save(data, key: key)
        let loaded = await cache.load(key: key)

        #expect(loaded == data)
    }
}
