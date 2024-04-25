data "aws_route53_zone" "selected" {
  name         = "gnhengineering.com"
}


resource "aws_route53_record" "aws" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = "60"
  records = [kubernetes_service.web_loadbalancer.status[0].load_balancer[0].ingress[0].hostname]
  
  weighted_routing_policy {
    weight = 1
  }
  set_identifier = "aws"
}

resource "aws_route53_record" "azureip" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "azure.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "60"
  records = [kubernetes_service.web_loadbalancer-az.status[0].load_balancer[0].ingress[0].ip]
  
}

resource "aws_route53_record" "azure" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_route53_record.azureip.name]
  
  weighted_routing_policy {
    weight = 1
  }
  set_identifier = "azure"
}
