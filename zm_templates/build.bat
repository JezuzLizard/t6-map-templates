@echo off
set "MOD_NAME=zm_frontend"
set "OAT_BASE=%cd%\oat"
set "BIN_PATH=%cd%\bin"
set "COMMON_PATH=%cd%\common"
set "SOURCE_PATH=%cd%\%MOD_NAME%\zone_source"
set "SOURCE_PATH_TEMPLATED=%cd%\common\zone_source"
set "MAP_BASE=%cd%\%MOD_NAME%"
set "ZONE_OUT=%MAP_BASE%\zone_out"

if not exist "%OAT_BASE%" (
    echo Downloading OAT...
    powershell -Command "Invoke-WebRequest -Uri https://github.com/Laupetin/OpenAssetTools/releases/latest/download/oat-windows.zip -OutFile oat-windows.zip"
    
    echo Extracting OAT...
    powershell -Command "Expand-Archive -Path oat-windows.zip -DestinationPath '%OAT_BASE%' -Force"
    
    del oat-windows.zip
    
    echo OAT has been successfully downloaded and extracted.
    echo.
    echo.
    echo.
)

:: frontend.ff, have to remove the soundbank
"%OAT_BASE%\Linker.exe" ^
--load "%BIN_PATH%\common.ff" ^
--load "%BIN_PATH%\zm_transit.ff" ^
--load "%BIN_PATH%\zm_transit_patch.ff" ^
--load "%BIN_PATH%\frontend.ff" ^
--load "%BIN_PATH%\so_zsurvival_zm_transit.ff" ^
--base-folder "%MAP_BASE%\frontend" ^
--add-asset-search-path "%COMMON_PATH%" ^
--add-asset-search-path "%MAP_BASE%" ^
--add-source-search-path "%SOURCE_PATH%" ^
--add-source-search-path "%SOURCE_PATH_TEMPLATED%" ^
--output-folder "%ZONE_OUT%" frontend

echo.
echo.
echo.

:: en_frontend.ff, have to remove the soundbank
"%OAT_BASE%\Linker.exe" ^
--base-folder "%MAP_BASE%\en_frontend" ^
--add-asset-search-path "%COMMON_PATH%" ^
--add-asset-search-path "%MAP_BASE%\en_frontend" ^
--add-source-search-path "%SOURCE_PATH%" ^
--add-source-search-path "%SOURCE_PATH_TEMPLATED%" ^
--output-folder "%ZONE_OUT%" en_frontend

echo.
echo.
echo.

:: mod.ff
"%OAT_BASE%\Linker.exe" ^
--load "%BIN_PATH%\common.ff" ^
--load "%BIN_PATH%\zm_transit.ff" ^
--load "%BIN_PATH%\zm_transit_patch.ff" ^
--load "%BIN_PATH%\so_zsurvival_zm_transit.ff" ^
--base-folder "%MAP_BASE%\mod" ^
--add-asset-search-path "%COMMON_PATH%" ^
--add-asset-search-path "%MAP_BASE%" ^
--add-source-search-path "%SOURCE_PATH%" ^
--add-source-search-path "%SOURCE_PATH_TEMPLATED%" ^
--output-folder "%ZONE_OUT%" mod

echo.
echo.
echo.

:: copy to the mods folder
set err=%ERRORLEVEL%

if %err% EQU 0 (
    XCOPY "%ZONE_OUT%" "%LOCALAPPDATA%\Plutonium\storage\t6\mods\%MOD_NAME%" /Y /D /H /K /I
) ELSE (
    COLOR C
    echo FAILED!
)

echo Compiled mod moved to "%LOCALAPPDATA%\Plutonium\storage\t6\mods\%MOD_NAME%".
pause