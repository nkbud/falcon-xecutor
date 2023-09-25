/**
 * @typedef {Object} FalconxEvent
 * @property {string} eventType - The type of event.
 * @property {string} baseToken - The base token for the order.
 * @property {string} quoteToken - The quote token for the order.
 * @property {number} baseAmount - The amount of the base token.
 * @property {number} quotePriceExpected - The expected price of the quote token.
 * @property {number} quoteAmountExpected - The expected amount of the quote token.
 * @property {string} quoteId - The ID of the quote.
 * @property {string} traderEmail - The email of the trader.
 * @property {string} quoteDateUTC - The UTC date of the quote.
 * @property {string} quoteTimeUTC - The UTC time of the quote.
 * @property {string} quoteStatus - The status of the quote.
 * @property {string} quoteError - Any error associated with the quote.
 * @property {number} quotePriceReceived - The received price of the quote.
 * @property {number} quoteAmountReceived - The received amount of the quote.
 * @property {number} quotePriceError - The error in the quote price.
 * @property {number} quoteAmountError - The error in the quote amount.
 * @property {number} quotePriceAbsError - The absolute error in the quote price.
 * @property {number} quoteAmountAbsError - The absolute error in the quote amount.
 * @property {number} quoteAmountGain - The gain in the quote amount.
 * @property {number} quoteAmountLoss - The loss in the quote amount.
 * @property {number} grossFeeBps - The gross fee in basis points.
 * @property {number} grossFeeUsd - The gross fee in USD.
 * @property {number} netFeeBps - The net fee in basis points.
 * @property {number} netFeeUsd - The net fee in USD.
 * @property {string} executeStatus - The status of the execution.
 * @property {boolean} executeFilled - Whether the execution was filled.
 * @property {string} executeError - Any error associated with the execution.
 * @property {number} executeTimeDiffMs - The time difference between execution and quote in milliseconds.
 * @property {number} executeSlippageBps - The slippage in basis points during execution.
 * @property {number} executeSlippageUsd - The slippage in USD during execution.
 */
class FalconxEvent {
    /**
     * @param {FalconxOrder} falconxOrder
     * @param {FalconxResponse} fxQuote
     * @param {FalconxResponse} fxExecute
     */
    constructor(
        falconxOrder,
        fxQuote,
        fxExecute
    ) {
        this.eventType = `falcon-xecutor.${falconxOrder.buyOrSell}`
        //
        // client's request
        //
        this.baseToken = falconxOrder.baseToken
        this.quoteToken = falconxOrder.quoteToken
        this.baseAmount = falconxOrder.baseTokenAmount
        this.quotePriceExpected = falconxOrder.quoteTokenPrice
        this.quoteAmountExpected = this.quotePriceExpected * this.baseAmount
        //
        // fxQuote
        //
        this.quoteId = fxQuote.fx_quote_id
        this.traderEmail = fxQuote.trader_email
        this.quoteDateUTC = fxQuote.t_quote.split('T')[0]
        this.quoteTimeUTC = fxQuote.t_quote.split('T')[1].split('+')[0]
        this.quoteStatus = fxQuote.status
        this.quoteError = fxQuote.error === null ? "" : fxQuote.error
        //
        // error = (quote - request)
        //
        switch (falconxOrder.buyOrSell) {
            case "BUY":
                this.quotePriceReceived = fxQuote.buy_price
                this.quoteAmountReceived = fxQuote.position_out.value
                break
            case "SELL":
                this.quotePriceReceived = fxQuote.sell_price
                this.quoteAmountReceived = fxQuote.position_in.value
                break
        }
        this.quotePriceError = this.quotePriceReceived - this.quotePriceExpected
        this.quoteAmountError = this.quoteAmountReceived - this.quoteAmountExpected
        this.quotePriceAbsError = Math.abs(this.quotePriceError)
        this.quoteAmountAbsError = Math.abs(this.quoteAmountError)
        //
        // is the error a gain or loss?
        //
        this.quoteAmountGain = 0
        this.quoteAmountLoss = 0
        switch (falconxOrder.buyOrSell) {
            case "BUY":
                if (this.quoteAmountError > 0) {
                    this.quoteAmountLoss = this.quoteAmountError
                } else {
                    this.quoteAmountGain = this.quoteAmountError
                }
                break
            case "SELL":
                if (this.quoteAmountError > 0) {
                    this.quoteAmountGain = this.quoteAmountError
                } else {
                    this.quoteAmountLoss = this.quoteAmountError
                }
                break
        }
        //
        // any fees?
        //
        this.grossFeeBps = fxQuote.gross_fee_bps
        this.grossFeeUsd = fxQuote.gross_fee_usd
        this.netFeeBps = fxQuote.fee_bps
        this.netFeeUsd = fxQuote.fee_usd
        //
        // fxExecute
        //
        this.executeFilled = fxExecute.is_filled
        this.executeStatus = fxExecute.status === null ? "" : fxExecute.status
        this.executeError = fxExecute.error === null ? "" : fxExecute.error
        //
        // (execute - quote) time difference
        //
        this.executeTimeDiffMs = 0
        try {
            const executeTime = new Date(fxExecute.t_execute)
            const quoteTime = new Date(fxQuote.t_quote)
            this.executeTimeDiffMs = new Date(fxExecute.t_execute) - new Date(fxQuote.t_quote);
        } catch (e) {}
        //
        // any slippage?
        //
        this.executeSlippageBps = fxExecute.slippage_bps === null ? 0 : fxExecute.slippage_bps
        this.executeSlippageUsd = this.quoteAmountReceived * (this.executeSlippageBps / 10000)
    }

    /** @returns FalconxEvent */
    toJson() {
        return {
            "eventType": this.eventType,
            "baseToken": this.baseToken,
            "quoteToken": this.quoteToken,
            "baseAmount": this.baseAmount,
            "quotePriceExpected": this.quotePriceExpected,
            "quoteAmountExpected": this.quoteAmountExpected,
            "quoteId": this.quoteId,
            "traderEmail": this.traderEmail,
            "quoteDateUTC": this.quoteDateUTC,
            "quoteTimeUTC": this.quoteTimeUTC,
            "quoteStatus": this.quoteStatus,
            "quoteError": this.quoteError,
            "quotePriceReceived": this.quotePriceReceived,
            "quoteAmountReceived": this.quoteAmountReceived,
            "quotePriceError": this.quotePriceError,
            "quoteAmountError": this.quoteAmountError,
            "quotePriceAbsError": this.quotePriceAbsError,
            "quoteAmountAbsError": this.quoteAmountAbsError,
            "quoteAmountGain": this.quoteAmountGain,
            "quoteAmountLoss": this.quoteAmountLoss,
            "grossFeeBps": this.grossFeeBps,
            "grossFeeUsd": this.grossFeeUsd,
            "netFeeBps": this.netFeeBps,
            "netFeeUsd": this.netFeeUsd,
            "executeStatus": this.executeStatus,
            "executeFilled": this.executeFilled,
            "executeError": this.executeError,
            "executeTimeDiffMs": this.executeTimeDiffMs,
            "executeSlippageBps": this.executeSlippageBps,
            "executeSlippageUsd": this.executeSlippageUsd
        };
    }
}

