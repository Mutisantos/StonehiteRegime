#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ Tinys Travel Map
#║ By TinyMine
#║
#║  First Published/Erstveröffentlicht 09.07.2013
#║
#║  Visit : http://rpgmaker-vx-ace.de/ for further Information
#║
#║  Suggestions? Support? Bugs? Contact me in http://rpgmaker-vx-ace.de/
#║
#║  Credits required : TinyMine
#║  Commercial Use?  : Contact me in http://rpgmaker-vx-ace.de/
#║  
#║  
#║ Version : 1.41 // 04.06.2014
#╚═=═=════════════════════════════════════════════════════════════════════════=#

$imported ||= {}
$imported[:TINY_TTM] = 1.41

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ ** UPDATES **
#║ 
#║ 1.41
#║ - FIXED: No more Savegame error
#║ 
#║ 1.4
#║ - New Highlight Options
#║ - New Highlight Effect (replacing old one)
#║ - New Addon Compatibility
#║ 
#╚═=═=════════════════════════════════════════════════════════════════════════=#

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ ** FEATURES **
#║ 
#║ - Use a map image to fasttravel across it
#║ - 2 Modifications
#║    Mode 1 : For small maps
#║    Mode 2 : For big maps
#║ - Own targets placeable
#║ - Everything is adjustable by you (Graphics, names, fonts etc...)
#║ - New folder "Map" for your map scene
#║ 
#╚═=═=════════════════════════════════════════════════════════════════════════=#

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ ** USAGE INSTRUCTIONS **
#║ 
#║ Adding a target during game progress to your map
#║ █  add_map_target(ID)
#║ Where ID is the ID of your target you want to add
#║ 
#║ Removing a target during game progress from your map
#║ █  rem_map_target(ID)
#║ Where ID is the ID of your target you want to remove
#║ 
#║ Calling the scene to travel across your map, type...
#║ █  open_travel_map
#║ Which opens the Scene_TinyMap automatically
#║ 
#╚═=═=════════════════════════════════════════════════════════════════════════=#

module TINY # Do not touch
  module TTM_GENERAL # Do not touch
#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** EDITABLE REGION ** Defining TTM General Settings ** EDITABLE REGION **
#╚═=═=════════════════════════════════════════════════════════════════════════=#
    
    # Defines the map graphic image name which is found in new "map" folder
    GRAPHIC_MAP = "MapasTodos"
    
    # Graphic which shows the players position on the map
    GRAPHIC_POS = "Pin"
    
    # Defines the background image name which is found in new "map" folder
    # "" for black screen
    BACKGROUND = ""
    
    # Defines used mode in your game
    MODE = 2
    
    # Mode 1 : Resize the map to 400x368px. All "added" targets visible and selectable
    # Mode 2 : For bigger maps. No resizing. Scrolling across the map between "added" targets
    
    # Do you want to scroll or jump across MODE 2 maps? (true = scroll)
    SCROLLING = true
    # Scrollspeed is calculated by px/frame (frame is 1/60 second)
    SCROLLSPEED = 10
    
    # Should a menu point be visible for the map?
    MENUPOINT = true
    
    # Highlight Options
    HIGHLIGHT_SELECTED = true
    # Highlight Size // 10-20 recommended
    HIGHLIGHT_SIZE     = 20
    # Shall the Highlight effect be smooth or not
    HIGHLIGHT_SMOOTH   = false
    # the higher the level the higher the blur (1 = lowest)
    HIGHLIGHT_SMOOTH_LEVEL = 1
    # Blink the selected target if HIGHLIGHT_SELECTED is true
    BLINK_SELECTED = true
    # The lower the faster
    BLINK_SPEED    = 60

#═=═=═════════════════════════════════════════════════════════════════════════=#    
  end # Do not touch
  module TTM_VOCAB # Do not touch
#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** EDITABLE REGION **    Defining TTM Vocab          ** EDITABLE REGION **
#╚═=═=════════════════════════════════════════════════════════════════════════=#
    
    # Headername for the travel map
    VOC_MAPNAME = "Muparacon"
    
    # Name of menu point if activated
    VOC_MENUNAME = "Map"
    
    
