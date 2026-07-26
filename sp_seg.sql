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
