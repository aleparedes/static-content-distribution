# WAF -------------------------------------------
resource "aws_waf_ipset" "static_content_distribution_firewall_ips" {
  name = "static_content_distribution_firewall_ips"
  ip_set_descriptors {
    type  = "IPV4"
    value = var.alllowed_ip_range
  }
}

resource "aws_waf_rule" "StaticContentDistributionFirewallIpsRule" {
  depends_on  = [aws_waf_ipset.static_content_distribution_firewall_ips]
  name        = "StaticContentDistributionFirewallIpsRule"
  metric_name = "StaticContentDistributionFirewallIpsRule"
  predicates {
    data_id = aws_waf_ipset.static_content_distribution_firewall_ips.id
    negated = false
    type    = "IPMatch"
  }
  tags = {
    owner = var.resource_owner_email
  }
}

resource "aws_waf_web_acl" "StaticContentDistributionAccessControlList" {
  depends_on = [
    aws_waf_ipset.static_content_distribution_firewall_ips,
    aws_waf_rule.StaticContentDistributionFirewallIpsRule,
  ]
  name        = "StaticContentDistributionAccessControlList"
  metric_name = "StaticContentDistributionAccessControlList"
  default_action {
    type = "BLOCK"
  }
  rules {
    action {
      type = "ALLOW"
    }
    priority = 1
    rule_id  = aws_waf_rule.StaticContentDistributionFirewallIpsRule.id
    type     = "REGULAR"
  }
  tags = {
    owner = var.resource_owner_email
  }
}
