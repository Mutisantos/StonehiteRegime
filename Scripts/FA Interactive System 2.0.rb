#==============================================================================#
#  #*****************#                                                         #
#  #*** By Falcao ***#              * Interactive system 2.0                   #
#  #*****************#         This script allow you to interact with events   #
#                              game player, game characters and tarrain tiles  #
#       RMVXACE                The feeling of realism is inminent              #
#  www.makerpalace.com         Date: September 5 2012                          #
#==============================================================================#

# * Installation
#
# You will need the graphics characters provided in the download post,
# all pictures must be placed in character folder.
#
# Copy and paste the script above main and below materials. Done!
#
# Any pixel movement script may alter the X and Y axis this script is based
# so i recomend you get rid any pixel movement script you have installed.
#-------------------------------------------------------------------------------
# License: 
# For non-comercial games only, for comercial games contact me to the
# following email address falmc99@gmail.com

#-------------------------------------------------------------------------------
#      * Features
#
# - Interactive Push system
# - Interactive Pick Up system
# - Interactive Fall System
# - Interactive Jump System
# - Interactive Sensor Vision System
# - Interactive Tool HookShot
# - Interactive Tool Flame Thrower
# - Interactive Tool Bombs
# - Interactive Tool Barrel
# - Interactive Tool Blade
# - Interactive Tool Arrows
# - Interactive Dynamic Light Effects
# - Interactive Dynamic Drop
#
# The push system allow you to push events to your desire place, allow you to
# press targets and easily  tell them to do something when collide, events can
# press targets by themself if you give them movement
#
# The pick up system allow you to pick up events and move it wherever you want
# when you throw the event you can easily tell them to do something afther
# throwed
#
# The fall system allow you to fall to espeficific tiles, events fall, fallowers
# fall, events can make the player fall, also you can make something happen
# when an event fall
#
# The Jump System allow you to jump by triggering the action key, followers
# jump together with the player.
#
# The Sensor vision system allow you to activate any event within a vision range
# between the player and the event, the event deactivate when out range
#
# The tool hookshot allow you to pull yourself to a different positions in
# the map, you can grab objects from x distance and also start events tagged
#
# The tool flame thrower alllow tou star events tagged, burn torchs, burn the
# barrel etc, create a ligh effect to see in the darkness
#
# The tool bomb allow you to explode some areas activating events tagged,
# bombs can be picked and throwed, game party is affected if the bomb hurt them
#
# The tool barrel is a native tool created for this system never seen before in
# a game, you can make a lot of things as: use it as a lantern, pick up throw,
# burn the barrel with the flame trower, can be grabbed with the hook shot, 
# allow tou to solve puzzles, push events from the push system and much more.
#
# The tool blade allow you clean your path by cutting grass or wherever you want
# to do with it, also you can apply drop to it
#
# The tool Arrows aloow you to activate events from long distance, you can
# interact with bombs like creating a bomb arrow at real time
#
# The dynamic light effects allow you to create real lights on event tagged
# you can set intencity, direction and do a lot of things.
#
# The dynamic drop allow you to create events to drop items jus by tagging
# a simple comman.
#-------------------------------------------------------------------------------

module FalInt
  
#-------------------------------------------------------------------------------
#                      * Push system *
#
# Write the followings lines on a event command comment tag
#
# PUSHABLE            - Event can be pushed wherever you want
# JUMPBACK            - event jump back if you pushed against an impasable tile
# 
# TARGET SELF SWITCH  - Put the self switch letter you want to activate
#                       when collide ex: TARGET SELF SWITCH A
# 
# TARGET SWITCH       - Put the switch id you want to activate when collide
#                       ex: TARGET SWITCH 10
#
# TARGET VARIABLE     - Put the variable id you want to increase (+) when 
#                       collide ex: TARGET VARIABLE 5
#
# * Important info:
#
# Switches and variables are activated when PUSHED and TARGET collide and
# they are deactivated when not colliding,  when you tranfer to another map
# switches and variables the target activated reset
#
# TARGET events are always through on, always priority below characters and
# dont start with the action key
# PUSHABLE events are always direction fix off and always through off
#
# By default Player can push events too but you can disable or enable that
# anytime with the following command
#
# $game_player.allowto_push = value    change value for true/false
#

  # Sound played when the player push an event
  PushSe = "Open1"
  
  # Sound played when pressing a target
  PressTarget = "Switch2"
  
  # Sound played when realeasing the target
  ReleaseTarget = "Switch1"

#-------------------------------------------------------------------------------
#                         * Pick Up system *
#
# Write the followings lines on an event command comment tag
#
# PICK UP             The event is picked up when the action keys is triggered
#
# THROW SELF SWITCH   Put self switch letter you want to activate when you throw
#                     the event ex: THROW SELF SWITCH A
#
# If you dont want self switch just leave it.
#
# You can do a lot of stuff when you throw an event, like desappear it, drop
# something, use your imagination.
#
  # Sound played when player pick up an event
  PickUpSe = "Shot1"
  
  # Sound played when player throw the event
  ThrowSe = "smrpg_enemy_throw"

# * Pick Up Graphic
#
# You can change the actor graphic while picking an object, to show the graphic
# the following requiriment must match.
#
# 1 -Obviously you graphic 
# 2- Name your graphic as your ariginal graphic plus $ and index 
#
# Example: my character name is Actor4 index 0, so your pick up graphic must
# be named $Actor4_index0
#
# If your main character is individual leave index0 as default
#-------------------------------------------------------------------------------
#                           * Fall System *
#
  
  # Terrain tag where the player and events fall
  FallTag = 6
  
  # Sound played when falling
  FallSe = "Fall"
  
# Followers can fall too, events can fall too but events are no fools, they
# only fall when player push them, so in order to make an event fall it must be
# tagged PUSHABLE 
#
# Write the followings lines on an event command comment tag
#
# FALL SWITCH        Put the switch id you want to activate when event fall
#                    ex: FALL SWITCH 20
# 
# FALL VARIABLE      Put the variable id you want to increase (+) when an
#                    event fall ex: FALL VARIABLE 6
#
# If you dont want to activate switch or variable just leave it blank
# Event is erased when they fall
#
# Player and followers decrease hp when they fall, default amount of hp to loose
# is 100, but you can change that value anytime with the following command
#
# 
# $game_player.fallhp = value     Change value for desire hp to loose
#                                 ex: $game_player.fallhp = 200
#
# Events can push the player in order to make him fall, write the following line
# on event command comment tag: PUSH THE PLAYER the player will be jumped away
# from the event.
#-------------------------------------------------------------------------------
#                      * Jump System
#
# Call the following line to activate the jump system
#
# $game_player.enable_jump = value      Change value for true / false
#                                       ex: $game_player.enable_jump = true
#
# Player and followers jump together, they can jump only two tiles while
# moving, if the are standing jump only at the same place, press the action key
# to jump

  # Sound played when jumping
  JumpSe = "Jump1"
#-------------------------------------------------------------------------------
#                      * Sensor Vision System
#
# Write the followings lines on an event command comment tag
#
# SENSOR VISION RANGE       Put vision range in tiles you want the event to have
#                           ex: SENSOR VISION RANGE 6
#
# The distance is based in tiles between the game player and the event, when the
# player is within the vision range a self switch is activated and it is
# deactivated when the player is out of range
#
  # Self switch that is activated when the player is whithin the range
  SensorSelfsw = "C"
#-------------------------------------------------------------------------------

  # Action key, this key toggle pick up events, throw events and jump
  ActionKey = :C
  
#-------------------------------------------------------------------------------
# * Interactive tool Hookshot
  
  # Hookshot graphic, must be on characters graphic folder
  HookGraphic = "$Hooktest4"
  
  # Weapon id that need to be equiped in order to use the Hook Shot
  HweaponId = 61
  
  # How long you want the hook to have? it is measure in tiles
  HookLong = 11
  
  # Hookshot speed, you can choose a value between 1 to 10, it support decimals
  HookSpeed = 6
  
  # Sound played when using the hook
  HookActionSe = "Bow1"
  
  # Sound played when hooking object
  HookHookingSe = "Hammer"
  
#  HookShot Actions, write the followings lines on event comment tag
#  
#  HOOK PULL           Game player move from current position to event position
#
#  HOOK GRAB           The event can be grabbed by the hookshot
#
#  HOOK START          The event start when hit it by the hookshot 
#
  
#-------------------------------------------------------------------------------
# * Interactive tool Flame Thrower
  
  # Flame graphic, must be on characters graphic folder
  FlameGraphic = "$Flame"
  
  # Weapon id that need to be equiped in order to use the flame thrower
  FweaponId = 62
  
  # Magic points (MP) that is consumed when using the flame thrower
  FlameMpCost = 0
  
  # Flame duration, it is measured in frames, 60 frames = 1 second
  FlameDuration = 60
  
  # Sound played when using the flame
  FlameSoundSe = "Fire1"
  
# Flame Actions, write the followings lines on event comment tag
#
# FLAME START           The event start when hit it by the Flame Thrower
#
# Note: A flame ligh is displayed when the current game tone change, it can be
# used as a small lantern for short time.

#-------------------------------------------------------------------------------
# * Interactive tool Water Shower
  
  # Flame graphic, must be on characters graphic folder
  WaterGraphic = "$Water"
  
  # Weapon id that need to be equiped in order to use the flame thrower
  WweaponId = 6
  
  # Magic points (MP) that is consumed when using the flame thrower
  WaterMpCost = 0
  
  # Flame duration, it is measured in frames, 60 frames = 1 second
  WaterDuration = 30
  
  # Sound played when using the flame
  WaterSoundSe = "Water1"
  
# Water Actions, write the followings lines on event comment tag
#
# WATER START           The event start when hit it by the Flame Thrower
#
# Note: A WATER ligh is displayed when the current game tone change, it can be
# used as a small lantern for short time.
  
