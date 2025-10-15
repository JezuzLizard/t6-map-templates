//
// file: frontend_amb.gsc
// description: level ambience script for frontend
// scripter: 
//
#include maps\mp\_utility;
#include common_scripts\utility; 


autoexec main()
{	
	level.unlockableMusic = [];
	level setup_unlockable_music_tracks();
}

/*Music Tracks will play in the order specified below
 * If a track is unlocked after a specific level, it will be ignored in the order until unlocked, then assume the correct placement
 * add_music_track( musicstate_name, string, unlocked_after_which_level )
 */
setup_unlockable_music_tracks()
{
	add_music_track( "MUS_SHADOWS", &"MUS_SHADOWS_INFO", 0 );
	add_music_track( "MUS_CHECKIN", &"MUS_CHECKIN_INFO", 0 );
	add_music_track( "MUS_SURVEILLANCE_BEATS", &"MUS_SURVEILLANCE_BEATS_INFO", 0 );
	add_music_track( "MUS_UP_RIVER", &"MUS_UP_RIVER_INFO", 0 );
	add_music_track( "MUS_ZMB_COMINGHOME", &"MUS_ZMB_COMINGHOME_INFO", 1 );
	add_music_track( "MUS_ZMB_115", &"MUS_ZMB_115_INFO", 2 );
	add_music_track( "MUS_ZMB_ABRACADAVRE", &"MUS_ZMB_ABRACADAVRE_INFO", 3 );
	add_music_track( "MUS_ZMB_PAREIDOLIA", &"MUS_ZMB_PAREIDOLIA_INFO", 4 );
}
add_music_track( alias, name, unlocked )
{
	m = spawnstruct();
	m.alias = alias;
	m.name = name;
	m.unlocked = unlocked;	
	level.unlockableMusic = add_to_array( level.unlockableMusic, m );
}