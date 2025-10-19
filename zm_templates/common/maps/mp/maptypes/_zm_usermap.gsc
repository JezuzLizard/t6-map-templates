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

	level._no_water_risers = 1;
	level._no_navcards = true;
	level.riser_fx_on_client = 1;
	level._usermap = true;

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
	// level.zombiemode_reusing_pack_a_punch = true;

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
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "in_box";
	level._add_zombie_weapons[ level._add_zombie_weapons.size ] = "box_limit";

	level._include_powerups_columns = [];
	level._include_powerups_columns[ level._include_powerups_columns.size ] = "index";
	level._include_powerups_columns[ level._include_powerups_columns.size ] = "powerup_name";
	level._include_powerups_columns[ level._include_powerups_columns.size ] = "override";

	setdvar( "zombiemode_path_minz_bias", 13 );

	level.culldist = 5500;

	// adjust these if the map is too small
	if ( !isdefined( level.zombie_ai_limit ) )
	{
		level.zombie_ai_limit = 24;
	}

	level._post_zm_overrides_func = ::post_zm_init_overrides;
}

assert_zone_spawn_locations_validity( spawn_locations )
{
	for ( i = 0; i < spawn_locations.size; i++ )
	{
		loc = spawn_locations[ i ];

		assert( loc.classname == "script_struct" );
		assert( isdefined( loc.origin ) );
		assert( isvec( loc.origin ) );
		assert( isdefined( loc.angles ) );
		assert( isvec( loc.angles ) );
		assert( isdefined( loc.script_noteworthy ) );

		tokens = strtok( loc.script_noteworthy, " " );
		for ( j = 0; j < tokens.size; j++ )
		{
			tok = tokens[ j ];
			switch ( tok )
			{
				case "riser_location":
					break;
				case "dog_location":
					break;
				case "screecher_location":
					break;
				case "avogadro_location":
					break;
				case "inert_location":
					break;
				case "quad_location":
					break;
				case "leaper_location":
					break;
				case "brutus_location":
					break;
				case "mechz_location":
					break;
				case "astro_location":
					break;
				case "napalm_location":
					break;
				default:
					assert( false );
			}

			if ( tok != "brutus_location" && tok != "mechz_location" )
			{
				assert( isdefined( loc.script_string ) );
				assert( loc.script_string == "find_flesh" );
			}
		}
	}
}

assert_zone_entities_validity()
{
	zone_volumes = getentarray( "player_volume", "script_noteworthy" );
	assert( zone_volumes.size > 0 );

	for ( i = 0; i < zone_volumes.size; i++ )
	{
		volume = zone_volumes[ i ];
		assert( volume.classname == "info_volume" );
		targetname = volume.targetname;
		assert( isdefined( targetname ) );
		target = volume.target;
		assert( isdefined( target ) );

		spawn_locations = getentarray( volume.target, "targetname" );
		assert( spawn_locations.size );
		assert_zone_spawn_locations_validity ( spawn_locations );
	}
}

assert_spawner_entities_validity()
{
	spawners = getspawnerarray();
	assert( spawners.size > 0 );

	
}

start_zombie_mode( init_zones )
{
	if ( isarray( init_zones ) )
	{
		assert( init_zones.size > 0 );
	}
	else if ( isstring( init_zones ) )
	{
		assert( init_zones != "" );
	}
	else
	{
		assert( false );
	}

	assert_zone_entities_validity();

	// fix possible script error if map has no limited weapons
	if ( !isdefined( level.limited_weapons ) )
	{
		level.limited_weapons = [];
	}

	maps\mp\zombies\_zm::init();
	precacheitem( "death_throe_zm" );

	setculldist( level.culldist );

	level thread maps\mp\zombies\_zm_zonemgr::manage_zones( init_zones );

	if ( isdefined( level._post_zm_overrides_func ) )
	{
		level thread [[ level._post_zm_overrides_func ]]();
	}
}

