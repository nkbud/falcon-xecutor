const {parseOrder, FalconxOrder} = require('./order');
const {expect, test, describe} = require('@jest/globals');

/**
 * @param {FalconxOrder} actual - The returned value
 * @param {FalconxOrder} expected - The expected value
 */
function deepEquals(actual, expected) {
    expect(expected instanceof FalconxOrder).toBeTruthy();
    expect(actual instanceof FalconxOrder).toBeTruthy();
    expect(actual.buyOrSell).toBe(expected.buyOrSell);
    expect(actual.baseToken).toBe(expected.baseToken);
    expect(actual.quoteToken).toBe(expected.quoteToken);
    expect(actual.baseTokenAmount).toBe(expected.baseTokenAmount);
    expect(actual.quoteTokenPrice).toBe(expected.quoteTokenPrice);
}

describe('parse function', () => {

    test('parses a valid request', () => {
        // BUY
        let validInput = '' +
            'BUY\n0.0001 BTC\n30000 USD'
        let expectedParse = new FalconxOrder(
            "BUY",
            "BTC",
            "USD",
            0.0001,
            30000
        )
        let actualParse = parseOrder(validInput);
        deepEquals(actualParse, expectedParse);

        // SELL
        validInput = '' +
            'SELL\n1 BTC\n0.01 USD'
        expectedParse = new FalconxOrder(
            "SELL",
            "BTC",
            "USD",
            1,
            0.01
        )
        actualParse = parseOrder(validInput);
        deepEquals(actualParse, expectedParse);
    });

    test('returns error on invalid request', () => {
        // NOT 3 LINES
        let invalidInput = '' +
            'BUY 1 BTC 0.0001 USD'
        let actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO EXEC ACTION
        invalidInput = '' +
            '0.0001 BTC\n30000 USD'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // BAD EXEC KEY
        invalidInput = '' +
            'IDK\n0.001 BTC\n3000.1 USD'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO BASE TOKEN
        invalidInput = '' +
            'BUY\n0.0001\n30000 USD'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO BASE AMOUNT
        invalidInput = '' +
            'BUY\nBTC\n30000 USD'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // BAD BASE AMOUNT
        invalidInput = '' +
            'SELL\nidk BTC\n30000 USD'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO QUOTE TOKEN
        invalidInput = '' +
            'BUY\n0.0001 BTC\n30000 '
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO QUOTE PRICE
        invalidInput = '' +
            'SELL\n0.1 BTC\n USD'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // BAD QUOTE PRICE
        invalidInput = '' +
            'SELL\n0.1 BTC\nidk USD'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');
    });
});