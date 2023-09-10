// a server
const express = require('express');
const app = express();
const PORT = 1000;

// that handles plaintext request bodies
const {text} = require("express");
app.use(text());

// custom helper functions
const {authenticate, getSignature} = require('./lib/auth')
const {parseOrder, FalconxOrder} = require('./lib/parseOrder')
const {getAndExecuteQuote} = require('./lib/falconx')

// a real falconx client
const FalconxClient = require('falconx-node')
const fxClient = new FalconxClient(
    process.env.FALCONX_API_KEY,
    process.env.FALCONX_SECRET_KEY,
    process.env.FALCONX_PASSPHRASE
);

// GET
app.get("/health", (req, res) => {
    return res.send("OK");
});

app.get('/', (req, res) => {
    res.send(getSignature());
});

// POST
const nginxIpAddrHeader = 'X-Real-IP';
app.post('/', async (req, res) => {
    try {
        // Extract and log info
        const reqBody = req.body
        console.log(reqBody)
        const ipAddr = req.header(nginxIpAddrHeader)
        console.log(ipAddr)

        // Authenticate request
        const authError = authenticate(ipAddr, reqBody);
        if (authError) {
            return res.status(401).send();
        }

        // Parse request
        const parsedOrder = parseOrder(reqBody)
        if (!(parsedOrder instanceof FalconxOrder)) {
            console.error(`Error parsing the request body: ${parsedOrder}`);
            return res.status(400).send()
        }
        await getAndExecuteQuote(parsedOrder);

    } catch (error) {
        console.error(`Server error processing request: ${error}`);
        return res.status(500).send('Internal server error.');
    }
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});

