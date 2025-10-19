#include clientscripts\mp\_utility;
#include clientscripts\mp\zombies\_zm_weapons;
#include clientscripts\mp\zombies\_zm_utility;
#include clientscripts\mp\zombies\_zm_weap_slipgun;

// setup autoexecs
#include clientscripts\mp\frontend_fx;

// Script mover flags
#define CLIENT_FLAG_HOLO_RED		14
#define CLIENT_FLAG_HOLO_VISIBLE	15

main()
{
	clientscripts\mp\maptypes\_zm_usermap::setup_zombie_defaults();

	// you can edit the tables or redirect these calls to your map script
	clientscripts\mp\maptypes\_zm_usermap::include_weapons(); // zm/zm_weapons.csv
	clientscripts\mp\maptypes\_zm_usermap::include_powerups(); // zm/include_powerups.csv
	clientscripts\mp\maptypes\_zm_usermap::include_fx(); // zm/include_fx.csv

	//register_clientflag_callback( "scriptmover", CLIENT_FLAG_HOLO_RED, ::set_hologram_red );
	//register_clientflag_callback( "scriptmover", CLIENT_FLAG_HOLO_VISIBLE, ::set_hologram_shown );

	level.zombiemode_using_doubletap_perk = 1;
	level.zombiemode_using_juggernaut_perk = 1;
	level.zombiemode_using_marathon_perk = 1;
	level.zombiemode_using_revive_perk = 1;
	level.zombiemode_using_sleightofhand_perk = 1;
	level.zombiemode_using_tombstone_perk = 0;

	clientscripts\mp\zombies\_zm_weap_slipgun::init();

	// blue
	level._override_eye_fx = level._effect["blue_eyes"];
	
	clientscripts\mp\maptypes\_zm_usermap::start_zombie_mode();
	thread clientscripts\mp\frontend_amb::main();

	waitforclient( 0 );
	println( "*** Client : '" + level.script + "' map running..." );
}