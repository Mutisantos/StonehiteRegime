#==============================================================================
# Found here
#http://rm-vx-ace.de/WBB4/index.php/Thread/565-YSA-Battle-System-Predicted-Charge-Turn-Battle-BROKEN/
# ▼ YSA Battle Add-On: Order Battlers
# -- Last Updated: 2012.02.20
# -- Level: Easy
# -- Requires: n/a
#
#==============================================================================

$imported = {} if $imported.nil?
$imported["YSA-OrderBattler"] = true

#==============================================================================
# ▼ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.02.20 - Reduced lag a little.
# - Hide Gauge when victory.
# 2012.02.16 - Compatible with: Yami's PCTB.
# 2012.01.01 - Bug fixed: No-skill/item issue.
# 2011.12.28 - Bug fixed: Speed Fix issue.
# - Groundwork is also made to support future battle system types.
# - Can show/hide by a switch.
# 2011.12.27 - Started Script and Finished.
#
#==============================================================================
# ▼ Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
#
# -----------------------------------------------------------------------------
# Actor Notetags - These notetags go in the actor notebox in the database.
# -----------------------------------------------------------------------------
# <battler icon: x>
# Change actor's icon into x.
#
# <icon hue: x>
# Change icon hue.
#
# -----------------------------------------------------------------------------
# Enemy Notetags - These notetags go in the enemy notebox in the database.
# -----------------------------------------------------------------------------
# <battler icon: x>
# Change enemy's icon into x.
#
# <icon hue: x>
# Change icon hue.
#
#==============================================================================
# ▼ Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
#
#==============================================================================

module YSA
  module ORDER_GAUGE

    # Default Icon for actor and enemy
    DEFAULT_ENEMY_ICON = 260
    DEFAULT_ACTOR_ICON = 160

    # Order Sprite Visual. Decide Order's Background and Border.
    BATTLER_ICON_BORDERS = { # Do not remove this.
      # Type => [Back, Border, current],
      :actor => [257, 259, 256],
      :enemy => [258, 258, 268],
    } # Do not remove this.

    # Turn this to true if you want to show death battlers.
    # SHOW_DEATH = false

    # Coordinate-X of order gauge
    GAUGE_X = 500
    # Coordinate-Y of order gauge
    GAUGE_Y = 58  # Moved up to accommodate vertical layout

    # Show Switch. Turn this switch on to show it. If you want to disable, set this
    # to 0.
    SHOW_SWITCH = 87
  end
end

#==============================================================================
# ▼ Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

#==============================================================================
# ■ Regular Expression
#==============================================================================

module YSA
  module REGEXP
    module ACTOR
      BATTLER_ICON = /<(?:BATTLER_ICON|battler icon):[ ](\d+)?>/i
      ICON_HUE = /<(?:ICON_HUE|icon hue):[ ](\d+)?>/i
    end # ACTOR

    module ENEMY
      BATTLER_ICON = /<(?:BATTLER_ICON|battler icon):[ ](\d+)?>/i
      ICON_HUE = /<(?:ICON_HUE|icon hue):[ ](\d+)?>/i
    end # ENEMY
  end # REGEXP
end # YSA

#==============================================================================
# ■ DataManager
#==============================================================================

module DataManager

  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_orbt load_database; end
  def self.load_database
    load_database_orbt
    load_notetags_orbt
  end

  #--------------------------------------------------------------------------
  # new method: load_notetags_orbt
  #--------------------------------------------------------------------------
  def self.load_notetags_orbt
    groups = [$data_enemies + $data_actors]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_orbt
      end
    end
  end
end # DataManager

#==============================================================================
# ■ BattleManager
#==============================================================================

