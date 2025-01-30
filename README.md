# Informe de Implementación y Despliegue de PetClinic en AWS

## 1. Configuración de la Infraestructura en AWS con Terraform

Se utilizó Terraform para desplegar la infraestructura necesaria en AWS, incluyendo:
- Un **par de claves** (`aws_key_pair`)
- Un **grupo de seguridad** (`aws_security_group`)
- Una **instancia EC2** (`aws_instance`)

### Comandos ejecutados:
```bash
terraform apply
```

### Resultado del despliegue:
```bash
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

**Direcciones IP obtenidas:**
- **IP privada:** `172.31.81.68`
- **IP pública:** `3.92.228.34`

---

## 2. Transferencia de Archivos y Configuración de la Instancia

Se ingreso a la instancia de EC2 usando SSH

```bash
ssh -i ~/.ssh/id_rsa ubuntu@3.92.228.34
```

Se intentó copiar el archivo `docker-compose.yml` a la instancia EC2 con `scp`:

```bash
scp -i ~/.ssh/id_rsa docker-compose.yml ubuntu@3.92.228.34:~/app/docker-compose.yml
```

Se encontró un problema de permisos con la clave SSH.

### Solución:
Se verificaron las claves SSH con:
```bash
ls -l ~/.ssh/id_rsa
```
Se confirmó que el `key_pair` estaba correctamente configurado en AWS:
```bash
aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName"
```
Resultado:
```bash
[
    "my-key"
]
```

---

## 3. Instalación de Docker y Docker Compose en la Instancia

Se instalaron los paquetes necesarios en la máquina virtual de AWS (EC2):
```bash
sudo apt update && sudo apt install -y docker.io docker-compose
```
Se verificó la instalación:
```bash
docker --version
docker-compose --version
```

Se añadió el usuario `ubuntu` al grupo `docker` para evitar permisos denegados:
```bash
sudo usermod -aG docker ubuntu
```

Se aplicaron los cambios sin reiniciar la sesión:
```bash
newgrp docker
```

---

## 4. Edición del Archivo `docker-compose.yml`

Se utilizó `nano` para modificar el archivo de configuración de Docker Compose:
```bash
nano docker-compose.yml
```

**Servicios incluidos en el archivo:**
- `config-server`
- `discovery-server`
- `customers-service`
- `visits-service`
- `vets-service`
- `api-gateway`
- `tracing-server`
- `admin-server`
- `grafana-server`
- `prometheus-server`

---

## 5. Despliegue de los Servicios con Docker Compose

Se ejecutó el siguiente comando para levantar los servicios en la instancia EC2:
```bash
docker-compose up -d
```

Se encontró un problema de permisos al intentar acceder al socket de Docker:
```bash
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
```

### Solución:
Se ejecutó Docker con permisos de superusuario:
```bash
sudo docker-compose up -d
```

---

## 6. Acceso al API Gateway

Se verificó el acceso al API Gateway en la instancia EC2 utilizando la IP pública:
```bash
curl http://3.92.228.34:8080
```

---

## 7. Cierre de Sesiones SSH

Se listaron las sesiones SSH activas:
```bash
ps aux | grep ssh
```

Para cerrar todas las sesiones SSH:
```bash
kill -9 <PID>
```
O simplemente cerrando la terminal activa con:
```bash
exit
```

---

## Conclusiones

- Se logró desplegar la infraestructura en AWS utilizando Terraform.
- Se configuró correctamente Docker y Docker Compose en la instancia EC2.
- Se levantaron los servicios del sistema PetClinic con Docker Compose.
- Se accedió al API Gateway a través de la IP pública de la instancia.
- Se resolvieron problemas de permisos en SSH y Docker.