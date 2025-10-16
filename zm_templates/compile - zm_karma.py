import os
import subprocess
import shutil
import urllib.request
import zipfile

MOD_NAME = "zm_karma"
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
    f"{BIN_PATH}\\karma.ff",
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
    missing_files = []

    for req_file in REQUIRED_FILES:
        if not os.path.exists(req_file):
            missing_files.append(req_file)

    return missing_files

def print_required_files(missing_files):
    print("You must place the following files in \"zm_templates\\bin\" to compile:\n")

    for file in missing_files:
        print(f"- {file.replace(f"{BIN_PATH}", f"{ZONE_ALL}")}")

    print("\nYou can obtain them from your game folder on Steam.\n")
    input("Press the Enter key to exit...")

def link_zone(zone_name, zone_deps = []):
    zone_path = f"{MOD_PATH}\\{zone_name}"
    
    oat_command = [
        f"{OAT_PATH}\\Linker.exe",
        "--base-folder",            f"{zone_path}",
        "--add-asset-search-path",  f"{zone_path}",
        "--add-asset-search-path",  f"{COMMON_PATH}",
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
    bsp_name =              "karma.d3dbsp"
    iwd_path =              os.path.join(ZONE_OUT_PATH, "mod.iwd")
    source_bsp_path =       os.path.join(CWD, "zm_karma", "karma", "maps", "mp", f"{bsp_name}")
    inner_bsp_path =        os.path.join("maps", "mp", f"{bsp_name}") # the path inside the iwd itself
    rel_bsp_path =          os.path.relpath(inner_bsp_path, CWD)
    
    print(f"Building iwd \"mod\"")
    
    # iwds are just zip files with a special extension
    with zipfile.ZipFile(iwd_path, "w", zipfile.ZIP_DEFLATED) as zip:
        zip.write(source_bsp_path, arcname=rel_bsp_path)

    print(f"Created iwd \"mod\"")

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
    
    # the folder didnt exist so just print everything
    if not os.path.exists(BIN_PATH):
        os.mkdir(BIN_PATH)
        print_required_files(REQUIRED_FILES)
        return
    
    # it exists so they might be missing a fastfile or two
    missing_files = has_required_files()
    if missing_files:
        print_required_files(missing_files)
        return
        
    # remove the old zone_out
    if os.path.exists(ZONE_OUT_PATH):
        shutil.rmtree(ZONE_OUT_PATH)
        
    # karma.ff, removes the soundbank
    karma_zones = [ f"{BIN_PATH}\\karma.ff" ]
    link_zone("karma", karma_zones)
    
    # en_karma.ff, removes the soundbank
    link_zone("en_karma")
    
    # mod.ff
    mod_zones = [
        f"{BIN_PATH}\\code_post_gfx.ff",
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

    print(f"\nCopied \"zone_out\" to \"{PLUTO_MODS_DIR}\\{MOD_NAME}\".")
    print("Finished compiling!")
    input("Press the Enter key to exit...")

if __name__ == "__main__":
    main()