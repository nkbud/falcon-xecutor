const fs = require('fs');
const path = require('path');
const { getAndExecuteQuote } = require('./falconx');
const {expect, test, beforeEach, describe} = require("@jest/globals");

// Mocking the falconxClient
const mockFalconxClient = {
    getQuote: jest.fn(),
    executeQuote: jest.fn()
};

// Reading the JSONs from the specified files
const getQuoteExample = JSON.parse(fs.readFileSync(path.join(__dirname, 'falconx.getQuote.example.json'), 'utf8'));
const executeQuoteExample = JSON.parse(fs.readFileSync(path.join(__dirname, 'falconx.executeQuote.example.json'), 'utf8'));

describe('getAndExecuteQuote function', () => {

    beforeEach(() => {
        // Reset the mock functions before each test
        mockFalconxClient.getQuote.mockReset();
        mockFalconxClient.executeQuote.mockReset();
    });

    test('successful quote and execution', async () => {
        mockFalconxClient.getQuote.mockResolvedValue(getQuoteExample);
        mockFalconxClient.executeQuote.mockResolvedValue(executeQuoteExample);

        const result = await getAndExecuteQuote(
            mockFalconxClient,
            "BUY",
            "ETH",
            "USD",
            0.1,
            294.0,
            true
        );

        expect(result).toBe(""); // Expecting no error (empty string)
        expect(mockFalconxClient.getQuote).toHaveBeenCalledTimes(1);
        expect(mockFalconxClient.executeQuote).toHaveBeenCalledTimes(1);
    });

    test('opt-out of order execution', async () => {
        mockFalconxClient.getQuote.mockResolvedValue(getQuoteExample);

        const result = await getAndExecuteQuote(
            mockFalconxClient,
            "BUY",
            "ETH",
            "USD",
            0.1,
            294.0,
            false
        );

        expect(result).toBe("Function caller opted-out of order execution.");
        expect(mockFalconxClient.getQuote).toHaveBeenCalledTimes(1);
        expect(mockFalconxClient.executeQuote).toHaveBeenCalledTimes(0); // Should not be called
    });


    test('invalid quote received', async () => {
        mockFalconxClient.getQuote.mockResolvedValue({}); // Empty object, no fx_quote_id

        const result = await getAndExecuteQuote(
            mockFalconxClient,
            "BUY",
            "ETH",
            "USD",
            0.1,
            294.0,
            true
        );

        expect(result).toBe("Quote does not contain the expected 'fx_quote_id' property: [object Object]");
    });

    test('quote contains an error message', async () => {
        mockFalconxClient.getQuote.mockResolvedValue({ message: "Some error message" });

        const result = await getAndExecuteQuote(
            mockFalconxClient,
            "BUY",
            "ETH",
            "USD",
            0.1,
            294.0,
            true
        );

        expect(result).toBe("Received an FxError: Some error message");
    });

    test('error during order execution', async () => {
        mockFalconxClient.getQuote.mockResolvedValue(getQuoteExample);
        mockFalconxClient.executeQuote.mockRejectedValue(new Error("Execution error"));

        const result = await getAndExecuteQuote(
            mockFalconxClient,
            "BUY",
            "ETH",
            "USD",
            0.1,
            294.0,
            true
        );

        expect(result).toBe("Unknown error during falconx interaction: Error: Execution error");
    });

    test('should throw error for invalid falconxClient', async () => {
        await expect(getAndExecuteQuote(null, 'BUY', 'BTC', 'USD', 1, 30000)).resolves.toEqual('falconxClient should be an object: null');
    });

    test('should throw error for invalid buyOrSell', async () => {
        await expect(getAndExecuteQuote(mockFalconxClient, 'INVALID', 'BTC', 'USD', 1, 30000)).resolves.toEqual('buyOrSell should be either BUY or SELL: INVALID');
    });

    test('should throw error for invalid baseToken', async () => {
        await expect(getAndExecuteQuote(mockFalconxClient, 'BUY', 123, 'USD', 1, 30000)).resolves.toEqual('baseToken should be a string: 123');
    });

    test('should throw error for invalid quoteToken', async () => {
        await expect(getAndExecuteQuote(mockFalconxClient, 'BUY', 'BTC', 456, 1, 30000)).resolves.toEqual('quoteToken should be a string: 456');
    });

    test('should throw error for invalid baseTokenAmount', async () => {
        await expect(getAndExecuteQuote(mockFalconxClient, 'BUY', 'BTC', 'USD', 'invalid', 30000)).resolves.toEqual('baseTokenAmount should be a number: invalid');
    });

    test('should throw error for invalid quoteTokenPrice', async () => {
        await expect(getAndExecuteQuote(mockFalconxClient, 'BUY', 'BTC', 'USD', 1, 'invalid')).resolves.toEqual('quoteTokenPrice should be a number: invalid');
    });

    test('should throw error for invalid doExecute', async () => {
        await expect(getAndExecuteQuote(mockFalconxClient, 'BUY', 'BTC', 'USD', 1, 30000, 'invalid')).resolves.toEqual('doExecute should be a boolean: invalid');
    });

    test('should throw error for invalid quotePriceTolerance', async () => {
        await expect(getAndExecuteQuote(mockFalconxClient, 'BUY', 'BTC', 'USD', 1, 30000, true, 'invalid')).resolves.toEqual('quotePriceTolerance should be a number: invalid');
    });
});