// a server
const express = require('express');
const app = express();
const PORT = 1000;

// that handles plaintext request bodies
app.use(express.text());

// custom helper functions
const {authenticate, getSignaturePath} = require('./lib/auth')
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
    res.sendFile(getSignaturePath());
});

app.use('/img', express.static(path.join(__dirname, 'img')));

// POST
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
        if (!(parsedOrder instanceof FalconxOrder)) {
            console.error(`Error parsing the request body: ${parsedOrder}`);
            return res.status(400).send()
        }

        // Get and execute a quote:
        const falconxError = await getAndExecuteQuote(
            fxClient,
            parsedOrder.buyOrSell,
            parsedOrder.baseToken,
            parsedOrder.quoteToken,
            parsedOrder.baseTokenAmount,
            parsedOrder.quoteTokenPrice,
            false,
        );
        if (falconxError) {
            console.error(falconxError);
            return res.status(500).send();
        }

    } catch (error) {
        console.error(`Server error processing request: ${error}`);
        return res.status(500).send('Internal server error.');
    }

    console.log("Request success.")
    return res.status(200).send();
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});

