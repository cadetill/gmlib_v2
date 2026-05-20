@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

echo ==================================================
echo  GMLib - Limpieza de artefactos binarios/caches
echo  Repo: %CD%
echo ==================================================
echo.
echo Se eliminaran:
echo  - binarios de demos/tests (bin, exe, dll, so, apk...)
echo  - caches de Delphi (^*.identcache, ^*.dproj.local, ^*.groupproj.local)
echo  - artefactos Lazarus/FPC (^*.o, ^*.ppu, units)
echo  - BPL generadas en dpk
echo  - historico __history de formularios
echo.
set /p _confirm=Continuar? (S/N): 
if /I not "%_confirm%"=="S" (
  echo Cancelado.
  exit /b 0
)

echo.
echo [1/8] Limpieza de binarios en demos...
if exist "demos\Vcl\bin" rmdir /s /q "demos\Vcl\bin"
if exist "demos\Fmx\bin" rmdir /s /q "demos\Fmx\bin"

echo [2/8] Limpieza de binarios en tests/build...
if exist "tests\bin" rmdir /s /q "tests\bin"
if exist "build\check\exe" rmdir /s /q "build\check\exe"

echo [3/8] Limpieza de unidades Lazarus build...
if exist "build\lazarus" rmdir /s /q "build\lazarus"

echo [4/8] Limpieza de unidades LCL en lib...
if exist "lib\Lcl" rmdir /s /q "lib\Lcl"

echo [5/8] Limpieza de BPL generadas en dpk...
for %%F in ("dpk\*.bpl") do (
  if exist "%%~fF" del /q "%%~fF"
)

echo [6/8] Limpieza de caches de Delphi...
for /r %%F in (*.identcache) do del /q "%%~fF"
for /r %%F in (*.dproj.local) do del /q "%%~fF"
for /r %%F in (*.groupproj.local) do del /q "%%~fF"
for /r %%F in (*.tvsconfig) do del /q "%%~fF"

echo [7/8] Limpieza de ejecutables sueltos versionados por accidente...
if exist "tests\GMLibTests.exe" del /q "tests\GMLibTests.exe"
if exist "demos\Vcl\RoutesLab\GMLibRoutesLab.exe" del /q "demos\Vcl\RoutesLab\GMLibRoutesLab.exe"
if exist "demos\Fmx\RoutesLab\GMLibRoutesLabFmx.exe" del /q "demos\Fmx\RoutesLab\GMLibRoutesLabFmx.exe"

echo [8/8] Limpieza de carpetas de historial (__history)...
for /d /r %%D in (__history) do (
  if exist "%%~fD" rmdir /s /q "%%~fD"
)

echo.
echo Limpieza completada.
echo.
echo Sugerencia: ejecuta despues un "git status" para revisar cambios.
exit /b 0

