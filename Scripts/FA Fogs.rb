#===============================================================================
#                 RAFAEL_SOL_MAKER's ACE PERFECT FOG v1.0
#_______________________________________________________________________________
#   Description  | Adds a fog effect, identical to the RPG Maker XP fog, in
#                | RPG Maker VX maps, with also similar functionality.
#                | It's just a port of my VX's version. Enough said.
#________________|______________________________________________________________
#     Usage      | To show the fog, type this command in a 'Script...'
#                | event command:
#                |  
#                |    setup_fog("filename", hue, opacity, blend_type, zoom,
#                |              speed_x, speed_y, visible?)
#                |
#                |   Where:      Is equivalent to:
#                | filename    > Name of the bitmap used in the fog effect.
#                | hue         > Hue(Color). Use a value between 0 and 360.
#                | opacity     > Opacity. Use a value between 0 and 255.
#                | blend_type  > Bitmap alpha blend mode. See values below.
#                | zoom        > Zoom, in scale. Decimal values are allowed.
#                | speed_x     > Horizontal speed, in pixels. Negatives allowed.
#                | speed_y     > Vertical speed, in pixels. Negatives allowed.
#                | visible?    > Visibility of the fog. Use 'true' or 'false'.
#                |
#              > | Place all fog graphics in the folder 'Graphics/Fogs/'.
#                |
#              > | The parameter 'blend_type' accepts three values:
#                | BLEND_NORMAL, BLEND_ADD and BLEND_SUB,  for the use of
#                | normal, addition and subtraction blend modes, respectively.
#                |
#              > | Note: All parameters are optional; default values will be
#                | used, if omitted. It's possible to omit only the parameteres
#                | you want. To do this, just type 'nil' in its place instead.
#                |
#              > | You can set the default values in the general configurations
#                | module. Now let's see the other commands:
#                |
#                |     change_fog_tone(tone, [duration])
#                |     change_fog_opacity(opacity, [duration])
#                |
#              > | To change the hue, and opacity of the fog, respectively.
#                | In 'tone', you will need to use a 'Tone' object:
#                |   Tone.new(red, green, blue, [gray])
#                | Where colors accept values of -255 to 255 and gray 0 to 255.
#                | In opacity use a value between 0 and 255 too.
#                | The value of 'duration' is optional, use a value in frames.
#                | If the value is omitted the transition will be immediate.
#                |
#                |     show_fog
#                |     hide_fog
#                |
#              > | Use these commands to show and hide the fog, respectively.
#________________|______________________________________________________________
# Specifications | Difficulty to Use:
#                |  * * ½ (some commands may need little scripting knowledge)
#                | Scripting Difficulty:
#                |  * * (required some graphics/Game engine knowledge)
#                | Compatibility:
#                |  * * * *(probably highly compatible)
#                | New Methods:
#                |  - (many, and a brand new Game class, see in the code below)
#                | Overwritten Methods:
#                |  - (none)
#                | Aliased Methods:
#                |  - Game_Map.setup
#                |  - Game_Map.update
#                |  - Spriteset_Map.initialize
#                |  - Spriteset_Map.update
#                |  - Spriteset_Map.dispose
#________________|______________________________________________________________
# Special Thanks | Miget man12, Woratana
#________________|______________________________________________________________
#===============================================================================
 
#_______________________________________________________________________________
#     SCRIPT CONFIGURATIONS - Some adjusts that you can do without problems.
#_______________________________________________________________________________
#===============================================================================
 
module PPVXAce_General_Configs
  Fog_Filename = 'Fog01'  # Bitmap name
  Fog_Hue = 0             # Hue(Colour)
  Fog_Opacity = 128       # Opacity
  Fog_Blend_Type = 1      # Blend Mode
  Fog_Zoom = 1            # Zoom Scale
  Fog_SpeedX = 4          # Horizontal Speed
  Fog_SpeedY = 4          # Vertical Speed
  Fog_Visible = true      # Visibility
