const {authenticate, getSignature} = require('./auth');
const {describe, expect, test} = require('@jest/globals');

describe('authenticate function', () => {

    // Test for successful authentication
    test('empty string on a valid request', () => {
        const validIp = "localhost";
        const validReqBody = "Some request body content here" + getSignature()
        const result = authenticate(validIp, validReqBody);
        expect(result).toBe("");
    });

    // Test for failed IP address authentication
    test('error string on an invalid IP address', () => {
        const invalidIp = "192.168.1.1";
        const validReqBody = "Some request body content here" + getSignature()
        const result = authenticate(invalidIp, validReqBody);
        expect(result.length).toBeGreaterThan(0);
    });

    // Test for failed signature authentication
    test('error string on an invalid request body signature', () => {
        const validIp = "localhost";
        const invalidReqBody = "Some request body content here without the correct signature";
        const result = authenticate(validIp, invalidReqBody);
        expect(result.length).toBeGreaterThan(0);
    });

    // Test for invalid input types
    test('error string on invalid input types', () => {
        const invalidIp = 12345;
        const invalidReqBody = ["Some request body content here"];
        const result = authenticate(invalidIp, invalidReqBody);
        expect(result.length).toBeGreaterThan(0);
    });
});