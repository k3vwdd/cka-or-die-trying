# Inspect kubelet PKI files on node01
ls -la /var/lib/kubelet/pki

# Extract issuer for the kubelet client certificate
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep Issuer

# Extract extended key usage for the kubelet client certificate
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem | grep "Extended Key Usage" -A1

# Extract issuer for the kubelet server certificate
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep Issuer

# Extract extended key usage for the kubelet server certificate
openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt | grep "Extended Key Usage" -A1

# Write the collected values into the required file
cat <<'EOF' > /opt/course/3/certificate-info.txt
Issuer: <client-cert-issuer>
X509v3 Extended Key Usage: <client-cert-eku>
Issuer: <server-cert-issuer>
X509v3 Extended Key Usage: <server-cert-eku>
EOF

# Replace the placeholders with the actual values extracted above
# Example EKU values may look like:
# TLS Web Client Authentication
# TLS Web Server Authentication

# Verify the output file
cat /opt/course/3/certificate-info.txt
