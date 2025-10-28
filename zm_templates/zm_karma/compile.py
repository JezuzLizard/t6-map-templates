import os
import subprocess
import shutil
import urllib.request
import zipfile

MOD_NAME = "zm_karma"
MAP_NAME = "karma"
CWD = os.path.dirname(os.path.abspath(__file__))

OAT_PATH = os.path.join(CWD, "..", "oat")
ASSETS_PATH = os.path.join(CWD, "..", "assets")
ASSETS_SOUND_PATH = os.path.join(ASSETS_PATH, "sound")
COMMON_PATH = os.path.join(CWD, "..", "common")

SOURCE_PATH = os.path.join(CWD, "zone_source")
ZONE_OUT_PATH = os.path.join(CWD, "zone_out")
SOURCE_PATH_TEMPLATED = os.path.join(COMMON_PATH, "zone_source")

LOCALAPPDATA = os.environ.get("LOCALAPPDATA") or ""
PLUTO_MODS_DIR = os.path.join(LOCALAPPDATA, "Plutonium-staging", "storage", "t6", "mods")

ZONE_ALL = "zone\\all"
REQUIRED_FILES = [
    f"{ASSETS_PATH}\\karma.ff",
    
    f"{ASSETS_PATH}\\code_post_gfx.ff",
    f"{ASSETS_PATH}\\common.ff",
    f"{ASSETS_PATH}\\common_zm.ff",
    f"{ASSETS_PATH}\\zm_tomb.ff",
    f"{ASSETS_PATH}\\zm_transit.ff",
    f"{ASSETS_PATH}\\zm_transit_patch.ff",
    f"{ASSETS_PATH}\\so_zsurvival_zm_transit.ff",
]

def download_oat():
    print("OAT install not detected, downloading it.")
    
    # sticking with a set version because newer ones might introduce build problems later
    url = "https://github.com/Laupetin/OpenAssetTools/releases/download/v0.24.1/oat-windows.zip"
    zip_path = os.path.join(CWD, "..", "oat.zip")    
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

def print_required_files(missing_files, show_list, sounds_required = False):
    if show_list:
        print("You must place the following files in \"zm_templates\\assets\" to compile:\n")
        
        for file in missing_files:
            print(f"- {file.replace(f"{ASSETS_PATH}", f"{ZONE_ALL}")}")


    # typically you will only need tranzit and the common_zm extracted, but it doesn't hurt to have every sound extracted
    if sounds_required:
        print("You also will need to use Black Ops II Sound Studio to extract all of the vanilla sound files to \"zm_templates\\assets\\sound\" to compile.")
        print("It is important that the \"raw\" and \"devraw\" folders go inside of \"sound\".")
        
    print("\nYou can obtain all of these files from your game folder on Steam.\n")
    input("Press the Enter key to exit...")

def link_zone(zone_name, zone_deps = []):
    oat_command = [
        f"{OAT_PATH}\\Linker.exe",
        "--base-folder",            os.path.join(CWD, zone_name),
        "--add-asset-search-path",  os.path.join(CWD, zone_name),
        "--add-asset-search-path",  f"{ASSETS_PATH}\\sound\\raw",       # for sound files
        "--add-asset-search-path",  f"{ASSETS_PATH}\\sound\\devraw",    # for sound files
        "--add-asset-search-path",  f"{ASSETS_PATH}\\sound\\english",   # for sound files
        "--add-asset-search-path",  COMMON_PATH,
        "--add-source-search-path", SOURCE_PATH,
        "--add-source-search-path", SOURCE_PATH_TEMPLATED,
        "--output-folder",          ZONE_OUT_PATH,
        zone_name
    ]
    
    # each of the zones being loaded needs to be added to the command
    for to_load in zone_deps:
        oat_command.extend([ "--load", f"{to_load}" ])
    
    subprocess.run(oat_command, cwd=CWD, universal_newlines=True, check=True)

def create_mod_iwd(files):
    print(f"Building iwd \"mod\"")
    iwd_path = os.path.join(ZONE_OUT_PATH, "mod.iwd")
    
    with zipfile.ZipFile(iwd_path, "w", zipfile.ZIP_DEFLATED) as zip:
        for file_name, inner_dir in files.items():
            source_path = os.path.join(CWD, MAP_NAME, inner_dir, f"{file_name}")
            inner_path  = os.path.join(inner_dir, file_name) # the path inside the iwd itself
            rel_path    = os.path.relpath(inner_path, CWD)
            
            if not os.path.exists(source_path):
                print(f"Warning: file for mod.iwd was not found: \"{file_name}\"")
                continue
            
            zip.write(source_path, arcname=rel_path)    

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
    if not os.path.exists(ASSETS_PATH):
        os.mkdir(ASSETS_PATH)
        os.mkdir(ASSETS_SOUND_PATH)
        print_required_files(REQUIRED_FILES, True)
        return
    
    # no sounds existed
    if not os.path.exists(ASSETS_SOUND_PATH):
        os.mkdir(ASSETS_SOUND_PATH)
        print_required_files([], False, True)
        return
    
    # it exists so they might be missing a fastfile or two
    missing_files = has_required_files()
    if missing_files:
        print_required_files(missing_files, True)
        return
        
    # remove the old zone_out
    if os.path.exists(ZONE_OUT_PATH):
        shutil.rmtree(ZONE_OUT_PATH)
        
    # karma.ff, removes the soundbank
    karma_zones = [ f"{ASSETS_PATH}\\karma.ff" ]
    link_zone("karma", karma_zones)
    
    # en_karma.ff, removes the soundbank
    link_zone("en_karma")
    
    # mod.ff
    mod_zones = REQUIRED_FILES
    mod_zones.remove(f"{ASSETS_PATH}\\karma.ff")
    link_zone("mod", mod_zones)
    
    # we have to override the mapents and pathnodes, otherwise the map doesnt load
    create_mod_iwd({
        "karma.d3dbsp":          "maps/mp",
        "karma.d3dbsp.paths":    "maps/mp",
    })
    
    # for convenience purposes, copy it to the mods folder automatically
    copy_to_pluto()

    print(f"\nCopied \"zone_out\" to \"{PLUTO_MODS_DIR}\\{MOD_NAME}\".")
    print("Finished compiling!")
    input("Press the Enter key to exit...")

if __name__ == "__main__":
    main()