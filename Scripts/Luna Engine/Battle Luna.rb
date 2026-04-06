$imported = {} if $imported.nil?
$imported["YEL-BattleLuna"] = true

#==============================================================================
# ■ RPG::BaseItem
#==============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :atk_animation_id1
  attr_accessor :atk_animation_id2
  
end # RPG::BaseItem

#==============================================================================
# ■ Game_Actor
#==============================================================================

class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor   :battle_hud
  
  #--------------------------------------------------------------------------
  # new method: hud_x
  #--------------------------------------------------------------------------
  def hud_x
    @battle_hud ? @battle_hud.screen_x : 0
  end
  
  #--------------------------------------------------------------------------
  # new method: hud_y
  #--------------------------------------------------------------------------
  def hud_y
    @battle_hud ? @battle_hud.screen_y : 0
  end
  
  #--------------------------------------------------------------------------
  # new method: hud_z
  #--------------------------------------------------------------------------
  def hud_z
    @battle_hud ? @battle_hud.screen_z : 0
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: use_sprite?
  #--------------------------------------------------------------------------
  alias battle_luna_use_sprite? use_sprite?
  def use_sprite?
    return battle_luna_use_sprite? unless BattleLuna::CORE::VISUAL[:animation_on_hud]
    return true
  end
  
  #--------------------------------------------------------------------------
  # new method: sprite
  #--------------------------------------------------------------------------
  def sprite
    index = $game_party.battle_members.index(self)
    return nil unless index
    return nil unless SceneManager.scene_is?(Scene_Battle)
    return nil unless SceneManager.scene.spriteset
    return SceneManager.scene.spriteset.actor_sprites[index]
  end
  
  #--------------------------------------------------------------------------
  # Define method :screen_x
  #--------------------------------------------------------------------------
  if BattleLuna::CORE::VISUAL[:animation_on_hud]
  def screen_x
    return hud_x + BattleLuna::CORE::VISUAL[:ani_offset_x] || 0
  end
  end

  #--------------------------------------------------------------------------
  # Define method :screen_y
  #--------------------------------------------------------------------------
  if BattleLuna::CORE::VISUAL[:animation_on_hud]
  def screen_y
    return hud_y + BattleLuna::CORE::VISUAL[:ani_offset_y] || 0
  end
  end

  #--------------------------------------------------------------------------
  # Define method :screen_z
  #--------------------------------------------------------------------------
  if BattleLuna::CORE::VISUAL[:animation_on_hud]
  def screen_z
    return hud_z || 0
  end
  end
  
end # Game_Actor

#==============================================================================
# ■ Game_Enemy
#==============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # new method: sprite
  #--------------------------------------------------------------------------
  def sprite
    return nil unless SceneManager.scene_is?(Scene_Battle)
    return nil unless SceneManager.scene.spriteset
    return SceneManager.scene.spriteset.enemy_sprites.reverse[self.index]
  end
  
  #--------------------------------------------------------------------------
  # new method: atk_animation_id1
  #--------------------------------------------------------------------------
  def atk_animation_id1
    return enemy.atk_animation_id1 || BattleLuna::CORE::VISUAL[:enemy_attack_animation]
  end
  
  #--------------------------------------------------------------------------
  # new method: atk_animation_id2
  #--------------------------------------------------------------------------
  def atk_animation_id2
    return enemy.atk_animation_id2 || 0
  end
  
end # Game_Enemy

#==============================================================================
# ■ Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # alias method: update_bitmap
  #--------------------------------------------------------------------------
  alias battle_luna_update_bitmap update_bitmap
  def update_bitmap
    return if @battler.battler_name == ""
    battle_luna_update_bitmap
  end
  
end # Sprite_Battler

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================

class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_reader   :info_viewport
  attr_reader   :battle_hud
  attr_accessor :actor_sprites
  attr_accessor :enemy_sprites
  
  #--------------------------------------------------------------------------
  # alias method: create_viewports
  #--------------------------------------------------------------------------
  alias battle_luna_create_viewports create_viewports
  def create_viewports
    battle_luna_create_viewports
    create_battle_hud
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_actors
  # Fixed large party issue.
  #--------------------------------------------------------------------------
  def create_actors
    max_members = $game_party.max_battle_members
    @actor_sprites = Array.new(max_members) { Sprite_Battler.new(@info_viewport) }
  end
  
  #--------------------------------------------------------------------------
  # new method: create_battle_hud
  #--------------------------------------------------------------------------
  def create_battle_hud
    @battle_hud = Battle_HUD.new(@info_viewport)
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias battle_luna_update update
  def update
    battle_luna_update
    update_battle_hud
  end
  
  #--------------------------------------------------------------------------
  # new method: update_battle_hud
  #--------------------------------------------------------------------------
  def update_battle_hud
    @battle_hud.update
  end
  
  #--------------------------------------------------------------------------
  # alias method: dispose
  #--------------------------------------------------------------------------
  alias battle_luna_dispose dispose
  def dispose
    battle_luna_dispose
    dispose_battle_hud
  end
  
  #--------------------------------------------------------------------------
  # new method: dispose_battle_hud
  #--------------------------------------------------------------------------
  def dispose_battle_hud
    @battle_hud.dispose
  end
  
end # Spriteset_Battle

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # new method: spriteset
  #--------------------------------------------------------------------------
  def spriteset
    @spriteset
  end
  
  #--------------------------------------------------------------------------
  # new method: help_window
  #--------------------------------------------------------------------------
  def help_window
    @help_window
  end
  
  #--------------------------------------------------------------------------
  # new method: status_window
  #--------------------------------------------------------------------------
  def status_window
    @status_window
  end
  
  #--------------------------------------------------------------------------
  # new method: actor_command_window
  #--------------------------------------------------------------------------
  def actor_command_window
    @actor_command_window
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: show_attack_animation
  #--------------------------------------------------------------------------
  def show_attack_animation(targets)
    show_normal_animation(targets, @subject.atk_animation_id1, false)
    wait_for_animation
    show_normal_animation(targets, @subject.atk_animation_id2, true)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update_message_open
  #--------------------------------------------------------------------------
  def update_message_open
    close_msg = BattleLuna::CORE::VISUAL[:status_close_msg]
    if $game_message.busy? && (!@status_window.close? || !close_msg)
      @message_window.openness = 0 if close_msg
      @status_window.close if close_msg
      @party_command_window.close
      @actor_command_window.close
    end
  end
  