module BattleManager

  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  class << self
    attr_accessor :action_battlers
    attr_accessor :performed_battlers
    attr_accessor :ctb_battlers
    alias order_gauge_make_action_orders make_action_orders
  end

  #--------------------------------------------------------------------------
  # new method: make_ctb_battler_order
  #--------------------------------------------------------------------------
  def self.make_ctb_battler_order
    @ctb_battlers = []
    if $imported["YSA-PCTB"] && YSA::PCTB::CTB_MECHANIC[:predict] == 2
      battlers = self.sort_battlers
      battlers.each { |battler|
        battler.pctb_speed_cache = battler.pctb_speed
      }
      number = YSA::PCTB::CTB_MECHANIC[:pre_turns]
      i = 0
      number.times {
        add_ctb_battler_order(i)
        i += 1
      }
      return
    end
    ctb_battlers_dummy = self.sort_battlers
    ctb_battlers_dummy.each { |battler|
      @ctb_battlers.push(battler) unless battler.dead?
    }
  end

  #--------------------------------------------------------------------------
  # new method: add_ctb_battler_order
  #--------------------------------------------------------------------------
  def self.add_ctb_battler_order(i)
    battlers = self.sort_battlers(true)
    first_battler = battlers[0]
    tick = first_battler.pctb_ctr(true)
    battlers.each { |battler|
      battler.pctb_speed_cache += tick * battler.real_gain_pctb
    }
    first_battler.reset_pctb_speed(true) if i == 0
    first_battler.pctb_speed_cache -= self.pctb_threshold if i != 0
    @ctb_battlers.push(first_battler)
  end

  #--------------------------------------------------------------------------
  # alias method: make_action_orders
  #--------------------------------------------------------------------------
  def self.make_action_orders
    return if btype?(:pctb)
    order_gauge_make_action_orders
  end
end # BattleManager

#==============================================================================
# ■ RPG::Actor
#==============================================================================

class RPG::Actor < RPG::BaseItem

  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :battler_icon
  attr_accessor :icon_hue

  #--------------------------------------------------------------------------
  # common cache: load_notetags_orbt
  #--------------------------------------------------------------------------
  def load_notetags_orbt
    @battler_icon = YSA::ORDER_GAUGE::DEFAULT_ACTOR_ICON
    #---
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YSA::REGEXP::ACTOR::BATTLER_ICON
        @battler_icon = $1.to_i
      when YSA::REGEXP::ACTOR::ICON_HUE
        @icon_hue = $1.to_i
      end
    } # self.note.split
    #---
  end
end # RPG::Actor

#==============================================================================
# ■ RPG::Enemy
#==============================================================================

class RPG::Enemy < RPG::BaseItem

  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :battler_icon
  attr_accessor :icon_hue

  #--------------------------------------------------------------------------
  # common cache: load_notetags_orbt
  #--------------------------------------------------------------------------
  def load_notetags_orbt
    @battler_icon = YSA::ORDER_GAUGE::DEFAULT_ENEMY_ICON
    #---
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YSA::REGEXP::ENEMY::BATTLER_ICON
        @battler_icon = $1.to_i
      when YSA::REGEXP::ENEMY::ICON_HUE
        @icon_hue = $1.to_i
      end
    } # self.note.split
    #---
  end
end # RPG::Enemy

#==============================================================================
# ■ Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase

  #--------------------------------------------------------------------------
  # new method: battler_icon
  #--------------------------------------------------------------------------
  def battler_icon
    actor? ? actor.battler_icon : enemy.battler_icon
  end

  #--------------------------------------------------------------------------
  # new method: battler_icon_hue
  #--------------------------------------------------------------------------
  def battler_icon_hue
    actor? ? actor.icon_hue : enemy.icon_hue
  end
end # Game_Battler

#==============================================================================
# ■ Sprite_OrderBattler
#==============================================================================

