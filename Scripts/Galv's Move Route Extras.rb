#------------------------------------------------------------------------------#
#  Galv's Move Route Extras
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 1.9
#------------------------------------------------------------------------------#
#  2013-07-30 - Version 1.9 - added move toward and away from x,y
#  2013-04-25 - Version 1.8 - added turn toward event
#  2013-03-22 - Version 1.7 - move randomly only in region id's specified
#  2013-03-14 - Version 1.6 - added activating other events
#  2013-03-14 - Version 1.5 - fixed a bug with jumping to xy, added jump forward
#  2013-03-12 - Version 1.4 - added random wait and play animation
#  2013-03-12 - Version 1.3 - added changing priortiy level
#  2013-03-12 - Version 1.2 - added repeating multiple commands
#  2013-03-12 - Version 1.1 - added fading in/out and repeating move commands
#  2013-03-12 - Version 1.0 - release
#------------------------------------------------------------------------------#
#  This script was written to fill some gaps the move route commands left out.
#  Script commands can be used in move routes (for events and player) to:
#  - Jump to x,y coordinates on the map
#  - Jump to an event's or player's current location
#  - Jump forward (the direction currently facing) x number of tiles
#  - Move toward or away from an event
#  - Move toward or away from x,y location
#  - Turn self switches on and off
#  - Change charset to any pose without that 'visible turning frame'
#  - Repeat move commands
#  - Change the priority level (under, same as, above player)
#  - Play animation/balloon
#  - Activate an event below or in front of
#  - Move in a random direction only on a specified region
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#  SCRIPTS to use within MOVE ROUTES
#------------------------------------------------------------------------------#
#
#  jump_to(x,y)               # jumps to that x,y location
#  jump_to_char(id)           # jumps to event with that id or -1 for player
#  jump_forward(x)            # jump forward x amount of tiles
#
#  move_toward_event(id)      # steps toward event with that id.
#  move_away_from_event(id)   # moves away from event with that id.
#  turn_toward_event(id)      # turns toward event with that id
#
#  move_toward_xy(x,y)        # steps toward x,y coordinates
#  move_away_from_xy(x,y)     # steps away from x,y coordinates
#
#  fadeout(speed)             # fade out an event at the speed specified
#  fadein(speed)              # fade in an event at the speed specified
#
#  repeat(x)                  # repeat all commands between this and end_repeat
#  end_repeat                 # and do it x number of times.
#
#  repeat_next(x)             # repeat the following move command x times
#
#  char_level(x)              # change the character's level to x (0-2)
#                             # 0 = below    1 = same as player    2 = above
#
#  anim(id)                   # play animation with that id on character
#  balloon(id)                 # pops ballon with that id above player
#
#  wait(a,b)                  # wait a random amount of frames between a and b
#
#  self_switch("switch",status)    # turns self switch on or off (true or false)
#  self_switch("switch",status,x)  # turns self switch on/off for event id x
#
#  set_char("Charset",index,col,dir)  # Change event graphic to any charset pose
#                                     # index = character in the charset (1-8)
#                                     # col = the column/step of graphic (1-3)
#                                     # dir = direction (2,4,6,8)
#
#  restore_char       # restores event animation (that was disabled by set_char)
#
#  activate_event(type)     # activates another event...
#                           # type 0 is below it, type 1 is in front of it.
#                           # NOTE: If the move route is "wait for completition
#                           # then the other event won't start until the current
#                           # move route is finished.
#
#  random_region(x,x,x)     # Move in a random direction ONLY on the region ids
#                           # specified (x's) to keep NPC's where they belong.
#
#------------------------------------------------------------------------------#
#  EXAMPLES OF USE:
#
#  set_char("Damage3",5,1,4)   # 5th actor, left facing, column 1 of Damage3
#  self_switch("A",true)       # turns self switch A ON
#  self_switch("C",false)      # turns self switch C OFF
#  fadeout(10)                 # gradually fades the event out at speed 10
#  anim(66)                    # play animation with id 66
#  wait(50,100)                # wait a random amount of frames between 50 & 100
#  char_level(0)               # set level as below player
#  random_region(1,2,3,4,5)    # will move a random direction on these regions
#  repeat_next(9)              # repeats the next move command 9 times
#
#  repeat(10)                  # Will repeat moving forward and turning 10 times
#  - Move Forward
#  - Turn 90 degrees left
#  end_repeat
#
#
#  move_toward_xy(10,5)        # Moves toward tile at coordinates x10, y5
#  move_toward_xy($game_varables[1],$game_varables[2])  # same as above using
#                                                       # stored variables
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
#  NO SETTINGS FOR YOU! Script calls only for this one :)
#------------------------------------------------------------------------------#

