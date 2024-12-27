create database tienda_online;
use tienda_online;
create table clientes(
	clienteid int auto_increment primary key,
    nombre varchar(100) not null,
    apellido varchar(100) not null,
    email varchar(100) unique,
	telefono varchar(100),
    fecha_registro date
);
create table productos(
	productoid int auto_increment primary key,
    nombre varchar(100) not null,
    precio decimal(10,2) not null check(precio>0) ,
    stock int not null check(stock>=0),
    unique(nombre)
);
create table pedidos(
	pedidoid int auto_increment primary key,
    clienteid int,
    fecha_pedido date,
    total int,
    foreign key (clienteid) references clientes(clienteid)
);
create table detalles_pedido(
	detalles_pedidoid int auto_increment primary key,
    pedidoid int,
    cantidad int,
    precio_unitario decimal(10,2) not null check(precio_unitario>0),
    foreign key (pedidoid) references pedidos(pedidoid)
);
-- Ingreso de registros
insert into clientes (nombre,apellido,email,telefono,fecha_registro)
values				 ("Daniel","Guzman","dg@gmail.com","0984352134","2020-01-15"),
					 ("Carlos","Endara","ce@gmail.com","0975434567","2020-03-15"),
                     ("Gabriel","Beltran","gb@gmail.com","0983657689","2021-04-15");

insert into productos (nombre,precio,stock)
values				 ("Ropa",25.50,50),
					 ("Celulares",150.75,80),
                     ("Laoptos",400.25,100);

insert into pedidos (clienteid,fecha_pedido,total)
values				 (2,"2024-12-15",10),
					 (3,"2024-11-30",5),
                     (1,"2024-10-15",12);

insert into detalles_pedido(pedidoid,cantidad,precio_unitario)
values				 (1,5,25.50),
					 (2,10,150.75),
                     (3,6,400.25);
                     
-- Insertar un nuevo cliente
DELIMITER $$

CREATE PROCEDURE insertar_cliente(
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_email VARCHAR(255),
    IN p_telefono VARCHAR(15)
)
BEGIN
    INSERT INTO clientes (nombre, apellido, email, telefono)
    VALUES (p_nombre, p_apellido, p_email, p_telefono);
END $$

DELIMITER ;
-- Actualizar datos
DELIMITER $$

CREATE PROCEDURE actualizar_cliente(
    IN p_clienteid INT,
    IN p_nombre VARCHAR(100),
    IN p_apellido VARCHAR(100),
    IN p_email VARCHAR(255),
    IN p_telefono VARCHAR(15)
)
BEGIN
    UPDATE clientes
    SET nombre = p_nombre,
        apellido = p_apellido,
        email = p_email,
        telefono = p_telefono
    WHERE clienteid = p_clienteid;
END $$

DELIMITER ;

-- Obtener nombre completo
DELIMITER $$

CREATE FUNCTION obtener_nombre_completo(clienteid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE nombre_completo VARCHAR(255);
    SELECT CONCAT(nombre, ' ', apellido) INTO nombre_completo
    FROM clientes
    WHERE id_cliente = cliente_id;
    RETURN nombre_completo;
END $$
DELIMITER ;

-- Mostrar 
SELECT obtener_nombre_completo(3);

-- Función para calcular el descuento de un producto
DELIMITER $$

CREATE FUNCTION calcular_descuento(precio DECIMAL(10, 2), descuento DECIMAL(5, 2)) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE precio_con_descuento DECIMAL(10, 2);
    
    -- Calcular el precio con el descuento aplicado
    SET precio_con_descuento = precio - (precio * descuento / 100);
    
    -- Retornar el precio con descuento
    RETURN precio_con_descuento;
END $$

DELIMITER ;
SELECT calcular_descuento(100, 15);

-- Calcular el total de un pedido
DELIMITER $$
CREATE FUNCTION calcular_total_pedido(pedidoid INT) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10, 2);
    -- Calcular el total del pedido (precio * cantidad)
    SELECT SUM(p.precio * dp.cantidad) 
    INTO total
    FROM detalle_pedido dp
    JOIN productos p ON dp.productoid = p.productoid
    WHERE dp.pedido_id = pedido_id;
    -- Retornar el total calculado
    RETURN total;
END $$

DELIMITER ;
-- Mostrar
SELECT calcular_total_pedido(1);

-- Verificar la disponibilidad en stock
DELIMITER $$
CREATE FUNCTION verificar_stock(producto_id INT, cantidad INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE stock_disponible INT;
    -- Obtener el stock disponible del producto
    SELECT stock INTO stock_disponible
    FROM productos
    WHERE productoid = producto_id;
    -- Verificar si el stock disponible es suficiente
    IF stock_disponible >= cantidad THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END $$
DELIMITER ;
-- Mostrar
SELECT verificar_stock(1, 10);
-- Calcular la antiguedad de un cliente
DELIMITER $$
CREATE FUNCTION calcular_antiguedad(clienteid INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE fecha_registro DATE;
    DECLARE antiguedad INT;

    -- Obtener la fecha de registro del cliente
    SELECT fecha_registro INTO fecha_registro
    FROM clientes
    WHERE cliente_id = cliente_id;
    -- Calcular la antigüedad en años
    SET antiguedad = TIMESTAMPDIFF(YEAR, fecha_registro, CURDATE());
    -- Retornar la antigüedad calculada
    RETURN antiguedad;
END $$
DELIMITER ;
-- Mostar
SELECT calcular_antiguedad(1);
-- Consulta para obtener el nombre completo de un cliente
SELECT CONCAT(nombre, ' ', apellido) AS nombre_completo
FROM clientes
WHERE clienteid = 4;
-- Calcular el descuento de un procducto
SELECT precio, (precio - (precio * 0.10)) AS precio_con_descuento
FROM productos
WHERE productoid =2;
-- Calcular el total de un pedido
SELECT SUM(p.precio * dp.cantidad) AS total_pedido
FROM detalles_pedido dp
JOIN productos p ON dp.pedidoid = p.productoid
WHERE dp.pedidoid = 3;
-- Si un producto tiene la cantidad solicitada
SELECT 
    CASE 
        WHEN stock >= 50 THEN 'Suficiente stock'
        ELSE 'Stock insuficiente'
    END AS disponibilidad
FROM productos
WHERE productoid = 3;

                     
select * from detalles_pedido;
select * from pedidos;                     
select *from productos;