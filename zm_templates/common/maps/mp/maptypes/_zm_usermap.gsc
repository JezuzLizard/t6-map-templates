#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;

#include maps\mp\maptypes\_zm_usermap_utility;

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
	level._is_clienside = false;

	level._alphabet_array = [];

	alpha_string = "abcdefghijklmnopqrstuvwxyz";

	for ( i = 0; i < alpha_string.size; i++ )
	{
		level._alphabet_array[ alpha_string[ i ] ] = i;
	}

	level._numeric_array = [];

	numeric_string = "0123456789";

	for ( i = 0; i < numeric_string.size; i++ )
	{
		level._numeric_array[ numeric_string[ i ] ] = i;
	}

	level._number_strings = [];
	level._number_strings[ "float" ] = "-.0123456789";
	level._number_strings[ "positive_float" ] = ".0123456789";
	level._number_strings[ "int" ] = "-0123456789";
	level._number_strings[ "positive_int" ] = "0123456789";
	level._number_strings[ "natural_int" ] = "123456789";

	level._include_fx_columns = [];
	level._include_fx_columns[ level._include_fx_columns.size ] = "index";
	level._include_fx_columns[ level._include_fx_columns.size ] = "fx_name";
	level._include_fx_columns[ level._include_fx_columns.size ] = "asset_name";

	level._add_zombie_weapons = [];
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "index";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "weapon_name";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "upgrade_name";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "hint";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "cost";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "weapon_voice_over";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "weapon_voice_over_response";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "ammo_cost";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "create_vox";

	level._include_powerups_columns = [];
	level._include_powerups_columns[ level._include_powerups_columns.size ] = "index";
	level._include_powerups_columns[ level._include_powerups_columns.size ] = "powerup_name";
	level._include_powerups_columns[ level._include_powerups_columns.size ] = "override";

	level._include_weapons_columns = [];
	level._include_weapons_columns[ level._include_weapons_columns.size ] = "index";
	level._include_weapons_columns[ level._include_weapons_columns.size ] = "weapon_name";
	level._include_weapons_columns[ level._include_weapons_columns.size ] = "in_box";
	level._include_weapons_columns[ level._include_weapons_columns.size ] = "limit_count";
}

start_zombie_mode( init_zones )
{
	maps\mp\zombies\_zm::init();
	precacheitem( "death_throe_zm" );

	if ( !isdefined( level.culldist ) )
	{
		level.culldist = 5500;
	}
	setculldist( level.culldist );

	level.zones = [];

	level thread maps\mp\zombies\_zm_zonemgr::manage_zones( init_zones );

	level.player_out_of_playable_area_monitor = false;

	// adjust these if the map is too small
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

assert_include_weapon_entry( weapon_res, in_box_res, limit_res )
{
	assert( !weapon_res.is_null );
	assert( !weapon_res.errored );
	assert( !in_box_res.errored );
	assert( !limit_res.errored );

	success = !weapon_res.is_null && !weapon_res.errored && !in_box_res.errored && !limit_res.errored;
	return success;
}

assert_include_weapon_success( weapon_name )
{
	assert( _WEAPON_EXISTS( weapon_name ) ); // precached failed...
}

include_weapons()
{
	succeeded = set_working_table( "zm/include_weapons.csv" );
	if ( !succeeded )
	{
		// no "zm/include_weapons.csv" was found to parse, user will need to define the weapons manually
		assert( false );
		return;
	}

	table = get_working_table();
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		set_working_row_num( index );
		weapon_name_result = get_csv_str( 1 ); // required
		in_box_result = get_csv_bool( 2 ); // optional
		limit_count_result = get_csv_int( 3 ); // optional

		if ( !assert_include_weapon_entry( weapon_name_result, in_box_result, limit_count_result ) )
		{
			continue;
		}

		if ( !in_box_result.is_null )
		{
			include_weapon( weapon_name_result.value, in_box_result.value );
		}
		else
		{
			include_weapon( weapon_name_result.value );
		}

		if ( !limit_count_result.is_null )
		{
			add_limited_weapon( weapon_name_result.value, limit_count_result.value );
		}

		assert_include_weapon_success( weapon_name_result.value );
	}

	set_working_table( undefined );
	set_working_row_num( undefined );
}

assert_include_powerup_entry( powerup_res )
{
	assert( !powerup_res.is_null );
	assert( !powerup_res.errored );

	success = !powerup_res.is_null && !powerup_res.errored;
	return success;
}

include_powerups()
{
	succeeded = set_working_table( "zm/include_powerups.csv" );
	if ( !succeeded )
	{
		// no "zm/include_powerups.csv" was found to parse, user will need to define the powerups manually
		assert( false );
		return;
	}

	table = get_working_table();
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		set_working_row_num( index );
		powerup_name_res = get_csv_str( 1 ); // required

		if ( !assert_include_powerup_entry( powerup_name_res ) )
		{
			continue;
		}

		include_powerup( powerup_name_res.value );
	}

	set_working_table( undefined );
	set_working_row_num( undefined );
}

assert_include_fx_success( fx_alias, asset_name )
{
	if ( !isdefined( level._effect[ fx_alias ] ) )
	{
		assert( false );
		println( "*******Missing map fx, alias: '" + fx_alias + "', asset: '" + asset_name + "'" );
	}
}

add_map_fx( fx_alias, asset_name )
{
	level._effect[ fx_alias ] = loadfx( asset_name );
	assert_include_fx_success( fx_alias, asset_name );
}