#═=═=═════════════════════════════════════════════════════════════════════════=#    
  end # Do not touch
  module TTM_TARGETS # Do not touch
    TARGETS = {  # Do not touch
#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** EDITABLE REGION **    Defining TTM Targets        ** EDITABLE REGION **
#╚═=═=════════════════════════════════════════════════════════════════════════=#
    
    #█ EXAMPLE TARGETS # ** Dont change the Data packs symbols - use them everytime
    
    # Target id    # Data packs  #  "Target name"
      :tatama => {:text         => "Tatama",
                                 # [ Target x, Target y, "graphicname in map folder", icon id ] 
                  :graphic      => [350, 750,"orb", 232],
                                 # [ Mapid, Mapx, Mapy ]
                  :teleportdest => [13, 16, 6]
          }, # Don't forget comma if another target follows    
                    
      :tundra =>  {:text         =>  "Tundra",
                   :graphic      =>  [500, 1100,"tundra", 232],
                   :teleportdest =>  [15, 8, 0]
                   
          },
      :grassland =>{:text         =>  "Grasland",
                    :graphic      =>  [1200, 1100,"wiese", 232],
                    :teleportdest =>  [16, 8, 12]
                  
          },
      :mountain => { :text         => "Mountain",
                     :graphic      => [1200, 1000,"berge", 232],
                     :teleportdest => [2, 0, 6]
                  
          } # Don't put a comma if it is the last target 
                                   
                                   
     #█ OWN TARGETS                   
                                   
                                   
                                   
                                   
                                   
                                   
                                   
#═=═=═════════════════════════════════════════════════════════════════════════=#  
    } # end targets hash * Do not touch
  end # Do not touch  
  module TTM_MODE # Do not touch
#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** EDITABLE REGION **  Defining TTM MODE General   ** EDITABLE REGION **
#╚═=═=════════════════════════════════════════════════════════════════════════=#
  
  # █ ** all x/y, width/height adjustments only affect MODE 2
  
  # Defining the "cursors" position when scrolling/jumping on the map by x/y px
  CURSORX = 300
  CURSORY = 208
  
  # Defining x/y pos of header window; dont forget the brackets []
  HEADPOS   = [0, 0] 
  # Defining width/height of header window; dont forget the brackets []
  HEADSIZE  = [544, 48] 
  # Defining the Windowskin of your header window; => system folder            
  HSKIN     = "window1"        
  # Defining the font which should be used in header window
  HEADFONT  = "VL Gothic"              
  # Defines the fonts size in header window
  HFTSIZE   = 26   
  # Defines if font is bold
  HBOLD   = true
  # Defines if font has shadow
  HSHADOW   = true                  
  # Defines the header windows opacity ( 255 = fully visible)
  HOPACITY   = 0    

  # Defining x/y pos of target list window; dont forget the brackets []
  LISTPOS   = [24, 96]
  # Defining width/height of target list window; dont forget the brackets []
  LISTSIZE  = [144, 200]
  # Defining the Windowskin of your target list window; => system folder  
  LSKIN     = "Window"
  # Defining the font which should be used in target list window
  LISTFONT  = "VL Gothic"
  # Defines the fonts size in target list window
  LFTSIZE   = 22 
  # Defines if font is bold
  LBOLD   = false
  # Defines if font has shadow
  LSHADOW   = false
  # Defines the target list windows opacity ( 255 = fully visible)
  LOPACITY   = 192

#═=═=═════════════════════════════════════════════════════════════════════════=# 
  end # Do not touch
#╔═=══════════════════════════════════════════════════════════════════════════=#         
#║ █ ** END OF EDITABLE REGION ** BEWARE ** END OF EDITABLE REGION ** DONT! **
#║ █ **           Dont edit below this line, except... just don't           **
#╚═=═=════════════════════════════════════════════════════════════════════════=#
end

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Module Cache
#╚═=═=════════════════════════════════════════════════════════════════════════=#
module Cache
  
  # Loads from a new folder to developers graphic folder
  def self.map(filename)
    load_bitmap("Graphics/Map/", filename)
  end

end # Cache

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Module DataManager
#╚═=═=════════════════════════════════════════════════════════════════════════=#
module DataManager
  
  class << self
    alias_method :create_game_objects_tiny_13177           ,:create_game_objects
    alias_method :make_save_contents_tiny_45774             ,:make_save_contents
    alias_method :extract_save_contents_tiny_89733       ,:extract_save_contents
  end
  
  def self.create_game_objects
    create_game_objects_tiny_13177
    $game_travelmap = Game_Travelmap.new
  end  
  
  def self.make_save_contents
    contents = make_save_contents_tiny_45774
    contents[:travelmap] = $game_travelmap
    contents
  end
  
  def self.extract_save_contents(contents)
    extract_save_contents_tiny_89733(contents)
    $game_travelmap     = contents[:travelmap]
  end
  
