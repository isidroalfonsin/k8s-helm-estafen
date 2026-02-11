# Estafen Helm Chart - Intermediate Level

Helm chart Kubernetes con una aplicación Node.js de ejemplo.

## **Características**

- **Aplicación Node.js simple** con endpoints de health
- **Deployment** con 2 réplicas y RollingUpdate
- **Service LoadBalancer** para acceso externo
- **HPA** (auto-scaling de pods)
- **RBAC** básico
- **Dockerfile** incluido
- **AWS EKS ready**
- **AWS Secrets Manager**

## **Inicio Rápido**

### 1. Construir la imagen Docker

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
docker tag estafen/api:1.0.0 user/estafen-api:1.0.0
docker push user/estafen-api:1.0.0
```

### 3. Actualizar values.yaml

Edita `values.yaml` con la nueva imagen:

```yaml
image:
  repository: user/estafen-api
  tag: "1.0.0"
```

### 4. Instalar con Helm

```bash
# Validar el chart con lint
helm lint .

# se habilito el kubernetes cluster en docker hub y luego se ejecuto el siguiente comando

# Instalar el chart
helm install estafen . \
  --namespace estafen \
  --create-namespace

# Ver el estado del despliegue
helm status estafen -n estafen
```

## **Verificar el Despliegue**

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

## **Acceder a la Aplicación**

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

## **Probar Auto-scaling (HPA)**

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

## **Endpoints de la API**

| Endpoint | Descripción |
|----------|-------------|
| `/api` | Información de la aplicación |
| `/health` | Health check (liveness) |
| `/ready` | Readiness check |

## **Comandos Útiles**

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

## **Estructura del Proyecto**

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

## **Personalización**

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

## **Troubleshooting**

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

##  **Desplegar en AWS EKS**

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

## **Gestión Segura de Secretos**

Para usar AWS Secrets Manager en lugar de secretos planos:

**[SECRETS-GUIDE.md](SECRETS-GUIDE.md)** - Guía completa de External Secrets Operator

### Características
- ✅ Secretos encriptados en AWS Secrets Manager
- ✅ Sincronización automática con Kubernetes
- ✅ Rotación de secretos
- ✅ Auditoría con CloudTrail
- ✅ IRSA (IAM Roles for Service Accounts)

## **Próximos Pasos**

1. Desplegar la aplicación básica
2. Agregar Prometheus y Grafana para monitoring
3. Habilitar Ingress con TLS
4. Agregar una base de datos
5. Implementar CI/CD con GitHub Actions

## **Errores que ocurrieron y Soluciones**

### Error 1: Docker Build - Autenticación Fallida

**Síntoma:**
```
ERROR: failed to solve: failed to fetch oauth token: unexpected status from GET request to 
https://auth.docker.io/token: 401 Unauthorized: incorrect username or password
```

**Causa:**
Las credenciales de Docker Hub no estaban correctas
**Solución:**
```bash
# Cerrar sesión de Docker Hub
docker logout

# Iniciar sesión nuevamente
docker login

# Verificar que funciona
docker build -t estafen/api:1.0.0 .
```

### Error 2: Kubernetes Cluster Unreachable

**Síntoma:**
```
Error: INSTALLATION FAILED: cluster reachability check failed: kubernetes cluster unreachable: 
Get "https://127.0.0.1:51142/version": dial tcp 127.0.0.1:51142: connect: connection refused
```

**Causa:**
El clúster de Kubernetes no está corriendo o no está habilitado.

**Solución para Docker Desktop:**
Habilita el clúster de Kubernetes en Docker Desktop.

**Verificar:**
```bash
kubectl cluster-info
kubectl get nodes
```

### Error 3: External IP no Accesible en kind

**Síntoma:**
El servicio muestra una EXTERNAL-IP (ejemplo: `172.18.0.6`) pero `curl` no puede conectarse:
```bash
kubectl get svc estafen -n estafen
# NAME      TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)
# estafen   LoadBalancer   10.96.47.203   172.18.0.6    80:32441/TCP

curl http://172.18.0.6/api
# curl: (28) Connection timed out
```

**Causa:**
En kind (Kubernetes in Docker), la IP externa está en la red interna de Docker y no es accesible directamente desde el host.

**Solución: Usar Port Forward**
```bash
# Crear un port forward del servicio
kubectl port-forward -n estafen svc/estafen 8080:80

# En otra terminal, acceder vía localhost
curl http://localhost:8080/api
curl http://localhost:8080/health
```

