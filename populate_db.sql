--
-- Autor: David Ruiz
-- Fecha: Octubre de 2026
-- Descripción: Procedimiento para poblar la BD de Aficiones Dinámicas
--
USE hobbies_nm_db;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_populate()
BEGIN
    DELETE FROM users_hobbies;
    DELETE FROM hobbies;
    DELETE FROM users;

    ALTER TABLE users AUTO_INCREMENT = 1;
    INSERT INTO users (full_name, gender, age, email) VALUES
        ('David Ruiz', 'MASCULINO', 45, 'druiz@us.es'),
        ('Carlos Arévalo', 'MASCULINO', 58, 'carevalo@us.es'),
        ('Margarita Cruz', 'FEMENINO', 58, 'mcruz@us.es'),
        ('Inma Hernández', 'FEMENINO', 35, 'inmahernandez@us.es'),
        ('Alfonso Márquez', 'MASCULINO', 35, 'amarquez@us.es'),
        ('Daniel Ayala', 'MASCULINO', 28, 'dayala1@us.es'),
        ('Raquel Sampedro', 'FEMENINO', 55, 'rsampedro@gmail.com'),
        ('Marta López', 'FEMENINO', 18, 'mlopez@mail.com'),
        ('David Ruiz', 'MASCULINO', 25, 'druiz@mail.com');

    INSERT INTO users (full_name, age, email)
        VALUES ('Andrea Gómez', 27, 'agomez@mail.es');

    INSERT INTO users (full_name, gender, age, email)
        VALUES ('Ernesto Murillo', 'OTRO', 55, 'emurillo@correo.es');

    ALTER TABLE hobbies AUTO_INCREMENT = 1;
    INSERT INTO hobbies (hobby_name) VALUES
        ('Cine'),
        ('Deporte'),
        ('Jugar al fútbol'),
        ('Hacer senderismo'),
        ('Montar a caballo');

    ALTER TABLE users_hobbies AUTO_INCREMENT = 1;
    INSERT INTO users_hobbies (user_id, hobby_id, horas_semanales, nivel) VALUES
        (1,3, 10, 'EXPERTO'),
		  (1,4, 5, 'INTERMEDIO'),
        (2,3, 8, 'EXPERTO'),
		  (2,1, 6, 'EXPERTO'),
		  (2,2, 4, 'INTERMEDIO'),
        (4,4, 8, 'PRINCIPIANTE'),
		  (4,2, 15, 'EXPERTO'),
		  (4,1, 7, 'PRINCIPIANTE'),
        (5,3, 18, 'EXPERTO'),
        (6,2, 2, 'PRINCIPIANTE'),
        (8,3, 5, 'EXPERTO'),
		  (8,4, 5, 'EXPERTO'),
		  (8,1, 2, 'INTERMEDIO'),
		  (8,2, 2, 'INTERMEDIO'),
        (9,3, 5, 'EXPERTO'),
		  (9,1, 2, 'INTERMEDIO'),
		  (9,2, 2, 'PRINCIPIANTE'),
        (10,4, 5, 'EXPERTO'),
        (11,5, 2, 'PRINCIPIANTE'),
        (8,5, 2, 'PRINCIPIANTE');
END //
DELIMITER ;

CALL p_populate();
