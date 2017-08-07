#==============================================================================#
#  #*****************#                                                         #
#  #*** By Falcao ***#          * Int System Tool Selector + service pack      #
#  #*****************#          This script display a quick tool selection menu#
#                               and provide a bug fix pack and add-ons to      #
#       RMVXACE                 Falcao Interactive System 2.0                  #
#                               Date: September 18 2012                        #
#                                                                              #
# Falcao RGSS site:  http://falcaorgss.wordpress.com                           #
# Falcao Forum site: http://makerpalace.com                                    #
#                                                                              #
#==============================================================================#
# 0.2 Fixed small bug
# 0.3 Fixed issue with the Hook lol
# 0.4 removed new non movable metdod due to contant problems
# done with this script
#
#-------------------------------------------------------------------------------
# * Installation
#
# Paste this script BELOW FA Interactive System 2.0
#-------------------------------------------------------------------------------
# * Int System Tool Selector Features
#
#  - Display a quick tool selection menu
#  - Display interactive weapon icon on map
#  - Display item cost value below interactive weapon icon
#
# * Service pack add-ons and fixes
#
#  - Added move animation to Game_Arrow
#  - Added mouse support (plugin is activated if Mouse System button is installe
#  - You can now add more weapon ids to be used as interactive weapon
#  - Fixed minor bug when planting bombs or a barrel next to fall tiles
#  - Fixed bug when making a bomb arrow at real time (bomb movemenmet now reset)
#  - Fixed bug when bomb explode forcing the player to remove pick up graphic
 
msgbox(sprintf('Paste me below FA Interactive System 2.0')) if
not defined?(FalInt).is_a?(String)
 
# Configuration module
module IntTool
  include FalInt
 
  # Slot you want to use as tools:   true = weapon slot   false = armor slot
  WToolSlot = true
 
  # X position in tiles of the tool hud on screen
  Pos_X = 1
 
  # Y position in tiles of the tool hud on screen
  Pos_Y = 1
 
  # Input key to call the tool selectionwindow
  ToolSelectorKey = :ALT
 
  # Weapon/armors ids that equips the same tool, put inside the array the corr-
  # esponding weapon/armor ids (this function is helpful in case you want more
  # than one id to trigger the assigned tool), separate each id with a coma
  Interactive_Weapons = {
 
  HweaponId     => [ ],  # HookShot
  FweaponId     => [14,15,16,18],  # Flame
  BweaponId     => [ ],  # Bomb
  BAweaponId    => [ ],  # Barrel
  BladeWeaponId => [ ],  # Blade
  ArrowWeaponId => [3],  # Arrow
  GunWeaponId   => [2],  # Sniper
  WweaponId     => [4,8],# Water
  }
 
  #-----------------------------------------------------------------------------
  # * Available scripts calls
  #
  # SceneManager.goto(Scene_ToolSelector)   - Call the tools window manually
  # $game_system.hide_mhud                  - Hide tool hud on map
  # $game_system.show_mhud                  - Show tool hud on map
 
  # Note: The tool hud on map is visible when the player have equipped an
  # interactive weapon/armor.
 
  #-----------------------------------------------------------------------------
  # get interactive weapons / armor array
  def self.tool_weapons
    weapons = []  ; collected = []
    Interactive_Weapons.each do |w , value|
      value.each {|i| collected.push(i)}
      collected.push(w) unless value.include?(w)
    end
    WToolSlot ? data = $data_weapons : data = $data_armors
    collected.each {|w_id| weapons.push(data[w_id]) }
    return weapons
  end
 
  # check if specific interactive weapon / armor is equipped?
  def self.equipped?(dw, value)
    value.push(dw) unless value.include?(dw)
    if WToolSlot
      value.any? {|wep| $game_player.actor.weapons.include?($data_weapons[wep])}
    else
      value.any? {|arm| $game_player.actor.armors.include?($data_armors[arm])}
    end
  end
 
  # get equipped weapon / armor icon index
  def self.icon_index
    for t in tool_weapons
      return t.icon_index if $game_player.actor.weapons.include?(t) if WToolSlot
      return t.icon_index if $game_player.actor.armors.include?(t) if !WToolSlot
    end
    return nil
  end
