@echo off
REM Automatically process the only .qmd file in the current directory

cd /d %~dp0

REM Find .qmd file
for %%f in (*.qmd) do (
  SET "QMD_FILE=%%f"
  goto found
)

echo No .qmd file found in this folder.
pause
exit /b 1

:found
echo Found Quarto file: %QMD_FILE%

REM Remove extension to get base name
for %%f in ("%QMD_FILE%") do (
  SET "BASENAME=%%~nf"
)

REM Render to HTML
echo Rendering to HTML with Quarto...
quarto render "%QMD_FILE%"
if %ERRORLEVEL% NEQ 0 (
  echo Quarto render failed.
  pause
  exit /b 1
)

REM Define paths
set "HTML_FILE=%BASENAME%.html"
set "PDF_FILE=%BASENAME%.pdf"
set "HTML_URL=file:///%cd:\=/%/%HTML_FILE%"

REM Delete existing PDF if it exists
if exist "%PDF_FILE%" del /f "%PDF_FILE%"

REM Export to PDF using Decktape
echo Exporting to PDF using Decktape...
call decktape reveal "%HTML_URL%" "%PDF_FILE%" --size 1920x1080
if %ERRORLEVEL% NEQ 0 (
  echo ERROR: Decktape export failed.
  pause
  exit /b 1
)

echo Export complete: %PDF_FILE%
start "" "%PDF_FILE%"
pause