#-------------------------------------------------------------------------------
# * Interactive tool Bomb
  
  # Bomb graphic, must be on characters graphic folder
  BombGraphic = "$Bomb"
  
  # Weapon id that need to be equiped in order to use the bombs
  BweaponId = 63
  
  # Item id that is consumed when using a bomb
  BcostItemId = 17
  
  # How long you want the bomb to be showed? it is measured in seconds
  BombDuration = 4
  
  # Bomb impact area, it is measured in tiles between the bomb and the object
  BombImpactArea = 2
  
  # Total damage done to the game party if hurted by the bomb
  BombDamage = 100
  
  # Sound played when using a bomb
  BombActionSe = "Knock"
  
  # Animation id that is showed when the bomb explode
  BombAnimationId = 14
  
# Bomb Actions, write the followings lines on event comment tag
#
# BOMB SELF SWITCH        Put self switch letter you want to activate when the
#                         bomb explode an event. ex: BOMB SELF SWITCH A
#
# Note: The bomb is an area tool, affect to all events tagged above, it hurt to
# the game party, keep your ass in a safe place, Bomb can be picked an throwed

#-------------------------------------------------------------------------------
# * Interactive tool Barrel
  
  # Barrel graphic showed when is normal
  BarrelGraphicOff = "$Barrel1"
  
  # Barrel graphic showed when is burning
  BarrelGraphicOn = "$Barrel2"
  
  # Weapon id that need to be equiped in order to use the barrel
  BAweaponId = 64
  
  # Item id that is consumed when using the barrel (the barrel wood)
  BarrelItemCost = 19
  
  # Sound played when using a barrel
  BarrelActionSe = "Knock"

# Note: The barrel system is a powerfull tool, that can do a lot of things
# - Use the barrel as a lantern
# - Burn the barrel with the flamne thrower
# - Pick up and throw the barrel
# - Grab the barrel with the hookshot
# - Press events from the push system 
# 
# Note2: When the barrel is burned a ligh effect is created so you can pick up
# the barrel and have a lantern
#
# Default barrel burn time is 20 seconds but can be changed wherever you want
# with this script call:    $game_player.barrelburntime = 30   time in seconds
#
#           * Screen tone asociated with the barrel burnnig time
#
# By default no screen tone is changed when burning the barrel, just a pure ligh
# is displayed around the barrel, but you can apply screen tone changes where
# the barrel ligh gonna be used.
#
# Use this scripts call to tint next maps and activate the barrel burn tone chan
#
# $game_player.dark_nextmap           Activate the barrel ligh tone changes and
#                                     the next map will be tinted dark
#                                     
# $game_player.normal_nextmap         Next map normalize, yes when you leave
#                                     from the cave or something like that

# Barrel light tone change (Red, Green, Blue, Gray), when barrel burn
  BarrelScreenTone = Tone.new(-60, -60, -60, 10)
  
  # Tone that is defined as normal in your game ( it s the default game tone)
  GameNormalTone = Tone.new(0, 0, 0, 0)
  
#-------------------------------------------------------------------------------
# * Interactive tool Blade
  
  # Blade graphic
  BladeGraphic = "$Navaja"
  
  # Weapon id that need to be equiped in order to use the Blade
  BladeWeaponId = 65
  
  # Sound played when using the blade
  BladeSoundSe = "Bow2"
  
# Blade Actions, write the followings lines on event comment tag
#
# BLADE SELF SWITCH     Put self switch letter you want to activate when the
#                       blade hit the event ex: BLADE SELF SWITCH A
#
# BLADE HIT ANIMATION   Put animation id that you want to be showed when the
#                       blade hit the event ex: BLADE HIT ANIMATION 112
#
#-------------------------------------------------------------------------------
# * Interactive tool Arrow
  
  # Arrow Graphic
  ArrowGraphic = "$Arrow"
  
  # Weapon id that need to be equiped in order to use Arrows
  ArrowWeaponId = 66
  
  # Item id that is consumed when using the arrows
  ArrowItemCost = 18
  
  # Range of the arrows, it is measured in tiles
  ArrowRange = 15
  
  # Sound played when using arrows
  ArrowActionSe = "Bow3"
  
# Arrow Actions, write the followings lines on event comment tag 
#
# ARROW START           Event start when hit it by the arrows
#
#-------------------------------------------------------------------------------
# * Interactive tool Gun

  # Gun Sniper
  GunSnipe = "$snipegun"

  # Gun Graphic
  GunGraphic = "$Bullet"
  
  # Weapon id that need to be equiped in order to use Gun
  GunWeaponId = 2
  
  # Item id that is consumed when using the Gun
  GunItemCost = 1
  
  # Range of the Gun, it is measured in tiles
  GunRange = 15
  
  # Sound played when using Gun
  GunActionSe = "rifle8"
  
# Gun Actions, write the followings lines on event comment tag 
#
# GUN START           Event start when hit it by the bullets
#
#-------------------------------------------------------------------------------
# Key to triggers the tools, key A from the keyboard
  ToolActionKey = :X
#
#-------------------------------------------------------------------------------
#                      * Tools important notes
#
# An event tagged as HOOK START, FLAME START, ARROW START, dont start with the
# player action key, they only start with the action tool.
#
#-------------------------------------------------------------------------------
# * Interactive Dynamic Lights
  
  # Ligh effects graphic
  LightsGraphic = "$Light_effects"
  
# Light Effects Actions, write the followings lines on event comment tag 
# 
# LIGHT EFFECT DIRECTION     Activate Ligh effect on that event, write the
#                            direcction you want the graphic to be displayed
#                            2 = Down, 4 = LEFT, 6 = RIGHT, 8 = UP
#                            ex: LIGHT EFFECT DIRECTION = 2
#
# LIGHT EFFECT INTENCITY     Put the intencity number you want the light to have
#                            there are five levels only: choose a value from 
#                            1 to 5 ex: LIGHT EFFECT INTENCITY 1
#
# LIGHT EFFECT REQUIRE FLAME The light effec is displayed only when the flame
#                            thrower hit it
#
# Note: in case you want to turn on / off the ligh effect manually on event
# use the followings script calls
#
# $game_map.lighactive(event_id, value)
#
# Intead of event id put event id, intead of value put true / false
# ex: $game_map.lighactive(1, true)
#
# Note2: in order to use those script calls you have to tag the event as
# LIGHT EFFECT REQUIRE FLAME
# 
#-------------------------------------------------------------------------------
# * Interactive Dynamic Drop
#
# Write the followings lines on event comment tag 
# 
# DROP ITEM ID          Put item id that you want to be droped by the event.
#                       ex: DROP ITEM ID 1
#-------------------------------------------------------------------------------
end

#-------------------------------------------------------------------------------
#                 * Falcao Interactive System version 2.0

#
#  * Game tools creation





# Game hook
class Game_Hook < Game_Character
  attr_accessor   :index
  def initialize(index)
    super()
    @through = true
    @index = index
    @character_name = FalInt::HookGraphic 
    @move_speed = FalInt::HookSpeed
    @priority_type = 2
  end
end

# Game fire
class Game_Fire < Game_Character
  attr_accessor   :action_time
  def initialize
    super
    @through = true
    @character_name = FalInt::FlameGraphic
    @move_speed = 6
    @action_time = 0
    @priority_type = 2
    @step_anime = true
  end
end

# Game water
class Game_Water < Game_Character
  attr_accessor   :action_time
  def initialize
    super
    @through = true
    @character_name = FalInt::WaterGraphic
    @move_speed = 6
    @action_time = 0
    @priority_type = 2
    @step_anime = true
  end
end

# Game bomb
class Game_Bomb < Game_Character
  attr_accessor   :action_time
  def initialize
    super
    @character_name = FalInt::BombGraphic
    @action_time = 0
    @step_anime = true
    @move_speed = 6
  end
end

# Game Barrel
class Game_Barrel < Game_Character
  attr_accessor   :fire_duration
  attr_accessor   :character_name
  attr_accessor   :pevent
  def initialize
    super
    @character_name = FalInt::BarrelGraphicOff
    @fire_duration = 0
    @step_anime = true
    @move_speed = 6
  end
end

# Game Blade
class Game_Blade < Game_Character
  attr_accessor   :action_time
  def initialize
    super
    @character_name = FalInt::BladeGraphic
    @move_speed = 6
    @action_time = 0
    @through = true
    @priority_type = 2
    @step_anime = true
  end
end

# Game arrows
class Game_Arrow < Game_Character
  def initialize
    super
    @through = true
    @character_name = FalInt::ArrowGraphic 
    @move_speed = 5
    @priority_type = 2
  end
end

# Game bullets
class Game_Gun < Game_Character
  def initialize
    super
    @through = true
    @character_name = FalInt::GunGraphic 
    @move_speed = 7
    @priority_type = 2   
  end
end


