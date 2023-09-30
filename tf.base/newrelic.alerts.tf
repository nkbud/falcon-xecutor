#
# gonna explore this
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/guides/provider_configuration
#

#
#data "newrelic_entity" "app" {
#  name = "my-app"
#  type = "APPLICATION"
#  domain = "APM"
#}
#
#resource "newrelic_alert_policy" "foo" {
#  name = "foo"
#}
#
#resource "newrelic_alert_condition" "foo" {
#  policy_id = newrelic_alert_policy.foo.id
#
#  name        = "foo"
#  type        = "apm_app_metric"
#  entities    = [data.newrelic_entity.app.application_id]
#  metric      = "apdex"
#  runbook_url = "https://www.example.com"
#  condition_scope = "application"
#
#  term {
#    duration      = 5
#    operator      = "below"
#    priority      = "critical"
#    threshold     = "0.75"
#    time_function = "all"
#  }
#}
