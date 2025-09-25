import pandas as pd
import pyodbc

# 1. CONFIGURACIÓN DE LA BASE DE DATOS (Windows Authentication)
def conectar_bd():
    server = "MSI"
    database = "Sistema_Analisis" 
    
    conexion = pyodbc.connect(
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={server};DATABASE={database};"
        f"Trusted_Connection=yes;"  # Autenticación de Windows
    )
    return conexion

# 2. FUNCIÓN PARA PROCESAR CADA CSV
def procesar_csv(archivo, tabla):
    print(f"📂 Procesando {archivo}...")
    
    try:
        # Leer CSV
        df = pd.read_csv(f"data/{archivo}")
        print(f"   Registros originales: {len(df)}")
        
        # Limpieza básica
        df = df.drop_duplicates()  # Quitar duplicados
        df = df.dropna()           # Quitar filas con nulos
        print(f"   Registros después de limpieza: {len(df)}")
        
        if len(df) == 0:
            print("   ⚠️  No hay datos después de la limpieza")
            return
        
        # Mapeo de columnas para manejar caracteres especiales
        mapeo_columnas = {
            'Categoría': 'Categoria',
            'Clasificación': 'Clasificacion', 
            'PuntajeSatisfacción': 'PuntajeSatisfaccion'
        }
        
        # Renombrar columnas si es necesario
        df.rename(columns=mapeo_columnas, inplace=True)
        
        # Definir columnas de identidad que deben excluirse (autoincremento)
        columnas_identity_excluir = {
            'Comentarios_Sociales': ['IdComment'],  # Excluir T0001, usar autoincremento
            'Review': ['IdReview'],                 # Excluir W0001, usar autoincremento
            'Encuestas': ['IdOpinion'],             # Ya viene sin IdOpinion en CSV
            'Fuente_De_Datos': ['IdFuente']         # Autoincremento
        }
        
        # Excluir columnas de identidad para tablas que usan autoincremento
        if tabla in columnas_identity_excluir:
            columnas_a_excluir = columnas_identity_excluir[tabla]
            df = df.drop(columns=[col for col in columnas_a_excluir if col in df.columns])
            print(f"   🔧 Excluyendo columnas de identidad: {[col for col in columnas_a_excluir if col in df.columns]}")
        
        # Crear mapeo de IDs únicos para Cliente y Producto desde CSVs alfanuméricos
        if tabla in ['Comentarios_Sociales', 'Review']:
            print("   🔧 Procesando datos con IDs alfanuméricos...")
            
            # Para social_comments y web_reviews: extraer IDs únicos
            if 'IdCliente' in df.columns:
                # Filtrar valores no nulos para IdCliente
                clientes_unicos = df['IdCliente'].dropna().unique()
                if len(clientes_unicos) > 0:
                    print(f"   📋 Clientes únicos encontrados: {clientes_unicos[:5]}{'...' if len(clientes_unicos) > 5 else ''}")
            
            if 'IdProducto' in df.columns:
                productos_unicos = df['IdProducto'].unique()
                print(f"   📋 Productos únicos encontrados: {productos_unicos[:5]}{'...' if len(productos_unicos) > 5 else ''}")
        
        # Cargar a la base de datos
        conexion = conectar_bd()
        cursor = conexion.cursor()
        
        registros_insertados = 0
        
        for index, row in df.iterrows():
            try:
                # Construir query dinámica
                columnas = ', '.join([f'[{col}]' for col in row.index])  # [] para nombres con espacios
                valores = ', '.join(['?'] * len(row))
                query = f"INSERT INTO {tabla} ({columnas}) VALUES ({valores})"
                
                cursor.execute(query, tuple(row))
                registros_insertados += 1
            except Exception as e:
                print(f"   Error en fila {index}: {e}")
        
        conexion.commit()
        conexion.close()
        print(f"   ✅ {registros_insertados} registros cargados en {tabla}\n")
        
    except FileNotFoundError:
        print(f"   ❌ Archivo {archivo} no encontrado en la carpeta 'data/'\n")
    except Exception as e:
        print(f"   ❌ Error procesando {archivo}: {e}\n")

