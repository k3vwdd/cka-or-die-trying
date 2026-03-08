# Check PKI directory for kubelet certs on node01:
ls -la /var/lib/kubelet/pki
# Get Issuer and EKU for client cert:
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep Issuer
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep "Extended Key Usage" -A1
# Get Issuer and EKU for server cert:
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep Issuer
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep "Extended Key Usage" -A1
# Write required fields to /opt/course/3/certificate-info.txt as:
# Issuer: <client-cert-issuer>
# X509v3 Extended Key Usage: <client-cert-eku>
# Issuer: <server-cert-issuer>
# X509v3 Extended Key Usage: <server-cert-eku>
