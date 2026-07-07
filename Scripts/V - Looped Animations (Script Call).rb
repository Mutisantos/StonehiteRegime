#==============================================================================
# ** Looped Animations (Script Call Version)
#------------------------------------------------------------------------------
# Author : Adapted from Victor Engine - Loop Animation
# 
# Version: 1.00
#
# This script provides looped animation functionality through simple script calls
# without overwriting Animation, Sprite_Base, or Sprite_Battler classes.
# Compatible with Tanketai Sideview Battle System.
#------------------------------------------------------------------------------
# Instructions:
# Place this script above Main in the script editor.
# No dependencies on Victor Engine Basic Module required.
#
#------------------------------------------------------------------------------
# Script Calls:
#
#  start_event_loop_anim(event_id, animation_id, type = 0, loop = 999)
#   Start a looped animation on a map event
#     event_id: Event ID (0 for player, -1 for this event)
#     animation_id: Database animation ID
#     type: Animation type ID (animations of different types cycle independently)
#     loop: Number of times to loop (999 = infinite, or use any large number)
#
#  stop_event_loop_anim(event_id, animation_id = nil, type = 0)
#   Stop a looped animation on a map event
#     event_id: Event ID (0 for player, -1 for this event)
#     animation_id: Database animation ID (nil to stop all of type)
#     type: Animation type ID
#
#  clear_event_loop_anims(event_id)
#   Clear all looped animations on a map event
#     event_id: Event ID (0 for player, -1 for this event)
#
#  start_actor_loop_anim(actor_index, animation_id, type = 0, loop = 999)
#   Start a looped animation on a battle actor
#     actor_index: Actor index in battle party
#     animation_id: Database animation ID
#     type: Animation type ID
#     loop: Number of times to loop (999 = infinite, or use any large number)
#
#  stop_actor_loop_anim(actor_index, animation_id = nil, type = 0)
#   Stop a looped animation on a battle actor
#     actor_index: Actor index in battle party
#     animation_id: Database animation ID (nil to stop all of type)
#     type: Animation type ID
#
#  clear_actor_loop_anims(actor_index)
#   Clear all looped animations on a battle actor
#     actor_index: Actor index in battle party
#
#  start_enemy_loop_anim(enemy_index, animation_id, type = 0, loop = 999)
#   Start a looped animation on a battle enemy
#     enemy_index: Enemy index in troop
#     animation_id: Database animation ID
#     type: Animation type ID
#     loop: Number of times to loop (999 = infinite, or use any large number)
#
#  stop_enemy_loop_anim(enemy_index, animation_id = nil, type = 0)
#   Stop a looped animation on a battle enemy
#     enemy_index: Enemy index in troop
#     animation_id: Database animation ID (nil to stop all of type)
#     type: Animation type ID
#
#  clear_enemy_loop_anims(enemy_index)
#   Clear all looped animations on a battle enemy
#     enemy_index: Enemy index in troop
#
#------------------------------------------------------------------------------
# Additional Notes:
#
# - The animation type is used to group animations. Animations of the same
#   type will cycle through each other. Animations of different types will
#   play simultaneously.
# - Type 0 is the default. Use different type IDs to have multiple independent
#   looped animations on the same target.
# - Loop count of 999 means the animation loops infinitely (or use any large number).
# - This system uses a separate sprite manager and does not interfere with
#   the Tanketai battle system's animation handling.
#
#==============================================================================

$imported ||= {}
$imported[:looped_animations_script_call] = 1.00

#==============================================================================
# ** LoopAnimationManager
#------------------------------------------------------------------------------
#  Manages looped animations without overwriting core classes
#==============================================================================

