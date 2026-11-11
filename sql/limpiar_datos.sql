USE restaurante_gestion;

SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM pagos;
DELETE FROM detalle_pedido;
DELETE FROM pedidos;
DELETE FROM receta_ingredientes;
DELETE FROM platos;
DELETE FROM categorias;
DELETE FROM mesas;
DELETE FROM ingredientes;

ALTER TABLE pagos               AUTO_INCREMENT = 1;
ALTER TABLE detalle_pedido      AUTO_INCREMENT = 1;
ALTER TABLE pedidos             AUTO_INCREMENT = 1;
ALTER TABLE receta_ingredientes AUTO_INCREMENT = 1;
ALTER TABLE platos              AUTO_INCREMENT = 1;
ALTER TABLE categorias          AUTO_INCREMENT = 1;
ALTER TABLE mesas               AUTO_INCREMENT = 1;
ALTER TABLE ingredientes        AUTO_INCREMENT = 1;

SET FOREIGN_KEY_CHECKS = 1;
