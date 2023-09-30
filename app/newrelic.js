'use strict';

// it's just a config file
// https://docs.newrelic.com/docs/apm/agents/nodejs-agent/installation-configuration/nodejs-agent-configuration/
// https://docs.newrelic.com/docs/apm/agents/nodejs-agent/installation-configuration/codestream-integration/

// https://docs.newrelic.com/docs/data-apis/ingest-apis/event-api/introduction-event-api/
// https://docs.newrelic.com/docs/data-apis/ingest-apis/metric-api/introduction-metric-api/

// https://newrelic.github.io/node-newrelic/API.html#recordLogEvent
// https://newrelic.github.io/node-newrelic/API.html#recordMetric
// https://docs.newrelic.com/docs/apm/agents/nodejs-agent/api-guides/guide-using-nodejs-agent-api/

exports.config = {
    // app_name: 'falcon-xecutor-local',
    // license_key: 'use this to test locally',
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
