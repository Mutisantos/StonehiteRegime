#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ Tinys Travel Map //
#║ **     Text Names Addon
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
#║ Version : 1.0 // 04.06.2014
#╚═=═=════════════════════════════════════════════════════════════════════════=#

$imported ||= {}
if $imported[:TINY_TTM] == nil
  msgbox_p("You need to install \"Tiny Travel Map\" Main Script to use \"Fade Out Addon\"")
elsif $imported[:TINY_TTM] < 1.4
  msgbox_p("You need to install \"Tiny Travel Map 1.4\" or higher Main Script to use \"Map Effects Addon\"")
else
$imported[:TINY_TTM_TN] = 1.0

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ ** FEATURES **
#║ 
#║ - Show the Names of the Targets in the Map directly
#║ 
#╚═=═=════════════════════════════════════════════════════════════════════════=#

module TINY # Do not touch
  module TTM_GENERAL # Do not touch
#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** EDITABLE REGION ** Defining TTM General Settings ** EDITABLE REGION **
#╚═=═=════════════════════════════════════════════════════════════════════════=#
    
    # Need the default Window?
    WINDOW_TARGETS = true
    
    # Font Type
    TARGET_FONT_NAME = "VL Gothic" 
    # Font Size of Name in map
    TARGET_FONT_SIZE = 18
    # Properties
    TARGET_FONT_BOLD = false
    TARGET_FONT_SHADOW = false
    
    # Adjustment needed for the Y Pos of the Name in map?
    TARGET_NAME_Y_POS = -25
    # Adjustment needed for the X Pos of the Name in map?
    TARGET_NAME_X_POS = 0

    
    
#╔═=══════════════════════════════════════════════════════════════════════════=#         
#║ █ ** END OF EDITABLE REGION ** BEWARE ** END OF EDITABLE REGION ** DONT! **
#║ █ **           Dont edit below this line, except... just don't           **
#╚═=═=════════════════════════════════════════════════════════════════════════=#  
  end # Do not touch
end # TINY

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Sprite_MapTarget
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Sprite_MapTargetSet
  
  # Alias
  alias_method :initialize_addon_travelnames                        ,:initialize
  alias_method :set_pos_addon_travelnames                              ,:set_pos
  alias_method :upd_pos_addon_travelnames                              ,:upd_pos
  alias_method :set_visual_addon_travelnames                        ,:set_visual
  alias_method :dispose_addon_travelnames                              ,:dispose
  
  def initialize(x, y, bitmap, id)
    @text = Sprite.new
    initialize_addon_travelnames(x, y, bitmap, id)
  end
  
  def set_pos(x, y)
    set_pos_addon_travelnames(x, y)
    @text.x = @target.x
    @text.y = @target.y
    @text.z = @target.z+1
  end
  
  def upd_pos(x, y)
    upd_pos_addon_travelnames(x, y)
    @text.x = @target.x
    @text.y = @target.y
  end
  
  def set_visual(filename)
    set_visual_addon_travelnames(filename)
    @text.bitmap = Bitmap.new(@target.bitmap.width*2, [@target.bitmap.height, TINY::TTM_GENERAL::TARGET_FONT_SIZE].max)
    @text.ox = @target.bitmap.width + TINY::TTM_GENERAL::TARGET_NAME_X_POS
    @text.oy = @target.bitmap.height/2 + TINY::TTM_GENERAL::TARGET_NAME_Y_POS
    set_font_config
    @text.bitmap.draw_text(@text.bitmap.rect, TINY::TTM_TARGETS::TARGETS[@target_id][:text], 1) 

  end
  
  def set_font_config
    font = Font.new([TINY::TTM_GENERAL::TARGET_FONT_NAME])
    font.bold = TINY::TTM_GENERAL::TARGET_FONT_BOLD
    font.shadow = TINY::TTM_GENERAL::TARGET_FONT_SHADOW
    font.size = TINY::TTM_GENERAL::TARGET_FONT_SIZE
    @text.bitmap.font = font
  end
  
  def dispose
    @text.dispose
    dispose_addon_travelnames
  end
  
end # Sprite_MapTarget

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Sprite_MapTarget
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Scene_TinyMap
  
  # Alias
  alias_method :create_windows_addon_travelnames                ,:create_windows
  
  def create_windows
    create_windows_addon_travelnames
    @tar_window.visible = TINY::TTM_GENERAL::WINDOW_TARGETS
  end
  
end # Scene_TinyMap
end #endif

#╔═=═══════════════════════════════════════════════════════════════════════════╗
#╠══════════════════════════════▲ END OF SCRIPT ▲══════════════════════════════╣
#╚═=═=═════════════════════════════════════════════════════════════════════════╝