end # Scene_Battle

#==============================================================================
# ■ Spriteset_HUD
#==============================================================================

class Spriteset_HUD
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :battler
  attr_accessor :actor_window
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, battler)
    @viewport = viewport
    @battler = battler
    @sprites = []
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    result = setting[:x] + eval(setting[:offset_x].to_s)
    return result if setting[:vertical]
    if setting[:center] 
      total_battlers = $game_party.battle_members.size
      total_width = setting[:max_width] / total_battlers
      result += (total_width - setting[:spacing]) * index
      result += [(total_width - setting[:width]), 0].max / 2
    else
      result += (setting[:width] + setting[:spacing]) * index
    end
    result
  end

  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    result = setting[:y] + eval(setting[:offset_y].to_s)
    return result unless setting[:vertical]
    if setting[:center] 
      total_battlers = $game_party.battle_members.size
      total_height = setting[:max_height] / total_battlers
      result += (total_height - setting[:spacing]) * index
      result += [(total_height - setting[:height]), 0].max / 2
    else
      result += (setting[:height] + setting[:spacing]) * index
    end
    result
  end

  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # opacity
  #--------------------------------------------------------------------------
  def opacity
    return 0 unless SceneManager.scene_is?(Scene_Battle)
    return 0 unless SceneManager.scene.status_window
    return SceneManager.scene.status_window.openness
  end
  
  #--------------------------------------------------------------------------
  # visible
  #--------------------------------------------------------------------------
  def visible
    return false unless SceneManager.scene_is?(Scene_Battle)
    return false unless SceneManager.scene.status_window
    return SceneManager.scene.status_window.visible
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::HUD::BATTLER_HUD
  end
  
  #--------------------------------------------------------------------------
  # index
  #--------------------------------------------------------------------------
  def index
    @battler.index
  end
  
  #--------------------------------------------------------------------------
  # battler
  #--------------------------------------------------------------------------
  def battler=(battler)
    return if @battler == battler
    @battler = battler
    @sprites.each { |sprite| sprite.battler = battler }
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return dispose if @battler.nil?
    refresh if @battler && @sprites.size == 0
    @sprites.each { |sprite| sprite.update }
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    @sprites.each { |sprite| sprite.dispose }
    @sprites.clear
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    dispose
    #---
    create_window
    create_main
    create_select
    create_face
    create_name
    create_bars
    create_numbers
    create_states
    #---
    update
  end
  
  #--------------------------------------------------------------------------
  # create_window
  #--------------------------------------------------------------------------
  def create_window
  end
  
  #--------------------------------------------------------------------------
  # create_main
  #--------------------------------------------------------------------------
  def create_main
    main = SpriteHUD_Main.new(@viewport, self)
    @sprites.push(main)
  end
  
  #--------------------------------------------------------------------------
  # create_select
  #--------------------------------------------------------------------------
  def create_select
    select = SpriteHUD_Select.new(@viewport, self)
    @sprites.push(select)
  end
  
  #--------------------------------------------------------------------------
  # create_face
  #--------------------------------------------------------------------------
  def create_face
    face = SpriteHUD_Face.new(@viewport, self)
    @sprites.push(face)
  end
  
  #--------------------------------------------------------------------------
  # create_name
  #--------------------------------------------------------------------------
  def create_name
    name = SpriteHUD_Name.new(@viewport, self)
    @sprites.push(name)
  end
  
  #--------------------------------------------------------------------------
  # create_bars
  #--------------------------------------------------------------------------
  def create_bars
    hp_bar = SpriteHUD_Bar.new(@viewport, self, :hp_bar)
    mp_bar = SpriteHUD_Bar.new(@viewport, self, :mp_bar)
    tp_bar = SpriteHUD_Bar.new(@viewport, self, :tp_bar)
    @sprites.push(hp_bar, mp_bar, tp_bar)
  end
  
  #--------------------------------------------------------------------------
  # create_numbers
  #--------------------------------------------------------------------------
  def create_numbers
    hp = SpriteHUD_Numbers.new(@viewport, self, :hp)
    mp = SpriteHUD_Numbers.new(@viewport, self, :mp)
    tp = SpriteHUD_Numbers.new(@viewport, self, :tp)
    mhp = SpriteHUD_Numbers.new(@viewport, self, :mhp)
    mmp = SpriteHUD_Numbers.new(@viewport, self, :mmp)
    mtp = SpriteHUD_Numbers.new(@viewport, self, :mtp)
    @sprites.push(hp, mp, tp, mhp, mmp, mtp)
  end
  
  #--------------------------------------------------------------------------
  # create_states
  #--------------------------------------------------------------------------
  def create_states
    states = SpriteHUD_States.new(@viewport, self)
    @sprites.push(states)
  end
  
end # Spriteset_HUD

#==============================================================================
# ■ Battle_HUD
#==============================================================================

class Battle_HUD
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport)
    @viewport = viewport
    @spritesets = []
    setup_hud
  end
  
  #--------------------------------------------------------------------------
  # setup_hud
  #--------------------------------------------------------------------------
  def setup_hud
    $game_party.max_battle_members.times { |i|
      spriteset = Spriteset_HUD.new(@viewport, nil)
      @spritesets.push(spriteset)
    }
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    @spritesets.each_with_index { |spriteset, index|
      spriteset.battler.battle_hud = nil if spriteset.battler
      spriteset.battler = $game_party.battle_members[index]
      next unless $game_party.battle_members[index]
      next if $game_troop.all_dead?
      $game_party.battle_members[index].battle_hud = spriteset
    }
    @spritesets.each { |spriteset| spriteset.update }
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    @spritesets.each { |spriteset| spriteset.dispose }
    @spritesets.clear
    #---
    $game_party.members.each { |battler| battler.battle_hud = nil }
  end
  
  #--------------------------------------------------------------------------
  # actor_window
  #--------------------------------------------------------------------------
  def actor_window=(window)
    @actor_window = window
    @spritesets.each { |spriteset| spriteset.actor_window = window }
  end
  
end # Battle_HUD

#==============================================================================
# ■ Window_BattleStatus
#==============================================================================

