const {parseOrder, FalconxOrder} = require('./parseOrder');
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
            'exec: BUY\nbase: BTC 0.0001\nquote: USD 30000'
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
            'exec: SELL\nbase: BTC 1\nquote: USD 0.01'
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
            'exec: BUY base: BTC 0.0001 quote: USD 30000'
        let actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO EXEC ACTION
        invalidInput = '' +
            'exec: \nbase: BTC 0.0001\nquote: USD 30000'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // BAD EXEC KEY
        invalidInput = '' +
            'exe: IDK\nbase: BTC 0.0001\nquote: USD 30000'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO BASE TOKEN
        invalidInput = '' +
            'exec: \nbase: 0.0001\nquote: USD 30000'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO BASE AMOUNT
        invalidInput = '' +
            'exec: BUY\nbase: BTC\nquote: USD 30000'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO BASE TOKEN
        invalidInput = '' +
            'exec: BUY\nbase: 0.0001\nquote: USD 30000'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO BASE AMOUNT
        invalidInput = '' +
            'exec: SELL\nbase: BTC\nquote: USD 30000'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // BAD BASE AMOUNT
        invalidInput = '' +
            'exec: SELL\nbase: BTC idk\nquote: USD 30000'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO QUOTE TOKEN
        invalidInput = '' +
            'exec: BUY\nbase: BTC 0.0001\nquote: 30000'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // NO QUOTE PRICE
        invalidInput = '' +
            'exec: SELL\nbase: BTC 0.0001\nquote: USD'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');

        // BAD QUOTE PRICE
        invalidInput = '' +
            'exec: SELL\nbase: BTC 0.0001\nquote: USD idk'
        actualParse = parseOrder(invalidInput);
        expect(typeof(actualParse)).toBe('string');
    });
});