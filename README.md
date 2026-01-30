# Estafen Helm Chart - Intermediate Level

Helm chart simplificado para aprender Kubernetes con una aplicación Node.js de ejemplo.

## 🎯 **Características**

- ✅ **Aplicación Node.js simple** con endpoints de health
- ✅ **Deployment** con 2 réplicas y RollingUpdate
- ✅ **Service LoadBalancer** para acceso externo
- ✅ **HPA** (auto-scaling de pods)
- ✅ **RBAC** básico
- ✅ **Dockerfile** incluido
- ✅ **AWS EKS ready** - Ver [EKS-DEPLOYMENT.md](EKS-DEPLOYMENT.md)
- ✅ **AWS Secrets Manager** - Ver [SECRETS-GUIDE.md](SECRETS-GUIDE.md)

## 📋 **Prerequisitos**

- Kubernetes 1.28+ (EKS, Minikube, Kind, etc.)
- Helm 3.10+
- Docker (para construir la imagen)
- kubectl configurado

## 🚀 **Inicio Rápido**

### 1. Construir la Imagen Docker

```bash
# Construir la imagen
docker build -t estafen/api:1.0.0 .

# Probar localmente
docker run -p 8080:8080 estafen/api:1.0.0

# Verificar
curl http://localhost:8080/health
curl http://localhost:8080/api
```

### 2. Subir la Imagen a un Registry

**Opción A: Docker Hub**
```bash
docker tag estafen/api:1.0.0 tu-usuario/estafen-api:1.0.0
docker push tu-usuario/estafen-api:1.0.0
```

**Opción B: AWS ECR**
```bash
# Crear repositorio
aws ecr create-repository --repository-name estafen-api

# Login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Tag y push
docker tag estafen/api:1.0.0 123456789012.dkr.ecr.us-east-1.amazonaws.com/estafen-api:1.0.0
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/estafen-api:1.0.0
```

### 3. Actualizar values.yaml

Edita `values.yaml` con tu imagen:

```yaml
image:
  repository: tu-usuario/estafen-api  # o tu ECR URL
  tag: "1.0.0"
```

### 4. Instalar con Helm

```bash
# Validar el chart
helm lint .

# Ver los manifiestos que se generarán
helm template estafen . --debug

# Instalar
helm install estafen . \
  --namespace estafen \
  --create-namespace

# Ver el estado
helm status estafen -n estafen
```

## 🔍 **Verificar el Despliegue**

```bash
# Ver todos los recursos
kubectl get all -n estafen

# Ver pods
kubectl get pods -n estafen

# Ver logs
kubectl logs -n estafen -l app.kubernetes.io/name=estafen --tail=50

# Ver el service
kubectl get svc -n estafen

# Ver HPA
kubectl get hpa -n estafen
```

## 🌐 **Acceder a la Aplicación**

### Opción 1: LoadBalancer (AWS/GCP)

```bash
# Obtener la IP externa
kubectl get svc estafen -n estafen

# Esperar a que aparezca EXTERNAL-IP
# Luego acceder:
curl http://<EXTERNAL-IP>/api
curl http://<EXTERNAL-IP>/health
```

### Opción 2: Port Forward (Local/Minikube)

```bash
kubectl port-forward -n estafen svc/estafen 8080:80

# En otra terminal:
curl http://localhost:8080/api
curl http://localhost:8080/health
```

## 📊 **Probar Auto-scaling (HPA)**

```bash
# Ver estado del HPA
kubectl get hpa -n estafen -w

# Generar carga (en otra terminal)
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh

# Dentro del pod:
while true; do wget -q -O- http://estafen.estafen.svc.cluster.local/api; done

# Observar cómo escala
kubectl get pods -n estafen -w
```

## 📝 **Endpoints de la API**

| Endpoint | Descripción |
|----------|-------------|
| `/api` | Información de la aplicación |
| `/health` | Health check (liveness) |
| `/ready` | Readiness check |

## 🛠️ **Comandos Útiles**

```bash
# Ver logs en tiempo real
kubectl logs -n estafen -l app.kubernetes.io/name=estafen -f

# Describir un pod
kubectl describe pod -n estafen <pod-name>

# Ejecutar shell en un pod
kubectl exec -it -n estafen <pod-name> -- /bin/sh

# Actualizar la aplicación
helm upgrade estafen . -n estafen

# Rollback
helm rollback estafen -n estafen

# Desinstalar
helm uninstall estafen -n estafen
```

