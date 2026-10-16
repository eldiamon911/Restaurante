CREATE DATABASE IF NOT EXISTS restaurante_gestion;

USE restaurante_gestion;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    usuario    VARCHAR(50)  NOT NULL UNIQUE,
    contra     VARCHAR(250) NOT NULL,
    rol        ENUM('ADMIN', 'MESERA', 'CAJERA') NOT NULL,
    estado     BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(50) NOT NULL UNIQUE,
    descrip      VARCHAR(250),
    estado       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS platos (
    id_plato     INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    descrip      TEXT,
    precio       DECIMAL(10,2) NOT NULL,
    img          VARCHAR(255),
    disponible   BOOLEAN NOT NULL DEFAULT TRUE,
    estado       BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_plato_categoria
        FOREIGN KEY (id_categoria) REFERENCES categorias (id_categoria)
);

CREATE TABLE IF NOT EXISTS ingredientes (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL UNIQUE,
    unidad_medida  VARCHAR(200) NOT NULL,
    cantidadA      DECIMAL(10,3) NOT NULL DEFAULT 0,
    cantidadM      DECIMAL(10,3) NOT NULL DEFAULT 0,
    estado         BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS receta_ingredientes (
    id_receta_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    id_plato              INT NOT NULL,
    id_ingrediente        INT NOT NULL,
    cantidad_utilizada   DECIMAL(10,3) NOT NULL,
    CONSTRAINT fk_receta_plato
        FOREIGN KEY (id_plato) REFERENCES platos (id_plato),
    CONSTRAINT fk_receta_ingrediente
        FOREIGN KEY (id_ingrediente) REFERENCES ingredientes (id_ingrediente),
    CONSTRAINT uk_plato_ingrediente
        UNIQUE (id_plato, id_ingrediente)
);

CREATE TABLE IF NOT EXISTS mesas (
    id_mesa     INT AUTO_INCREMENT PRIMARY KEY,
    numero_mesa INT NOT NULL UNIQUE,
    capacidad   INT NOT NULL,
    estado      ENUM('DISPONIBLE', 'OCUPADA') NOT NULL DEFAULT 'DISPONIBLE'
);

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
);

CREATE TABLE IF NOT EXISTS detalle_pedido (
    id_detalle      INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido       INT NOT NULL,
    id_plato        INT NOT NULL,
    cantidad        INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal        DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedidos (id_pedido),
    CONSTRAINT fk_detalle_plato
        FOREIGN KEY (id_plato) REFERENCES platos (id_plato)
);

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
);

INSERT IGNORE INTO usuarios (nombre, usuario, contra, rol) VALUES
    ('Administrador Principal', 'admin',  '1234', 'ADMIN'),
    ('Mesera Turno',            'mesera', '1234', 'MESERA'),
    ('Cajera Turno',            'cajera', '345',  'CAJERA');

INSERT IGNORE INTO categorias (nombre, descrip) VALUES
    ('Entradas',       'Platos para comenzar'),
    ('Platos Fuertes', 'Platos principales del menu'),
    ('Bebidas',        'Bebidas frias y calientes'),
    ('Postres',        'Dulces y postres');

INSERT IGNORE INTO ingredientes (nombre, unidad_medida, cantidadA, cantidadM) VALUES
    ('Arroz',        'gramos',      5000,  1000),
    ('Pollo',        'gramos',      3000,   800),
    ('Papa',         'gramos',      8000,  1500),
    ('Queso',        'gramos',       350,   500),
    ('Tomate',       'gramos',      2000,   500),
    ('Cebolla',      'gramos',      1800,   500),
    ('Carne de res', 'gramos',      2500,   700),
    ('Harina',       'gramos',      4000,  1000),
    ('Leche',        'mililitros',  3000,   800),
    ('Aceite',       'mililitros',  2000,   500),
    ('Lechuga',      'gramos',       900,   300),
    ('Limon',        'unidades',      40,    10),
    ('Azucar',       'gramos',      3000,   500),
    ('Cafe',         'gramos',      1200,   300),
    ('Agua',         'mililitros', 10000,  2000);

INSERT INTO platos (id_categoria, nombre, descrip, precio, disponible)
SELECT c.id_categoria, 'Ensalada Cesar', 'Lechuga, tomate y queso', 12000, TRUE
FROM categorias c WHERE c.nombre = 'Entradas'
AND NOT EXISTS (SELECT 1 FROM platos p WHERE p.nombre = 'Ensalada Cesar');

INSERT INTO platos (id_categoria, nombre, descrip, precio, disponible)
SELECT c.id_categoria, 'Sopa de Pollo', 'Caldo caliente con pollo', 10000, TRUE
FROM categorias c WHERE c.nombre = 'Entradas'
AND NOT EXISTS (SELECT 1 FROM platos p WHERE p.nombre = 'Sopa de Pollo');

INSERT INTO platos (id_categoria, nombre, descrip, precio, disponible)
SELECT c.id_categoria, 'Pollo con Arroz', 'Pechuga con arroz blanco', 18000, TRUE
FROM categorias c WHERE c.nombre = 'Platos Fuertes'
AND NOT EXISTS (SELECT 1 FROM platos p WHERE p.nombre = 'Pollo con Arroz');

INSERT INTO platos (id_categoria, nombre, descrip, precio, disponible)
SELECT c.id_categoria, 'Carne Bistec', 'Carne de res con papas', 22000, TRUE
FROM categorias c WHERE c.nombre = 'Platos Fuertes'
AND NOT EXISTS (SELECT 1 FROM platos p WHERE p.nombre = 'Carne Bistec');

