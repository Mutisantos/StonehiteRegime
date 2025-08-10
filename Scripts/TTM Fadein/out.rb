#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ Tinys Travel Map //
#║ **     Fade Out Addon
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
#║ Version : 1.1 // 04.06.2014
#╚═=═=════════════════════════════════════════════════════════════════════════=#

$imported ||= {}
if $imported[:TINY_TTM] == nil
  msgbox_p("You need to install \"Tiny Travel Map\" Main Script to use \"Fade Out Addon\"")
elsif $imported[:TINY_TTM] < 1.4
  msgbox_p("You need to install \"Tiny Travel Map 1.4\" or higher Main Script to use \"Fade Out Addon\"")
else
$imported[:TINY_TTM_FO] = 1.1

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ ** UPDATES **
#║ 
#║ 1.1
#║ - Now Supports Map Window
#║ 
#╚═=═=════════════════════════════════════════════════════════════════════════=#
#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ ** FEATURES **
#║ 
#║ - Fading out of Travel Map when travelling
#║ 
#╚═=═=════════════════════════════════════════════════════════════════════════=#

module TINY # Do not touch
  module TTM_GENERAL # Do not touch
#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** EDITABLE REGION ** Defining TTM General Settings ** EDITABLE REGION **
#╚═=═=════════════════════════════════════════════════════════════════════════=#
    


    
    # Set the Fade Type ( 0 = Black, 1 = White )
    FADE_TYPE = 1
    # Adjusting the Fade Speed (Default: 30)
    FADE_SPEED = 30

    
    
    
#╔═=══════════════════════════════════════════════════════════════════════════=#         
#║ █ ** END OF EDITABLE REGION ** BEWARE ** END OF EDITABLE REGION ** DONT! **
#║ █ **           Dont edit below this line, except... just don't           **
#╚═=═=════════════════════════════════════════════════════════════════════════=#  
  end # Do not touch
end # TINY

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Scene_Map
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Scene_Map
  
  # Alias
  alias_method :start_addon_fadeout                                      ,:start
  
  def start
    start_addon_fadeout
    travel_start
  end
  
  def travel_start
    return unless $game_travelmap.travel_transfer
    $game_travelmap.travel_transfer = false
    post_transfer
  end
  
end # Scene_Map

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Game_Travelmap
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Game_Travelmap
  
  # Attr
  attr_accessor :travel_transfer
  
  # Alias
  alias_method :initialize_addon_fadeout                            ,:initialize
    
  def initialize
    initialize_addon_fadeout
    @travel_transfer = false
  end
  
end # Game_Travelmap

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Scene_TinyMap
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Scene_TinyMap
    
  # Alias
  alias_method :perform_transfer_fade_addon                   ,:perform_transfer
  alias_method :check_transfer_fade_addon                       ,:check_transfer
  
  def check_transfer
    $game_temp.fade_type = TINY::TTM_GENERAL::FADE_TYPE
    check_transfer_fade_addon
  end
  
  def perform_transfer
    pre_transfer
    $game_travelmap.travel_transfer = true
    perform_transfer_fade_addon
  end
  
  def update_for_fade
    update_basic
  end
  
  def fade_loop(duration)
    duration.times do |i|
      yield 255 * (i + 1) / duration
      update_for_fade
    end
  end
  
  def fadeout(duration)
    fade_loop(duration) {|v| Graphics.brightness = 255 - v }
  end
  
  def white_fadeout(duration)
    fade_loop(duration) {|v| @viewport.color.set(255, 255, 255, v) }
  end
  
  def pre_transfer
    case $game_temp.fade_type
    when 0
      fadeout(TINY::TTM_GENERAL::FADE_SPEED)
    when 1
      white_fadeout(TINY::TTM_GENERAL::FADE_SPEED)
    end
  end
  
end # Scene_TinyMap
end # endif

#╔═=═══════════════════════════════════════════════════════════════════════════╗
#╠══════════════════════════════▲ END OF SCRIPT ▲══════════════════════════════╣
#╚═=═=═════════════════════════════════════════════════════════════════════════╝