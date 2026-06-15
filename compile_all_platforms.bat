@echo off
setlocal enabledelayedexpansion

:: =======================================================
:: MENÚ INTERACTIVO DE SELECCIÓN DE CONFIGURACIÓN
:: =======================================================
:menu
cls
echo =======================================================
echo   COMPILADOR AUTOMATICO PARA GMLIB V2
echo =======================================================
echo   1. Compilar en modo DEBUG (Desarrollo)
echo   2. Compilar en modo RELEASE (Produccion)
echo   3. Cancelar y Salir
echo =======================================================
echo.
set /p "OPCION=Por favor, selecciona una opcion (1-3): "

if "%OPCION%"=="1" (
    set "CONFIG=Debug"
    goto iniciar
)
if "%OPCION%"=="2" (
    set "CONFIG=Release"
    goto iniciar
)
if "%OPCION%"=="3" (
    echo Saliendo del instalador...
    goto fin_script
)

echo [AVISO] Opcion no valida, intenta de nuevo.
pause
goto menu


:iniciar
:: =======================================================
:: 1. CONFIGURACIÓN DE RUTAS Y ARCHIVOS
:: =======================================================
:: Nombre de los paquetes multiplataforma (Delphi)
set "PKG_MLCORE=.\dpk\MapLibCore.dproj"
set "PKG_GMRUNTIME=.\dpk\GMLibRuntime.dproj"
set "PKG_OSMRUNTIME=.\dpk\OSMLibRuntime.dproj"
set "PKG_GMFMXRUNTIME=.\dpk\GMLibRuntime.Fmx.dproj"

:: Nombre de los paquetes solo Windows (Delphi)
set "PKG_GMVCLRuntime=.\dpk\GMLibRuntime.Vcl.dproj"
set "PKG_OSMVCLRuntime=.\dpk\OSMLibRuntime.Vcl.dproj"
set "PKG_MLVCLDESIGN=.\dpk\MapLibDesign.Vcl.dproj"
set "PKG_MLFMXDESIGN=.\dpk\MapLibDesign.Fmx.dproj"

:: Configuración del paquete para Lazarus (LCL)
set "PKG_LCLGMRUNTIME=.\dpk\GMLibRuntime.Lcl.lpk"
set "PKG_LCLMLDESIGN=.\dpk\MapLibDesign.Lcl.lpk"
set "RUTA_LAZBUILD=C:\lazarus\lazbuild.exe"

:: Nombre del archivo donde se guardarán los Hints, Warnings y Errores
set "ARCHIVO_LOG=reporte_compilacion.log"

:: Si ya existía un log anterior, lo borramos para empezar limpios
if exist "%ARCHIVO_LOG%" del "%ARCHIVO_LOG%"


:: =======================================================
:: 2. CARGAR ENTORNO DE RAD STUDIO (rsvars.bat)
:: =======================================================
if exist "%ProgramFiles(x86)%\Embarcadero\Studio\37.0\bin\rsvars.bat" (
    set "VER=37.0"
    call "%ProgramFiles(x86)%\Embarcadero\Studio\37.0\bin\rsvars.bat"
) else if exist "%ProgramFiles(x86)%\Embarcadero\Studio\25.0\bin\rsvars.bat" (
    set "VER=25.0"
    call "%ProgramFiles(x86)%\Embarcadero\Studio\25.0\bin\rsvars.bat"
) else if exist "%ProgramFiles(x86)%\Embarcadero\Studio\23.0\bin\rsvars.bat" (
    set "VER=23.0"
    call "%ProgramFiles(x86)%\Embarcadero\Studio\23.0\bin\rsvars.bat"
) else if exist "%ProgramFiles(x86)%\Embarcadero\Studio\22.0\bin\rsvars.bat" (
    set "VER=22.0"
    call "%ProgramFiles(x86)%\Embarcadero\Studio\22.0\bin\rsvars.bat"
) else (
    echo [ERROR] No se encontro rsvars.bat. Edita este script con la ruta correcta de tu Delphi.
    pause
    exit /b
)

cls
echo =======================================================
echo   INICIANDO COMPILACIÓN AUTOMÁTICA DE GMLIB
echo   Configuración seleccionada: %CONFIG%
echo   Version de Delphi cargada:  %VER%
echo   Guardando reporte en:       %ARCHIVO_LOG%
echo =======================================================

:: Definimos las propiedades base de MSBuild para reducir código repetido
:: /v:n activa la visualización normal para ver Hints. 
:: /fl y /flp activan el volcado de texto hacia el archivo .log acumulando las líneas (Append)
set "MSB_FLAGS=/p:Config=%CONFIG% /p:ProductVersion=%VER% /t:Build /p:UseConfigInOutputs=true /p:DCC_Hints=true /p:DCC_Warnings=true /v:n /fl /flp:LogFile=%ARCHIVO_LOG%;Append"