end # DataManager

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Game_Interpreter
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Game_Interpreter
  
  # Command adding predefined targets to travel map
  def add_map_target(id)
    $game_travelmap.add_map_target(id)
  end
  
  # Command removing predefined targets from travel map
  def rem_map_target(id)
    $game_travelmap.rem_map_target(id)
  end
  
  # Command for opening the travel scene
  def open_travel_map
    SceneManager.call(Scene_TinyMap)
  end
  
end # Game_Interpreter

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Game_Map
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Game_Map
  
  # Attr
  attr_reader    :map_id
  
end # Game_Map

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Window_MenuCommand
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Window_MenuCommand
  # Only change class when active
  if TINY::TTM_GENERAL::MENUPOINT
    
  # Alias
  alias_method :tiny_tinymap_add_commands_23498     ,     :add_original_commands
  
  def add_original_commands
    tiny_tinymap_add_commands_23498
    # add_command(TINY::TTM_VOCAB::VOC_MENUNAME,:map,main_commands_enabled)
  end
  
  end # end of if
end # Window_MenuCommand

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** OLD Class Scene_Menu
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Scene_Menu
  # Only change class when active
  if TINY::TTM_GENERAL::MENUPOINT
  
  # Alias
  alias_method :tiny_tinymap_set_handlers_17348     ,     :create_command_window
  
  def create_command_window
    tiny_tinymap_set_handlers_17348 
    @command_window.set_handler(:map,method(:call_tinymap))
  end
  
  def call_tinymap
    SceneManager.call(Scene_TinyMap)
  end
  
  end # end of if
end # Scene_Menu

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** NEW Class Game_Travelmap
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Game_Travelmap
  
  # Attr
  attr_reader   :targets
  attr_accessor :last_target
  
  def initialize
    @targets = []
    @last_target = nil
  end
  
  def add_map_target(id)
    return if @targets.include?(id)
    @targets << id if TINY::TTM_TARGETS::TARGETS[id]
    @last_target = id
  end
  
  def rem_map_target(id)
    return unless @targets.include?(id)
    @targets.delete(id)
  end
  
  def update
    # Future Use
  end
  
end # Game_Travelmap

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** NEW Class Window_Target_List
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Window_Target_List < Window_Selectable
  
  def initialize
    if TINY::TTM_GENERAL::MODE == 2
      super(TINY::TTM_MODE::LISTPOS[0], TINY::TTM_MODE::LISTPOS[1], 
      TINY::TTM_MODE::LISTSIZE[0], TINY::TTM_MODE::LISTSIZE[1])
    else
      super(0, 48, 144, 368)
    end
  
    self.windowskin = Cache.system(TINY::TTM_MODE::LSKIN)
    
    self.index = $game_travelmap.targets.index($game_travelmap.last_target) unless $game_travelmap.targets.empty?
    activate
    set_config
    refresh
  end
  
  def item_max
    $game_travelmap.targets.size
  end
  
  def all_targets
    return @list[index]
  end
  
  def set_config
    self.opacity = TINY::TTM_MODE::LOPACITY
    font = Font.new([TINY::TTM_MODE::HEADFONT])
    font.bold = TINY::TTM_MODE::LBOLD
    font.shadow = TINY::TTM_MODE::LSHADOW
    font.size = TINY::TTM_MODE::HFTSIZE
    font.out_color = Color.new(0, 0, 0, 128)
    self.contents.font = font
  end
 
  def refresh
    
    self.contents.clear
    
    @list ||= []
    for i in 0..item_max-1
      e = $game_travelmap.targets[i]
      @list << e
      draw_icon(TINY::TTM_TARGETS::TARGETS[e][:graphic][3], 0, i * 24)
      self.contents.draw_text(24, i * 24, self.width - 24, 24, TINY::TTM_TARGETS::TARGETS[e][:text])
    end
    
  end
  
end # Window_Target_List

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** NEW Class Window_Map_Header
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Window_Map_Header < Window_Base
 
  def initialize
    if TINY::TTM_GENERAL::MODE == 2
      super(TINY::TTM_MODE::HEADPOS[0], TINY::TTM_MODE::HEADPOS[1], 
      TINY::TTM_MODE::HEADSIZE[0], TINY::TTM_MODE::HEADSIZE[1])
    else
      super(0, 0, 544, 48)
    end
  
    self.windowskin = Cache.system(TINY::TTM_MODE::HSKIN)
    
    set_config
    refresh
  end 
  
  def set_config
    self.opacity = TINY::TTM_MODE::HOPACITY
    font = Font.new([TINY::TTM_MODE::HEADFONT])
    font.bold = TINY::TTM_MODE::HBOLD
    font.shadow = TINY::TTM_MODE::HSHADOW
    font.size = TINY::TTM_MODE::HFTSIZE
    font.out_color = Color.new(0, 0, 0, 128)
    self.contents.font = font
  end
  
  def refresh
    self.contents.clear
    
    self.contents.draw_text(4, -2, self.width - 24, 28, TINY::TTM_VOCAB::VOC_MAPNAME, 1)
  end
  
