# 📊 Sistema de Análisis de Encuestas - Pipeline ETL

Un pipeline ETL completo para procesar y analizar datos de encuestas, comentarios sociales y reviews de productos, almacenándolos en una base de datos SQL Server para análisis posteriores.

## 🎯 Objetivo del Proyecto

Este sistema integra múltiples fuentes de datos de feedback de clientes:
- **Encuestas internas** de satisfacción
- **Comentarios de redes sociales** (Facebook, Twitter, Instagram)  
- **Reviews de sitios web** de productos
- **Datos de clientes y productos**

## 🏗️ Arquitectura del Sistema

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Fuentes CSV   │───▶│  Pipeline ETL    │───▶│  SQL Server     │
│                 │    │                  │    │                 │
│ • clients.csv   │    │ • Lectura        │    │ • Cliente       │
│ • products.csv  │    │ • Procesamiento  │    │ • Producto      │
│ • surveys.csv   │    │ • Transformación │    │ • Encuestas     │
│ • comments.csv  │    │ • Validación     │    │ • Reviews       │
│ • reviews.csv   │    │ • Carga          │    │ • Comentarios   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📁 Estructura del Proyecto

```
MiniProyectoEncuestas/
├── 📂 data/                    # Archivos CSV de entrada
│   ├── clients.csv             # Datos de clientes
│   ├── products.csv            # Catálogo de productos
│   ├── surveys_part1.csv       # Encuestas de satisfacción
│   ├── social_comments.csv     # Comentarios de redes sociales
│   ├── web_reviews.csv         # Reviews de sitios web
│   └── fuente_datos.csv        # Metadatos de fuentes
├── 📂 scripts/                 # Scripts del pipeline ETL
│   └── etl_pipeline.py         # Pipeline principal
├── 📂 database/                # Scripts de base de datos
│   └── create_database.sql     # Creación de esquema
├── 📂 docs/                    # Documentación adicional
│   └── data_dictionary.md      # Diccionario de datos
├── 📄 README.md                # Este archivo
├── 📄 requirements.txt         # Dependencias Python
└── 📄 .gitignore              # Archivos a ignorar en git
```

## 🛠️ Tecnologías Utilizadas

- **Python 3.11+** - Lenguaje principal del pipeline
- **pandas** - Manipulación y análisis de datos
- **pyodbc** - Conexión a SQL Server
- **SQL Server** - Base de datos relacional
- **Git/GitHub** - Control de versiones

## 📋 Requisitos Previos

### Software necesario:
1. **Python 3.11 o superior**
2. **SQL Server** (Local o remoto)
3. **ODBC Driver 17 for SQL Server**
4. **Git** (para clonar el repositorio)

### Verificar instalación:
```bash
python --version
sqlcmd -S [servidor] -E -Q "SELECT @@VERSION"
```

## ⚙️ Instalación

### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/sistema-analisis-etl.git
cd sistema-analisis-etl
```

### 2. Instalar dependencias Python
```bash
pip install -r requirements.txt
```

### 3. Configurar base de datos
```bash
# Ejecutar script de creación de base de datos
sqlcmd -S tu-servidor -E -i database/create_database.sql
```

### 4. Configurar conexión
Editar `scripts/etl_pipeline.py` y actualizar los parámetros de conexión:
```python
def conectar_bd():
    server = "TU_SERVIDOR"      # Cambiar por tu servidor
    database = "Sistema_Analisis" 
    # ... resto de la configuración
```

## 🚀 Uso del Sistema

### Ejecución básica:
```bash
cd MiniProyectoEncuestas
python scripts/etl_pipeline.py
```

### Salida esperada:
```
🚀 INICIANDO CARGA DE ARCHIVOS CSV

🔧 CREANDO REGISTROS DE CLIENTE Y PRODUCTO DESDE CSVs...
📊 Analizando social_comments.csv...
   Clientes: 38, Productos: 20
💾 Insertando 40 clientes únicos...
   ✅ 40 clientes insertados

📂 Procesando clients.csv...
   ✅ 500 registros cargados en Cliente

