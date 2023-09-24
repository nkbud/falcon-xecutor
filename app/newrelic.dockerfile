FROM newrelic/infrastructure:1.47.1
# https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/linux-installation/container-infrastructure-monitoring/

COPY newrelic.yml /etc/newrelic-infra.yml
COPY newrelic.logging.yml /etc/newrelic-infra/logging.d/logging.yml

RUN apk --no-cache add wget cmake g++ make
RUN wget -O /tmp/newrelic-fluent-bit-output.tar.gz https://github.com/newrelic/newrelic-fluent-bit-output/archive/refs/tags/v1.17.3.tar.gz \
    && tar -xzvf /tmp/newrelic-fluent-bit-output.tar.gz -C /tmp/ \
    && cd /tmp/newrelic-fluent-bit-output-1.17.3/ \
    && cmake . && make && make install \
    && rm -rf /tmp/newrelic-fluent-bit-output-1.17.3/ /tmp/newrelic-fluent-bit-output.tar.gz