class Game_Character < Game_CharacterBase
  def jump_to(x,y)
    sx = distance_x_from(x)
    sy = distance_y_from(y)
    jump(-sx,-sy)
  end
  
  def jump_to_char(id)
    if id <= 0
      sx = distance_x_from($game_player.x)
      sy = distance_y_from($game_player.y)
    else
      sx = distance_x_from($game_map.events[id].x)
      sy = distance_y_from($game_map.events[id].y)
    end
    jump(-sx,-sy)
  end
  
  def jump_forward(count)
    sx = 0; sy = 0
    case @direction
    when 2; sy = count
    when 8; sy = -count
    when 4; sx = -count
    when 6; sx = count
    end
    jump(sx,sy)
  end
  
  def set_char(name,index,pattern,direction)
    @gstop = true
    @direction = direction
    @pattern = pattern - 1
    @character_name = name
    @character_index = index - 1
  end
  
  def restore_char
    @gstop = false
  end
  
  alias galv_move_extras_gc_update_anime_pattern update_anime_pattern
  def update_anime_pattern
    return if @gstop
    galv_move_extras_gc_update_anime_pattern
  end
  
  def move_toward_event(id)
    move_toward_xy($game_map.events[id].x,$game_map.events[id].y)
  end
  
  def move_toward_xy(sx,sy)
    sx = distance_x_from(sx)
    sy = distance_y_from(sy)
    if sx.abs > sy.abs
      move_straight(sx > 0 ? 4 : 6)
      move_straight(sy > 0 ? 8 : 2) if !@move_succeed && sy != 0
    elsif sy != 0
      move_straight(sy > 0 ? 8 : 2)
      move_straight(sx > 0 ? 4 : 6) if !@move_succeed && sx != 0
    end
  end

  def turn_toward_event(id)
    turn_toward_character($game_map.events[id])
  end
  
  def move_away_from_event(id)
    move_away_from_xy($game_map.events[id].x,$game_map.events[id].y)
  end
  
  def move_away_from_xy(sx,sy)
    sx = distance_x_from(sx)
    sy = distance_y_from(sy)
    if sx.abs > sy.abs
      move_straight(sx > 0 ? 6 : 4)
      move_straight(sy > 0 ? 2 : 8) if !@move_succeed && sy != 0
    elsif sy != 0
      move_straight(sy > 0 ? 2 : 8)
      move_straight(sx > 0 ? 6 : 4) if !@move_succeed && sx != 0
    end
  end
  
  def self_switch(switch,status,id = @id)
    return if $game_self_switches[[@map_id,id,switch]].nil?
    $game_self_switches[[@map_id,id,switch]] = status
  end
  
  def fadeout(speed)
    @opacity -= (speed)
    @move_route_index -= 1 if @opacity > 0
  end
  def fadein(speed)
    @opacity += (speed)
    @move_route_index -= 1 if @opacity < 255
  end
  
  def repeat_next(times)
    @crepeat_next = times - 1
  end
  
  def repeat(times)
    @crepeats = times - 1
    @index_position = @move_route_index
  end
  
  def end_repeat
    if @crepeats > 0
      @crepeats -= 1
      @move_route_index = @index_position if @index_position
    else
      @index_position = nil
    end
  end

  def char_level(type)
    @priority_type = type
  end
  
  def anim(id)
    @animation_id = id
  end
  def balloon(id)
    @balloon_id = id
  end
  
  def wait(low,high)
    @wait_count = (rand(low - high) + low).to_i
  end
  
  alias galv_move_extras_gc_init_private_members init_private_members
  def init_private_members
    @crepeats = 0
    @crepeat_next = 0
    galv_move_extras_gc_init_private_members
  end
  
  alias galv_move_extras_gc_process_move_command process_move_command
  def process_move_command(command)
    #if @crepeat_next > 0
    #  @move_route_index -= 1
    #  @crepeat_next -= 1
    #end
    galv_move_extras_gc_process_move_command(command)
  end
  
  def activate_event(type)
    sx = 0; sy = 0
    if type != 0
      case @direction
      when 2; sy = 1
      when 8; sy = -1
      when 4; sx = -1
      when 6; sx = 1
      end
    end
    $game_map.events_xy(@x + sx, @y + sy).each do |event|
      event.start unless event.id == @id
    end
  end
  
  def random_region(*args)
    r = [*args]
    dir = 2 + rand(4) * 2
    sx = 0; sy = 0
    case dir
    when 2; sy = 1
    when 8; sy = -1
    when 4; sx = -1
    when 6; sx = 1
    end
    return if !r.include?($game_map.region_id(@x + sx, @y + sy))
    move_straight(dir, false)
  end
  
end