module LoopAnimationManager
  #--------------------------------------------------------------------------
  # * Module Variables
  #--------------------------------------------------------------------------
  @active_animations = {}
  @sprite_managers = {}
  
  #--------------------------------------------------------------------------
  # * Start Event Loop Animation
  #--------------------------------------------------------------------------
  def self.start_event_loop_anim(event_id, animation_id, type = 0, loop = 999)
    return unless $game_map
    event = get_event(event_id)
    return unless event
    
    key = [:event, event.id]
    add_animation(key, animation_id, type, loop)
    ensure_sprite_manager(key, event)
  end
  
  #--------------------------------------------------------------------------
  # * Stop Event Loop Animation
  #--------------------------------------------------------------------------
  def self.stop_event_loop_anim(event_id, animation_id = nil, type = 0)
    return unless $game_map
    event = get_event(event_id)
    return unless event
    
    key = [:event, event.id]
    remove_animation(key, animation_id, type)
  end
  
  #--------------------------------------------------------------------------
  # * Clear Event Loop Animations
  #--------------------------------------------------------------------------
  def self.clear_event_loop_anims(event_id)
    return unless $game_map
    event = get_event(event_id)
    return unless event
    
    key = [:event, event.id]
    clear_animations(key)
  end
  
  #--------------------------------------------------------------------------
  # * Start Actor Loop Animation
  #--------------------------------------------------------------------------
  def self.start_actor_loop_anim(actor_index, animation_id, type = 0, loop = 999)
    return unless $game_party.in_battle
    actor = $game_party.battle_members[actor_index]
    return unless actor
    
    key = [:actor, actor_index]
    add_animation(key, animation_id, type, loop)
    ensure_sprite_manager(key, actor)
  end
  
  #--------------------------------------------------------------------------
  # * Stop Actor Loop Animation
  #--------------------------------------------------------------------------
  def self.stop_actor_loop_anim(actor_index, animation_id = nil, type = 0)
    return unless $game_party.in_battle
    key = [:actor, actor_index]
    remove_animation(key, animation_id, type)
  end
  
  #--------------------------------------------------------------------------
  # * Clear Actor Loop Animations
  #--------------------------------------------------------------------------
  def self.clear_actor_loop_anims(actor_index)
    return unless $game_party.in_battle
    key = [:actor, actor_index]
    clear_animations(key)
  end
  
  #--------------------------------------------------------------------------
  # * Start Enemy Loop Animation
  #--------------------------------------------------------------------------
  def self.start_enemy_loop_anim(enemy_index, animation_id, type = 0, loop = 999)
    return unless $game_party.in_battle
    enemy = $game_troop.members[enemy_index]
    return unless enemy
    
    key = [:enemy, enemy_index]
    add_animation(key, animation_id, type, loop)
    ensure_sprite_manager(key, enemy)
  end
  
  #--------------------------------------------------------------------------
  # * Stop Enemy Loop Animation
  #--------------------------------------------------------------------------
  def self.stop_enemy_loop_anim(enemy_index, animation_id = nil, type = 0)
    return unless $game_party.in_battle
    key = [:enemy, enemy_index]
    remove_animation(key, animation_id, type)
  end
  
  #--------------------------------------------------------------------------
  # * Clear Enemy Loop Animations
  #--------------------------------------------------------------------------
  def self.clear_enemy_loop_anims(enemy_index)
    return unless $game_party.in_battle
    key = [:enemy, enemy_index]
    clear_animations(key)
  end
  
  #--------------------------------------------------------------------------
  # * Get Event
  #--------------------------------------------------------------------------
  def self.get_event(event_id)
    if event_id == -1
      $game_map.events[$game_map.interpreter.event_id]
    elsif event_id == 0
      $game_player
    else
      $game_map.events[event_id]
    end
  end
  
  #--------------------------------------------------------------------------
  # * Add Animation
  #--------------------------------------------------------------------------
  def self.add_animation(key, animation_id, type, loop)
    @active_animations[key] ||= {}
    @active_animations[key][type] ||= []
    
    # Check if animation already exists
    exists = @active_animations[key][type].any? { |a| a[:anim] == animation_id }
    return if exists
    
    @active_animations[key][type] << { anim: animation_id, loop: loop }
  end
  
  #--------------------------------------------------------------------------
  # * Remove Animation
  #--------------------------------------------------------------------------
  def self.remove_animation(key, animation_id, type)
    return unless @active_animations[key]
    return unless @active_animations[key][type]
    
    if animation_id
      @active_animations[key][type].delete_if { |a| a[:anim] == animation_id }
    else
      @active_animations[key][type].clear
    end
    
    @active_animations[key].delete(type) if @active_animations[key][type].empty?
    @active_animations.delete(key) if @active_animations[key].empty?
  end
  
  #--------------------------------------------------------------------------
  # * Clear Animations
  #--------------------------------------------------------------------------
  def self.clear_animations(key)
    @active_animations.delete(key)
    dispose_sprite_manager(key)
  end
  
  #--------------------------------------------------------------------------
  # * Ensure Sprite Manager
  #--------------------------------------------------------------------------
  def self.ensure_sprite_manager(key, target)
    return if @sprite_managers[key]
    
    viewport = nil
    if SceneManager.scene_is?(Scene_Map)
      spriteset = SceneManager.scene.spriteset
      viewport = spriteset.instance_variable_get(:@viewport1) if spriteset
    elsif SceneManager.scene_is?(Scene_Battle)
      spriteset = SceneManager.scene.spriteset
      viewport = spriteset.instance_variable_get(:@viewport1) if spriteset
    end
    
    return unless viewport
    @sprite_managers[key] = LoopAnimationSpriteManager.new(viewport, target, key)
  end
  
  #--------------------------------------------------------------------------
  # * Dispose Sprite Manager
  #--------------------------------------------------------------------------
  def self.dispose_sprite_manager(key)
    manager = @sprite_managers[key]
    return unless manager
    
    manager.dispose
    @sprite_managers.delete(key)
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def self.update
    @sprite_managers.each do |key, manager|
      # Only update if the scene matches the animation type
      should_update = false
      if key[0] == :event && SceneManager.scene_is?(Scene_Map)
        should_update = true
      elsif (key[0] == :actor || key[0] == :enemy) && SceneManager.scene_is?(Scene_Battle)
        should_update = true
      end
      
      # Skip update if not in correct scene (e.g., menu is open)
      next unless should_update
      
      # Check if viewport is still valid
      if manager.viewport_valid?
        manager.update(@active_animations[key])
      else
        # Viewport was disposed, recreate the sprite manager
        manager.dispose
        @sprite_managers.delete(key)
        
        # Get fresh target reference
        fresh_target = get_fresh_target(key)
        if fresh_target
          ensure_sprite_manager(key, fresh_target)
        end
      end
      
      # Clean up if no animations
      if !@active_animations[key] || @active_animations[key].empty?
        manager.dispose
        @sprite_managers.delete(key)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Dispose All
  #--------------------------------------------------------------------------
  def self.dispose_all
    @sprite_managers.each { |key, manager| manager.dispose }
    @sprite_managers.clear
    @active_animations.clear
  end
  
  #--------------------------------------------------------------------------
  # * Dispose Map Animations
  #--------------------------------------------------------------------------
  def self.dispose_map_animations
    @active_animations.keys.each do |key|
      if key[0] == :event
        manager = @sprite_managers[key]
        manager.dispose if manager
        @sprite_managers.delete(key)
        @active_animations.delete(key)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Dispose Battle Animations
  #--------------------------------------------------------------------------
  def self.dispose_battle_animations
    @active_animations.keys.each do |key|
      if key[0] == :actor || key[0] == :enemy
        manager = @sprite_managers[key]
        manager.dispose if manager
        @sprite_managers.delete(key)
        @active_animations.delete(key)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Animation Data
  #--------------------------------------------------------------------------
  def self.get_animation_data(key)
    @active_animations[key]
  end
  
  #--------------------------------------------------------------------------
  # * Get Fresh Target
  #--------------------------------------------------------------------------
  def self.get_fresh_target(key)
    type = key[0]
    id = key[1]
    
    if type == :event
      if id == 0
        return $game_player
      else
        return $game_map.events[id]
      end
    elsif type == :actor
      return $game_party.battle_members[id] if $game_party.in_battle
    elsif type == :enemy
      return $game_troop.members[id] if $game_party.in_battle
    end
    
    nil
  end
