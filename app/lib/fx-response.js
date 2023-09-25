/**
 * @typedef {Object} FalconxResponse
 * @property {?string} buy_price
 * @property {?string} client_order_id
 * @property {?string} client_order_uuid
 * @property {?string} error
 * @property {number} fee_bps
 * @property {number} fee_usd
 * @property {string} fx_quote_id
 * @property {number} gross_fee_bps
 * @property {number} gross_fee_usd
 * @property {boolean} is_filled
 * @property {string} order_type
 * @property {string} platform
 * @property {Position} position_in
 * @property {Position} position_out
 * @property {Position} quantity_requested
 * @property {number} rebate_bps
 * @property {number} rebate_usd
 * @property {?string} sell_price
 * @property {?string} side_executed
 * @property {string} side_requested
 * @property {?number} slippage_bps
 * @property {string} status
 * @property {?string} t_execute
 * @property {?string} t_expiry
 * @property {?string} t_quote
 * @property {TokenPair} token_pair
 * @property {string} trader_email
 * @property {Array<string>} warnings
 */

/**
 * @typedef {Object} Position
 * @property {string} token
 * @property {string} value
 */

/**
 * @typedef {Object} TokenPair
 * @property {string} base_token
 * @property {string} quote_token
 */