end
 
#_______________________________________________________________________________
#     BEGGINING OF THE SCRIPT - Don't modify without know what you're doing!
#_______________________________________________________________________________
#===============================================================================
 
module Cache
  def self.fog(filename)
    load_bitmap('Graphics/Fogs/', filename)
  end
end
 
class Game_Interpreter
  include PPVXAce_General_Configs  
 
  BLEND_NORMAL = 0  # Blend Mode: Normal
  BLEND_ADD = 1     # Blend Mode: Addition
  BLEND_SUB = 2     # Blend Mode: Subtraction
 
  #--------------------------------------------------------------------------
  # Fog Initiaization
  #--------------------------------------------------------------------------  
  def setup_fog(filename = Fog_Filename, hue = Fog_Hue, opacity = Fog_Opacity,
                blend_type = Fog_Blend_Type, zoom = Fog_Zoom, sx = Fog_SpeedX,
                sy = Fog_SpeedY, visible = Fog_Visible)
   
    filename = Fog_Filename if filename.nil?
    hue = Fog_Hue if hue.nil?
    opacity = Fog_Opacity if opacity.nil?
    blend_type = Fog_Blend_Type if blend_type.nil?
    zoom = Fog_Zoom if zoom.nil?
    sx = Fog_SpeedX if sx.nil?
    sy = Fog_SpeedY if sy.nil?
    visible = Fog_Visible if visible.nil?
 
    # Start the fog, use defaults if value is omitted('nil')
    $game_map.setup_fog(filename, hue, opacity , blend_type, zoom, sx, sy, visible)
  end
 
  #--------------------------------------------------------------------------
  # Fog Tone
  #--------------------------------------------------------------------------  
  def change_fog_tone(tone, duration = 0)
    # Start the changing of the color tone
    $game_map.fog.start_tone_change(tone, duration)
    return true
  end
 
  #--------------------------------------------------------------------------
  # Fog Opacity
  #--------------------------------------------------------------------------  
  def change_fog_opacity(opacity, duration = 0)
    # Start the changing of the opacity level
    $game_map.fog.start_opacity_change(opacity, duration)
    return true
  end
 
  #--------------------------------------------------------------------------
  # Hide Fog
  #--------------------------------------------------------------------------  
  def hide_fog
    # Make the fog invisible
    $game_map.fog.visible = false
    return true
  end
 
  #--------------------------------------------------------------------------
  # Show Fog
  #--------------------------------------------------------------------------  
  def show_fog
    # Make fog visible again
    $game_map.fog.visible = true
    return true
  end
 
end
 
class Game_Fog
  attr_accessor :name
  attr_accessor :hue
  attr_accessor :opacity
  attr_accessor :blend_type
  attr_accessor :zoom
  attr_accessor :sx
  attr_accessor :sy
  attr_accessor :visible
  attr_reader   :ox
  attr_reader   :oy
  attr_reader   :tone
 
  def initialize
    @name = ""
    @hue = 0
    @opacity = 255.0
    @blend_type = 0
    @zoom = 100.0
    @sx = 0
    @sy = 0
    @ox = 0
    @oy = 0
    @visible = true
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @opacity_duration = 0
    @opacity_target = 0
  end
 
  def setup(name, hue, opacity , blend_type, zoom, sx, sy, visible)
    @name = name
    @hue = hue
    @opacity =  opacity
    @blend_type = blend_type
    @zoom = zoom
    @sx = sx
    @sy = sy
    @visible = visible
    @ox = 0
    @oy = 0
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @opacity_duration = 0
    @opacity_target = 0    
  end
 
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    if @tone_duration == 0
      @tone = @tone_target.clone
    end
  end
 
  def start_opacity_change(opacity, duration)
    @opacity_target = opacity * 1.0
    @opacity_duration = duration
    if @opacity_duration == 0
      @opacity = @opacity_target
    end
  end
 
  def update
    @ox -= @sx
    @oy -= @sy
    if @tone_duration >= 1
      d = @tone_duration
      target = @tone_target
      @tone.set( (@tone.red   * (d - 1) + target.red)  / d,
                 (@tone.green * (d - 1) + target.green)/ d,
                 (@tone.blue  * (d - 1) + target.blue) / d,
                 (@tone.gray  * (d - 1) + target.gray) / d )
      @tone_duration -= 1
    end
    if @opacity_duration >= 1
      d = @opacity_duration
      @opacity =(@opacity *(d - 1) + @opacity_target) / d
      @opacity_duration -= 1
    end
  end
 
