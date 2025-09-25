# Diccionario de Datos - Sistema de Análisis de Encuestas

## 📋 Descripción General
Este documento describe la estructura de datos del sistema de análisis de encuestas, incluyendo todas las tablas, campos y relaciones.

---

## 🗂️ Tablas del Sistema

### 1. **Cliente**
**Descripción**: Almacena información de los clientes del sistema
**Tipo**: Tabla padre (sin dependencias)

| Campo | Tipo | Nulo | Descripción | Ejemplo |
|-------|------|------|-------------|---------|
| `IdCliente` | NVARCHAR(20) | NO | **PK** - Identificador único alfanumérico | C007, C019 |
| `Nombre` | NVARCHAR(100) | NO | Nombre completo del cliente | Cliente_C007 |
| `Email` | NVARCHAR(100) | NO | Correo electrónico del cliente | c007@mail.com |

**Índices**: Clave primaria en `IdCliente`

---

### 2. **Producto**  
**Descripción**: Catálogo de productos disponibles en el sistema
**Tipo**: Tabla padre (sin dependencias)

| Campo | Tipo | Nulo | Descripción | Ejemplo |
|-------|------|------|-------------|---------|
| `IdProducto` | NVARCHAR(20) | NO | **PK** - Identificador único alfanumérico | P003, P016 |
| `Nombre` | NVARCHAR(100) | NO | Nombre del producto | Producto_P016 |
| `Categoria` | NVARCHAR(100) | NO | Categoría del producto | Electrónica, Juguetes |

**Índices**: Clave primaria en `IdProducto`

---

### 3. **Fuente_De_Datos**
**Descripción**: Metadatos sobre las fuentes de datos del sistema  
**Tipo**: Tabla padre (sin dependencias)

| Campo | Tipo | Nulo | Descripción | Ejemplo |
|-------|------|------|-------------|---------|
| `IdFuente` | INT IDENTITY(1,1) | NO | **PK** - ID autoincremental | 1, 2, 3 |
| `TipoFuente` | NVARCHAR(200) | NO | Tipo de fuente de datos | CSV, API REST |
| `FechaCarga` | DATE | SÍ | Fecha de última carga | 2025-09-24 |

**Índices**: Clave primaria en `IdFuente`

---

### 4. **Comentarios_Sociales**
**Descripción**: Comentarios recopilados de redes sociales sobre productos
**Tipo**: Tabla hija (depende de Cliente y Producto)

| Campo | Tipo | Nulo | Descripción | Ejemplo |
|-------|------|------|-------------|---------|
| `IdComment` | INT IDENTITY(1,1) | NO | **PK** - ID autoincremental | 1, 2, 3 |
| `IdCliente` | NVARCHAR(20) | SÍ | **FK** - Referencia a Cliente | C019, C036 |
| `IdProducto` | NVARCHAR(20) | NO | **FK** - Referencia a Producto | P003, P010 |
| `Fuente` | NVARCHAR(100) | SÍ | Red social origen | Facebook, Twitter, Instagram |
| `Fecha` | DATE | SÍ | Fecha del comentario | 2025-06-15 |
| `Comentario` | NVARCHAR(1000) | SÍ | Texto del comentario | "Muy mala calidad..." |

**Relaciones**:
- `FK_ComSoc_Cliente`: `IdCliente` → `Cliente.IdCliente`
- `FK_ComSoc_Producto`: `IdProducto` → `Producto.IdProducto`

**Índices**: 
- `IX_Comentarios_Fecha` en `Fecha`
- `IX_Comentarios_Fuente` en `Fuente`

**Notas**: 
- El campo `IdComment` del CSV (T0001, T0002...) se ignora y usa autoincremento
- `IdCliente` puede ser NULL si el comentario es anónimo

---

### 5. **Encuestas**
**Descripción**: Encuestas internas de satisfacción del cliente
**Tipo**: Tabla hija (SIN foreign keys por incompatibilidad de IDs)

| Campo | Tipo | Nulo | Descripción | Ejemplo |
|-------|------|------|-------------|---------|
| `IdOpinion` | INT IDENTITY(1,1) | NO | **PK** - ID autoincremental | 1, 2, 3 |
| `IdCliente` | INT | SÍ | ID numérico de cliente (formato diferente) | 8537, 2721 |
| `IdProducto` | INT | SÍ | ID numérico de producto (formato diferente) | 366, 667 |
| `Fecha` | DATE | SÍ | Fecha de la encuesta | 2025-07-15 |
| `Comentario` | NVARCHAR(1000) | SÍ | Comentario de la encuesta | "El producto está bien..." |
| `Clasificacion` | NVARCHAR(100) | SÍ | Clasificación del sentimiento | Positiva, Negativa, Neutra |
| `PuntajeSatisfaccion` | INT | SÍ | Puntuación de satisfacción (1-5) | 1, 2, 3, 4, 5 |
| `Fuente` | NVARCHAR(50) | SÍ | Fuente de la encuesta | EncuestaInterna |

**Índices**: 
- `IX_Encuestas_Fecha` en `Fecha`
- `IX_Encuestas_Clasificacion` en `Clasificacion`

