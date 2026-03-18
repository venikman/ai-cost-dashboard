import Foundation

public actor PricingService {
    private let openRouter = OpenRouterAPI()
    private let liteLLM = LiteLLMDataSource()
    private let cache = DiskCache()

    private let cacheKey = "merged_models.json"
    private let maxCacheAge: TimeInterval = 15 * 60 // 15 minutes

    public init() {}

    /// Fetches models from both sources, merges them, and returns the result.
    /// Falls back to cache if network fails.
    public func fetchAll() async -> (models: [AIModel], fromCache: Bool) {
        // Try loading from cache first for instant display
        let cached = await cache.loadModels(key: cacheKey)

        do {
            // Fetch from both sources in parallel
            async let orModels = openRouter.fetchModels()
            async let llmModels = liteLLM.fetchModels()

            let (openRouterResult, liteLLMResult) = try await (orModels, llmModels)
            let merged = ModelMatcher.merge(openRouterModels: openRouterResult, liteLLMModels: liteLLMResult)

            // Cache the result
            await cache.saveModels(merged, key: cacheKey)

            return (merged, false)
        } catch {
            print("⚠️ Fetch failed: \(error.localizedDescription). Using cache.")
            return (cached ?? [], true)
        }
    }

    /// Returns cached models if available (for instant startup).
    public func loadCached() async -> [AIModel]? {
        await cache.loadModels(key: cacheKey)
    }
}