:: =======================================================
:: 3. COMPILACIÓN PARA WINDOWS (32 y 64 BITS - COMPLETO)
:: =======================================================
for %%P in (Win32 Win64) do (
    echo.
    echo [PROCESO] Compilando ecosistema Delphi para %%P...
    msbuild "%PKG_MLCORE%" /p:Platform=%%P %MSB_FLAGS% || goto error
    msbuild "%PKG_GMRUNTIME%" /p:Platform=%%P %MSB_FLAGS% || goto error
    msbuild "%PKG_OSMRUNTIME%" /p:Platform=%%P %MSB_FLAGS% || goto error
    msbuild "%PKG_GMFMXRUNTIME%" /p:Platform=%%P %MSB_FLAGS% || goto error
    msbuild "%PKG_GMVCLRuntime%" /p:Platform=%%P %MSB_FLAGS% || goto error
    msbuild "%PKG_OSMVCLRuntime%" /p:Platform=%%P %MSB_FLAGS% || goto error
    msbuild "%PKG_MLVCLDESIGN%" /p:Platform=%%P %MSB_FLAGS% || goto error
    msbuild "%PKG_MLFMXDESIGN%" /p:Platform=%%P %MSB_FLAGS% || goto error
)


:: =======================================================
:: 4. COMPILACIÓN MULTIPLATAFORMA (Android64, iOSDevice64 y OSXARM64)
:: =======================================================
::  iOSDevice64 OSXARM64
for %%P in (Android64) do (
    echo.
    echo [PROCESO] Compilando paquetes de Runtime para %%P...
    msbuild "%PKG_MLCORE%" /p:Platform=%%P %MSB_FLAGS% || goto error
    msbuild "%PKG_GMRUNTIME%" /p:Platform=%%P %MSB_FLAGS% || goto error
    msbuild "%PKG_OSMRUNTIME%" /p:Platform=%%P %MSB_FLAGS% || goto error
    msbuild "%PKG_GMFMXRUNTIME%" /p:Platform=%%P %MSB_FLAGS% || goto error
)


:: =======================================================
:: 5. COMPILACIÓN PARA LAZARUS / LCL
:: =======================================================
echo.
echo =======================================================
echo   INICIANDO COMPILACIÓN DEL ENTORNO LAZARUS / LCL
echo =======================================================
if exist "%RUTA_LAZBUILD%" (
    echo [PROCESO] Compilando paquete LCL con LazBuild... >> "%ARCHIVO_LOG%"
    
    echo [PROCESO] Compilando paquete LCL con LazBuild...
    
    :: Compila el paquete de Runtime de Lazarus (guarda en log)
    "%RUTA_LAZBUILD%" -B "%PKG_LCLGMRUNTIME%" >> "%ARCHIVO_LOG%" 2>&1
    if %errorlevel% neq 0 (
        echo.
        echo [ERROR] Error critico al compilar el paquete de Runtime LCL.
        echo Moviendo ultimas lineas del log a la pantalla:
        echo -------------------------------------------------------
        powershell -Command "Get-Content '%ARCHIVO_LOG%' -Tail 15"
        echo -------------------------------------------------------
        goto error
    )
    
    :: Compila el paquete de Diseno de Lazarus (guarda en log)
    "%RUTA_LAZBUILD%" -B "%PKG_LCLMLDESIGN%" >> "%ARCHIVO_LOG%" 2>&1
    if %errorlevel% neq 0 (
        echo.
        echo [ERROR] Error critico al compilar el paquete de Diseno LCL.
        echo Moviendo ultimas lineas del log a la pantalla:
        echo -------------------------------------------------------
        powershell -Command "Get-Content '%ARCHIVO_LOG%' -Tail 15"
        echo -------------------------------------------------------
        goto error
    )
) else (
    echo [AVISO] No se encontro lazbuild.exe en la ruta especificada. Saltando paso LCL.
)


:: =======================================================
:: Fin del script con éxito
:: =======================================================
echo.
echo =======================================================
echo   [OK] ¡GMLib compilo correctamente en todas las plataformas!
echo   Puedes revisar todos los Hints y Warnings en: %ARCHIVO_LOG%
echo =======================================================
pause
exit /b

:error
echo.
echo =======================================================
echo   [ERROR] La compilacion se detuvo por un fallo.
echo   Revisa el final de '%ARCHIVO_LOG%' para ver el motivo del error.
echo =======================================================
pause
exit /b

:fin_script
exit /b
