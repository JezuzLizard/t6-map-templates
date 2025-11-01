#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_score;
#include maps\mp\_demo;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;

// setup autoexec
#include maps\mp\frontend_fx;
#include maps\mp\frontend_util;

main()
{
    maps\mp\maptypes\_zm_usermap::setup_zombie_defaults();

    func = GetFunction( "maps/mp/zombies/_zm_blockers", "debris_think" );
    replaceFunc( func, ::frontend_debris_think );

    // you can edit the tables or redirect these calls to your script
    maps\mp\maptypes\_zm_usermap::include_powerups(); // zm/include_powerups.csv
    maps\mp\maptypes\_zm_usermap::include_fx(); // zm/include_fx.csv
    maps\mp\maptypes\_zm_usermap::add_zombie_weapons(); // zm/add_zombie_weapons.csv

    // map specific setup here
    level.enable_magic = getgametypesetting( "magic" );
    maps\mp\_sticky_grenade::init();
    level._melee_weapons = []; // since we dont have bowie or tazers, init as empty

    level._post_zm_overrides_func = ::frontend_post_zm_init;
    level.givecustomloadout = ::givecustomloadout;
    level.zombie_init_done = ::zombie_init_done;
    onplayerconnect_callback( ::frontend_connected );

    // perk opt ins
    level.zombiemode_using_pack_a_punch = 0;
    level.zombiemode_reusing_pack_a_punch = 0;
    level.zombiemode_using_tombstone_perk = 0;
    level.zombiemode_using_revive_perk = 1;
    level.zombiemode_using_juggernaut_perk = 1;
    level.zombiemode_using_marathon_perk = 1;
    level.zombiemode_using_doubletap_perk = 1;
    level.zombiemode_using_sleightofhand_perk = 1;

    // disable loading random tranzit fx
    level.disable_fx_upgrade_aquired = true;
    level.fx_exclude_tesla_head_light = true;
    level.disable_fx_zmb_tranzit_shield_explo = true;

    level.culldist = 5000;
    setup_characters();

    // adjust these if the map is too small
    // custom maps must do this before _zm_usermap::start_zombie_mode
    level.zombie_ai_limit = 18;

    // custom zones go here, zm_frontend has two spawn zones to start off with
    level.zone_manager_init_func = ::frontend_zone_init;
    level.zones = [];
    init_zones[0] = "war_room_volume";
    init_zones[1] = "spawn_room_volume";
    maps\mp\maptypes\_zm_usermap::start_zombie_mode( init_zones );

    // stuff that has to be after zm::init
    frontend_magicbox_init();
    maps\mp\zombies\_zm_weap_slipgun::init();

    level thread sndsetupmusiceasteregg();

    // the spawn room hologram globe
    init_globe();
    level thread open_junk();
}

init_globe()
{
	globe = build_globe();
	float_pos = GetEnt( "holo_table_floating", "targetname" );
	globe.origin = float_pos.origin;

	wait_network_frame();
	show_globe();
}

// once open is opened, open the rest
open_junk()
{
	level waittill( "junk purchased 2", which_debris );
	debris_array = GetEntArray( "zombie_debris", "targetname" );

	foreach ( debris in debris_array )
	{
		if ( debris == which_debris )
		{
			continue;
		}

		debris notify( "trigger", self, true );
	}
}

frontend_magicbox_init()
{
    chest = GetStruct( "frontend_chest", "script_noteworthy" );
    level.chests = [];
    level.chests[level.chests.size] = chest;
	
    maps\mp\zombies\_zm_magicbox::treasure_chest_init( "frontend_chest" );
}

frontend_post_zm_init()
{
	level.player_out_of_playable_area_monitor = true;
	level.player_too_many_weapons_monitor = true;
	level._use_choke_weapon_hints = true;
	level._use_choke_blockers = true;
	level.calc_closest_player_using_paths = false;
	level.zombie_melee_in_water = true;
	level.put_timed_out_zombies_back_in_queue = true;
	level.use_alternate_poi_positioning = true;

    // monkey bombs
    level.legacy_cymbal_monkey = 1;
    maps\mp\zombies\_zm_weap_cymbal_monkey::init();

    // removed power, turn them on by default
    turn_on_perks();
}

turn_on_perks()
{
    flag_wait( "start_zombie_round_logic" );
    wait 1;

    level notify( "revive_on" );
    wait_network_frame();
    level notify( "doubletap_on" );
    wait_network_frame();
    level notify( "marathon_on" );
    wait_network_frame();
    level notify( "juggernog_on" );
    wait_network_frame();
    level notify( "sleight_on" );
}

frontend_connected()
{
	self setclientdvars( "r_lodbiasskinned", "-1000", "r_lodbiasrigid", "-1000" );
}

givecustomloadout( takeallweapons, alreadyspawned )
{
	self giveweapon( "knife_zm" );
	self give_start_weapon( 1 );
}

zombie_init_done()
{
	self.allowpain = 0;
	self setphysparams( 15, 0, 48 );
}

frontend_zone_init()
{
    flag_init( "always_on" );
    flag_set( "always_on" );

    add_adjacent_zone( "spawn_room_volume", "war_room_volume", "always_on" );
    add_adjacent_zone( "war_room_volume", "power_room_volume", "activate_power_zone" );
}

