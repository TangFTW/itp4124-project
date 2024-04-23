
resource "kubernetes_deployment" "web-nginx" {
  metadata {
    name = "web-nginx-deployment"
    labels = {
      app = "web"
    }
  }
 
  spec {
    replicas = 5
 
    selector {
      match_labels = {
        app = "web"
      }
    }
 
    template {
      metadata {
        labels = {
          app = "web"
        }
      }
 
      spec {
        container {
          image = "public.ecr.aws/p2m9o5b7/foraz220001935:v1"
          name  = "web"
          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web_loadbalancer" {
    metadata {
        name = "webloadbalancer"
        labels = {
            app = "web"
        }
    }
    
    spec {
        selector = {
            app = "web"
        }
        
        
        port {
            name="http"
            protocol = "TCP"
            port = "80"
            target_port = "5000"
        }
        
        type = "LoadBalancer"
    }
}
