const path = require('path');
const fs = require('fs');

// we check to see if the request came from these ip addresses:
const allowedIpAddrs = [
    "localhost",
    "52.89.214.238",
    "34.212.75.30",
    "54.218.53.128",
    "52.32.178.7",
    // me
    "96.35.0.217",
];

// and ends with the signature
const signatureFilePath = path.join(__dirname, 'index.html');
const signature = fs.readFileSync(signatureFilePath, 'utf8');

function getSignature() {
    return signature;
}

function getSignaturePath() {
    return signatureFilePath;
}

/**
 * Authenticates a request based on IP address and request body signature.
 *
 * @param {string} ipAddr - The IP address of the request.
 * @param {string} reqBodyText - The text of the request body.
 * @returns {string} - Returns an empty string if authentication is successful, otherwise returns an error message.
 * @throws {Error} - Throws an error if the provided arguments are not of the expected type.
 */
function authenticate(ipAddr, reqBodyText) {
    // Validate input types
    if (typeof ipAddr !== 'string' || typeof reqBodyText !== 'string') {
        return `Invalid input types. Expected strings for both ipAddr: ${ipAddr} and reqBodyText: ${reqBodyText}`;
    }

    // Check IP address against allowed list
    if (!allowedIpAddrs.includes(ipAddr)) {
        return `Failed authentication: ${ipAddr}`;
    }

    // Remove whitespace from request body and signature for comparison
    const noWsReqBody = reqBodyText.replace(/\s+/g, '');
    const noWsSignature = signature.replace(/\s+/g, '');
    const reqBodyEndsWithSignature = noWsReqBody.endsWith(noWsSignature);

    // Check if request body ends with the expected signature
    if (!reqBodyEndsWithSignature) {
        return "Failed signature.";
    }

    // Return empty string if authentication is successful
    return "";
}


module.exports = {
    authenticate,
    getSignature,
    getSignaturePath
}