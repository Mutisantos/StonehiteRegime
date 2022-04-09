#------------------------------------------------------------------------------#
#  Galv's Region Effects
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 1.9
#  Credit to Yanfly and Quack for event spawning method
#------------------------------------------------------------------------------#
#  2014-01-07 - Version 1.9 - upgrade to not stop animations playing when a 
#                             region effect is drawn.
#  2013-01-24 - Version 1.8 - minor tweaks
#  2013-01-22 - Version 1.7 - Made effects work during forced move routes
#  2012-11-15 - Version 1.6 - Fixed a major bug caused with last update.
#  2012-11-04 - Version 1.5 - streamline updates and bug fix suggested by Quack
#  2012-10-23 - Version 1.4 - updated alias naming convention for compatability
#  2012-10-09 - Version 1.3 - re-wrote the code to be more efficient when
#                           - using many different region effects.
#  2012-10-09 - Version 1.2 - code tweak that may reduce lag on low-end pc's
#  2012-09-16 - Version 1.1 - now compatible with Yanfly's spawn events
#  2012-09-15 - Version 1.0 - release
#------------------------------------------------------------------------------#
#  Designed to activate effects when regions are stood on.
#  An effect can include:
#     - Sound Effect
#     - An event that appears at the player's location
#     - Activating a common event
#
# 
#  INSTRUCTIONS:
#  1. Copy image from /Graphics/Characters/!Other-specials.png to your project
#  2. Copy the map from this demo into your game.
#        - this map has events set up for the pre-made effects
#  3. Check the map ID of the map you copied in your game
#  4. Change the SPAWN_MAP_ID number to this map ID
#  5. Change REGION_EFFECT_SWITCH to a switch you are not using in your game.
#  6. Add some regions to your map to test.
# 
#
#
#  To disable region effects use
#  $game_player.region_effects = false
#
#------------------------------------------------------------------------------#

$imported = {} if $imported.nil?
$imported["Region_Effects"] = true

module Region_Effects
#------------------------------------------------------------------------------#
#  SCRIPT SETUP OPTIONS
#------------------------------------------------------------------------------#

   REGION_EFFECT_SWITCH = 111   # Turn this switch ON to disable the effects.

   MAX_EFFECTS = 20           # Number of effects that can be on screen
                              # before being removed. (To prevent lag)
                               
   SPAWN_MAP_ID = 7           # Map ID of the map you store event effects in.
   
   

#------------------------------------------------------------------------------#
#  ENVIRONMENT REGIONS SETUP
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#
#  region => ["sound", vol, pitch, event_id, common_event_id]
#
#  region          -  the region ID the effect will activate on
#  sound           -  the name of the SE file. "" for no sound
#  vol             -  the volume of the SE (0 - 100)
#  pitch           -  the pitch of the SE (50 - 150)
#  event_id        -  event ID called from the spawn map. 0 for none.
#  common_event_id -  common event ID to call. 0 for no common event.
#
#------------------------------------------------------------------------------#
    EFFECT = { # ! don't touch this
#------------------------------------------------------------------------------#

    0 => ["", 0, 0, 0, 0],              # No Effect (no region)
    
    # Pre-made effects (requires demo events)
    1  => ["Water1", 60, 110, 11, 0],        # Shallow Water
    2  => ["", 40, 150, 35, 0],              # No Sound Footprint
    3  => ["jungrite", 50, 130, 0, 0],       # Walking over thick grass
    # 3  => ["jungrite", 50, 130, 38, 0],      # Walking over thick grass
    4  => ["Fire3", 80, 120, 37, 0],         # Calls fire trap
    5  => ["", 0, 0, 38, 0],                 # Dirt dust
    6  => ["", 80, 120, 39, 0],              # Dust cloud
    7  => ["woodleft", 60, 150, 0, 0],       # Wood footstep
    8  => ["snowrite", 40, 150, 35, 0],      # Snow Footprint
    9  => ["concrite", 40, 150, 0, 0],       # Concrete footstep
    10 => ["gravrite", 50, 130, 35, 0],      # Walking over mud
    
    # You can add more as required. eg:
    # 42 => ["", 0, 0, 0, 0],
    # 18 => ["", 0, 0, 0, 0],
    # etc. etc.
    
    # Only one effect per region number will work
    
#------------------------------------------------------------------------------#
    } # ! don't touch this
#------------------------------------------------------------------------------#
#  END SCRIPT SETUP
#------------------------------------------------------------------------------#
    
