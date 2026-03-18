import Testing
@testable import AICostDashboard

// MARK: - 5. Formatting Tests

@Suite("PriceFormatter")
struct PriceFormatterTests {

    // 5.1
    @Test("Formats small prices with 4 decimal places")
    func testPriceFormatSmall() {
        #expect(PriceFormatter.format(0.075) == "$0.075")
        #expect(PriceFormatter.format(0.003) == "$0.0030")
        #expect(PriceFormatter.format(0.0001) == "$0.0001")
    }

    // 5.2
    @Test("Formats medium prices with 2 decimal places")
    func testPriceFormatMedium() {
        #expect(PriceFormatter.format(3.00) == "$3.00")
        #expect(PriceFormatter.format(15.00) == "$15.00")
        #expect(PriceFormatter.format(0.50) == "$0.500")
    }

    // 5.3
    @Test("Formats large prices without decimals")
    func testPriceFormatLarge() {
        #expect(PriceFormatter.format(75.00) == "$75.00")
        #expect(PriceFormatter.format(150.00) == "$150")
        #expect(PriceFormatter.format(9710.00) == "$9710")
    }

    // 5.4
    @Test("Formats context window tokens")
    func testContextFormat() {
        #expect(PriceFormatter.formatContext(200_000) == "200K")
        #expect(PriceFormatter.formatContext(128_000) == "128K")
        #expect(PriceFormatter.formatContext(1_000_000) == "1M")
        #expect(PriceFormatter.formatContext(2_000_000) == "2M")
        #expect(PriceFormatter.formatContext(1_500_000) == "1.5M")
    }

    // 5.5
    @Test("Formats speed in tokens per second")
    func testSpeedFormat() {
        #expect(PriceFormatter.formatSpeed(78.0) == "78 t/s")
        #expect(PriceFormatter.formatSpeed(200.0) == "200 t/s")
        #expect(PriceFormatter.formatSpeed(1500.0) == "1500 t/s")
    }

    @Test("Formats savings percentage")
    func testSavingsFormat() {
        #expect(PriceFormatter.formatSavings(0) == "—")
        #expect(PriceFormatter.formatSavings(-5) == "—")
        #expect(PriceFormatter.formatSavings(15) == "↓15%")
        #expect(PriceFormatter.formatSavings(94.3) == "↓94%")
    }

    @Test("Formats price pair")
    func testFormatPair() {
        let result = PriceFormatter.formatPair(input: 3.00, output: 15.00)
        #expect(result == "$3.00 / $15.00")
    }
}
