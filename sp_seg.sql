-- =============================================
-- SIMULATE MODE: Stored Procedures
-- =============================================

CREATE OR REPLACE FUNCTION seg.f_simulate_check(p_simulate BOOLEAN)
RETURNS BOOLEAN AS $$
BEGIN
    IF p_simulate THEN
        RAISE NOTICE 'SIMULATE: Operacion no ejecutada en BD';
        RETURN true;
    END IF;
    RETURN false;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STORED PROCEDURES/FUNCTIONS PARA ROLES (seg)
-- =============================================

-- GET ALL ROLES
CREATE OR REPLACE FUNCTION seg.f_roles_get_all()
RETURNS TABLE(
    id_rol INTEGER,
    rol_nombre VARCHAR(50),
    descripcion VARCHAR(200),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id_rol, r.rol_nombre, r.descripcion, r.activo, r.fecha_registro
    FROM seg.roles r
    ORDER BY r.id_rol;
END;
$$ LANGUAGE plpgsql;

-- GET ROL BY ID
CREATE OR REPLACE FUNCTION seg.f_roles_get_by_id(p_id_rol INTEGER)
RETURNS TABLE(
    id_rol INTEGER,
    rol_nombre VARCHAR(50),
    descripcion VARCHAR(200),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id_rol, r.rol_nombre, r.descripcion, r.activo, r.fecha_registro
    FROM seg.roles r
    WHERE r.id_rol = p_id_rol;
END;
$$ LANGUAGE plpgsql;

-- INSERT ROL
CREATE OR REPLACE FUNCTION seg.f_roles_insert(
    p_rol_nombre VARCHAR(50),
    p_descripcion VARCHAR(200) DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN 999;
    END IF;

    INSERT INTO seg.roles (rol_nombre, descripcion)
    VALUES (p_rol_nombre, p_descripcion)
    RETURNING id_rol INTO v_id;

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- UPDATE ROL
CREATE OR REPLACE FUNCTION seg.f_roles_update(
    p_id_rol INTEGER,
    p_rol_nombre VARCHAR(50),
    p_descripcion VARCHAR(200) DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;

    UPDATE seg.roles
    SET rol_nombre = p_rol_nombre,
        descripcion = p_descripcion,
        activo = COALESCE(p_activo, activo)
    WHERE id_rol = p_id_rol;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- DELETE ROL
CREATE OR REPLACE FUNCTION seg.f_roles_delete(
    p_id_rol INTEGER,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;

    DELETE FROM seg.roles WHERE id_rol = p_id_rol;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STORED PROCEDURES/FUNCTIONS PARA USUARIOS (seg)
-- =============================================

-- GET ALL USUARIOS
CREATE OR REPLACE FUNCTION seg.f_usuarios_get_all()
RETURNS TABLE(
    id_usuario INTEGER,
    usuario VARCHAR(50),
    contrasena VARCHAR(255),
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    correo VARCHAR(100),
    telefono VARCHAR(20),
    id_rol INTEGER,
    rol_nombre VARCHAR(50),
    activo BOOLEAN,
    fecha_registro TIMESTAMP,
    fecha_actualiza TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id_usuario,
        u.usuario,
        u.contrasena,
        u.nombre,
        u.apellido,
        u.correo,
        u.telefono,
        u.id_rol,
        r.rol_nombre,
        u.activo,
        u.fecha_registro,
        u.fecha_actualiza
    FROM seg.usuarios u
    LEFT JOIN seg.roles r ON u.id_rol = r.id_rol
    ORDER BY u.id_usuario;
END;
$$ LANGUAGE plpgsql;

-- GET USUARIO BY ID
CREATE OR REPLACE FUNCTION seg.f_usuarios_get_by_id(p_id_usuario INTEGER)
RETURNS TABLE(
    id_usuario INTEGER,
    usuario VARCHAR(50),
    contrasena VARCHAR(255),
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    correo VARCHAR(100),
    telefono VARCHAR(20),
    id_rol INTEGER,
    rol_nombre VARCHAR(50),
    activo BOOLEAN,
    fecha_registro TIMESTAMP,
    fecha_actualiza TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id_usuario,
        u.usuario,
        u.contrasena,
        u.nombre,
        u.apellido,
        u.correo,
        u.telefono,
        u.id_rol,
        r.rol_nombre,
        u.activo,
        u.fecha_registro,
        u.fecha_actualiza
    FROM seg.usuarios u
    LEFT JOIN seg.roles r ON u.id_rol = r.id_rol
    WHERE u.id_usuario = p_id_usuario;
END;
$$ LANGUAGE plpgsql;

-- GET USUARIO BY USERNAME (for login)
CREATE OR REPLACE FUNCTION seg.f_usuarios_get_by_username(p_usuario VARCHAR(50))
RETURNS TABLE(
    id_usuario INTEGER,
    usuario VARCHAR(50),
    contrasena VARCHAR(255),
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    correo VARCHAR(100),
    telefono VARCHAR(20),
    id_rol INTEGER,
    rol_nombre VARCHAR(50),
    activo BOOLEAN,
    fecha_registro TIMESTAMP,
    fecha_actualiza TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id_usuario,
        u.usuario,
        u.contrasena,
        u.nombre,
        u.apellido,
        u.correo,
        u.telefono,
        u.id_rol,
        r.rol_nombre,
        u.activo,
        u.fecha_registro,
        u.fecha_actualiza
    FROM seg.usuarios u
    LEFT JOIN seg.roles r ON u.id_rol = r.id_rol
    WHERE u.usuario = p_usuario AND u.activo = TRUE;
END;
$$ LANGUAGE plpgsql;

-- INSERT USUARIO
CREATE OR REPLACE FUNCTION seg.f_usuarios_insert(
    p_usuario VARCHAR(50),
    p_contrasena VARCHAR(255),
    p_nombre VARCHAR(100),
    p_apellido VARCHAR(100),
    p_id_rol INTEGER,
    p_correo VARCHAR(100) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN 999;
    END IF;

    INSERT INTO seg.usuarios (
        usuario, contrasena, nombre, apellido,
        id_rol, correo, telefono
    )
    VALUES (
        p_usuario, p_contrasena, p_nombre, p_apellido,
        p_id_rol, p_correo, p_telefono
    )
    RETURNING id_usuario INTO v_id;

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- UPDATE USUARIO
CREATE OR REPLACE FUNCTION seg.f_usuarios_update(
    p_id_usuario INTEGER,
    p_usuario VARCHAR(50) DEFAULT NULL,
    p_contrasena VARCHAR(255) DEFAULT NULL,
    p_nombre VARCHAR(100) DEFAULT NULL,
    p_apellido VARCHAR(100) DEFAULT NULL,
    p_correo VARCHAR(100) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_id_rol INTEGER DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;

    UPDATE seg.usuarios
    SET
        usuario = COALESCE(p_usuario, usuario),
        contrasena = COALESCE(p_contrasena, contrasena),
        nombre = COALESCE(p_nombre, nombre),
        apellido = COALESCE(p_apellido, apellido),
        correo = COALESCE(p_correo, correo),
        telefono = COALESCE(p_telefono, telefono),
        id_rol = COALESCE(p_id_rol, id_rol),
        activo = COALESCE(p_activo, activo),
        fecha_actualiza = CURRENT_TIMESTAMP
    WHERE id_usuario = p_id_usuario;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- DELETE USUARIO
CREATE OR REPLACE FUNCTION seg.f_usuarios_delete(
    p_id_usuario INTEGER,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;

    DELETE FROM seg.usuarios WHERE id_usuario = p_id_usuario;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- LOGIN USUARIO (bcrypt comparison)
CREATE OR REPLACE FUNCTION seg.f_usuarios_login(
    p_usuario VARCHAR(50),
    p_contrasena VARCHAR(255)
)
RETURNS TABLE(
    id_usuario INTEGER,
    usuario VARCHAR(50),
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    rol_nombre VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id_usuario,
        u.usuario,
        u.nombre,
        u.apellido,
        r.rol_nombre
    FROM seg.usuarios u
    INNER JOIN seg.roles r ON u.id_rol = r.id_rol
    WHERE u.usuario = p_usuario
      AND u.contrasena = crypt(p_contrasena, u.contrasena)
      AND u.activo = TRUE;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STORED PROCEDURES/FUNCTIONS PARA CATEGORIAS (cat)
-- =============================================

CREATE OR REPLACE FUNCTION cat.f_categorias_get_all()
RETURNS TABLE(
    id_categoria INTEGER,
    codigo_categoria VARCHAR(20),
    categoria_nombre VARCHAR(100),
    descripcion VARCHAR(255),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id_categoria, c.codigo_categoria, c.categoria_nombre, c.descripcion, c.activo, c.fecha_registro
    FROM cat.categorias c
    ORDER BY c.id_categoria;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_categorias_get_by_id(p_id_categoria INTEGER)
RETURNS TABLE(
    id_categoria INTEGER,
    codigo_categoria VARCHAR(20),
    categoria_nombre VARCHAR(100),
    descripcion VARCHAR(255),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id_categoria, c.codigo_categoria, c.categoria_nombre, c.descripcion, c.activo, c.fecha_registro
    FROM cat.categorias c
    WHERE c.id_categoria = p_id_categoria;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_categorias_insert(
    p_codigo_categoria VARCHAR(20),
    p_categoria_nombre VARCHAR(100),
    p_descripcion VARCHAR(255) DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN 999;
    END IF;
    INSERT INTO cat.categorias (codigo_categoria, categoria_nombre, descripcion)
    VALUES (p_codigo_categoria, p_categoria_nombre, p_descripcion)
    RETURNING id_categoria INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_categorias_update(
    p_id_categoria INTEGER,
    p_codigo_categoria VARCHAR(20) DEFAULT NULL,
    p_categoria_nombre VARCHAR(100) DEFAULT NULL,
    p_descripcion VARCHAR(255) DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;
    UPDATE cat.categorias SET
        codigo_categoria = COALESCE(p_codigo_categoria, codigo_categoria),
        categoria_nombre = COALESCE(p_categoria_nombre, categoria_nombre),
        descripcion = COALESCE(p_descripcion, descripcion),
        activo = COALESCE(p_activo, activo)
    WHERE id_categoria = p_id_categoria;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_categorias_delete(
    p_id_categoria INTEGER,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;
    DELETE FROM cat.categorias WHERE id_categoria = p_id_categoria;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STORED PROCEDURES/FUNCTIONS PARA PROVEEDORES (cat)
-- =============================================

CREATE OR REPLACE FUNCTION cat.f_proveedores_get_all()
RETURNS TABLE(
    id_proveedor INTEGER,
    codigo_proveedor VARCHAR(20),
    proveedor_nombre VARCHAR(200),
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion VARCHAR(300),
    notas VARCHAR(500),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_proveedor, p.codigo_proveedor, p.proveedor_nombre, p.contacto, p.telefono,
           p.correo, p.direccion, p.notas, p.activo, p.fecha_registro
    FROM cat.proveedores p
    ORDER BY p.id_proveedor;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_proveedores_get_by_id(p_id_proveedor INTEGER)
RETURNS TABLE(
    id_proveedor INTEGER,
    codigo_proveedor VARCHAR(20),
    proveedor_nombre VARCHAR(200),
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion VARCHAR(300),
    notas VARCHAR(500),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_proveedor, p.codigo_proveedor, p.proveedor_nombre, p.contacto, p.telefono,
           p.correo, p.direccion, p.notas, p.activo, p.fecha_registro
    FROM cat.proveedores p
    WHERE p.id_proveedor = p_id_proveedor;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_proveedores_insert(
    p_codigo_proveedor VARCHAR(20),
    p_proveedor_nombre VARCHAR(200),
    p_contacto VARCHAR(100) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_correo VARCHAR(100) DEFAULT NULL,
    p_direccion VARCHAR(300) DEFAULT NULL,
    p_notas VARCHAR(500) DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN 999;
    END IF;
    INSERT INTO cat.proveedores (codigo_proveedor, proveedor_nombre, contacto, telefono, correo, direccion, notas)
    VALUES (p_codigo_proveedor, p_proveedor_nombre, p_contacto, p_telefono, p_correo, p_direccion, p_notas)
    RETURNING id_proveedor INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_proveedores_update(
    p_id_proveedor INTEGER,
    p_codigo_proveedor VARCHAR(20) DEFAULT NULL,
    p_proveedor_nombre VARCHAR(200) DEFAULT NULL,
    p_contacto VARCHAR(100) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_correo VARCHAR(100) DEFAULT NULL,
    p_direccion VARCHAR(300) DEFAULT NULL,
    p_notas VARCHAR(500) DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;
    UPDATE cat.proveedores SET
        codigo_proveedor = COALESCE(p_codigo_proveedor, codigo_proveedor),
        proveedor_nombre = COALESCE(p_proveedor_nombre, proveedor_nombre),
        contacto = COALESCE(p_contacto, contacto),
        telefono = COALESCE(p_telefono, telefono),
        correo = COALESCE(p_correo, correo),
        direccion = COALESCE(p_direccion, direccion),
        notas = COALESCE(p_notas, notas),
        activo = COALESCE(p_activo, activo),
        fecha_actualiza = CURRENT_TIMESTAMP
    WHERE id_proveedor = p_id_proveedor;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_proveedores_delete(
    p_id_proveedor INTEGER,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;
    DELETE FROM cat.proveedores WHERE id_proveedor = p_id_proveedor;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STORED PROCEDURES/FUNCTIONS PARA MARCA (cat)
-- =============================================

CREATE OR REPLACE FUNCTION cat.f_marca_get_all()
RETURNS TABLE(
    id_marca INTEGER,
    marca_nombre VARCHAR(100),
    descripcion VARCHAR(255),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.id_marca, m.marca_nombre, m.descripcion, m.activo, m.fecha_registro
    FROM cat.marca m
    ORDER BY m.id_marca;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_marca_get_by_id(p_id_marca INTEGER)
RETURNS TABLE(
    id_marca INTEGER,
    marca_nombre VARCHAR(100),
    descripcion VARCHAR(255),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.id_marca, m.marca_nombre, m.descripcion, m.activo, m.fecha_registro
    FROM cat.marca m
    WHERE m.id_marca = p_id_marca;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_marca_insert(
    p_marca_nombre VARCHAR(100),
    p_descripcion VARCHAR(255) DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN 999;
    END IF;
    INSERT INTO cat.marca (marca_nombre, descripcion)
    VALUES (p_marca_nombre, p_descripcion)
    RETURNING id_marca INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_marca_update(
    p_id_marca INTEGER,
    p_marca_nombre VARCHAR(100) DEFAULT NULL,
    p_descripcion VARCHAR(255) DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;
    UPDATE cat.marca SET
        marca_nombre = COALESCE(p_marca_nombre, marca_nombre),
        descripcion = COALESCE(p_descripcion, descripcion),
        activo = COALESCE(p_activo, activo)
    WHERE id_marca = p_id_marca;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_marca_delete(
    p_id_marca INTEGER,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;
    DELETE FROM cat.marca WHERE id_marca = p_id_marca;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STORED PROCEDURES/FUNCTIONS PARA PRESENTACION (cat)
-- =============================================

CREATE OR REPLACE FUNCTION cat.f_presentacion_get_all()
RETURNS TABLE(
    id_presentacion INTEGER,
    presentacion_nombre VARCHAR(100),
    descripcion VARCHAR(255),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_presentacion, p.presentacion_nombre, p.descripcion, p.activo, p.fecha_registro
    FROM cat.presentacion p
    ORDER BY p.id_presentacion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_presentacion_get_by_id(p_id_presentacion INTEGER)
RETURNS TABLE(
    id_presentacion INTEGER,
    presentacion_nombre VARCHAR(100),
    descripcion VARCHAR(255),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_presentacion, p.presentacion_nombre, p.descripcion, p.activo, p.fecha_registro
    FROM cat.presentacion p
    WHERE p.id_presentacion = p_id_presentacion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_presentacion_insert(
    p_presentacion_nombre VARCHAR(100),
    p_descripcion VARCHAR(255) DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN 999;
    END IF;
    INSERT INTO cat.presentacion (presentacion_nombre, descripcion)
    VALUES (p_presentacion_nombre, p_descripcion)
    RETURNING id_presentacion INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_presentacion_update(
    p_id_presentacion INTEGER,
    p_presentacion_nombre VARCHAR(100) DEFAULT NULL,
    p_descripcion VARCHAR(255) DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;
    UPDATE cat.presentacion SET
        presentacion_nombre = COALESCE(p_presentacion_nombre, presentacion_nombre),
        descripcion = COALESCE(p_descripcion, descripcion),
        activo = COALESCE(p_activo, activo)
    WHERE id_presentacion = p_id_presentacion;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_presentacion_delete(
    p_id_presentacion INTEGER,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;
    DELETE FROM cat.presentacion WHERE id_presentacion = p_id_presentacion;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STORED PROCEDURES/FUNCTIONS PARA PRODUCTOS (cat)
-- =============================================

CREATE OR REPLACE FUNCTION cat.f_productos_get_all()
RETURNS TABLE(
    id_producto INTEGER,
    codigo VARCHAR(20),
    codigo_barras VARCHAR(50),
    producto_nombre VARCHAR(200),
    descripcion VARCHAR(500),
    id_categoria INTEGER,
    categoria_nombre VARCHAR(100),
    precio_compra NUMERIC(18,2),
    precio_venta NUMERIC(18,2),
    precio_venta_usd NUMERIC(18,2),
    stock_minimo INTEGER,
    stock_actual INTEGER,
    fecha_vencimiento DATE,
    lote VARCHAR(50),
    id_proveedor INTEGER,
    proveedor_nombre VARCHAR(200),
    id_marca INTEGER,
    marca_nombre VARCHAR(100),
    id_presentacion INTEGER,
    presentacion_nombre VARCHAR(100),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        pr.id_producto, pr.codigo, pr.codigo_barras, pr.producto_nombre, pr.descripcion,
        pr.id_categoria, COALESCE(ca.categoria_nombre, ''),
        pr.precio_compra, pr.precio_venta, pr.precio_venta_usd,
        pr.stock_minimo, pr.stock_actual, pr.fecha_vencimiento, pr.lote,
        pr.id_proveedor, COALESCE(pv.proveedor_nombre, ''),
        pr.id_marca, COALESCE(m.marca_nombre, ''),
        pr.id_presentacion, COALESCE(pr2.presentacion_nombre, ''),
        pr.activo, pr.fecha_registro
    FROM cat.productos pr
    LEFT JOIN cat.categorias ca ON pr.id_categoria = ca.id_categoria
    LEFT JOIN cat.proveedores pv ON pr.id_proveedor = pv.id_proveedor
    LEFT JOIN cat.marca m ON pr.id_marca = m.id_marca
    LEFT JOIN cat.presentacion pr2 ON pr.id_presentacion = pr2.id_presentacion
    ORDER BY pr.id_producto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_productos_get_by_id(p_id_producto INTEGER)
RETURNS TABLE(
    id_producto INTEGER,
    codigo VARCHAR(20),
    codigo_barras VARCHAR(50),
    producto_nombre VARCHAR(200),
    descripcion VARCHAR(500),
    id_categoria INTEGER,
    categoria_nombre VARCHAR(100),
    precio_compra NUMERIC(18,2),
    precio_venta NUMERIC(18,2),
    precio_venta_usd NUMERIC(18,2),
    stock_minimo INTEGER,
    stock_actual INTEGER,
    fecha_vencimiento DATE,
    lote VARCHAR(50),
    id_proveedor INTEGER,
    proveedor_nombre VARCHAR(200),
    id_marca INTEGER,
    marca_nombre VARCHAR(100),
    id_presentacion INTEGER,
    presentacion_nombre VARCHAR(100),
    activo BOOLEAN,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        pr.id_producto, pr.codigo, pr.codigo_barras, pr.producto_nombre, pr.descripcion,
        pr.id_categoria, COALESCE(ca.categoria_nombre, ''),
        pr.precio_compra, pr.precio_venta, pr.precio_venta_usd,
        pr.stock_minimo, pr.stock_actual, pr.fecha_vencimiento, pr.lote,
        pr.id_proveedor, COALESCE(pv.proveedor_nombre, ''),
        pr.id_marca, COALESCE(m.marca_nombre, ''),
        pr.id_presentacion, COALESCE(pr2.presentacion_nombre, ''),
        pr.activo, pr.fecha_registro
    FROM cat.productos pr
    LEFT JOIN cat.categorias ca ON pr.id_categoria = ca.id_categoria
    LEFT JOIN cat.proveedores pv ON pr.id_proveedor = pv.id_proveedor
    LEFT JOIN cat.marca m ON pr.id_marca = m.id_marca
    LEFT JOIN cat.presentacion pr2 ON pr.id_presentacion = pr2.id_presentacion
    WHERE pr.id_producto = p_id_producto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_productos_insert(
    p_codigo VARCHAR(20),
    p_producto_nombre VARCHAR(200),
    p_id_categoria INTEGER,
    p_codigo_barras VARCHAR(50) DEFAULT NULL,
    p_descripcion VARCHAR(500) DEFAULT NULL,
    p_precio_compra NUMERIC(18,2) DEFAULT 0,
    p_precio_venta NUMERIC(18,2) DEFAULT 0,
    p_precio_venta_usd NUMERIC(18,2) DEFAULT NULL,
    p_stock_minimo INTEGER DEFAULT 0,
    p_stock_actual INTEGER DEFAULT 0,
    p_fecha_vencimiento DATE DEFAULT NULL,
    p_lote VARCHAR(50) DEFAULT NULL,
    p_id_proveedor INTEGER DEFAULT NULL,
    p_id_marca INTEGER DEFAULT NULL,
    p_id_presentacion INTEGER DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN 999;
    END IF;
    INSERT INTO cat.productos (
        codigo, producto_nombre, id_categoria, codigo_barras, descripcion,
        precio_compra, precio_venta, precio_venta_usd, stock_minimo, stock_actual,
        fecha_vencimiento, lote, id_proveedor, id_marca, id_presentacion
    )
    VALUES (
        p_codigo, p_producto_nombre, p_id_categoria, p_codigo_barras, p_descripcion,
        p_precio_compra, p_precio_venta, p_precio_venta_usd, p_stock_minimo, p_stock_actual,
        p_fecha_vencimiento, p_lote, p_id_proveedor, p_id_marca, p_id_presentacion
    )
    RETURNING id_producto INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_productos_update(
    p_id_producto INTEGER,
    p_codigo VARCHAR(20) DEFAULT NULL,
    p_codigo_barras VARCHAR(50) DEFAULT NULL,
    p_producto_nombre VARCHAR(200) DEFAULT NULL,
    p_descripcion VARCHAR(500) DEFAULT NULL,
    p_id_categoria INTEGER DEFAULT NULL,
    p_precio_compra NUMERIC(18,2) DEFAULT NULL,
    p_precio_venta NUMERIC(18,2) DEFAULT NULL,
    p_precio_venta_usd NUMERIC(18,2) DEFAULT NULL,
    p_stock_minimo INTEGER DEFAULT NULL,
    p_stock_actual INTEGER DEFAULT NULL,
    p_fecha_vencimiento DATE DEFAULT NULL,
    p_lote VARCHAR(50) DEFAULT NULL,
    p_id_proveedor INTEGER DEFAULT NULL,
    p_id_marca INTEGER DEFAULT NULL,
    p_id_presentacion INTEGER DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;
    UPDATE cat.productos SET
        codigo = COALESCE(p_codigo, codigo),
        codigo_barras = COALESCE(p_codigo_barras, codigo_barras),
        producto_nombre = COALESCE(p_producto_nombre, producto_nombre),
        descripcion = COALESCE(p_descripcion, descripcion),
        id_categoria = COALESCE(p_id_categoria, id_categoria),
        precio_compra = COALESCE(p_precio_compra, precio_compra),
        precio_venta = COALESCE(p_precio_venta, precio_venta),
        precio_venta_usd = COALESCE(p_precio_venta_usd, precio_venta_usd),
        stock_minimo = COALESCE(p_stock_minimo, stock_minimo),
        stock_actual = COALESCE(p_stock_actual, stock_actual),
        fecha_vencimiento = COALESCE(p_fecha_vencimiento, fecha_vencimiento),
        lote = COALESCE(p_lote, lote),
        id_proveedor = COALESCE(p_id_proveedor, id_proveedor),
        id_marca = COALESCE(p_id_marca, id_marca),
        id_presentacion = COALESCE(p_id_presentacion, id_presentacion),
        activo = COALESCE(p_activo, activo),
        fecha_actualiza = CURRENT_TIMESTAMP
    WHERE id_producto = p_id_producto;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cat.f_productos_delete(
    p_id_producto INTEGER,
    p_simulate BOOLEAN DEFAULT false
)
RETURNS BOOLEAN AS $$
BEGIN
    IF seg.f_simulate_check(p_simulate) THEN
        RETURN true;
    END IF;
    DELETE FROM cat.productos WHERE id_producto = p_id_producto;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;
