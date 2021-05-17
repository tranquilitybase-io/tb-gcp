

# #!/bin/bash -x
export HTTPS_PROXY="localhost:3128" 

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=TB Inc./CN=eagle-console.tranquilitybase-demo.io' -keyout /home/e_hsan/private.landing-zone.com.key -out /home/e_hsan/private.landing-zone.com.crt
openssl req -out /home/e_hsan/eagle-console.private.landing-zone.com.csr -newkey rsa:2048 -nodes -keyout /home/e_hsan/eagle-console.private.landing-zone.com.key -subj "/CN=eagle-console.tranquilitybase-demo.io/O=eagle-console organization"
openssl x509 -req -days 365 -CA /home/e_hsan/private.landing-zone.com.crt -CAkey /home/e_hsan/private.landing-zone.com.key -set_serial 0 -in /home/e_hsan/eagle-console.private.landing-zone.com.csr -out /home/e_hsan/eagle-console.private.landing-zone.com.crt
## create secret
kubectl create -n istio-system secret tls ec-tls-credential --key=/home/e_hsan/eagle-console.private.landing-zone.com.key --cert=/home/e_hsan/eagle-console.private.landing-zone.com.crt





