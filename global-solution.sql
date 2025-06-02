-- Daniel da Silva Barros   | RM 556152
-- Luccas de Alencar Rufino | RM 558253

SET VERIFY OFF;
SET SERVEROUTPUT ON;

-- ==================================
-- REMOVER TABELAS 
-- ==================================
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE LeituraSensor CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE OcorrenciaColaborativa CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE LocalizacaoUsuario CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Alerta CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE RotasSeguras CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Abrigo CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Sensor CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Usuario CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Tabelas ainda não existiam ou foram removidas');
END;
/

-- ======================
-- 1. CRIAÇÃO DAS TABELAS
-- ======================
CREATE TABLE Usuario (
    id_usuario NUMBER PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    senha VARCHAR2(200) NOT NULL,
    data_cadastro DATE DEFAULT SYSDATE
);

CREATE TABLE LocalizacaoUsuario (
    id_localizacao NUMBER PRIMARY KEY,
    id_usuario NUMBER NOT NULL,
    latitude NUMBER(10,6) NOT NULL,
    longitude NUMBER(10,6) NOT NULL,
    data_hora_registro TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Alerta (
    id_alerta NUMBER PRIMARY KEY,
    id_usuario NUMBER NOT NULL,
    tipo_evento VARCHAR2(50) NOT NULL,
    nivel_alerta VARCHAR2(20) CHECK (nivel_alerta IN ('informativo', 'atenção', 'perigo')),
    mensagem VARCHAR2(255),
    latitude NUMBER(10,6),
    longitude NUMBER(10,6),
    data_emissao TIMESTAMP DEFAULT SYSTIMESTAMP,
    status VARCHAR2(20) CHECK (status IN ('ativo', 'resolvido', 'expirado')),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Abrigo (
    id_abrigo NUMBER PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    endereco VARCHAR2(200),
    latitude NUMBER(10,6),
    longitude NUMBER(10,6),
    capacidade_max NUMBER,
    disponibilidade_atual NUMBER,
    contato VARCHAR2(50)
);

CREATE TABLE RotasSeguras (
    id_rota NUMBER PRIMARY KEY,
    id_usuario NUMBER NOT NULL,
    id_abrigo_destino NUMBER NOT NULL,
    origem_latitude NUMBER(10,6),
    origem_longitude NUMBER(10,6),
    destino_latitude NUMBER(10,6),
    destino_longitude NUMBER(10,6),
    tipo_rota VARCHAR2(50),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    FOREIGN KEY (id_abrigo_destino) REFERENCES Abrigo(id_abrigo)
);

CREATE TABLE Sensor (
    id_sensor NUMBER PRIMARY KEY,
    tipo_sensor VARCHAR2(50),
    localizacao_lat NUMBER(10,6),
    localizacao_long NUMBER(10,6),
    status VARCHAR2(20) CHECK (status IN ('ativo', 'inativo', 'manutenção')),
    data_instalacao DATE
);

CREATE TABLE LeituraSensor (
    id_leitura NUMBER PRIMARY KEY,
    id_sensor NUMBER NOT NULL,
    valor_lido NUMBER NOT NULL,
    data_hora TIMESTAMP DEFAULT SYSTIMESTAMP,
    unidade_medida VARCHAR2(20),
    FOREIGN KEY (id_sensor) REFERENCES Sensor(id_sensor)
);

CREATE TABLE OcorrenciaColaborativa (
    id_ocorrencia NUMBER PRIMARY KEY,
    id_usuario NUMBER NOT NULL,
    tipo_ocorrencia VARCHAR2(100),
    descricao VARCHAR2(255),
    latitude NUMBER(10,6),
    longitude NUMBER(10,6),
    data_envio TIMESTAMP DEFAULT SYSTIMESTAMP,
    status VARCHAR2(20) CHECK (status IN ('pendente', 'confirmada', 'ignorada')),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

-- =========================
-- 2. FUNÇÕES DML POR TABELA
-- =========================

-- Tabela Usuario
CREATE OR REPLACE FUNCTION inserir_usuario(p_id NUMBER, p_nome VARCHAR2, p_email VARCHAR2, p_senha VARCHAR2)
RETURN NUMBER AS BEGIN
  INSERT INTO Usuario (id_usuario, nome, email, senha) VALUES (p_id, p_nome, p_email, p_senha);
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION atualizar_usuario(p_id NUMBER, p_nome VARCHAR2, p_email VARCHAR2)
RETURN NUMBER AS BEGIN
  UPDATE Usuario SET nome = p_nome, email = p_email WHERE id_usuario = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION excluir_usuario(p_id NUMBER)
RETURN NUMBER AS BEGIN
  DELETE FROM Usuario WHERE id_usuario = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

-- Tabela LocalizacaoUsuario
CREATE OR REPLACE FUNCTION inserir_localizacao(p_id NUMBER, p_usuario NUMBER, p_lat NUMBER, p_long NUMBER)
RETURN NUMBER AS BEGIN
  INSERT INTO LocalizacaoUsuario (id_localizacao, id_usuario, latitude, longitude) VALUES (p_id, p_usuario, p_lat, p_long);
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION atualizar_localizacao(p_id NUMBER, p_lat NUMBER, p_long NUMBER)
RETURN NUMBER AS BEGIN
  UPDATE LocalizacaoUsuario SET latitude = p_lat, longitude = p_long WHERE id_localizacao = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION excluir_localizacao(p_id NUMBER)
RETURN NUMBER AS BEGIN
  DELETE FROM LocalizacaoUsuario WHERE id_localizacao = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

-- Tabela Alerta
CREATE OR REPLACE FUNCTION inserir_alerta(
    p_id NUMBER, p_usuario NUMBER, p_tipo VARCHAR2, p_nivel VARCHAR2, p_msg VARCHAR2, 
    p_lat NUMBER, p_long NUMBER, p_status VARCHAR2
) RETURN NUMBER AS BEGIN
  INSERT INTO Alerta(id_alerta, id_usuario, tipo_evento, nivel_alerta, mensagem, latitude, longitude, status) 
  VALUES (p_id, p_usuario, p_tipo, p_nivel, p_msg, p_lat, p_long, p_status);
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION atualizar_alerta(
    p_id NUMBER, p_tipo VARCHAR2, p_nivel VARCHAR2, p_msg VARCHAR2, p_status VARCHAR2
) RETURN NUMBER AS BEGIN
  UPDATE Alerta 
  SET tipo_evento = p_tipo, nivel_alerta = p_nivel, mensagem = p_msg, status = p_status
  WHERE id_alerta = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION excluir_alerta(p_id NUMBER)
RETURN NUMBER AS BEGIN
  DELETE FROM Alerta WHERE id_alerta = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

-- Tabela Abrigo
CREATE OR REPLACE FUNCTION inserir_abrigo(
    p_id NUMBER, p_nome VARCHAR2, p_endereco VARCHAR2, p_lat NUMBER, p_long NUMBER, 
    p_cap_max NUMBER, p_disp_atual NUMBER, p_contato VARCHAR2
) RETURN NUMBER AS BEGIN
  INSERT INTO Abrigo(id_abrigo, nome, endereco, latitude, longitude, capacidade_max, disponibilidade_atual, contato)
  VALUES (p_id, p_nome, p_endereco, p_lat, p_long, p_cap_max, p_disp_atual, p_contato);
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION atualizar_abrigo(
    p_id NUMBER, p_disp_atual NUMBER
) RETURN NUMBER AS BEGIN
  UPDATE Abrigo SET disponibilidade_atual = p_disp_atual WHERE id_abrigo = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION excluir_abrigo(p_id NUMBER)
RETURN NUMBER AS BEGIN
  DELETE FROM Abrigo WHERE id_abrigo = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

-- Tabela RotasSeguras
CREATE OR REPLACE FUNCTION inserir_rota(
    p_id NUMBER, p_usuario NUMBER, p_abrigo NUMBER, p_orig_lat NUMBER, p_orig_long NUMBER, 
    p_dest_lat NUMBER, p_dest_long NUMBER, p_tipo VARCHAR2
) RETURN NUMBER AS BEGIN
  INSERT INTO RotasSeguras(id_rota, id_usuario, id_abrigo_destino, origem_latitude, origem_longitude, destino_latitude, destino_longitude, tipo_rota)
  VALUES (p_id, p_usuario, p_abrigo, p_orig_lat, p_orig_long, p_dest_lat, p_dest_long, p_tipo);
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION atualizar_rota(
    p_id NUMBER, p_dest_lat NUMBER, p_dest_long NUMBER
) RETURN NUMBER AS BEGIN
  UPDATE RotasSeguras 
  SET destino_latitude = p_dest_lat, destino_longitude = p_dest_long 
  WHERE id_rota = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION excluir_rota(p_id NUMBER)
RETURN NUMBER AS BEGIN
  DELETE FROM RotasSeguras WHERE id_rota = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

-- Tabela Sensor
CREATE OR REPLACE FUNCTION inserir_sensor(
    p_id NUMBER, p_tipo VARCHAR2, p_lat NUMBER, p_long NUMBER, p_status VARCHAR2, p_data DATE
) RETURN NUMBER AS BEGIN
  INSERT INTO Sensor(id_sensor, tipo_sensor, localizacao_lat, localizacao_long, status, data_instalacao)
  VALUES (p_id, p_tipo, p_lat, p_long, p_status, p_data);
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION atualizar_sensor_status(p_id NUMBER, p_status VARCHAR2)
RETURN NUMBER AS BEGIN
  UPDATE Sensor SET status = p_status WHERE id_sensor = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION excluir_sensor(p_id NUMBER)
RETURN NUMBER AS BEGIN
  DELETE FROM Sensor WHERE id_sensor = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

-- Tabela LeituraSensor
CREATE OR REPLACE FUNCTION inserir_leitura(
    p_id NUMBER, p_sensor NUMBER, p_valor NUMBER, p_unidade VARCHAR2
) RETURN NUMBER AS BEGIN
  INSERT INTO LeituraSensor(id_leitura, id_sensor, valor_lido, unidade_medida)
  VALUES (p_id, p_sensor, p_valor, p_unidade);
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION atualizar_leitura(p_id NUMBER, p_valor NUMBER)
RETURN NUMBER AS BEGIN
  UPDATE LeituraSensor SET valor_lido = p_valor WHERE id_leitura = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION excluir_leitura(p_id NUMBER)
RETURN NUMBER AS BEGIN
  DELETE FROM LeituraSensor WHERE id_leitura = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

-- Tabela OcorrenciaColaborativa
CREATE OR REPLACE FUNCTION inserir_ocorrencia(
    p_id NUMBER, p_usuario NUMBER, p_tipo VARCHAR2, p_desc VARCHAR2, p_lat NUMBER, p_long NUMBER, p_status VARCHAR2
) RETURN NUMBER AS BEGIN
  INSERT INTO OcorrenciaColaborativa(id_ocorrencia, id_usuario, tipo_ocorrencia, descricao, latitude, longitude, status)
  VALUES (p_id, p_usuario, p_tipo, p_desc, p_lat, p_long, p_status);
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION atualizar_ocorrencia_status(p_id NUMBER, p_status VARCHAR2)
RETURN NUMBER AS BEGIN
  UPDATE OcorrenciaColaborativa SET status = p_status WHERE id_ocorrencia = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

CREATE OR REPLACE FUNCTION excluir_ocorrencia(p_id NUMBER)
RETURN NUMBER AS BEGIN
  DELETE FROM OcorrenciaColaborativa WHERE id_ocorrencia = p_id;
  RETURN 1;
EXCEPTION WHEN OTHERS THEN RETURN 0;
END;
/

-- ==================================
-- 3. INSERÇÕES DE DADOS (5+ POR TABELA)
-- ==================================
DECLARE
    success NUMBER;
BEGIN
    -- Usuários
    success := inserir_usuario(1, 'Ana Silva', 'ana@email.com', 'senha123');
    success := inserir_usuario(2, 'Luis Santos', 'luis@email.com', 'abc456');
    success := inserir_usuario(3, 'Maria Oliveira', 'maria@email.com', 'qwerty');
    success := inserir_usuario(4, 'Pedro Costa', 'pedro@email.com', 'zxcvbn');
    success := inserir_usuario(5, 'Carla Mendes', 'carla@email.com', 'asdfgh');

    -- Localizações
    success := inserir_localizacao(1, 1, -23.550520, -46.633308);
    success := inserir_localizacao(2, 2, -23.549843, -46.634581);
    success := inserir_localizacao(3, 3, -23.548112, -46.632345);
    success := inserir_localizacao(4, 4, -23.551234, -46.635678);
    success := inserir_localizacao(5, 5, -23.552345, -46.631234);

    -- Abrigos 
    success := inserir_abrigo(1, 'Abrigo Centro', 'Rua Central, 100', -23.550000, -46.634000, 200, 50, '11-9999-8888');
    success := inserir_abrigo(2, 'Abrigo Norte', 'Av. Norte, 500', -23.540000, -46.630000, 150, 120, '11-7777-6666');
    success := inserir_abrigo(3, 'Abrigo Sul', 'Rua Sulista, 300', -23.560000, -46.638000, 100, 90, '11-5555-4444');
    success := inserir_abrigo(4, 'Abrigo Leste', 'Al. Leste, 200', -23.545000, -46.620000, 180, 170, '11-3333-2222');
    success := inserir_abrigo(5, 'Abrigo Oeste', 'Pça. Oeste, 150', -23.555000, -46.645000, 120, 110, '11-1111-0000');

    -- Rotas Seguras 
    success := inserir_rota(1, 1, 1, -23.550520, -46.633308, -23.550000, -46.634000, 'abrigo mais próximo');
    success := inserir_rota(2, 2, 2, -23.549843, -46.634581, -23.540000, -46.630000, 'evacuação');
    success := inserir_rota(3, 3, 3, -23.548112, -46.632345, -23.560000, -46.638000, 'abrigo mais próximo');
    success := inserir_rota(4, 4, 4, -23.551234, -46.635678, -23.545000, -46.620000, 'evacuação');
    success := inserir_rota(5, 5, 5, -23.552345, -46.631234, -23.555000, -46.645000, 'abrigo mais próximo');

    -- Alertas 
    success := inserir_alerta(1, 1, 'risco de deslizamento', 'perigo', 'Área de alto risco', -23.550520, -46.633308, 'ativo');
    success := inserir_alerta(2, 2, 'chuva intensa', 'atenção', 'Precipitação 50mm/h', -23.549843, -46.634581, 'ativo');
    success := inserir_alerta(3, 3, 'calor extremo', 'informativo', 'Temperatura acima de 40°C', -23.548112, -46.632345, 'expirado');
    success := inserir_alerta(4, 4, 'vento forte', 'atenção', 'Rajadas de 70km/h', -23.551234, -46.635678, 'resolvido');
    success := inserir_alerta(5, 5, 'alagamento', 'perigo', 'Nível água 1.5m', -23.552345, -46.631234, 'ativo');

    -- Sensores
    success := inserir_sensor(1, 'inclinação_solo', -23.550123, -46.633456, 'ativo', TO_DATE('2023-01-15', 'YYYY-MM-DD'));
    success := inserir_sensor(2, 'nivel_agua', -23.551234, -46.634567, 'ativo', TO_DATE('2023-02-20', 'YYYY-MM-DD'));
    success := inserir_sensor(3, 'pressão_atmosferica', -23.552345, -46.635678, 'manutenção', TO_DATE('2023-03-10', 'YYYY-MM-DD'));
    success := inserir_sensor(4, 'umidade_solo', -23.553456, -46.636789, 'inativo', TO_DATE('2023-04-05', 'YYYY-MM-DD'));
    success := inserir_sensor(5, 'temperatura', -23.554567, -46.637890, 'ativo', TO_DATE('2023-05-12', 'YYYY-MM-DD'));

    -- Leituras Sensor
    success := inserir_leitura(1, 1, 15.5, 'graus');
    success := inserir_leitura(2, 1, 16.2, 'graus');
    success := inserir_leitura(3, 2, 120.5, 'cm');
    success := inserir_leitura(4, 2, 125.0, 'cm');
    success := inserir_leitura(5, 5, 38.7, 'Celsius');

    -- Ocorrências Colaborativas
    success := inserir_ocorrencia(1, 1, 'deslizamento observado', 'Trincas no solo', -23.550520, -46.633308, 'confirmada');
    success := inserir_ocorrencia(2, 2, 'alagamento', 'Água na altura do joelho', -23.549843, -46.634581, 'pendente');
    success := inserir_ocorrencia(3, 3, 'vento forte', 'Árvores caídas', -23.548112, -46.632345, 'confirmada');
    success := inserir_ocorrencia(4, 4, 'deslizamento observado', 'Movimento de terra', -23.551234, -46.635678, 'ignorada');
    success := inserir_ocorrencia(5, 5, 'alagamento', 'Rua intransitável', -23.552345, -46.631234, 'confirmada');
END;
/

-- ==================================
-- 4. FUNÇÕES DE RETORNO DE DADOS
-- ==================================
CREATE OR REPLACE FUNCTION total_ocorrencias_por_tipo RETURN SYS_REFCURSOR AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR
    SELECT tipo_ocorrencia, COUNT(*) AS total
    FROM OcorrenciaColaborativa
    GROUP BY tipo_ocorrencia;
  RETURN c;
END;
/

CREATE OR REPLACE FUNCTION media_leitura_sensor RETURN SYS_REFCURSOR AS
  c SYS_REFCURSOR;
BEGIN
  OPEN c FOR
    SELECT unidade_medida, ROUND(AVG(valor_lido), 2) AS media
    FROM LeituraSensor
    GROUP BY unidade_medida;
  RETURN c;
END;
/

-- ==================================
-- 5. BLOCOS ANÔNIMOS
-- ==================================
-- Bloco 1: Consulta com JOIN e tratamento de erro
DECLARE
  v_nome_usuario Usuario.nome%TYPE;
BEGIN
  SELECT u.nome INTO v_nome_usuario
  FROM Usuario u
  JOIN OcorrenciaColaborativa o ON u.id_usuario = o.id_usuario
  WHERE o.status = 'confirmada'
  AND ROWNUM = 1;

  DBMS_OUTPUT.PUT_LINE('Usuário com ocorrência confirmada: ' || v_nome_usuario);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nenhuma ocorrência confirmada encontrada');
END;
/

-- Bloco 2: LOOP com cursor explícito
DECLARE
  v_id_usuario Usuario.id_usuario%TYPE;
  v_total NUMBER := 0;
  CURSOR c_usuarios IS
    SELECT id_usuario FROM Usuario;
BEGIN
  OPEN c_usuarios;
  LOOP
    FETCH c_usuarios INTO v_id_usuario;
    EXIT WHEN c_usuarios%NOTFOUND;
    
    SELECT COUNT(*) INTO v_total 
    FROM OcorrenciaColaborativa 
    WHERE id_usuario = v_id_usuario;
    
    IF v_total > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Usuário ' || v_id_usuario || ' possui ' || v_total || ' ocorrência(s)');
    END IF;
  END LOOP;
  CLOSE c_usuarios;
END;
/

-- Bloco 3: Testar função de ocorrências por tipo
DECLARE
  v_cursor SYS_REFCURSOR;
  v_tipo VARCHAR2(100);
  v_total NUMBER;
BEGIN
  v_cursor := total_ocorrencias_por_tipo();
  
  DBMS_OUTPUT.PUT_LINE('--- Ocorrências por Tipo ---');
  LOOP
    FETCH v_cursor INTO v_tipo, v_total;
    EXIT WHEN v_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_tipo || ': ' || v_total);
  END LOOP;
  CLOSE v_cursor;
END;
/

-- Bloco 4: Testar função de média de leituras
DECLARE
  v_cursor SYS_REFCURSOR;
  v_unidade VARCHAR2(20);
  v_media NUMBER;
BEGIN
  v_cursor := media_leitura_sensor();
  
  DBMS_OUTPUT.PUT_LINE('--- Média de Leituras por Unidade ---');
  LOOP
    FETCH v_cursor INTO v_unidade, v_media;
    EXIT WHEN v_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_unidade || ': ' || v_media);
  END LOOP;
  CLOSE v_cursor;
END;
/

-- ==================================
-- 7. CONSULTAS SQL COMPLEXAS
-- ==================================
-- Consulta 1: Total de alertas por nível
SELECT nivel_alerta, COUNT(*) AS total FROM Alerta GROUP BY nivel_alerta;

-- Consulta 2: Abrigos com mais de 70% da capacidade ocupada
SELECT nome, capacidade_max, disponibilidade_atual,
       ROUND((capacidade_max - disponibilidade_atual) / capacidade_max * 100, 2) || '%' AS ocupacao
FROM Abrigo
WHERE (capacidade_max - disponibilidade_atual) / capacidade_max > 0.7;

-- Consulta 3: JOIN entre sensores e leituras com filtro
SELECT s.id_sensor, s.tipo_sensor, s.status, l.valor_lido, l.unidade_medida, l.data_hora
FROM Sensor s
JOIN LeituraSensor l ON s.id_sensor = l.id_sensor
WHERE s.status = 'ativo'
ORDER BY l.data_hora DESC;

-- Consulta 4: Ocorrências agrupadas por status com contagem
SELECT status, COUNT(*) AS total 
FROM OcorrenciaColaborativa 
GROUP BY status
ORDER BY total DESC;

-- Consulta 5: Subquery - usuários com mais de 2 ocorrências confirmadas
SELECT u.id_usuario, u.nome, u.email
FROM Usuario u
WHERE u.id_usuario IN (
    SELECT id_usuario 
    FROM OcorrenciaColaborativa 
    WHERE status = 'confirmada'
    GROUP BY id_usuario 
    HAVING COUNT(*) > 2
);

-- Consulta 6: Usuários com alertas ativos e seus abrigos de destino
SELECT DISTINCT u.nome, a.tipo_evento, a.nivel_alerta, ab.nome as abrigo_destino, ab.disponibilidade_atual
FROM Usuario u
JOIN Alerta a ON u.id_usuario = a.id_usuario
JOIN RotasSeguras rs ON u.id_usuario = rs.id_usuario
JOIN Abrigo ab ON rs.id_abrigo_destino = ab.id_abrigo
WHERE a.status = 'ativo'
AND ab.disponibilidade_atual > 0
ORDER BY a.nivel_alerta DESC;

-- Consulta 7: Abrigos mais procurados via rotas
SELECT ab.nome, ab.endereco, COUNT(rs.id_rota) as total_rotas, ab.capacidade_max, ab.disponibilidade_atual
FROM Abrigo ab
LEFT JOIN RotasSeguras rs ON ab.id_abrigo = rs.id_abrigo_destino
GROUP BY ab.id_abrigo, ab.nome, ab.endereco, ab.capacidade_max, ab.disponibilidade_atual
ORDER BY total_rotas DESC;