end

#==============================================================================
# ** LoopAnimationSpriteManager
#------------------------------------------------------------------------------
#  Manages sprites for looped animations on a single target
#==============================================================================

class LoopAnimationSpriteManager
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader :target
  attr_reader :key
  attr_reader :viewport
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(viewport, target, key)
    @viewport = viewport
    @target = target
    @key = key
    @loop_animations = {}
    @loop_lists = {}
    @reference_count = {}
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update(animation_data)
    return unless animation_data
    
    # Update loop lists from manager data
    update_loop_lists(animation_data)
    
    # Setup new animations
    setup_new_animations
    
    # Update all active animations
    update_all_animations
    
    # End animations if target not visible
    end_all_animations unless target_visible?
  end
  
  #--------------------------------------------------------------------------
  # * Update Loop Lists
  #--------------------------------------------------------------------------
  def update_loop_lists(animation_data)
    animation_data.each do |type, anims|
      @loop_lists[type] ||= []
      
      # Add new animations
      anims.each do |anim|
        next if @loop_lists[type].any? { |a| a[:anim] == anim[:anim] }
        @loop_lists[type] << anim.dup
      end
      
      # Remove animations no longer in data
      @loop_lists[type].delete_if do |anim|
        !anims.any? { |a| a[:anim] == anim[:anim] }
      end
      
      # Clean up empty types
      if @loop_lists[type].empty?
        @loop_lists.delete(type)
        dispose_animation(type)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Setup New Animations
  #--------------------------------------------------------------------------
  def setup_new_animations
    @loop_lists.keys.each do |type|
      if !@loop_animations[type] && @loop_lists[type] && !@loop_lists[type].empty?
        create_animation(type)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Create Animation
  #--------------------------------------------------------------------------
  def create_animation(type)
    return unless @loop_lists[type]
    
    item = @loop_lists[type].first
    anim_data = $data_animations[item[:anim]]
    return unless anim_data
    
    start_animation(anim_data, type)
    @loop_animations[type][:loop] = item[:loop] - 1 if @loop_animations[type]
  end
  
  #--------------------------------------------------------------------------
  # * Start Animation
  #--------------------------------------------------------------------------
  def start_animation(animation, type)
    dispose_animation(type)
    
    @loop_animations[type] = {
      data: animation,
      duration: animation.frame_max * 4 + 1,
      frame_max: animation.frame_max,
      rate: 4,
      sprites: [],
      loop: 0,
      position: animation.position,
      mirror: false
    }
    
    load_animation_bitmap(type)
    make_animation_sprites(type)
    set_animation_origin(type)
  end
  
  #--------------------------------------------------------------------------
  # * Load Animation Bitmap
  #--------------------------------------------------------------------------
  def load_animation_bitmap(type)
    anim = @loop_animations[type]
    return unless anim
    
    anim[:bitmap1] = Cache.animation(anim[:data].animation1_name, anim[:data].animation1_hue)
    anim[:bitmap2] = Cache.animation(anim[:data].animation2_name, anim[:data].animation2_hue)
    
    @reference_count[anim[:bitmap1]] ||= 0
    @reference_count[anim[:bitmap1]] += 1
    
    @reference_count[anim[:bitmap2]] ||= 0
    @reference_count[anim[:bitmap2]] += 1
    
    Graphics.frame_reset
  end
  
  #--------------------------------------------------------------------------
  # * Make Animation Sprites
  #--------------------------------------------------------------------------
  def make_animation_sprites(type)
    anim = @loop_animations[type]
    return unless anim
    
    if anim[:position] != 3
      16.times do
        sprite = Sprite.new(@viewport)
        sprite.visible = false
        anim[:sprites] << sprite
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Set Animation Origin
  #--------------------------------------------------------------------------
  def set_animation_origin(type)
    anim = @loop_animations[type]
    return unless anim
    
    if anim[:position] == 3
      # Screen animation
      if @viewport
        anim[:ox] = @viewport.rect.width / 2
        anim[:oy] = @viewport.rect.height / 2
      else
        anim[:ox] = Graphics.width / 2
        anim[:oy] = Graphics.height / 2
      end
    else
      # Target animation
      anim[:ox] = get_target_x
      anim[:oy] = get_target_y
      
      if anim[:position] == 0
        anim[:oy] -= get_target_height / 2
      elsif anim[:position] == 2
        anim[:oy] += get_target_height / 2
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Target X
  #--------------------------------------------------------------------------
  def get_target_x
    if @target.respond_to?(:screen_x)
      @target.screen_x
    elsif @target.respond_to?(:x)
      @target.x * 32 + 16 - $game_map.display_x * 32
    else
      0
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Target Y
  #--------------------------------------------------------------------------
  def get_target_y
    if @target.respond_to?(:screen_y)
      @target.screen_y
    elsif @target.respond_to?(:y)
      @target.y * 32 + 32 - $game_map.display_y * 32
    else
      0
    end
  end
  
  #--------------------------------------------------------------------------
  # * Get Target Height
  #--------------------------------------------------------------------------
  def get_target_height
    if @target.respond_to?(:height)
      @target.height
    else
      32
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update All Animations
  #--------------------------------------------------------------------------
  def update_all_animations
    @loop_animations.keys.each do |type|
      update_animation(type)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Animation
  #--------------------------------------------------------------------------
  def update_animation(type)
    anim = @loop_animations[type]
    return unless anim
    
    anim[:duration] -= 1
    
    # Update position for target animations
    if anim[:position] != 3
      anim[:ox] = get_target_x
      anim[:oy] = get_target_y
      
      if anim[:position] == 0
        anim[:oy] -= get_target_height / 2
      elsif anim[:position] == 2
        anim[:oy] += get_target_height / 2
      end
    end
    
    if anim[:duration] > 0
      update_animation_frames(anim)
    elsif anim[:duration] <= 0 && anim[:loop] > 0
      anim[:loop] -= 1
      anim[:duration] = anim[:frame_max] * anim[:rate] + 1
    elsif @loop_lists[type] && @loop_lists[type].size > 1
      # Cycle to next animation
      cycle_animation(type)
    else
      # End animation
      dispose_animation(type)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Cycle Animation
  #--------------------------------------------------------------------------
  def cycle_animation(type)
    return unless @loop_lists[type] && @loop_lists[type].size > 1
    
    # Move first to end
    first = @loop_lists[type].shift
    @loop_lists[type] << first
    
    create_animation(type)
    
    # Immediately update frames to prevent blinking
    anim = @loop_animations[type]
    if anim
      anim[:duration] = anim[:frame_max] * anim[:rate]
      update_animation_frames(anim)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Animation Frames
  #--------------------------------------------------------------------------
  def update_animation_frames(anim)
    frame = (anim[:duration] + anim[:rate] - 1) / anim[:rate]
    index = anim[:frame_max] - frame
    
    if anim[:data].frames[index]
      animation_set_sprites(anim, anim[:data].frames[index])
    end
    
    # Process timings
    if anim[:duration] % anim[:rate] == 1
      anim[:data].timings.each do |timing|
        process_timing(timing) if timing.frame == index
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Animation Set Sprites
  #--------------------------------------------------------------------------
  def animation_set_sprites(anim, frame)
    cell_data = frame.cell_data
    
    anim[:sprites].each_with_index do |sprite, i|
      next unless sprite
      
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      
      if anim[:duration] % anim[:rate] == 0
        setup_pattern(anim, pattern, sprite)
      end
      
      setup_position(anim, cell_data, sprite, i)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Setup Pattern
  #--------------------------------------------------------------------------
  def setup_pattern(anim, pattern, sprite)
    sprite.bitmap = pattern < 100 ? anim[:bitmap1] : anim[:bitmap2]
    sprite.visible = true
    sprite.src_rect.set(pattern % 5 * 192, pattern % 100 / 5 * 192, 192, 192)
  end
  
  #--------------------------------------------------------------------------
  # * Setup Position
  #--------------------------------------------------------------------------
  def setup_position(anim, cell_data, sprite, i)
    if anim[:mirror]
      sprite.x = anim[:ox] - cell_data[i, 1]
      sprite.y = anim[:oy] + cell_data[i, 2]
      sprite.angle = 360 - cell_data[i, 4]
      sprite.mirror = cell_data[i, 5] == 0
    else
      sprite.x = anim[:ox] + cell_data[i, 1]
      sprite.y = anim[:oy] + cell_data[i, 2]
      sprite.angle = cell_data[i, 4]
      sprite.mirror = cell_data[i, 5] == 1
    end
    
    sprite.z = 1000 + i
    sprite.ox = 96
    sprite.oy = 96
    sprite.zoom_x = cell_data[i, 3] / 100.0
    sprite.zoom_y = cell_data[i, 3] / 100.0
    sprite.opacity = cell_data[i, 6]
    sprite.blend_type = cell_data[i, 7]
  end
  
  #--------------------------------------------------------------------------
  # * Process Timing
  #--------------------------------------------------------------------------
  def process_timing(timing)
    # Flash
    if timing.flash_scope == 0
      @target.flash(timing.flash_color, timing.flash_duration)
    elsif timing.flash_scope == 1
      @viewport.flash(timing.flash_color, timing.flash_duration)
    end
    
    # SE
    if timing.se && timing.se.name != ""
      timing.se.play
    end
  end
  
  #--------------------------------------------------------------------------
  # * Target Visible?
  #--------------------------------------------------------------------------
  def target_visible?
    if @target.respond_to?(:visible)
      @target.visible
    elsif @target.respond_to?(:opacity)
      @target.opacity > 0
    else
      true
    end
  end
  
  #--------------------------------------------------------------------------
  # * Viewport Valid?
  #--------------------------------------------------------------------------
  def viewport_valid?
    return false unless @viewport
    @viewport.disposed? == false
  end
  
  #--------------------------------------------------------------------------
  # * Dispose Animation
  #--------------------------------------------------------------------------
  def dispose_animation(type)
    anim = @loop_animations[type]
    return unless anim
    
    # Dispose bitmaps
    if anim[:bitmap1]
      @reference_count[anim[:bitmap1]] -= 1
      if @reference_count[anim[:bitmap1]] <= 0
        anim[:bitmap1].dispose
        @reference_count.delete(anim[:bitmap1])
      end
    end
    
    if anim[:bitmap2]
      @reference_count[anim[:bitmap2]] -= 1
      if @reference_count[anim[:bitmap2]] <= 0
        anim[:bitmap2].dispose
        @reference_count.delete(anim[:bitmap2])
      end
    end
    
    # Dispose sprites
    anim[:sprites].each { |sprite| sprite.dispose }
    
    @loop_animations.delete(type)
  end
  
  #--------------------------------------------------------------------------
  # * End All Animations
  #--------------------------------------------------------------------------
  def end_all_animations
    @loop_animations.keys.each { |type| dispose_animation(type) }
    @loop_lists.clear
  end
  
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    end_all_animations
  end
