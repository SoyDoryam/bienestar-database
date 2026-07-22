# DataBase - Scripts PostgreSQL

Scripts SQL para la base de datos del sistema de bienestar.

## Contenido

- `init.sql` - Esquemas y tablas iniciales
- `sp_seg.sql` - Stored procedures para seguridad (roles y usuarios)

## Ejecucion con Docker

```bash
# Crear volumen
docker volume create postgres_data

# Ejecutar contenedor con scripts
docker run -d --name bienestar-db \
  -e POSTGRES_DB=bienestar \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  -v ./init.sql:/docker-entrypoint-initdb.d/init.sql \
  postgres:16-alpine
```

## Ejecucion Manual

```bash
# Con psql
psql -h localhost -U postgres -d bienestar -f init.sql
psql -h localhost -U postgres -d bienestar -f sp_seg.sql
```

## Conexion

```bash
# Docker
psql -h localhost -U postgres -d bienestar

# Local
psql -U postgres -d bienestar
```

## Esquemas

- **seg** - Seguridad (roles, usuarios)
- **cat** - Catalogos (categorias, productos, marcas, proveedores)
- **inv** - Inventario
- **fac** - Facturas y pagos
- **cfg** - Configuracion (sucursales, cajas)

## Tablas Principales

- seg.roles, seg.usuarios
- cat.categorias, cat.productos, cat.marca, cat.presentacion, cat.proveedores
- cat.catalogo, cat.catalogo_detalle, cat.sub_tipo_catalogo
- inv.inventario
- fac.clientes, fac.facturas, fac.factura_detalle, fac.pagos, fac.metodos_pago
- cfg.sucursales, cfg.cajas