end # Window_Map_Header

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** NEW Class Sprite_MapBack
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Sprite_MapBack < Sprite_Base
  
  def initialize(x, y)
    super(nil)
    self.z = 11
    self.bitmap = Cache.map(TINY::TTM_GENERAL::GRAPHIC_MAP)
    define_mode_one(x, y)
    @tar_x = self.x
    @tar_y = self.y
  end
  
  def define_mode_one(x, y)
    return unless TINY::TTM_GENERAL::MODE == 1
    self.x = x
    self.y = y
    rect = Rect.new(0, 0, 400, 368) 
    self.bitmap.stretch_blt(rect, bitmap, self.bitmap.rect)
  end
  
  def get_pos
    return [self.x, self.y]
  end
  
  def get_size
    return [self.width, self.height]
  end
  
  def jmp_pos
    self.x = @tar_x
    self.y = @tar_y
  end
  
  def upd_pos(x, y)
    @tar_x = 0 - x
    @tar_y = 0 - y
  end
  
  def upd_movement
    savescr = TINY::TTM_GENERAL::SCROLLSPEED
    
    if self.x != @tar_x 
      
      if TINY::TTM_GENERAL::SCROLLING
        
        if self.x > @tar_x
          self.x -= 1
          self.x -= savescr-1 if self.x > @tar_x+savescr
        else self.x < @tar_x
          self.x += 1 
          self.x += savescr-1 if self.x < @tar_x-savescr
        end
        
      else
        self.x = @tar_x
      end
    end
    
    if self.y != @tar_y 
      
      if TINY::TTM_GENERAL::SCROLLING
        
        if self.y > @tar_y
          self.y -= 1
          self.y -= savescr-1 if self.y > @tar_y+savescr 
        else self.y < @tar_y
          self.y += 1 
          self.y += savescr-1 if self.y < @tar_y-savescr 
        end
        
      else
        self.y = @tar_y
      end
      
    end
  end
  
  def update
    super
    upd_movement
  end
  
end # Sprite_MapBack
    
#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** NEW Class Sprite_MapTarget
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Sprite_MapTargetSet
  
  # Attr
  attr_accessor :blink, :target
  attr_reader   :target_id, :x, :y
  
  def initialize(x, y, bitmap, id)
    @x = x-TINY::TTM_MODE::CURSORX
    @y = y-TINY::TTM_MODE::CURSORY
    @target = Sprite.new
    @target_highlight = Sprite.new
    @timer = 0
    @blink = false
    set_pos(x, y)
    set_id(id)
    set_visual(bitmap)
  end
  
  def local_position
    @local_pos = Sprite.new
    @local_pos.bitmap = Cache.map(TINY::TTM_GENERAL::GRAPHIC_POS) rescue nil
    @local_pos.z = 13
  end
  
  def set_pos(x, y)
    @target.x = 144+x
    @target.y = 48+y
    @target.z = 12
    @target_highlight.x = @target.x
    @target_highlight.y = @target.y
    @target_highlight.z = @target.z-1
  end
  
  def upd_pos(x, y)
    @target.x = TINY::TTM_MODE::CURSORX + @x + x - @target.bitmap.width/2 
    @target.y = TINY::TTM_MODE::CURSORY + @y + y - @target.bitmap.height/2
    @target_highlight.x = @target.x
    @target_highlight.y = @target.y
    unless @local_pos == nil
      @local_pos.x = @target.x - @local_pos.bitmap.width/2
      @local_pos.y = @target.y - @target.height
    end
  end
  
  def set_id(id)
    @target_id = id
  end
  
  def set_visual(filename)
    @target.bitmap = Cache.map(filename)
    # Pass new bitmap to work with it separately
    @target_highlight.bitmap = Bitmap.new("Graphics/Map/"+filename)
    @target.ox = @target.bitmap.width/2
    @target.oy = @target.bitmap.height/2
    @target_highlight.ox = @target.bitmap.width/2
    @target_highlight.oy = @target.bitmap.height/2
    @target_highlight.zoom_x = 1.0 + (TINY::TTM_GENERAL::HIGHLIGHT_SIZE/100.0)
    @target_highlight.zoom_y = 1.0 + (TINY::TTM_GENERAL::HIGHLIGHT_SIZE/100.0)
    TINY::TTM_GENERAL::HIGHLIGHT_SMOOTH_LEVEL.to_i.times do @target_highlight.bitmap.blur end if TINY::TTM_GENERAL::HIGHLIGHT_SMOOTH
  end
  
  def dispose
    @target.dispose
    @target_highlight.dispose
    @local_pos.dispose unless @local_pos == nil
    @target_id = nil
  end
  
  def show_char
    return unless @local_pos == nil
    local_position
  end
  
  def hide_char
    return if @local_pos == nil
    return if @local_pos.disposed?
    @local_pos.dispose 
  end
  
  def blink_update
    @target_highlight.update
    unless @blink
      @target_highlight.visible = false
      return 
    end
    @target_highlight.visible = true
    color = Color.new(255, 255, 255)
    unless TINY::TTM_GENERAL::BLINK_SELECTED
      @target_highlight.flash(color, 90)
      return
    end
    if @timer == 0
      @timer = TINY::TTM_GENERAL::BLINK_SPEED/2
      @target_highlight.flash(color, TINY::TTM_GENERAL::BLINK_SPEED)
    end
    @timer -= 1
  end
  
  def update
    blink_update
  end
  
