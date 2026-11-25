--
-- Autor: David Ruiz
-- Fecha: Octubre de 2026
-- Descripción: Script para crear la BD de Aficiones Dinámicas
--

DROP DATABASE IF EXISTS hobbies_nm_db;
CREATE DATABASE hobbies_nm_db;
USE hobbies_nm_db;

-- =============================================================
-- Se eliminan las tablas previas
-- =============================================================
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS users_hobbies;
DROP TABLE IF EXISTS hobbies;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================
-- Tabla: users
-- =============================================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT,
    full_name VARCHAR(64) NOT NULL,
    gender ENUM('MASCULINO','FEMENINO','OTRO') NULL,
    age TINYINT NOT NULL,
    email VARCHAR(255) NOT NULL,
    PRIMARY KEY (user_id),
    CONSTRAINT ck_users_rn01_adult_age CHECK (age >= 18),
    CONSTRAINT uq_users_rn02_email UNIQUE (email)
);

-- =============================================================
-- Tabla: hobbies
-- =============================================================
CREATE TABLE hobbies (
    hobby_id INT AUTO_INCREMENT,
    hobby_name VARCHAR(128) NOT NULL,
    PRIMARY KEY (hobby_id)
);

-- =============================================================
-- Tabla: users_hobbies
-- =============================================================
CREATE TABLE users_hobbies (
    user_hobby_id INT AUTO_INCREMENT,
    user_id INT NOT NULL,
    hobby_id INT NOT NULL,
    
    -- Parámetros necesarios para crear RA01 y RA02
    
    horas_semanales INT NOT NULL,
    nivel ENUM('PRINCIPIANTE', 'INTERMEDIO', 'EXPERTO') NOT NULL,
    
    PRIMARY KEY (user_hobby_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (hobby_id) REFERENCES hobbies(hobby_id),
    CONSTRAINT uq_users_hobbies_rn03 UNIQUE (user_id, hobby_id),
    
    -- RA01 y RA02
    CONSTRAINT ck_users_hobbies_ra01 CHECK (horas_semanales BETWEEN 1 AND 20),
    CONSTRAINT ck_users_hobbies_ra02 CHECK (nivel IN ('PRINCIPIANTE', 'INTERMEDIO') OR horas_semanales >= 5) 
    
);


-- RA03 y RA04

DELIMITER //

CREATE OR REPLACE TRIGGER t_ra03_ra04
BEFORE INSERT OR UPDATE ON users_hobbies
FOR EACH ROW
BEGIN
	DECLARE v_horas_totales INT;
	DECLARE v_contador_experto INT;
	
	-- RA04
	
	IF NEW.nivel = 'EXPERTO' THEN
		SELECT COUNT(*) INTO v_contador_experto
		FROM users_hobbies uh
		WHERE uh.user_id = NEW.user_id AND uh.nivel = 'EXPERTO' AND NOT (uh.user_hobby_id <=> OLD.user_hobby_id);
		
		IF v_contador_experto >= 2 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'RA04: Un usuario no es experto en más de 2 aficiones';
		END IF;
	END IF;
	
	-- RA03
	
	SELECT SUM(uh.horas_semanales) INTO v_horas_totales
	FROM user_hobbies uh
	WHERE uh.user_id = NEW.user_id AND NOT (uh.user_hobby_id <=> OLD.user_hobby_id);
	
	IF (v_horas_totales + NEW.horas_semanales) > 30 THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'RA03: Un usuario no dedica más de 30 horas a la semana al total de sus aficiones';
	END IF;

END //
DELIMITER ;
