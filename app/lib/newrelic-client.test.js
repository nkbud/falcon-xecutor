const {describe, expect, test} = require('@jest/globals');
const newrelicClient = require('newrelic')
// falcon-xecutor/test is invalid, it must match /^[a-zA-Z0-9:_ ]+$/"

describe('newrelic client', () => {

    test('newrelic can send an event', async () => {
        const result = newrelicClient.recordCustomEvent("falcon_xecutor:test", {"test": 1})
        expect(result).toBe(undefined)
    });

});
