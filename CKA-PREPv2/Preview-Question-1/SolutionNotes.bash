KEY_PATH=$(grep -oE -- '--key-file=[^ ]+' /opt/course/p1/etcd.yaml | cut -d= -f2)
CERT_PATH=$(grep -oE -- '--cert-file=[^ ]+' /opt/course/p1/etcd.yaml | cut -d= -f2)
CLIENT_AUTH=$(grep -oE -- '--client-cert-auth=[^ ]+' /opt/course/p1/etcd.yaml | cut -d= -f2)
EXPIRATION=$(openssl x509 -noout -enddate -in "$CERT_PATH" | cut -d= -f2)

if [ "$CLIENT_AUTH" = "true" ]; then
  ENABLED="yes"
else
  ENABLED="no"
fi

cat > /opt/course/p1/etcd-info.txt <<EOF
Server private key location: ${KEY_PATH}
Server certificate expiration date: ${EXPIRATION}
Is client certificate authentication enabled: ${ENABLED}
EOF
