import os
import subprocess
import shutil
import urllib.request
import zipfile

MOD_NAME = "zm_castaway"
MAP_NAME = "mp_castaway"
CWD = os.path.dirname(os.path.abspath(__file__))

OAT_PATH = os.path.join(CWD, "..", "oat")
ASSETS_PATH = os.path.join(CWD, "..", "assets")
SOUND_PATH = os.path.join(ASSETS_PATH, "sound")
ZONE_PATH = os.path.join(ASSETS_PATH, "zone")
COMMON_PATH = os.path.join(CWD, "..", "common")

SOURCE_PATH = os.path.join(CWD, "zone_source")
ZONE_OUT_PATH = os.path.join(CWD, "zone_out")
SOURCE_PATH_TEMPLATED = os.path.join(COMMON_PATH, "zone_source")

LOCALAPPDATA = os.environ.get("LOCALAPPDATA") or ""
PLUTO_MODS_DIR = os.path.join(LOCALAPPDATA, "Plutonium", "storage", "t6", "mods")

ZONE_ALL = "zone\\all"
REQUIRED_FILES = [
    f"{ZONE_PATH}\\mp_castaway.ff",
    
    f"{ZONE_PATH}\\code_post_gfx.ff",
    f"{ZONE_PATH}\\common_mp.ff",
    f"{ZONE_PATH}\\common_zm.ff",
    
    # override whatever assets got loaded from the other maps
    f"{ZONE_PATH}\\zm_nuked.ff",
    f"{ZONE_PATH}\\zm_tomb.ff",
    f"{ZONE_PATH}\\zm_transit.ff",
    f"{ZONE_PATH}\\zm_transit_patch.ff",
    f"{ZONE_PATH}\\so_zsurvival_zm_transit.ff"
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
        print("You must place the following files in \"zm_templates\\assets\\zone\" to compile:\n")
        
        for file in missing_files:
            print(f"- {file.replace(f"{ZONE_PATH}", f"{ZONE_ALL}")}")


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
        "--add-asset-search-path",  f"{SOUND_PATH}\\raw",       # for sound files
        "--add-asset-search-path",  f"{SOUND_PATH}\\devraw",    # for sound files
        "--add-asset-search-path",  f"{SOUND_PATH}\\english",   # for sound files
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
        for file_name, file_info in files.items():
            source_dir = file_info.get("source_dir")
            inner_dir  = file_info.get("inner_dir")

            source_path = os.path.join(source_dir, file_name)
            inner_path  = os.path.join(inner_dir, file_name)

            if not os.path.exists(source_path):
                print(f"Warning: file for mod.iwd not found: \"{source_path}\"")
                continue

            zip.write(source_path, arcname=inner_path)
            print(f"Added {source_path} -> {inner_path}")

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
    
    # mod.json contains information for the Plutonium menu
    shutil.copyfile(os.path.join(CWD, "mod", "mod.json"), os.path.join(pluto_mod_folder, "mod.json"))

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
        os.mkdir(ZONE_PATH)
        os.mkdir(SOUND_PATH)
        print_required_files(REQUIRED_FILES, True)
        return
    
    # no sounds existed
    if not os.path.exists(SOUND_PATH):
        os.mkdir(SOUND_PATH)
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
        
    # override mp_castaway.ff so that its no longer an mp map
    map_zones = [ f"{ZONE_PATH}\\mp_castaway.ff" ]
    link_zone("mp_castaway", map_zones)
    
    # mod.ff
    mod_zones = REQUIRED_FILES
    mod_zones.remove(f"{ZONE_PATH}\\mp_castaway.ff")
    link_zone("mod", mod_zones)
    
    # we have to put certain files in an iwd, otherwise the map just explodes
    # "source_dir" is the folder that the file resides in, its data will be copied to the iwd
    # "inner_dir" is the folder structure that will be used for writing the file to the iwd
    create_mod_iwd({
        "mainlobby.lua": {
            "source_dir": "mod\\ui\\t6",
            "inner_dir": "ui\\t6"
        },
        "mp_castaway.d3dbsp": {
            "source_dir": f"{MAP_NAME}\\maps\\mp",
            "inner_dir": "maps\\mp"
        },
        "mp_castaway.d3dbsp.paths": {
            "source_dir": f"{MAP_NAME}\\maps\\mp",
            "inner_dir": "maps\\mp"
        },
        "specialty_quickrevive_zombies.iwi": {
            "source_dir": "mod\\images",
            "inner_dir": "images"
        },
        "specialty_juggernaut_zombies.iwi": {
            "source_dir": "mod\\images",
            "inner_dir": "images"
        },
        "specialty_fastreload_zombies.iwi": {
            "source_dir": "mod\\images",
            "inner_dir": "images"
        },
        "specialty_doubletap_zombies.iwi": {
            "source_dir": "mod\\images",
            "inner_dir": "images"
        },
    })
    
    # for convenience purposes, copy it to the mods folder automatically
    copy_to_pluto()

    print(f"\nCopied \"zone_out\" to \"{PLUTO_MODS_DIR}\\{MOD_NAME}\".")
    print("Finished compiling!")

if __name__ == "__main__":
    main()