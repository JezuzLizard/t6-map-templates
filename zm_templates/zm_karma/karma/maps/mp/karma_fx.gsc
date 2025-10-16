#include common_scripts\utility; 
#include maps\mp\_utility;

autoexec main()
{
    //precache_scripted_fx();
    //maps\mp\createfx\karma_fx::main();
}

precache_util_fx()
{

}

precache_scripted_fx()
{
    level._effect["sniper_glint"] = loadfx( "misc/fx_misc_sniper_scope_glint" );
    level._effect["flesh_hit"] = loadfx( "impacts/fx_flesh_hit" );
    level._effect["parting_clouds"] = loadfx( "maps/karma/fx_kar_flight_intro" );
    level._effect["flight_spotlight"] = loadfx( "maps/karma/fx_kar_flight_spotlight" );
    level._effect["flight_hologram"] = loadfx( "maps/karma/fx_kar_flight_hologram" );
    level._effect["flight_lights_glows1"] = loadfx( "maps/karma/fx_kar_flight_lights_bulk_glows" );
    level._effect["flight_lights_centers1"] = loadfx( "maps/karma/fx_kar_flight_lights_bulk_centers" );
    level._effect["flight_lights_glows2"] = loadfx( "maps/karma/fx_kar_flight_lights_leftover_glows" );
    level._effect["flight_lights_centers2"] = loadfx( "maps/karma/fx_kar_flight_lights_leftover_centers" );
    level._effect["flight_overhead_panel_centers"] = loadfx( "maps/karma/fx_kar_flight_lights_bulk2_centers" );
    level._effect["flight_overhead_panel_glows"] = loadfx( "maps/karma/fx_kar_flight_lights_bulk2_glows" );
    level._effect["flight_overhead_panel_centers2"] = loadfx( "maps/karma/fx_kar_flight_lights_leftover2_centers" );
    level._effect["flight_overhead_panel_glows2"] = loadfx( "maps/karma/fx_kar_flight_lights_leftover2_glows" );
    level._effect["flight_access_panel_01"] = loadfx( "maps/karma/fx_kar_flight_lights3" );
    level._effect["flight_access_panel_02"] = loadfx( "maps/karma/fx_kar_flight_lights4" );
    level._effect["flight_lights_3p"] = loadfx( "maps/karma/fx_kar_flight_lights_3p" );
    level._effect["flight_tread_player"] = loadfx( "maps/karma/fx_kar_vtol_tread_1p" );
    level._effect["vtol_exhaust"] = loadfx( "vehicle/exhaust/fx_exhaust_heli_vtol" );
    level._effect["elevator_lights"] = loadfx( "maps/karma/fx_kar_elevator_lights" );
    level._effect["ambient_boat_wake"] = loadfx( "maps/karma/fx_kar_boat_wake1" );
    level._effect["scanner_ping"] = loadfx( "misc/fx_weapon_indicator01" );
    level._effect["checkin_scanner_red"] = loadfx( "light/fx_powerbutton_blink_red_sm" );
    level._effect["checkin_scanner_green"] = loadfx( "light/fx_powerbutton_constant_green_sm" );
    level._effect["eye_light_friendly"] = loadfx( "light/fx_vlight_metalstorm_eye_grn" );
    level._effect["eye_light_enemy"] = loadfx( "light/fx_vlight_metalstorm_eye_red" );
    level._effect["crc_neck_stab_blood"] = loadfx( "maps/karma/fx_kar_blood_neck_stab" );
    level._effect["crc_neck_slash_blood"] = loadfx( "maps/karma/fx_kar_blood_neck_child" );
    level._effect["elevator_light"] = loadfx( "light/fx_kar_light_spot_elevator" );
    level._effect["spiderbot_scanner"] = loadfx( "maps/karma/fx_kar_spider_scanner" );
    level._effect["spiderbot_taser_infinite"] = loadfx( "maps/karma/fx_kar_spider_taser_infinite" );
    level._effect["blood_spurt"] = loadfx( "maps/karma/fx_kar_blood_meatshield" );
    level._effect["muzzle_flash"] = loadfx( "maps/karma/fx_kar_muzzleflash01" );
    level._effect["planet_static"] = loadfx( "maps/karma/fx_kar_hologram_static1" );
    level._effect["club_dance_floor_laser"] = loadfx( "maps/karma/fx_kar_light_projectors2" );
    level._effect["club_dj_cage_laser"] = loadfx( "maps/karma/fx_kar_laser_cage1" );
    level._effect["club_dj_front_laser1"] = loadfx( "maps/karma/fx_kar_laser_stage1" );
    level._effect["club_dj_front_laser2"] = loadfx( "maps/karma/fx_kar_laser_stage2" );
    level._effect["club_dance_floor_laser"] = loadfx( "maps/karma/fx_kar_light_projectors2" );
    level._effect["club_dj_cage_laser"] = loadfx( "maps/karma/fx_kar_laser_cage1" );
    level._effect["club_dj_front_laser2_disco"] = loadfx( "maps/karma/fx_kar_laser_stage2_disco" );
    level._effect["club_dj_front_laser2_fan"] = loadfx( "maps/karma/fx_kar_laser_stage2_fan" );
    level._effect["club_dj_front_laser2_light"] = loadfx( "maps/karma/fx_kar_laser_stage2_light" );
    level._effect["club_dj_front_laser2_roller"] = loadfx( "maps/karma/fx_kar_laser_stage2_roller" );
    level._effect["club_dj_front_laser2_shell"] = loadfx( "maps/karma/fx_kar_laser_stage2_shell" );
    level._effect["club_dj_front_laser2_smoke"] = loadfx( "maps/karma/fx_kar_laser_stage2_smoke" );
    level._effect["club_sun"] = loadfx( "maps/karma/fx_kar_globe_glow1" );
    level._effect["club_sun_small"] = loadfx( "maps/karma/fx_kar_globe_glow2" );
    level._effect["club_dj_front_laser_static"] = loadfx( "maps/karma/fx_kar_laser_static1" );
    level._effect["execution_blood"] = loadfx( "maps/karma/fx_kar_blood_execution1" );
    level._effect["club_tracers"] = loadfx( "maps/karma/fx_kar_club_tracers1" );
    level._effect["light_caution_red_flash"] = loadfx( "light/fx_light_caution_red_flash" );
    level._effect["light_caution_orange_flash"] = loadfx( "light/fx_light_caution_orange_flash" );
    level._effect["kar_ashtray01"] = loadfx( "maps/karma/fx_kar_ashtray01" );
    level._effect["kar_candle01"] = loadfx( "maps/karma/fx_kar_candle01" );
    level._effect["kar_shrimp_civ"] = loadfx( "maps/karma/fx_kar_shrimp_01" );
    level._effect["defalco_muzzle_flash"] = loadfx( "maps/karma/fx_kar_muzzle_flash_custom" );
}

precache_createfx_fx()
{
}