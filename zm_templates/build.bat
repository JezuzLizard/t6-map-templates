@echo off
set "MOD_NAME=zm_frontend"
set "OAT_BASE=%cd%\oat"
set "BIN_PATH=%cd%\bin"
set "COMMON_PATH=%cd%\common"
set "SOURCE_PATH=%cd%\%MOD_NAME%\zone_source"
set "MAP_BASE=%cd%\%MOD_NAME%"

if not exist "%OAT_BASE%" (
    echo Downloading OpenAssetTools...
    powershell -Command "Invoke-WebRequest -Uri https://github.com/Laupetin/OpenAssetTools/releases/latest/download/oat-windows.zip -OutFile oat-windows.zip"
    
    echo Extracting OpenAssetTools...
    powershell -Command "Expand-Archive -Path oat-windows.zip -DestinationPath '%OAT_BASE%' -Force"
    
    del oat-windows.zip
    
    echo OpenAssetTools has been successfully downloaded and extracted.
    echo.
)

:: frontend.ff, have to remove the soundbank
"%OAT_BASE%\Linker.exe" ^
-v ^
--load "%BIN_PATH%\frontend.ff" ^
--base-folder "%MAP_BASE%\frontend" ^
--add-asset-search-path "%COMMON_PATH%" ^
--add-asset-search-path "%MAP_BASE%" ^
--source-search-path "%SOURCE_PATH%" ^
--output-folder "%MAP_BASE%" frontend

:: en_frontend.ff, have to remove the soundbank
"%OAT_BASE%\Linker.exe" ^
-v ^
--base-folder "%MAP_BASE%\en_frontend" ^
--add-asset-search-path "%COMMON_PATH%" ^
--add-asset-search-path "%MAP_BASE%" ^
--source-search-path "%SOURCE_PATH%" ^
--output-folder "%MAP_BASE%" en_frontend

:: mod.ff
"%OAT_BASE%\Linker.exe" ^
-v ^
--load "bin\common.ff" ^
--load "bin\common_zm.ff" ^
--load "bin\patch_zm.ff" ^
--load "bin\zm_transit.ff" ^
--load "bin\zm_transit_patch.ff" ^
--load "bin\so_zsurvival_zm_transit.ff" ^
--base-folder "%MAP_BASE%\mod" ^
--add-asset-search-path "%COMMON_PATH%" ^
--add-asset-search-path "%MAP_BASE%" ^
--source-search-path "%SOURCE_PATH%" ^
--output-folder "%MAP_BASE%" mod