end

#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
#  Added update call for loop animation manager
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # * Alias Method: update
  #--------------------------------------------------------------------------
  alias update_loop_animations_script_call update
  def update
    update_loop_animations_script_call
    LoopAnimationManager.update
  end
  
  #--------------------------------------------------------------------------
  # * Alias Method: terminate
  #--------------------------------------------------------------------------
  alias terminate_loop_animations_script_call terminate
  def terminate
    terminate_loop_animations_script_call
    # Dispose animations based on scene type
    if self.is_a?(Scene_Map)
      LoopAnimationManager.dispose_map_animations
    elsif self.is_a?(Scene_Battle)
      LoopAnimationManager.dispose_battle_animations
    end
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  Script call interface
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Script Call: start_event_loop_anim
  #--------------------------------------------------------------------------
  def start_event_loop_anim(event_id, animation_id, type = 0, loop = 999)
    LoopAnimationManager.start_event_loop_anim(event_id, animation_id, type, loop)
  end
  
  #--------------------------------------------------------------------------
  # * Script Call: stop_event_loop_anim
  #--------------------------------------------------------------------------
  def stop_event_loop_anim(event_id, animation_id = nil, type = 0)
    LoopAnimationManager.stop_event_loop_anim(event_id, animation_id, type)
  end
  
  #--------------------------------------------------------------------------
  # * Script Call: clear_event_loop_anims
  #--------------------------------------------------------------------------
  def clear_event_loop_anims(event_id)
    LoopAnimationManager.clear_event_loop_anims(event_id)
  end
  
  #--------------------------------------------------------------------------
  # * Script Call: start_actor_loop_anim
  #--------------------------------------------------------------------------
  def start_actor_loop_anim(actor_index, animation_id, type = 0, loop = 999)
    LoopAnimationManager.start_actor_loop_anim(actor_index, animation_id, type, loop)
  end
  
  #--------------------------------------------------------------------------
  # * Script Call: stop_actor_loop_anim
  #--------------------------------------------------------------------------
  def stop_actor_loop_anim(actor_index, animation_id = nil, type = 0)
    LoopAnimationManager.stop_actor_loop_anim(actor_index, animation_id, type)
  end
  
  #--------------------------------------------------------------------------
  # * Script Call: clear_actor_loop_anims
  #--------------------------------------------------------------------------
  def clear_actor_loop_anims(actor_index)
    LoopAnimationManager.clear_actor_loop_anims(actor_index)
  end
  
  #--------------------------------------------------------------------------
  # * Script Call: start_enemy_loop_anim
  #--------------------------------------------------------------------------
  def start_enemy_loop_anim(enemy_index, animation_id, type = 0, loop = 999)
    LoopAnimationManager.start_enemy_loop_anim(enemy_index, animation_id, type, loop)
  end
  
  #--------------------------------------------------------------------------
  # * Script Call: stop_enemy_loop_anim
  #--------------------------------------------------------------------------
  def stop_enemy_loop_anim(enemy_index, animation_id = nil, type = 0)
    LoopAnimationManager.stop_enemy_loop_anim(enemy_index, animation_id, type)
  end
  
  #--------------------------------------------------------------------------
  # * Script Call: clear_enemy_loop_anims
  #--------------------------------------------------------------------------
  def clear_enemy_loop_anims(enemy_index)
    LoopAnimationManager.clear_enemy_loop_anims(enemy_index)
  end
end
