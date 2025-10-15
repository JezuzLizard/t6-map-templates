#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;

// setup autoexec
#include maps\mp\frontend_fx;

main()
{
	maps\mp\maptypes\_zm_usermap::setup_zombie_defaults();
	// you can edit the tables or redirect these calls to your script
	maps\mp\maptypes\_zm_usermap::include_weapons(); // zm/include_weapons.csv
	maps\mp\maptypes\_zm_usermap::include_powerups(); // zm/include_powerups.csv
	maps\mp\maptypes\_zm_usermap::include_fx(); // zm/include_fx.csv
	maps\mp\maptypes\_zm_usermap::add_zombie_weapons(); // zm/add_zombie_weapons.csv

	// map specific setup here
	maps\mp\_sticky_grenade::init();
	level.givecustomloadout = ::givecustomloadout;
	level.zombie_init_done = ::zombie_init_done;
	
	// perk opt ins
	level.zombiemode_using_pack_a_punch = 1;
	level.zombiemode_reusing_pack_a_punch = 1;
	level.zombiemode_using_doubletap_perk = 1;
	level.zombiemode_using_juggernaut_perk = 1;
	level.zombiemode_using_marathon_perk = 1;
	level.zombiemode_using_revive_perk = 1;
	level.zombiemode_using_sleightofhand_perk = 1;
	level.zombiemode_using_tombstone_perk = 1;

	setup_characters();

	level.zone_manager_init_func = ::zone_init;

	init_zones[0] = "war_room_volume";
	maps\mp\maptypes\_zm_usermap::start_zombie_mode( init_zones );
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

zone_init()
{

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