# 3. FUNCIÓN PARA CREAR CLIENTES Y PRODUCTOS DESDE IDs ALFANUMÉRICOS
def crear_clientes_productos_desde_csvs():
    print("🔧 CREANDO REGISTROS DE CLIENTE Y PRODUCTO DESDE CSVs...\n")
    
    try:
        # Recopilar todos los IDs únicos de clientes y productos
        clientes_unicos = set()
        productos_unicos = set()
        
        # Leer social_comments.csv
        print("📊 Analizando social_comments.csv...")
        df_social = pd.read_csv("data/social_comments.csv")
        clientes_social = df_social['IdCliente'].dropna().unique()
        productos_social = df_social['IdProducto'].unique()
        clientes_unicos.update(clientes_social)
        productos_unicos.update(productos_social)
        print(f"   Clientes: {len(clientes_social)}, Productos: {len(productos_social)}")
        
        # Leer web_reviews.csv
        print("📊 Analizando web_reviews.csv...")
        df_reviews = pd.read_csv("data/web_reviews.csv")
        clientes_reviews = df_reviews['IdCliente'].unique()
        productos_reviews = df_reviews['IdProducto'].unique()
        clientes_unicos.update(clientes_reviews)
        productos_unicos.update(productos_reviews)
        print(f"   Clientes: {len(clientes_reviews)}, Productos: {len(productos_reviews)}")
        
        conexion = conectar_bd()
        cursor = conexion.cursor()
        
        # Insertar clientes únicos
        print(f"\n💾 Insertando {len(clientes_unicos)} clientes únicos...")
        clientes_insertados = 0
        for cliente_id in clientes_unicos:
            try:
                cursor.execute(
                    "INSERT INTO Cliente (IdCliente, Nombre, Email) VALUES (?, ?, ?)",
                    (cliente_id, f"Cliente_{cliente_id}", f"{cliente_id.lower()}@mail.com")
                )
                clientes_insertados += 1
            except Exception as e:
                print(f"   Error insertando cliente {cliente_id}: {e}")
        
        # Insertar productos únicos
        print(f"💾 Insertando {len(productos_unicos)} productos únicos...")
        productos_insertados = 0
        for producto_id in productos_unicos:
            try:
                cursor.execute(
                    "INSERT INTO Producto (IdProducto, Nombre, Categoria) VALUES (?, ?, ?)",
                    (producto_id, f"Producto_{producto_id}", "General")
                )
                productos_insertados += 1
            except Exception as e:
                print(f"   Error insertando producto {producto_id}: {e}")
        
        conexion.commit()
        conexion.close()
        
        print(f"   ✅ {clientes_insertados} clientes insertados")
        print(f"   ✅ {productos_insertados} productos insertados\n")
        
    except Exception as e:
        print(f"   ❌ Error creando clientes/productos: {e}\n")

# 4. EJECUTAR TODO EL PROCESO
def main():
    print("🚀 INICIANDO CARGA DE ARCHIVOS CSV\n")
    
    # PASO 1: Crear registros de Cliente y Producto basándose en IDs alfanuméricos
    crear_clientes_productos_desde_csvs()
    
    # PASO 2: Lista de archivos restantes (ORDEN IMPORTANTE)
    archivos = [
        {"csv": "clients.csv", "tabla": "Cliente"},      # Si existe, agregar más clientes
        {"csv": "products.csv", "tabla": "Producto"},    # Si existe, agregar más productos
        {"csv": "fuente_datos.csv", "tabla": "Fuente_De_Datos"}, 
        {"csv": "surveys_part1.csv", "tabla": "Encuestas"},
        {"csv": "social_comments.csv", "tabla": "Comentarios_Sociales"},
        {"csv": "web_reviews.csv", "tabla": "Review"}
    ]
    
    # Procesar cada archivo
    for archivo in archivos:
        procesar_csv(archivo["csv"], archivo["tabla"])
    
    print("🎉 CARGA COMPLETADA!")

# Ejecutar
if __name__ == "__main__":
    main()