resource "kubernetes_deployment" "web-nginx" {
  provider = kubernetes.aws
  metadata {
    name = "web-nginx-deployment"
    labels = {
      app = "web"
    }
  }
 
  spec {
    replicas = 30
 
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
          image = "601036370972.dkr.ecr.us-east-1.amazonaws.com/ea2:dywebv3"
          name  = "web"
          port {
            container_port = 5000
          }
          env {
            name = "DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.dbsecret.metadata[0].name
                key = "password"
              }
            }
          }
          env {
            name = "DATABASE_ENDPOINT"
            value = aws_db_instance.ea2_rds.address
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web_loadbalancer" {
    provider = kubernetes.aws
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

resource "kubernetes_secret" "dbsecret" {
  provider = kubernetes.aws
  metadata {
    name = "dbsecret"
  }
  
  data = {
    password = "1016385336qQ"
  }
}