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
-- USUARIO ADMINISTRADOR INICIAL
-- =============================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO seg.usuarios
(
    usuario,
    contrasena,
    nombre,
    apellido,
    correo,
    telefono,
    id_rol
)
SELECT
    'admin',
    crypt('Admin2026*', gen_salt('bf', 10)),
    'Administrador',
    'Sistema',
    'admin@bienestar.com',
    NULL,
    id_rol
FROM seg.roles
WHERE rol_nombre = 'ADMIN'
AND NOT EXISTS (
    SELECT 1
    FROM seg.usuarios
    WHERE usuario = 'admin'
);

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

-- =============================================
-- DATOS DE CATALOGOS
-- =============================================

INSERT INTO cat.categorias (id_categoria, codigo_categoria, categoria_nombre, descripcion) VALUES
(1, 'CAT-MED', 'Medicamentos', 'Analgésicos, antibióticos, antihistamínicos y jarabes'),
(2, 'CAT-NUT', 'Nutrición e Infantil', 'Fórmulas lácteas, leches en polvo y cereales infantiles'),
(3, 'CAT-BEB', 'Cuidado del Bebé', 'Biberones, chupones, mamilas y accesorios'),
(4, 'CAT-AUX', 'Primeros Auxilios', 'Material de curación, antisépticos y desinfectantes'),
(5, 'CAT-HIG', 'Higiene Personal', 'Cuidado oral, jabones, champús y talcos');

INSERT INTO cat.proveedores (id_proveedor, codigo_proveedor, proveedor_nombre, contacto, telefono, correo, direccion) VALUES
(1, 'PROV-DRO', 'Droguería Farmacéutica Central S.A.', 'Carlos Ruiz', '2222-1111', 'ventas@drogueriacentral.com', 'Zona Industrial Lote 12'),
(2, 'PROV-NUT', 'Distribuidora Láctea e Infantil', 'Ana Gómez', '2244-3322', 'pedidos@lacteosinfantiles.com', 'Km 7 Carretera Norte'),
(3, 'PROV-SUM', 'Suministros Médicos y Botiquín', 'Jorge Blandón', '2288-9900', 'jblandon@sumedglobal.com', 'Reparto San Juan #45');

INSERT INTO cat.marca (id_marca, marca_nombre, descripcion) VALUES
(1, 'MK', 'Línea de medicamentos genéricos bioequivalentes'),
(2, 'Enfamil', 'Fórmulas lácteas infantiles de alta nutrición'),
(3, 'Nan', 'Fórmulas infantiles Nestlé'),
(4, 'Evenflo', 'Productos y accesorios para lactancia y bebé'),
(5, 'Jaloma', 'Productos para botiquín y primeros auxilios'),
(6, 'Bayer', 'Laboratorio farmacéutico multinacional'),
(7, 'Johnson & Johnson', 'Cuidado e higiene infantil y personal'),
(8, 'Colgate', 'Cuidado e higiene oral');

INSERT INTO cat.presentacion (id_presentacion, presentacion_nombre, descripcion) VALUES
(1, 'Caja', 'Caja de cartón con tabletas o blísteres'),
(2, 'Lata', 'Lata metálica sellada para leches/fórmulas'),
(3, 'Frasco', 'Frasco de plástico o vidrio para líquidos/jarabes'),
(4, 'Unidad', 'Pieza individual u empaque blíster simple'),
(5, 'Paquete', 'Empaque plástico con múltiples unidades');

INSERT INTO cat.productos (
    id_producto, codigo, codigo_barras, producto_nombre, descripcion,
    id_categoria, precio_compra, precio_venta, precio_venta_usd,
    stock_minimo, stock_actual, fecha_vencimiento, lote,
    id_proveedor, id_marca, id_presentacion
) VALUES

-- FÓRMULAS LÁCTEAS
(101, 'NUT-ENF-400', '7501234998877', 'Enfamil Premium Etapa 1 400g', 'Fórmula láctea en lata con hierro para lactantes de 0 a 6 meses',
 2, 14.50, 19.50, 0.53, 5, 20, '2027-08-31', 'LT-ENF-2026', 2, 2, 2),

(102, 'NUT-NAN-400', '7501234998884', 'Nan Pro Etapa 1 400g', 'Fórmula infantil con optipro y probióticos',
 2, 13.80, 18.25, 0.49, 5, 18, '2027-10-15', 'LT-NAN-102', 2, 3, 2),

(103, 'NUT-ENF-800', '7501234998891', 'Enfamil Premium Etapa 2 800g', 'Fórmula láctea de continuación para lactantes de 6 a 12 meses',
 2, 26.00, 34.00, 0.92, 4, 12, '2027-11-20', 'LT-ENF-800', 2, 2, 2),

-- JARABES Y MEDICAMENTOS LÍQUIDOS
(104, 'MED-AMB-120', '7504455667788', 'Ambroxol Jarabe Infantil 120ml', 'Expectorante y mucolítico para alivio de la tos con flemas',
 1, 2.10, 4.25, 0.12, 10, 35, '2027-03-15', 'LT-JAR-551', 1, 1, 3),

