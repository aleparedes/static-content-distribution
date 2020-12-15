# WAF -------------------------------------------
resource "aws_waf_ipset" "firewall_ips" {
  name = "firewall_ips"
  ip_set_descriptors {
    type  = "IPV4"
    value = var.alllowed_ip_range
  }
}

resource "aws_waf_rule" "FirewallIpsRule" {
  depends_on  = [aws_waf_ipset.firewall_ips]
  name        = "FirewallIpsRule"
  metric_name = "FirewallIpsRule"
  predicates {
    data_id = aws_waf_ipset.firewall_ips.id
    negated = false
    type    = "IPMatch"
  }
  tags = {
    owner = var.resource_owner_email
  }
}

resource "aws_waf_web_acl" "AccessControlList" {
  depends_on = [
    aws_waf_ipset.firewall_ips,
    aws_waf_rule.FirewallIpsRule,
  ]
  name        = "AccessControlList"
  metric_name = "AccessControlList"
  default_action {
    type = "BLOCK"
  }
  rules {
    action {
      type = "ALLOW"
    }
    priority = 1
    rule_id  = aws_waf_rule.FirewallIpsRule.id
    type     = "REGULAR"
  }
  tags = {
    owner = var.resource_owner_email
  }
}