end # Sprite_MapTarget

#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** NEW Class Scene_TinyMap
#╚═=═=════════════════════════════════════════════════════════════════════════=#
class Scene_TinyMap < Scene_Base
  
  include TINY::TTM_GENERAL
  
  def start
    super
    @tar = nil
    create_windows
    create_handler
    create_targets
    create_map
    create_background
    set_mappos if MODE == 2
  end
  
  def create_windows
    @head_window = Window_Map_Header.new
    @tar_window = Window_Target_List.new
  end
  
  def create_handler
    @tar_window.set_handler(:ok,     method(:check_transfer))
    @tar_window.set_handler(:cancel, method(:return_scene))
  end
  
  def create_targets
    @sprites = []
    $game_travelmap.targets.each { |tar_id|
      arr = TINY::TTM_TARGETS::TARGETS[tar_id][:graphic]
      @sprites << Sprite_MapTargetSet.new(arr[0], arr[1], arr[2], tar_id)
    }
    # Mark player pos
    @sprites.each { |e|
      val = e.target_id
      if  TINY::TTM_TARGETS::TARGETS[val][:teleportdest][0] == $game_map.map_id
        e.show_char
        return
      else
        e.hide_char
      end
    }
  end
  
  def create_map
    @map = Sprite_MapBack.new(144, 48)
    return unless MODE == 2
    @map.upd_pos(@map.get_size[0]/2,@map.get_size[1]/2) if $game_travelmap.targets.size == 0
    @map.jmp_pos
  end
  
  def create_background
    @background = Sprite.new
    @background.bitmap = Cache.map(BACKGROUND) rescue @background.bitmap = SceneManager.background_bitmap
  end
  
  def set_mappos
    @sprites.each { |spr|
        if spr.target_id == @tar_window.all_targets
          @map.upd_pos(spr.x, spr.y)
          @map.jmp_pos
        end
      }
  end
  
  def check_transfer
    dest = []
    return SceneManager.call(Scene_Map) if TINY::TTM_TARGETS::TARGETS[@tar_window.all_targets].nil?
    dest = TINY::TTM_TARGETS::TARGETS[@tar_window.all_targets][:teleportdest]
    if dest != nil
      $game_player.reserve_transfer(dest[0], dest[1], dest[2])
      perform_transfer
      $game_travelmap.last_target = @tar_window.all_targets
    end
    SceneManager.call(Scene_Map)
  end
  
  def update
    super
    @map.update if MODE == 2
    @sprites.each { |e| 
      e.update 
      e.upd_pos(@map.get_pos[0], @map.get_pos[1]) if MODE == 2
    }
    # Change Properties when target is changing
    if @tar != @tar_window.all_targets
      @sprites.each { |e|
        if e.target_id == @tar_window.all_targets
          e.blink = true if HIGHLIGHT_SELECTED
          @map.upd_pos(e.x, e.y) if MODE == 2
        else
          e.blink = false
        end
      }
      @tar = @tar_window.all_targets
    end
    $game_travelmap.update
  end
  
  def perform_transfer
    $game_player.perform_transfer
  end
  
  def terminate
    @sprites.each { |e| e.dispose }
    @map.dispose
    @background.dispose
    super
  end
  
end # Scene_TinyMap

#╔═=═══════════════════════════════════════════════════════════════════════════╗
#╠══════════════════════════════▲ END OF SCRIPT ▲══════════════════════════════╣
#╚═=═=═════════════════════════════════════════════════════════════════════════╝