end # Region_Effects

module DataManager

#--------------------------------------------------------------------------
# alias method: load_normal_database
#--------------------------------------------------------------------------
class <<self; alias load_normal_database_spawn_alias load_normal_database; end
  def self.load_normal_database
    load_normal_database_spawn_alias
    $data_spawn_map = load_data(sprintf("Data/Map%03d.rvdata2", Region_Effects::SPAWN_MAP_ID))
  end
end

class Game_Player < Game_Character
  attr_accessor :region_effects
  
  alias galv_region_effects_update_update_nonmoving update_nonmoving
  def update_nonmoving(last_moving)
    if last_moving
      galv_region_check unless $game_switches[Region_Effects::REGION_EFFECT_SWITCH] == true
    end
    galv_region_effects_update_update_nonmoving(last_moving)
  end
  
  def galv_region_check
    return if Input.trigger?(:C)
    v = rand(10) - rand(10)
    p = rand(40) - rand(40)
    
    r_id = $game_map.region_id($game_player.x, $game_player.y)
    return if Region_Effects::EFFECT[r_id] == nil
    
    sound = Region_Effects::EFFECT[r_id][0]
    vol = Region_Effects::EFFECT[r_id][1]
      pit = Region_Effects::EFFECT[r_id][2]
      eve = Region_Effects::EFFECT[r_id][3]
      com_eve = Region_Effects::EFFECT[r_id][4]

      RPG::SE.new(sound, vol + v, pit + p).play
      if eve > 0
        $game_map.region_event($game_player.x, $game_player.y, eve, Region_Effects::SPAWN_MAP_ID)
      end
      $game_temp.reserve_common_event(com_eve) unless com_eve == nil
  end
  

end # Game_Player



class Game_Map
  attr_accessor :effectlist
  attr_accessor :r_events

  alias galv_region_effects_setup setup
  def setup(map_id)
    @effectlist = []
    @r_events = {}
    galv_region_effects_setup(map_id)
    
    @eid = 0
  end
  
  def region_event(dx, dy, event_id, map_id)
    map_id = @map_id if map_id == 0
    map = $data_spawn_map
    event = generated_region_event(map, event_id)

    @eid += 1
    @effectlist.push(@eid)
    @effectlist.shift if @effectlist.count > Region_Effects::MAX_EFFECTS

    @r_events[@eid] = Game_Event.new(@map_id, event)
    @r_events[@eid].moveto(dx, dy)
    SceneManager.scene.spriteset.refresh_region_effects

    @eid = 0 if @eid >= Region_Effects::MAX_EFFECTS
  end

  
  def generated_region_event(map, event_id)
    for key in map.events
      event = key[1]
      next if event.nil?
      return event if event.id == event_id
    end
    return nil
  end

  alias galv_region_effects_gm_refresh refresh
  def refresh
    @r_events.each_value {|event| event.refresh }
    galv_region_effects_gm_refresh
  end
  
  alias galv_region_effects_gm_update_events update_events
  def update_events
    @r_events.each_value {|event| event.update }
    galv_region_effects_gm_update_events
  end
  
end # Game_Map



class Spriteset_Map
  def refresh_region_effects
    dispose_region_sprites
    create_region_sprites
  end
  
  alias galv_region_effect_sm_sb_create_characters create_characters
  def create_characters
    create_region_sprites
    galv_region_effect_sm_sb_create_characters
  end
  
  alias galv_region_effect_sm_sb_update_characters update_characters
  def update_characters
    galv_region_effect_sm_sb_update_characters
    @region_sprites.each { |sprite| sprite.update }
  end
  
  alias galv_region_effect_sm_sb_dispose_characters dispose_characters
  def dispose_characters
    dispose_region_sprites
    galv_region_effect_sm_sb_dispose_characters
  end
  
  def create_region_sprites
    @region_sprites = []
    $game_map.effectlist.each_with_index { |id,i|
      @region_sprites[i] = Sprite_Character.new(@viewport1,$game_map.r_events[id])
    }
  end
  
  def dispose_region_sprites
    @region_sprites.each { |sprite| sprite.dispose }
  end
end



class Scene_Map < Scene_Base
  attr_accessor :spriteset
  
  alias galv_region_effects_start start
  def start
    galv_region_effects_start
    SceneManager.scene.spriteset.refresh_region_effects
  end
end # Scene_Map