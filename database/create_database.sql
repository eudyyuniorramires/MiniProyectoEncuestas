-- ======================================================================
-- SCRIPT DE CREACIÓN DE BASE DE DATOS - SISTEMA DE ANÁLISIS DE ENCUESTAS
-- ======================================================================
-- Descripción: Crea la base de datos y todas las tablas necesarias
--              para el pipeline ETL de análisis de encuestas
-- Autor: Sistema de Análisis de Encuestas
-- Fecha: Septiembre 2025
-- Versión: 1.0
-- ======================================================================

-- Eliminar base de datos si existe (CUIDADO: BORRA TODOS LOS DATOS)
-- Descomenta las siguientes líneas solo si quieres empezar desde cero
/*
USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Sistema_Analisis')
BEGIN
    ALTER DATABASE Sistema_Analisis SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Sistema_Analisis;
    PRINT '✅ Base de datos anterior eliminada';
END
GO
*/

-- Crear nueva base de datos
CREATE DATABASE Sistema_Analisis;
GO

PRINT '✅ Base de datos Sistema_Analisis creada exitosamente';

-- Usar la nueva base de datos
USE Sistema_Analisis;
GO

-- ======================================================================
-- CREAR TABLAS PADRE (SIN DEPENDENCIAS)
-- ======================================================================

-- Tabla Cliente: Almacena información de clientes con IDs alfanuméricos
CREATE TABLE Cliente(
    IdCliente NVARCHAR(20) PRIMARY KEY,    -- IDs como C007, C019, etc.
    Nombre NVARCHAR(100) NOT NULL,         -- Nombre del cliente
    Email NVARCHAR(100) NOT NULL           -- Email del cliente
);

PRINT '✅ Tabla Cliente creada';

-- Tabla Producto: Catálogo de productos con IDs alfanuméricos  
CREATE TABLE Producto(
    IdProducto NVARCHAR(20) PRIMARY KEY,   -- IDs como P003, P016, etc.
    Nombre NVARCHAR(100) NOT NULL,         -- Nombre del producto
    Categoria NVARCHAR(100) NOT NULL       -- Categoría del producto
);

PRINT '✅ Tabla Producto creada';

-- Tabla Fuente_De_Datos: Metadatos de las fuentes de datos
CREATE TABLE Fuente_De_Datos(
    IdFuente INT IDENTITY(1,1) PRIMARY KEY, -- ID autoincremental
    TipoFuente NVARCHAR(200) NOT NULL,      -- Tipo de fuente (CSV, API, etc.)
    FechaCarga DATE                         -- Fecha de carga de datos
);

PRINT '✅ Tabla Fuente_De_Datos creada';

-- ======================================================================
-- CREAR TABLAS HIJAS (CON FOREIGN KEYS)
-- ======================================================================

-- Tabla Comentarios_Sociales: Comentarios de redes sociales
CREATE TABLE Comentarios_Sociales(
    IdComment INT IDENTITY(1,1) PRIMARY KEY,    -- ID autoincremental (ignora T0001 del CSV)
    IdCliente NVARCHAR(20),                     -- Referencia a Cliente (puede ser NULL)
    IdProducto NVARCHAR(20),                    -- Referencia a Producto
    Fuente NVARCHAR(100),                       -- Red social (Facebook, Twitter, Instagram)
    Fecha DATE,                                 -- Fecha del comentario
    Comentario NVARCHAR(1000),                  -- Texto del comentario
    
    -- Claves foráneas
    CONSTRAINT FK_ComSoc_Cliente FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente),
    CONSTRAINT FK_ComSoc_Producto FOREIGN KEY (IdProducto) REFERENCES Producto(IdProducto)
);

PRINT '✅ Tabla Comentarios_Sociales creada';

-- Tabla Encuestas: Encuestas internas de satisfacción
CREATE TABLE Encuestas(
    IdOpinion INT IDENTITY(1,1) PRIMARY KEY,   -- ID autoincremental
    IdCliente INT,                             -- ID numérico (diferente formato que Cliente)
    IdProducto INT,                            -- ID numérico (diferente formato que Producto) 
    Fecha DATE,                                -- Fecha de la encuesta
    Comentario NVARCHAR(1000),                 -- Comentario de la encuesta
    Clasificacion NVARCHAR(100),               -- Clasificación (Positiva, Negativa, Neutra)
    PuntajeSatisfaccion INT,                   -- Puntuación 1-5
    Fuente NVARCHAR(50)                        -- Fuente de la encuesta
    
    -- NOTA: Sin Foreign Keys porque los IDs no coinciden con Cliente/Producto
    -- Las encuestas usan IDs numéricos puros, mientras Cliente/Producto usan alfanuméricos
);

