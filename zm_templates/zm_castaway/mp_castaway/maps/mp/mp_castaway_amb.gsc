#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

main()
{
    allowed[0] = "tdm"; // just use tdm, that has the most clean entities
    entities = getentarray();

    for ( entity_index = entities.size - 1; entity_index >= 0; entity_index-- )
    {
        entity = entities[entity_index];

        if ( !entity_is_allowed( entity, allowed ) )
            entity delete();
    }
}

entity_is_allowed( entity, allowed_game_modes )
{
    if ( isdefined( level.createfx_enabled ) && level.createfx_enabled )
        return 1;

    allowed = 1;

    if ( isdefined( entity.script_gameobjectname ) && entity.script_gameobjectname != "[all_modes]" )
    {
        allowed = 0;
        gameobjectnames = strtok( entity.script_gameobjectname, " " );

        for ( i = 0; i < allowed_game_modes.size && !allowed; i++ )
        {
            for ( j = 0; j < gameobjectnames.size && !allowed; j++ )
                allowed = gameobjectnames[j] == allowed_game_modes[i];
        }
    }

    return allowed;
}