# Sprite sets
class Spriteset_Map
  alias falcao_intsystem_create_characters create_characters
  def create_characters
    create_interactive_characters
    falcao_intsystem_create_characters
  end
  
  def create_interactive_characters
    if $game_player.clear_lights
      dispose_light_effects
      dispose_drop_sprites
      $game_player.clear_lights = false
    end
    @hook_sprites = []
    @lighesprites = []
    @drop_sprites = []
    @drop_events = []
    play = $game_player
    play.showing_hook   ? create_hook_sprites   : play.clear_hook
    play.showing_fire   ? create_fire_sprite    : play.gamefire.moveto(-1, -1)
    play.showing_water  ? create_water_sprite   : play.gamewater.moveto(-1, -1)
    play.showing_bomb   ? create_bomb_sprite    : play.gamebomb.moveto(-1, -1)
    play.showing_barrel ? create_barrel_sprite  : play.gamebarrel.moveto(-1, -1)
    play.showing_blade  ? create_blade_sprite   : play.gameblade.moveto(-1, -1)
    play.showing_arrow  ? create_arrow_sprite   : play.gamearrow.moveto(-1, -1)
    play.showing_gun    ? create_gun_sprite     : play.gamegun.moveto(-1, -1)
    create_light_effects
    create_fblight  # fire barrel light
    create_fireligh # flame thrower light
    case    play.intreserved_tone[0]
    when 1; $game_map.screen.start_tone_change(Tone.new(-130, -130, -130, 10),0)
    when 2; $game_map.screen.start_tone_change(FalInt::GameNormalTone, 0)
    end 
    play.intreserved_tone[1] = $game_map.map_id if play.intreserved_tone[0] != 0
    play.intreserved_tone[1] = nil if play.intreserved_tone[0] == 2
    if play.intreserved_tone[0] != 0 and play.gamebarrel.fire_duration > 0 and
      play.intreserved_tone[1] != nil
      play.current_tonesv = $game_map.screen.tone
      $game_map.screen.start_tone_change(FalInt::BarrelScreenTone, 0)
    end
    play.intreserved_tone[0] = 0
  end
  
  alias falcao_intsystem_dispose_h dispose
  def dispose
    dispose_hook_sprites
    dispose_fire_sprite
    dispose_water_sprite
    dispose_bomb_sprite
    dispose_barrel_sprite
    dispose_light_effects
    dispose_fblight   #fire barrel light
    dispose_fireligh  #flame thrower light
    dispose_blade_sprite
    dispose_drop_sprites
    dispose_arrow_sprite
    dispose_gun_sprite
    falcao_intsystem_dispose_h
  end
  
  def create_hook_sprites
    return if not @hook_sprites.empty?
    for hook in $game_player.hookshot
      hook.transparent = false
      sprite = Sprite_Character.new(@viewport1, hook)
      @hook_sprites.push(sprite)
    end
  end
  
  def dispose_hook_sprites
    return if @hook_sprites.empty?
    @hook_sprites.each {|sprite| sprite.dispose }
    @hook_sprites = []
  end
  
  def create_fire_sprite
    return if not @fire_sprite.nil?
    @fire_sprite = Sprite_Character.new(@viewport1, $game_player.gamefire)
  end
  
  def dispose_fire_sprite
    return if @fire_sprite.nil?
    @fire_sprite.dispose
    @fire_sprite = nil
  end

  def create_water_sprite
    return if not @water_sprite.nil?
    @water_sprite = Sprite_Character.new(@viewport1, $game_player.gamewater)
  end
  
  def dispose_water_sprite
    return if @water_sprite.nil?
    @water_sprite.dispose
    @water_sprite = nil
  end
  
  def create_bomb_sprite
    return if not @bomb_sprite.nil?
    @bomb_sprite = Sprite_Character.new(@viewport1, $game_player.gamebomb)
  end
  
  def dispose_bomb_sprite
    return if @bomb_sprite.nil?
    @bomb_sprite.dispose
    @bomb_sprite = nil
  end
  
  def create_barrel_sprite
    return if not @barrel_sprite.nil?
    @barrel_sprite = Sprite_Character.new(@viewport1, $game_player.gamebarrel)
  end
  
  def dispose_barrel_sprite
    return if @barrel_sprite.nil?
    @barrel_sprite.dispose
    @barrel_sprite = nil
  end
  
  def create_fblight
    return if not @fblight_sprite.nil?
    @fblight_sprite = Sprite_LightEffec.new(@viewport1,
    $game_player.gamebarrel, 2,  5)
  end
  
  def dispose_fblight
    return if @fblight_sprite.nil?
    @fblight_sprite.dispose
    @fblight_sprite = nil
  end
  
  def create_fireligh
    return if not @firelight_sprite.nil?
    @firelight_sprite = Sprite_LightEffec.new(@viewport1,
    $game_player.gamefire, 2,  2)
  end
  
  def dispose_fireligh
    return if @firelight_sprite.nil?
    @firelight_sprite.dispose
    @firelight_sprite = nil
  end
  
  def create_blade_sprite
    return if not @blade_sprite.nil?
    @blade_sprite = Sprite_Character.new(@viewport1, $game_player.gameblade)
  end
  
  def dispose_blade_sprite
    return if @blade_sprite.nil?
    @blade_sprite.dispose
    @blade_sprite = nil
  end
  
  def create_arrow_sprite
    return if not @arrow_sprite.nil?
    @arrow_sprite = Sprite_Character.new(@viewport1, $game_player.gamearrow)
  end
  
  def dispose_arrow_sprite
    return if @arrow_sprite.nil?
    @arrow_sprite.dispose
    @arrow_sprite = nil
  end

  def create_gun_sprite
    return if not @gun_sprite.nil?
    @gun_sprite = Sprite_Character.new(@viewport1, $game_player.gamegun)
    play = $game_player
    #alter the weapon shown, accord
    case play.direction
      when 2 ; create_weapon_show(true,7,10,0,30)
      when 4 ; create_weapon_show(false,-15,10,0,0)
      when 6 ; create_weapon_show(true,15,10,1000,0)
      #when 8 ; create_weapon_show(false,15,10,0,45)
    end
  end

  #Create a weapon sprite along with the bullet 
  def create_weapon_show (mirror, x, y, z, angle)
    @spr = Sprite.new
    @spr.bitmap = Cache.character(FalInt::GunSnipe) 
    dx = ($game_map.adjust_x($game_player.x)*32 ) + x
    dy = ($game_map.adjust_y($game_player.y)*32 ) + y 
    @spr.x = dx 
    @spr.y = dy 
    @spr.z = z  
    @spr.angle = angle 
    @spr.mirror = mirror
    @spr.src_rect = Rect.new( 0 , 0 , 29, 10) 
  end
  
  def dispose_gun_sprite
    if @spr != nil
      @spr.bitmap.dispose
    #  @spr.bitmap.dispose
    #  @spr.bitmap = nil
    #  @spr.dispose
    #  @spr = nil
      
    end
    return if @gun_sprite.nil?
    @gun_sprite.dispose
    @gun_sprite = nil
  end
  
  
 
  alias falcao_intsystem_update_characters update_characters
  def update_characters
    update_int_game_sprites
    falcao_intsystem_update_characters
  end
  
  def update_int_game_sprites
    $game_player.showing_hook   ? create_hook_sprites  : dispose_hook_sprites
    $game_player.showing_bomb   ? create_bomb_sprite   : dispose_bomb_sprite
    $game_player.showing_barrel ? create_barrel_sprite : dispose_barrel_sprite
    $game_player.showing_blade  ? create_blade_sprite  : dispose_blade_sprite
    $game_player.showing_arrow  ? create_arrow_sprite  : dispose_arrow_sprite
    $game_player.showing_gun    ? create_gun_sprite    : dispose_gun_sprite
    if $game_player.showing_fire
      create_fire_sprite
      create_fireligh if $game_map.screen.tone != $game_player.snormal_tone 
    elsif $game_player.showing_water
      create_water_sprite
    else
      dispose_water_sprite
      dispose_fire_sprite
      dispose_fireligh
    end
    $game_player.gamebarrel.fire_duration > 0 ? create_fblight : dispose_fblight
    @hook_sprites.each {|sprite| sprite.update }
    @fire_sprite.update      if not @fire_sprite.nil?
    @water_sprite.update     if not @water_sprite.nil?
    @bomb_sprite.update      if not @bomb_sprite.nil?
    @barrel_sprite.update    if not @barrel_sprite.nil?
    @fblight_sprite.update   if not @fblight_sprite.nil? # fire barrel ligh
    @firelight_sprite.update if not @firelight_sprite.nil?
    @blade_sprite.update     if not @blade_sprite.nil?
    @arrow_sprite.update     if not @arrow_sprite.nil?
    @gun_sprite.update       if not @gun_sprite.nil?
    update_drop_sprites
    @lighesprites.each {|sprite| sprite.update }
  end
  
  # ligh effecs creation
  def create_light_effects
    for event in $game_map.events.values
      direction = event.check_var("LIGHT EFFECT DIRECTION")
      if direction != 0
        intencity = event.check_var("LIGHT EFFECT INTENCITY")
        @lighesprites.push(Sprite_LightEffec.new(@viewport1, 
        event, direction, intencity == 0 ? 1 : intencity))
      end
    end
  end
  
  def dispose_light_effects
    @lighesprites.each {|sprite| sprite.dispose }
    @lighesprites.clear
  end
  
  # easy drop system
  def update_drop_sprites
    for event in $game_map.events.values
      item = event.check_var("DROP ITEM ID")
      if item != 0
        unless @drop_events.include?(event)
          sprite = Sprite_DropItem.new(@viewport1, event, item)
          @drop_sprites.push(sprite)
          @drop_events.push(event)
        end
      end
    end
    for drop in @drop_sprites
      drop.update
      if drop.disposed?
        @drop_sprites.delete(drop)
      end
    end
  end
  
  # drop sprites dispose
  def dispose_drop_sprites
    @drop_sprites.each {|sprite| sprite.dispose }
    @drop_sprites.clear
  end
end

# Ligh effects sprites
class Sprite_LightEffec < Sprite
  def initialize(viewport, character, direction=2, intencity=1)
    super(viewport)
    @character = character
    @character_name = FalInt::LightsGraphic
    @direction = direction
    self.blend_type = 1
    self.z = 2 * 100
    set_character_bitmap
    self.wave_amp = 3
    self.wave_length = 240
    self.wave_speed = 320
    setup_intencity(intencity)
    update
  end
  
  def setup_intencity(intencity)
    case intencity
    when 1 ; @intencity = [zx = 1,   zy = 1,   sx = 0, sy = 0,   opa = 42]
    when 2 ; @intencity = [zx = 1.5, zy = 1.5, sx = 0, sy = 30,  opa = 42]
    when 3 ; @intencity = [zx = 2,   zy = 2,   sx = 0, sy = 60,  opa = 42]
    when 4 ; @intencity = [zx = 2.5, zy = 2.5, sx = 0, sy = 90,  opa = 42]
    when 5 ; @intencity = [zx = 3,   zy = 3,   sx = 0, sy = 120, opa = 42]
    end
    self.zoom_x  = @intencity[0]
    self.zoom_y  = @intencity[1]
    self.opacity = @intencity[4]
  end
  
  def set_character_bitmap
    self.bitmap = Cache.character(@character_name)
    @cw = bitmap.width / 3
    @ch = bitmap.height / 4
    self.ox = @cw / 2 ;  self.oy = @ch
  end

  def update
    super
    self.bush_depth = @character.bush_depth
    update_src_rect
    update_position
  end
  
  def update_position
    if @character.picked
      self.x = $game_player.screen_x + @intencity[2]
      self.y = $game_player.screen_y + @intencity[3]
    else
      self.x = @character.screen_x      + @intencity[2]
      self.y = @character.screen_y + 22 + @intencity[3]
    end
    if @character.is_a?(Game_Event)
      active = @character.check_com("LIGHT EFFECT REQUIRE FLAME")
      self.visible = @character.activate_light if active
    end
    if @character.is_a?(Game_Fire)
      play = $game_player
      case play.direction
      when 2 ; self.x = play.screen_x ;      self.y = play.screen_y + 120
      when 4 ; self.x = play.screen_x - 60 ; self.y = play.screen_y + 65
      when 6 ; self.x = play.screen_x + 60 ; self.y = play.screen_y + 65
      when 8 ; self.x = play.screen_x ;      self.y = play.screen_y + 10
      end
    end
    if @character.is_a?(Game_Water)
      play = $game_player
      case play.direction
      when 2 ; self.x = play.screen_x ;      self.y = play.screen_y + 120
      when 4 ; self.x = play.screen_x - 60 ; self.y = play.screen_y + 65
      when 6 ; self.x = play.screen_x + 60 ; self.y = play.screen_y + 65
      when 8 ; self.x = play.screen_x ;      self.y = play.screen_y + 10
      end
    end
  end
  
  def update_src_rect
    pattern = @character.pattern < 3 ? @character.pattern : 1
    sx = (0 % 4 * 3 + pattern) * @cw
    sy = (0 / 4 * 4 + (@direction - 2) / 2) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
