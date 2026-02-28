CERT_PATH=$(cat /opt/course/14/cert-path)

openssl x509 -noout -enddate -in "$CERT_PATH" | cut -d= -f2 > /opt/course/14/expiration

kubeadm certs check-expiration | grep apiserver

# Compare manually with:
# cat /opt/course/14/kubeadm-check-expiration.txt

echo "kubeadm certs renew apiserver" > /opt/course/14/kubeadm-renew-certs.sh
