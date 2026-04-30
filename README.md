# 📚 Selora

> Red social para lectores. Rastrea tus lecturas, descubre libros, conecta con comunidades y participa en tertulias.

**Estado actual:** MVP — Tracker de libros

---

## Índice

- [Requisitos](#requisitos)
- [Instalación y despliegue local](#instalación-y-despliegue-local)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Comandos útiles](#comandos-útiles)
- [Variables de entorno](#variables-de-entorno)
- [Roadmap](#roadmap)

---

## Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/Mac/Linux)
- Git

No necesitas PHP, Node ni Composer instalados localmente. Todo corre dentro de Docker.

---

## Instalación y despliegue local

### 1. Clonar el repositorio

```bash
git clone https://github.com/IonFDev/selora.git
cd selora
```

### 2. Configurar variables de entorno

```bash
cp .env.example .env
```

Abre `.env` y ajusta estos valores (ya coinciden con el `docker-compose.yml` por defecto):

```env
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=selora
DB_USERNAME=root
DB_PASSWORD=secret
```

> ⚠️ El host de la DB es `db` (nombre del servicio Docker), no `127.0.0.1`.

### 3. Construir y levantar los contenedores

```bash
docker compose up -d --build
```

La primera vez tarda un par de minutos. Los siguientes `up` son instantáneos gracias al caché de capas y los volúmenes persistentes.

### 4. Generar la clave de la aplicación

```bash
docker exec -it selora_app php artisan key:generate
```

### 5. Ejecutar migraciones

```bash
docker exec -it selora_app php artisan migrate
```

Si quieres poblar la base de datos con datos de prueba:

```bash
docker exec -it selora_app php artisan migrate:fresh --seed
```

### 6. Permisos de almacenamiento (solo si hay errores de escritura)

```bash
docker exec -it selora_app chmod -R 775 storage bootstrap/cache
docker exec -it selora_app chown -R www-data:www-data storage bootstrap/cache
```

### 7. Listo 🎉

| Servicio      | URL                          |
|---------------|------------------------------|
| Aplicación    | http://localhost:8000        |
| phpMyAdmin    | http://localhost:8080        |
| Vite (HMR)    | http://localhost:5173        |

---

## Estructura del proyecto

```
selora/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── BookController.php
│   │   │   ├── DashboardController.php
│   │   │   └── ProfileController.php
│   │   └── Requests/
│   └── Models/
│       ├── User.php
│       └── Book.php
├── database/
│   ├── migrations/
│   └── seeders/
├── resources/
│   ├── css/
│   ├── js/
│   └── views/
│       ├── layouts/
│       │   ├── app.blade.php      ← Layout autenticado
│       │   └── guest.blade.php    ← Layout público (landing, auth)
│       ├── landing/
│       │   └── index.blade.php    ← Página de inicio pública
│       ├── dashboard/
│       │   └── index.blade.php
│       ├── books/
│       │   ├── index.blade.php    ← Búsqueda / catálogo (datos de API)
│       │   └── show.blade.php     ← Detalle del libro + acciones del usuario
│       └── profile/
│           └── index.blade.php
├── routes/
│   └── web.php
├── docker-compose.yml
├── Dockerfile
└── .env.example
```

---

## Comandos útiles

### Contenedores

```bash
# Levantar en segundo plano
docker compose up -d

# Apagar (conserva volúmenes y datos)
docker compose down

# Apagar y borrar TODOS los volúmenes (borra la DB también)
docker compose down -v

# Ver logs en tiempo real
docker compose logs -f

# Ver logs de un servicio concreto
docker compose logs -f app
docker compose logs -f node
```

### Artisan (Laravel)

```bash
# Ejecutar cualquier comando artisan
docker exec -it selora_app php artisan <comando>

# Ejemplos frecuentes
docker exec -it selora_app php artisan migrate
docker exec -it selora_app php artisan migrate:fresh --seed
docker exec -it selora_app php artisan make:model NombreModelo -mcr
docker exec -it selora_app php artisan route:list
docker exec -it selora_app php artisan config:clear
docker exec -it selora_app php artisan cache:clear
```

### Shell dentro del contenedor

```bash
docker exec -it selora_app bash
```

---

## Variables de entorno

| Variable           | Valor por defecto     | Descripción                        |
|--------------------|-----------------------|------------------------------------|
| `APP_NAME`         | `Selora`              | Nombre de la app                   |
| `APP_ENV`          | `local`               | Entorno (`local`, `production`)    |
| `APP_DEBUG`        | `true`                | Debug mode (desactivar en prod)    |
| `APP_URL`          | `http://localhost:8000` | URL base                         |
| `DB_HOST`          | `db`                  | Host MySQL (nombre del servicio)   |
| `DB_DATABASE`      | `selora`              | Nombre de la base de datos         |
| `DB_USERNAME`      | `root`                | Usuario MySQL                      |
| `DB_PASSWORD`      | `secret`              | Contraseña MySQL                   |

---

## Roadmap

### ✅ MVP — Tracker de libros
- [x] Setup Docker (PHP 8.4, MySQL 8, Vite, phpMyAdmin)
- [ ] Autenticación (registro, login, logout)
- [ ] Catálogo de libros vía API (los usuarios no crean ni editan libros)
- [ ] Estados de lectura por usuario (quiero leer · leyendo · leído · abandonado)
- [ ] Reseña personal por libro
- [ ] Valoración (ranking) por libro
- [ ] Marcar como favorito
- [ ] Lista de deseos
- [ ] Dashboard con estadísticas del usuario (libros leídos, en progreso, etc.)

> Los libros son de solo lectura para el usuario final. Se importan desde la API
> de Google Books. El usuario únicamente interactúa con ellos (estados, reseñas, rankings, favoritos).

### 🔜 Fase 2 — Social
- [ ] Perfiles públicos de usuario
- [ ] Sistema de seguimiento entre usuarios
- [ ] Comunidades por género / autor
- [ ] Tertulias (clubes de lectura)

### 🔮 Fase 3 — Integraciones
- [ ] API Google Books (búsqueda y metadatos)
- [ ] Amazon Afiliados
- [ ] Sugerencias de libros con IA
- [ ] Creadores de contenido / reseñas

---

## Servicios Docker

| Contenedor              | Imagen              | Puerto interno | Puerto host |
|-------------------------|---------------------|----------------|-------------|
| `selora_app`            | PHP 8.4 + Apache    | 80             | 8000        |
| `selora_db`             | MySQL 8.0           | 3306           | 3306        |
| `selora_node`           | Node 22 Alpine      | 5173           | 5173        |
| `selora_phpmyadmin`     | phpMyAdmin          | 80             | 8080        |