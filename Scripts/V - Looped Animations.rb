#==============================================================================
# ** Victor Engine - Loop Animation
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.01 > First relase
#  v 1.01 - 2012.01.07 > Fixed Bug with Comment Call
#                      > Reordered the Regular Expression to fix a mismatch
#  v 1.02 - 2012.01.15 > Compatibility with Target Arrow
#  v 1.03 - 2012.03.11 > Compatibility with Animation Setting
#  v 1.04 - 2013.02.13 > Compatibility with Basic Module 1.35
#------------------------------------------------------------------------------
#  This script allows to display looping and cycling animations, the
# animation loops indefinitely, and if there's more than one they cycles
# between them. They're used to display status effects or can be called to
# display some visual effect.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.35 or higher
# 
# * Alias methods (Default)
#   class Game_Battler < Game_BattlerBase
#     def initialize
#
#   class Game_Enemy < Game_Battler
#     def initialize
#
#   class Game_CharacterBase
#     def initialize
#
#   class Sprite_Base < Sprite
#     def initialize(viewport = nil)
#     def dispose
#     def update
#
#   class Sprite_Character < Sprite_Base
#     def initialize(viewport, character = nil)
#     def setup_new_effect
#
#   class Sprite_Battler < Sprite_Base
#     def initialize(viewport, battler = nil)
#     def setup_new_effect
#
# * Alias methods (Basic Module)
#   class Game_Interpreter
#     def comment_call
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the scripts 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
#
#  <event loop animation i: x>
#   Display a loop animation on the event.
#     i : event ID
#     x : loop animation ID
#
#  <event loop animation type i: x, y>
#   Set the loop animation type for events, have effect only when used together
#   with <event loop animation i: x>, otherwise have no effect, this tag is
#   opitional
#     i : event ID
#     x : loop animation ID
#     y : loop animation type
#
#  <event loop animation loop i: x, y>
#   Set the loop animation loop numbers for events, have effect only when used
#   together with <event loop animation i: x>, otherwise have no effect,
#   this tag is opitional
#     i : event ID
#     x : loop animation ID
#     y : loop animation loop times
#
#  <actor loop animation i: x>
#   Display a loop animation on the actors, can be used in battles.
#     i : actor index
#     x : loop animation ID
#
#  <actor loop animation type i: x, y>
#   Set the loop animation type for actors, have effect only when used together
#   with <actor loop animation i: x>, otherwise have no effect, this tag
#  is opitional
#     i : actor index
#     x : loop animation ID
#     y : loop animation type
#
#  <actor loop animation loop i: x, y>
#   Set the loop animation loop numbers for actors, have effect only when used
#   together with <actor loop animation i: x>, otherwise have no effect,
#   this tag is opitional
#     i : actor index
#     x : loop animation ID
#     y : loop animation loop times
#
#  <vehicle loop animation i: x>
#   Display a loop animation on the vehicles, can be used in battles.
#   this tag is opitional
#     i : vehicle type name
#     x : loop animation ID
#
#  <vehicle loop animation type i: x, y>
#   Set the loop animation type for vehicles, have effect only when used
#   together with <vehicle loop animation i: x>, otherwise have no effect,
#   this tag is opitional
#     i : vehicle type name
#     x : loop animation ID
#     y : loop animation type
#
#  <vehicle loop animation loop i: x, y>
#   Set the loop animation loop numbers for vehicles, have effect only when 
#   used together with <vehicle loop animation i: x>, otherwise have no
#   effect, this tag is opitional
#     i : vehicle type name
#     x : loop animation ID
#     y : loop animation loop times
#
#------------------------------------------------------------------------------
# Comment boxes note tags:
#   Tags to be used on events Comment boxes. They're different from the
#   comment call, they're called always the even refresh.
#
#  <loop animation: i>
#   Display a loop animation on the event.
#     i : loop animation ID
#
#  <loop animation type: x, y>
#   Set the loop animation type, have effect only when used together with
#   <self loop animation id: x>, otherwise have no effect, this tag is opitional
#     x : loop animation ID
#     y : loop animation type
#
#  <loop animation loop: x, y>
#   Set the loop animation loop numbers, have effect only when used 
#   together with <self loop animation id: x>, otherwise have no effect, 
#   this tag is opitional
#     x : loop animation ID
#     y : loop animation loop times
#
#------------------------------------------------------------------------------
# Enemies note tags:
#   Tags to be used on the Enemies note box in the database
#
#  <loop animation: i>
#   Display a loop animation on the enemy.
#     i : loop animation ID
#
#  <loop animation type: x, y>
#   Set the loop animation type, have effect only when used together with
#   <loop animation id: x>, otherwise have no effect, this tag is opitional
#     x : loop animation ID
#     y : loop animation type
#
#  <loop animation loop: x, y>
#   Set the loop animation loop numbers, have effect only when used together
#   with <loop animation id: x>, otherwise have no effect, this tag is opitional
#     x : loop animation ID
#     y : loop animation loop times
#
#------------------------------------------------------------------------------
# States note tags:
#   Tags to be used on the States note box in the database
#
#  <loop animation: i>
#   Display a loop animation on the target of the state during battles
#     i : loop animation ID
#
#  <loop animation type: x, y>
#   Set the loop animation type, have effect only when used together with
#   <loop animation: x>, otherwise have no effect, this tag is opitional
#     x : loop animation ID
#     y : loop animation type
#
#  <loop animation loop: x, y>
#   Set the loop animation loop numbers, have effect only when used together 
#   with <loop animation: x>, otherwise have no effect, this tag is opitional
#     x : loop animation ID
#     y : loop animation loop times
#
#  <map loop animation: i>
#   Display a loop animation on the target of the state on the map
#     i : loop animation ID
#
#  <map loop animation type: x, y>
#   Set the loop animation type, have effect only when used together with
#   <map loop animation: x>, otherwise have no effect, this tag is opitional
#     x : loop animation ID
#     y : loop animation type
#
#  <map loop animation loop: x, y>
#   Set the loop animation loop numbers, have effect only when used together
#   with <map loop animation: x>, otherwise have no effect, this tag is
#   opitional
#     x : loop animation ID
#     y : loop animation loop times
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  The animation type is a identifier to decide the animation cycle. Loop
#  animations only cycle thought animations of the same type. If two or more
#  animations from different types are displayed on the same target.
#  all animations from the different types will be displayed at same time.
#  Avoid overdoing with this because it may cause FPS drop.
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * required
  #   This method checks for the existance of the basic module and other
  #   VE scripts required for this script to work, don't edit this
  #--------------------------------------------------------------------------
  def self.required(name, req, version, type = nil)
    if !$imported[:ve_basic_module]
      msg = "The script '%s' requires the script\n"
      msg += "'VE - Basic Module' v%s or higher above it to work properly\n"
      msg += "Go to http://victorenginescripts.wordpress.com/ to download this script."
      msgbox(sprintf(msg, self.script_name(name), version))
      exit
    else
      self.required_script(name, req, version, type)
    end
  end
  #--------------------------------------------------------------------------
  # * script_name
  #   Get the script name base on the imported value, don't edit this
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_loop_animation] = 1.04
Victor_Engine.required(:ve_loop_animation, :ve_basic_module, 1.35, :above)

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  This class deals with battlers. It's used as a superclass of the Game_Actor
# and Game_Enemy classes.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :add_animation
  attr_reader   :remove_animation
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_loop_animation :initialize
  def initialize
    initialize_ve_loop_animation
    clear_add_loop_animation
  end
  #--------------------------------------------------------------------------
  # * New method: add_loop_animation
  #--------------------------------------------------------------------------
  def add_loop_animation(anim, type, loop = 1)
    @add_animation = {anim: anim, type: type, loop: loop}
  end
  #--------------------------------------------------------------------------
  # * New method: remove_loop_animation
  #--------------------------------------------------------------------------
  def remove_loop_animation(anim, type)
    @remove_animation = {anim: anim, type: type}
  end
  #--------------------------------------------------------------------------
  # * New method: clear_add_loop_animation
  #--------------------------------------------------------------------------
  def clear_add_loop_animation
    @add_animation = nil
  end
  #--------------------------------------------------------------------------
  # * New method: clear_remove_loop_animation
  #--------------------------------------------------------------------------
  def clear_remove_loop_animation
    @remove_animation = nil
  end
