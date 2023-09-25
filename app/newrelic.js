'use strict';

// it's just a config file
// https://docs.newrelic.com/docs/apm/agents/nodejs-agent/installation-configuration/nodejs-agent-configuration/
// https://docs.newrelic.com/docs/apm/agents/nodejs-agent/installation-configuration/codestream-integration/

exports.config = {
    allow_all_headers: true,
    attributes: {
        exclude: [
            'request.headers.cookie',
            'request.headers.authorization',
            'request.headers.proxyAuthorization',
            'request.headers.setCookie*',
            'request.headers.x*',
            'response.headers.cookie',
            'response.headers.authorization',
            'response.headers.proxyAuthorization',
            'response.headers.setCookie*',
            'response.headers.x*'
        ]
    }
}


