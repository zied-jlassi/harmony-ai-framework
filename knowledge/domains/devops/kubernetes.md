---
name: "kubernetes"
description: "Kubernetes deployment patterns"
version: "1.0"
auto_invoke: true
activate_when:
  file_matches:
    - "k8s/**"
    - "*.yaml"
    - "*.yml"
  keywords:
    - "kubernetes"
    - "k8s"
    - "deployment"
    - "hpa"
    - "ingress"
agents:
  - devops
  - architect
---

# Kubernetes Patterns

> Patterns K8s pour applications conteneurisées

## Deployment Template

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {app-name}
  namespace: {namespace}
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    spec:
      containers:
        - name: {app-name}
          image: {registry}/{image}:{tag}
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          readinessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 5
          securityContext:
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 1000
```

## HPA (Horizontal Pod Autoscaler)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {app-name}
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

## Network Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {app-name}-policy
spec:
  podSelector:
    matchLabels:
      app: {app-name}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: ingress-nginx
      ports:
        - protocol: TCP
          port: 3000
```

## Ingress with TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  tls:
    - hosts:
        - {domain}
      secretName: {app-name}-tls
  rules:
    - host: {domain}
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: {app-name}-backend
                port:
                  number: 3000
```

## Security Checklist

- [ ] Pod runs as non-root
- [ ] ReadOnlyRootFilesystem
- [ ] Resource limits defined
- [ ] NetworkPolicy configured
- [ ] RBAC with least privilege
- [ ] Secrets from External Secrets

## Deployment Strategies

| Strategy | Use Case |
|----------|----------|
| RollingUpdate | Default, zero-downtime |
| Blue-Green | Instant rollback |
| Canary | Progressive rollout |

## References

- Kustomize structure: `k8s/base/` + `k8s/overlays/`
- Secrets: External Secrets Operator
