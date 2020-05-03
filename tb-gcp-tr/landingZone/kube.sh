echo '# Copyright 2019 The Tranquility Base Authors
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##
apiVersion: v1
kind: Namespace
metadata:
  name: vault
  labels:
    name: vault
---
apiVersion: v1
kind: Service
metadata:
  name: vault
  namespace: vault
  annotations:
    cloud.google.com/load-balancer-type: "Internal"
  labels:
    app: vault
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  selector:
    app: vault
  ports:
  - name: vault-port
    port: 443
    targetPort: 8200
    protocol: TCP

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: vault
  namespace: vault
  labels:
    app: vault
spec:
  serviceName: vault
  replicas: 3
  selector:
    matchLabels:
      app: vault
  template:
    metadata:
      labels:
        app: vault
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 60
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values: ["vault"]
              topologyKey: kubernetes.io/hostname
      terminationGracePeriodSeconds: 10
      containers:
      - name: vault-init
        image: "sethvargo/vault-init:1.0.0"
        imagePullPolicy: IfNotPresent
        resources:
          requests:
            cpu: "100m"
            memory: "64Mi"
        env:
        - name: GCS_BUCKET_NAME
          value: "shared-secrets-ce6630ae-vault-storage"
        - name: KMS_KEY_ID
          value: "projects/shared-secrets-ce6630ae/locations/europe-west2/keyRings/vault/cryptoKeys/vault-init"
        - name: VAULT_ADDR
          value: "http://127.0.0.1:8200"
        - name: VAULT_SECRET_SHARES
          value: "1"
        - name: VAULT_SECRET_THRESHOLD
          value: "1"
      - name: vault
        image: "vault:1.0.1"
        imagePullPolicy: IfNotPresent
        args: ["server"]
        securityContext:
          capabilities:
            add: ["IPC_LOCK"]
        ports:
        - containerPort: 8200
          name: vault-port
          protocol: TCP
        - containerPort: 8201
          name: cluster-port
          protocol: TCP
        resources:
          requests:
            cpu: "500m"
            memory: "256Mi"
        volumeMounts:
        - name: vault-tls
          mountPath: /etc/vault/tls
        env:
        - name: VAULT_ADDR
          value: "http://127.0.0.1:8200"
        - name: POD_IP_ADDR
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: VAULT_LOCAL_CONFIG
          value: |
            api_addr     = "https://35.246.12.116"
            cluster_addr = "https://$(POD_IP_ADDR):8201"

            log_level = "warn"

            ui = true

            seal "gcpckms" {
              project    = "shared-secrets-ce6630ae"
              region     = "europe-west2"
              key_ring   = "vault"
              crypto_key = "vault-init"
            }

            storage "gcs" {
              bucket     = "shared-secrets-ce6630ae-vault-storage"
              ha_enabled = "true"
            }

            listener "tcp" {
              address     = "127.0.0.1:8200"
              tls_disable = "true"
            }

            listener "tcp" {
              address       = "$(POD_IP_ADDR):8200"
              tls_cert_file = "/etc/vault/tls/vault.crt"
              tls_key_file  = "/etc/vault/tls/vault.key"

              tls_disable_client_certs = true
            }
        readinessProbe:
          httpGet:
            path: /v1/sys/health?standbyok=true
            port: 8200
            scheme: HTTPS
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: vault-tls
        secret:
          secretName: vault-tls
' | kubectl apply --context="gke_shared-secrets-ce6630ae_europe-west2_gke-sec" -f -