PRINT '✅ Tabla Encuestas creada';

-- Tabla Review: Reviews de sitios web
CREATE TABLE Review(
    IdReview INT IDENTITY(1,1) PRIMARY KEY,    -- ID autoincremental (ignora W0001 del CSV)
    IdCliente NVARCHAR(20),                     -- Referencia a Cliente
    IdProducto NVARCHAR(20),                    -- Referencia a Producto
    Fecha DATE,                                 -- Fecha del review
    Comentario NVARCHAR(1000),                  -- Texto del review
    Rating INT,                                 -- Puntuación del review (1-5)
    
    -- Claves foráneas
    CONSTRAINT FK_Review_Cliente FOREIGN KEY (IdCliente) REFERENCES Cliente(IdCliente),
    CONSTRAINT FK_Review_Producto FOREIGN KEY (IdProducto) REFERENCES Producto(IdProducto)
);

PRINT '✅ Tabla Review creada';

-- ======================================================================
-- CREAR ÍNDICES PARA OPTIMIZAR CONSULTAS
-- ======================================================================

-- Índices en campos de búsqueda frecuente
CREATE INDEX IX_Comentarios_Fecha ON Comentarios_Sociales(Fecha);
CREATE INDEX IX_Comentarios_Fuente ON Comentarios_Sociales(Fuente);
CREATE INDEX IX_Review_Fecha ON Review(Fecha);
CREATE INDEX IX_Review_Rating ON Review(Rating);
CREATE INDEX IX_Encuestas_Fecha ON Encuestas(Fecha);
CREATE INDEX IX_Encuestas_Clasificacion ON Encuestas(Clasificacion);

PRINT '✅ Índices creados para optimización';

-- ======================================================================
-- VERIFICACIÓN DE CREACIÓN DE TABLAS
-- ======================================================================

-- Mostrar resumen de tablas creadas
SELECT 
    TABLE_NAME as 'Tabla Creada',
    CASE 
        WHEN TABLE_NAME IN ('Cliente', 'Producto') THEN 'Tabla Padre (IDs Alfanuméricos)'
        WHEN TABLE_NAME = 'Fuente_De_Datos' THEN 'Tabla Padre (ID Autoincremental)'
        WHEN TABLE_NAME = 'Encuestas' THEN 'Tabla Hija (Sin FK - IDs Numéricos)'
        ELSE 'Tabla Hija (Con FK - IDs Alfanuméricos)'
    END as 'Tipo de Tabla'
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Mostrar Foreign Keys creadas
SELECT 
    FK.CONSTRAINT_NAME as 'Foreign Key',
    FK.TABLE_NAME as 'Tabla Hija',
    FK.COLUMN_NAME as 'Columna',
    PK.TABLE_NAME as 'Tabla Padre'
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE FK ON RC.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE PK ON RC.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
ORDER BY FK.TABLE_NAME;

PRINT '';
PRINT '🎉 ¡BASE DE DATOS CONFIGURADA EXITOSAMENTE!';
PRINT '';
PRINT '📋 PRÓXIMOS PASOS:';
PRINT '1. Verificar que las tablas se crearon correctamente';
PRINT '2. Configurar la conexión en etl_pipeline.py';  
PRINT '3. Ejecutar el pipeline ETL: python scripts/etl_pipeline.py';
PRINT '';
PRINT '📊 TABLAS CREADAS:';
PRINT '   • Cliente (IDs alfanuméricos: C001, C007...)';
PRINT '   • Producto (IDs alfanuméricos: P003, P016...)'; 
PRINT '   • Comentarios_Sociales (Con FK a Cliente/Producto)';
PRINT '   • Review (Con FK a Cliente/Producto)';
PRINT '   • Encuestas (Sin FK - IDs numéricos diferentes)';
PRINT '   • Fuente_De_Datos (Metadatos)';
PRINT '';

-- ======================================================================
-- SCRIPT COMPLETADO
-- ======================================================================