cat <<'EOF' > 13-httproute.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: traffic-director
  namespace: project-r500
spec:
  parentRefs:
  - name: main
  hostnames:
  - r500.gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /desktop
    backendRefs:
    - name: web-desktop
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /mobile
    backendRefs:
    - name: web-mobile
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /auto
      headers:
      - type: Exact
        name: user-agent
        value: mobile
    backendRefs:
    - name: web-mobile
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /auto
    backendRefs:
    - name: web-desktop
      port: 80
EOF

kubectl apply -f 13-httproute.yaml
