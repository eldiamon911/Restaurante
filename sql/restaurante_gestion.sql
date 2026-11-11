CREATE DATABASE IF NOT EXISTS restaurante_gestion
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE restaurante_gestion;

-- 1. Tabla de Usuarios (Roles: ADMIN, MESERA, CAJERA)
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    usuario    VARCHAR(50)  NOT NULL UNIQUE,
    contra     VARCHAR(250) NOT NULL,
    rol        ENUM('ADMIN', 'MESERA', 'CAJERA') NOT NULL,
    estado     BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Tabla de Categorías
CREATE TABLE IF NOT EXISTS categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(50) NOT NULL UNIQUE,
    descrip      VARCHAR(250),
    estado       BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Tabla de Platos (Con stock integrado desde el inicio)
CREATE TABLE IF NOT EXISTS platos (
    id_plato     INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    descrip      TEXT,
    precio       DECIMAL(10,2) NOT NULL,
    img          VARCHAR(255),
    stock        INT NOT NULL DEFAULT 0,
    disponible   BOOLEAN NOT NULL DEFAULT TRUE,
    estado       BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_plato_categoria
        FOREIGN KEY (id_categoria) REFERENCES categorias (id_categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Tabla de Ingredientes (Inventario)
CREATE TABLE IF NOT EXISTS ingredientes (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL UNIQUE,
    unidad_medida  VARCHAR(200) NOT NULL,
    cantidadA      DECIMAL(10,3) NOT NULL DEFAULT 0,
    cantidadM      DECIMAL(10,3) NOT NULL DEFAULT 0,
    estado         BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Tabla Relacional de Recetas (Ingredientes por Plato)
CREATE TABLE IF NOT EXISTS receta_ingredientes (
    id_receta_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    id_plato              INT NOT NULL,
    id_ingrediente        INT NOT NULL,
    cantidad_utilizada    DECIMAL(10,3) NOT NULL,
    CONSTRAINT fk_receta_plato
        FOREIGN KEY (id_plato) REFERENCES platos (id_plato),
    CONSTRAINT fk_receta_ingrediente
        FOREIGN KEY (id_ingrediente) REFERENCES ingredientes (id_ingrediente),
    CONSTRAINT uk_plato_ingrediente
        UNIQUE (id_plato, id_ingrediente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Tabla de Mesas
CREATE TABLE IF NOT EXISTS mesas (
    id_mesa     INT AUTO_INCREMENT PRIMARY KEY,
    numero_mesa INT NOT NULL UNIQUE,
    capacidad   INT NOT NULL,
    estado      ENUM('DISPONIBLE', 'OCUPADA') NOT NULL DEFAULT 'DISPONIBLE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Tabla de Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_mesa   INT NOT NULL,
    id_mesera INT NOT NULL,
    fecha     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado    ENUM('PENDIENTE', 'CONFIRMADO', 'PAGADO', 'FINALIZADO', 'CANCELADO')
              NOT NULL DEFAULT 'PENDIENTE',
    total     DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_pedido_mesa
        FOREIGN KEY (id_mesa) REFERENCES mesas (id_mesa),
    CONSTRAINT fk_pedido_mesera
        FOREIGN KEY (id_mesera) REFERENCES usuarios (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Tabla de Detalle de Pedido (Con observación integrada)
CREATE TABLE IF NOT EXISTS detalle_pedido (
    id_detalle      INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido       INT NOT NULL,
    id_plato        INT NOT NULL,
    cantidad        INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal        DECIMAL(10,2) NOT NULL,
    observacion     VARCHAR(255) NULL,
    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido),
    CONSTRAINT fk_detalle_plato
        FOREIGN KEY (id_plato) REFERENCES platos (id_plato)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Tabla de Pagos
CREATE TABLE IF NOT EXISTS pagos (
    id_pago      INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido    INT NOT NULL UNIQUE,
    id_cajera    INT NOT NULL,
    metodo_pago  ENUM('EFECTIVO', 'TARJETA', 'TRANSFERENCIA') NOT NULL,
    valor_pagado DECIMAL(10,2) NOT NULL,
    fecha        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pago_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido),
    CONSTRAINT fk_pago_cajera
        FOREIGN KEY (id_cajera) REFERENCES usuarios (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ========================================================
-- CREACIÓN DE VISTAS (VIEWS) PARA REPORTES LIMPIOS EN JAVA
-- ========================================================

-- Vista para ver detalles completos de los pedidos (Ideal para reportes de consumo)
CREATE OR REPLACE VIEW vw_detalle_pedidos_completo AS
SELECT 
    dp.id_detalle,
    p.id_pedido,
    pl.nombre AS plato,
    dp.cantidad,
    dp.precio_unitario,
    dp.subtotal,
    dp.observacion,
    me.numero_mesa,
    p.fecha,
    u.nombre AS mesera,
    p.estado AS estado_pedido
FROM detalle_pedido dp
JOIN pedidos p  ON dp.id_pedido = p.id_pedido
JOIN platos pl  ON dp.id_plato  = pl.id_plato
JOIN mesas me   ON p.id_mesa    = me.id_mesa
JOIN usuarios u ON p.id_mesera  = u.id_usuario;

-- Vista para control de inventario crítico (Stock bajo que requiere alerta)
CREATE OR REPLACE VIEW vw_inventario_critico AS
SELECT 
    id_ingrediente,
    nombre,
    unidad_medida,
    cantidadA AS cantidad_actual,
    cantidadM AS cantidad_minima,
    CASE 
        WHEN cantidadA <= cantidadM THEN 'CRITICO / ALERTA'
        ELSE 'ESTABLE'
    END AS estado_stock
FROM ingredientes;

-- Vista para consolidado de pagos y ventas por cajera
CREATE OR REPLACE VIEW vw_reporte_pagos AS
SELECT 
    pa.id_pago,
    pa.id_pedido,
    u.nombre AS cajera,
    pa.metodo_pago,
    pa.valor_pagado,
    pa.fecha
FROM pagos pa
JOIN usuarios u ON pa.id_cajera = u.id_usuario;


-- ========================================================
-- INSERCIÓN DE DATOS DE PRUEBA (SEEDERS)
-- ========================================================

INSERT IGNORE INTO usuarios (nombre, usuario, contra, rol) VALUES
    ('Administrador Principal', 'admin',  '1234', 'ADMIN'),
    ('Mesera Turno',            'mesera', '1234', 'MESERA'),
    ('Cajera Turno',            'cajera', '345',  'CAJERA');

INSERT IGNORE INTO categorias (nombre, descrip) VALUES 
('Platos Fuertes', 'Platos tradicionales y principales'),
('Comidas Rápidas', 'Hamburguesas, perros y fritos'),
('Entradas y Acompañamientos', 'Porciones y entradas típicas'),
('Bebidas', 'Jugos naturales, limonadas y cervezas'),
('Postres', 'Postres caseros de la casa');

INSERT IGNORE INTO platos (id_categoria, nombre, descrip, precio, stock, disponible, estado) VALUES 
((SELECT id_categoria FROM categorias WHERE nombre='Platos Fuertes'), 'Bandeja Paisa', 'Frijoles, chicharrón, carne molida, huevo, tajada, aguacate y arroz', 35000.00, 10, 1, 1),
((SELECT id_categoria FROM categorias WHERE nombre='Platos Fuertes'), 'Ajiaco Santafereño', 'Sopa tradicional con tres tipos de papa, pollo, mazorca y crema de leche', 28000.00, 10, 1, 1),
((SELECT id_categoria FROM categorias WHERE nombre='Comidas Rápidas'), 'Perro Caliente Especial', 'Salchicha suiza, queso mozzarella, tocineta y ripio de papa', 16000.00, 15, 1, 1),
((SELECT id_categoria FROM categorias WHERE nombre='Bebidas'), 'Limonada Cerezada', 'Limonada natural frapeada con toque de cereza', 9500.00, 30, 1, 1),
((SELECT id_categoria FROM categorias WHERE nombre='Postres'), 'Tres Leches', 'Bizcocho húmedo bañado en tres leches', 10500.00, 8, 1, 1);

INSERT IGNORE INTO ingredientes (nombre, unidad_medida, cantidadA, cantidadM) VALUES 
('Pechuga de Pollo', 'kg', 20.000, 4.000),
('Chicharrón de Cerdo', 'kg', 15.000, 3.000),
('Arroz Blanco', 'kg', 50.000, 10.000),
('Papa Pastusa', 'kg', 60.000, 10.000),
('Leche', 'litros', 40.000, 10.000);

INSERT IGNORE INTO mesas (numero_mesa, capacidad) VALUES
(1,4), (2,4), (3,2), (4,6), (5,4);

-- Insertar pedidos de prueba históricos
INSERT IGNORE INTO pedidos (id_pedido, id_mesa, id_mesera, fecha, estado, total) VALUES
(1, (SELECT id_mesa FROM mesas WHERE numero_mesa=1), (SELECT id_usuario FROM usuarios WHERE usuario='mesera'), '2026-10-10 12:30:00', 'PAGADO', 44500),
(2, (SELECT id_mesa FROM mesas WHERE numero_mesa=2), (SELECT id_usuario FROM usuarios WHERE usuario='mesera'), '2026-10-11 13:00:00', 'PAGADO', 28000);

INSERT IGNORE INTO detalle_pedido (id_pedido, id_plato, cantidad, precio_unitario, subtotal, observacion) VALUES
(1, (SELECT id_plato FROM platos WHERE nombre='Bandeja Paisa'), 1, 35000, 35000, 'Sin aguacate'),
(1, (SELECT id_plato FROM platos WHERE nombre='Limonada Cerezada'), 1, 9500, 9500, 'Menos dulce'),
(2, (SELECT id_plato FROM platos WHERE nombre='Ajiaco Santafereño'), 1, 28000, 28000, 'Sin crema de leche');

INSERT IGNORE INTO pagos (id_pedido, id_cajera, metodo_pago, valor_pagado, fecha) VALUES
(1, (SELECT id_usuario FROM usuarios WHERE usuario='cajera'), 'EFECTIVO', 50000, '2026-10-10 12:45:00'),
(2, (SELECT id_usuario FROM usuarios WHERE usuario='cajera'), 'TARJETA', 28000, '2026-10-11 13:15:00');

DELIMITER //

CREATE TRIGGER trg_descontar_inventario_pago
AFTER INSERT ON pagos
FOR EACH ROW
BEGIN
    -- Descuenta automáticamente los ingredientes según los platos del pedido pagado
    UPDATE ingredientes i
    JOIN receta_ingredientes ri ON i.id_ingrediente = ri.id_ingrediente
    JOIN detalle_pedido dp ON ri.id_plato = dp.id_plato
    SET i.cantidadA = i.cantidadA - (ri.cantidad_utilizada * dp.cantidad)
    WHERE dp.id_pedido = NEW.id_pedido;
END//

DELIMITER ;
