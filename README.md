# DataBase - Scripts PostgreSQL

Scripts SQL para la base de datos del sistema de bienestar.

## Archivos

- `init.sql` - Esquemas, tablas y datos iniciales
- `sp_seg.sql` - Stored procedures para seguridad (roles y usuarios)

## Ejecución con Docker

```bash
# Crear y ejecutar contenedor PostgreSQL
docker run -d --name bienestar-db \
  -e POSTGRES_DB=bienestar \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:16-alpine

# Esperar 10 segundos, luego ejecutar scripts
docker exec -i bienestar-db psql -U postgres -d bienestar < init.sql
docker exec -i bienestar-db psql -U postgres -d bienestar < sp_seg.sql
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