class Sprite_OrderBattler < Sprite_Base

  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, battler, battle = :dtb, number = 0)
    super(viewport)
    @battler = battler
    @battle = battle
    @move_rate_x = 1
    @move_rate_y = 0.1
    @move_x = nil
    @move_y = nil
    @first_time = true
    @update_wait = 0
    @show_dead = false
    @number = number
    if $imported["YSA-PCTB"]
      type = YSA::PCTB::CTB_MECHANIC[:predict]
      num = YSA::PCTB::CTB_MECHANIC[:pre_turns]
    end
    self.x = num * 24 + 36 if @battle == :pctb2 && type && type == 2
    create_battler_bitmap
  end

  #--------------------------------------------------------------------------
  # create_battler_bitmap
  #--------------------------------------------------------------------------
  def create_battler_bitmap
    return unless @battler
    create_dtb_style if @battle == :dtb || @battle == :pctb
  end

  #--------------------------------------------------------------------------
  # create_dtb_style
  #--------------------------------------------------------------------------
  def create_dtb_style
    bitmap = Bitmap.new(24, 24)
    if $imported["YEA-BattleEngine"]
      icon_bitmap = $game_temp.iconset
    else
      icon_bitmap = Cache.system("IconSet")
    end
    #--- Create Battler Background (position 0) ---
    icon_index = @battler.actor? ? YSA::ORDER_GAUGE::BATTLER_ICON_BORDERS[:actor][0] : YSA::ORDER_GAUGE::BATTLER_ICON_BORDERS[:enemy][0]
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap.blt(0, 0, icon_bitmap, rect)
    #--- Create Battler Icon ---
    icon_index = @battler.battler_icon
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    temp_bitmap = Bitmap.new(24, 24)
    temp_bitmap.blt(0, 0, icon_bitmap, rect)
    temp_bitmap.hue_change(@battler.battler_icon_hue) if @battler.battler_icon_hue
    bitmap.blt(0, 0, temp_bitmap, Rect.new(0, 0, 24, 24))
    temp_bitmap.dispose
    #--- Create Battler Border (position 1) ---
    icon_index = @battler.actor? ? YSA::ORDER_GAUGE::BATTLER_ICON_BORDERS[:actor][1] : YSA::ORDER_GAUGE::BATTLER_ICON_BORDERS[:enemy][1]
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap.blt(0, 0, icon_bitmap, rect)
    self.bitmap.dispose if self.bitmap != nil
    self.bitmap = bitmap
    return if @created_icon
    @created_icon = true
    self.ox = 12; self.oy = 12
    self.x = 24 if @battle != :pctb2 && @battle != :pctb3
    self.y = 24  # Start at top for vertical layout
    self.z = 1
  end

  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    super
    return unless SceneManager.scene_is?(Scene_Battle)
    if $imported["YSA-PCTB"]
      type = YSA::PCTB::CTB_MECHANIC[:predict]
      num = YSA::PCTB::CTB_MECHANIC[:pre_turns]
    end
    self.x = BattleManager.ctb_battlers.size * 24 + 36 if BattleManager.ctb_battlers && @battle == :pctb2 && type && type == 1
    return if @battle == :pctb2 || @battle == :pctb3
    #---
    update_dtb_style if @battle == :dtb || @battle == :pctb
    self.opacity = 0 if @battle == :catb
  end

  #--------------------------------------------------------------------------
  # battler=
  #--------------------------------------------------------------------------
  def battler=(battler)
    @battler = battler
    return unless @battler
    create_dtb_style
  end

  #--------------------------------------------------------------------------
  # update_dtb_style
  #--------------------------------------------------------------------------
  def update_dtb_style
    actor_window = SceneManager.scene.actor_window
    enemy_window = SceneManager.scene.enemy_window
    if actor_window.active
      if $game_party.members[actor_window.index] == @battler
        @move_x = 12  # HIGHLIGHTED: Move left when targeted
      else
        @move_x = 24  # NORMAL: Default X position
      end
    end
    if enemy_window.active
      if $game_troop.members[enemy_window.index] == @battler
        @move_x = 12  # HIGHLIGHTED: Move left when targeted
      else
        @move_x = 24  # NORMAL: Default X position
      end
    end
    if !actor_window.active && !enemy_window.active
      @move_x = 24  # NORMAL: No targeting active
    end
    #---
    return if !@move_x && !@move_y
    if @battler.hidden? || (!@show_dead && @battler.dead?)
      self.opacity -= 20
    end
    # VERTICAL MOVEMENT: Handle Y-axis animation
    if self.y != @move_y && @move_y
      if @move_y > self.y
        @move_x = 30  # Moving down: Adjust X slightly
      elsif @move_y < self.y
        @move_x = 16  # Moving up: Adjust X slightly
      else
        @move_x = 20  # Same position: Center X
      end
      self.z = (@move_y < self.y) ? 7500 : 8500  # Z-order based on vertical direction
      if @move_y >= self.y
        self.y += [@move_rate_y, @move_y - self.y].min  # Move down
      else
        self.y -= [@move_rate_y, -@move_y + self.y].min  # Move up
      end
    end
    # HORIZONTAL MOVEMENT: Handle targeting feedback
    if self.x != @move_x && @move_x
      self.x += (self.x > @move_x) ? -@move_rate_x : @move_rate_x
    end
    if self.y == @move_y && @move_y
      @first_time = false if @first_time
      @move_y = nil
    end
    if self.x == @move_x && @move_x
      @move_x = nil
    end
  end

  #--------------------------------------------------------------------------
  # make_destination
  #--------------------------------------------------------------------------
  def make_destination
    make_dtb_destination if @battle == :dtb
    make_pctb_destination if @battle == :pctb
    make_pctb2_image if @battle == :pctb3
  end

  #--------------------------------------------------------------------------
  # make_dtb_destination
  #--------------------------------------------------------------------------
  def make_dtb_destination
    #---
    BattleManager.performed_battlers = [] if !BattleManager.performed_battlers
    array = BattleManager.performed_battlers.reverse
    action = BattleManager.action_battlers.reverse - BattleManager.performed_battlers.reverse
    array += action
    action.uniq!
    array.uniq!
    #---
    result = []
    for member in array
      next if member.hidden?
      result.push(member) unless member.dead?
      action.delete(member) if member.dead? and !@show_dead
    end
    if @show_dead
      for member in array
        next if member.hidden?
        result.push(member) if member.dead?
      end
    end
    #---
    index = result.index(@battler).to_i
    # VERTICAL LAYOUT: Stack icons vertically with 24px spacing
    # FLIPPED ORDER: Current battler on top (index 0), last on bottom
    total_battlers = result.size
    flipped_index = (total_battlers - 1) - index
    @move_y = 24 + flipped_index * 24
    @move_x = 24  # Fixed X position for all icons
    
    if BattleManager.in_turn?
      @move_x += 6 if action.include?(@battler)           # Active battler offset
      @move_x += 6 if (index + 1 == result.size) and action.size > 1  # Last battler offset
    end
    den = @first_time ? 12 : 24
    @move_rate_y = [((@move_y - self.y) / den).abs, 1].max
  end

  #--------------------------------------------------------------------------
  # make_pctb_destination
  #--------------------------------------------------------------------------
  def make_pctb_destination
    return unless BattleManager.ctb_battlers
    #---
    array = BattleManager.ctb_battlers.reverse
    #---
    result = []
    for member in array
      next if member.hidden?
      result.push(member) unless member.dead?
    end
    if @show_dead
      for member in array
        next if member.hidden?
        result.push(member) if member.dead?
      end
    end
    #---
    index = result.index(@battler).to_i
    # VERTICAL LAYOUT: Stack icons vertically with 24px spacing
    # FLIPPED ORDER: Current battler on top (index 0), last on bottom
    total_battlers = result.size
    flipped_index = (total_battlers - 1) - index
    @move_y = 24 + flipped_index * 24
    @move_x = 24  # Fixed X position for all icons
    den = @first_time ? 12 : 24
    @move_rate_y = [((@move_y - self.y) / den).abs, 1].max
  end

  #--------------------------------------------------------------------------
  # make_pctb2_image
  # This method renders the battler's position in the PCTB2 mechanic.
  # @number Attribute determines the battler's position in the array, used to locate the bitmap.
  #--------------------------------------------------------------------------
  def make_pctb2_image
    return unless BattleManager.ctb_battlers
    num = YSA::PCTB::CTB_MECHANIC[:pre_turns] - 1
    array = BattleManager.ctb_battlers
    self.battler = array[@number]
    # FLIPPED ORDER: Current battler on top (index 0), last on bottom
    self.y = 24 + @number * 24  # Simple vertical stacking
    if @number == 0
      # Current battler indicator - use position 2 for current battler only
      self.x = 12
    end
  end