end

# Basic drop sprites
class Sprite_DropItem < Sprite
  def initialize(viewport, event, item)
    super(viewport)
    @event = event
    @item = $data_items[item]
    self.z = @event.screen_z
    @object_zooming = 0
    set_bitmap
    update
    @event.jump(0,0)
  end
  
  def update
    super
    @event.through = true if not @event.through
    @object_zooming += 1
    case @object_zooming
    when 1..10  ; self.zoom_x -= 0.02 ;  self.zoom_y -= 0.02
    when 11..20 ; self.zoom_x += 0.02 ;  self.zoom_y += 0.02
    when 21..30 ; self.zoom_x = 1.0   ;  self.zoom_y = 1.0; @object_zooming = 0 
    end
    self.x = @event.screen_x - 12
    self.y = @event.screen_y - 24
    if @event.x == $game_player.x and @event.y == $game_player.y
      RPG::SE.new("Item1", 80).play
      $game_party.gain_item(@item, 1)
      @event.start
      dispose
    end
  end
  
  def dispose
    self.bitmap.dispose
    self.bitmap = nil
    super
  end
  
  def set_bitmap
    self.bitmap = Bitmap.new(24, 24)
    bitmap = Cache.system("Iconset")
    icon = @item.icon_index
    rect = Rect.new(icon % 16 * 24, icon / 16 * 24, 24, 24)
    self.bitmap.blt(0, 0, bitmap, rect)
  end
end




# Game character base: new methods, variables and public instance variables
class Game_CharacterBase
  attr_accessor   :through
  attr_accessor   :priority_type
  attr_accessor   :opacity
  attr_accessor   :move_speed 
  attr_accessor   :zoom_x
  attr_accessor   :zoom_y
  attr_accessor   :pushed
  attr_accessor   :direction_fix
  attr_accessor   :x
  attr_accessor   :y
  attr_accessor   :picked
  attr_accessor   :throwed
  attr_accessor   :force_move
  attr_accessor   :obfalling
  attr_accessor   :direction
  attr_accessor   :pushable_busy
  attr_accessor   :inrange
  attr_accessor   :fallbyjump
  attr_accessor   :char_steps
  attr_accessor   :hook_start
  attr_accessor   :fire_start
  attr_accessor   :water_start
  attr_accessor   :activate_light
  attr_accessor   :bush_depth
  attr_accessor   :pattern 
  attr_accessor   :blade_start
  alias falcao_intsystem_base_ini initialize
  def initialize
    @zoom_x = 1.0
    @zoom_y = 1.0
    @pushed = false
    @picked = false
    @throwed = false
    @obfalling = 0
    @char_steps = 0
    @activate_light = false
    falcao_intsystem_base_ini
  end
  
  alias falcao_intsystem_update_stop update_stop
  def update_stop
    char_steps_update if self.is_a?(Game_Player) and $game_player.hooking
    char_steps_update if self.is_a?(Game_Hook) and !$game_player.hooking 
    char_steps_update unless self.is_a?(Game_Player) || self.is_a?(Game_Hook)
    falcao_intsystem_update_stop
  end
  
  def char_steps_update
    if @char_steps > 0 and not moving?
      move_forward ; @char_steps -= 1
    end
  end
  
  alias falcao_intsystem_passable passable?
  def passable?(x, y, d)
    bx = $game_map.round_x_with_direction(x, d)
    by = $game_map.round_y_with_direction(y, d)
    if self.is_a?(Game_Event) || self.is_a?(Game_Player)
      return false if collide_with_bomb(bx, by)
      return false if collide_with_barrel(bx, by)
    end
    falcao_intsystem_passable(x, y, d)
  end
  
  def collide_with_bomb(x, y)
    $game_player.gamebomb.pos_nt?(x, y)
  end
  
  def collide_with_barrel(x, y)
    $game_player.gamebarrel.pos_nt?(x, y)
  end
  
  # Pasable jump: distance measured in tiles, ignore fall terrian tiles
  def jump_passable?(distance, ignore_events=false)
    dir = @direction
    return false if !ignore_events and collide_with_characters?(
    @x + ajustxy(self)[0] * distance, @y + ajustxy(self)[1] * distance)
    
    return true if self.is_a?(Game_Player) and
    $game_map.terrain_tag(@x + ajustxy(self)[0] * distance, 
    @y + ajustxy(self)[1] * distance) == FalInt::FallTag
    
    return true if self.is_a?(Game_Event) and self.check_com("PUSHABLE") and
    $game_map.terrain_tag(@x + ajustxy(self)[0] * distance, 
    @y + ajustxy(self)[1] * distance) == FalInt::FallTag
    
    return true if map_passable?(@x, @y + distance,  dir) and dir == 2
    return true if map_passable?(@x - distance, @y,  dir) and dir == 4
    return true if map_passable?(@x + distance, @y,  dir) and dir == 6
    return true if map_passable?(@x, @y - distance,  dir) and dir == 8
    return false
  end
  
  # sensor 
  def sensor_area?(target, size)
    distance = (@x - target.x).abs + (@y - target.y).abs
    enable   = (distance <= size-1)
    return true if enable
    return false
  end
  
  # Start jump: power measured in tiles
  def start_jump(power)
    player = self.is_a?(Game_Player)
    if player
      RPG::SE.new(FalInt::JumpSe,80).play 
      self.followers.reverse_each do |f|
        break if Input.dir4 == 0
        f.move_toward_player ; f.move_toward_player ; f.move_toward_player
        f.jump(0,  power)  if @direction == 2
        f.jump(- power, 0) if @direction == 4
        f.jump(power,  0)  if @direction == 6
        f.jump(0, - power) if @direction == 8
      end
    end
    jump(0,  power)  if player ? Input.dir4 == 2 : @direction == 2
    jump(- power, 0) if player ? Input.dir4 == 4 : @direction == 4
    jump(power,  0)  if player ? Input.dir4 == 6 : @direction == 6
    jump(0, - power) if player ? Input.dir4 == 8 : @direction == 8
    jump(0, 0) if Input.dir4 == 0 and player
  end
  
  # Jump back: power measured in tiles
  def jump_back(power=1)
    @direction_fix = true
    jump(0, - power)       if @direction == 2
    jump(power, 0)         if @direction == 4
    jump(- power,  0)      if @direction == 6 
    jump(0, power)         if @direction == 8 
    @direction_fix = false
  end
  
  # Jump forward: power measured in tiles
  def jump_forward(power=1)
    jump(0, power)       if @direction == 2 
    jump(- power, 0)     if @direction == 4
    jump(power,  0)      if @direction == 6 
    jump(0, - power)     if @direction == 8 
  end
  
   # Ajust x y: object direction if nil take Input only for player
  def ajustxy(d=nil)
    push_x, push_y =   0,   1 if d.nil? ? Input.dir4 == 2 : d.direction == 2
    push_x, push_y = - 1,   0 if d.nil? ? Input.dir4 == 4 : d.direction == 4
    push_x, push_y =   1,   0 if d.nil? ? Input.dir4 == 6 : d.direction == 6
    push_x, push_y =   0, - 1 if d.nil? ? Input.dir4 == 8 : d.direction == 8
    return [push_x, push_y] if d != nil
    push_x, push_y =   0,   0 if Input.dir4 == 0
    return [push_x, push_y]
  end
  
  # Avoid update game player pattern when required
  alias falcao_intsystem_update_anime_pattern update_anime_pattern
  def update_anime_pattern
    return if self.is_a?(Game_Player) and self.tool_anime > 0
    return if self.is_a?(Game_Blade) and self.action_time > 0
    falcao_intsystem_update_anime_pattern
  end
end

