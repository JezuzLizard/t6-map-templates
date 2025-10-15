#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;

call_function_safe( func, threaded )
{
	threaded = isdefined( threaded ) ? threaded : false;
	if ( !isdefined( func ) )
	{
		assert( false );
		return false;
	}

	level thread [[ func ]]();

	return true;
}

setup_zombie_defaults()
{
	level.script = getdvar( "mapname" );
	level.gametype = getdvar( "g_gametype" );

	maps\mp\zombies\_load::main();

	level.default_start_location = level.script;
	level.default_game_mode = level.gametype;

	maps\mp\zombies\_zm::init_fx();
	maps\mp\animscripts\zm_death::precache_gib_fx();

	level.zombiemode = 1;
	level._no_water_risers = 1;
	level._no_navcards = true;
	level.riser_fx_on_client = 1;

	maps\mp\teams\_teamset_cdc::register();
	maps\mp\teams\_teamset_cdc::level_init();
	maps\mp\gametypes_zm\_spawning::level_use_unified_spawning( 1 );
	level.givecustomloadout = ::givecustomloadout;
	level.enemy_location_override_func = ::enemy_location_override;
	initcharacterstartindex();

	level.zombie_init_done = ::zombie_init_done;
	level.pap_interaction_height = 47;
	level.special_weapon_magicbox_check = ::special_weapon_magicbox_check;
	level._allow_melee_weapon_switching = 1;
	level.raygun2_included = 1;

	level._zombie_custom_add_weapons = ::table_add_weapons;
}

start_zombie_mode( init_zones )
{
	// intentionally after includes
	maps\mp\zombies\_zm::init();
	precacheitem( "death_throe_zm" );

	level.culldist = 5500;
	setculldist( level.culldist );

	level.zones = [];

	level thread maps\mp\zombies\_zm_zonemgr::manage_zones( init_zones );

	// adjust these if that fr is too small
	level.zombie_ai_limit = 24;
	setdvar( "zombiemode_path_minz_bias", 13 );
}

givecustomloadout( takeallweapons, alreadyspawned )
{
	self giveweapon( "knife_zm" );
	self give_start_weapon( 1 );
}

initcharacterstartindex()
{
	level.characterstartindex = 0;
}

zombie_init_done()
{
	self.allowpain = 0;
	self setphysparams( 15, 0, 48 );
}

special_weapon_magicbox_check( weapon )
{
	if ( isdefined( level.raygun2_included ) && level.raygun2_included )
	{
		if ( weapon == "ray_gun_zm" )
		{
			if ( self has_weapon_or_upgrade( "raygun_mark2_zm" ) )
				return false;
		}

		if ( weapon == "raygun_mark2_zm" )
		{
			if ( self has_weapon_or_upgrade( "ray_gun_zm" ) )
				return false;

			if ( randomint( 100 ) >= 33 )
				return false;
		}
	}

	return true;
}

enemy_location_override( zombie, enemy )
{
	location = enemy.origin;

	if ( is_true( self.reroute ) )
	{
		if ( isdefined( self.reroute_origin ) )
			location = self.reroute_origin;
	}

	return location;
}

include_weapons()
{
	table = "zm/include_weapons.csv";
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		weapon_name = tablelookup( table, 0, index, 1);
		in_box = tablelookup( table, 0, index, 2);
		limit_count = tablelookup( table, 0, index, 3);

		in_box_value = false;
		if ( in_box == "" || in_box == "0" || in_box == "false" )
		{
			in_box_value = false;
		}
		else if ( in_box == "1" || in_box == "true" )
		{
			in_box_value = true;
		}

		limit_count_value = undefined;
		if ( limit_count != "" )
		{
			limit_count_value = int( limit_count );
		}

		include_weapon( weapon_name, in_box );

		if ( isdefined( limit_count_value ) )
		{
			add_limited_weapon( weapon_name, limit_count_value );
		}
	}
}

include_powerups()
{
	table = "zm/include_powerups.csv";
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		powerup_name = tablelookup( table, 0, index, 1);

		include_powerup( powerup_name );
	}
}

add_map_fx( fx_alias, asset_name )
{
	level._effect[ fx_alias ] = loadfx( asset_name );
	if ( !isdefined( level._effect[ fx_alias ] ) )
	{
		assert( false );
		println( "*******Missing map fx, alias: '" + fx_alias + "', asset: '" + asset_name + "'" );
	}
}

include_fx()
{
	table = "zm/include_fx.csv";

	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		fx_alias = tablelookup( table, 0, index, 1 );
		asset_name = tablelookup( table, 0, index, 2 );

		// TODO: assert alias is non colliding, and isdefined
		// TODO: assert asset_name isdefined

		add_map_fx( fx_alias, asset_name );
	}
}

add_zombie_weapons()
{
	level._usermap_add_weapons = [];
	table = "zm/add_zombie_weapons.csv";
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		weapon_name = tablelookup( table, 0, index, 1 );
		upgrade_name = tablelookup( table, 0, index, 2 );
		hint = tablelookup( table, 0, index, 3 );
		cost = tablelookup( table, 0, index, 4 );
		ammo_cost = tablelookup( table, 0, index, 5 );
		weapon_voice_over = tablelookup( table, 0, index, 6 );
		create_vox = tablelookup( table, 0, index, 6 );

		if ( hint == "" )
		{
			hint == undefined;
		}
		else
		{
			hint = istring( hint );
		}

		if ( cost == "" )
		{
			cost = 50;
		}
		else
		{
			cost = int( cost );
		}

		if ( ammo_cost == "" )
		{
			ammo_cost = undefined;
		}
		else
		{
			ammo_cost = int( ammo_cost );
		}

		if ( weapon_voice_over == "" )
		{
			weapon_voice_over = "crappy";
		}

		if ( weapon_voice_over_response == "" )
		{
			weapon_voice_over_response = undefined;
		}

		create_vox = false;
		if ( create_vox == "" )
		{
			create_vox = false;
		}
		else if ( create_vox == "1" || create_vox == "true" )
		{
			create_vox = true;
		}

		add_weapon = spawnstruct();
		add_weapon.name = weapon_name;
		add_weapon.upgrade_name = upgrade_name;
		add_weapon.hint = hint;
		add_weapon.cost = cost;
		add_weapon.ammo_cost = ammo_cost;
		add_weapon.weaponvo = weapon_voice_over;
		add_weapon.weaponvoresp = weapon_voice_over_response;
		add_weapon.create_vox = create_vox;

		level._usermap_add_weapons[ level._usermap_add_weapons.size ] = add_weapon;
	}
}

table_add_weapons()
{
	if ( !isdefined( level._usermap_add_weapons ) || level._usermap_add_weapons.size <= 0 )
	{
		return;
	}

	for ( i = 0; i < level._usermap_add_weapons.size; i++ )
	{
		weapon = level._usermap_add_weapons[ i ];
		add_zombie_weapon( weapon.name, weapon.upgrade_name, weapon.hint, weapon.cost, weapon.ammo_cost, weapon.weaponvo, weapon.weaponvoresp, weapon.create_vox );
	}
}