📂 Procesando social_comments.csv...
   ✅ 112 registros cargados en Comentarios_Sociales

🎉 CARGA COMPLETADA!
```

## 📊 Esquema de Base de Datos

### Tablas principales:

#### **Cliente**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| IdCliente | NVARCHAR(20) | ID único del cliente (ej: C007) |
| Nombre | NVARCHAR(100) | Nombre del cliente |
| Email | NVARCHAR(100) | Email del cliente |

#### **Producto**  
| Campo | Tipo | Descripción |
|-------|------|-------------|
| IdProducto | NVARCHAR(20) | ID único del producto (ej: P016) |
| Nombre | NVARCHAR(100) | Nombre del producto |
| Categoria | NVARCHAR(100) | Categoría del producto |

#### **Review**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| IdReview | INT IDENTITY | ID autoincremental |
| IdCliente | NVARCHAR(20) | Referencia a Cliente |
| IdProducto | NVARCHAR(20) | Referencia a Producto |
| Fecha | DATE | Fecha del review |
| Comentario | NVARCHAR(1000) | Texto del review |
| Rating | INT | Puntuación (1-5) |

## 🔄 Proceso ETL Detallado

### **1. Extracción (Extract)**
- Lee archivos CSV desde la carpeta `data/`
- Valida formato y estructura de datos
- Maneja encodings y caracteres especiales

### **2. Transformación (Transform)**  
- **Limpieza**: Elimina duplicados y valores nulos
- **Mapeo de columnas**: Convierte caracteres especiales (ñ, acentos)
- **Validación de IDs**: Maneja IDs alfanuméricos (C007, P016)
- **Creación de referencias**: Genera registros padre automáticamente

### **3. Carga (Load)**
- **Orden jerárquico**: Carga tablas padre antes que hijas
- **Manejo de IDENTITY**: Excluye columnas autoincremento
- **Control de errores**: Registra errores por fila sin detener el proceso
- **Transacciones**: Confirma cambios solo si todo es exitoso

## 🧪 Características Especiales

### ✅ Manejo de IDs Alfanuméricos
El sistema maneja automáticamente IDs con formato:
- **Clientes**: C001, C007, C019...  
- **Productos**: P003, P016, P020...
- **Comments**: T0001, T0002... (excluidos, usa autoincremento)
- **Reviews**: W0001, W0002... (excluidos, usa autoincremento)

### ✅ Creación Automática de Referencias
- Analiza archivos de comentarios y reviews
- Extrae IDs únicos de clientes y productos  
- Crea registros automáticamente en tablas padre
- Evita errores de Foreign Key

### ✅ Control de Calidad
- Reportes detallados de registros procesados
- Manejo de errores fila por fila
- Validación de integridad referencial
- Limpieza automática de datos

## 📈 Métricas de Procesamiento

En una ejecución típica procesa:
- **540 clientes** (40 automáticos + 500 del CSV)
- **220 productos** (20 automáticos + 200 del CSV)  
- **500 encuestas** de satisfacción
- **112 comentarios** de redes sociales
- **200 reviews** de sitios web
- **100 registros** de fuentes de datos

## 🐛 Solución de Problemas

### Error de conexión a base de datos:
```
Error: Microsoft ODBC Driver not found
```
**Solución**: Instalar ODBC Driver 17 for SQL Server

### Error de permisos:
```
Error: Login failed for user
```  
**Solución**: Verificar credenciales o usar autenticación Windows

### Error de archivo no encontrado:
```
Error: Archivo clients.csv no encontrado
```
**Solución**: Verificar que los archivos CSV están en la carpeta `data/`

## 🤝 Contribuciones

1. Fork el repositorio
2. Crea una rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👥 Autores

- **Eudy Yunior Lorenzo Ramirez** - *Desarrollo inicial* - (https://github.com/eudyyuniorramires)


---
  
🔗 **Repositorio**: https://github.com/tu-usuario/sistema-analisis-etl  
📅 **Última actualización**: Septiembre 2025
