const fs = require('fs');
const path = require('path');
const {getAndExecuteQuote} = require('./fx-client');
const {expect, test, beforeEach, describe} = require("@jest/globals");
const {UserOrder} = require("./user-order");

// Mocking the falconxClient
const mockFxClient = {
    getQuote: jest.fn(),
    executeQuote: jest.fn()
};

// Reading the JSONs from the specified files
const fxResponseExample = JSON.parse(fs.readFileSync(path.join(__dirname, 'fx-response.model.json'), 'utf8'));

describe('getAndExecuteQuote function', () => {

    beforeEach(() => {
        // Reset the mock functions before each test
        mockFxClient.getQuote.mockReset();
        mockFxClient.executeQuote.mockReset();
    });

    test('successful quote and execution', async () => {
        mockFxClient.getQuote.mockResolvedValue(fxResponseExample);
        mockFxClient.executeQuote.mockResolvedValue(fxResponseExample);
        fxOrder = new UserOrder("BUY", "ETH", "USD", 0.1, 294.0,)

        const result = await getAndExecuteQuote(
            mockFxClient,
            fxOrder,
            true
        );

        expect(result).toBe(""); // Expecting no error (empty string)
        expect(mockFxClient.getQuote).toHaveBeenCalledTimes(1);
        expect(mockFxClient.executeQuote).toHaveBeenCalledTimes(1);
    });

    test('opt-out of order execution', async () => {
        mockFxClient.getQuote.mockResolvedValue(fxResponseExample);
        order = new UserOrder("BUY", "ETH", "USD", 0.1, 294.0,)

        const result = await getAndExecuteQuote(
            mockFxClient,
            order,
            false
        );

        expect(mockFxClient.getQuote).toHaveBeenCalledTimes(1);
        expect(mockFxClient.executeQuote).toHaveBeenCalledTimes(0); // Should not be called
    });


    test('invalid quote received', async () => {
        mockFxClient.getQuote.mockResolvedValue({}); // Empty object, no fx_quote_id
        order = new UserOrder("BUY", "ETH", "USD", 0.1, 294.0,)

        const result = await getAndExecuteQuote(
            mockFxClient,
            order,
            true
        );

        expect(result).toContain("Quote does not contain the expected 'fx_quote_id' property:");
    });

    test('quote contains an error message', async () => {
        mockFxClient.getQuote.mockResolvedValue({message: "Some error message"});
        order = new UserOrder("BUY", "ETH", "USD", 0.1, 294.0,)

        const result = await getAndExecuteQuote(
            mockFxClient,
            order,
            true
        );

        expect(result).toBe("Received an FxError: Some error message");
    });

    test('error during quote execution', async () => {
        mockFxClient.getQuote.mockResolvedValue(undefined);
        order = new UserOrder("BUY", "ETH", "USD", 0.1, 294.0,)

        const result = await getAndExecuteQuote(
            mockFxClient,
            order,
            true
        );

        expect(result).toContain("Invalid quote received from Falconx:");
    });

    test('error during order execution', async () => {
        mockFxClient.getQuote.mockResolvedValue(fxResponseExample);
        mockFxClient.executeQuote.mockRejectedValue(new Error("Execution error"));
        order = new UserOrder("BUY", "ETH", "USD", 0.1, 294.0,)

        const result = await getAndExecuteQuote(
            mockFxClient,
            order,
            true
        );

        expect(result).toContain("Unknown error during falconx interaction:");
    });

    test('should throw error for invalid falconxClient', async () => {
        order = new UserOrder("BUY", "ETH", "USD", 0.1, 294.0,)
        await expect(getAndExecuteQuote(null, order)).resolves.toContain('falconxClient should be an object');
    });

    test('should throw error for invalid UserOrder', async () => {
        order = null
        await expect(getAndExecuteQuote(mockFxClient, order)).resolves.toContain('userOrder should be an object');
    });

    test('should throw error for invalid doExecute', async () => {
        order = new UserOrder("BUY", "ETH", "USD", 0.01, 3000)
        await expect(getAndExecuteQuote(mockFxClient, order, 'invalid')).resolves.toContain('doExecute should be a boolean');
    });

    test('should throw error for invalid quotePriceTolerance', async () => {
        order = new UserOrder("BUY", "ETH", "USD", 0.01, 3000)
        await expect(getAndExecuteQuote(mockFxClient, order, true, 'invalid')).resolves.toContain('quotePriceTolerance should be a number');
    });
});