end
 
#-------------------------------------------------------------------------------
# * Game system new variables
class Game_System
  attr_accessor :tool_icon_index
  attr_accessor :showing_twindow
  attr_accessor :enable_ctool
  attr_accessor :over_msbutton
  attr_accessor :hide_thud
 
  def hide_mhud
    @hide_thud = true
  end
 
  def show_mhud
    @hide_thud = nil
  end
end
 
#-------------------------------------------------------------------------------
# * Tools toolbar class
class Weapons_ToolBar
  include FalInt
  def initialize
    @globalpos_x = IntTool::Pos_X * 32
    @globalpos_y = IntTool::Pos_Y * 32
    $game_system.tool_icon_index = IntTool::icon_index
  end
 
  def create_sprites
    create_back_sprite
    create_icon_sprite
    create_itemcost_sprite  if item_cost > 0
  end
 
  def create_back_sprite
    return if not @back_sprite.nil?
    @back_sprite = Window_Base.new(@globalpos_x, @globalpos_y, 32, 32)
    @back_sprite.opacity = 150
    @back_sprite.z = 0
  end
 
  def dispose_back_sprite
    return if @back_sprite.nil?
    @back_sprite.dispose
    @back_sprite = nil
  end
 
  def create_icon_sprite
    return if not @icon_sprite.nil?
    @icon_sprite = Sprite.new
    @icon_sprite.bitmap = Bitmap.new(24, 24)
    @icon_sprite.x = @globalpos_x + 4
    @icon_sprite.y = @globalpos_y + 4
    refresh_icon_sprite
  end
 
  def refresh_icon_sprite
    return if @icon_sprite.nil?
    @icon_sprite.bitmap.clear
    return if $game_system.tool_icon_index.nil?
    icon = $game_system.tool_icon_index
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon % 16 * 24, icon / 16 * 24, 24, 24)
    @icon_sprite.bitmap.blt(0, 0, bitmap, rect)
  end
 
  def dispose_icon_sprite
    return if @icon_sprite.nil?
    @icon_sprite.dispose
    @icon_sprite.bitmap.dispose
    @icon_sprite = nil
  end
 
  def create_itemcost_sprite
    return if not @itemcost_sprite.nil?
    @itemcost_sprite = Sprite.new
    @itemcost_sprite.bitmap = Bitmap.new(32, 32)
    @itemcost_sprite.bitmap.font.size = 13
    @itemcost_sprite.bitmap.font.bold = true
    @itemcost_sprite.z = 50
    @itemcost_sprite.x = @globalpos_x + 10
    @itemcost_sprite.y = @globalpos_y + 12
    refresh_itemcost_sprite
  end
 
  def dispose_itemcost_sprite
    return if @itemcost_sprite.nil?
    @itemcost_sprite.dispose
    @itemcost_sprite.bitmap.dispose
    @itemcost_sprite = nil
  end
 
  def refresh_itemcost_sprite
    return if @itemcost_sprite.nil?
    @itemcost_sprite.bitmap.clear
    @itemcost_sprite.bitmap.draw_text(0, 0, 212, 32, item_cost.to_s)
  end
 
  def create_blink_sprite
    return if not @blink_sprite.nil?
    @blink_sprite = Sprite.new
    @blink_sprite.bitmap = Bitmap.new(32, 32)
    @blink_sprite.opacity = 60
    @blink_sprite.bitmap.fill_rect(0, 0, 24, 24, Color.new(255, 255, 255, 255))
    @blink_sprite.x = @globalpos_x + 4
    @blink_sprite.y = @globalpos_y + 4
    @blink_sprite.z = 50
  end
 
  def dispose_blink_sprite
    return if @blink_sprite.nil?
    @blink_sprite.dispose
    @blink_sprite.bitmap.dispose
    @blink_sprite = nil
  end
 
  # item cost value
  def item_cost
    cost = 0
    IntTool::Interactive_Weapons.each do |dw , value|
      cost = $game_party.item_number($data_items[BcostItemId]) if
      dw == BweaponId and IntTool.equipped?(dw, value)
      cost = $game_party.item_number($data_items[BarrelItemCost]) if
      dw == BAweaponId and IntTool.equipped?(dw, value)
      cost = $game_party.item_number($data_items[ArrowItemCost]) if
      dw == ArrowWeaponId and IntTool.equipped?(dw, value)
      cost = $game_player.actor.mp if dw == FweaponId and
      IntTool.equipped?(dw, value)
    end
    return cost
  end
 
  def dispose
    dispose_back_sprite
    dispose_icon_sprite
    dispose_itemcost_sprite
    dispose_blink_sprite
  end
 
  def update
    update_call_selector
    if $game_system.hide_thud.nil?
      $game_system.tool_icon_index.nil? ?  dispose  : create_sprites
      item_cost > 0 ? create_itemcost_sprite : dispose_itemcost_sprite
    else
      dispose
      return
    end
    update_icon_sprite
    update_blink_sprite
  end
 
  def update_icon_sprite
    if @lastcost != item_cost
      @lastcost = item_cost
      refresh_itemcost_sprite
    end
    if defined?(Map_Buttons).is_a?(String)
      if !@back_sprite.nil? && Mouse.object_area?(@back_sprite.x,@back_sprite.y,
        @back_sprite.width, @back_sprite.height)
        $game_system.enable_ctool = true
        create_blink_sprite
      else
        $game_system.enable_ctool = nil
        dispose_blink_sprite
      end
    end
    if $game_system.tool_icon_index != IntTool::icon_index
      $game_system.tool_icon_index = IntTool::icon_index
      refresh_icon_sprite
    end
  end
 
  def update_call_selector
    if Input.trigger?(IntTool::ToolSelectorKey)
      SceneManager.goto(Scene_ToolSelector)
      Sound.play_ok
    end
  end
 
  def update_blink_sprite
    return if @blink_sprite.nil?
    @blink_sprite.opacity -= 3
    @blink_sprite.opacity = 60 if @blink_sprite.opacity <= 0
  end
