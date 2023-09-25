/**
 * Interacts with Falconx to get a quote and optionally execute it
 *
 * @param {FalconxClient} falconxClient - the client to use for order execution
 * @param {"BUY" | "SELL"} buyOrSell - The side of the trade (either "buy" or "sell")
 * @param {string} baseToken - The ID of the base token.
 * @param {string} quoteToken - The ID of the quote token.
 * @param {number} baseTokenAmount - The amount of base token to execute.
 * @param {number} quoteTokenPrice - The price of the quote token that we're aiming for.
 * @param {boolean} [doExecute=false] - If false, we will only debug-print the quote info. If false, place the order.
 * @param {number} [quotePriceTolerance=0.0001] - The maximum amount of price discrepancy we'll allow between (expected, quoted)
 * @param {boolean} [recordMetrics=false] - If true, we will send events / metrics to NewRelic via the API
 */
async function getAndExecuteQuote(
    falconxClient,
    buyOrSell,
    baseToken,
    quoteToken,
    baseTokenAmount,
    quoteTokenPrice,
    doExecute = false,
    quotePriceTolerance = 0.0001,
    recordMetrics = false
) {
  if (typeof falconxClient !== 'object' || !falconxClient) {
    return `falconxClient should be an object: ${falconxClient}`;
  }
  if (buyOrSell !== 'BUY' && buyOrSell !== 'SELL') {
    return `buyOrSell should be either BUY or SELL: ${buyOrSell}`;
  }
  if (typeof baseToken !== 'string') {
    return `baseToken should be a string: ${baseToken}`;
  }
  if (typeof quoteToken !== 'string') {
    return `quoteToken should be a string: ${quoteToken}`;
  }
  if (typeof baseTokenAmount !== 'number' || isNaN(baseTokenAmount)) {
    return `baseTokenAmount should be a number: ${baseTokenAmount}`;
  }
  if (typeof quoteTokenPrice !== 'number' || isNaN(quoteTokenPrice)) {
    return `quoteTokenPrice should be a number: ${quoteTokenPrice}`;
  }
  if (typeof doExecute !== 'boolean') {
    return `doExecute should be a boolean: ${doExecute}`;
  }
  if (typeof quotePriceTolerance !== 'number' || isNaN(quotePriceTolerance)) {
    return `quotePriceTolerance should be a number: ${quotePriceTolerance}`;
  }

  try {
    const quote = await falconxClient.getQuote(
        baseToken,
        quoteToken,
        baseTokenAmount,
        buyOrSell.toLowerCase()
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
    // If the caller opts out of execution, log and return.
    if (!doExecute) {
      console.info("Function caller opted-out of order execution.")
      return "";
    }

    // Execute the order.
    const executedQuote = await falconxClient.executeQuote(
        quote.fx_quote_id,
        buyOrSell
    );
    console.info("Executed the quote successfully: ", executedQuote);

  } catch (error) {
    return `Unknown error during falconx interaction: ${error.message}`;
  }

  // empty string means no error
  return "";
}


module.exports = {
  getAndExecuteQuote
};
