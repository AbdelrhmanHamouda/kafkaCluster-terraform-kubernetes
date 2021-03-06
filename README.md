# kafka cluster with terraform and kubernetes

A 3 broker Kafka cluster with Kafka drop setup using terraform and kubernetes resource.

# Spinup the cluster

```shell
terraform apply
```

Running `kubectl get pods` will return a list of 5 pods (a zookeeper pod, 3 kafka broke pods and kafkaDrop pod).

Each container has its own service.

# Teardown

```shell
terraform destroy
```