end
 
#-------------------------------------------------------------------------------
# Window tool selection
class Window_Tool_Select < Window_Selectable
  def initialize(x=0, y=0, w=150, h=192)
    super(x, y,  w, h)
    self.z = 101
    refresh
    self.index = 0
    activate
  end
 
  def item
    return @data[self.index]
  end
 
  def refresh
    self.contents.clear if self.contents != nil
    @data = []
    for weapon in IntTool.tool_weapons
      if $game_player.actor.equippable?(weapon) and
        $game_party.has_item?(weapon, true)
        @data.push(weapon)
      end
    end
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 26)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
 
  def draw_item(index)
    item = @data[index]
    x, y = index % col_max * (120 + 32), index / col_max  * 24
    self.contents.font.size = 18
    draw_icon(item.icon_index, x, y)
    self.contents.draw_text(x + 24, y, 212, 32, item.name, 0)
  end
 
  def item_max
    return @item_max.nil? ? 0 : @item_max
  end
 
  def col_max
    return IntTool.tool_weapons.size > 6 ? 2 : 1
  end
end
 
#-------------------------------------------------------------------------------
# Scene tool selector
class Scene_ToolSelector < Scene_MenuBase
  def start
    super
    IntTool.tool_weapons.size > 6 ? w = 300 : w = 150
    @tool_window = Window_Tool_Select.new(544/2 - w / 2, 416 / 2 - 192/2, w)
    @tool_window.opacity = 200
    @tool_header = Window_Base.new(@tool_window.x, @tool_window.y - 40, w, 40)
    @tool_header.contents.draw_text(-6, -6, @tool_header.width, 32, 'Habilidad', 1)
    @tool_header.opacity = @tool_window.opacity
  end
 
  def update
    super
    if Input.trigger?(:B)
      SceneManager.goto(Scene_Map)
      Sound.play_cancel
    end
    if Input.trigger?(:C)
      if @tool_window.item.nil?
        SceneManager.goto(Scene_Map)
        Sound.play_cancel
        return
      end
      type = @tool_window.item.etype_id
      $game_player.actor.change_equip_by_id(type, @tool_window.item.id)
      Sound.play_equip
      SceneManager.goto(Scene_Map)
    end
  end
 
  def terminate
    super
    @tool_window.dispose
    @tool_header.dispose
  end
