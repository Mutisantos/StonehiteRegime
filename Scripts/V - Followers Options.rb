#==============================================================================
# ** Victor Engine - Followers Options
#------------------------------------------------------------------------------
# Author : Victor Sant
#
# Version History:
#  v 1.00 - 2012.01.20 > First release
#  v 1.01 - 2012.03.20 > Compatibility with Follower Control
#  v 1.02 - 2012.05.20 > Compatibility with Map Turn Battle
#                      > Fixed disable followers display
#  v 1.03 - 2012.05.29 > Compatibility with Pixel Movement
#  v 1.04 - 2012.07.30 > Improved compatibility with Pixel Movement
#  v 1.05 - 2012.08.18 > Fixed issue with Pixel Movement and Vehicles
#  v 1.06 - 2012.12.13 > Fixed issue with Map Turn Battle
#  v 1.07 - 2013.01.24 > Fixed issue with entering vehicles
#  v 1.08 - 2013.02.13 > Fixed issue with jump event command and Pixel Movement
#------------------------------------------------------------------------------
#  This script adds new options for the followers display. It improves the
# movement, and allows to set the display of dead characters and reorder
# the members on map without changing the battle order.
#------------------------------------------------------------------------------
# Compatibility
#   Requires the script 'Victor Engine - Basic Module' v 1.16 or higher
#
# * Overwrite methods (Default)
#   class Game_Player < Game_Character
#     def refresh
#     def actor
#
# * Alias methods (Default)
#   class Game_Actor < Game_Battler
#     def setup(actor_id)
#
#   class Game_Party < Game_Unit
#     def initialize
#     def setup_starting_members
#
#   class Game_Map
#     def update(main = false)
#     def refresh
#
#   class Game_CharacterBase
#     def initialize
#     def update_move
#     def moveto(x, y)
#
#   class Game_Follower < Game_Character
#     def initialize(member_index, preceding_character)
#     def update
#
# * Alias methods (Basic Module)
#   class Game_Interpreter
#     def comment_call
#
#------------------------------------------------------------------------------
# Instructions:
#  To instal the script, open you script editor and paste this script on
#  a new section bellow the Materials section. This script must also
#  be bellow the script 'Victor Engine - Basic'
#
#------------------------------------------------------------------------------
# Comment calls note tags:
#  Tags to be used in events comment box, works like a script call.
#  
#  <dead charset id: 'x', i>
#   Change dead graphic charset
#     id  : actor ID
#     'x' : dead charset filename ('filename')
#     i   : dead charset charset index, if using 8 chars charsets. (0-7)
#
#------------------------------------------------------------------------------
# Actors note tags:
#   Tags to be used on the Actors note box in the database
#  
#  <dead charset: 'x', i>
#   Initial dead graphic charset
#     'x' : dead charset filename ('filename')
#     i   : dead charset charset index, if using 8 chars charsets. (0-7)
#
#==============================================================================

#==============================================================================
# ** Victor Engine
#------------------------------------------------------------------------------
#   Setting module for the Victor Engine
#==============================================================================

