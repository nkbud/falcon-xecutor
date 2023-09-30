const newrelicClient = require("newrelic");

// a server
const path = require('path');
const express = require('express');
const app = express();
const PORT = 1000;

// that handles plaintext request bodies
app.use(express.text());

// custom helper functions
const {authenticate, getSignaturePath} = require('./lib/user-auth')
const {parseOrder, UserOrder} = require('./lib/user-order')
const {getAndExecuteQuote} = require('./lib/fx-client')

// a real falconx client
const FalconxClient = require('falconx-node')
const fxClient = new FalconxClient(
    process.env.FALCONX_API_KEY,
    process.env.FALCONX_SECRET_KEY,
    process.env.FALCONX_PASSPHRASE
);

//
// GET
//

app.get("/health", (req, res) => {
    return res.send("OK");
});

app.use('/img', express.static(path.join(__dirname, 'img')));
app.get('/', (req, res) => {
    res.sendFile(getSignaturePath());
});

//
// POST
//

const nginxIpAddrHeader = 'X-Real-IP';
app.post('/', async (req, res) => {
    try {
        // Extract and log info
        const reqBody = req.body
        const ipAddr = req.header(nginxIpAddrHeader)

        // Authenticate request
        const authError = authenticate(ipAddr, reqBody);
        if (authError) {
            console.error(authError);
            return res.status(401).send(authError);
        }

        // Parse request
        const parsedOrder = parseOrder(reqBody)
        if (!(parsedOrder instanceof UserOrder)) {
            console.error(`Error parsing the request body: ${parsedOrder}`);
            return res.status(400).send()
        }

        // Get and execute a quote:
        const fxErrorMessage = await getAndExecuteQuote(
            fxClient,
            parsedOrder,
            false,
        );
        if (fxErrorMessage) {
            console.error(fxErrorMessage);
            return res.status(500).send();
        }

    } catch (error) {
        console.error(`Server error processing request: ${error}`);
        return res.status(500).send('Internal server error.');
    }

    console.log("Request success.")
    return res.status(200).send();
});

//
// run()
//

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
    console.error('There was an uncaught error', err);
});

