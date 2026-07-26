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