end
 
#-------------------------------------------------------------------------------
# Sprite sets
class Spriteset_Map
  alias falint_toolbar_ini initialize
  def initialize
    @int_toolbar = Weapons_ToolBar.new
    falint_toolbar_ini
  end
 
  alias falint_toolbar_dis dispose
  def dispose
    @int_toolbar.dispose
    falint_toolbar_dis
  end
 
  alias falint_toolbar_up update
  def update
    @int_toolbar.update
    falint_toolbar_up
    if defined?(Map_Buttons).is_a?(String)
      @interact_buttoms.mouse_over_button? ? $game_system.over_msbutton = true :
      $game_system.over_msbutton = nil
    end
  end
end
 
#-------------------------------------------------------------------------------
# * Plugins
class Game_Player < Game_Character
  alias falint_toolbar_pickup_int_character pickup_int_character
  def pickup_int_character(char)
    return if @tool_anime > 0 || $game_system.enable_ctool ||
    $game_system.over_msbutton
    falint_toolbar_pickup_int_character(char)
  end
 
  alias falint_toolbar_perform_jump perform_jump
  def perform_jump
    return if $game_system.enable_ctool || $game_system.over_msbutton
    falint_toolbar_perform_jump
  end
end
 
#-------------------------------------------------------------------------------
# * Service pack script
class Game_CharacterBase
  alias falcao_intservice_pack_bombcoll collide_with_bomb
  def collide_with_bomb(x, y)
    return false if self.is_a?(Game_Player) and self.obfalling > 0
    falcao_intservice_pack_bombcoll(x, y)
  end
 
  alias falcao_intservice_pack_barrelcoll collide_with_barrel
  def collide_with_barrel(x, y)
    return false if self.is_a?(Game_Player) and self.obfalling > 0
    falcao_intservice_pack_barrelcoll(x, y)
  end
end
 
class Game_Player < Game_Character
  def tool_canuse?(id)
    return false if @obfalling > 0
    IntTool::Interactive_Weapons.each do |dw , value|
      if dw == id
        if defined?(Map_Buttons).is_a?(String)
          return false if $game_system.showing_twindow
          return true if Mouse.trigger?(0) && !$game_map.interpreter.running? &&
          $game_system.enable_ctool && !@player_busy &&
          IntTool.equipped?(dw, value)
        else
          return true if Input.trigger?(ToolActionKey) && !@player_busy &&
          !$game_map.interpreter.running? && IntTool.equipped?(dw, value)
        end
      end
    end
    return false
  end
 
  alias falcao_intservice_pack_start_bomb_impact start_bomb_impact
  def start_bomb_impact
    falcao_intservice_pack_start_bomb_impact
    applypick_grafhic if @player_busy
    @gamebomb.char_steps = 0
  end
end
 
class Game_Arrow < Game_Character
  alias falcao_intservice_pack_aini initialize
  def initialize
    falcao_intservice_pack_aini
    @step_anime = true
  end
end