end


#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemy characters. It's used within the Game_Troop class
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ge_ve_loop_animation :initialize
  def initialize(index, enemy_id)
    initialize_ge_ve_loop_animation(index, enemy_id)
    refresh_loop_animations
  end
  #--------------------------------------------------------------------------
  # * New method: refresh_loop_animations
  #--------------------------------------------------------------------------
  def refresh_loop_animations
    note.scan(/<LOOP ANIMATION: (\d+)>/i) do
      id   = $1
      type = note =~ /<LOOP ANIMATION TYPE: #{id},\s*(\d+)>/i ? $1 : 0
      loop = note =~ /<LOOP ANIMATION LOOP: #{id},\s*(\d+)>/i ? $1 : 1
      add_loop_animation(id.to_i, type.to_i, loop.to_i)
    end
  end
end

#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This class deals with characters. Common to all characters, stores basic
# data, such as coordinates and graphics. It's used as a superclass of the
# Game_Character class.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :add_animation
  attr_reader   :remove_animation
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_loop_animation :initialize
  def initialize
    initialize_ve_loop_animation
    clear_add_loop_animation
  end
  #--------------------------------------------------------------------------
  # * New method: add_loop_animation
  #--------------------------------------------------------------------------
  def add_loop_animation(anim, type, loop = 1)
    @add_animation = {anim: anim, type: type, loop: loop}
  end
  #--------------------------------------------------------------------------
  # * New method: remove_loop_animation
  #--------------------------------------------------------------------------
  def remove_loop_animation(anim, type)
    @remove_animation = {anim: anim, type: type}
  end
  #--------------------------------------------------------------------------
  # * New method: clear_add_loop_animation
  #--------------------------------------------------------------------------
  def clear_add_loop_animation
    @add_animation = nil
  end
  #--------------------------------------------------------------------------
  # * New method: clear_remove_loop_animation
  #--------------------------------------------------------------------------
  def clear_remove_loop_animation
    @remove_animation = nil
  end
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class deals with events. It handles functions including event page 
# switching via condition determinants, and running parallel process events.
# It's used within the Game_Map class.
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: clear_starting_flag
  #--------------------------------------------------------------------------
  alias :clear_starting_flag_ve_loop_animation :clear_starting_flag
  def clear_starting_flag
    clear_starting_flag_ve_loop_animation
    refresh_loop_animations if @page
  end
  #--------------------------------------------------------------------------
  # * New method: refresh_loop_animations
  #--------------------------------------------------------------------------
  def refresh_loop_animations
    note.scan(/<LOOP ANIMATION ID: (\d+)>/i) do
      id   = $1
      type = note =~ /<LOOP ANIMATION TYPE: #{id},\s*(\d+)>/i ? $1 : 0
      loop = note =~ /<LOOP ANIMATION LOOP: #{id},\s*(\d+)>/i ? $1 : 1
      add_loop_animation(id.to_i, type.to_i, loop.to_i)
    end
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_loop_animation :comment_call
  def comment_call
    call_event_loop_anim
    call_actor_loop_anim
    call_vehicle_loop_anim
    call_enemy_loop_anim
    comment_call_ve_loop_animation
  end
  #--------------------------------------------------------------------------
  # * New method: call_event_loop_anim
  #--------------------------------------------------------------------------
  def call_event_loop_anim
    note.scan(/<EVENT LOOP ANIMATION (\d+): (\d+)>/i) do |i, id|
      event = $game_map.events[i.to_i]
      regexp = "EVENT LOOP ANIMATION"
      type   = note =~ /<#{regexp} TYPE #{i}: #{id},\s*(\d+)>/i ? $1 : 1
      loop   = note =~ /<#{regexp} LOOP #{i}: #{id},\s*(\d+)>/i ? $1 : 1
      event.add_loop_animation(id.to_i, type.to_i, loop.to_i)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_actor_loop_anim
  #--------------------------------------------------------------------------
  def call_actor_loop_anim
    note.scan(/<ACTOR LOOP ANIMATION (\d+): (\d+)>/i) do |i, id|
      if $game_party.in_battle
        actor = $game_party.battle_members[i.to_i]
      else
        actor = $game_map.actors[i.to_i]
      end
      regexp = "ACTOR LOOP ANIMATION"
      type   = note =~ /<#{regexp} TYPE #{i}: #{id},\s*(\d+)>/i ? $1 : 1
      loop   = note =~ /<#{regexp} LOOP #{i}: #{id},\s*(\d+)>/i ? $1 : 1
      actor.add_loop_animation(id.to_i, type.to_i, loop.to_i)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_vehicle_loop_anim
  #--------------------------------------------------------------------------
  def call_vehicle_loop_anim
    note.scan(/<VEHICLE LOOP ANIMATION (\w+): (\d+)>/i) do |i, id|
      vehicle = $game_map.vehicle(eval(":#{i}"))
      regexp = "VEHICLE LOOP ANIMATION"
      type   = note =~ /<#{regexp} TYPE #{i}: #{id},\s*(\d+)>/i ? $1 : 1
      loop   = note =~ /<#{regexp} LOOP #{i}: #{id},\s*(\d+)>/i ? $1 : 1
      vehicle.add_loop_animation(id.to_i, type.to_i, loop.to_i)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: call_enemy_loop_anim
  #--------------------------------------------------------------------------
  def call_enemy_loop_anim
    return if !$game_party.in_battle
    note.scan(/<ENEMY LOOP ANIMATION (\d+): (\d+)>/i) do |i, id|
      enemy = $game_troop.members[i.to_i]
      regexp = "ENEMY LOOP ANIMATION"
      type   = note =~ /<#{regexp} TYPE #{i}: #{id},\s*(\d+)>/i ? $1 : 1
      loop   = note =~ /<#{regexp} LOOP #{i}: #{id},\s*(\d+)>/i ? $1 : 1
      enemy.add_loop_animation(id.to_i, type.to_i, loop.to_i)
    end
  end  
