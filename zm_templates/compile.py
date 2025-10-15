import os
import subprocess
import shutil
import urllib.request
import zipfile

MOD_NAME = "zm_frontend"
CWD = os.path.dirname(os.path.abspath(__file__))

OAT_PATH = os.path.join(CWD, "oat")
BIN_PATH = os.path.join(CWD, "bin")
MOD_PATH = os.path.join(CWD, MOD_NAME)

COMMON_PATH = os.path.join(CWD, "common")
SOURCE_PATH = os.path.join(MOD_PATH, "zone_source")
SOURCE_PATH_TEMPLATED = os.path.join(COMMON_PATH, "zone_source")
ZONE_OUT_PATH = os.path.join(MOD_PATH, "zone_out")

LOCALAPPDATA = os.environ.get("LOCALAPPDATA") or ""
PLUTO_MODS_DIR = os.path.join(LOCALAPPDATA, "Plutonium", "storage", "t6", "mods")

ZONE_ALL = "zone\\all"
REQUIRED_FILES = [
    f"{BIN_PATH}\\frontend.ff",
    f"{BIN_PATH}\\frontend_gump_sf_a.ff",
    f"{BIN_PATH}\\code_post_gfx.ff",
    f"{BIN_PATH}\\common.ff",
    f"{BIN_PATH}\\common_zm.ff",
    f"{BIN_PATH}\\zm_tomb.ff",
    f"{BIN_PATH}\\zm_transit.ff",
    f"{BIN_PATH}\\zm_transit_patch.ff",
    f"{BIN_PATH}\\so_zsurvival_zm_transit.ff",
]

def download_oat():
    print("OAT install not detected, downloading it.")
    
    # sticking with a set version because newer ones might introduce build problems later
    url = "https://github.com/Laupetin/OpenAssetTools/releases/download/v0.24.1/oat-windows.zip"
    zip_path = os.path.join(CWD, "oat.zip")    
    urllib.request.urlretrieve(url, zip_path)
    
    # we have to extract it now
    print("OAT downloaded, extracting.")
    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        zip_ref.extractall(OAT_PATH)

    # remove the remaining zip file
    os.remove(zip_path)

def has_required_files():
    has_files = 1
    
    for req_file in REQUIRED_FILES:
        if not os.path.exists(req_file):
            has_files = 0
            break
    
    return bool(has_files)

def print_required_files():
    print("You must place the following files in \"zm_templates\\bin\" to compile:\n")
    
    for file in REQUIRED_FILES:
        print(f"- {file.replace(f"{BIN_PATH}", f"{ZONE_ALL}")}")
        
    print("\nYou can obtain them from your game folder on Steam.\n")
    input("Press the Enter key to exit...")

def link_zone(zone_name, zone_deps = []):
    print(f"Compiling zone \"{zone_name}\"\n")
    
    zone_path = f"{MOD_PATH}\\{zone_name}"
    oat_command = [
        f"{OAT_PATH}\\Linker.exe",
        "--base-folder",            f"{zone_path}",
        "--add-asset-search-path",  f"{COMMON_PATH}",
        "--add-asset-search-path",  f"{zone_path}",
        "--add-source-search-path", f"{SOURCE_PATH}",
        "--add-source-search-path", f"{SOURCE_PATH_TEMPLATED}",
        "--output-folder",          f"{ZONE_OUT_PATH}",
        f"{zone_name}"
    ]
    
    # each of the zones being loaded needs to be added to the command
    for to_load in zone_deps:
        oat_command.extend([ "--load", f"{to_load}" ])
    
    subprocess.run(oat_command, cwd=CWD, universal_newlines=True, check=True)

def create_bsp_iwd():    
    bsp_name =      "frontend.d3dbsp"
    bsp_path =      os.path.join(CWD, "zm_frontend", "frontend", "maps", "mp", f"{bsp_name}")
    iwd_name =      os.path.join(ZONE_OUT_PATH, "mod.iwd")
    internal_path = os.path.join("maps", "mp", f"{bsp_name}")
    rel_path =      os.path.relpath(internal_path, CWD)
    
    print(f"Writing frontend.d3dbsp to mod.iwd.")
    
    # iwds are just zip files with a special extension
    with zipfile.ZipFile(iwd_name, "w", zipfile.ZIP_DEFLATED) as zip:
        zip.write(bsp_path, arcname=rel_path)

def copy_to_pluto():
    destination_root = PLUTO_MODS_DIR
    pluto_mod_folder = os.path.join(destination_root, MOD_NAME)
    os.makedirs(destination_root, exist_ok=True)
    
    # remove the old mod folder
    if os.path.exists(pluto_mod_folder):
        shutil.rmtree(pluto_mod_folder)
    
    # now copy it
    shutil.copytree(ZONE_OUT_PATH, pluto_mod_folder)

def main():
    print("")
    os.chdir(CWD)
    
    # they might not have oat
    if not os.path.exists(OAT_PATH):
        download_oat()
        print("Done, continuing with compile.")
    
    if not os.path.exists(BIN_PATH):
        os.mkdir(BIN_PATH)
        print_required_files()
        return
    
    if not has_required_files():
        print_required_files()
        return
        
    # remove the old zone_out
    if os.path.exists(ZONE_OUT_PATH):
        shutil.rmtree(ZONE_OUT_PATH)
        
    # frontend.ff, removes the soundbank
    frontend_zones = [ f"{BIN_PATH}\\frontend.ff" ]
    link_zone("frontend", frontend_zones)
    
    # en_frontend.ff, removes the soundbank
    link_zone("en_frontend")
    
    # mod.ff
    mod_zones = [
        f"{BIN_PATH}\\code_post_gfx.ff",
        f"{BIN_PATH}\\frontend_gump_sf_a.ff",
        f"{BIN_PATH}\\common.ff",
        f"{BIN_PATH}\\common_zm.ff",
        f"{BIN_PATH}\\zm_tomb.ff",
        f"{BIN_PATH}\\zm_transit.ff",
        f"{BIN_PATH}\\zm_transit_patch.ff",
        f"{BIN_PATH}\\so_zsurvival_zm_transit.ff",
    ]
    link_zone("mod", mod_zones)
    
    # we have to override the bsp, otherwise the map doesnt load
    create_bsp_iwd()
    
    # for convenience purposes, copy it to the mods folder automatically
    copy_to_pluto()

    print(f"\nCopied zone_out to \"{PLUTO_MODS_DIR}\\{MOD_NAME}\".")
    print("Finished compiling!")
    input("Press the Enter key to exit...")

if __name__ == "__main__":
    main()