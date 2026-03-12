mkdir -p /opt/course/v4/3

CLIENT_ISSUER=$(openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | awk -F'Issuer: ' '/Issuer:/{print $2; exit}')
CLIENT_EKU=$(openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | awk '/Extended Key Usage/{getline; gsub(/^[[:space:]]+/, ""); print; exit}')

SERVER_ISSUER=$(openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | awk -F'Issuer: ' '/Issuer:/{print $2; exit}')
SERVER_EKU=$(openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | awk '/Extended Key Usage/{getline; gsub(/^[[:space:]]+/, ""); print; exit}')

cat <<EOF > /opt/course/v4/3/certificate-info.txt
Issuer: ${CLIENT_ISSUER}
X509v3 Extended Key Usage: ${CLIENT_EKU}
Issuer: ${SERVER_ISSUER}
X509v3 Extended Key Usage: ${SERVER_EKU}
EOF