module Victor_Engine
  #--------------------------------------------------------------------------
  # * Setup move distance
  #   This is the distance for the movement dealy for the follower, to3
  #   remove the delay just leave it zero.
  #--------------------------------------------------------------------------
  VE_MOVE_DISTANCE = 16
  #--------------------------------------------------------------------------
  # * Setup follower reorder
  #   You can reorder the players on the map without changing the battle
  #   order.
  #--------------------------------------------------------------------------
  VE_FOLLOWERS_REORDER = {
    enable:   true,      # Enable followers reorder
    next_key: :R,        # Key that will move the next actor to the front
                         # must be a valid key symbol, nil for no key
    last_key: :L,        # Key that will move the last actor to the front
                         # must be a valid key symbol, nil for no key
    sound:    "Cursor2", # Filename of the SE played when changin order
                         # nil for no sound
    volume:   100,       # Volume of the change order SE
    pitch:    100,       # Pitch of the change order SE
  } # Don't remove
  #--------------------------------------------------------------------------
  # * Setup dead followers display
  #   You can change how dead followes will be displayed
  #--------------------------------------------------------------------------
  VE_DEAD_FOLLOWER = {
    hide:      false,     # Hide the display of dead actors
    last:      true,      # Place dead actors as the last followers
    filename:  "$Coffin", # Filename for dead graphic character, leave nil for
                          # no dead graphic change
    fileindex: 0          # Index for the dead graphic character, should be 0
                          # for single charsets
  } # Don't remove
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
$imported[:ve_followers_options] = 1.08
Victor_Engine.required(:ve_followers_options, :ve_basic_module, 1.16, :above)
Victor_Engine.required(:ve_followers_options, :ve_multi_frames, 1.00, :bellow)
Victor_Engine.required(:ve_followers_options, :ve_character_effects, 1.00, :bellow)
Victor_Engine.required(:ve_followers_options, :ve_map_battle, 1.00, :bellow)
Victor_Engine.required(:ve_followers_options, :ve_pixel_movement, 1.00, :bellow)

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Alias method: setup
  #--------------------------------------------------------------------------
  alias :setup_ve_followers_options :setup
  def setup(actor_id)
    setup_ve_followers_options(actor_id)
    regexp = /<DEAD CHARSET: #{get_filename}(?: *, *(\d+))?>/i
    setup_dead_graphic(note, regexp)
  end
  #--------------------------------------------------------------------------
  # * New method: dead_graphic
  #--------------------------------------------------------------------------
  def dead_graphic
    @dead_graphic
  end
  #--------------------------------------------------------------------------
  # * New method: setup_dead_graphic
  #--------------------------------------------------------------------------
  def setup_dead_graphic(note, regexp)
    @dead_graphic = {name: $1, index: $2 ? $2.to_i : 0} if note =~ regexp
  end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles the party. It includes information on amount of gold 
