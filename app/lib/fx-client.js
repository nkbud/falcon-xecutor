const {UserOrder} = require("./user-order");
const {FxEvent} = require("./fx-event");
const newrelicClient = require("newrelic");

/**
 * Interacts with Falconx to get a quote and optionally execute it
 *
 * @param {FalconxClient} falconxClient - the client to use for order execution
 * @param {UserOrder} userOrder - the parsed order information
 * @param {boolean} [doExecute=false] - If false, we will only debug-print the quote info. If false, place the order.
 * @param {number} [quotePriceTolerance=0.0001] - The maximum amount of price discrepancy we'll allow between (expected, quoted)
 * @param {boolean} [recordEvent=true] - If true, we will send this event to NewRelic via the API
 */
async function getAndExecuteQuote(
    falconxClient,
    userOrder,
    doExecute = false,
    quotePriceTolerance = 0.0001,
    recordEvent = true
) {
    if (typeof falconxClient !== 'object' || !falconxClient) {
        return `falconxClient should be an object: ${falconxClient}`;
    }
    if (typeof userOrder !== 'object' || !userOrder) {
        return `userOrder should be an object: ${userOrder}`;
    }
    if (typeof doExecute !== 'boolean') {
        return `doExecute should be a boolean: ${doExecute}`;
    }
    if (typeof quotePriceTolerance !== 'number' || isNaN(quotePriceTolerance)) {
        return `quotePriceTolerance should be a number: ${quotePriceTolerance}`;
    }
    if (typeof recordEvent !== 'boolean') {
        return `recordEvent should be a boolean: ${recordEvent}`;
    }

    try {
        const quote = await falconxClient.getQuote(
            userOrder.baseToken,
            userOrder.quoteToken,
            userOrder.baseTokenAmount,
            userOrder.buyOrSell.toLowerCase()
        );
        console.info("Received the following quote: ", quote);

        // Check if the quote is valid.
        if (!quote || typeof quote !== 'object') {
            return `Invalid quote received from Falconx: ${quote}`;
        }
        // Check if the quote contains an error message.
        if ("message" in quote) {
            return `Received an FxError: ${quote.message}`;
        }
        // Ensure the quote has the expected property.
        if (!("fx_quote_id" in quote)) {
            return `Quote does not contain the expected 'fx_quote_id' property: ${quote}`;
        }

        let executedQuote = undefined
        if (doExecute) {
            console.info("Executing the quote...");
            executedQuote = await falconxClient.executeQuote(
                quote.fx_quote_id,
                userOrder.buyOrSell
            );
            console.info("Executed the quote successfully: ", executedQuote);
        }
        if (recordEvent) {
            const fxEvent = new FxEvent(
                userOrder,
                quote,
                executedQuote
            )
            const result = newrelicClient.recordCustomEvent(fxEvent.eventType, fxEvent.toJson());
            if (result !== undefined) {
                console.error("Something went wrong on the newrelic logging")
            }
        }
    } catch (error) {
        return `Unknown error during falconx interaction: ${error.message}`;
    }

    // empty string means no error
    return "";
}


module.exports = {
    getAndExecuteQuote
};
