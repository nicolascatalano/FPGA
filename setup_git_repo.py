#!/usr/bin/env python3
"""
Script para inicializar un repositorio GIT en la carpeta FPGA
y asociarlo con el repositorio remoto en GitHub
"""

import os
import subprocess
import sys
from pathlib import Path

# Configuración
REPO_LOCAL = r"f:\Proyectos\sist_adq_dbf\FPGA"
REPO_REMOTE = "https://github.com/nicolascatalano/FPGA.git"

def run_command(cmd, description=""):
    """Ejecuta un comando y maneja errores"""
    if description:
        print(f"\n📌 {description}")
    print(f"   $ {cmd}")
    
    try:
        result = subprocess.run(cmd, shell=True, cwd=REPO_LOCAL, 
                              capture_output=True, text=True, check=True)
        if result.stdout:
            print(f"   ✓ {result.stdout.strip()}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"   ❌ Error: {e.stderr.strip() if e.stderr else str(e)}")
        return False
    except Exception as e:
        print(f"   ❌ Error: {str(e)}")
        return False

def setup_git_repo():
    """Configura el repositorio GIT"""
    
    print("=" * 70)
    print("  INICIALIZACIÓN DE REPOSITORIO GIT - PROYECTO FPGA")
    print("=" * 70)
    
    # Verificar que la carpeta existe
    if not os.path.exists(REPO_LOCAL):
        print(f"\n❌ ERROR: La carpeta {REPO_LOCAL} no existe")
        return False
    
    print(f"\n📁 Carpeta local: {REPO_LOCAL}")
    print(f"📡 Repositorio remoto: {REPO_REMOTE}")
    
    # 1. Inicializar repositorio
    if not run_command("git init", "1️⃣  Inicializando repositorio GIT"):
        return False
    
    # 2. Configurar remoto
    if not run_command(f'git remote add origin "{REPO_REMOTE}"', 
                       "2️⃣  Agregando repositorio remoto"):
        return False
    
    # 3. Verificar remoto
    if not run_command("git remote -v", "3️⃣  Verificando remoto configurado"):
        return False
    
    # 4. Listar archivos a trackear
    print(f"\n4️⃣  Listando archivos en la carpeta...")
    files = []
    for root, dirs, filenames in os.walk(REPO_LOCAL):
        # Ignorar carpetas especiales
        dirs[:] = [d for d in dirs if d not in ['.git', '.venv', '__pycache__', '.Xil']]
        
        for file in filenames:
            rel_path = os.path.relpath(os.path.join(root, file), REPO_LOCAL)
            if not rel_path.startswith('.git'):
                files.append(rel_path)
    
    if files:
        print(f"   📄 Archivos encontrados: {len(files)}")
        for f in sorted(files)[:10]:  # Mostrar primeros 10
            print(f"      - {f}")
        if len(files) > 10:
            print(f"      ... y {len(files) - 10} más")
    else:
        print("   ℹ️  No hay archivos para trackear (carpeta vacía)")
    
    # 5. Agregar archivos
    print(f"\n5️⃣  Agregando archivos al staging area...")
    if not run_command("git add .", ""):
        return False
    
    # 6. Verificar estado
    print(f"\n6️⃣  Estado del repositorio:")
    run_command("git status", "")
    
    # 7. Hacer commit
    print(f"\n7️⃣  Creando commit inicial...")
    if not run_command('git commit -m "Initial commit: FPGA project setup"', ""):
        print("   ℹ️  Sin cambios para commitear (probablemente .gitignore vacío)")
    
    # 8. Fetch para sincronizar
    print(f"\n8️⃣  Sincronizando con repositorio remoto...")
    run_command("git fetch origin", "")
    
    # 9. Configurar rama
    print(f"\n9️⃣  Configurando rama tracking...")
    run_command("git branch --set-upstream-to=origin/main main", "")
    
    # Si main no existe, intentar master
    if not run_command("git branch --set-upstream-to=origin/master master", ""):
        pass  # No fatal si falla
    
    # 10. Push
    print(f"\n🔟 Haciendo PUSH al repositorio remoto...")
    print("    ⚠️  NOTA: Se te pedirá autenticación de GitHub")
    print("    Usa: token personal (Settings > Developer settings > Personal access tokens)")
    
    result = run_command("git push -u origin main", "")
    
    if not result:
        print("\n⚠️  Push a 'main' falló. Intentando con 'master'...")
        result = run_command("git push -u origin master", "")
    
    if result:
        print("\n✅ PUSH completado exitosamente!")
    else:
        print("\n⚠️  PUSH falló. Verifica:")
        print("   - Conexión a internet")
        print("   - Credenciales de GitHub")
        print("   - Permisos en el repositorio remoto")
        return False
    
    # Resumen final
    print("\n" + "=" * 70)
    print("  CONFIGURACIÓN COMPLETADA")
    print("=" * 70)
    print(f"\n✅ Repositorio GIT inicializado exitosamente")
    print(f"\n📍 Ubicación: {REPO_LOCAL}")
    print(f"🔗 Remoto: {REPO_REMOTE}")
    
    print(f"\n💡 Próximos pasos:")
    print(f"   1. Copiar archivos VHDL, TCL y constraints a FPGA/")
    print(f"   2. Ejecutar: git add .")
    print(f"   3. Ejecutar: git commit -m 'Add FPGA design files'")
    print(f"   4. Ejecutar: git push")
    
    print(f"\n📚 Comandos útiles:")
    print(f"   cd {REPO_LOCAL}")
    print(f"   git log --oneline              # Ver histórico")
    print(f"   git status                     # Ver cambios")
    print(f"   git diff                       # Ver diferencias")
    print(f"   git push                       # Enviar cambios")
    
    return True

if __name__ == '__main__':
    print()
    
    success = setup_git_repo()
    
    print("\n" + "=" * 70)
    sys.exit(0 if success else 1)