# and items. The instance of this class is referenced by $game_party.
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_followers_options :initialize
  def initialize
    initialize_ve_followers_options
    @followers_id = []
  end
  #--------------------------------------------------------------------------
  # * New method: setup_starting_members
  #--------------------------------------------------------------------------
  alias :setup_starting_members_ve_followers_options :setup_starting_members
  def setup_starting_members
    setup_starting_members_ve_followers_options
    @followers_id = battle_members.collect {|member| member.id }
  end
  #--------------------------------------------------------------------------
  # * New method: members_id
  #--------------------------------------------------------------------------
  def members_id
    battle_members.collect {|member| member.id }.sort
  end
  #--------------------------------------------------------------------------
  # * New method: followers
  #--------------------------------------------------------------------------
  def followers
    @followers_id.collect {|id| $game_actors[id] }
  end
  #--------------------------------------------------------------------------
  # * New method: alive_followers
  #--------------------------------------------------------------------------
  def alive_followers
    followers.select {|actor| !actor.dead? }
  end
  #--------------------------------------------------------------------------
  # * New method: next_member
  #--------------------------------------------------------------------------
  def next_member
    @followers_id.next_item
  end
  #--------------------------------------------------------------------------
  # * New method: previous_member
  #--------------------------------------------------------------------------
  def previous_member
    @followers_id.previous_item
  end
  #--------------------------------------------------------------------------
  # * New method: dead_followers
  #--------------------------------------------------------------------------
  def dead_followers
    alive_followers + followers.select {|actor| actor.dead? }
  end
  #--------------------------------------------------------------------------
  # * New method: display_followers
  #--------------------------------------------------------------------------
  def display_followers
    return [alive_followers.first] if !$game_player.followers.visible
    return alive_followers if VE_DEAD_FOLLOWER[:hide]
    return dead_followers  if VE_DEAD_FOLLOWER[:last]
    followers
  end
  #--------------------------------------------------------------------------
  # * New method: update_followers
  #--------------------------------------------------------------------------
  def update_followers
    update_followers_id
    update_alive_followers
  end
  #--------------------------------------------------------------------------
  # * New method: update_followers_id
  #--------------------------------------------------------------------------
  def update_followers_id
    return if @followers_id.sort == members_id
    @followers_id.delete_if {|id| !members_id.include?(id) }
    @followers_id += members_id.select {|id| !@followers_id.include?(id)}
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * New method: update_alive_followers
  #--------------------------------------------------------------------------
  def update_alive_followers
    return if @alive_followers == alive_followers
    @alive_followers = alive_followers.dup
    $game_player.refresh
  end
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_ve_followers_options :update
  def update(main = false)
    update_ve_followers_options(main)
    $game_party.update_followers
    reorder_party if VE_FOLLOWERS_REORDER[:enable]
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :refresh_ve_followers_options :refresh
  def refresh
    refresh_ve_followers_options
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * New method: reorder_party
  #--------------------------------------------------------------------------
  def reorder_party
    if Input.trigger?(VE_FOLLOWERS_REORDER[:next_key])
      reorder_sound if VE_FOLLOWERS_REORDER[:sound]
      $game_party.next_member
    elsif Input.trigger?(VE_FOLLOWERS_REORDER[:last_key])
      reorder_sound if VE_FOLLOWERS_REORDER[:sound]
      $game_party.previous_member
    end
  end
  #--------------------------------------------------------------------------
  # * New method: reorder_sound
  #--------------------------------------------------------------------------
  def reorder_sound
    value = VE_FOLLOWERS_REORDER
    sound = RPG::SE.new(value[:sound], value[:volume], value[:pitch])
    sound.play
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
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_ve_followers_options :initialize
  def initialize
    initialize_ve_followers_options
    @real_x_dist = 0
    @real_y_dist = 0
  end
  #--------------------------------------------------------------------------
  # * Alias method: update_move
  #--------------------------------------------------------------------------
  alias :update_move_ve_followers_options :update_move
  def update_move
    update_move_ve_followers_options
    @real_x_dist = @real_x
    @real_y_dist = @real_y
  end
  #--------------------------------------------------------------------------
  # * Alias method: moveto
  #--------------------------------------------------------------------------
  alias :moveto_ve_followers_options :moveto
  def moveto(x, y)
    moveto_ve_followers_options(x, y)
    @real_x_dist = @x
    @real_y_dist = @y
  end
  #--------------------------------------------------------------------------
  # * New method: real_x_dist
  #--------------------------------------------------------------------------
  def real_x_dist
    @real_x_dist
  end
  #--------------------------------------------------------------------------
  # * New method: real_y_dist
  #--------------------------------------------------------------------------
  def real_y_dist
    @real_y_dist
  end
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles maps. It includes event starting determinants and map
# scrolling functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :vehicle_getting_off
  attr_reader   :vehicle_getting_on
  #--------------------------------------------------------------------------
  # * Overwirte method: refresh
  #--------------------------------------------------------------------------
  def refresh
    @character_name  = actor_graphic[:name]
    @character_index = actor_graphic[:index]
    @followers.refresh
  end
  #--------------------------------------------------------------------------
  # * Overwirte method: actor
  #--------------------------------------------------------------------------
  def actor
    $game_party.display_followers[0]
  end
  #--------------------------------------------------------------------------
  # * New method: actor_graphic
  #--------------------------------------------------------------------------
  def actor_graphic
    return {name: "", index: 0} unless actor
    return actor.dead_graphic if actor.dead? && actor.dead_graphic
    return dead_follower      if actor.dead? && dead_follower[:name]
    return {name: actor.character_name, index: actor.character_index}
  end
  #--------------------------------------------------------------------------
  # * New method: dead_follower
  #--------------------------------------------------------------------------
  def dead_follower
    {name: VE_DEAD_FOLLOWER[:filename], index: VE_DEAD_FOLLOWER[:fileindex]}
  end
  #--------------------------------------------------------------------------
  # * New method: move_straight
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    add_move_update([d]) if passable?(@x, @y, d)
    super
  end
  #--------------------------------------------------------------------------
  # * New method: move_diagonal
  #--------------------------------------------------------------------------
  def move_diagonal(horz, vert)
    add_move_update([horz, vert]) if diagonal_passable?(@x, @y, horz, vert)
    super
  end
  #--------------------------------------------------------------------------
  # * New method: jump
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    if x_plus != 0 || y_plus != 0
      @followers[0].move_update.push({dir: [nil], x: x_plus, y: y_plus})
    end
    super
  end
  #--------------------------------------------------------------------------
  # * New method: add_move_update
  #--------------------------------------------------------------------------
  def add_move_update(dir)
    return unless @followers[0] 
    last = @followers[0].move_update.last 
    if last && last[:dir] && opposite_move(dir, last[:dir])
      @followers[0].move_update.pop
      return
    end
    @followers[0].move_update.push({dir: dir})
  end
  #--------------------------------------------------------------------------
  # * New method: opposite_move
  #--------------------------------------------------------------------------
  def opposite_move(dir, last)
    dir == [2] && last == [8] || dir == [8] && last == [2] ||
    dir == [4] && last == [6] || dir == [6] && last == [4] ||
    dir == [4] && last == [6] || dir == [6] && last == [4] ||
    dir == [4, 2] && last == [6, 8] || dir == [6, 8] && last == [4, 2] ||
    dir == [6, 2] && last == [4, 8] || dir == [4, 8] && last == [6, 2]
  end
  #--------------------------------------------------------------------------
  # * New method: origin_position?
  #--------------------------------------------------------------------------
  def origin_position?
    return false
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
  attr_accessor :move_update
  #--------------------------------------------------------------------------
  # * Overwirte method: refresh
  #--------------------------------------------------------------------------
  def refresh
    @character_name  = actor_graphic[:name]
    @character_index = actor_graphic[:index]
  end
  #--------------------------------------------------------------------------
  # * Overwirte method: actor
  #--------------------------------------------------------------------------
  def actor
    $game_party.display_followers[@member_index]
  end
  #--------------------------------------------------------------------------
  # * Alias method: initialize
  #--------------------------------------------------------------------------
  alias :initialize_gf_ve_followers_options :initialize
  def initialize(member_index, preceding_character)
    initialize_gf_ve_followers_options(member_index, preceding_character)
    @move_update = []
    @real_move_speed = @move_speed
  end
  #--------------------------------------------------------------------------
  # * Alias method: update
  #--------------------------------------------------------------------------
  alias :update_gf_ve_followers_options :update
  def update
    update_movement
    update_gf_ve_followers_options
  end
  #--------------------------------------------------------------------------
  # * New method: actor_graphic
  #--------------------------------------------------------------------------
  def actor_graphic
    return {name: "", index: 0} unless actor
    return actor.dead_graphic if actor.dead? && actor.dead_graphic
    return dead_follower      if actor.dead? && dead_follower[:name]
    return {name: actor.character_name, index: actor.character_index}
  end
  #--------------------------------------------------------------------------
  # * New method: dead_follower
  #--------------------------------------------------------------------------
  def dead_follower
    {name: VE_DEAD_FOLLOWER[:filename], index: VE_DEAD_FOLLOWER[:fileindex]}
  end
  #--------------------------------------------------------------------------
  # * New method: move_straight
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    add_move_update([d]) if passable?(@x, @y, d)
    super
  end
  #--------------------------------------------------------------------------
  # * New method: move_diagonal
  #--------------------------------------------------------------------------
  def move_diagonal(horz, vert)
    add_move_update([horz, vert]) if diagonal_passable?(@x, @y, horz, vert)
    super
  end
  #--------------------------------------------------------------------------
  # * New method: jump
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    if next_character
      next_character.move_update.push({dir: [nil], x: x_plus, y: y_plus})
    end
    super
  end
  #--------------------------------------------------------------------------
  # * New method: update_movement
  #--------------------------------------------------------------------------
  def update_movement
    @move_update.clear  if same_tile? && !@preceding_character.origin_position?
    clear_move          if $imported[:ve_pixel_movement]
    @start_move = false if @move_update.size <= movement_size && !moving?
    pixel_gather_fix    if $imported[:ve_pixel_movement] && gathering?
    return if no_update
    process_movement(@move_update.shift)
  end
  #--------------------------------------------------------------------------
  # * New method: movement_size
  #--------------------------------------------------------------------------
  def movement_size
    return 1
  end
  #--------------------------------------------------------------------------
  # * New method: process_movement
  #--------------------------------------------------------------------------
  def pixel_gather_fix
    return if @move_update.size > 0 || gathered? || moving?
    move_toward_player
    @move_list.clear if gathered?
  end
  #--------------------------------------------------------------------------
  # * New method: process_movement
  #--------------------------------------------------------------------------
  def process_movement(move)
    @start_move = true
    if move && move[:x]
      jump(move[:x], move[:y])
    elsif move && move[:dir]
      @real_move_speed = move[:speed]
      method = move[:dir].size == 1 ? :move_straight : :move_diagonal
      send(method, *move[:dir])
    end
  end
  #--------------------------------------------------------------------------
  # * New method: same_tile?
  #--------------------------------------------------------------------------
  def same_tile?
    char = @preceding_character
    (char.real_x == real_x && char.real_y == real_y && jumping?) ||
    (char.x == @x && char.y == @y)
  end
  #--------------------------------------------------------------------------
  # * New method: no_update
  #--------------------------------------------------------------------------
  def no_update
    return false if gathering? && !moving? && pixel_no_update
    return true  if move_route_forcing
    return true  if moving? || jumping?
    return true  if player_distance && !@start_move
    return true  if @move_update.size <= 1
    if @move_update.first[:x]
      pos  = @move_update.first
      char = @preceding_character
      return true if (char.x - pos[:x] == @x && char.y - pos[:y] == @y)    
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * New method: pixel_no_update
  #--------------------------------------------------------------------------
  def pixel_no_update
    char = @preceding_character
    !$imported[:ve_pixel_movement] || char.player? || char.gathered?
  end
  #--------------------------------------------------------------------------
  # * New method: player_distance
  #--------------------------------------------------------------------------
  def player_distance
    self_x  = $game_map.adjust_x(real_x_dist)
    self_y  = $game_map.adjust_y(real_y_dist)
    front_x = $game_map.adjust_x(@preceding_character.real_x_dist)
    front_y = $game_map.adjust_y(@preceding_character.real_y_dist)
    dist_x  = (front_x - self_x).abs
    dist_y  = (front_y - self_y).abs
    dist_m  = (next_diagonal? ? 2 : 1) + [VE_MOVE_DISTANCE / 32.0, 0].max
    dist_x + dist_y < dist_m
  end
  #--------------------------------------------------------------------------
  # * New method: add_move_update
  #--------------------------------------------------------------------------
  def add_move_update(dir)
    return if !next_character || move_route_forcing || origin_position?
    next_character.move_update.push({dir: dir, speed: real_move_speed})
  end
  #--------------------------------------------------------------------------
  # * New method: origin_position?
  #--------------------------------------------------------------------------
  def origin_position?
    $imported[:ve_followers_control] && origin_position
  end
  #--------------------------------------------------------------------------
  # * New method: next_character
  #--------------------------------------------------------------------------
  def next_character
    $game_player.followers[@member_index]
  end
  #--------------------------------------------------------------------------
  # * New method: next_diagonal?
  #--------------------------------------------------------------------------
  def next_diagonal?
    next_move && next_move[:dir] && next_move[:dir].size == 2 &&
    !$imported[:ve_pixel_movement]
  end
  #--------------------------------------------------------------------------
  # * New method: next_move
  #--------------------------------------------------------------------------
  def next_move
    @move_update.first
  end
  #--------------------------------------------------------------------------
  # * New method: clear_move
  #--------------------------------------------------------------------------
  def clear_move
    char = @preceding_character
    clear_move_horz if char.real_x == real_x
    clear_move_vert if char.real_y == real_y
  end 
  #--------------------------------------------------------------------------
  # * New method: clear_move_horz
  #--------------------------------------------------------------------------
  def clear_move_horz
    @move_update.delete_if {|move| move[:dir] == [4] || move[:dir] == [6]}
    @move_update.collect do |move|
      move[:dir].size == 1 ? move[:dir] :
      move[:dir].delete(move[:dir].include?(4) ? 4 : 6)
    end
  end
  #--------------------------------------------------------------------------
  # * New method: clear_move_vert
  #--------------------------------------------------------------------------  
  def clear_move_vert
    @move_update.delete_if {|move| move[:dir] == [2] || move[:dir] == [8]}
    @move_update.collect do |move|
      move[:dir].size == 1 ? move[:dir] :
      move[:dir].delete(move[:dir].include?(2) ? 2 : 8)
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
  alias :comment_call_ve_followers_options :comment_call
  def comment_call
    call_follower_setting
    comment_call_ve_followers_options
  end  
  #--------------------------------------------------------------------------
  # * New method: call_follower_setting
  #--------------------------------------------------------------------------
  def call_follower_setting
    note.scan(/<DEAD CHARSET (\d+): #{get_filename}(?: *, *(\d+))?>/i) do
      actor = $game_actors[$1.to_i]
      next unless actor
      notes  = "\"#{$1}\", #{$2 ? $2 : 0}"
      regexp = /#{get_filename} *, *(\d+)/
      actor.setup_dead_graphic(notes, regexp)
    end
  end
end