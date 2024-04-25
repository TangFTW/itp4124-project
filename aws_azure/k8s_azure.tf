resource "kubernetes_deployment" "web-nginx-az" {
  provider = kubernetes.azure
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
          image = "public.ecr.aws/p2m9o5b7/foraz220001935:azurewebv1"
          name  = "web"
          port {
            container_port = 5000
          }
          env {
            name = "DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.dbsecret_az.metadata[0].name
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



resource "kubernetes_service" "web_loadbalancer-az" {
    provider = kubernetes.azure
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


resource "kubernetes_secret" "dbsecret_az" {
  provider = kubernetes.azure
  metadata {
    name = "dbsecret"
  }
  
  data = {
    password = "1016385336qQ"
  }
}