setup_characters()
{
	level.should_use_cia = 1;

	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters;
}

precache_team_characters()
{
	precachemodel( "c_zom_player_cia_fb" );
	precachemodel( "c_zom_suit_viewhands" );
}

give_team_characters()
{
	if ( isdefined( level.hotjoin_player_setup ) && [[ level.hotjoin_player_setup ]]( "c_zom_suit_viewhands" ) )
		return;

	self detachall();
	self set_player_is_female( 0 );
	
	self setmodel( "c_zom_player_cia_fb" );
	self setviewmodel( "c_zom_suit_viewhands" );
	self.characterindex = 0;
	self.voice = "american";
	self.skeleton = "base";

	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
}

sndsetupmusiceasteregg()
{
    origins = [];
    origins[0] = ( 653.227, 428.195, 473.454 );
    origins[1] = ( 193.478, -338.844, 470.201 );
    origins[2] = ( 671, 992, 439 );
    level.meteor_counter = 0;
    level.music_override = 0;

    for ( i = 0; i < origins.size; i++ )
    {
        level thread sndmusicegg( origins[i] );
    }
}

sndmusicegg( bear_origin )
{
    temp_ent = spawn( "script_origin", bear_origin );
    temp_ent playloopsound( "zmb_meteor_loop" );
    temp_ent thread maps\mp\zombies\_zm_sidequests::fake_use( "main_music_egg_hit", ::waitfor_override );
    temp_ent waittill( "main_music_egg_hit", player );
    temp_ent stoploopsound( 1 );
    player playsound( "zmb_meteor_activate" );
    level.meteor_counter = level.meteor_counter + 1;

    if ( level.meteor_counter == 3 )
        level thread sndplaymusicegg( player, temp_ent );
    else
    {
        wait 1.5;
        temp_ent delete();
    }
}

waitfor_override()
{
    if ( isdefined( level.music_override ) && level.music_override )
        return false;

    return true;
}

sndplaymusicegg( player, ent )
{
    wait 1;
    ent playsound( "mus_zmb_secret_song" );
    ent thread waittill_song_over();

    level waittill( "end_game" );
    ent stopsounds();
    wait 0.05;
    ent delete();
}

waittill_song_over()
{
    level endon( "end_game" );

    level.music_override = 1;
    wait 120;
    level.music_override = 0;
}

// edits:
// - support for multiple debris clips
// - when the force variable is set, the trigger will not take additional points
frontend_debris_think()
{
    if ( isdefined( level.custom_debris_function ) )
        self [[ level.custom_debris_function ]]();

    while ( true )
    {
        self waittill( "trigger", who, force );

        if ( getdvarint( #"zombie_unlock_all" ) > 0 || isdefined( force ) && force )
        {

        }
        else
        {
            if ( !who usebuttonpressed() )
                continue;

            if ( who in_revive_trigger() )
                continue;
        }

        if ( is_player_valid( who ) )
        {
            players = get_players();

            if ( getdvarint( #"zombie_unlock_all" ) > 0 )
            {

            }
            else if ( who.score >= self.zombie_cost )
            {
                // only take points if its not forced
                if ( !isdefined( force ) || !force )
                {
                    who maps\mp\zombies\_zm_score::minus_to_player_score( self.zombie_cost );
                }
                
                maps\mp\_demo::bookmark( "zm_player_door", gettime(), who );
                who maps\mp\zombies\_zm_stats::increment_client_stat( "doors_purchased" );
                who maps\mp\zombies\_zm_stats::increment_player_stat( "doors_purchased" );
            }
            else
            {
                play_sound_at_pos( "no_purchase", self.origin );
                who maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "door_deny" );
                continue;
            }

            bbprint( "zombie_uses", "playername %s playerscore %d round %d cost %d name %s x %f y %f z %f type %s", who.name, who.score, level.round_number, self.zombie_cost, self.script_flag, self.origin, "door" );
            junk = getentarray( self.target, "targetname" );
            clips = getentarray( self.target + "_clip", "targetname" );

            if ( isdefined( self.script_flag ) )
            {
                tokens = strtok( self.script_flag, "," );

                for ( i = 0; i < tokens.size; i++ )
                    flag_set( tokens[i] );
            }

            play_sound_at_pos( "purchase", self.origin );
            level notify( "junk purchased" );
            level notify( "junk purchased 2", self );
            move_ent = undefined;

            for ( i = 0; i < junk.size; i++ )
            {
                junk[i] connectpaths();
                struct = undefined;

                if ( isdefined( junk[i].script_linkto ) )
                {
                    struct = getstruct( junk[i].script_linkto, "script_linkname" );

                    if ( isdefined( struct ) )
                    {
                        move_ent = junk[i];
                        junk[i] thread maps\mp\zombies\_zm_blockers::debris_move( struct );
                    }
                    else
                    {
                        junk[i] delete();
                    }

                    continue;
                }

                junk[i] delete();
            }

            all_trigs = getentarray( self.target, "target" );

            for ( i = 0; i < all_trigs.size; i++ )
                all_trigs[i] delete();

            if ( isdefined( move_ent ) )
                move_ent waittill( "movedone" );

            for ( i = 0; i < clips.size; i++ )
                clips[i] delete();

            break;
        }
    }
}