(105, 'MED-LOR-100', '7504455667795', 'Loratadina Jarabe 100ml', 'Antihistamínico para alergias y rinitis alérgica',
 1, 1.90, 3.80, 0.10, 8, 25, '2027-05-30', 'LT-LOR-882', 1, 1, 3),

(106, 'MED-PAR-120', '7504455667801', 'Paracetamol Jarabe 120ml', 'Analgésico y antipirético infantil sabor a cereza',
 1, 1.75, 3.50, 0.09, 12, 40, '2027-07-10', 'LT-PAR-301', 1, 1, 3),

-- LACTANCIA Y BEBÉ
(107, 'BEB-EVE-009', '7509876543210', 'Biberón Evenflo Anticólicos 9oz', 'Biberón libre de BPA con mamila de silicona flujo medio',
 3, 3.80, 6.75, 0.18, 5, 15, NULL, NULL, 2, 4, 4),

(108, 'BEB-EVE-004', '7509876543227', 'Biberón Evenflo Recién Nacido 4oz', 'Biberón compacto flujo lento para recién nacidos',
 3, 3.10, 5.50, 0.15, 5, 12, NULL, NULL, 2, 4, 4),

(109, 'BEB-MAM-002', '7509876543234', 'Mamilas de Silicona Evenflo (2 pack)', 'Repuesto de tetinas anticólicos flujo medio',
 3, 1.50, 2.99, 0.08, 6, 20, NULL, NULL, 2, 4, 5),

(110, 'BEB-CHU-001', '7509876543241', 'Chupón Ortodóntico Etapa 1', 'Chupón de entretención anatómico de silicona libre de BPA',
 3, 1.20, 2.50, 0.07, 8, 14, NULL, NULL, 2, 4, 4),

(111, 'BEB-CEP-001', '7509876543258', 'Cepillo Limpiador de Biberones', 'Cepillo con cerdas suaves y limpia-mamila integrado',
 3, 1.80, 3.25, 0.09, 4, 10, NULL, NULL, 2, 4, 4),

-- ANALGÉSICOS
(112, 'MED-ACE-500', '7501000111223', 'Acetaminofén MK 500mg (Caja x 100)', 'Analgésico y antipirético para alivio de dolor y fiebre',
 1, 2.10, 4.50, 0.12, 10, 50, '2028-01-15', 'LT-MK-8891', 1, 1, 1),

(113, 'MED-ASP-500', '7501334455667', 'Aspirina Bayer 500mg (Caja x 40)', 'Ácido acetilsalicílico para alivio del dolor de cabeza y muscular',
 1, 3.00, 5.80, 0.16, 10, 45, '2026-12-31', 'LT-ASP-990', 1, 6, 1),

(114, 'MED-IBU-400', '7501000111247', 'Ibuprofeno MK 400mg (Caja x 50)', 'Antiinflamatorio no esteroideo para dolores fuertes',
 1, 2.50, 5.00, 0.14, 8, 30, '2027-09-30', 'LT-IBU-441', 1, 1, 1),

(115, 'MED-SUE-500', '7506543210987', 'Suero Oral Rehidratante 500ml', 'Solución de electrólitos orales sabor a manzana',
 1, 0.90, 1.80, 0.05, 15, 60, '2026-11-15', 'LT-SUE-401', 1, 1, 3),

-- PRIMEROS AUXILIOS
(116, 'AUX-ALC-500', '7501122334455', 'Alcohol Etílico 70% Jaloma 500ml', 'Antiséptico de uso externo para desinfección de heridas',
 4, 1.10, 2.25, 0.06, 10, 30, '2028-06-30', 'LT-JAL-7712', 3, 5, 3),

(117, 'AUX-AGU-250', '7501122334462', 'Agua Oxigenada Jaloma 250ml', 'Solución antiséptica y hemostática para lavado de heridas',
 4, 0.85, 1.75, 0.05, 10, 25, '2028-03-15', 'LT-JAL-221', 3, 5, 3),

(118, 'AUX-GAS-010', '7501122334479', 'Gasas Estériles 3x3 (Sobre x 5)', 'Sobres de gasa de algodón para curaciones',
 4, 0.40, 0.90, 0.02, 20, 80, NULL, NULL, 3, 5, 5),

-- HIGIENE PERSONAL
(119, 'HIG-TAL-200', '7507788990011', 'Talco Infantil Johnson 200g', 'Talco suave e hipoalergénico para absorción de humedad',
 5, 2.20, 4.10, 0.11, 6, 18, NULL, NULL, 2, 7, 4),

(120, 'HIG-COL-100', '7507788990028', 'Crema Dental Colgate Triple Acción 100ml', 'Crema dental con flúor para protección anticaries',
 5, 1.30, 2.50, 0.07, 10, 35, '2027-04-30', 'LT-COL-991', 1, 8, 1);

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
