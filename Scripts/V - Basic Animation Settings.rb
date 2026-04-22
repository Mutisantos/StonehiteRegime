#==============================================================================
# ** Victor Engine - Animations Settings
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.03.11 > First release
#  v 1.01 - 2012.03.15 > Compatibility with ENG version/VXAce_SP1
#  v 1.02 - 2012.07.25 > Fixed animation movement on characters
#  v 1.03 - 2013.02.13 > Compatibility with Basic Module 1.35
#                      > Removed tags <x: *>, <y: *> and <z *>
#                      > Added tags <above> and <bellow>
#------------------------------------------------------------------------------
#  This script adds some new options to control battle animation display.
# It also allows to display multiples animations on the same target (by default
# only one animation can be displayed) and fix some animations display bugs.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.35 or higher
#   If used with 'Victor Engine - Animated Battle' place this bellow it.
#
# * Overwrite methods (Default)
#   class Sprite_Base < Sprite
#     def animation?
#     def set_animation_rate
#     def start_animation(animation, mirror = false)
#     def load_animation_bitmap
#     def make_animation_sprites
#     def set_animation_origin
#     def animation_set_sprites(animation, frame)
#     def update_animation
#     def dispose_animation
#
#   class Sprite_Character < Sprite_Base
#     def move_animation(dx, dy)
#
# * Alias methods (Default)
#   class Sprite_Base < Sprite
#     def initialize(viewport = nil)
#
#   class Scene_Battle < Scene_Base
#     def show_normal_animation(targets, animation_id, mirror = false)
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Animation Name tags:
#  Since Animations don't have note boxes, the tags must be added to the
#  animation name on the database
#  
#  <above>
#   Animation is displayed above all sprites
#
#  <bellow>
#   Animation is displayed bellow the target.
#
#  <rate: x>
#   The animation update rate.
#     x : rate value, the default is 4. Lower values make the animation faster.
#
#  <zoom: x%>
#   Changes the animation zoom to rate.
#     x : zoom rate, the default is 100
#
#  <follow>
#    By default, once the animation start, it don't move even if the target
#    position change, with this tag the animation will follow the target.
#
#  <udir>
#    This tag have effect only when used together with the script
#    'VE - Animated Battle'. This will make the animation direction change
#    according to the action user direction. So the animation will be mirrored
#    if the user is facing right.
#
#  <tdir>
#    This tag have effect only when used together with the script
#    'VE - Animated Battle'. This will make the animation direction change
#    according to the action target direction. So the animation will be
#    mirrored if the target is facing right.
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#   If neither <above> or <bellow> is added to the animation name, then the
#   animation will be displayed at the same level of the target.
#   For screen animations to be displayed above all sprites you must add
#   the <above> tag to the animation name.
#
#   It's possible to make a script call before displaying a animation on a
#   character on the map.
#   $game_party.members[index].anim_direction = X #for actors
#   $game_map.events[index].anim_direction = X    #for events
#
#   X is the direction: 2 = down, 4 = left, 6 = right, 8 = up;
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
      msg += "Go to http://victorscripts.wordpress.com/ to download this script."
      msgbox(sprintf(msg, self.script_name(name), version))
      exit
    else
      self.required_script(name, req, version, type)
    end
  end
  #--------------------------------------------------------------------------
  # * script_name
  #   Get the script name base on the imported value
  #--------------------------------------------------------------------------
  def self.script_name(name, ext = "VE")
    name = name.to_s.gsub("_", " ").upcase.split
    name.collect! {|char| char == ext ? "#{char} -" : char.capitalize }
    name.join(" ")
  end
end

$imported ||= {}
$imported[:ve_animations_settings] = 1.03
Victor_Engine.required(:ve_animations_settings, :ve_basic_module, 1.00, :above)

#==============================================================================
# ** RPG::Animation
#------------------------------------------------------------------------------
#  The data class for animation.
#==============================================================================

class RPG::Animation
  #--------------------------------------------------------------------------
  # * New method: target_dir?
  #--------------------------------------------------------------------------
  def target_dir?
    @name =~ /<TDIR>/i
  end
  #--------------------------------------------------------------------------
  # * New method: user_dir?
  #--------------------------------------------------------------------------
  def user_dir?
    @name =~ /<UDIR>/i
  end
