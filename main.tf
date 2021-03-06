// Setup namespace
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context_cluster = "minikube"
}

resource "kubernetes_namespace" "kstream-namespace" {
  metadata {
    name = "kstream-namespace"
  }
}

// Setup Kafka services
resource "kubernetes_service" "zookeeper" {

  metadata {
    name = "zookeeper"
    namespace = kubernetes_namespace.kstream-namespace.metadata.0.name
  }
  spec {
    selector = {
      app = "zookeeper-server"
    }
    port {
      protocol = "TCP"
      port = 2181
      target_port = 2181
    }
  }
}

resource "kubernetes_service" "broker1" {

  metadata {
    name = "broker1"
    namespace = kubernetes_namespace.kstream-namespace.metadata.0.name
  }
  spec {
    selector = {
      app = "kafka-broker1"
    }
    port {
      name = "internal"
      protocol = "TCP"
      port = 9091
      target_port = 9091
    }

    port {
      name = "external"
      protocol = "TCP"
      port = 29091
      target_port = 29091
    }
  }
}

resource "kubernetes_service" "broker2" {

  metadata {
    name = "broker2"
    namespace = kubernetes_namespace.kstream-namespace.metadata.0.name
  }
  spec {
    selector = {
      app = "kafka-broker2"
    }
    port {
      name = "internal"
      protocol = "TCP"
      port = 9092
      target_port = 9092
    }

    port {
      name = "external"
      protocol = "TCP"
      port = 29092
      target_port = 29092
    }
  }
}

resource "kubernetes_service" "broker3" {

  metadata {
    name = "broker3"
    namespace = kubernetes_namespace.kstream-namespace.metadata.0.name
  }
  spec {
    selector = {
      app = "kafka-broker3"
    }
    port {
      name = "internal"
      protocol = "TCP"
      port = 9093
      target_port = 9093
    }

    port {
      name = "external"
      protocol = "TCP"
      port = 29093
      target_port = 29093
    }
  }
}

resource "kubernetes_service" "kafka-drop" {

  metadata {
    name = "kafkadrop"
    namespace = kubernetes_namespace.kstream-namespace.metadata.0.name
  }
  spec {
    selector = {
      app = "kafka-drop"
    }
    port {
      protocol = "TCP"
      port = 9000
      target_port = 9000
    }
  }
}

// Setup Kafka deployment
resource "kubernetes_deployment" "zookeeper" {
  metadata {
    name = "zookeeper"
    namespace = kubernetes_namespace.kstream-namespace.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "zookeeper-server"
      }
    }

    template {
      metadata {
        name = "zookeeper"
        labels = {
          app = "zookeeper-server"
        }
      }
      spec {
        hostname = "zookeeper"

        container {
          name = "zookeeper"
          image = "confluentinc/cp-zookeeper:6.1.0"

          port {
            container_port = 2181
          }

          env {
            name = "ZOOKEEPER_CLIENT_PORT"
            value = 2181
          }

          env {
            name = "ZOOKEEPER_TICK_TIME"
            value = 2000
          }
        }

      }
    }
  }
}

resource "kubernetes_deployment" "kafka-broker1" {
  metadata {
    name = "kafka-broker1"
    namespace = kubernetes_namespace.kstream-namespace.metadata.0.name
    labels = {
      app = "kafka-broker1"
    }

  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kafka-broker1"
      }
    }

    template {
      metadata {
        name = "kafka-broker1"
        labels = {
          app = "kafka-broker1"
        }
      }
      spec {
        hostname = "broker1"
        container {
          name = "broker1"
          image = "confluentinc/cp-kafka:6.1.0"

          port {
            name = "internal"
            container_port = 9091
          }

          port {
            name = "external"
            container_port = 29091
          }

          env {
            name = "KAFKA_BROKER_ID"
            value = 1
          }

          env {
            name = "KAFKA_ZOOKEEPER_CONNECT"
            value = "zookeeper:2181"
          }

          env {
            name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
            value = "PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT"
          }

          env {
            name = "KAFKA_ADVERTISED_LISTENERS"
            value = "PLAINTEXT://broker1:29091,PLAINTEXT_HOST://localhost:9091"
          }

          env {
            name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS"
            value = 0
          }

          env {
            name = "KAFKA_CONFLUENT_LICENSE_TOPIC_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "KAFKA_CONFLUENT_BALANCER_TOPIC_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR"
            value = 1
          }

          env {
            name = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "CONFLUENT_METRICS_ENABLE"
            value = "false"
          }


        }

      }
    }
  }
}

