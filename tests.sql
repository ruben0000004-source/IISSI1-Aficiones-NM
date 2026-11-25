-- 
-- Autor: David Ruiz
-- Fecha: Octubre de 2026
-- Descripción: Tests negativos para la BD de Aficiones Dinámicas
-- 
USE hobbies_nm_db;

-- =============================================================
-- TABLA DE RESULTADOS
-- =============================================================
CREATE OR REPLACE TABLE test_results (
    test_id VARCHAR(20) PRIMARY KEY,
    test_name VARCHAR(200) NOT NULL,
    test_message VARCHAR(500) NOT NULL,
    test_status ENUM('PASS','FAIL') NOT NULL,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================
-- PROCEDIMIENTO AUXILIAR
-- =============================================================
DELIMITER //
CREATE OR REPLACE PROCEDURE p_log_test(
    IN p_test_id VARCHAR(20),
    IN p_message VARCHAR(500),
    IN p_status ENUM('PASS','FAIL')
)
BEGIN
    INSERT INTO test_results(test_id, test_name, test_message, test_status)
    VALUES (p_test_id, SUBSTRING_INDEX(p_message, ':', 1), p_message, p_status);
END //
DELIMITER ;

-- =============================================================
-- TESTS (RN01 - RN03)
-- =============================================================

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn01_age_adult()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN01', 'RN01: Edad mínima 18 años', 'PASS');

    CALL p_populate();

    INSERT INTO users (full_name, gender, age, email)
        VALUES ('Usuario Menor', 'MASCULINO', 17, 'menor@ejemplo.com');

    CALL p_log_test('RN01', 'ERROR: Se permitió un usuario menor de edad', 'FAIL');
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn02_unique_email()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN02', 'RN02: Email debe ser único', 'PASS');

    CALL p_populate();

    INSERT INTO users (full_name, gender, age, email)
        VALUES ('Correo Duplicado', 'FEMENINO', 30, 'druiz@us.es');

    CALL p_log_test('RN02', 'ERROR: Se permitió duplicar un email', 'FAIL');
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn03_unique_hobby_per_user()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN03', 'RN03: No se pueden repetir aficiones por usuario', 'PASS');

    CALL p_populate();

    INSERT INTO users_hobbies (user_id, hobby_id) VALUES (1, 3);

    CALL p_log_test('RN03', 'ERROR: Se permitió repetir afición para el mismo usuario', 'FAIL');
END //
DELIMITER ;


-- =============================================================
-- RA01, RA02, RA03, RA04
-- =============================================================

DELIMITER //

CREATE OR REPLACE PROCEDURE p_test_ra01()
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		CALL p_log_test('RA01', 'RA01: Horas semanales entre 1 y 20', 'PASS');
		
	CALL p_populate();
	
	INSERT INTO users_hobbies (user_id, hobby_id, horas_semanales, nivel)
		VALUES (6, 1, 21, 'PRINCIPIANTE');
	
	CALL p_log_test('RA01', 'ERROR: Se permitieron más de 20 horas semanales', 'FAIL');

END //
DELIMITER ;


DELIMITER //

CREATE OR REPLACE PROCEDURE p_test_ra02()
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		CALL p_log_test('RA02', 'RA02: Nivel EXPERTO requiere al menos 5 horas', 'PASS');
		
	CALL p_populate();
	
	INSERT INTO users_hobbies (user_id, hobby_id, horas_semanales, nivel)
		VALUES (6, 1, 4, 'EXPERTO');
	
	CALL p_log_test('RA02', 'ERROR: Se permitieron nivel EXPERTO con menos de 5 horas', 'FAIL');

END //
DELIMITER ;


DELIMITER //

CREATE OR REPLACE PROCEDURE p_test_ra03()
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		CALL p_log_test('RA03', 'RA03: Máximo de 30 horas semanales en total por usuario', 'PASS');
		
	CALL p_populate();
	
	INSERT INTO users_hobbies (user_id, hobby_id, horas_semanales, nivel)
		VALUES (4, 3, 1, 'PRINCIPIANTE');
	
	CALL p_log_test('RA03', 'ERROR: Se permitió superar las 30 horas semanales totales', 'FAIL');

END //
DELIMITER ;


DELIMITER //

CREATE OR REPLACE PROCEDURE p_test_ra04()
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		CALL p_log_test('RA04', 'RA04: Máximo de 2 aficiones en EXPERTO por usuario', 'PASS');
		
	CALL p_populate();
	
	INSERT INTO users_hobbies (user_id, hobby_id, horas_semanales, nivel)
		VALUES (2, 4, 5, 'EXPERTO');
	
	CALL p_log_test('RA04', 'ERROR: Se permitió ser EXPERTO en más de 2 aficiones', 'FAIL');

END //
DELIMITER ;

-- =============================================================
-- ORQUESTADOR
-- =============================================================
DELIMITER //
CREATE OR REPLACE PROCEDURE p_run_tests()
BEGIN
    DELETE FROM test_results;

    CALL p_test_rn01_age_adult();
    CALL p_test_rn02_unique_email();
    CALL p_test_rn03_unique_hobby_per_user();
    CALL p_test_ra01();
    CALL p_test_ra02();
    CALL p_test_ra03();
    CALL p_test_ra04();
								
    SELECT * FROM test_results ORDER BY execution_time, test_id;
    SELECT test_status, COUNT(*) AS total FROM test_results GROUP BY test_status;
END //
DELIMITER ;

CALL p_run_tests();