# Game Player
class Game_Player < Game_Character
  include FalInt
  attr_accessor   :pushable
  attr_accessor   :fallhp
  attr_accessor   :allowto_push
  attr_accessor   :enable_jump
  attr_accessor   :working_at
  attr_accessor   :icontrol
  attr_reader     :hookshot     
  attr_reader     :hooking
  attr_reader     :showing_hook
  attr_reader     :gamefire
  attr_reader     :showing_fire
  attr_reader     :gamewater
  attr_reader     :showing_water
  attr_reader     :gamebomb
  attr_reader     :showing_bomb
  attr_reader     :grabing
  attr_accessor   :clear_lights
  attr_reader     :gamebarrel
  attr_reader     :showing_barrel
  attr_reader     :gameblade
  attr_reader     :showing_blade
  attr_reader     :snormal_tone
  attr_accessor   :intreserved_tone
  attr_accessor   :current_tonesv
  attr_reader     :tool_anime
  attr_reader     :gamearrow
  attr_reader     :showing_arrow
  attr_reader     :gamegun
  attr_reader     :showing_gun
  attr_reader     :spr
  
  attr_accessor   :barrelburntime
  # aliasing
  alias falcao_intsystem_ini initialize
  alias falcao_intsystem_update update
  alias falcao_intsystem_get_on_vehicle get_on_vehicle
  alias falcao_intsystem_get_off_vehicle get_off_vehicle
  alias falcao_intsystem_move_by_input move_by_input
  alias falcao_intsystem_start_map_event start_map_event
  alias falcao_intsystem_perform_transfer perform_transfer
  
  def initialize
    int_system_initialize
    falcao_intsystem_ini
  end
  
  def update
    update_intsystem
    falcao_intsystem_update
  end
  
  def int_system_initialize
    @pushable = []
    @eve_fall = []
    @fallhp = 2
    @player_busy = false
    @jump_delay = 0
    @allowto_push = true
    @enable_jump = false
    @pickup_delay = 0
    @standing_pushing = false
    @working_at = {}
    @icontrol = 0
    @grabevents = []
    @clear_lights = false
    @intreserved_tone = [0, nil]
    @tool_anime = 0
    @snormal_tone = GameNormalTone
    initialize_int_tools
  end
  
  def initialize_int_tools
    @hooking = false
    @hookshot = []
    for i in 1..HookLong
      @hookshot.push(Game_Hook.new(i))
    end
    @showing_hook = false
    @gamefire = Game_Fire.new
    @showing_fire = false
    @gamewater = Game_Water.new
    @showing_water = false
    @gamebomb = Game_Bomb.new
    @showing_bomb = false
    @collectargets = []
    @damage_blink = 0
    @gamebarrel = Game_Barrel.new
    @showing_barrel = false
    @barrelburntime = 20
    @gameblade = Game_Blade.new
    @showing_blade = false
    @gamearrow = Game_Arrow.new
    @showing_arrow = false
    @gamegun = Game_Gun.new
    @showing_gun = false
    
  end
  
  def update_intsystem
    update_push_events
    update_falling
    update_pick_up 
    update_sensor_system
    update_hookshot
    update_game_fire
    update_game_water
    update_game_bomb
    update_game_barrel
    update_game_blade
    update_game_arrow
    update_game_gun
    perform_jump if Input.trigger?(ActionKey) and
    !$game_map.interpreter.running? and @enable_jump
    update_int_timing
  end
  
  def update_int_timing
    @jump_delay -= 1   if @jump_delay > 0
    @icontrol   -= 1   if @icontrol > 0
    @tool_anime -= 1   if @tool_anime > 0
    @pattern     = 0   if @tool_anime > 0
  end
  
  #---------------------------------------------------------------------------
  # * Hook Shot action definition
  
  # Trigger this tool
  def hook_action
    if tool_canuse?(HweaponId) and not @showing_hook
      unless character_at_playerpos?
        @hookshot.each do |hook| 
          hook.direction = @direction
          hook.moveto(@x, @y)
          hook.char_steps = hook.index
        end
        @showing_hook = true
        RPG::SE.new(HookActionSe, 80).play
        @tool_anime = 30
      else
        Sound.play_buzzer
      end
    end
  end
  
  def update_hookshot
    hook_action
    return unless @showing_hook
    @hookshot.each do |hook|
      hook.update
      hook.x = @x unless hook_moving?
      hook.y = @y unless hook_moving?
      hook.transparent = true if hook.real_x == @real_x and
      hook.real_y == @real_y
      if !hook_moving? and @showing_hook and hook.index == HookLong and 
        hook.real_x == @real_x and hook.real_y == @real_y and @grabing.nil?
        @showing_hook = false 
      end
      #barrel grabing
      if @gamebarrel.x == hook.x and @gamebarrel.y == hook.y and @grabing.nil?
        unless @gamebarrel.x == @x and @gamebarrel.y == @y
          @gamebarrel.through = true
          @gamebarrel.move_speed = hook.move_speed + 0.5
          @gamebarrel.turn_toward_player
          @gamebarrel.char_steps = hook.index
          @grabing = true
        end
      elsif @grabing != nil
        hook.char_steps = 0
        if @gamebarrel.x == @x and @gamebarrel.y == @y
          @gamebarrel.move_speed = 6
          @gamebarrel.through = false
          @grabing = nil
        end
      end

      $game_map.events.values.each do |event|
        # Hook grab
        if event.check_com("HOOK GRAB")
          @grabevents.push(event) unless @grabevents.include?(event)
          event.direction_fix = false if event.direction_fix
          if event.x == hook.x and event.y == hook.y and @grabing.nil?
            unless event.x == @x and event.y == @y
              @datae_s_t = [event.move_speed, event.through, event.move_type]
              event.through = true
              event.move_speed = hook.move_speed + 0.5
              event.move_type  = 0
              event.turn_toward_player
              event.char_steps = hook.index
              @grabing = true
            end
          elsif @grabing != nil
            hook.char_steps = 0
            if event.x == @x and event.y == @y
              event.move_speed = @datae_s_t[0]
              event.through = @datae_s_t[1]
              event.move_type = @datae_s_t[2]
              @grabing = nil
            end
          end
          
          # hook pull
        elsif event.check_com("HOOK PULL")
          if event.x == @x and event.y == @y
            @move_speed = @data_s_t[0]
            @through = @data_s_t[1]
            @hooking = @showing_hook = false
            hook.priority_type = 2
            break
          end
          if hook.x == event.x and hook.y == event.y and not @hooking
            @data_s_t = [@move_speed, @through]
            @move_speed = hook.move_speed
            @through = @hooking = true
            @char_steps = hook.index
            hook.priority_type = 1
            followers.gather
            RPG::SE.new(HookHookingSe,80).play
          end
        end
          
        # Hook start
        if event.check_com("HOOK START")
          if event.x == hook.x and event.y == hook.y and event.hook_start.nil?
            event.start
            event.hook_start = true
          elsif event.hook_start != nil
            hook.char_steps = 0
            event.hook_start = nil unless hook_moving?
          end
        end
      end
    end
  end
  
  def character_at_playerpos?
    return true if @gamebarrel.x == @x and @gamebarrel.y == @y
    @grabevents.any?{|event| event.x == @x && event.y == @y }
  end
  
  def hook_moving?
    @hookshot.any? {|hook| hook.char_steps > 0 }
  end
  
  def clear_hook
    @hookshot.each {|hook| hook.moveto(-1, -1) }
  end
  
  #---------------------------------------------------------------------------
  # * Flame Thrower action definition
  
  # Trigger this tool
  def game_fire_action
    if tool_canuse?(FweaponId) and not @showing_fire
      if actor.mp >= FlameMpCost
        @gamefire.direction = @direction
        @gamefire.moveto(@x, @y)
        @gamefire.char_steps = 2
        @gamefire.action_time = FlameDuration
        @showing_fire = true
        RPG::SE.new(FlameSoundSe,80).play
        #actor.mp -= FlameMpCost
        @tool_anime = FlameDuration
      else
        Sound.play_buzzer
      end
    end
  end
  
  def update_game_fire
    game_fire_action
    return unless @showing_fire
    @gamefire.update
    @gamefire.action_time -= 1 if @gamefire.action_time > 0
    @showing_fire = false if @gamefire.action_time == 0
    @gamefire.moveto(-1, -1) if @gamefire.action_time == 0
    $game_map.events.values.each do |event|
      if event.fire_start != nil and @gamefire.action_time == 0
        clear_event
        break
      end
      if event.check_com("FLAME START")
        if event.x == @gamefire.x and event.y == @gamefire.y and
          event.fire_start.nil?
          active = event.check_com("LIGHT EFFECT REQUIRE FLAME")
          event.activate_light = true if active
          event.start
          event.fire_start = true
        end
      end
    end
  end
  
  #---------------------------------------------------------------------------
  # * Water Shower action definition
  
  # Trigger this tool
  def game_water_action
    if tool_canuse?(WweaponId) and not @showing_water
      if actor.mp >= FlameMpCost
        @gamewater.direction = @direction
        @gamewater.moveto(@x, @y)
        @gamewater.char_steps = 2
        @gamewater.action_time = WaterDuration
        @showing_water = true
        RPG::SE.new(WaterSoundSe,80).play
        #actor.mp -= FlameMpCost
        @tool_anime = WaterDuration
      else
        Sound.play_buzzer
      end
    end
  end
  
  def update_game_water
    game_water_action
    return unless @showing_water
    @gamewater.update
    @gamewater.action_time -= 1 if @gamewater.action_time > 0
    @showing_water = false if @gamewater.action_time == 0
    @gamewater.moveto(-1, -1) if @gamewater.action_time == 0
    $game_map.events.values.each do |event|
      if event.water_start != nil and @gamewater.action_time == 0
        clear_event
        break
      end
      if event.check_com("WATER START")
        if event.x == @gamewater.x and event.y == @gamewater.y and
          event.water_start.nil?
          event.start
          event.water_start = true
        end
      end
    end
  end

  def clear_event
    $game_map.events.values.each {|event| event.fire_start = nil }
    $game_map.events.values.each {|event| event.water_start = nil }
  end
  
  #---------------------------------------------------------------------------
  # * Bombs action definition
  
  # Trigger this tool
  def game_bomb_action
    if tool_canuse?(BweaponId) and not @showing_bomb
      if $game_party.has_item?($data_items[BcostItemId]) 
        $game_party.consume_item($data_items[BcostItemId])
        @gamebomb.direction = @direction
        @gamebomb.moveto(@x, @y)
        @gamebomb.jump_passable?(1)?@gamebomb.start_jump(1) :@gamebomb.jump(0,0)
        @gamebomb.action_time = BombDuration * 60
        @showing_bomb = true
        @gamebomb.through = false
        RPG::SE.new(BombActionSe,90).play
        @tool_anime = 20
      else
        Sound.play_buzzer
      end
    end
  end
  
  def update_game_bomb
    game_bomb_action
    if @damage_blink > 0
      @damage_blink -= 1 
      self.opacity = (self.opacity + 70) % 160 + 60 if @damage_blink < 30
      self.opacity = 255 if @damage_blink == 0
    end
    return unless @showing_bomb
    @gamebomb.update
    pickup_int_character(@gamebomb)
    @gamebomb.action_time -= 1 if @gamebomb.action_time > 0
    if @gamebomb.action_time == 35
      @gamebomb.picked ? self.animation_id = BombAnimationId : 
      @gamebomb.animation_id = BombAnimationId
    end
    
    # if time is over collect targets to activate them
    if @gamebomb.action_time == 0
      $game_map.events.values.each do |event|
        if @gamebomb.sensor_area?(event, BombImpactArea)
          @collectargets.push(event)
        end
      end
      @collectargets.push(self) if sensor_area?(@gamebomb, BombImpactArea)
      start_bomb_impact
      @showing_bomb = false
    end
  end
  
  # Bomb impact
  def start_bomb_impact
    @collectargets.each do |targets|
      if targets.is_a?(Game_Event)
        self_sw = targets.check_selfsw("BOMB SELF SWITCH")
        if self_sw != nil
          $game_self_switches[[$game_map.map_id, targets.id, self_sw]] = true
        end
      elsif targets.is_a?(Game_Player)
        @damage_blink = 40
      end
    end
    if @damage_blink > 0
      $game_party.members.each {|actor| actor.hp -= BombDamage }
      move_backward
    end
    @collectargets.clear
    @player_busy = @gamebomb.picked = @gamebomb.throwed = false if
    @gamebomb.picked
    removepick_graphic
    @gamebomb.moveto(-1, -1)
  end
  
  #-----------------------------------------------------------------------------
  # * Barrel action definition
  
  # Trigger this tool
  def game_barrel_action
    if tool_canuse?(BAweaponId) and not @showing_barrel
      if $game_party.has_item?($data_items[BarrelItemCost]) 
        $game_party.consume_item($data_items[BarrelItemCost])
        @gamebarrel.direction = @direction
        @gamebarrel.moveto(@x, @y)
        @gamebarrel.jump_passable?(1) ? @gamebarrel.start_jump(1) :
        @gamebarrel.jump(0, 0)
        @showing_barrel = true
        @tool_anime = 20
        RPG::SE.new(BarrelActionSe,80).play
      else
        Sound.play_buzzer
      end
    end
  end
  
  def update_game_barrel
    game_barrel_action
    return unless @showing_barrel
    @gamebarrel.update
    pickup_int_character(@gamebarrel)
    if @gamebarrel.fire_duration > 0
      @gamebarrel.fire_duration -= 1 
      if @gamebarrel.fire_duration == 0
        @gamebarrel.character_name = BarrelGraphicOff
        $game_map.screen.start_tone_change(@current_tonesv, 0) if 
        @intreserved_tone[1] != nil
      end
    end
    if @gamebarrel.x == @gamefire.x and  @gamebarrel.y == @gamefire.y and 
      @gamebarrel.fire_duration == 0
      @gamebarrel.character_name = BarrelGraphicOn
      @gamebarrel.fire_duration = @barrelburntime * 60
      if @intreserved_tone[1] != nil
        @current_tonesv = $game_map.screen.tone
        $game_map.screen.start_tone_change(BarrelScreenTone, 0)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # * Blade action definition
  
  # Trigger this tool
  def game_blade_action
    if tool_canuse?(BladeWeaponId) and not @showing_blade
      @gameblade.direction = @direction
      @gameblade.moveto(@x, @y)
      @showing_blade = true
      @gameblade.action_time = 30
      @tool_anime = @gameblade.action_time
      RPG::SE.new(BladeSoundSe,75, 130).play
    end
  end
  
  def update_game_blade
    game_blade_action
    return unless @showing_blade
    @gameblade.update
    @gameblade.action_time -= 1 if @gameblade.action_time > 0
    @gameblade.move_forward if @gameblade.action_time == 18 
    case @gameblade.action_time
    when 24..30 ; @gameblade.pattern = 0
    when 18..24 ; @gameblade.pattern = 1
    when 1..18 ; @gameblade.pattern = 2
    when 0 ; @showing_blade = false
    end
    for event in $game_map.events.values
      if event.blade_start != nil and @gameblade.action_time == 0
        event.blade_start = nil
        break
      end
      self_sw = event.check_selfsw("BLADE SELF SWITCH")
      if self_sw != nil
        if event.x == @gameblade.x and event.y == @gameblade.y and
          event.blade_start.nil?
          animation = event.check_var("BLADE HIT ANIMATION")
          event.animation_id = animation if animation != 0
          $game_self_switches[[$game_map.map_id, event.id, self_sw]] = true
          event.blade_start = true
        end
      end
    end
  end
  
  #----------------------------------------------------------------------------
  # Arrow
  
  def game_arrow_action
    
    if tool_canuse?(ArrowWeaponId) and not @showing_arrow
      @gamearrow.direction = @direction
      @gamearrow.moveto(@x, @y)
      @showing_arrow = true
      @tool_anime = 20
      @gamearrow.char_steps = ArrowRange
      RPG::SE.new(ArrowActionSe,80).play
    end
  end
  
  def update_game_arrow
    game_arrow_action
    return unless @showing_arrow
    @gamearrow.update
    @showing_arrow = false if @gamearrow.char_steps == 0
    if @gamebomb.x == @gamearrow.x  and @gamebomb.y == @gamearrow.y and
      @gamebomb.char_steps == 0 and @showing_arrow
      @gamebomb.through = true
      @gamebomb.direction = @gamearrow.direction
      @gamebomb.char_steps = @gamearrow.char_steps
    end
    for event in $game_map.events.values
      if event.check_com("ARROW START")
        if event.x == @gamearrow.x and event.y == @gamearrow.y and 
          @gamearrow.char_steps > 0
          event.start
          @gamearrow.char_steps = 0
        end
      end
    end
  end
  
  
  #---------------------------------------------------------------------------
  #----------------------------------------------------------------------------
  # GUN
  
  def game_gun_action
    
    if tool_canuse?(GunWeaponId) and not @showing_gun
      @gamegun.direction = @direction
      @gamegun.moveto(@x, @y)
      @showing_gun = true
      @tool_anime = 20
      @gamegun.char_steps = GunRange
      RPG::SE.new(GunActionSe,80).play
    end
  end
  
  def update_game_gun
    game_gun_action
    return unless @showing_gun
    if @spr != nil
      @spr.bitmap.dispose
      @spr.bitmap = nil
      @spr.dispose
      @spr = nil
    end if
    @gamegun.update
    @showing_gun = false if @gamegun.char_steps == 0   
    if @gamebomb.x == @gamegun.x  and @gamebomb.y == @gamegun.y and
      @gamebomb.char_steps == 0 and @showing_gun
      @gamebomb.through = true
      @gamebomb.direction = @gamegun.direction
      @gamebomb.char_steps = @gamegun.char_steps
    end
    for event in $game_map.events.values
      if event.check_com("GUN START")
        if event.x == @gamegun.x and event.y == @gamegun.y and 
          @gamegun.char_steps > 0
          event.start         
          @gamegun.char_steps = 0
        end
      end
    end
  end
  
  
  #---------------------------------------------------------------------------
  



  # * Tools common actions
  
  # check if equiped tool can be used
  def tool_canuse?(id)
    return false if @obfalling > 0
    return true if !@player_busy and Input.trigger?(ToolActionKey) &&
    !$game_map.interpreter.running? && actor.weapons.include?($data_weapons[id])
    return false
  end
  
  # pick interactive character, apply to bombs and barrel
  def pickup_int_character(char)
    if char.throwed
      if char.force_move != nil and char.jump_passable?(1, true)
        char.start_jump(1) ; char.force_move = nil
      end
      unless char.jumping?
        RPG::SE.new(ThrowSe, 90).play
        @player_busy = char.throwed = false
      end
    end
    return if char.is_a?(Game_Bomb) and char.action_time < 35
    if Input.trigger?(ActionKey) and  char.picked and
      !$game_map.interpreter.running?
      if    char.jump_passable?(4) ;  char.start_jump(4)
      elsif char.jump_passable?(3) ;  char.start_jump(3)
      elsif char.jump_passable?(2) ;  char.start_jump(2)
      else                          ;      char.force_move = true
      end
      char.picked = false
      char.throwed = true
      removepick_graphic ; @tool_anime = 16
    end
    if Input.trigger?(ActionKey) and char.x == @x + ajustxy(self)[0] and
      char.y == @y + ajustxy(self)[1] and !self.moving? and !@player_busy
      RPG::SE.new(PickUpSe, 80).play
      @player_busy = char.picked = true
      applypick_grafhic ; @tool_anime = 16
    end
  end
  
  #---------------------------------------------------------------------------
  # * Push System
  #---------------------------------------------------------------------------
  # Player push event object
  def player_push(event)
    event.turn_away_from_player
    event.jump_back if event.check_com("JUMPBACK") and
    event.pushable_busy.nil? and not event.jump_passable?(1, true)
    if event.passable?(event.x, event.y, @direction) and !event.moving?
      unless event.x == @x and event.y == @y
        event.move_away_from_player
        RPG::SE.new(PushSe,80).play
      end
    end
  end
  
  # Push the target
  def press_target(event, sound=true)
    RPG::SE.new(PressTarget,80).play if sound
    self_sw = event.check_selfsw("TARGET SELF SWITCH")
    if self_sw != nil
      $game_self_switches[[$game_map.map_id, event.id, self_sw]] = true
    end
    switch = event.check_var("TARGET SWITCH")
    $game_switches[switch] = true if switch != 0
    variable = event.check_var("TARGET VARIABLE")
    $game_variables[variable] += 1 if variable != 0
    event.pushed = true
    event.refresh
  end
  
  # Release the target 
  def release_target(event, sound=true)
    RPG::SE.new(ReleaseTarget, 80).play if sound
    self_sw = event.check_selfsw("TARGET SELF SWITCH")
    if self_sw != nil
      $game_self_switches[[$game_map.map_id, event.id, self_sw]] = false
    end
    switch = event.check_var("TARGET SWITCH")
    $game_switches[switch] = false if switch != 0
    variable = event.check_var("TARGET VARIABLE")
    $game_variables[variable] -= 1 if variable != 0
    event.pushed = false
    event.refresh
  end
  
  # Get float info necesary to release a target
  def afloatxy(object)
    push_x, push_y =   0,  - 0.5  if object.direction == 2 # down
    push_x, push_y =   0.5,   0   if object.direction == 4 # left
    push_x, push_y = - 0.5,   0   if object.direction == 6 # right
    push_x, push_y =   0,     0.5 if object.direction == 8 # up
    return [push_x, push_y]
  end
  
  # Update push events
  def update_push_events
    return if @vehicle_getting_on || in_boat? || in_ship? || in_airship?
    for event in $game_map.events.values
      if event.check_com("PUSHABLE") and !self.moving?
        event.direction_fix = false if event.direction_fix
        if event.x == @x + ajustxy[0] and event.y == @y + ajustxy[1]
          player_push(event) 
        end
      end
      
      if event.check_selfsw("TARGET SELF SWITCH") != nil
        event.through = true if not event.through
        event.priority_type = 0 if event.priority_type != 0
        
        # Player push targets
        if @allowto_push
          if event.real_x == @real_x and event.real_y == @real_y and 
            not event.pushed 
            press_target(event, @icontrol == 0)
            @standing_pushing = true
          elsif event.pushed
            if event.real_x == @real_x + afloatxy(self)[0] and 
              event.real_y == @real_y + afloatxy(self)[1]
              release_target(event) 
              @standing_pushing = false
            end
          end
        end
        
        # Barrel presing
        if event.real_x == @gamebarrel.real_x and event.real_y == 
          @gamebarrel.real_y and not event.pushed and !@gamebarrel.picked and
          not @gamebarrel.throwed
          press_target(event, @icontrol == 0) ; @gamebarrel.pushable_busy = true
          @gamebarrel.pevent = event
        elsif event.pushed and event.x == @x + ajustxy(self)[0] and event.y ==
          @y + ajustxy(self)[1] and Input.trigger?(ActionKey) and 
          not @gamebarrel.pushable_busy.nil?
          release_target(event) ; @gamebarrel.pushable_busy = nil
          break
        end
        if @gamebarrel.char_steps > 0 and !@grabing.nil? and 
          !@gamebarrel.pushable_busy.nil?
          release_target(@gamebarrel.pevent) ; @gamebarrel.pushable_busy = nil
        end
        
        @pushable.each do |ev|
          if @grabing.nil?
            ev.through = false if ev.through
          end
          # release a pushed target if the player pick up the object
          if ev.check_com("PICK UP")
            @working_at.delete(ev.id) if !ev.pushable_busy.nil? and
            ev.x == @x + ajustxy(self)[0] and ev.y == @y + ajustxy(self)[1] and
            Input.trigger?(ActionKey)
            if event.pushed and event.x == @x + ajustxy(self)[0] and event.y ==
              @y + ajustxy(self)[1] and Input.trigger?(ActionKey)
              release_target(event)
              break
            end
          end
          
          # events pushing and releasing conditions
          if event.real_x == ev.real_x and event.real_y == ev.real_y and
            not event.pushed and not ev.picked and not ev.throwed
            press_target(event, @icontrol == 0) ; ev.pushable_busy = true
            @working_at[ev.id] = [ev.x, ev.y]
          elsif event.pushed 
            break if event.real_x == ev.real_x and event.real_y == ev.real_y
            if event.real_x == ev.real_x + afloatxy(ev)[0] and 
              event.real_y == ev.real_y + afloatxy(ev)[1] and not ev.picked
              release_target(event) ; ev.pushable_busy = nil
              @working_at.delete(ev.id)
            end
          end
        end
      end
    end
  end
  
  #---------------------------------------------------------------------------
  # * Pick up System  
  #---------------------------------------------------------------------------
  def update_pick_up
    return if @vehicle_getting_on || in_boat? || in_ship? || in_airship?
    @pickup_delay -= 1 if @pickup_delay > 0
    return if @pickup_delay > 0
    for event in $game_map.events.values
      if event.throwed  # if throwed do this
        if event.force_move != nil and event.jump_passable?(1, true)
          event.start_jump(1)
          event.force_move = nil
        end
        
        unless event.jumping?
          RPG::SE.new(ThrowSe,80).play
          self_sw = event.check_selfsw("THROW SELF SWITCH")
          if self_sw != nil
            $game_self_switches[[$game_map.map_id, event.id, self_sw]] = true
            event.refresh
            event.direction = event.page.graphic.direction
            changing = true
          end
          @player_busy = event.throwed = false
          event.jump(0,  0) if changing.nil?
          changing = nil
        end
      end
      
      if event.check_com("PICK UP")
        event.priority_type = 1 if event.priority_type == 0
        event.direction_fix = false if event.direction_fix
        # Throw object
        if Input.trigger?(ActionKey) and  event.picked and
          !$game_map.interpreter.running?
          event.move_speed = @pickevdata[0]
          if    event.jump_passable?(4) ;  event.start_jump(4)
          elsif event.jump_passable?(3) ;  event.start_jump(3)
          elsif event.jump_passable?(2) ;  event.start_jump(2)
          else                          ;  event.force_move = true
          end
          event.picked = false
          event.move_type = @pickevdata[1] 
          event.throwed = true
          removepick_graphic ; @tool_anime = 16
        end
        
        # Pick up object
        if Input.trigger?(ActionKey) and event.x == @x + ajustxy(self)[0] and
          event.y == @y + ajustxy(self)[1] and !event.picked and
          not self.moving? and not @player_busy
          RPG::SE.new(PickUpSe, 80).play
          @pickevdata = [event.move_speed, event.move_type]
          event.move_speed = 6
          event.move_type = 0
          event.priority_type = 1
          @player_busy = event.picked = true
          @pickup_delay = 5
          applypick_grafhic ; @tool_anime = 16
        end
      end
    end
  end
  
  def applypick_grafhic
    if actor_graphic_pickup != nil
      @lastgrain = [@character_name, @character_index]
      @character_name = actor_graphic_pickup
    end
  end
  
  def removepick_graphic
    if @lastgrain != nil
      @character_name = @lastgrain[0]
      @character_index = @lastgrain[1]
      @lastgrain = nil
    end
  end
  
  def actor_graphic_pickup
    name = @character_name.sub("$", "") ; index = @character_index
    graphic_name = "$" + name + "_index" + index.to_s
    graphic = Cache.character(graphic_name) rescue nil
    return graphic_name if graphic != nil
    return nil
  end
  
  #---------------------------------------------------------------------------
  # * Fall System  
  #---------------------------------------------------------------------------
  # events start falling
  def start_falling(event)
    event.obfalling = 1
    event.move_speed = 4.5
    event.through = true
    event.fallbyjump.nil? ? event.move_away_from_player : event.fallbyjump = nil
    RPG::SE.new(FallSe,80).play 
    @eve_fall.push(event) unless @eve_fall.include?(event)
    @eve_fall = @eve_fall.uniq 
    @player_busy = event.picked = false if event.picked
  end
  
  # Player start falling
  def player_start_falling
    $game_map.events.values.each do |event|
      if event.picked and not event.check_com("PUSHABLE")
        start_falling(event) 
      end
    end
    self.through = true
    set_direction(Input.dir4) if Input.dir4 != 0
    self.move_forward if @fallbyjump.nil?
    RPG::SE.new(FallSe,80).play
    @last_speed = self.move_speed 
    self.move_speed = 5
    @obfalling = 100
    if @gamebarrel.picked 
      @player_busy = @gamebarrel.picked = false
      @gamebarrel.jump_back
    end
    if @gamebomb.picked 
      @player_busy = @gamebomb.picked = false
      @gamebomb.jump_back
    end
    removepick_graphic
  end
  
  def update_falling
    return if @vehicle_getting_on || in_boat? || in_ship? || in_airship?
    
    # Events fall 
    for event in $game_map.events.values
      if event.check_com("PUSHABLE") and @grabing.nil?
        
        @pushable.push(event) unless @pushable.include?(event)
        if $game_map.terrain_tag(event.real_x + ajustxy[0], 
          event.real_y + ajustxy[1]) == FallTag  and
          event.real_x == @real_x + ajustxy[0] and 
          event.real_y == @real_y + ajustxy[1] and event.obfalling == 0
          start_falling(event) unless event.moving? and self.moving?
          
        elsif $game_map.terrain_tag(event.real_x, event.real_y) == FallTag and 
          event.obfalling == 0 
          unless event.moving?
            event.fallbyjump = true
            start_falling(event) 
          end
        end
      end
      
      # Events push the player away
      if event.check_com("PUSH THE PLAYER") 
        event.direction_fix = false if event.direction_fix
        if @jump_delay == 0 and @real_x == event.real_x + ajustxy(event)[0] and
          @real_y == event.real_y + ajustxy(event)[1] and @obfalling == 0 and
          not @showing_hook
          @direction = event.direction
          move_forward
          followers.gather
          if jump_passable?(1, ignore_events = true)
            @lastpxy = [@x, @y]
            jump_forward(1) ; @jump_delay = 20
          end
        end
      end
    end
    
    # event falling effect
    @eve_fall.each do |ev| 
      if ev.obfalling > 0
        ev.zoom_x -= 0.06
        ev.zoom_y -= 0.06
        if ev.zoom_x <= 0.06  and !ev.erased
          switch = ev.check_var("FALL SWITCH")
          $game_switches[switch] = true if switch != 0
          variable = ev.check_var("FALL VARIABLE")
          $game_variables[variable] += 1 if variable != 0
          event.refresh if switch != 0 || variable != 0
          ev.erase 
          @eve_fall.delete_if { |e| e == ev }
          event.obfalling = 0
        end
      end
    end
  
   # followes fall with the player
    self.followers.reverse_each do |f| 
      if @obfalling > 0
        f.zoom_x = @zoom_x
        f.zoom_y = @zoom_y
        f.move_toward_player ; f.move_toward_player ; f.move_toward_player
      end
    end
  
    unless @showing_hook
      if $game_map.terrain_tag(@real_x, @real_y) == FallTag and 
        @obfalling == 0 and not moving? and not jumping?
        @fallbyjump = true
        player_start_falling
      elsif $game_map.terrain_tag(@real_x + ajustxy[0], @real_y + ajustxy[1]) ==
        FallTag and @obfalling == 0 and !self.moving?
        player_start_falling
      end
    end
    
    if @obfalling > 0
      @obfalling -= 1
      if @obfalling > 30 and @obfalling < 100
        self.zoom_x -= 0.06; self.zoom_y -= 0.06
      end
      if @obfalling == 40
        @fallbyjump.nil? ? self.move_backward : moveto(@lastpxy[0],
        @lastpxy[1]) rescue nil
        @fallbyjump = nil
      end
      if @obfalling == 30
        self.zoom_x = 1.0
        self.zoom_y = 1.0
        $game_party.members.each do |actor|
          actor.hp -= @fallhp
        end
      end
      self.through = false if @obfalling == 15
      self.opacity = (self.opacity + 70) % 160 + 60 if @obfalling < 40
      self.opacity = 255 if @obfalling == 0
      self.move_speed = @last_speed if @obfalling == 0
    end
  end
  
  #---------------------------------------------------------------------------
  # * Jump System 
  #---------------------------------------------------------------------------
  def perform_jump
    return if @standing_pushing || self.jumping? || @obfalling > 0 ||
    in_airship? || @vehicle_getting_on || in_boat? || in_ship? ||
    @jump_delay > 0 || @player_busy || @showing_hook || @showing_fire || @showing_water
    $game_map.events.values.each do |event|
      if event.pushed
        return if event.x == @x and event.y == @y
        if event.x == @x + ajustxy(self)[0] and event.y == @y + ajustxy(self)[1]
          return
        end
      end
    end
    @lastpxy = [@x, @y]
    if    jump_passable?(2)  ;   start_jump(2)
    elsif jump_passable?(1)  ;   start_jump(1)
    else                     ;   start_jump(0)            
    end
    @jump_delay = 16
  end
  
  #---------------------------------------------------------------------------
  # * Sensor Vision System
  #---------------------------------------------------------------------------
  def update_sensor_system
    $game_map.events.values.each do |event|
      range = event.check_var("SENSOR VISION RANGE")
      if range != 0
        if sensor_area?(event, range)
          data = [$game_map.map_id, event.id, SensorSelfsw]
          if event.inrange.nil? and !$game_self_switches[[data[0], data[1],
            data[2]]]
            $game_self_switches[[data[0], data[1], data[2]]] = true
            event.inrange = true
          end
        elsif event.inrange != nil
          data = [$game_map.map_id, event.id, SensorSelfsw]
          if $game_self_switches[[data[0], data[1], data[2]]]
            $game_self_switches[[data[0], data[1], data[2]]] = false
            event.inrange = nil
          end
        end
      end
    end
  end

  #-----------------------------------------------------------------------------
  #                   * Flow control
  #-----------------------------------------------------------------------------
  def get_on_vehicle
    return if @player_busy 
    falcao_intsystem_get_on_vehicle
  end
  
  def get_off_vehicle
    return if $game_map.terrain_tag(@x, @y) == FallTag
    falcao_intsystem_get_off_vehicle
  end
  
  def move_by_input
    return if @obfalling > 0 || @showing_hook || @showing_fire|| @showing_water || @tool_anime > 0
    falcao_intsystem_move_by_input
  end
  
  def start_map_event(x, y, triggers, normal)
    $game_map.events_xy(x, y).each do |ev|
      return if ev.check_selfsw("TARGET SELF SWITCH") != nil || ev.check_com("FLAME START") || ev.check_com("ARROW START") || ev.check_com("GUN START") || ev.check_com("WATER START") || ev.check_com("HOOK START")
    end  
    falcao_intsystem_start_map_event(x, y, triggers, normal)
  end
  
  # refresh all the system if the map is not the same
  def perform_transfer
    if $game_map.map_id !=  @new_map_id
      refresh_falcao_int_system 
      @clear_lights = true
      @working_at = {} ; @grabevents = []
      if @showing_barrel and not @gamebarrel.picked
        @showing_barrel = false
        @gamebarrel.moveto(-1, -1)
        @gamebarrel.fire_duration  = 0; @gamebarrel.pushable_busy = nil
        @gamebarrel.character_name = BarrelGraphicOff
      end
      if @showing_bomb and not @gamebomb.picked
        @gamebomb.action_time = 0
        @showing_bomb = false
        @gamebomb.moveto(-1, -1)
      end
      @gamearrow.char_steps = 0 if @showing_arrow 
      @showing_arrow = false if @showing_arrow 
      @gamegun.char_steps = 0 if @showing_gun 
      @showing_gun = false if @showing_gun 
      
    end
    falcao_intsystem_perform_transfer
  end
  
  # Execute refresh
  def refresh_falcao_int_system
    @pushable = [];  @eve_fall = []
    @standing_pushing = false
    @player_busy = false unless @gamebomb.picked || @gamebarrel.picked
    for event in $game_map.events.values
      event.throwed = false if event.throwed
      if event.picked
        event.move_speed = @pickevdata[0]
        event.move_type  = @pickevdata[1]
        event.picked = false 
        removepick_graphic
      end
      event.pushable_busy = nil if event.pushable_busy != nil
      release_target(event, sound = false) if event.pushed
    end
  end
  
  def dark_nextmap
    @intreserved_tone[0] = 1
  end
  
  def normal_nextmap
    @intreserved_tone[0] = 2
  end