end

#==============================================================================
# ** Sprite_Base
#------------------------------------------------------------------------------
#  A sprite class with animation display processing added.
#==============================================================================

class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :loop_anim
  #--------------------------------------------------------------------------
  # * Class Variables
  #--------------------------------------------------------------------------
  @@loop_ani_checker = []
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_loop_animation :initialize
  def initialize(viewport = nil)
    initialize_ve_loop_animation(viewport)
    @loop_animation = {}
    @loop_list = {}
  end
  #--------------------------------------------------------------------------
  # * Alias method: dispose
  #--------------------------------------------------------------------------
  alias :dispose_ve_loop_animation :dispose
  def dispose
    dispose_ve_loop_animation
    end_all_loop_anim
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_loop_animation :update
  def update
    dispose_removed_loop_anim
    update_ve_loop_animation
    setup_loop_anim
    update_all_loop_anim
    end_all_loop_anim if any_loop_anim? && !sprite_visible
  end
  #--------------------------------------------------------------------------
  # * New method: user
  #--------------------------------------------------------------------------
  def user
    @battler ? @battler : @character
  end
  #--------------------------------------------------------------------------
  # * New method: setup_loop_anim
  #--------------------------------------------------------------------------
  def setup_loop_anim
    @loop_list.keys.each do |type|
      if !loop_anim?(type) && @loop_list[type].size > 0
        create_loop_anim(type)
      elsif @loop_list[type].empty?
        @loop_list.delete(type)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: create_loop_anim
  #--------------------------------------------------------------------------
  def create_loop_anim(type)
    return if !@loop_list[type]
    item = @loop_list[type].next_item
    anim = $data_animations[item.first]
    start_loop_anim(anim, type)
    @loop_animation[type].loop = item.last - 1
  end
  #--------------------------------------------------------------------------
  # * New method: any_loop_anim?
  #--------------------------------------------------------------------------
  def any_loop_anim?
    @loop_animation && @loop_animation.values.size > 0
  end
  #--------------------------------------------------------------------------
  # * New method: loop_anim?
  #--------------------------------------------------------------------------
  def loop_anim?(type)
    @loop_animation[type]
  end
  #--------------------------------------------------------------------------
  # * New method: start_loop_anim
  #--------------------------------------------------------------------------
  def start_loop_anim(animation, type, mirror = false)
    return if @loop_animation[type] && animation == @loop_animation[type].data
    dispose_loop_anim(type) if @loop_animation[type]
    @loop_animation[type] = Game_Animation.new(animation, mirror)
    if @loop_animation[type]
      load_loop_anim_bitmap(type)
      make_loop_anim_sprites(type)
      set_loop_anim_origin(type)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: load_loop_anim_bitmap
  #--------------------------------------------------------------------------
  def load_loop_anim_bitmap(type)
    animation  = @loop_animation[type]
    anim1_name = animation.animation1_name
    anim1_hue  = animation.animation1_hue
    anim2_name = animation.animation2_name
    anim2_hue  = animation.animation2_hue
    animation.bitmap1 = Cache.animation(anim1_name, anim1_hue)
    animation.bitmap2 = Cache.animation(anim2_name, anim2_hue)
    if @@_reference_count.include?(animation.bitmap1)
      @@_reference_count[animation.bitmap1] += 1
    else
      @@_reference_count[animation.bitmap1] = 1
    end
    if @@_reference_count.include?(animation.bitmap2)
      @@_reference_count[animation.bitmap2] += 1
    else
      @@_reference_count[animation.bitmap2] = 1
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # * New method: make_loop_anim_sprites
  #--------------------------------------------------------------------------
  def make_loop_anim_sprites(type)
    animation = @loop_animation[type]
    animation.duplicated = @@loop_ani_checker.include?(animation.data)
    if @use_sprite && !(animation.duplicated  && animation.position == 3)
      16.times do
        sprite = ::Sprite.new(viewport)
        sprite.visible = false
        animation.sprites.push(sprite)
      end
    end
    @@loop_ani_checker.push(animation.data) if !animation.duplicated
  end
  #--------------------------------------------------------------------------
  # * New method: set_loop_anim_origin
  #--------------------------------------------------------------------------
  def set_loop_anim_origin(type)
    animation = @loop_animation[type]
    if animation.position == 3
      update_animation_screen(animation)
    else
      update_animation_origin(animation)
    end
    animation.map_x = charset? ? $game_map.display_x : 0
    animation.map_y = charset? ? $game_map.display_y : 0
  end
  #--------------------------------------------------------------------------
  # * New method: update_animation_screen
  #--------------------------------------------------------------------------
  def update_animation_screen(animation)
    if viewport == nil
      animation.ox = Graphics.width  / 2
      animation.oy = Graphics.height / 2
    else
      animation.ox = viewport.rect.width  / 2
      animation.oy = viewport.rect.height / 2
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_animation_origin
  #--------------------------------------------------------------------------
  def update_animation_origin(animation)
    animation.ox  = x - ox + width  / 2
    animation.oy  = y - oy + height / 2
    animation.oy -= height / 2 if animation.position == 0
    animation.oy += height / 2 if animation.position == 2
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_loop_anim
  #--------------------------------------------------------------------------
  def dispose_loop_anim(type)
    animation = @loop_animation[type]
    if animation.bitmap1
      @@_reference_count[animation.bitmap1] -= 1
      animation.bitmap1.dispose if @@_reference_count[animation.bitmap1] == 0
    end
    if animation.bitmap2
      @@_reference_count[animation.bitmap2] -= 1
      animation.bitmap2.dispose if @@_reference_count[animation.bitmap2] == 0
    end
    animation.sprites.each {|sprite| sprite.dispose } if animation.sprites
    @loop_animation.delete(type)
  end
  #--------------------------------------------------------------------------
  # * New method: update_all_loop_anim
  #--------------------------------------------------------------------------
  def update_all_loop_anim
    @loop_animation.keys.each {|type| update_loop_anim(type) }
  end
  #--------------------------------------------------------------------------
  # * New method: update_loop_anim
  #--------------------------------------------------------------------------
  def update_loop_anim(type)
    animation = @loop_animation[type]
    animation.duration -= 1
    update_animation_origin(animation)
    if animation.duration > 0
      update_loop_frames(animation)
    elsif animation.duration <= 0 && animation.loop > 0
      animation.loop -= 1
      animation.duration = animation.frame_max * animation.rate + 1
    elsif @loop_list.empty?
      end_all_loop_anim
    else
      create_loop_anim(type)
      animation          = @loop_animation[type]
      animation.duration = animation.frame_max * animation.rate
      update_loop_frames(animation)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_loop_frames
  #--------------------------------------------------------------------------
  def update_loop_frames(animation)
    frame = (animation.duration + animation.rate - 1) / animation.rate
    index = animation.frame_max - frame
    animation_set_sprites(animation, animation.frames[index])
    @ani_duplicated = animation.duplicated
    @ani_rate       = animation.rate
    if animation.duration % animation.rate == 1
      @@loop_ani_checker.delete(animation.data)
      animation.timings.each do |timing|
        animation_process_timing(timing) if timing.frame == index
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_removed_loop_anim
  #--------------------------------------------------------------------------  
  def dispose_removed_loop_anim
    @loop_animation.keys.each do |type| 
      id = @loop_animation[type].id
      if @loop_list[type] && !@loop_list[type].include?(id)
        @loop_list[type].delete(id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: end_all_loop_anim
  #--------------------------------------------------------------------------
  def end_all_loop_anim
    @loop_animation.keys.each {|type| dispose_loop_anim(type) }
    @loop_list = {}
  end
  #--------------------------------------------------------------------------
  # * New method: end_all_loop_anim
  #--------------------------------------------------------------------------
  def end_loop_anim(type)
    return unless @loop_animation.keys.include?(type)
    dispose_loop_anim(type)
    @loop_list.delete(type)
  end
  #--------------------------------------------------------------------------
  # * New method: loop_anim_set_sprites
  #--------------------------------------------------------------------------
  def loop_anim_set_sprites(animation, frame)
    cell_data = frame.cell_data
    animation.sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      if animation.duration % animation.rate == 0
        setup_loop_pattern(animation, pattern, sprite)
      end
      setup_loop_position(animation, cell_data, sprite, i)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: setup_loop_pattern
  #--------------------------------------------------------------------------
  def setup_loop_pattern(animation, pattern, sprite)
    sprite.bitmap  = pattern < 100 ? animation.bitmap1 : animation.bitmap2
    sprite.visible = true
    sprite.src_rect.set(pattern % 5 * 192, pattern % 100 / 5 * 192, 192, 192)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_loop_position
  #--------------------------------------------------------------------------
  def setup_loop_position(animation, cell_data, sprite, i)
    if $imported[:ve_animation_setting]
      setup_sprite_position(animation, cell_data, sprite, i)
    else
      if animation.mirror 
        sprite.x = animation.ox - cell_data[i, 1] * animation.zoom
        sprite.y = animation.oy + cell_data[i, 2] * animation.zoom
        sprite.angle  = 360 - cell_data[i, 4]
        sprite.mirror = cell_data[i, 5] == 0
      else
        sprite.x = animation.ox + cell_data[i, 1] * animation.zoom
        sprite.y = animation.oy + cell_data[i, 2] * animation.zoom
        sprite.angle  = cell_data[i, 4]
        sprite.mirror = cell_data[i, 5] == 1
      end
      sprite.z  = self.z + 300 + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x     = cell_data[i, 3] / 100.0
      sprite.zoom_y     = cell_data[i, 3] / 100.0
      sprite.opacity    = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  #--------------------------------------------------------------------------
  # * New method: add_loop_animation
  #--------------------------------------------------------------------------
  def add_loop_animation(animation)
    if animation
      type = animation[:type]
      anim = animation[:anim]
      loop = animation[:loop]
      @loop_list[type] ||= []
      @loop_list[type].push([anim, loop]) 
      @loop_list[type].uniq!
    end
  end
  #--------------------------------------------------------------------------
  # * New method: remove_loop_animation
  #--------------------------------------------------------------------------
  def remove_loop_animation(animation)
    if animation
      type = animation[:type]
      data = animation[:anim]
      if @loop_list[type]
        @loop_list[type].delete_if {|anim| anim.first == data }
      end
      @loop_list.delete(type) if @loop_list[type] && @loop_list[type].empty?
    end
  end
  #--------------------------------------------------------------------------
  # * New method: remove_state_animations
  #--------------------------------------------------------------------------
  def remove_state_animations(new_states, old_states, map)
    regex = "#{map}\s*LOOP ANIMATION"
    old_states.each do |state|
      next if new_states.include?(state)
      if state.note =~ /<#{regex}: (\d+)>/i
        id   = $1.to_i
        type = state.note =~ /<#{regex} TYPE: #{id},\s*(\d+)>/i ? $1.to_i : ""
        anim = {anim: id, type: eval(":state#{type}")}
        remove_loop_animation(anim)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: add_state_animation
  #--------------------------------------------------------------------------
  def add_state_animation(new_states, old_states, map)
    regex = "#{map}\s*LOOP ANIMATION"
    new_states.each do |state|
      next if old_states.include?(state)
      if state.note =~ /<#{regex}: (\d+)>/i
        id   = $1.to_i
        type = state.note =~ /<#{regex} TYPE: #{id},\s*(\d+)>/i ? $1.to_i : ""
        loop = state.note =~ /<#{regex} LOOP: #{id},\s*(\d+)>/i ? $1.to_i : 1
        anim = {anim: id, type: eval(":state#{type}"), loop: loop}
        add_loop_animation(anim)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: sprite_visible
  #--------------------------------------------------------------------------
  def sprite_visible
    self.visible && self.opacity > 0
  end
end

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes a instance of the
# Game_Character class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_sc_ve_loop_animation :initialize
  def initialize(viewport, character = nil)
    @actor_states = []
    initialize_sc_ve_loop_animation(viewport, character)
  end
  #--------------------------------------------------------------------------
  # * Alias method: setup_new_effect
  #--------------------------------------------------------------------------
  alias :setup_new_effect_ve_loop_animation :setup_new_effect
  def setup_new_effect
    setup_new_effect_ve_loop_animation
    setup_new_loop_animation
    setup_remove_loop_animation
    setup_states_loop_animation
  end
  #--------------------------------------------------------------------------
  # * New method: setup_new_loop_animation
  #--------------------------------------------------------------------------
  def setup_new_loop_animation
    add_loop_animation(@character.add_animation)
    @character.clear_add_loop_animation
  end
  #--------------------------------------------------------------------------
  # * New method: setup_remove_loop_animation
  #--------------------------------------------------------------------------
  def setup_remove_loop_animation
    remove_loop_animation(@character.remove_animation)
    @character.clear_remove_loop_animation
  end
  #--------------------------------------------------------------------------
  # * New method: setup_states_loop_animation
  #--------------------------------------------------------------------------
  def setup_states_loop_animation
    return unless actor
    if @actor_states != actor.states
      remove_state_animations(actor.states, @actor_states, "MAP")
      add_state_animation(actor.states, @actor_states, "MAP")
      @actor_states = actor.states.dup
    end
  end
  #--------------------------------------------------------------------------
  # * New method: sprite_visible
  #--------------------------------------------------------------------------
  def sprite_visible
    self.visible && (self.opacity > 0 || @effect_type == :blink)
  end
end

#==============================================================================
# ** Sprite_Battler
#------------------------------------------------------------------------------
#  This sprite is used to display battlers. It observes a instance of the
# Game_Battler class and automatically changes sprite conditions.
#==============================================================================

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_sb_ve_loop_animation  :initialize
  def initialize(viewport, battler = nil)
    @battler_states = []
    initialize_sb_ve_loop_animation(viewport, battler)
  end
  #--------------------------------------------------------------------------
  # * Alias method: setup_new_effect
  #--------------------------------------------------------------------------
  alias :setup_new_effect_ve_loop_animation :setup_new_effect
  def setup_new_effect
    setup_new_effect_ve_loop_animation
    setup_new_loop_animation
    setup_remove_loop_animation
    setup_states_loop_animation
  end
  #--------------------------------------------------------------------------
  # * New method: setup_new_loop_animation
  #--------------------------------------------------------------------------
  def setup_new_loop_animation
    add_loop_animation(@battler.add_animation)
    @battler.clear_add_loop_animation
  end
  #--------------------------------------------------------------------------
  # * New method: setup_remove_loop_animation
  #--------------------------------------------------------------------------
  def setup_remove_loop_animation
    remove_loop_animation(@battler.remove_animation)
    @battler.clear_remove_loop_animation
  end
  #--------------------------------------------------------------------------
  # * New method: setup_states_loop_animation
  #--------------------------------------------------------------------------
  def setup_states_loop_animation
    if @battler_states != @battler.states
      remove_state_animations(@battler.states, @battler_states, "")
      add_state_animation(@battler.states, @battler_states, "")
      @battler_states = @battler.states.dup
    end
  end
  #--------------------------------------------------------------------------
  # * New method: sprite_visible
  #--------------------------------------------------------------------------
  def sprite_visible
    @battler_visible && (self.opacity > 0 || @effect_type == :blink)
  end
end