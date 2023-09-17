// exec: BUY
// base: BTC 0.000123
// quote: USD 30000.123

// exec: SELL
// base: BTC 0.000123
// quote: USD 30000.123

/**
 * @typedef FalconxOrder
 * @property {string} buyOrSell
 * @property {string} baseToken
 * @property {string} quoteToken
 * @property {number} baseTokenAmount
 * @property {number} quoteTokenPrice
 */
class FalconxOrder {
    /**
     * @param {string} buyOrSell - Whether to buy or sell the base token.
     * @param {string} baseToken - The base token being bought or sold.
     * @param {string} quoteToken - The token used for payment.
     * @param {number} baseTokenAmount - The amount of the base token to buy or sell.
     * @param {number} quoteTokenPrice - The amount of the base token to buy or sell.     */
    constructor(
        buyOrSell,
        baseToken,
        quoteToken,
        baseTokenAmount,
        quoteTokenPrice
    ) {
        this.buyOrSell = buyOrSell;
        this.baseToken = baseToken;
        this.quoteToken = quoteToken;
        this.baseTokenAmount = baseTokenAmount;
        this.quoteTokenPrice = quoteTokenPrice;
    }
}

/**
 * @param {string} text - The text to parse an order from
 * @return {FalconxOrder | string} - The parsed order, or an error message.
 */
function parseOrder(text) {

    // HAS AT LEAST 3 LINES
    const lines = text.split(/\r?\n/);
    if (lines.length < 3) {
        return `Failed to split the text into 3+ lines: ${lines}`
    }

    // CAN PARSE FIRST 3 LINES
    const execMatch = lines[0].match(/^(BUY|SELL)$/);
    const baseMatch = lines[1].match(/^(\d+(?:\.\d+)?) (\w+)$/);
    const quoteMatch = lines[2].match(/^(\d+(?:\.\d+)?) (\w+)$/);
    if (!execMatch) {
        return `Failed to parse (BUY|SELL) from first line: ${lines[0]}`
    }
    if (!baseMatch) {
        return `Failed to parse the base token and amount from second line: ${lines[1]}`
    }
    if (!quoteMatch) {
        return `Failed to parse the quote token and expected price from the third line: ${lines[2]}`
    }

    // EXTRACT AND PARSE INFO
    const buyOrSell = execMatch[1];
    const baseToken = baseMatch[2];
    const quoteToken = quoteMatch[2];
    const baseTokenAmount = parseFloat(baseMatch[1]);
    const quoteTokenPrice = parseFloat(quoteMatch[1]);
    if (isNaN(baseTokenAmount)) {
        return `The parsed base token amount is not a valid number: ${baseToken[1]}`
    }
    if (isNaN(quoteTokenPrice)) {
        return `The parsed quote token price is not a valid number: ${quoteMatch[1]}`
    }

    // RETURN OBJECT
    const order = new FalconxOrder(
        buyOrSell,
        baseToken,
        quoteToken,
        baseTokenAmount,
        quoteTokenPrice
    )
    console.log("Parsed the following order: ", order);
    return order;
}

module.exports = {
    parseOrder,
    FalconxOrder
 }