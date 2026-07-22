-- =============================================
-- BIENESTAR - Base de datos PostgreSQL
-- =============================================

-- =============================================
-- ESQUEMAS
-- =============================================
CREATE SCHEMA IF NOT EXISTS seg;
CREATE SCHEMA IF NOT EXISTS cat;
CREATE SCHEMA IF NOT EXISTS inv;
CREATE SCHEMA IF NOT EXISTS fac;
CREATE SCHEMA IF NOT EXISTS cfg;

-- =============================================
-- SEGURIDAD (seg)
-- =============================================
CREATE TABLE seg.roles(
    id_rol SERIAL PRIMARY KEY,
    rol_nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE seg.usuarios(
    id_usuario SERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(100),
    telefono VARCHAR(20),
    id_rol INTEGER NOT NULL REFERENCES seg.roles(id_rol),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualiza TIMESTAMP
);

INSERT INTO seg.roles (rol_nombre, descripcion) VALUES
('ADMIN', 'Administrador del sistema'),
('VENDEDOR', 'Usuario vendedor'),
('INVENTARIO', 'Usuario de inventario'),
('CAJERO', 'Usuario cajero');

-- =============================================
-- CATALOGOS (cat)
-- =============================================
CREATE TABLE cat.categorias(
    id_categoria SERIAL PRIMARY KEY,
    codigo_categoria VARCHAR(20) NOT NULL,
    categoria_nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cat.proveedores(
    id_proveedor SERIAL PRIMARY KEY,
    codigo_proveedor VARCHAR(20) NOT NULL,
    proveedor_nombre VARCHAR(200) NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion VARCHAR(300),
    notas VARCHAR(500),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualiza TIMESTAMP
);

CREATE TABLE cat.marca(
    id_marca SERIAL PRIMARY KEY,
    marca_nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cat.presentacion(
    id_presentacion SERIAL PRIMARY KEY,
    presentacion_nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cat.productos(
    id_producto SERIAL PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    codigo_barras VARCHAR(50),
    producto_nombre VARCHAR(200) NOT NULL,
    descripcion VARCHAR(500),
    id_categoria INTEGER NOT NULL REFERENCES cat.categorias(id_categoria),
    precio_compra NUMERIC(18,2) NOT NULL DEFAULT 0,
    precio_venta NUMERIC(18,2) NOT NULL DEFAULT 0,
    precio_venta_usd NUMERIC(18,2),
    stock_minimo INTEGER NOT NULL DEFAULT 0,
    stock_actual INTEGER NOT NULL DEFAULT 0,
    fecha_vencimiento DATE,
    lote VARCHAR(50),
    id_proveedor INTEGER REFERENCES cat.proveedores(id_proveedor),
    id_marca INTEGER REFERENCES cat.marca(id_marca),
    id_presentacion INTEGER REFERENCES cat.presentacion(id_presentacion),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualiza TIMESTAMP
);

INSERT INTO cat.categorias (codigo_categoria, categoria_nombre, descripcion) VALUES
('G00', 'GENERAL', 'Artículos generales'),
('MED', 'MEDICAMENTOS', 'Medicamentos y fármacos'),
('G01', 'AROS', 'Aros para lentes'),
('G04', 'ESTUCHES', 'Estuches para lentes'),
('G06', 'LENTES', 'Lentes y monturas'),
('G07', 'EXAMENES', 'Exámenes visuales');

INSERT INTO cat.marca (marca_nombre, descripcion) VALUES
('MK', 'Marca propia Farmacia'),
('Genfar', 'Laboratorios Genfar'),
('La Santé', 'Laboratorios La Santé'),
('Bayer', 'Bayer'),
('Pfizer', 'Pfizer'),
('Novartis', 'Novartis'),
('GlaxoSmithKline', 'GSK'),
('Sanofi', 'Sanofi'),
('Roche', 'Roche'),
('Johnson & Johnson', 'Johnson & Johnson'),
('Abbott', 'Abbott Laboratories'),
('Medley', 'Medley Farmacéutica');

INSERT INTO cat.presentacion (presentacion_nombre, descripcion) VALUES
('Tableta', 'Forma sólida'),
('Cápsula', 'Cápsula gelatinosa'),
('Jarabe', 'Suspensión líquida'),
('Inyección', 'Solución inyectable'),
('Crema', 'Forma semisólida topical'),
('Ungüento', 'Forma semisólida oleaginosa'),
('Gotas', 'Solución liquida oftalmica/auditivas'),
('Sobre', 'Polvo/solucion oral'),
('Supositorio', 'Forma sólida rectal'),
('Parche', 'Sistema transdérmico');

-- =============================================
-- INVENTARIO (inv)
-- =============================================
CREATE TABLE inv.inventario(
    id_inventario SERIAL PRIMARY KEY,
    id_producto INTEGER NOT NULL REFERENCES cat.productos(id_producto),
    tipo_movimiento VARCHAR(20) NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(18,2),
    numero_documento VARCHAR(50),
    observacion VARCHAR(300),
    id_usuario INTEGER NOT NULL REFERENCES seg.usuarios(id_usuario),
    fecha_movimiento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- CLIENTES (fac)
-- =============================================
CREATE TABLE fac.clientes(
    id_cliente SERIAL PRIMARY KEY,
    cedula VARCHAR(20),
    cliente_nombre VARCHAR(200) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion VARCHAR(300),
    fecha_nacimiento DATE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- FACTURAS (fac)
-- =============================================
CREATE TABLE fac.facturas(
    id_factura SERIAL PRIMARY KEY,
    numero_factura VARCHAR(20) NOT NULL UNIQUE,
    id_cliente INTEGER REFERENCES fac.clientes(id_cliente),
    id_usuario INTEGER NOT NULL REFERENCES seg.usuarios(id_usuario),
    subtotal NUMERIC(18,2) NOT NULL DEFAULT 0,
    descuento NUMERIC(18,2) NOT NULL DEFAULT 0,
    impuesto NUMERIC(18,2) NOT NULL DEFAULT 0,
    total NUMERIC(18,2) NOT NULL DEFAULT 0,
    moneda VARCHAR(5) NOT NULL DEFAULT 'NIO',
    tipo_pago VARCHAR(20) NOT NULL DEFAULT 'CONTADO',
    estado VARCHAR(20) NOT NULL DEFAULT 'COMPLETADA',
    observaciones VARCHAR(500),
    fecha_factura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE fac.factura_detalle(
    id_detalle SERIAL PRIMARY KEY,
    id_factura INTEGER NOT NULL REFERENCES fac.facturas(id_factura),
    id_producto INTEGER NOT NULL REFERENCES cat.productos(id_producto),
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(18,2) NOT NULL,
    costo_unitario NUMERIC(18,2) NOT NULL DEFAULT 0,
    descuento NUMERIC(18,2) NOT NULL DEFAULT 0,
    subtotal NUMERIC(18,2) NOT NULL
);

-- =============================================
-- PAGOS (fac)
-- =============================================
CREATE TABLE fac.metodos_pago(
    id_metodo SERIAL PRIMARY KEY,
    metodo_nombre VARCHAR(50) NOT NULL,
    codigo VARCHAR(10) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE fac.pagos(
    id_pago SERIAL PRIMARY KEY,
    id_factura INTEGER NOT NULL REFERENCES fac.facturas(id_factura),
    id_metodo INTEGER NOT NULL REFERENCES fac.metodos_pago(id_metodo),
    monto NUMERIC(18,2) NOT NULL,
    referencia VARCHAR(100),
    notas VARCHAR(300),
    fecha_pago TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO fac.metodos_pago (metodo_nombre, codigo) VALUES
('CONTADO', 'CONT'),
('TARJETA CREDITO', 'TDC'),
('TARJETA DEBITO', 'TDD'),
('TRANSFERENCIA', 'TRAN'),
('CHEQUE', 'CHE'),
('NOTA CREDITO', 'NC'),
('MIXTO', 'MIX');

-- =============================================
-- CATALOGO PROMOCIONES (cat)
-- =============================================
CREATE TABLE cat.sub_tipo_catalogo(
    id_sub_tipo SERIAL PRIMARY KEY,
    sub_tipo_nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cat.catalogo(
    id_catalogo SERIAL PRIMARY KEY,
    catalogo_nombre VARCHAR(100) NOT NULL,
    id_sub_tipo INTEGER REFERENCES cat.sub_tipo_catalogo(id_sub_tipo),
    descripcion VARCHAR(300),
    precio_especial NUMERIC(18,2) NOT NULL DEFAULT 0,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cat.catalogo_detalle(
    id_detalle SERIAL PRIMARY KEY,
    id_catalogo INTEGER NOT NULL REFERENCES cat.catalogo(id_catalogo),
    id_producto INTEGER NOT NULL REFERENCES cat.productos(id_producto),
    precio_oferta NUMERIC(18,2) NOT NULL
);

INSERT INTO cat.sub_tipo_catalogo (sub_tipo_nombre, descripcion) VALUES
('OFERTA', 'Ofertas y descuentos'),
('BLACK FRIDAY', 'Promociones Black Friday'),
('NAVIDAD', 'Promociones de Navidad'),
('ADELGAZANTES', 'Productos para control de peso'),
('DERMATOLOGICOS', 'Productos dermatológicos'),
('MEDICAMENTOS', 'Catálogo de medicamentos'),
('SUPLEMENTOS', 'Vitaminas y suplementos'),
('CUIDADO BEBÉ', 'Productos para bebé'),
('CUIDADO PERSONAL', 'Higiene y cuidado personal'),
('PATROCINADO', 'Marcas patrocinadas');

-- =============================================
-- CONFIGURACION (cfg)
-- =============================================
CREATE TABLE cfg.sucursales(
    id_sucursal SERIAL PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL,
    sucursal_nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(300),
    telefono VARCHAR(20),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE cfg.cajas(
    id_caja SERIAL PRIMARY KEY,
    id_sucursal INTEGER NOT NULL REFERENCES cfg.sucursales(id_sucursal),
    caja_nombre VARCHAR(50) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO cfg.sucursales (codigo, sucursal_nombre, direccion) VALUES
('MAT', 'MATAMOROS', 'Matamoros, Tamaulipas');

INSERT INTO cfg.cajas (id_sucursal, caja_nombre) VALUES
(1, 'CAJA 1'),
(1, 'CAJA 2');

-- =============================================
-- INDICES
-- =============================================
CREATE INDEX idx_productos_codigo ON cat.productos(codigo);
CREATE INDEX idx_productos_categoria ON cat.productos(id_categoria);
CREATE INDEX idx_facturas_cliente ON fac.facturas(id_cliente);
CREATE INDEX idx_facturas_fecha ON fac.facturas(fecha_factura);
CREATE INDEX idx_inventario_producto ON inv.inventario(id_producto);
CREATE INDEX idx_inventario_fecha ON inv.inventario(fecha_movimiento);
CREATE INDEX idx_pagos_factura ON fac.pagos(id_factura);