class Window_BattleStatus < Window_Selectable
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias battle_luna_initialize initialize
  def initialize
    battle_luna_initialize
    init_position
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    BattleLuna::HUD::BATTLER_HUD[:vertical] ? 1 : [1, item_max].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    width = BattleLuna::HUD::BACKGROUND_WINDOW[:width]
    [width, standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    height = BattleLuna::HUD::BACKGROUND_WINDOW[:height]
    [height, standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    BattleLuna::HUD::BACKGROUND_WINDOW[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    BattleLuna::HUD::BACKGROUND_WINDOW[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    BattleLuna::HUD::BACKGROUND_WINDOW[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::HUD::BACKGROUND_WINDOW
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    BattleLuna::HUD::BACKGROUND_WINDOW[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: type
  #--------------------------------------------------------------------------
  def type
    BattleLuna::HUD::BACKGROUND_WINDOW[:type]
  end

  #--------------------------------------------------------------------------
  # overwrite method: refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: draw_item
  #--------------------------------------------------------------------------
  def draw_item(index)
    # Removed.
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: update
  #--------------------------------------------------------------------------
  def update
    super
    case type
    when 0; update_type0
    when 1; update_type1
    when 2; update_type2
    end    
    init_position
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: update_cursor
  #--------------------------------------------------------------------------
  alias battle_luna_update_cursor update_cursor
  def update_cursor
    cursor_rect.empty
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_BattleStatus

#==============================================================================
# ■ SpriteHUD_Main
#==============================================================================

class SpriteHUD_Main < Sprite_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @main = ""
    @highlight = 12
    @fade = 0
    init_visible
  end
  
  #--------------------------------------------------------------------------
  # init_visible
  #--------------------------------------------------------------------------
  def init_visible
    return unless setting[:collapse]
    if setting[:collapse_type] == 0
      self.opacity = @battler.dead? ? 0 : 255
    elsif setting[:collapse_type] == 1
      self.tone = @battler.dead? ? Tone.new(0, 0, 0, 255) : Tone.new(0, 0, 0, 0)
    end
  end
  
  #--------------------------------------------------------------------------
  # battler
  #--------------------------------------------------------------------------
  def battler=(battler)
    return if @battler == battler
    @battler = battler
    update
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if main_change?
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
    #---
    update_highlight
    update_collapse
  end
  
  #--------------------------------------------------------------------------
  # update_highlight
  #--------------------------------------------------------------------------
  def update_highlight
    update_tone
    window = @spriteset.actor_window
    return unless window
    is_select = window.index == @battler.index || window.cursor_all
    return reset_tone if !window.active
    return reset_tone if !is_select
    return reset_tone unless setting[:highlight]
    @highlight = (@highlight + 1) % 24
    self.opacity = @battler.dead? ? 128 : 255
  end
  
  #--------------------------------------------------------------------------
  # update_tone
  #--------------------------------------------------------------------------
  def update_tone
    gray = self.tone.gray
    highlight = (12 - @highlight).abs * 3
    self.tone = Tone.new(highlight, highlight, highlight, gray)
  end
  
  #--------------------------------------------------------------------------
  # reset_tone
  #--------------------------------------------------------------------------
  def reset_tone
    gray = self.tone.gray
    self.tone = Tone.new(0, 0, 0, gray)
    init_visible
  end
  
  #--------------------------------------------------------------------------
  # update_collapse
  #--------------------------------------------------------------------------
  def update_collapse
    return unless setting[:collapse]
    rate = @battler.dead? ? 6 : -12
    if setting[:collapse_type] == 0
      @fade += rate
      @fade = 0 if @fade < 0
      @fade = 255 if @fade > 255
      #---
      self.blend_type = @battler.dead? ? 1 : 0
      if @battler.dead?
        self.color.set(255, 128, 128, 128)
      else
        self.color.set(0, 0, 0, 0)
      end
    elsif setting[:collapse_type] == 1
      gray = self.tone.gray
      self.tone.gray += rate
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    @main = real_name
    #---
    self.bitmap = Cache.system(@main)
  end
  
  #--------------------------------------------------------------------------
  # main_change?
  #--------------------------------------------------------------------------
  def main_change?
    @main != real_name
  end
  
  #--------------------------------------------------------------------------
  # main_change?
  #--------------------------------------------------------------------------
  def real_name
    result = setting[:filename]
    result += "_#{@battler.actor.id}" if setting[:base_actor]
    result += "_#{@battler.class.id}" if setting[:base_class]
    result
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::HUD::BATTLER_HUD[:main]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity - @fade
  end
  
end # SpriteHUD_Main

#==============================================================================
# ■ SpriteHUD_Select
#==============================================================================

class SpriteHUD_Select < Sprite_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @select = ""
    @frame = 0
    @tick = self.setting[:fps]
    @sx = 0
    @sy = 0
  end
  
  #--------------------------------------------------------------------------
  # battler
  #--------------------------------------------------------------------------
  def battler=(battler)
    return if @battler == battler
    @battler = battler
    update
  end
    
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if select_change?
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    #---
    update_visible
    update_frame
  end
  
  #--------------------------------------------------------------------------
  # update_visible
  #--------------------------------------------------------------------------
  def update_visible
    reset_visible
    window = @spriteset.actor_window
    if window && window.active
      is_select = window.index == @battler.index || window.cursor_all
      if is_select
        self.visible = true
        return
      else
        return reset_visible
      end
    end
    return reset_visible unless setting[:active]
    return reset_visible unless BattleManager.actor
    return reset_visible unless BattleManager.actor == @battler
    self.visible = true
  end
  
  #--------------------------------------------------------------------------
  # update_frame
  #--------------------------------------------------------------------------
  def update_frame
    @tick -= 1
    return unless @tick <= 0
    @tick  = setting[:fps]
    @frame = (@frame + 1) % setting[:frame]
    self.src_rect.set(@frame * @sx, 0, @sx, @sy)
  end
  
  #--------------------------------------------------------------------------
  # reset_visible
  #--------------------------------------------------------------------------
  def reset_visible
    self.visible = false
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    @select = real_name
    #---
    self.bitmap = Cache.system(@select)
    #---
    @sx = self.bitmap.width / setting[:frame]
    @sy = self.bitmap.height
    #---
    self.src_rect.set(0, 0, @sx, @sy)
  end
  
  #--------------------------------------------------------------------------
  # select_change?
  #--------------------------------------------------------------------------
  def select_change?
    @select != real_name
  end
  
  #--------------------------------------------------------------------------
  # main_change?
  #--------------------------------------------------------------------------
  def real_name
    result = setting[:filename]
    result += "_#{@battler.actor.id}" if setting[:base_actor]
    result += "_#{@battler.class.id}" if setting[:base_class]
    result
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::HUD::BATTLER_HUD[:select]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
end # SpriteHUD_Select

#==============================================================================
# ■ SpriteHUD_Face
#==============================================================================

class SpriteHUD_Face < Sprite_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @face = ["", 0]
    @highlight = 12
    @fade = 0
    init_visible
  end
  
  #--------------------------------------------------------------------------
  # battler
  #--------------------------------------------------------------------------
  def battler=(battler)
    return if @battler == battler
    @battler = battler
    update
  end
  
  #--------------------------------------------------------------------------
  # init_visible
  #--------------------------------------------------------------------------
  def init_visible
    return unless setting[:collapse]
    if setting[:collapse_type] == 0
      self.opacity = @battler.dead? ? 0 : 255
    elsif setting[:collapse_type] == 1
      self.tone = @battler.dead? ? Tone.new(0, 0, 0, 255) : Tone.new(0, 0, 0, 0)
    end
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if face_change?
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
    #---
    update_highlight
    update_collapse
  end
  
  #--------------------------------------------------------------------------
  # update_highlight
  #--------------------------------------------------------------------------
  def update_highlight
    update_tone
    window = @spriteset.actor_window
    return unless window
    is_select = window.index == @battler.index || window.cursor_all
    return reset_tone if !window.active
    return reset_tone if !is_select
    return reset_tone unless setting[:highlight]
    @highlight = (@highlight + 1) % 24
    self.opacity = @battler.dead? ? 128 : 255
  end
  
  #--------------------------------------------------------------------------
  # update_tone
  #--------------------------------------------------------------------------
  def update_tone
    gray = self.tone.gray
    highlight = (12 - @highlight).abs * 3
    self.tone = Tone.new(highlight, highlight, highlight, gray)
  end
  
  #--------------------------------------------------------------------------
  # reset_tone
  #--------------------------------------------------------------------------
  def reset_tone
    gray = self.tone.gray
    self.tone = Tone.new(0, 0, 0, gray)
    init_visible
  end
  
  #--------------------------------------------------------------------------
  # update_collapse
  #--------------------------------------------------------------------------
  def update_collapse
    return unless setting[:collapse]
    rate = @battler.dead? ? 6 : -12
    if setting[:collapse_type] == 0
      @fade += rate
      @fade = 0 if @fade < 0
      @fade = 255 if @fade > 255
      #---
      self.blend_type = @battler.dead? ? 1 : 0
      if @battler.dead?
        self.color.set(255, 128, 128, 128)
      else
        self.color.set(0, 0, 0, 0)
      end
    elsif setting[:collapse_type] == 1
      gray = self.tone.gray
      self.tone.gray += rate
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    case setting[:type]
    when 0; refresh_type0
    when 1; refresh_type1
    when 2; refresh_type2
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh_type0
  #--------------------------------------------------------------------------
  def refresh_type0
    @face.clear
    @face = [faceset_name[0], faceset_name[1]]
    face_name = @face[0]
    face_index = @face[1]
    #---
    bitmap = Bitmap.new(96, 96)
    face_bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
    bitmap.blt(0, 0, face_bitmap, rect)
    face_bitmap.dispose
    #---
    self.bitmap.dispose if self.bitmap
    self.bitmap = bitmap
  end
  
  #--------------------------------------------------------------------------
  # refresh_type1
  #--------------------------------------------------------------------------
  def refresh_type1
    @face.clear
    @face = [real_name, 0]
    #---
    self.bitmap = Cache.face(real_name)
  end
  
  #--------------------------------------------------------------------------
  # refresh_type2
  #--------------------------------------------------------------------------
  def refresh_type2
    @face.clear
    @face = [@battler.face_name, @battler.face_index]
    #---
    self.bitmap = Cache.face(real_name)
  end
  
  #--------------------------------------------------------------------------
  # face_change?
  #--------------------------------------------------------------------------
  def face_change?
    case setting[:type]
    when 0
      return faceset_name != @face
    when 1
      return @face[0] != real_name
    when 2
      return @face[0] + "_" + @face[1].to_s != real_name
    end
  end
  
  #--------------------------------------------------------------------------
  # faceset_name
  #--------------------------------------------------------------------------
  def faceset_name
    [@battler.face_name, @battler.face_index]
  end
  
  #--------------------------------------------------------------------------
  # real_name
  #--------------------------------------------------------------------------
  def real_name
    result = ""
    if setting[:type] == 1
      result = setting[:type_1][:filename]
      result += "_#{@battler.actor.id}" if setting[:type_1][:base_actor]
      result += "_#{@battler.class.id}" if setting[:type_1][:base_class]
    elsif setting[:type] == 2
      result = "#{@battler.face_name}_#{@battler.face_index}"
    end
    result
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::HUD::BATTLER_HUD[:face]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity - @fade
  end
  
  #--------------------------------------------------------------------------
  # highlight_time
  #--------------------------------------------------------------------------
  def highlight_time
    45
  end
  
  #--------------------------------------------------------------------------
  # highlight_rate
  #--------------------------------------------------------------------------
  def highlight_rate
    60
  end
  
end # SpriteHUD_Face

#==============================================================================
# ■ SpriteHUD_Name
#==============================================================================

class SpriteHUD_Name < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @name = ""
  end
  
  #--------------------------------------------------------------------------
  # battler
  #--------------------------------------------------------------------------
  def battler=(battler)
    return if @battler == battler
    @battler = battler
    update
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if name_change?
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    color = setting[:color]
    out = setting[:outline]
    @name = @battler.name
    #---
    bitmap = Bitmap.new(setting[:width], setting[:height])
    bitmap.font.name = setting[:font]
    bitmap.font.size = setting[:size]
    bitmap.font.bold = setting[:bold]
    bitmap.font.italic = setting[:italic]
    if color.is_a?(String)
      bitmap.font.color = eval(color)
    else
      bitmap.font.color = Color.new(color[0], color[1], color[2], color[3])
    end
    if out.is_a?(String)
      bitmap.font.out_color = eval(out)
    else
      bitmap.font.out_color = Color.new(out[0], out[1], out[2], out[3])
    end
    bitmap.draw_text(0, 0, bitmap.width, bitmap.height, @name, setting[:align])
    #---
    self.bitmap.dispose if self.bitmap
    self.bitmap = bitmap
  end
  
  #--------------------------------------------------------------------------
  # name_change?
  #--------------------------------------------------------------------------
  def name_change?
    @name != @battler.name
  end
    
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::HUD::BATTLER_HUD[:name]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
end # SpriteHUD_Name

#==============================================================================
# ■ SpriteHUD_Bar
#==============================================================================

class SpriteHUD_Bar < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset, symbol)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @symbol = symbol
    @rate = real_rate
    @text = Sprite.new(viewport)
    refresh
  end
  
  #--------------------------------------------------------------------------
  # battler
  #--------------------------------------------------------------------------
  def battler=(battler)
    return if @battler == battler
    @battler = battler
    update
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    update_rate if real_opacity > 0
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
    #---
    return if setting[:type] != 0
    @text.update
    @text.x = text_x; @text.y = text_y; @text.z = text_z
    @text.opacity = real_opacity
    @text.visible = @spriteset.visible
  end
  
  #--------------------------------------------------------------------------
  # update_rate
  #--------------------------------------------------------------------------
  def update_rate
    rate = [(@rate - real_rate).abs, setting[:ani_rate]].min
    @rate += @rate > real_rate ? -rate : rate
    refresh if rate > 0
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    case setting[:type]
    when 0; refresh_type0
    when 1; refresh_type1
    when 2; refresh_type2
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh_type0
  #--------------------------------------------------------------------------
  def refresh_type0
    self.bitmap ||= Bitmap.new(setting_type[:length], setting_type[:height])
    self.bitmap.clear
    #---
    rect = self.bitmap.rect
    color1 = setting_type[:color1]
    if color1.is_a?(String)
      color1 = eval(color1)
    else
      color1 = Color.new(color1[0], color1[1], color1[2], color1[3])
    end
    color2 = setting_type[:color2]
    if color2.is_a?(String)
      color2 = eval(color2)
    else
      color2 = Color.new(color2[0], color2[1], color2[2], color2[3])
    end
    back_color = setting_type[:back_color]
    if back_color.is_a?(String)
      back_color = eval(back_color)
    else
      back_color = Color.new(back_color[0], back_color[1], back_color[2], back_color[3])
    end
    outline = setting_type[:outline]
    if outline.is_a?(String)
      outline = eval(outline)
    else
      outline = Color.new(outline[0], outline[1], outline[2], outline[3])
    end
    self.bitmap.fill_rect(rect, outline)
    rect.x += 1; rect.y += 1; rect.width -= 2; rect.height -= 2
    self.bitmap.fill_rect(rect, back_color)
    if setting[:vertical]
      height = rect.height
      rect.height = rect.height * @rate
      rect.y      = height - rect.height
    else
      rect.width = rect.width * @rate
    end
    self.bitmap.gradient_fill_rect(rect, color1, color2)
    #---
    if @text.bitmap.nil?
      type = setting_type
      color = type[:tcolor]
      out = type[:toutline]
      @text.bitmap = Bitmap.new(setting_type[:length], 32)
      @text.bitmap.font.name = type[:font]
      @text.bitmap.font.size = type[:size]
      @text.bitmap.font.bold = type[:bold]
      @text.bitmap.font.italic = type[:italic]
      if color.is_a?(String)
        @text.bitmap.font.color = eval(color)
      else
        @text.bitmap.font.color = Color.new(color[0], color[1], color[2], color[3])
      end
      if out.is_a?(String)
        @text.bitmap.font.out_color = eval(out)
      else
        @text.bitmap.font.out_color = Color.new(out[0], out[1], out[2], out[3])
      end
      @text.bitmap.draw_text(0, 0, @text.bitmap.width, @text.bitmap.height, type[:text], type[:align])
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh_type1
  #--------------------------------------------------------------------------
  def refresh_type1
    self.bitmap = Cache.system(setting_type[:filename]) if self.bitmap.nil?
    #---
    width = self.bitmap.width
    height = self.bitmap.height
    y = 0
    if setting[:vertical]
      height = height * @rate
      y = self.bitmap.height - height
      self.oy = -y
    else
      width = width * @rate
    end
    self.src_rect.set(0, y, width, height)
  end
  
  #--------------------------------------------------------------------------
  # refresh_type2
  #--------------------------------------------------------------------------
  def refresh_type2
    self.bitmap = Cache.system(setting_type[:filename]) if self.bitmap.nil?
    #---
    frames = setting_type[:frames]
    rate   = 1.0 / frames
    width  = self.bitmap.width / frames
    height = self.bitmap.height
    x      = [(@rate / rate).floor, frames - 1].min * width
    self.src_rect.set(x, 0, width, height)
  end
    
  #--------------------------------------------------------------------------
  # real_rate
  #--------------------------------------------------------------------------
  def real_rate
    case @symbol
    when :hp_bar; return @battler.hp_rate
    when :mp_bar; return @battler.mp_rate
    when :tp_bar; return @battler.tp_rate
    end
  end
    
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::HUD::BATTLER_HUD[@symbol]
  end
  
  #--------------------------------------------------------------------------
  # setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # text_x
  #--------------------------------------------------------------------------
  def text_x
    @spriteset.screen_x + setting_type[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # text_y
  #--------------------------------------------------------------------------
  def text_y
    @spriteset.screen_y + setting_type[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # text_z
  #--------------------------------------------------------------------------
  def text_z
    @spriteset.screen_z + setting_type[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @text.dispose
  end
  
end # SpriteHUD_Bar

#==============================================================================
# ■ SpriteHUD_Numbers
#==============================================================================

class SpriteHUD_Numbers < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset, symbol)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @symbol = symbol
    @number = real_number
    @max_number = 0
    refresh
  end
  
  #--------------------------------------------------------------------------
  # battler
  #--------------------------------------------------------------------------
  def battler=(battler)
    return if @battler == battler
    @battler = battler
    update
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    update_rate if real_opacity > 0
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
  end
  
  #--------------------------------------------------------------------------
  # update_rate
  #--------------------------------------------------------------------------
  def update_rate
    case @symbol
    when :hp; rate = @battler.mhp * setting[:ani_rate]
    when :mp; rate = @battler.mmp * setting[:ani_rate]
    when :tp; rate = @battler.max_tp * setting[:ani_rate]
    when :mhp; rate = @battler.mhp * setting[:ani_rate]
    when :mmp; rate = @battler.mmp * setting[:ani_rate]
    when :mtp; rate = @battler.max_tp * setting[:ani_rate]
    end
    case @symbol
    when :hp; max = @battler.mhp
    when :mp; max = @battler.mmp
    when :tp; max = @battler.max_tp
    end
    rate = [(@number.to_i - real_number.to_i).abs, rate.ceil].min
    @number += @number > real_number ? -rate : rate
    @number = @number.to_i
    refresh if rate > 0
    return unless setting[:with_max]
    refresh if max != @max_number
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    case setting[:type]
    when 0; refresh_type0
    when 1; refresh_type1
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh_type0
  #--------------------------------------------------------------------------
  def refresh_type0
    case @symbol
    when :hp; @max_number = @battler.mhp
    when :mp; @max_number = @battler.mmp
    when :tp; @max_number = @battler.max_tp
    end
    #---
    self.bitmap ||= Bitmap.new(setting_type[:width], setting_type[:height])
    self.bitmap.clear
    #---
    type = setting_type
    color = type[:color]
    out = type[:outline]
    if setting[:text]
      str = sprintf(setting[:text], @number, @max_number)
      str = setting[:with_max] ? str : @number
    else
      str = @number
    end
    self.bitmap = Bitmap.new(type[:width], type[:height])
    self.bitmap.font.name = type[:font]
    self.bitmap.font.size = type[:size]
    self.bitmap.font.bold = type[:bold]
    self.bitmap.font.italic = type[:italic]
    if color.is_a?(String)
      bitmap.font.color = eval(color)
    else
      bitmap.font.color = Color.new(color[0], color[1], color[2], color[3])
    end
    if out.is_a?(String)
      bitmap.font.out_color = eval(out)
    else
      bitmap.font.out_color = Color.new(out[0], out[1], out[2], out[3])
    end
    self.bitmap.draw_text(0, 0, self.bitmap.width, self.bitmap.height, str, type[:align])
  end
  
  #--------------------------------------------------------------------------
  # refresh_type1
  #--------------------------------------------------------------------------
  def refresh_type1
    num_bitmap = Cache.system(setting_type[:filename])
    #---
    self.bitmap ||= Bitmap.new(setting_type[:width], num_bitmap.height)
    self.bitmap.clear
    #---
    align    = setting_type[:align]
    spacing  = setting_type[:spacing]
    nwidth  = num_bitmap.width / 10
    nheight = num_bitmap.height
    ncount  = @number.to_s.size
    twidth  = ncount * (nwidth + spacing) - spacing
    case align
    when 0; offset_x = 0
    when 1; offset_x = [(setting_type[:width] - twidth) / 2, 0].max
    when 2; offset_x = [setting_type[:width] - twidth, 0].max
    end
    #---
    (0...ncount).each { |index|
      x = offset_x + index * (nwidth + spacing)
      number = @number.to_s[index].to_i
      rect   = Rect.new(nwidth * number, 0, nwidth, nheight)
      self.bitmap.blt(x, 0, num_bitmap, rect)
    }
  end
    
  #--------------------------------------------------------------------------
  # real_number
  #--------------------------------------------------------------------------
  def real_number
    case @symbol
    when :hp; return @battler.hp
    when :mp; return @battler.mp
    when :tp; return @battler.tp
    when :mhp; return @battler.mhp
    when :mmp; return @battler.mmp
    when :mtp; return @battler.max_tp
    end
  end
    
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    case @symbol
    when :hp; return BattleLuna::HUD::BATTLER_HUD[:hp_num]
    when :mp; return BattleLuna::HUD::BATTLER_HUD[:mp_num]
    when :tp; return BattleLuna::HUD::BATTLER_HUD[:tp_num]
    when :mhp; return BattleLuna::HUD::BATTLER_HUD[:hp_max_num]
    when :mmp; return BattleLuna::HUD::BATTLER_HUD[:mp_max_num]
    when :mtp; return BattleLuna::HUD::BATTLER_HUD[:tp_max_num]
    end
  end
  
  #--------------------------------------------------------------------------
  # setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
end # SpriteHUD_Numbers

#==============================================================================
# ■ SpriteHUD_States
#==============================================================================

class SpriteHUD_States < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @states = []
    @back_sprite = Sprite.new(viewport)
    @index = 0
    refresh
    refresh_back
  end
  
  #--------------------------------------------------------------------------
  # battler
  #--------------------------------------------------------------------------
  def battler=(battler)
    return if @battler == battler
    @battler = battler
    update
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if states_change?
    update_scroll if setting[:type] == 1
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
    #---
    @back_sprite.update
    @back_sprite.x = back_x
    @back_sprite.y = back_y
    @back_sprite.z = back_z
    @back_sprite.opacity = real_opacity
    @back_sprite.visible = @spriteset.visible
  end
  
  #--------------------------------------------------------------------------
  # update_scroll
  #--------------------------------------------------------------------------
  def update_scroll
    @states.clear
    @states = @battler.state_icons + @battler.buff_icons
    #---
    @index  = 0 if @index > @states.size - 1
    #---
    @scroll ||= setting_type[:rate]
    @scroll -= 1
    #---
    return unless @states.size > 0
    #---
    return if @scroll > 0
    @index = (@index + 1) % @states.size
    @scroll = setting_type[:rate]
    refresh
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    case setting[:type]
    when 0; refresh_type0
    when 1; refresh_type1
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh_type0
  #--------------------------------------------------------------------------
  def refresh_type0
    @states.clear
    @states = @battler.state_icons + @battler.buff_icons
    #---
    w = 24 + setting_type[:spacing]
    width = w * setting_type[:max] - setting_type[:spacing]
    bitmap = Bitmap.new(width, 24)
    icon_bitmap = Cache.system("Iconset")
    @states.each_with_index { |icon_index, i|
      x = i * w
      rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
      bitmap.blt(x, 0, icon_bitmap, rect)
    }
    #---
    self.bitmap.dispose if self.bitmap
    self.bitmap = bitmap
  end
  
  #--------------------------------------------------------------------------
  # refresh_type1
  #--------------------------------------------------------------------------
  def refresh_type1
    @states.clear
    @states = @battler.state_icons + @battler.buff_icons
    #---
    bitmap = Bitmap.new(24, 24)
    icon_bitmap = Cache.system("Iconset")
    icon_index = @states[@index]
    if icon_index.nil?
      self.bitmap.dispose if self.bitmap
      self.bitmap = bitmap
      return false
    end
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap.blt(0, 0, icon_bitmap, rect)
    #---
    self.bitmap.dispose if self.bitmap
    self.bitmap = bitmap
  end
  
  #--------------------------------------------------------------------------
  # refresh_back
  #--------------------------------------------------------------------------
  def refresh_back
    return unless setting_back[:enable]
    @back_sprite.bitmap = Cache.system(setting_back[:filename])
  end
  
  #--------------------------------------------------------------------------
  # name_change?
  #--------------------------------------------------------------------------
  def states_change?
    @states != @battler.state_icons + @battler.buff_icons
  end
    
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::HUD::BATTLER_HUD[:states]
  end
  
  #--------------------------------------------------------------------------
  # setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # setting_back
  #--------------------------------------------------------------------------
  def setting_back
    BattleLuna::HUD::BATTLER_HUD[:states][:back]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # back_x
  #--------------------------------------------------------------------------
  def back_x
    @spriteset.screen_x + setting_back[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # back_y
  #--------------------------------------------------------------------------
  def back_y
    @spriteset.screen_y + setting_back[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # back_z
  #--------------------------------------------------------------------------
  def back_z
    @spriteset.screen_z + setting_back[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @back_sprite.dispose
  end
  
end # SpriteHUD_States

#==============================================================================
# ■ Window_PartyCommand
#==============================================================================

class Window_PartyCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias battle_luna_initialize initialize
  def initialize
    battle_luna_initialize
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    setting[:padding]
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    eval(setting[:x].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    setting[:vertical] ? 1 : item_max
  end

  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    8
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: alignment
  #--------------------------------------------------------------------------
  def alignment
    setting[:align]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::WINDOWS::WINDOW_COMMANDS[:party_commands]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_PartyCommand

#==============================================================================
# ■ Window_ActorCommand
#==============================================================================

class Window_ActorCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias battle_luna_initialize initialize
  def initialize
    battle_luna_initialize
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # new method: actor_position
  #--------------------------------------------------------------------------
  def actor_position
    self.x = destination_x
    self.y = destination_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    setting[:padding]
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    eval(setting[:x].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: destination_x
  #--------------------------------------------------------------------------
  def destination_x
    pos_type = setting[:pos_type]
    case pos_type
    when 0; return init_screen_x
    when 1; return @actor.hud_x + eval(setting[:x].to_s)
    when 2; return @actor.screen_x + eval(setting[:x].to_s)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: destination_y
  #--------------------------------------------------------------------------
  def destination_y
    pos_type = setting[:pos_type]
    case pos_type
    when 0; return init_screen_y
    when 1; return @actor.hud_y + eval(setting[:y].to_s)
    when 2; return @actor.screen_y + eval(setting[:y].to_s)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: aindex
  #--------------------------------------------------------------------------
  def aindex
    @actor ? @actor.index : 0
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    [setting[:vertical] ? 1 : item_max, 1].max
  end

  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    8
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: alignment
  #--------------------------------------------------------------------------
  def alignment
    setting[:align]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # alias method: setup
  #--------------------------------------------------------------------------
  alias battle_luna_setup setup
  def setup(actor)
    battle_luna_setup(actor)
    actor_position
  end
  
end # Window_ActorCommand

#==============================================================================
# ■ Window_BattleActor
#==============================================================================

class Window_BattleActor < Window_BattleStatus
  
  #--------------------------------------------------------------------------
  # overwrite method: update
  #--------------------------------------------------------------------------
  def update
    super
    self.x = self.y = 999
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    999
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    999
  end
    
end # Window_BattleActor

#==============================================================================
# ■ Window_BattleHelp
#==============================================================================

class Window_BattleHelp < Window_Help
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(line_number)
    init_position
    update_padding
    create_contents
    refresh_background
    self.hide
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(line_number) + setting[:height_buff]
  end
  
  #--------------------------------------------------------------------------
  # standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    setting[:padding]
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::WINDOWS::WINDOW_GUI[:help_window]
  end
  
  #--------------------------------------------------------------------------
  # line_number
  #--------------------------------------------------------------------------
  def line_number
    setting[:line_number]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_BattleHelp

#==============================================================================
# ■ Window_BattleSkill
#==============================================================================

class Window_BattleSkill < Window_SkillList
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #-------------------------------------------------------------------------- 
  def initialize(help_window, info_viewport)
    super(screen_x, screen_y, window_width, window_height)
    self.visible = false
    @help_window = help_window
    @info_viewport = info_viewport
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
    refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    setting[:padding]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::WINDOWS::WINDOW_GUI[:skill_window]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # alias method: show
  #--------------------------------------------------------------------------
  alias battle_luna_show show
  def show
    init_position
    battle_luna_show
  end
  
end # Window_BattleSkill

#==============================================================================
# ■ Window_BattleItem
#==============================================================================

class Window_BattleItem < Window_ItemList
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #-------------------------------------------------------------------------- 
  def initialize(help_window, info_viewport)
    super(screen_x, screen_y, window_width, window_height)
    self.visible = false
    @help_window = help_window
    @info_viewport = info_viewport
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
    refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    setting[:padding]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::WINDOWS::WINDOW_GUI[:item_window]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # alias method: show
  #--------------------------------------------------------------------------
  alias battle_luna_show show
  def show
    init_position
    battle_luna_show
  end
  
end # Window_BattleItem

#==============================================================================
# ■ Window_BattleLog
#==============================================================================

class Window_BattleLog < Window_Selectable
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias battle_luna_initialize initialize
  def initialize
    battle_luna_initialize
    init_position
    update_padding
    create_contents
    refresh_background
    self.openness = 0
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # standard_padding
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(max_line_number) + setting[:height_buff]
  end
  
  #--------------------------------------------------------------------------
  # standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    setting[:padding]
  end
  
  #--------------------------------------------------------------------------
  # max_line_number
  #--------------------------------------------------------------------------
  def max_line_number
    setting[:line_number]
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    BattleLuna::WINDOWS::WINDOW_GUI[:battlelog_window]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: update
  #--------------------------------------------------------------------------
  def update
    super
    #---
    if setting[:show_no_line]
      self.close if line_number == 0
    end
    self.open if line_number > 0
    #---
    type = setting[:back_type]
    case type
    when 0; update_type0
    when 1; update_type1
    when 2; update_type2
    end    
    #---
    @back_sprite.x = 999 unless type == 3
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # alias method: add_text
  #--------------------------------------------------------------------------
  alias battle_luna_add_text add_text
  def add_text(text)
    return unless setting[:enable]
    battle_luna_add_text(text)
  end
  
  #--------------------------------------------------------------------------
  # alias method: replace_text
  #--------------------------------------------------------------------------
  alias battle_luna_replace_text replace_text
  def replace_text(text)
    return unless setting[:enable]
    battle_luna_replace_text(text)
  end
  
  #--------------------------------------------------------------------------
  # alias method: last_text
  #--------------------------------------------------------------------------
  alias battle_luna_last_text last_text
  def last_text
    battle_luna_last_text || ""
  end
  
end # Window_BattleHelp

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
    
  #--------------------------------------------------------------------------
  # alias method: create_status_window
  #--------------------------------------------------------------------------
  alias battle_luna_create_status_window create_status_window
  def create_status_window
    battle_luna_create_status_window
    @status_window.update
  end

  #--------------------------------------------------------------------------
  # alias method: create_info_viewport
  #--------------------------------------------------------------------------
  alias battle_luna_create_info_viewport create_info_viewport
  def create_info_viewport
    battle_luna_create_info_viewport
    @status_window.viewport = @spriteset.info_viewport
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_party_command_window
  #--------------------------------------------------------------------------
  alias battle_luna_create_party_command_window create_party_command_window
  def create_party_command_window
    battle_luna_create_party_command_window
    @party_command_window.viewport = nil
    @party_command_window.init_position
  end

  #--------------------------------------------------------------------------
  # alias method: create_actor_command_window
  #--------------------------------------------------------------------------
  alias battle_luna_create_actor_command_window create_actor_command_window
  def create_actor_command_window
    battle_luna_create_actor_command_window
    @actor_command_window.viewport = nil
    @actor_command_window.init_position
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_actor_window
  #--------------------------------------------------------------------------
  alias battle_luna_create_actor_window create_actor_window
  def create_actor_window
    battle_luna_create_actor_window
    @spriteset.battle_hud.actor_window = @actor_window
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_help_window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_BattleHelp.new
    @help_window.visible = false
  end
  
  #--------------------------------------------------------------------------
  # alias method: turn_start
  #--------------------------------------------------------------------------
  alias battle_luna_turn_start turn_start
  def turn_start
    @actor_command_window.openness = 0 if BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands][:hide_select]
    battle_luna_turn_start
  end
  
  #--------------------------------------------------------------------------
  # alias method: start_actor_command_selection
  #--------------------------------------------------------------------------
  alias battle_luna_start_actor_command_selection start_actor_command_selection
  def start_actor_command_selection
    @actor_command_window.close if !BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands][:hide_select]
    @actor_command_window.openness = 0 if BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands][:hide_select]
    update_basic while !@actor_command_window.close?
    battle_luna_start_actor_command_selection
    @actor_command_window.show
  end
  
  #--------------------------------------------------------------------------
  # alias method: command_skill
  #--------------------------------------------------------------------------
  alias battle_luna_command_skill command_skill
  def command_skill
    battle_luna_command_skill
    @status_window.show
    @actor_command_window.show if !BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands][:hide_select]
    @actor_command_window.hide if BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands][:hide_select]
  end
  
  #--------------------------------------------------------------------------
  # alias method: command_item
  #--------------------------------------------------------------------------
  alias battle_luna_command_item command_item
  def command_item
    battle_luna_command_item
    @status_window.show
    @actor_command_window.show if !BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands][:hide_select]
    @actor_command_window.hide if BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands][:hide_select]
  end
  
  #--------------------------------------------------------------------------
  # alias method: select_actor_selection
  #--------------------------------------------------------------------------
  alias battle_luna_select_actor_selection select_actor_selection
  def select_actor_selection
    battle_luna_select_actor_selection
    @status_window.show
    @actor_command_window.show if !BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands][:hide_select]
    @actor_command_window.hide if BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands][:hide_select]
    @skill_window.hide if BattleLuna::WINDOWS::WINDOW_GUI[:skill_window][:hide_select]
    @item_window.hide if BattleLuna::WINDOWS::WINDOW_GUI[:item_window][:hide_select]
    case @actor_command_window.current_symbol
    when :skill
      @skill_window.show unless BattleLuna::WINDOWS::WINDOW_GUI[:skill_window][:hide_select]
    when :item
      @item_window.show unless BattleLuna::WINDOWS::WINDOW_GUI[:item_window][:hide_select]
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: select_enemy_selection
  #--------------------------------------------------------------------------
  alias battle_luna_select_enemy_selection select_enemy_selection
  def select_enemy_selection
    battle_luna_select_enemy_selection
    @status_window.show
    @actor_command_window.show if !BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands][:hide_select]
    @actor_command_window.hide if BattleLuna::WINDOWS::WINDOW_COMMANDS[:actor_commands][:hide_select]
    @skill_window.hide if BattleLuna::WINDOWS::WINDOW_GUI[:skill_window][:hide_select]
    @item_window.hide if BattleLuna::WINDOWS::WINDOW_GUI[:item_window][:hide_select]
    case @actor_command_window.current_symbol
    when :skill
      @skill_window.show unless BattleLuna::WINDOWS::WINDOW_GUI[:skill_window][:hide_select]
    when :item
      @item_window.show unless BattleLuna::WINDOWS::WINDOW_GUI[:item_window][:hide_select]
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_actor_cancel
  #--------------------------------------------------------------------------
  alias battle_luna_on_actor_cancel on_actor_cancel
  def on_actor_cancel
    battle_luna_on_actor_cancel
    case @actor_command_window.current_symbol
    when :skill
      @skill_window.show
    when :item
      @item_window.show
    else
      @actor_command_window.show
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_enemy_cancel
  #--------------------------------------------------------------------------
  alias battle_luna_on_enemy_cancel on_enemy_cancel
  def on_enemy_cancel
    battle_luna_on_enemy_cancel
    case @actor_command_window.current_symbol
    when :skill
      @skill_window.show
    when :item
      @item_window.show
    else
      @actor_command_window.show
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_skill_cancel
  #--------------------------------------------------------------------------
  alias battle_luna_on_skill_cancel on_skill_cancel
  def on_skill_cancel
    battle_luna_on_skill_cancel
    @actor_command_window.show
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_item_cancel
  #--------------------------------------------------------------------------
  alias battle_luna_on_item_cancel on_item_cancel
  def on_item_cancel
    battle_luna_on_item_cancel
    @actor_command_window.show
  end
  
end # Scene_Battle