end # Sprite_OrderBattler

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================

class Spriteset_Battle

  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :viewportOrder

  #--------------------------------------------------------------------------
  # alias method: create_viewports
  #--------------------------------------------------------------------------
  alias order_gauge_create_viewports create_viewports

  def create_viewports
    order_gauge_create_viewports
    @viewportOrder = Viewport.new
    @viewportOrder.z = 1000
    if YSA::ORDER_GAUGE::SHOW_SWITCH == 0 || $game_switches[YSA::ORDER_GAUGE::SHOW_SWITCH]
      @viewportOrder.ox = -YSA::ORDER_GAUGE::GAUGE_X
      @viewportOrder.oy = -YSA::ORDER_GAUGE::GAUGE_Y
    else
      @viewportOrder.ox = Graphics.width
      @viewportOrder.oy = Graphics.height
    end
  end
end # Spriteset_Battle

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :actor_window
  attr_accessor :enemy_window

  #--------------------------------------------------------------------------
  # alias method: create_all_windows
  #--------------------------------------------------------------------------
  alias order_gauge_create_all_windows create_all_windows

  def create_all_windows
    order_gauge_create_all_windows
    @spriteset_order = []
    if $imported["YSA-PCTB"] && YSA::PCTB::CTB_MECHANIC[:predict] == 1
      @active_order_sprite = Sprite_OrderBattler.new(@spriteset.viewportOrder, nil, :pctb2)
    end
    if $imported["YSA-PCTB"] && YSA::PCTB::CTB_MECHANIC[:predict] == 2
      num = YSA::PCTB::CTB_MECHANIC[:pre_turns]
      i = 0
      num.times {
        order = Sprite_OrderBattler.new(@spriteset.viewportOrder, nil, :pctb3, i)
        @spriteset_order.push(order)
        i += 1
      }
      return
    end
    for battler in $game_party.members + $game_troop.members
      battle_type = :dtb
      battle_type = :pctb if BattleManager.btype?(:pctb)
      battle_type = :catb if BattleManager.btype?(:catb)
      order = Sprite_OrderBattler.new(@spriteset.viewportOrder, battler, battle_type)
      @spriteset_order.push(order)
    end
    
    # Create static current turn indicator sprite
    create_static_turn_indicator
  end

  #--------------------------------------------------------------------------
  # new method: create_static_turn_indicator
  #--------------------------------------------------------------------------
  def create_static_turn_indicator
    @static_turn_indicator = Sprite.new(@spriteset.viewportOrder)
    bitmap = Bitmap.new(24, 24)
    
    if $imported["YEA-BattleEngine"]
      icon_bitmap = $game_temp.iconset
    else
      icon_bitmap = Cache.system("IconSet")
    end
    
    # Use the actor's turn indicator icon (position 2)
    icon_index = YSA::ORDER_GAUGE::BATTLER_ICON_BORDERS[:actor][2]
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap.blt(0, 0, icon_bitmap, rect, 220)
    
    @static_turn_indicator.bitmap = bitmap
    @static_turn_indicator.x = 12  # Same X as GAUGE_X
    @static_turn_indicator.y = 60  # Same Y as GAUGE_Y
    @static_turn_indicator.z = 1001  # Above other sprites
    @static_turn_indicator.visible = false  # Initially hidden
  end

  #--------------------------------------------------------------------------
  # alias method: battle_start
  #--------------------------------------------------------------------------
  alias order_gauge_battle_start battle_start

  def battle_start
    order_gauge_battle_start
    unless BattleManager.btype?(:pctb)
      BattleManager.make_action_orders
      for order in @spriteset_order
        order.make_destination
      end
    end
  end

  #--------------------------------------------------------------------------
  # alias method: dispose_spriteset
  #--------------------------------------------------------------------------
  alias order_gauge_dispose_spriteset dispose_spriteset

  def dispose_spriteset
    for order in @spriteset_order
      order.bitmap.dispose
      order.dispose
    end
    # Dispose static turn indicator
    if @static_turn_indicator
      @static_turn_indicator.bitmap.dispose
      @static_turn_indicator.dispose
    end
    order_gauge_dispose_spriteset
  end

  #--------------------------------------------------------------------------
  # alias method: update_basic
  #--------------------------------------------------------------------------
  alias order_gauge_update_basic update_basic

  def update_basic
    order_gauge_update_basic
    for order in @spriteset_order
      order.update
    end
    @active_order_sprite.update if @active_order_sprite
    if $imported["YSA-PCTB"]
      type = YSA::PCTB::CTB_MECHANIC[:predict]
    end
    
    # Update static turn indicator visibility
    update_static_turn_indicator
    
    if @update_ordergauge
      if type && type == 1
        BattleManager.actor.restore_speed
        BattleManager.actor.storage_speed
        BattleManager.actor.reset_pctb_speed
      end
      BattleManager.make_action_orders
      BattleManager.make_ctb_battler_order if BattleManager.btype?(:pctb)
      for order in @spriteset_order
        order.make_destination
      end
      @update_ordergauge = false
    end
    if YSA::ORDER_GAUGE::SHOW_SWITCH == 0 || $game_switches[YSA::ORDER_GAUGE::SHOW_SWITCH]
      @spriteset.viewportOrder.ox = -YSA::ORDER_GAUGE::GAUGE_X if @spriteset.viewportOrder.ox != -YSA::ORDER_GAUGE::GAUGE_X
      @spriteset.viewportOrder.oy = -YSA::ORDER_GAUGE::GAUGE_Y if @spriteset.viewportOrder.oy != -YSA::ORDER_GAUGE::GAUGE_Y
    else
      @spriteset.viewportOrder.ox = Graphics.height if @spriteset.viewportOrder.ox != Graphics.width
      @spriteset.viewportOrder.oy = Graphics.width if @spriteset.viewportOrder.oy != Graphics.height
    end
    if $game_party.all_dead? || $game_troop.all_dead?
      @spriteset.viewportOrder.ox = Graphics.height if @spriteset.viewportOrder.ox != Graphics.width
      @spriteset.viewportOrder.oy = Graphics.width if @spriteset.viewportOrder.oy != Graphics.height
    end
  end

  #--------------------------------------------------------------------------
  # new method: update_static_turn_indicator
  #--------------------------------------------------------------------------
  def update_static_turn_indicator
    return unless @static_turn_indicator
    
    # Show only when there's a current battler and order gauge is visible
    if BattleManager.action_list_ctb && BattleManager.action_list_ctb[0]
      current_battler = BattleManager.action_list_ctb[0]
      
      # Update icon based on current battler type
      update_static_indicator_icon(current_battler)
      
      # Show/hide based on gauge visibility
      gauge_visible = (YSA::ORDER_GAUGE::SHOW_SWITCH == 0 || $game_switches[YSA::ORDER_GAUGE::SHOW_SWITCH]) &&
                      !($game_party.all_dead? || $game_troop.all_dead?)
      @static_turn_indicator.visible = gauge_visible
      
      # Update position to follow current battler's position in queue
      update_static_indicator_position(current_battler)
    else
      @static_turn_indicator.visible = false
    end
  end

  #--------------------------------------------------------------------------
  # new method: update_static_indicator_icon
  #--------------------------------------------------------------------------
  def update_static_indicator_icon(battler)
    # Update icon based on battler type (actor vs enemy)
    icon_index = battler.actor? ? YSA::ORDER_GAUGE::BATTLER_ICON_BORDERS[:actor][2] : YSA::ORDER_GAUGE::BATTLER_ICON_BORDERS[:enemy][2]
    
    if $imported["YEA-BattleEngine"]
      icon_bitmap = $game_temp.iconset
    else
      icon_bitmap = Cache.system("IconSet")
    end
    
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    @static_turn_indicator.bitmap.clear
    @static_turn_indicator.bitmap.blt(0, 0, icon_bitmap, rect, 220)
  end

  #--------------------------------------------------------------------------
  # new method: update_static_indicator_position
  #--------------------------------------------------------------------------
  def update_static_indicator_position(battler)
    # Position the static indicator at the current battler's queue position
    # Find the battler's position in the order
    if BattleManager.btype?(:pctb) && BattleManager.ctb_battlers
      result = BattleManager.ctb_battlers.select { |b| !b.dead? && !b.hidden? }
      index = result.index(battler)
      if index
        # Use the same vertical positioning logic as other sprites
        @static_turn_indicator.x = -4 # Offset to the right of the queue
        @static_turn_indicator.y = 12  # Same Y as current battler
      end
    end
  end

  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias order_gauge_update update

  def update
    order_gauge_update
    return if YSA::PCTB::CTB_MECHANIC[:predict] == 2
    if @actor_command_window.active
      if BattleManager.actor.input == nil
        return
      end
      if @actor_command_window.current_symbol == :attack && !BattleManager.actor.input.attack?
        BattleManager.actor.input.set_attack if BattleManager.actor.usable?($data_skills[BattleManager.actor.attack_skill_id])
        @update_ordergauge = true
      end
      if @actor_command_window.current_symbol == :guard && BattleManager.actor.input.item != $data_skills[BattleManager.actor.guard_skill_id]
        BattleManager.actor.input.set_guard if BattleManager.actor.usable?($data_skills[BattleManager.actor.guard_skill_id])
        @update_ordergauge = true
      end
      if $imported["YEA-BattleCommandList"]
        if @actor_command_window.current_symbol == :use_skill && BattleManager.actor.input.item != $data_skills[@actor_command_window.current_ext]
          BattleManager.actor.input.set_skill(@actor_command_window.current_ext) if BattleManager.actor.usable?($data_skills[@actor_command_window.current_ext])
          @update_ordergauge = true
        end
      end
    end
    if @skill_window.active && BattleManager.actor && BattleManager.actor.input.item != @skill_window.item && @skill_window.current_item_enabled?
      BattleManager.actor.input.set_skill(@skill_window.item.id) if BattleManager.actor.usable?(@skill_window.item)
      @update_ordergauge = true
    end
    if @item_window.active && BattleManager.actor && BattleManager.actor.input.item != @item_window.item && @item_window.current_item_enabled?
      BattleManager.actor.input.set_item(@item_window.item.id) if BattleManager.actor.usable?(@item_window.item)
      @update_ordergauge = true
    end
  end

  #--------------------------------------------------------------------------
  # alias method: on_skill_cancel
  #--------------------------------------------------------------------------
  alias order_gauge_on_skill_cancel on_skill_cancel

  def on_skill_cancel
    order_gauge_on_skill_cancel
    BattleManager.actor.input.clear
    @update_ordergauge = true
  end

  #--------------------------------------------------------------------------
  # alias method: on_item_cancel
  #--------------------------------------------------------------------------
  alias order_gauge_on_item_cancel on_item_cancel

  def on_item_cancel
    order_gauge_on_item_cancel
    BattleManager.actor.input.clear
    @update_ordergauge = true
  end

  #--------------------------------------------------------------------------
  # alias method: turn_start
  #--------------------------------------------------------------------------
  alias order_gauge_turn_start turn_start

  def turn_start
    order_gauge_turn_start
    for order in @spriteset_order
      order.make_destination
    end
  end

  #--------------------------------------------------------------------------
  # alias method: process_action_end
  #--------------------------------------------------------------------------
  alias order_gauge_process_action_end process_action_end

  def process_action_end
    order_gauge_process_action_end
    for order in @spriteset_order
      order.make_destination
    end
  end

  #--------------------------------------------------------------------------
  # new method: refresh_order_gauge
  # Call this method when battlers are added during battle events
  # Usage: SceneManager.scene.refresh_order_gauge
  #--------------------------------------------------------------------------
  def refresh_order_gauge
    # Dispose existing sprites
    for order in @spriteset_order
      order.bitmap.dispose if order.bitmap
      order.dispose
    end
    @spriteset_order.clear
    
    # Recreate sprites with current battlers
    if $imported["YSA-PCTB"] && YSA::PCTB::CTB_MECHANIC[:predict] == 1
      @active_order_sprite = Sprite_OrderBattler.new(@spriteset.viewportOrder, nil, :pctb2)
    end
    if $imported["YSA-PCTB"] && YSA::PCTB::CTB_MECHANIC[:predict] == 2
      num = YSA::PCTB::CTB_MECHANIC[:pre_turns]
      i = 0
      num.times {
        order = Sprite_OrderBattler.new(@spriteset.viewportOrder, nil, :pctb3, i)
        @spriteset_order.push(order)
        i += 1
      }
      return
    end
    for battler in $game_party.members + $game_troop.members
      battle_type = :dtb
      battle_type = :pctb if BattleManager.btype?(:pctb)
      battle_type = :catb if BattleManager.btype?(:catb)
      order = Sprite_OrderBattler.new(@spriteset.viewportOrder, battler, battle_type)
      @spriteset_order.push(order)
    end
    
    # Update order calculations
    BattleManager.make_action_orders
    BattleManager.make_ctb_battler_order if BattleManager.btype?(:pctb)
    
    # Update sprite positions
    for order in @spriteset_order
      order.make_destination
    end
  end
end # Scene_Battle

#==============================================================================
#
# ▼ End of File
#
#==============================================================================
