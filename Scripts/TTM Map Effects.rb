#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ Tinys Travel Map //
#║ **     Map Effects Addon
#║ By TinyMine
#║
#║  First Published/Erstveröffentlicht 04.06.2014
#║
#║  Visit : http://rpgmaker-vx-ace.de/ for further Information
#║
#║  Suggestions? Support? Bugs? Contact me in http://rpgmaker-vx-ace.de/
#║
#║  Credits required : TinyMine
#║  Commercial Use?  : Contact me in http://rpgmaker-vx-ace.de/
#║  
#║  
#║ Version : 1.1 // 14.06.2014
#╚═=═=════════════════════════════════════════════════════════════════════════=#

$imported ||= {}
if $imported[:TINY_TTM] == nil
  msgbox_p("You need to install \"Tiny Travel Map\" Main Script to use \"Fade Out Addon\"")
elsif $imported[:TINY_TTM] < 1.4
  msgbox_p("You need to install \"Tiny Travel Map 1.4\" or higher Main Script to use \"Map Effects Addon\"")
else
$imported[:TINY_TTM_ME] = 1.1

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ ** UPDATES **
#║ 
#║ 1.1
#║ - Fixed Tints having delay when calling the map
#║ 
#╚═=═=════════════════════════════════════════════════════════════════════════=#

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ ** FEATURES **
#║ 
#║ - Makes it possible to add RGSS Weather Effects to you travel map
#║ - Makes it possible to change screen tone of you map/targets
#║ 
#╚═=═=════════════════════════════════════════════════════════════════════════=#

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ ** USAGE INSTRUCTIONS **
#║ 
#║ █  change_map_tone(r, g, b)
#║ Change the Tone of your travel map. r = Red, g = Green, b = Blue
#║ 
#║ █  change_map_weather(type, power)
#║ types
#║ :rain, :snow, :storm, :none
#║ power
#║ 0-9
#║ 
#╚═=═=════════════════════════════════════════════════════════════════════════=#

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Game_Interpreter
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Game_Interpreter
  
  def change_map_tone(r, g, b, fade=0)
    $game_travelmap.screen.start_tone_change(Tone.new(r,g,b), fade)
  end
  
  def change_map_weather(type, power, fade=0)
    $game_travelmap.screen.change_weather(type, power, fade)
  end
  
end # Game_Interpreter

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Game_Travelmap
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Game_Travelmap
  
  # Attr
  attr_accessor :screen
  
  # Alias
  alias_method :initialize_addon_mapeffects                         ,:initialize
  alias_method :update_addon_mapeffects                                 ,:update
  
  def initialize
    initialize_addon_mapeffects
    @screen = Game_Screen.new
  end
  
  def update
    update_addon_mapeffects
    @screen.update
  end
  
end # Game_Travelmap

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Scene_TinyMap
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Scene_TinyMap
  
  # Alias
  alias_method :start_addon_mapeffects                                   ,:start
  alias_method :update_addon_mapeffects                                 ,:update
  alias_method :terminate_addon_mapeffects                           ,:terminate
  
  def start
    start_addon_mapeffects
    @viewport_weather = Viewport.new(0,0,640, 480)
    @viewport_weather.z = 25
    @weather = Spriteset_Weather.new(@viewport_weather)
    @sprites.each { |e| e.target.tone = $game_travelmap.screen.tone }
    @map.tone = $game_travelmap.screen.tone
  end
  
  def update
    update_addon_mapeffects
    @sprites.each { |e| e.target.tone = $game_travelmap.screen.tone }
    @map.tone = $game_travelmap.screen.tone
    @weather.type = $game_travelmap.screen.weather_type
    @weather.power = $game_travelmap.screen.weather_power
    @weather.update
  end  
  
  def terminate
    terminate_addon_mapeffects
    @weather.dispose
  end
  
end # Scene_TinyMap

end #endif

#╔═=═══════════════════════════════════════════════════════════════════════════╗
#╠══════════════════════════════▲ END OF SCRIPT ▲══════════════════════════════╣
#╚═=═=═════════════════════════════════════════════════════════════════════════╝