INSERT INTO platos (id_categoria, nombre, descrip, precio, disponible)
SELECT c.id_categoria, 'Hamburguesa', 'Carne, queso y tomate', 20000, TRUE
FROM categorias c WHERE c.nombre = 'Platos Fuertes'
AND NOT EXISTS (SELECT 1 FROM platos p WHERE p.nombre = 'Hamburguesa');

INSERT INTO platos (id_categoria, nombre, descrip, precio, disponible)
SELECT c.id_categoria, 'Limonada', 'Bebida natural de limon', 6000, TRUE
FROM categorias c WHERE c.nombre = 'Bebidas'
AND NOT EXISTS (SELECT 1 FROM platos p WHERE p.nombre = 'Limonada');

INSERT INTO platos (id_categoria, nombre, descrip, precio, disponible)
SELECT c.id_categoria, 'Cafe', 'Cafe con leche', 4000, TRUE
FROM categorias c WHERE c.nombre = 'Bebidas'
AND NOT EXISTS (SELECT 1 FROM platos p WHERE p.nombre = 'Cafe');

INSERT INTO platos (id_categoria, nombre, descrip, precio, disponible)
SELECT c.id_categoria, 'Agua', 'Botella de agua', 2500, TRUE
FROM categorias c WHERE c.nombre = 'Bebidas'
AND NOT EXISTS (SELECT 1 FROM platos p WHERE p.nombre = 'Agua');

INSERT INTO platos (id_categoria, nombre, descrip, precio, disponible)
SELECT c.id_categoria, 'Torta de Chocolate', 'Porcion de torta', 9000, TRUE
FROM categorias c WHERE c.nombre = 'Postres'
AND NOT EXISTS (SELECT 1 FROM platos p WHERE p.nombre = 'Torta de Chocolate');

INSERT INTO platos (id_categoria, nombre, descrip, precio, disponible)
SELECT c.id_categoria, 'Flan', 'Flan de caramelo', 7000, TRUE
FROM categorias c WHERE c.nombre = 'Postres'
AND NOT EXISTS (SELECT 1 FROM platos p WHERE p.nombre = 'Flan');

INSERT INTO receta_ingredientes (id_plato, id_ingrediente, cantidad_utilizada)
SELECT p.id_plato, i.id_ingrediente, v.cant
FROM (
    SELECT 'Ensalada Cesar' AS plato, 'Lechuga' AS ing, 100 AS cant
    UNION ALL SELECT 'Ensalada Cesar', 'Queso', 30
    UNION ALL SELECT 'Ensalada Cesar', 'Tomate', 50
    UNION ALL SELECT 'Sopa de Pollo', 'Pollo', 150
    UNION ALL SELECT 'Sopa de Pollo', 'Cebolla', 30
    UNION ALL SELECT 'Sopa de Pollo', 'Agua', 300
    UNION ALL SELECT 'Pollo con Arroz', 'Pollo', 200
    UNION ALL SELECT 'Pollo con Arroz', 'Arroz', 150
    UNION ALL SELECT 'Pollo con Arroz', 'Aceite', 10
    UNION ALL SELECT 'Pollo con Arroz', 'Cebolla', 20
    UNION ALL SELECT 'Carne Bistec', 'Carne de res', 250
    UNION ALL SELECT 'Carne Bistec', 'Papa', 150
    UNION ALL SELECT 'Carne Bistec', 'Cebolla', 20
    UNION ALL SELECT 'Carne Bistec', 'Aceite', 10
    UNION ALL SELECT 'Hamburguesa', 'Harina', 80
    UNION ALL SELECT 'Hamburguesa', 'Carne de res', 180
    UNION ALL SELECT 'Hamburguesa', 'Queso', 25
    UNION ALL SELECT 'Hamburguesa', 'Tomate', 30
    UNION ALL SELECT 'Limonada', 'Limon', 3
    UNION ALL SELECT 'Limonada', 'Azucar', 20
    UNION ALL SELECT 'Limonada', 'Agua', 250
    UNION ALL SELECT 'Cafe', 'Cafe', 15
    UNION ALL SELECT 'Cafe', 'Leche', 100
    UNION ALL SELECT 'Cafe', 'Azucar', 10
    UNION ALL SELECT 'Cafe', 'Agua', 150
    UNION ALL SELECT 'Torta de Chocolate', 'Harina', 120
    UNION ALL SELECT 'Torta de Chocolate', 'Leche', 100
    UNION ALL SELECT 'Torta de Chocolate', 'Azucar', 80
    UNION ALL SELECT 'Flan', 'Leche', 150
    UNION ALL SELECT 'Flan', 'Azucar', 60
) AS v
JOIN platos p ON p.nombre = v.plato
JOIN ingredientes i ON i.nombre = v.ing
WHERE NOT EXISTS (
    SELECT 1 FROM receta_ingredientes r
    WHERE r.id_plato = p.id_plato AND r.id_ingrediente = i.id_ingrediente
);

INSERT IGNORE INTO mesas (numero_mesa, capacidad, estado) VALUES
    (1, 4, 'DISPONIBLE'),
    (2, 4, 'DISPONIBLE'),
    (3, 2, 'DISPONIBLE'),
    (4, 6, 'DISPONIBLE'),
    (5, 2, 'DISPONIBLE'),
    (6, 4, 'DISPONIBLE');