**Notas**: 
- No tiene foreign keys porque usa IDs numéricos puros que no coinciden con las tablas Cliente/Producto
- Los IDs representan un sistema de numeración diferente al del resto del sistema

---

### 6. **Review**
**Descripción**: Reviews de productos provenientes de sitios web
**Tipo**: Tabla hija (depende de Cliente y Producto)

| Campo | Tipo | Nulo | Descripción | Ejemplo |
|-------|------|------|-------------|---------|
| `IdReview` | INT IDENTITY(1,1) | NO | **PK** - ID autoincremental | 1, 2, 3 |
| `IdCliente` | NVARCHAR(20) | NO | **FK** - Referencia a Cliente | C007, C028 |
| `IdProducto` | NVARCHAR(20) | NO | **FK** - Referencia a Producto | P016, P005 |
| `Fecha` | DATE | SÍ | Fecha del review | 2024-10-23 |
| `Comentario` | NVARCHAR(1000) | SÍ | Texto del review | "Producto llegó rápido..." |
| `Rating` | INT | SÍ | Puntuación del review (1-5) | 1, 2, 3, 4, 5 |

**Relaciones**:
- `FK_Review_Cliente`: `IdCliente` → `Cliente.IdCliente`  
- `FK_Review_Producto`: `IdProducto` → `Producto.IdProducto`

**Índices**: 
- `IX_Review_Fecha` en `Fecha`
- `IX_Review_Rating` en `Rating`

**Notas**: 
- El campo `IdReview` del CSV (W0001, W0002...) se ignora y usa autoincremento

---

## 🔗 Diagrama de Relaciones

```
                    ┌─────────────────┐
                    │ Fuente_De_Datos │
                    │                 │
                    │ IdFuente        │
                    │ TipoFuente      │
                    │ FechaCarga      │
                    └─────────────────┘

┌─────────────┐                                   ┌─────────────┐
│   Cliente   │                                   │  Producto   │
│             │                                   │             │
│ IdCliente   │                                   │ IdProducto  │
│ Nombre      │                                   │ Nombre      │
│ Email       │                                   │ Categoria   │
└─────────────┘                                   └─────────────┘
       │                                                 │
       │                                                 │
       ├─────────────────┐                              │
       │                 │                              │
       ▼                 ▼                              ▼
┌──────────────────┐  ┌──────────────────┐     ┌──────────────────┐
│ Comentarios_     │  │     Review       │     │    Encuestas     │
│ Sociales         │  │                  │     │                  │
│                  │  │ IdReview         │     │ IdOpinion        │
│ IdComment        │  │ IdCliente (FK)   │     │ IdCliente (*)    │
│ IdCliente (FK)   │  │ IdProducto (FK)  │     │ IdProducto (*)   │
│ IdProducto (FK)  │  │ Fecha            │     │ Clasificacion    │
│ Fuente           │  │ Comentario       │     │ Puntuacion       │
│ Fecha            │  │ Rating           │     │ Fecha            │
│ Comentario       │  └──────────────────┘     │ Comentario       │
└──────────────────┘            │              └──────────────────┘
       │                        │                       
       └────────────────────────┘               
                │                               
                ▼                               
         (Ambas conectan                        
         con Producto)                          

(*) Sin FK - IDs diferentes (formato numérico vs alfanumérico)
```

---

## 📊 Estadísticas de Datos

### Volúmenes típicos por tabla:
- **Cliente**: ~540 registros (40 automáticos + 500 del CSV)
- **Producto**: ~220 registros (20 automáticos + 200 del CSV)
- **Comentarios_Sociales**: ~112 registros (después de limpieza)
- **Review**: ~200 registros
- **Encuestas**: ~500 registros
- **Fuente_De_Datos**: ~100 registros

---

## 🔍 Consultas Útiles

### Obtener comentarios por fuente:
```sql
SELECT Fuente, COUNT(*) as Total
FROM Comentarios_Sociales 
GROUP BY Fuente;
```

### Reviews con rating alto:
```sql
SELECT c.Nombre, p.Nombre, r.Rating, r.Comentario
FROM Review r
JOIN Cliente c ON r.IdCliente = c.IdCliente
JOIN Producto p ON r.IdProducto = p.IdProducto
WHERE r.Rating >= 4;
```

### Distribución de sentimientos en encuestas:
```sql
SELECT Clasificacion, COUNT(*) as Cantidad
FROM Encuestas
GROUP BY Clasificacion;
```

---

## ⚠️ Notas Importantes

1. **IDs Alfanuméricos**: Las tablas Cliente y Producto usan IDs alfanuméricos (C007, P016) que vienen directamente de los CSVs de comentarios y reviews.

2. **Encuestas Separadas**: La tabla Encuestas no tiene foreign keys porque usa un sistema de IDs numérico diferente (números puros) que no corresponde con los IDs alfanuméricos del resto del sistema.

3. **Autoincremento**: Las tablas hijas (Comentarios_Sociales, Review) ignoran los IDs del CSV (T0001, W0001) y usan autoincremento para evitar conflictos.

4. **Datos Nulos**: Varios campos permiten NULL para manejar datos incompletos en las fuentes originales.