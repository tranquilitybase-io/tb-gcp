resource "null_resource" "dependency_resource"{
  triggers = {
    trigger_dependency = "${var.dependency_var}"
  }
}

resource "kubernetes_namespace" "istio_system" {
  "metadata" {
    name = "istio-system"
  }
  depends_on = ["null_resource.dependency_resource"]
}

resource "kubernetes_cluster_role_binding" "helm_binding" {
  "metadata" {
    name = "istio-helm-binding"
  }
  "role_ref" {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  "subject" {
    kind = "ServiceAccount"
    name = "default"
    namespace = "kube-system"
  }
  depends_on = ["kubernetes_namespace.istio_system"]
}

resource "null_resource" "helm_init" {
  triggers = {
    "after" = "${kubernetes_cluster_role_binding.helm_binding.id}"
  }
  provisioner "local-exec" {
    command = "export KUBECONFIG=${var.kubernetes_config_path} && helm init"
  }
}

# Waiting for tillers creation
resource "null_resource" "sleep_before_istio_init" {
  triggers = {
    "after" = "${kubernetes_cluster_role_binding.helm_binding.0.id}"
  }
  provisioner "local-exec" {
    command = "sleep 120"
  }
  depends_on = ["null_resource.helm_init"]
}

resource "helm_release" "istio_init" {
  repository = "${data.helm_repository.istio.name}"
  chart = "istio-init"
  name = "istio-init"
  namespace = "${kubernetes_namespace.istio_system.metadata.0.name}"
  wait = true
  depends_on = ["kubernetes_cluster_role_binding.helm_binding", "null_resource.helm_init", "null_resource.sleep_before_istio_init"]
}

# Waiting for syncing CRDs
resource "null_resource" "sleep_before_istio" {
  triggers = {
    "after" = "${helm_release.istio_init.0.id}"
  }
  provisioner "local-exec" {
    command = "sleep 20"
  }
}

resource "helm_release" "istio" {
  repository = "${data.helm_repository.istio.name}"
  chart = "istio"
  name = "istio"
  namespace = "${kubernetes_namespace.istio_system.metadata.0.name}"
  values = [
    "${file("${path.module}/files/values-istio-demo.yaml")}"
  ]
  wait = false

  depends_on = ["null_resource.sleep_before_istio"]
}

resource "null_resource" "get_endpoint" {
  count = "${var.endpoint_file == "" ? 0 : 1}"
  provisioner "local-exec" {
    command = "echo -n 'http://' > ${var.endpoint_file} && kubectl --kubeconfig=${var.kubernetes_config_path} get svc istio-ingressgateway -n ${kubernetes_namespace.istio_system.metadata.0.name} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' >> ${var.endpoint_file}"
  }
  depends_on = ["helm_release.istio"]
}
