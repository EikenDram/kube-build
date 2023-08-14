@echo off
SETLOCAL
echo Script for transferring deployment to server
echo:
echo Selected component: %1
echo Selected object: %2
echo:

IF [%1]==[] (
    echo Usage: transfer.bat "component" "object"
    echo "components" - component directory name
    echo                use "all" to transfer all components
    echo:
    echo "object"     - object name:
    echo                    - bin
    echo                    - install
    echo                    - manifest
    echo                    - packages
    echo                    - script
    echo                    - helm
    echo                    - git
    echo                skip parameter to transfer all objects
)

CALL :TransferLog %1
{{- range .Components}}
set "COMPONENT={{index $.Version .Name "dir"}}"
CALL :TransferComponent %COMPONENT%, %1 , %2
{{- end}}

EXIT /B %ERRORLEVEL%

:TransferComponent
rem echo Transferring component: %~1
rem echo Selected component: %~2
rem echo Selected object: %~3
set "COMPONENT="
IF "%~2" == "all" set COMPONENT=1
IF "%~2" == "%~1" set COMPONENT=1
IF defined COMPONENT (
    echo Transferring %~1...
    CALL :TransferObject "bin" %~1 %~3
    CALL :TransferObject "install" %~1 %~3
    CALL :TransferObject "manifest" %~1 %~3
    CALL :TransferObject "packages" %~1 %~3
    CALL :TransferScript "script" %~1 %~3
    CALL :TransferObject "helm" %~1 %~3
    CALL :TransferObject "git" %~1 %~3
)
EXIT /B 0

:TransferObject
rem echo Transferring object: %~1
rem echo Transferring component: %~2
rem echo Selected object: %~3
set "OBJECT="
IF [%~3]==[] set OBJECT=1
IF "%~3" == "%~1" set OBJECT=1
IF defined OBJECT (
    echo Transferring %~2 %~1...
    scp %~1/%~2/* {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/%~1/%~2/
)
EXIT /B 0

:TransferScript
rem echo Transferring object: %~1
rem echo Transferring component: %~2
rem echo Selected object: %~3
set "OBJECT="
IF [%~3]==[] set OBJECT=1
IF "%~3" == "%~1" set OBJECT=1
IF defined OBJECT (
    echo Transferring %~2 %~1...
    scp scripts/%~2.sh {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/scripts/
)
EXIT /B 0

:TransferLog
rem echo Selected component: %~1
set "COMPONENT="
IF "%~1" == "all" set OBJECT=1
IF "%~1" == "log" set OBJECT=1
IF defined OBJECT (
    echo Transferring build log...
    scp log/* {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/log/
    scp README.md {{.Values.server.user}}@{{.Values.server.hostname}}:/home/{{.Values.server.user}}/deployment/
)
EXIT /B 0