## 📂 **Estructura del Proyecto**

```
k8s-helm-estafen/
├── app/
│   ├── server.js          # Aplicación Node.js
│   └── package.json
├── Dockerfile             # Imagen Docker
├── .dockerignore
├── Chart.yaml             # Metadatos del chart
├── values.yaml            # Configuración
├── .helmignore
├── README.md
└── templates/
    ├── _helpers.tpl       # Helpers de Helm
    ├── NOTES.txt          # Notas post-instalación
    ├── namespace.yaml     # Namespace
    ├── deployment.yaml    # Deployment (2 réplicas)
    ├── service.yaml       # LoadBalancer
    ├── ingress.yaml       # Ingress (opcional)
    ├── serviceaccount.yaml
    ├── clusterrole.yaml   # RBAC
    ├── clusterrolebinding.yaml
    └── hpa.yaml           # Auto-scaling
```

## ⚙️ **Configuración**

### Valores Principales en values.yaml

```yaml
replicaCount: 2              # Número de réplicas

image:
  repository: estafen/api    # Tu imagen
  tag: "1.0.0"

service:
  type: LoadBalancer         # O ClusterIP para local
  port: 80

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70

ingress:
  enabled: false             # Cambiar a true si usas Ingress
```

## 🔧 **Personalización**

### Cambiar el número de réplicas

```bash
helm upgrade estafen . \
  --set replicaCount=3 \
  -n estafen
```

### Deshabilitar HPA

```bash
helm upgrade estafen . \
  --set autoscaling.enabled=false \
  -n estafen
```

### Usar ClusterIP en lugar de LoadBalancer

```bash
helm upgrade estafen . \
  --set service.type=ClusterIP \
  -n estafen
```

## 🐛 **Troubleshooting**

### Pods no inician

```bash
kubectl describe pod -n estafen <pod-name>
kubectl logs -n estafen <pod-name>
```

### ImagePullBackOff

- Verifica que la imagen existe en el registry
- Verifica que tienes permisos para pull
- Si usas registry privado, configura `imagePullSecrets`

### LoadBalancer Pending

- En Minikube: Usa `minikube tunnel` en otra terminal
- En Kind: Usa port-forward en su lugar
- En AWS/GCP: Espera 2-3 minutos

## ☁️ **Desplegar en AWS EKS**

Para desplegar en Amazon EKS, sigue la guía completa:

📖 **[EKS-DEPLOYMENT.md](EKS-DEPLOYMENT.md)** - Guía paso a paso que incluye:
- Crear cluster EKS con eksctl
- Configurar ECR (Elastic Container Registry)
- Construir y subir imagen Docker
- Desplegar con Helm
- Configurar External Secrets Operator
- Monitoreo y troubleshooting
- Costos estimados

### Inicio Rápido EKS

```bash
# 1. Crear cluster
eksctl create cluster --name estafen-cluster --region us-east-1

# 2. Crear repo ECR y subir imagen
aws ecr create-repository --repository-name estafen-api
# ... (ver EKS-DEPLOYMENT.md para detalles)

# 3. Desplegar
helm install estafen . -n estafen --create-namespace

# 4. Acceder
kubectl get svc estafen -n estafen
```

## 🔐 **Gestión Segura de Secretos**

Para usar AWS Secrets Manager en lugar de secretos planos:

📖 **[SECRETS-GUIDE.md](SECRETS-GUIDE.md)** - Guía completa de External Secrets Operator

### Características
- ✅ Secretos encriptados en AWS Secrets Manager
- ✅ Sincronización automática con Kubernetes
- ✅ Rotación de secretos
- ✅ Auditoría con CloudTrail
- ✅ IRSA (IAM Roles for Service Accounts)

## 📚 **Próximos Pasos**

1. ✅ Desplegar la aplicación básica
2. 📊 Agregar Prometheus y Grafana para monitoring
3. 🔒 Habilitar Ingress con TLS
4. 🗄️ Agregar una base de datos
5. 🚀 Implementar CI/CD con GitHub Actions

## 📖 **Recursos**

- [Documentación de Helm](https://helm.sh/docs/)
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [HPA Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)

## 📧 **Soporte**

Para preguntas o issues: cloud-team@estafen.io

---

**¡Feliz aprendizaje de Kubernetes!** 🚀
