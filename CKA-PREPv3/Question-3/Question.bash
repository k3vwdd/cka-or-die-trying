Question 3 | Kubelet client/server cert info

Node node01 has been added to the cluster using kubeadm and TLS bootstrapping.

Your task is to find the Issuer and Extended Key Usage values on node01 for:
- Kubelet Client Certificate (used for outgoing connections to kube-apiserver)
- Kubelet Server Certificate (used for incoming connections from kube-apiserver)

Write the information into:
/opt/course/3/certificate-info.txt

Expected workflow:
1. On node01, inspect the kubelet PKI location.
2. Extract the Issuer and Extended Key Usage for the kubelet client certificate.
3. Extract the Issuer and Extended Key Usage for the kubelet server certificate.
4. Write the required values into /opt/course/3/certificate-info.txt.
5. Verify the file exists and contains the required information.

Relevant certificate paths to inspect on node01:
- /var/lib/kubelet/pki/kubelet-client-current.pem
- /var/lib/kubelet/pki/kubelet.crt

The output file should contain four lines in this order:
Issuer: <client-cert-issuer>
X509v3 Extended Key Usage: <client-cert-eku>
Issuer: <server-cert-issuer>
X509v3 Extended Key Usage: <server-cert-eku>
