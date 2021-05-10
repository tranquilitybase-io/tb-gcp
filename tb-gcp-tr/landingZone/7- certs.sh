

# #!/bin/bash -x
export HTTPS_PROXY="localhost:3128" 

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=TB Inc./CN=eagle-console.tranquilitybase-demo.io' -keyout /home/e_hsan/tranquilitybase-demo.io.key -out /home/e_hsan/tranquilitybase-demo.io.crt
openssl req -out /home/e_hsan/eagle-console.tranquilitybase-demo.io.csr -newkey rsa:2048 -nodes -keyout /home/e_hsan/eagle-console.tranquilitybase-demo.io.key -subj "/CN=eagle-console.tranquilitybase-demo.io/O=eagle-console organization"
openssl x509 -req -days 365 -CA /home/e_hsan/tranquilitybase-demo.io.crt -CAkey /home/e_hsan/tranquilitybase-demo.io.key -set_serial 0 -in /home/e_hsan/eagle-console.tranquilitybase-demo.io.csr -out /home/e_hsan/eagle-console.tranquilitybase-demo.io.crt
## create secret
kubectl create -n istio-system secret tls ec-tls-credential --key=/home/e_hsan/eagle-console.tranquilitybase-demo.io.key --cert=/home/e_hsan/eagle-console.tranquilitybase-demo.io.crt





