=begin
#===============================================================================
 Title: Splash Screen Map
 Author: Hime
 Date: Oct 17, 2013
 URL: http://himeworks.com/2013/10/17/splash-screen-map/
--------------------------------------------------------------------------------
 ** Change log
 Oct 17, 2013
   - Initial release
--------------------------------------------------------------------------------   
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 This script allows you to create splash screens using events. When the player
 launches your game, a special "splash screen map" will be loaded and start
 running.

 You can use events in this splash screen map to set up your opening sequences,
 such as any splash screens using "show picture" events, animations, messages,
 screen fade-in fade-out effects, and so on.

 You can create unique splash screens with no scripting knowledge required!

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main

--------------------------------------------------------------------------------
 ** Usage 
 
 In the configuration, set the ID of the map you want to designate as the
 splash screen map, and then just set up your scene in the selected map.
 
 If you want to set the camera to a particular position, create an event
 and set its name to "START"
 
 You can create a "skip" button for players to skip the splash screen in
 the configuration.
 
 To finish the scene and go to the title scene (or another scene),
 make the script call
 
   SceneManager.goto(Scene_Title)
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported["TH_SplashScreenMap"] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Splash_Screen_Map
    
    # The map that will be loaded before the game goes to the title screen.
    Map_ID = 56
    
    # Button to press to skip the splash screen
    # Set to nil if you don't want a skip button
    # I've set this to the "Z" key on your keyboard
    Skip_Button = :C
  end
end
#===============================================================================
# ** Rest of script
#===============================================================================
module SceneManager  
  class << self
    alias :th_splash_screen_map_first_scene_class :first_scene_class
  end
  
  #-----------------------------------------------------------------------------
  # Overwrite.
  #-----------------------------------------------------------------------------
  def self.first_scene_class
    $BTEST ? Scene_Battle : Scene_SplashScreenMap
  end
end

module DataManager
  
  #-----------------------------------------------------------------------------
  # Special setup for a splash screen scene
  #-----------------------------------------------------------------------------
  def self.setup_splash_screen_scene
    create_game_objects
    $game_map.setup(TH::Splash_Screen_Map::Map_ID)
    $game_player.moveto(-1, -1)
    ev = $game_map.instance_variable_get(:@map).events.values.find {|ev| ev.name == "START" }
    if ev
      center_x = (Graphics.width / 32 - 1) / 2.0
      center_y = (Graphics.height / 32 - 1) / 2.0
      $game_map.set_display_pos(ev.x - center_x, ev.y - center_y)
    end
  end
end

class Scene_SplashScreenMap < Scene_Map
  
  alias :th_splash_screen_map_start :start
  def start
    DataManager.setup_splash_screen_scene
    th_splash_screen_map_start
  end
  
  alias :th_splash_screen_map_update :update
  def update
    update_skip_key
    th_splash_screen_map_update
  end
  
  #-----------------------------------------------------------------------------
  # Check if player wants to skip the splash screen. Assumes next scene is the
  # title
  #-----------------------------------------------------------------------------
  def update_skip_key
    SceneManager.goto(Scene_Title) if Input.trigger?(TH::Splash_Screen_Map::Skip_Button)
  end
  
  #-----------------------------------------------------------------------------
  # Menu doesn't make sense here
  #-----------------------------------------------------------------------------
  def update_call_menu
  end
end