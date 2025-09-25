# 🚀 Comandos Git para el Proyecto

## 📋 Preparación inicial

### 1. Inicializar repositorio local (si no se ha hecho)
```bash
cd MiniProyectoEncuestas
git init
```

### 2. Configurar usuario (primera vez)
```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@dominio.com"
```

## 📤 Subir proyecto a GitHub

### 1. Agregar todos los archivos
```bash
git add .
```

### 2. Verificar qué archivos se van a subir
```bash
git status
```

### 3. Hacer commit inicial
```bash
git commit -m "🎉 Initial commit: Sistema ETL de Análisis de Encuestas

✅ Pipeline ETL completo para procesamiento de datos
✅ Manejo de IDs alfanuméricos (C007, P016, etc.)  
✅ Soporte para múltiples fuentes de datos (CSV)
✅ Base de datos SQL Server con foreign keys
✅ Documentación completa y diccionario de datos
✅ Scripts de configuración automatizados

Archivos incluidos:
- Pipeline ETL principal (scripts/etl_pipeline.py)
- Script de creación de BD (database/create_database.sql)
- Documentación completa (README.md, docs/)
- Datos de ejemplo (data/*.csv)
- Configuración del proyecto (requirements.txt, .gitignore)"
```

### 4. Conectar con repositorio remoto de GitHub
```bash
# Reemplaza 'tu-usuario' y 'nombre-repositorio' con los valores correctos
git remote add origin https://github.com/tu-usuario/sistema-analisis-etl.git
```

### 5. Subir al repositorio
```bash
git push -u origin main
```

## 🔄 Comandos para actualizaciones futuras

### Agregar cambios específicos
```bash
git add archivo-modificado.py
git commit -m "🔧 Descripción del cambio realizado"
git push
```

### Agregar todos los cambios
```bash
git add .
git commit -m "📝 Descripción de los cambios"
git push
```

## 📊 Comandos útiles de verificación

### Ver estado actual
```bash
git status
```

### Ver historial de commits
```bash
git log --oneline
```

### Ver diferencias antes de commit
```bash
git diff
```

### Ver repositorios remotos configurados
```bash
git remote -v
```

## 🔧 Comandos de configuración adicional

### Configurar editor por defecto
```bash
git config --global core.editor "code --wait"  # Para VS Code
```

### Ver configuración actual
```bash
git config --list
```

## 📁 Estructura que se subirá

```
MiniProyectoEncuestas/
├── 📂 data/                    ✅ Archivos CSV de ejemplo
├── 📂 scripts/                 ✅ Código Python del pipeline
├── 📂 database/                ✅ Scripts SQL de configuración
├── 📂 docs/                    ✅ Documentación del proyecto
├── 📄 README.md                ✅ Documentación principal
├── 📄 requirements.txt         ✅ Dependencias Python
├── 📄 .gitignore              ✅ Archivos a ignorar
└── 📄 git_commands.md         ✅ Este archivo de comandos
```

## ⚠️ Notas importantes

1. **Primera vez**: Usa `git push -u origin main` para establecer la rama por defecto
2. **Actualizaciones**: Usa solo `git push` después del primer push
3. **Credenciales**: GitHub puede pedirte usuario/contraseña o token de acceso
4. **Archivos grandes**: Los CSV se suben porque son de ejemplo/demo
5. **Privacidad**: Revisa que no haya datos sensibles antes de hacer push

## 🔐 Configuración de autenticación

Si GitHub pide autenticación:

### Opción 1: Token de acceso personal (recomendado)
1. Ve a GitHub.com > Settings > Developer settings > Personal access tokens
2. Genera un nuevo token con permisos de repositorio
3. Usa el token en lugar de la contraseña

### Opción 2: SSH (más seguro)
```bash
# Generar clave SSH
ssh-keygen -t ed25519 -C "tu-email@dominio.com"

# Agregar clave pública a GitHub
cat ~/.ssh/id_ed25519.pub

# Cambiar remote a SSH
git remote set-url origin git@github.com:tu-usuario/sistema-analisis-etl.git
```

## 📝 Mensajes de commit recomendados

Usa estos prefijos para mensajes claros:
- `🎉` - Commit inicial o funcionalidad nueva importante
- `✨` - Nueva funcionalidad
- `🔧` - Corrección de bugs
- `📝` - Actualización de documentación  
- `♻️` - Refactoring de código
- `⚡` - Mejora de rendimiento
- `🔒` - Corrección de seguridad
- `📦` - Actualización de dependencias