end
 
class Game_Map
  attr_accessor :fog
 
  alias solmaker_gamemap_fog_setup setup
  def setup(map_id)
    setup_fog_basic
    solmaker_gamemap_fog_setup(map_id)    
  end
 
  alias solmaker_gamemap_fog_update update
  def update(main = false)
    update_fog
    solmaker_gamemap_fog_update(main)
  end
 
  def setup_fog(name, hue, opacity, blend_type, zoom, sx, sy, visible)
    visible = true if visible != true and visible != false
    @fog = Game_Fog.new
    @fog.setup(name.to_s, hue.to_i, opacity.to_f, blend_type.to_i,
      zoom.to_f, sx.to_i, sy.to_i, visible) rescue raise(ArgumentError,
      'Error during fog setup!\nPlease check the given values!')
  end
 
  def setup_fog_basic  
    @fog = Game_Fog.new
  end
 
  def update_fog
  end
 
end
 
class Spriteset_Map
 
  alias solmaker_fog_initialize initialize
  def initialize
    create_fog
    solmaker_fog_initialize
  end
 
  alias solmaker_fog_update update
  def update
    update_fog
    solmaker_fog_update
  end
 
  alias solmaker_fog_dispose dispose
  def dispose
    dispose_fog
    solmaker_fog_dispose
  end
 
  def create_fog
    @plane_fog = Plane.new(@viewport1)
    @plane_fog.z = 100
    @temp_name = ""; @temp_hue = 0
  end  
 
  def update_fog
    $game_map.fog.update
    if @temp_name != $game_map.fog.name or @temp_hue != $game_map.fog.hue
      if @plane_fog.bitmap != nil
        @plane_fog.bitmap.dispose
        @plane_fog.bitmap = nil
      end
      if $game_map.fog.name != ""
        @plane_fog.bitmap = Cache.fog($game_map.fog.name)
        @plane_fog.bitmap.hue_change($game_map.fog.hue)
      end
      Graphics.frame_reset
    end
 
    @plane_fog.opacity = $game_map.fog.opacity
    @plane_fog.blend_type = $game_map.fog.blend_type
    @plane_fog.zoom_x = $game_map.fog.zoom
    @plane_fog.zoom_y = $game_map.fog.zoom
    @plane_fog.visible = $game_map.fog.visible
    @plane_fog.tone = $game_map.fog.tone
   
    @plane_fog.ox = ($game_map.display_x + $game_map.fog.ox) / 8.0 unless @plane_fog.nil?
    @plane_fog.oy = ($game_map.display_y + $game_map.fog.oy) / 8.0 unless @plane_fog.nil?
    @temp_name = $game_map.fog.name;   @temp_hue = $game_map.fog.hue
  end
 
  def dispose_fog
    # Prevents a bug while setting saturation, undoing saturation already processed
    @plane_fog.bitmap.hue_change -@temp_hue unless @plane_fog.bitmap.nil?
    Graphics.frame_reset
    @plane_fog.dispose unless @plane_fog.nil?
    @plane_fog = nil
  end
 
end
 
#_______________________________________________________________________________
#                  END OF THE SCRIPT - See ya next time!
#_______________________________________________________________________________
#===============================================================================