end

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
  attr_accessor :anim_direction
end

#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  This class deals with characters. It's used as a superclass of the
# Game_Player and Game_Event classes.
#==============================================================================

class Game_Character < Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :anim_direction
end

#==============================================================================
# ** Sprite_Base
#------------------------------------------------------------------------------
#  A sprite class with animation display processing added.
#==============================================================================

class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # * Class Variables
  #--------------------------------------------------------------------------
  @@multi_ani_checker ||= []
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_animations_settings :initialize
  def initialize(viewport = nil)
    initialize_ve_animations_settings(viewport)
    @animation  = {}
    @anim_index = 0
    @anim_position = {}
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: animation?
  #--------------------------------------------------------------------------
  def animation?
    !@animation.values.compact.empty?
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: start_animation
  #--------------------------------------------------------------------------
  def start_animation(animation, mirror = false)
    @anim_index += 1
    @animation[@anim_index] = Game_Animation.new(animation, mirror, user)
    if @animation[@anim_index]
      load_animation_bitmap
      make_animation_sprites
      set_animation_origin
    end
    user.anim_direction = nil if user
    user.animation_id   = 0   if user
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: load_animation_bitmap
  #--------------------------------------------------------------------------
  def load_animation_bitmap
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
  # * Overwrite method: make_animation_sprites
  #--------------------------------------------------------------------------
  def make_animation_sprites
    animation.duplicated  = @@multi_ani_checker.include?(animation.data)
    if @use_sprite && !(animation.duplicated  && animation.position == 3)
      16.times do
        sprite = ::Sprite.new(viewport)
        sprite.visible = false
        animation.sprites.push(sprite)
      end
    end
    @@multi_ani_checker.push(animation.data) if !animation.duplicated
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: set_animation_origin
  #--------------------------------------------------------------------------
  def set_animation_origin
    if animation.position == 3
      update_animation_screen(animation)
    else
      update_animation_origin(animation)
    end
    animation.map_x = charset? ? $game_map.display_x : 0
    animation.map_y = charset? ? $game_map.display_y : 0
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: animation_set_sprites
  #--------------------------------------------------------------------------
  def animation_set_sprites(animation, frame)
    cell_data = frame.cell_data
    animation.sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      if animation.duration % animation.rate == 0
        setup_sprite_pattern(animation, pattern, sprite)
      end
      setup_sprite_position(animation, cell_data, sprite, i)
    end
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: update_animation
  #--------------------------------------------------------------------------
  def update_animation
    @animation.keys.each {|index| update_animations(index) }
  end
  #--------------------------------------------------------------------------
  # * Overwrite method: dispose_animation
  #--------------------------------------------------------------------------
  def dispose_animation
    @animation.keys.each {|index| dispose_animations(index) }
  end  
  #--------------------------------------------------------------------------
  # * New method: user
  #--------------------------------------------------------------------------
  def user
    @battler ? @battler : @character
  end
  #--------------------------------------------------------------------------
  # * New method: animation
  #--------------------------------------------------------------------------
  def animation
    @animation[@anim_index]
  end
  #--------------------------------------------------------------------------
  # * New method: charset?
  #--------------------------------------------------------------------------
  def charset?
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: clear_anim_checker
  #--------------------------------------------------------------------------
  def clear_anim_checker
    @@multi_ani_checker.clear
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
  # * New method: update_animation_char
  #--------------------------------------------------------------------------
  def update_animation_char(animation)
    animation.ox   += (animation.map_x - $game_map.display_x) * 32
    animation.oy   += (animation.map_y - $game_map.display_y) * 32
    animation.map_x = $game_map.display_x
    animation.map_y = $game_map.display_y
  end
  #--------------------------------------------------------------------------
  # * New method: dispose_animations
  #--------------------------------------------------------------------------
  def dispose_animations(index)
    animation = @animation[index]
    if animation.bitmap1
      @@_reference_count[animation.bitmap1] -= 1
      animation.bitmap1.dispose if @@_reference_count[animation.bitmap1] == 0
    end
    if animation.bitmap2
      @@_reference_count[animation.bitmap2] -= 1
      animation.bitmap2.dispose if @@_reference_count[animation.bitmap2] == 0
    end
    animation.sprites.each {|sprite| sprite.dispose } if animation.sprites
    @animation.delete(index)
    @anim_index = 0 if @animation.values.empty?
  end
  #--------------------------------------------------------------------------
  # * New method: update_animations
  #--------------------------------------------------------------------------
  def update_animations(index)
    animation = @animation[index]
    animation.duration -= 1
    update_animation_origin(animation) if animation.follow
    update_animation_char(animation)   if charset?
    if animation.duration > 0
      update_animation_frames(animation)
    else
      dispose_animations(index)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: update_animation_frames
  #--------------------------------------------------------------------------
  def update_animation_frames(animation)
    frame = (animation.duration + animation.rate - 1) / animation.rate
    index = animation.frame_max - frame
    animation_set_sprites(animation, animation.frames[index])
    @ani_duplicated = animation.duplicated
    @ani_rate       = animation.rate
    if animation.duration % animation.rate == 1
      @@multi_ani_checker.delete(animation.data)
      animation.timings.each do |timing|
        animation_process_timing(timing) if timing.frame == index
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New method: setup_sprite_pattern
  #--------------------------------------------------------------------------
  def setup_sprite_pattern(animation, pattern, sprite)
    sprite.bitmap  = pattern < 100 ? animation.bitmap1 : animation.bitmap2
    sprite.visible = true
    sprite.src_rect.set(pattern % 5 * 192, pattern % 100 / 5 * 192, 192, 192)
  end
  #--------------------------------------------------------------------------
  # * New method: setup_sprite_position
  #--------------------------------------------------------------------------
  def setup_sprite_position(animation, cell_data, sprite, i)
    if animation.mirror || animation.direction == 6
      sprite.x = animation.ox - cell_data[i, 1] * animation.zoom
      sprite.y = animation.oy + cell_data[i, 2] * animation.zoom
      sprite.angle  = 360 - cell_data[i, 4]
      sprite.mirror = cell_data[i, 5] == 0
    elsif animation.direction == 2
      sprite.x = animation.ox + cell_data[i, 2] * animation.zoom
      sprite.y = animation.oy - cell_data[i, 1] * animation.zoom
      sprite.angle  = cell_data[i, 4] + 90
      sprite.mirror = cell_data[i, 5] == 1
    elsif animation.direction == 8
      sprite.x = animation.ox - cell_data[i, 2] * animation.zoom
      sprite.y = animation.oy + cell_data[i, 1] * animation.zoom
      sprite.angle  = cell_data[i, 4] - 90
      sprite.mirror = cell_data[i, 5] == 1
    else
      sprite.x = animation.ox + cell_data[i, 1] * animation.zoom
      sprite.y = animation.oy + cell_data[i, 2] * animation.zoom
      sprite.angle  = cell_data[i, 4]
      sprite.mirror = cell_data[i, 5] == 1
    end
    sprite.z  = self.z + animation.height
    sprite.ox = 96
    sprite.oy = 96
    sprite.zoom_x     = cell_data[i, 3] * animation.zoom / 100.0
    sprite.zoom_y     = cell_data[i, 3] * animation.zoom / 100.0
    sprite.opacity    = cell_data[i, 6] * self.opacity / 255.0
    sprite.blend_type = cell_data[i, 7]
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
  # * Overwrite method: move_animation
  #--------------------------------------------------------------------------
  def move_animation(dx, dy)
  end
  #--------------------------------------------------------------------------
  # * New method: charset?
  #--------------------------------------------------------------------------
  def charset?
    return true
  end
end

#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Alias method: show_animation
  #--------------------------------------------------------------------------
  alias :show_normal_animation_ve_animations_settings :show_normal_animation
  def show_normal_animation(targets, animation_id, mirror = false)
    animation = $data_animations[animation_id]
    if $imported[:ve_animated_battle] && animation && animation.target_dir?
      targets.each {|target| target.anim_direction = target.direction }
    elsif $imported[:ve_animated_battle] && animation && animation.user_dir?
      targets.each {|target| target.anim_direction = @subject.direction }
    end
    show_normal_animation_ve_animations_settings(targets, animation_id, mirror)
  end
end