assert_include_fx_entry( alias_res, asset_res, override_res )
{
	assert( !alias_res.errored );
	assert( !alias_res.is_null );
	assert( !asset_res.errored );
	assert( !asset_res.is_null );
	assert( !override_res.errored );
	if ( !override_res.value )
	{
		assert( !isdefined( level._effect[ alias_res.value ] ) );
	}
	
	override_allowed = override_res.value;
	if ( !alias_res.errored && !alias_res.is_null && isdefined( level._effect[ alias_res.value ] ) )
	{
		if ( !override_allowed )
		{
			println( "*******FX: '" + alias_res.value + "', asset: '" + asset_res.value + "' is overriding an existing FX, specify the 'override' column as TRUE to force override anyway" );
			return false;
		}
	}

	success = !alias_res.errored && !alias_res.is_null && !asset_res.errored && !asset_res.is_null;
	return success;
}

include_fx()
{
	succeeded = set_working_table( "zm/include_fx.csv" );
	if ( !succeeded )
	{
		// no "zm/include_fx.csv" was found to parse, user will need to define the fx manually
		assert( false );
		return;
	}

	table = get_working_table();
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		set_working_row_num( index );
		alias_res = get_csv_str( 1 ); // required
		asset_res = get_csv_str( 2 ); // required
		override_res = get_csv_bool( 3 ); // optional
		override_res.value = _DEFAULT( override_res.value, false );

		if ( !assert_include_fx_entry( alias_res, asset_res, override_res ) )
		{
			continue;
		}

		add_map_fx( alias_res.value, asset_res.value );
	}

	set_working_table( undefined );
	set_working_row_num( undefined );
}

assert_add_zombie_weapon_entry( weapon_res, upgrade_name_res, hint_res, cost_res, weapon_voice_over_res, weapon_voice_over_response_res, ammo_cost_res, create_vox_res )
{
	assert( !weapon_res.is_null );
	assert( !weapon_res.errored );

	success_weapon_name = !weapon_res.is_null && !weapon_res.errored;
	if ( !success_weapon_name )
	{
		return false;
	}

	assert( !upgrade_name_res.errored );

	success_upgrade_name = !weapon_res.errored;
	if ( !success_upgrade_name )
	{
		return false;
	}

	assert( !hint_res.is_null );
	assert( !hint_res.errored );

	success_hint = isdefined( hint_res.value );
	if ( !success_hint )
	{
		return false;
	}

	assert( !cost_res.is_null );
	assert( !cost_res.errored );

	success_cost = isdefined( cost_res.value );
	if ( !success_cost )
	{
		return false;
	}

	assert( !weapon_voice_over_res.errored );

	success_weaponvo = !weapon_voice_over_res.errored;
	if ( !success_weaponvo )
	{
		return false;
	}

	assert( !weapon_voice_over_response_res.errored );

	success_weaponvo_response = !weapon_voice_over_response_res.errored;
	if ( !success_weaponvo_response )
	{
		return false;
	}

	assert( !ammo_cost_res.errored );

	success_ammo_cost = !ammo_cost_res.errored;
	if ( !success_ammo_cost )
	{
		return false;
	}

	assert( !create_vox_res.errored );

	success_create_vox = !create_vox_res.errored;
	if ( !success_create_vox )
	{
		return false;
	}

	return true;
}

add_zombie_weapons()
{
	succeeded = set_working_table( "zm/add_zombie_weapons.csv" );
	if ( !succeeded )
	{
		// no "zm/add_zombie_weapons.csv" was found to parse, user will need to define the add weapons manually
		assert( false );
		return;
	}

	table = get_working_table();
	level._usermap_add_weapons = [];
	for ( index = 0; tablelookuprownum( table, 0, index ) != -1; index++ )
	{
		set_working_row_num( index );
		weapon_name_res = get_csv_str( 1 ); // required
		upgrade_name_res = get_csv_str( 2 ); // optional
		hint_res = get_csv_str( 3 ); // required
		cost_res = get_csv_int( 4 ); // required
		weapon_voice_over_res = get_csv_str( 5 ); // optional
		weapon_voice_over_response_res = get_csv_str( 6 ); // optional
		ammo_cost_res = get_csv_int( 7 ); // optional
		create_vox_res = get_csv_bool( 8 ); // optional

		if ( !assert_add_zombie_weapon_entry( weapon_name_res, upgrade_name_res, hint_res, cost_res, weapon_voice_over_res, weapon_voice_over_response_res, ammo_cost_res, create_vox_res ) )
		{
			continue;
		}

		hint = istring( hint_res.value );
		cost = cost_res.value;
		ammo_cost = ammo_cost.value;
		weapon_voice_over = isdefined( weapon_voice_over_res.value ) ? weapon_voice_over_res.value : "";
		weapon_voice_over_response = isdefined( weapon_voice_over_response_res.value ) ? weapon_voice_over_response_res.value : "";
		create_vox = is_true( create_vox_res.value ) ? true : undefined;

		add_weapon = spawnstruct();
		add_weapon.name = weapon_name_res.value;
		add_weapon.upgrade_name = isdefined( upgrade_name_res.value ) ? upgrade_name_res.value : undefined;
		add_weapon.hint = hint;
		add_weapon.cost = cost;
		add_weapon.ammo_cost = ammo_cost;
		add_weapon.weaponvo = weapon_voice_over;
		add_weapon.weaponvoresp = weapon_voice_over_response;
		add_weapon.create_vox = create_vox;

		level._usermap_add_weapons[ level._usermap_add_weapons.size ] = add_weapon;
	}

	set_working_table( undefined );
	set_working_row_num( undefined );
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
		add_zombie_weapon( weapon.name, weapon.upgrade_name, weapon.hint, weapon.cost, weapon.weaponvo, weapon.weaponvoresp, weapon.ammo_cost, weapon.create_vox );
	}

	// kill the array to save some vars
	level._usermap_add_weapons = undefined;
}