resource "kubernetes_deployment" "kafka-broker2" {
  metadata {
    name = "kafka-broker2"
    namespace = kubernetes_namespace.kstream-namespace.metadata.0.name
    labels = {
      app = "kafka-broker2"
    }

  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kafka-broker2"
      }
    }

    template {
      metadata {
        name = "kafka-broker2"
        labels = {
          app = "kafka-broker2"
        }
      }
      spec {
        hostname = "broker2"
        container {
          name = "broker2"
          image = "confluentinc/cp-kafka:6.1.0"

          port {
            name = "internal"
            container_port = 9092
          }

          port {
            name = "external"
            container_port = 29092
          }

          env {
            name = "KAFKA_BROKER_ID"
            value = 2
          }

          env {
            name = "KAFKA_ZOOKEEPER_CONNECT"
            value = "zookeeper:2181"
          }

          env {
            name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
            value = "PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT"
          }

          env {
            name = "KAFKA_ADVERTISED_LISTENERS"
            value = "PLAINTEXT://broker2:29092,PLAINTEXT_HOST://localhost:9092"
          }

          env {
            name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS"
            value = 0
          }

          env {
            name = "KAFKA_CONFLUENT_LICENSE_TOPIC_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "KAFKA_CONFLUENT_BALANCER_TOPIC_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR"
            value = 1
          }

          env {
            name = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "CONFLUENT_METRICS_ENABLE"
            value = "false"
          }


        }

      }
    }
  }
}

resource "kubernetes_deployment" "kafka-broker3" {
  metadata {
    name = "kafka-broker3"
    namespace = kubernetes_namespace.kstream-namespace.metadata.0.name
    labels = {
      app = "kafka-broker3"
    }

  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kafka-broker3"
      }
    }

    template {
      metadata {
        name = "kafka-broker3"
        labels = {
          app = "kafka-broker3"
        }
      }
      spec {
        hostname = "broker3"
        container {
          name = "broker3"
          image = "confluentinc/cp-kafka:6.1.0"

          port {
            name = "internal"
            container_port = 9093
          }

          port {
            name = "external"
            container_port = 29093
          }

          env {
            name = "KAFKA_BROKER_ID"
            value = 3
          }

          env {
            name = "KAFKA_ZOOKEEPER_CONNECT"
            value = "zookeeper:2181"
          }

          env {
            name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
            value = "PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT"
          }

          env {
            name = "KAFKA_ADVERTISED_LISTENERS"
            value = "PLAINTEXT://broker3:29093,PLAINTEXT_HOST://localhost:9093"
          }

          env {
            name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS"
            value = 0
          }

          env {
            name = "KAFKA_CONFLUENT_LICENSE_TOPIC_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "KAFKA_CONFLUENT_BALANCER_TOPIC_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR"
            value = 1
          }

          env {
            name = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR"
            value = 1
          }

          env {
            name = "CONFLUENT_METRICS_ENABLE"
            value = "false"
          }


        }

      }
    }
  }
}

// Kafka Drop
resource "kubernetes_deployment" "kafkaDrop" {

  metadata {
    name = "kafka-drop"
    namespace = kubernetes_namespace.kstream-namespace.metadata.0.name
    labels = {
      app = "kafka-drop"
    }

  }
  spec {

    replicas = 1
    selector {
      match_labels = {
        app = "kafka-drop"
      }
    }
    template {
      metadata {
        name = "kafka-drop"
        labels = {
          app = "kafka-drop"
        }
      }
      spec {
        container {
          name = "kafka-drop"
          image = "obsidiandynamics/kafdrop"

          port {
            container_port = 9000
          }

          env {
            name = "KAFKA_BROKERCONNECT"
            value = "broker1:29091,broker2:29092,broker3:29093"
          }

          env {
            name = "JVM_OPTS"
            value = "-Xms16M -Xmx48M -Xss180K -XX:-TieredCompilation -XX:+UseStringDeduplication -noverify"
          }
        }
      }
    }
  }
}


//provider "helm" {
//  kubernetes {
//    config_path = "~/.kube/minikube.config"
//    config_context_cluster = "minikube"
//
//  }
//}
//resource "helm_release" "local" {
//  name = "service-name"
//  chart = "./buildchart"
//  namespace = kubernetes_namespace.kstream-namespace.metadata[0].name
//}