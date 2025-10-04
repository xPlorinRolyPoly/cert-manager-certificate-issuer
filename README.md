# Cert-Manager Certificates Helm Chart

This Helm chart deploys cert-manager certificates and cluster issuers based on the k8s manifests.

## Prerequisites

- Kubernetes cluster with cert-manager installed
- Helm 3.x

## Installation

### Basic Installation with Component Pattern

The recommended approach is to use release names following the pattern `${component}-certificate-issuer`:

```bash
# For backend component
helm install backend-certificate-issuer ./helm-chart \
  --set component=backend \
  --set certificate.commonName=backend.example.com \
  --set certificate.dnsNames[0]=backend.example.com \
  --set clusterIssuer.acme.serverUrl=https://acme-server.example.com \
  --set clusterIssuer.acme.caBundle=LS0tLS1CRUdJTi...

# For frontend component  
helm install frontend-certificate-issuer ./helm-chart \
  --set component=frontend \
  --set certificate.commonName=frontend.example.com \
  --set certificate.dnsNames[0]=frontend.example.com

# For api component
helm install api-certificate-issuer ./helm-chart \
  --set component=api \
  --set certificate.commonName=api.example.com \
  --set certificate.dnsNames[0]=api.example.com
```

### Installation with Custom Values

```bash
helm install backend-certificate-issuer ./helm-chart \
  --set component=backend \
  --set certificate.commonName=backend.example.com \
  --set certificate.dnsNames[0]=backend.example.com \
  --set certificate.dnsNames[1]=api.backend.example.com \
  --set clusterIssuer.acme.serverUrl=https://acme-server.example.com \
  --set clusterIssuer.acme.caBundle=LS0tLS1CRUdJTi...
```

### Installation with Values File

Create a custom values file for your component:

**backend-values.yaml:**
```yaml
component: "backend"
namespace: "istio-system"

certificate:
  commonName: "backend.example.com"
  dnsNames:
    - "backend.example.com"
    - "api.backend.example.com"

clusterIssuer:
  acme:
    serverUrl: "https://acme-server.example.com"
    caBundle: "LS0tLS1CRUdJTi..."
    solvers:
      - http01:
          ingress:
            class: nginx
      - dns01:
          cloudflare:
            email: user@example.com
            apiKeySecretRef:
              name: cloudflare-api-key-secret
              key: api-key
```

Then install:

```bash
helm install backend-certificate-issuer ./helm-chart -f backend-values.yaml
```

## Configuration

The following table lists the configurable parameters and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `component` | Component name used in resource names | `default` |
| `namespace` | Namespace for the certificate | `istio-system` |
| `certificate.duration` | Certificate duration | `8760h` |
| `certificate.renewBefore` | Renew before expiry | `720h` |
| `certificate.commonName` | Certificate common name | `""` |
| `certificate.dnsNames` | List of DNS names | `[]` |
| `certificate.subject.organizations` | Organizations in certificate subject | `["ABC GmbH"]` |
| `certificate.subject.organizationalUnits` | Organizational units | `["IS"]` |
| `certificate.subject.countries` | Countries | `["DE"]` |
| `certificate.subject.provinces` | Provinces | `["Bayern"]` |
| `certificate.subject.localities` | Localities | `["Muenchen"]` |
| `clusterIssuer.acme.serverUrl` | ACME server URL | `""` |
| `clusterIssuer.acme.caBundle` | Base64 encoded CA bundle | `""` |
| `clusterIssuer.acme.email` | Email for ACME registration | `DL-ABC@xyz.de` |
| `clusterIssuer.acme.solvers` | List of ACME challenge solvers | `[]` |

### ACME Solvers Configuration

The `clusterIssuer.acme.solvers` parameter allows you to configure how cert-manager will solve ACME challenges for certificate validation. This is an optional parameter - if not specified or left as an empty list, the ClusterIssuer will be created without specific solver configuration.

Common solver types include:

**HTTP-01 Challenge with Ingress:**
```yaml
clusterIssuer:
  acme:
    solvers:
      - http01:
          ingress:
            class: nginx
```

**DNS-01 Challenge with CloudFlare:**
```yaml
clusterIssuer:
  acme:
    solvers:
      - dns01:
          cloudflare:
            email: user@example.com
            apiKeySecretRef:
              name: cloudflare-api-key-secret
              key: api-key
```

**Multiple Solvers with Selectors:**
```yaml
clusterIssuer:
  acme:
    solvers:
      - selector:
          dnsNames:
            - "*.example.com"
        dns01:
          cloudflare:
            email: user@example.com
            apiKeySecretRef:
              name: cloudflare-api-key-secret
              key: api-key
      - selector:
          dnsNames:
            - "example.com"
        http01:
          ingress:
            class: nginx
```

For more information about ACME solvers, refer to the [cert-manager documentation](https://cert-manager.io/docs/configuration/acme/).

## Upgrading

```bash
helm upgrade backend-certificate-issuer ./helm-chart
```

## Uninstalling

```bash
helm uninstall backend-certificate-issuer
```

## Verification

After installation, verify the resources:

```bash
# Check the certificate
kubectl get certificate -n <namespace>

# Check the cluster issuer
kubectl get clusterissuer

# Check the certificate status
kubectl describe certificate <component>-certificate -n <namespace>
```

## Testing

This Helm chart includes comprehensive tests to verify that the cert-manager setup is working correctly.

### Running Tests

After installing the chart, run the tests:

```bash
# Run all tests for backend component
helm test backend-certificate-issuer

# Run tests with logs
helm test backend-certificate-issuer --logs

# Run specific test
kubectl logs backend-certificate-issuer-test-clusterissuer
kubectl logs backend-certificate-issuer-test-certificate  
kubectl logs backend-certificate-issuer-test-integration
```

### Test Types

1. **ClusterIssuer Test** (`test-clusterissuer.yaml`)
   - Verifies that the ClusterIssuer is created and reaches "Ready" status
   - Checks ACME server configuration
   - Timeout: 5 minutes (configurable)

2. **Certificate Test** (`test-certificate.yaml`)
   - Verifies that the Certificate is issued successfully
   - Checks that the TLS secret is created with proper keys
   - Validates certificate expiry dates
   - Timeout: 10 minutes (configurable)

3. **Integration Test** (`test-integration.yaml`)
   - Comprehensive test covering both ClusterIssuer and Certificate
   - Validates configuration consistency
   - Checks DNS names and renewal settings
   - Provides detailed summary

### Test Configuration

You can configure test timeouts in values.yaml:

```yaml
tests:
  enabled: true
  clusterIssuerTimeout: 300  # 5 minutes
  certificateTimeout: 600    # 10 minutes
```

### Test Cleanup

Tests are automatically cleaned up after successful completion. Failed test pods are kept for debugging:

```bash
# Manual cleanup if needed
kubectl delete pod -l "helm.sh/hook=test"
```