end

# Game Event: Commands comments definition
class Game_Event < Game_Character
  attr_reader    :erased
  attr_reader    :page
  attr_accessor  :move_type
  def check_com(comment)
    return false if @list.nil? or @list.size <= 0
    for item in @list
      if item.code == 108 or item.code == 408
        if item.parameters[0].include?(comment)
          return true
        end
      end
    end
    return false
  end
  
  def check_var(comment)
    return 0 if @list.nil? or @list.size <= 0
    for item in @list
      if item.code == 108 or item.code == 408
        if item.parameters[0] =~ /#{comment}[ ]?(\d+)?/
          return $1.to_i
        end
      end
    end
    return 0
  end
  
  def check_selfsw(comment)
    return nil if @list.nil? or @list.size <= 0
    for item in @list
      next unless item.code == 108 or item.code == 408
      if item.parameters[0] =~ /#{comment} (.*)/
        return $1.to_s
      end
    end
    return nil
  end
end

# Sprite character
class Sprite_Character < Sprite_Base
  alias falcao123_zoom_update update
  def update
    falcao123_zoom_update
    if @zoom_x != @character.zoom_x or
      @zoom_y != @character.zoom_y
      @zoom_x = @character.zoom_x
      @zoom_y = @character.zoom_y      
      self.zoom_x = @character.zoom_x
      self.zoom_y = @character.zoom_y
    end  
  end

  alias falcao_intsystem_update_position update_position
  def update_position
    falcao_intsystem_update_position
    update_int_characters_positions
  end
  
  def update_int_characters_positions
    play = $game_player
     
    # Objects fixed to player position
    if @character.picked
      case play.direction
      when 2 ; self.x = play.screen_x + 5; self.y = play.screen_y - 5; self.z = 101
      when 4 ; self.x = play.screen_x - 10 ; self.y = play.screen_y - 10; self.z = 101
      when 6 ; self.x = play.screen_x + 10 ; self.y = play.screen_y - 10; self.z = 0
      when 8 ; self.x = play.screen_x - 5; self.y = play.screen_y - 15; self.z = 0
      end
      @character.direction = play.direction
      @character.x = play.x
      @character.y = play.y
      
      @character.bush_depth = 0
    end
    
    if @character.is_a?(Game_Hook)
      case play.direction
      when 2 ; self.x = self.x        ; self.y = self.y + 2
      when 4 ; self.x = self.x - 4    ; self.y = self.y
      when 6 ; self.x = self.x + 4    ; self.y = self.y
      when 8 ; self.x = self.x        ; self.y = self.y - 6
      end
    end
    
    if @character.is_a?(Game_Fire)
      case play.direction
      when 2; self.x = play.screen_x      ; self.y = play.screen_y + 90 # Down
      when 4; self.x = play.screen_x - 49 ; self.y = play.screen_y + 41 # Left
      when 6; self.x = play.screen_x + 49 ; self.y = play.screen_y + 41 # Right
      when 8; self.x = play.screen_x      ; self.y = play.screen_y - 20 # Up
      end
    end

    if @character.is_a?(Game_Water)
      case play.direction
      when 2; self.x = play.screen_x      ; self.y = play.screen_y + 90 # Down
      when 4; self.x = play.screen_x - 49 ; self.y = play.screen_y + 41 # Left
      when 6; self.x = play.screen_x + 49 ; self.y = play.screen_y + 41 # Right
      when 8; self.x = play.screen_x      ; self.y = play.screen_y - 20 # Up
      end
    end

    if @character.is_a?(Game_Blade)
      self.x = play.screen_x
      self.y = play.screen_y
    end
  end
