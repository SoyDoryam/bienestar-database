# DataBase - Scripts PostgreSQL

Scripts SQL para la base de datos del sistema de bienestar.

## Archivos

- `init.sql` - Esquemas, tablas y datos iniciales
- `sp_seg.sql` - Stored procedures para seguridad (roles y usuarios)

## Ejecución con Docker Compose

```bash
# Ir a la carpeta del proyecto
cd "C:\Users\doria\OneDrive\Documentos\04-Projectos\bienestar\bienestar-database"

# Eliminar contenedor Y volumen (borra datos existentes)
docker-compose down -v

# Recrear contenedor (ejecutará init.sql y sp_seg.sql automáticamente)
docker-compose up -d

# Verificar logs para confirmar que se ejecutaron
docker-compose logs postgres
```

## Ejecución Manual (psql)

```bash
# Con psql local
psql -h localhost -U postgres -d bienestar -f init.sql
psql -h localhost -U postgres -d bienestar -f sp_seg.sql
```

## Conexión

```bash
# Docker
psql -h localhost -U postgres -d bienestar

# Local
psql -U postgres -d bienestar
```

## Esquemas

| Esquema | Descripción |
|---------|-------------|
| seg | Seguridad (roles, usuarios) |
| cat | Catálogos (categorías, productos, marcas, proveedores) |
| inv | Inventario |
| fac | Facturas y pagos |
| cfg | Configuración (sucursales, cajas) |

## Tablas Principales

### seg (Seguridad)
- `seg.roles` - Roles del sistema
- `seg.usuarios` - Usuarios del sistema

### cat (Catálogos)
- `cat.categorias` - Categorías de productos
- `cat.proveedores` - Proveedores
- `cat.marca` - Marcas
- `cat.presentacion` - Presentaciones
- `cat.productos` - Productos
- `cat.sub_tipo_catalogo` - Tipos de catálogo
- `cat.catalogo` - Catálogos promocionales
- `cat.catalogo_detalle` - Detalle de catálogos

### inv (Inventario)
- `inv.inventario` - Movimientos de inventario

### fac (Facturación)
- `fac.clientes` - Clientes
- `fac.facturas` - Facturas
- `fac.factura_detalle` - Detalle de facturas
- `fac.metodos_pago` - Métodos de pago
- `fac.pagos` - Pagos

### cfg (Configuración)
- `cfg.sucursales` - Sucursales
- `cfg.cajas` - Cajas

## Usuarios de Pruebas

| Usuario | Contraseña | Rol |
|---------|------------|-----|
| admin | Admin2026* | ADMIN |

## Funciones de Login

### f_usuarios_login
Verifica credenciales y retorna datos del usuario.

```sql
SELECT * FROM seg.f_usuarios_login('admin', 'Admin2026*');
```

**Respuesta:**
```json
{
  "id_usuario": 1,
  "usuario": "admin",
  "nombre": "Administrador",
  "apellido": "Sistema",
  "rol_nombre": "ADMIN"
}
```

## Ejemplos de Uso

### Verificar que las tablas se crearon
```sql
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema IN ('seg', 'cat', 'inv', 'fac', 'cfg')
ORDER BY table_schema, table_name;
```

### Ver usuarios
```sql
SELECT id_usuario, usuario, nombre, apellido, activo,
       (SELECT rol_nombre FROM seg.roles WHERE id_rol = seg.usuarios.id_rol) as rol
FROM seg.usuarios;
```

### Ver productos
```sql
SELECT codigo, producto_nombre, precio_venta, stock_actual
FROM cat.productos
WHERE activo = true;
```

### Login desde psql (prueba rápida)
```sql
SELECT * FROM seg.f_usuarios_login('admin', 'Admin2026*');
```

### Ver contraseña hasheada (solo verificación)
```sql
SELECT usuario, contrasena FROM seg.usuarios WHERE usuario = 'admin';
```

### Reiniciar contraseña de admin
```sql
UPDATE seg.usuarios
SET contrasena = crypt('Admin2026*', gen_salt('bf', 10))
WHERE usuario = 'admin';
```

### Ver funciones disponibles
```sql
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'seg'
  AND routine_type = 'FUNCTION';
```

## Notas Importantes

- Las contraseñas se almacenan con **bcrypt** (hash de 10 rondas)
- Los scripts en `docker-entrypoint-initdb.d/` solo se ejecutan al **primer inicio**
- Para recrear la DB: `docker-compose down -v && docker-compose up -d`
- El puerto expuesto es **5433** (mapeado a 5432 del contenedor)
