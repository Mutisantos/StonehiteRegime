#==============================================================================
# ** Victor Engine - Followers Control
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.03.21 > First release
#  v 1.01 - 2012.03.21 > Added specific actor selection
#  v 1.02 - 2012.05.21 > Fixed bug with actor selection
#  v 1.03 - 2012.05.29 > Compatibility with Pixel Movement
#  v 1.04 - 2012.06.24 > Compatibility with Moving Platform
#------------------------------------------------------------------------------
#  This script allows the user to control the movement of the followers during
# events. With this you can make them leave the line, and return to the
# position at the event end. Using a comment call before the 'Set Move Route...'
# event command will make the move route commands works for a specific follower
# instead of the selected character. It's possible also to use this with the
# commands 'Display Animation', 'Show Ballon Icon' and 'Set Event Location'
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.25 or higher
#
# * Alias methods
#   class Game_Player < Game_Character
#     def move_by_input
#
#   class Game_Follower < Game_Character
#     def chase_preceding_character
#
#   class Game_Followers
#     def update
#
#   class Game_Interpreter
#     def get_character(param)
#     def command_203
#
#   class Game_Interpreter
#     def comment_call
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section on bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
# 
#  <control follower: x>
#   Gives control over the follower x. This command must be used before the
#   event command, this will make the command works for the selected follower
#   instead the selected character
#     x : follower position (starting from 1)
# 
#  <follower actor: x>
#   Gives control over the actor ID X, if he is in the active party.
#   This command must be used before the event command, this will make the
#   command works for the selected actor instead the selected character.
#   if the specified actor isn't in the party, nothing will happen (the event
#   command will be skiped).
#     x : actor ID
#
#  <gather followers>
#   This comment call will make the follower return to the position they were
#   before moving.
#
#------------------------------------------------------------------------------
# Additional instructions:
#
#  After moving the followers, it's highly adivised to use the comment call
#  <gather followers> or the event command 'Gather Followers' to gather the
#  followers after any scene where they were moved, otherwise, this might
#  break the follower movements and make them pass through plases that they
#  shouldn't.
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
$imported[:ve_followers_control] = 1.04
Victor_Engine.required(:ve_followers_control, :ve_basic_module, 1.25, :above)
Victor_Engine.required(:ve_followers_control, :ve_pixel_movement, 1.00, :bellow)

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player.
# The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Alias method: move_by_input
  #--------------------------------------------------------------------------
  alias :move_by_input_ve_followers_control :move_by_input
  def move_by_input
    return if followers.gathering_origin?
    move_by_input_ve_followers_control
  end
end

#==============================================================================
# ** Game_Follower
#------------------------------------------------------------------------------
#  This class handles the followers. Followers are the actors of the party
# that follows the leader in a line. It's used within the Game_Followers class.
#==============================================================================

class Game_Follower < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :origin_position
  #--------------------------------------------------------------------------
  # * Alias method: 
  #--------------------------------------------------------------------------
  alias :chase_preceding_character_ve_followers_control :chase_preceding_character
  def chase_preceding_character
    return if cant_follow_character
    chase_preceding_character_ve_followers_control
  end
  #--------------------------------------------------------------------------
  # * New method: cant_follow_preceding_character
  #--------------------------------------------------------------------------
  def cant_follow_character
    return false if $game_player.followers.gathering?
    return true  if $game_player.followers.gathering_origin?
    return @preceding_character.move_route_forcing || origin_position
  end
  #--------------------------------------------------------------------------
  # * New method: clear_origin_position
  #--------------------------------------------------------------------------
  def move_toward_position(x, y)
    super(x, y)
    clear_origin_position if in_origin?
  end
  #--------------------------------------------------------------------------
  # * New method: move_toward_origin
  #--------------------------------------------------------------------------
  def move_toward_origin
    return unless origin_position
    move_toward_position(origin_position[:x], origin_position[:y])
  end
  #--------------------------------------------------------------------------
  # * New method: in_origin?
  #--------------------------------------------------------------------------
  def in_origin?
    !origin_position || {x: @x, y: @y} == origin_position
  end
  #--------------------------------------------------------------------------
  # * New method: clear_origin_position
  #--------------------------------------------------------------------------
  def clear_origin_position
    @origin_position = nil
  end
end

#==============================================================================
# ** Game_Followers
#------------------------------------------------------------------------------
#  This class handles the followers. It's a wrapper for the built-in class
# "Array." It's used within the Game_Player class.
#==============================================================================

class Game_Followers
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_followers_control :update
  def update
    if gathering_origin?
      move_toward_origin unless moving? || moving?
      @gathering_origin = false if in_origin?
    end
    update_ve_followers_control
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  def gather
    @gathering = true
    visible_followers.each  {|follower| follower.clear_origin_position }
  end
  #--------------------------------------------------------------------------
  # * New method: gathering_origin?
  #--------------------------------------------------------------------------
  def gathering_origin?
    @gathering_origin
  end
  #--------------------------------------------------------------------------
  # * New method: in_origin?
  #--------------------------------------------------------------------------
  def in_origin?
    visible_followers.all? {|follower| follower.in_origin? }
  end
  #--------------------------------------------------------------------------
  # * New method: gather_origin
  #--------------------------------------------------------------------------
  def gather_origin
    @gathering_origin = true
  end
  #--------------------------------------------------------------------------
  # * New method: move_toward_origin
  #--------------------------------------------------------------------------
  def move_toward_origin
    visible_followers.each do |follower|
      follower.move_toward_origin if !follower.in_origin?
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
  # * Alias method: get_character
  #--------------------------------------------------------------------------
  alias :get_character_ve_followers_control :get_character
  def get_character(param)
    if @follower_control && !$game_party.in_battle
      @follower = $game_player.followers[@follower_control - 1]
      @follower_control = nil
      return nil if @follower.player?
      setup_origin
      @follower
    elsif @actor_follower && !$game_party.in_battle
      @follower = $game_player.followers.get_actor(@actor_follower)
      @actor_follower = nil
      return nil if @follower.player? 
      setup_origin
      @follower
    else
      get_character_ve_followers_control(param)
    end
  end
  #--------------------------------------------------------------------------
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :command_203_ve_followers_control :command_203
  def command_203
    character = get_character(@params[0])
    command_203_ve_followers_control
    character.origin_position = nil if character && character.follower?
  end
  #--------------------------------------------------------------------------
  # * Alias method: comment_call
  #--------------------------------------------------------------------------
  alias :comment_call_ve_followers_control :comment_call
  def comment_call
    control_follower
    gather_followers
    comment_call_ve_followers_control
  end
  #--------------------------------------------------------------------------
  # * New method: control_follower
  #--------------------------------------------------------------------------
  def control_follower
    @follower_control = $1.to_i if note =~ /<CONTROL FOLLOWER: (\d+)>/i 
    @actor_follower   = $1.to_i if note =~ /<FOLLOWER ACTOR: (\d+)>/i 
  end
  #--------------------------------------------------------------------------
  # * New method: gather_followers
  #--------------------------------------------------------------------------
  def gather_followers
    $game_player.followers.gather_origin if note =~ /<GATHER FOLLOWERS>/i
  end
  #--------------------------------------------------------------------------
  # * New method: setup_origin
  #--------------------------------------------------------------------------
  def setup_origin
    return if !@follower || @follower.origin_position
    @follower.origin_position = {x: @follower.x, y: @follower.y}
  end
end