end

class << DataManager

  # Refresh the system if saving
  alias falcao_intsystem_save_game save_game unless $@
  def DataManager.save_game(index)
    $game_player.refresh_falcao_int_system
    $game_player.icontrol = 10
    falcao_intsystem_save_game(index)
  end
  
  # Tell the system to repositioning the working events, if game is updated
  alias falcao_intsystem_mapreload reload_map_if_updated unless $@
  def DataManager.reload_map_if_updated
    if $game_system.version_id != $data_system.version_id
      $game_player.icontrol = 10
    end
    falcao_intsystem_mapreload
  end
end

# Add to array all pushable events
class Game_Map
  alias falcao_intsystem_setup_events setup_events
  def setup_events(*args, &block)
    falcao_intsystem_setup_events(*args, &block)
    @events.values.each do |event|
      $game_player.pushable.push(event) if event.check_com("PUSHABLE")
      
      # Execute event repositioning
      if $game_player.icontrol > 0
        $game_player.working_at.each do |id , value|
          event.moveto(value[0], value[1]) if id == event.id
        end
      end
    end
  end
  
  # avoid damage floor when hooking
  alias falcao_intsystem_damage_floor damage_floor?
  def damage_floor?(x, y)
    return if $game_player.showing_hook
    falcao_intsystem_damage_floor(x, y)
  end
  
  def lighactive(event_id, value)
    @events[event_id].activate_light = value
  end
end

# Avoid tranfer in some situatios
class Game_Interpreter
  alias falcao_intsystem_command_201 command_201
  def command_201
    return if $game_player.showing_hook || $game_player.showing_fire || $game_player.showing_water
    falcao_intsystem_command_201
  end
end

# While grabing object you cannot enter menu
class Scene_Map < Scene_Base
  alias falcao_intsystem_update_call_menu update_call_menu
  def update_call_menu
    return if $game_player.grabing != nil
    falcao_intsystem_update_call_menu
  end
end