post_zm_init_overrides()
{
	level.player_out_of_playable_area_monitor = true;
	level.player_too_many_weapons_monitor = true;
	level._use_choke_weapon_hints = true;
	level._use_choke_blockers = true;
	level.calc_closest_player_using_paths = false;
	level.zombie_melee_in_water = true;
	level.put_timed_out_zombies_back_in_queue = true;
	level.use_alternate_poi_positioning = true;
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

assert_include_weapon_entry( in_box_res, limit_res )
{
	assert( !in_box_res.null );
	assert( !in_box_res.errored );
	assert( !limit_res.errored );

	success = !in_box_res.null && !in_box_res.errored && !limit_res.errored;
	return success;
}

assert_include_weapon_success( weapon_name )
{
	assert( _WEAPON_EXISTS( weapon_name ) ); // precached failed...
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

assert_zm_weapons_table_parse_type_correctness( add_weapon, hint )
{
	assert( isstring( hint ) );
	assert( isstring( add_weapon.name ) );
	assert( !isdefined( add_weapon.upgrade_name ) || isstring( add_weapon.upgrade_name ) );
	assert( isint( add_weapon.cost ) );
	assert( !isdefined( add_weapon.ammo_cost ) || isint( add_weapon.ammo_cost ) );
	assert( !isdefined( add_weapon.weapon_voice_over ) || isstring( add_weapon.weapon_voice_over ) );
	assert( !isdefined( add_weapon.weaponvoresp ) || isstring( add_weapon.weaponvoresp ) );
	assert( !isdefined( add_weapon.create_vox ) || isint( add_weapon.create_vox ) );
}

add_zombie_weapon2( weapon_name, upgrade_name, hint, cost, weaponvo, weaponvoresp, ammo_cost, create_vox )
{
	if ( isdefined( level.zombie_include_weapons ) && !isdefined( level.zombie_include_weapons[weapon_name] ) )
		return;

	cost = round_up_to_ten( cost );

	precachestring( hint );
	struct = spawnstruct();

	if ( !isdefined( level.zombie_weapons ) )
		level.zombie_weapons = [];

	if ( !isdefined( level.zombie_weapons_upgraded ) )
		level.zombie_weapons_upgraded = [];

	if ( isdefined( upgrade_name ) )
		level.zombie_weapons_upgraded[upgrade_name] = weapon_name;

	struct.weapon_name = weapon_name;
	struct.upgrade_name = upgrade_name;
	struct.weapon_classname = "weapon_" + weapon_name;
	struct.hint = hint;
	struct.cost = cost;
	struct.vox = weaponvo;
	struct.vox_response = weaponvoresp;
/#
	println( "ZM >> Looking for weapon - " + weapon_name );
#/
	struct.is_in_box = level.zombie_include_weapons[weapon_name];

	if ( isdefined( ammo_cost ) )
	{
		ammo_cost = round_up_to_ten( ammo_cost );
	}
	else
	{
		ammo_cost = round_up_to_ten( int( cost * 0.5 ) );
	}

	struct.ammo_cost = ammo_cost;
	level.zombie_weapons[weapon_name] = struct;

	if ( isdefined( level.zombiemode_reusing_pack_a_punch ) && level.zombiemode_reusing_pack_a_punch && isdefined( upgrade_name ) )
		add_attachments( weapon_name, upgrade_name );

	if ( isdefined( create_vox ) )
		level.vox maps\mp\zombies\_zm_audio::zmbvoxadd( "player", "weapon_pickup", weapon_name, weaponvo, undefined );

/#
	if ( isdefined( level.devgui_add_weapon ) )
		[[ level.devgui_add_weapon ]]( weapon_name, upgrade_name, hint, cost, weaponvo, weaponvoresp, ammo_cost );
#/
}

add_zombie_weapons()
{
	succeeded = set_working_table( "zm/zm_weapons.csv" );
	if ( !succeeded )
	{
		// no "zm/zm_weapons.csv" was found to parse, user will need to define the add weapons manually
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

		// box logic section, formerly include_weapons.csv
		in_box_res = get_csv_bool( 9 ); // required
		limit_count_res = get_csv_int( 10 ); // optional

		if ( !assert_add_zombie_weapon_entry( weapon_name_res, upgrade_name_res, hint_res, cost_res, weapon_voice_over_res, weapon_voice_over_response_res, ammo_cost_res, create_vox_res ) )
		{
			continue;
		}

		if ( !assert_include_weapon_entry( in_box_res, limit_count_res ) )
		{
			continue;
		}

		include_weapon( weapon_name_res.value, in_box_res.value );

		if ( !limit_count_res.is_null )
		{
			add_limited_weapon( weapon_name_res.value, limit_count_res.value );
		}

		assert_include_weapon_success( weapon_name_res.value );

		hint = istring( hint_res.value );
		cost = cost_res.value;
		ammo_cost = ammo_cost_res.value;
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

		assert_zm_weapons_table_parse_type_correctness( add_weapon, hint_res );
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
		assert( level.zombie_include_weapons[weapon.name] );
		add_zombie_weapon2( weapon.name, weapon.upgrade_name, weapon.hint, weapon.cost, weapon.weaponvo, weapon.weaponvoresp, weapon.ammo_cost, weapon.create_vox );
	}

	// kill the array to save some vars
	level._usermap_add_weapons = undefined;
}