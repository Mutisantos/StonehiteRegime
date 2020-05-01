#------------------------------------------------------------------------------#
#  Galv's Character Effects
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 2.1
#------------------------------------------------------------------------------#
#  2014-01-16 - Version 2.1 - Fixed double balloon/animation bug with shadows
#  2013-12-07 - Version 2.0 - Added comments to more easily add event effects
#                           - Fixed shadow facing bug
#  2013-02-24 - Version 1.9 - added z level option for reflection and shadows
#  2013-02-23 - Version 1.8 - added multiple light sources for shadows
#  2013-02-22 - Version 1.7 - bug fixes
#  2013-02-22 - Version 1.6 - added icon effect
#  2013-02-22 - Version 1.5 - fixed mirror bug on large maps
#  2013-02-22 - Version 1.4 - added effects to vehicles
#  2013-02-21 - Version 1.3 - fixed jump reflection and other minor tweaks
#  2013-02-21 - Version 1.2 - bug with less than 4 actors (oops)
#  2013-02-21 - Version 1.1 - updated flicker effect
#  2013-02-21 - Version 1.0 - release
#------------------------------------------------------------------------------#
#  This script was made to provide some additional effects for characters such
#  as events, followers and the player on the map.
#  Currently it includes:
#
#  Shadows
#  Shadows that appear under player and events in a directions depending on
#  a light source that you choose.
#
#  Parallax Reflect
#  Reflections that appear on the parallax layer for events and actors to be
#  used for things like reflections in the water or glass floor etc. To get
#  effects like the demo, you need to edit the charset graphic to make the water
#  partially transparent.
#
#  Parallax Mirrors
#  Much like reflect but are instead actors and event are reflected in a mirror
#  on a wall designated by a region. Both mirror and reflect effects can be
#  changed so actors and events can use different charsets for their reflections
#
#------------------------------------------------------------------------------#
 

#------------------------------------------------------------------------------#
#  NEW - First event command as a COMMENT
#------------------------------------------------------------------------------#
#  You can add a comment as the first event command on an event page to set if
#  that event has an icon, shadow or reflection active. The tags to use are
#  below, all must be on the same line in the comment.
#
# <icon:id,x,y>      # set the event to display an icon (x,y position offset)
# <shadow>           # set the event to display a shadow
# <reflect>          # set the event to display reflections
#
#------------------------------------------------------------------------------#
#  EXAMPLE:
# <icon:1,0,0><shadow><reflect>    # to show reflect, shadow and icon 1 on event
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
#  SCRIPT CALLS:
#------------------------------------------------------------------------------#
#
#  char_effects(x,x,x,status)
#
#------------------------------------------------------------------------------#
#  # each effect can be true or false to enable/disable them during the game.
#  # you can change multiples of effects at once, x being the effect number
#  # 0 = reflect    1 = shadows    2 = mirror    3 = icons
#------------------------------------------------------------------------------#
#  EXAMPLES:
#  char_effects(0,true)              # turn reflections on
#  char_effects(0,2,true)            # turn reflections and mirror on
#  char_effects(1,3,false)           # turn shadows and icons off
#------------------------------------------------------------------------------#
#
#  reflect_sprite(actor_id,filename,pos)    # Change actor's reflect charset
#
#  reflect_esprite(event_id,filename,pos)   # Change event's reflect charset
#
#  reflect_vsprite(vehicle_id,filename,pos) # Change vehicle's reflect charset
#
#------------------------------------------------------------------------------#
#  EXAMPLES:
#  reflect_sprite(1,"Actor2",2)      # change actor 1's charset to use sprite
#                                    # in position 2 of "Actor2" charset.
#  reflect_esprite(3,"Actor4",5)     # event 3 will use sprite in position 5 of
#                                    # "Actor4" charset.
#  reflect_vsprite(1,"Vehicle",5)    # Ship will use sprite in position 5 of
#                                    # "Vehicle" charset.
#------------------------------------------------------------------------------#
 
#------------------------------------------------------------------------------#
#  SCRIPT CALLS to turn effects ON or OFF for chosen EVENTS
#------------------------------------------------------------------------------#
#
#  reflect(x,x,x,status)   # status can be true or false to turn on or off
#                          # use this to specify for mirror and reflect.
#  shadow(x,x,x,status)    # where x is the event ids you want to change
#                          # to change all events use :all
#  icon(x,x,x,icon_id)     # set which icon id to appear above character. Make
#                          # it 0 for no icon.
#
#------------------------------------------------------------------------------#
#  EXAMPLES:
#  reflect(14,17,3,1,true) # Turn events 14, 17, 3 and 1 reflections ON
#  shadow(1,false)         # Turn event 1 shadow OFF
#  reflect(:all,true)      # Turn all event reflections ON
#  icon(1,2,3,4,38)        # Events 1,2,3 and 4 will have icon 38 appear
#
#  NOTE: All events will default to NO shadows and NO reflections when entering
#        a map. This is a design decision to try to keep lag to a minimum. You
#        should use these effects sparingly and only activate them on events
#        that require them.
#------------------------------------------------------------------------------#
 
#------------------------------------------------------------------------------#
#  SCRIPT CALLS to turn effects ON or OFF for ACTORS and VEHICLES
#------------------------------------------------------------------------------#
#
#  actor_reflect(actor_id,status)  # reflections and shadows are ON by default 
#  actor_shadow(actor_id,status)   # for actors and vehicles. Turning them off 
#  actor_icon(actor_id,icon_id)    # or on will permanently change them.
#
#  v_reflect(x,x,x,status)    # use these v_ calls for changing vehicle effects
#  v_shadow(x,x,x,status)     # on and off for vehicles.
#  v_icon(x,x,x,icon_id)
#
#------------------------------------------------------------------------------#
 
#------------------------------------------------------------------------------#
#  SCRIPT CALLS for shadow options
#------------------------------------------------------------------------------#
#
#  shadow_source(x,y,id)       # set the x,y location for the light. id is the 
#                              # light source number you wish to change (for
#                              # more than one). These are reset on map change.
#  shadow_source(event_id,id)  # use an event's x,y location for the light.
#                              # This will need to be in parallel process if you
#                              # want it to be a moving light.
#
#  shadow_options(intensity,fade,flicker)    # descriptions below
#
#    # intensity = opacity when standing next to the light source (255 is black)
#    # fade = amount shadow becomes more transparent the further away you are.
#    # flicker = true or false. Shadows will flicker as if being cast by fire.
#
#------------------------------------------------------------------------------#
#  EXAMPLE:
#  shadow_options(80,10,false)    # This is the default setting.
#------------------------------------------------------------------------------#
 
#------------------------------------------------------------------------------#
#  SCRIPT CALLS for reflect options
#------------------------------------------------------------------------------#
#
#  reflect_options(wave_pwr) 
#
#    # wave_pwr = how strong the wave movement is. 0 is off
#
#------------------------------------------------------------------------------#
#  EXAMPLE:
#  reflect_options(1) # Turn wave power to 1
#------------------------------------------------------------------------------#
 
 
#------------------------------------------------------------------------------#
#  NOTETAG for ACTORS
#------------------------------------------------------------------------------#
#
#  <no_reflect>    # Actor will not have a reflection (for vampires of course!)
#
#  <reflect_sprite: FileName,pos>  # Actor will use this charset for reflections
#                                  # and use the character in position 'pos'
#
#------------------------------------------------------------------------------#
#  EXAMPLES:
#  <reflect_sprite: Actor2,0>    # The first character from Actor2 charset
#  <reflect_sprite: Actor3,7>    # The last character from Actor2 charset
#------------------------------------------------------------------------------#
 
 
($imported ||= {})["Galv_Character_Effects"] = true
module Galv_CEffects
 
#------------------------------------------------------------------------------#  
#  SETUP OPTIONS
#------------------------------------------------------------------------------#
 
  MIRROR_REGION = 1     # Region ID used to determine mirror walls. Paint the
                        # region on the wall you want to make reflective (and
                        # then use tiles/mapping that make the parallax visible)
 
  ICON_OFFSET = -60     # Y offset for icons that are displayed above characters
   
  REFLECT_Z = -10       # Z level of reflections
  SHADOW_Z = 0          # Z level of shadows
 
#------------------------------------------------------------------------------#  
#  END SETUP OPTIONS
#------------------------------------------------------------------------------#
end
 
 


class Game_Map
  def do_icons(refresh = true)
    @events.values.each { |e|
      next if !e.list
      if e.list[0].code == 108 && e.list[0].parameters[0] =~ /<icon:(.*),(.*),(.*)>/
        e.icon = $1.to_i
        e.icon_offset = [$2.to_i,$3.to_i]
      else
        e.icon = 0
        e.icon_offset = [0,0]
      end
    }
    SceneManager.scene.spriteset.refresh_effects if refresh
  end
  
  
  def do_shadows(refresh = true)
    @events.values.each { |e|
      next if !e.list
      if e.list[0].code == 108 && e.list[0].parameters[0] =~ /<shadow>/
        e.shadow = true
      else
        e.shadow = false
      end
    }
    SceneManager.scene.spriteset.refresh_effects if refresh
  end
  
  def do_reflects(refresh = true)
    @events.values.each { |e|
      next if !e.list
      if e.list[0].code == 108 && e.list[0].parameters[0] =~ /<reflect>/
        e.reflect = true
      else
        e.reflect = false
      end
    }
    SceneManager.scene.spriteset.refresh_effects if refresh
  end
  
  def do_all_chareffects
    do_icons(false)
    do_shadows(false)
    do_reflects(false)
  end
  
end # Game_Map



 
class Game_Interpreter
  
  def remove_icon
    icon(@event_id,0)
  end
 
#-----------------------------------#
#  REFLECTIONS
#-----------------------------------#
 
  # Add/Remove Reflections from selected events
  def reflect(*args,status)
    char_ids = [*args]
    if char_ids == [:all]
      $game_map.events.values.each { |e| e.reflect = status }
    else
      char_ids.each {|c| $game_map.events[c].reflect = status }
    end
    SceneManager.scene.spriteset.refresh_effects
  end
   
  # Change forever actor's reflect status
  def actor_reflect(actor_id,status)
    $game_actors[actor_id].reflect = status
    $game_player.refresh
  end
   
  # Change forever vehicle's reflect status
  def v_reflect(*args,status)
    char_ids = [*args]
    if char_ids == [:all]
      $game_map.vehicles.each { |v| v.reflect = status }
    else
      char_ids.each { |v| $game_map.vehicles[v].reflect = status }
    end
    SceneManager.scene.spriteset.refresh_effects
  end
 
  def reflect_options(*args)
    $game_map.reflect_options = [*args]
    SceneManager.scene.spriteset.refresh_effects
  end
   
  # Actor reflect sprite change
  def reflect_sprite(actor_id,filename,pos)
    $game_actors[actor_id].reflect_sprite = [filename,pos]
    $game_player.refresh
  end
   
  # Event reflect sprite change
  def reflect_esprite(event_id,filename,pos)
    $game_map.events[event_id].reflect_sprite = [filename,pos]
    $game_map.events[event_id].reflect = true
    SceneManager.scene.spriteset.refresh_characters
  end
   
  # Vehicle reflect sprite change
  def reflect_vsprite(v_id,filename,pos)
    $game_map.vehicles[v_id].reflect_sprite = [filename,pos]
    SceneManager.scene.spriteset.refresh_characters
  end
 
#-----------------------------------#
#  SHADOWS
#-----------------------------------#
 
  # Add/Remove Shadows from selected characters
  def shadow(*args,status)
    char_ids = [*args]
    if char_ids == [:all]
      $game_map.events.values.each { |e| e.shadow = status }
    else
      char_ids.each {|c| $game_map.events[c].shadow = status }
    end
    SceneManager.scene.spriteset.refresh_effects
  end
   
  # Change player and follower shadows
  def actor_shadows(status)
    $game_player.shadow = status
    $game_player.followers.each { |f| f.shadow = status }
    SceneManager.scene.spriteset.refresh_effects
  end
   
  # Change vehicle's shadow status
  def v_shadow(*args,status)
    char_ids = [*args]
    if char_ids == [:all]
      $game_map.vehicles.each { |v| v.shadow = status }
    else
      char_ids.each { |v| $game_map.vehicles[v].shadow = status }
    end
    SceneManager.scene.spriteset.refresh_effects
  end
   
  def shadow_options(*args)
    $game_map.shadow_options = [*args]
    SceneManager.scene.spriteset.refresh_effects
  end
 
  def shadow_source(*args,shad_id)
    shadsource = [*args]
 
    if shadsource.count == 1
      $game_map.light_source[shad_id] = [$game_map.events[shadsource[0]].real_x,
        $game_map.events[shadsource[0]].real_y]
    elsif shadsource.count > 1
      $game_map.light_source[shad_id] = shadsource
    else
      $game_map.light_source = []
    end
  end
 
 
#-----------------------------------#
#  ICONS
#-----------------------------------#
 
  # Add/Remove Icons from selected events
  def icon(*args,icon_id)
    char_ids = [*args]
    if char_ids == [:all]
      $game_map.events.values.each { |e|
      if e.icon <= 0
        e.icon = nil
      else
        e.icon = icon_id
      end
    }
    else
      char_ids.each {|c| $game_map.events[c].icon = icon_id }
    end
    SceneManager.scene.spriteset.refresh_effects
  end
   
  # Change forever actor's icon
  def actor_icon(actor_id,icon_id)
    $game_actors[actor_id].icon = icon_id
    $game_player.refresh
  end
   
  # Change forever vehicle's icon
  def v_icon(*args,icon_id)
    char_ids = [*args]
    if char_ids == [:all]
      $game_map.vehicles.each { |v| v.icon = icon_id }
    else
      char_ids.each { |v| $game_map.vehicles[v].icon = icon_id }
    end
    SceneManager.scene.spriteset.refresh_effects
  end
 
#-----------------------------------#
#  GENERAL
#-----------------------------------#
 
  # Turn on/off effects
    # 0 = reflect
    # 1 = shadow
    # 2 = mirror
    # 3 = icon
     
  def char_effects(*args,status)
    [*args].each { |e| $game_map.char_effects[e] = status }
    SceneManager.scene.spriteset.refresh_effects
  end
 
   
end # Game_Interpreter
 
 
#-------------------------------------------------------------------------------
#  Spriteset_Map
#-------------------------------------------------------------------------------
 
class Spriteset_Map
  alias galv_reflect_sm_initialize initialize
  def initialize
    create_effects
    galv_reflect_sm_initialize
    refresh_characters
  end
   
  alias galv_reflect_sm_refresh_characters refresh_characters
  def refresh_characters
    galv_reflect_sm_refresh_characters
    create_effects
  end
   
  def refresh_effects
    dispose_effects
    create_effects
  end
   
  def create_effects
    @shadow_sprites = []
    @reflect_sprites = []
    @mirror_sprites = []
    @icon_sprites = []
     
    # Do reflections
    if $game_map.char_effects[0]
      $game_map.events.values.each { |e|
        @reflect_sprites.push(Sprite_Reflect.new(@viewport1, e)) if e.reflect
      }
      $game_player.followers.each { |f|
        @reflect_sprites.push(Sprite_Reflect.new(@viewport1, f)) if f.reflect
      }
      if $game_player.reflect
        @reflect_sprites.push(Sprite_Reflect.new(@viewport1, $game_player))
      end
      $game_map.vehicles.each { |v|
        @reflect_sprites.push(Sprite_Reflect.new(@viewport1, v)) if v.reflect
      }
    end
     
    # Do mirrors
    if $game_map.char_effects[2]
      $game_map.events.values.each { |e|
        @mirror_sprites.push(Sprite_Mirror.new(@viewport1, e)) if e.reflect
      }
      $game_player.followers.each { |f|
        @mirror_sprites.push(Sprite_Mirror.new(@viewport1, f)) if f.reflect
      }
      if $game_player.reflect
        @mirror_sprites.push(Sprite_Mirror.new(@viewport1, $game_player))
      end
      $game_map.vehicles.each { |v|
        @mirror_sprites.push(Sprite_Mirror.new(@viewport1, v)) if v.reflect
      }
    end
     
    # Do Shadows
    if $game_map.char_effects[1]
      return if $game_map.light_source.empty?
      $game_map.light_source.count.times { |s|
        $game_map.events.values.each { |e|
          @shadow_sprites.push(Sprite_Shadow.new(@viewport1, e, s)) if e.shadow
        }
        $game_player.followers.each { |f|
          @shadow_sprites.push(Sprite_Shadow.new(@viewport1, f, s)) if f.shadow
        }
        if $game_player.shadow
          @shadow_sprites.push(Sprite_Shadow.new(@viewport1, $game_player, s))
        end
        $game_map.vehicles.each { |v|
          @shadow_sprites.push(Sprite_Shadow.new(@viewport1, v, s)) if v.shadow
        }
      }
    end
     
    # Do icons
    if $game_map.char_effects[3]
      $game_map.events.values.each { |e|
        @icon_sprites.push(Sprite_Icon.new(@viewport1, e)) if e.icon
      }
      $game_player.followers.each { |f|
        @icon_sprites.push(Sprite_Icon.new(@viewport1, f)) if f.icon
      }
      if $game_player.icon
        @icon_sprites.push(Sprite_Icon.new(@viewport1, $game_player))
      end
      $game_map.vehicles.each { |v|
        @icon_sprites.push(Sprite_Icon.new(@viewport1, v)) if v.icon
      }
    end
  end
   
  alias galv_reflect_sm_update update
  def update
    galv_reflect_sm_update
    @reflect_sprites.each {|s| s.update} if $game_map.char_effects[0]
    @mirror_sprites.each {|s| s.update} if $game_map.char_effects[2]
    @shadow_sprites.each {|s| s.update} if $game_map.char_effects[1]
    @icon_sprites.each {|s| s.update} if $game_map.char_effects[3]
  end
 
  alias galv_reflect_sm_dispose_characters dispose_characters
  def dispose_characters
    galv_reflect_sm_dispose_characters
    dispose_effects
  end
   
  def dispose_effects
    @reflect_sprites.each {|s| s.dispose}
    @shadow_sprites.each {|s| s.dispose}
    @mirror_sprites.each {|s| s.dispose}
    @icon_sprites.each {|s| s.dispose}
  end
end # Spriteset_Map
 
 
#-------------------------------------------------------------------------------
#  Sprite_Reflect 
#-------------------------------------------------------------------------------
 
class Sprite_Reflect < Sprite_Character
  def initialize(viewport, character = nil)
    super(viewport, character)
  end
 
  def update
    super
  end
   
  def update_balloon; end
  def setup_new_effect; end
   
  def set_character_bitmap
    if @character.reflect_sprite
      self.bitmap = Cache.character(@character.reflect_sprite[0])
    else
      self.bitmap = Cache.character(@character_name)
    end
    self.mirror = true
    self.angle = 180
    self.opacity = 220
    self.z = Galv_CEffects::REFLECT_Z
    self.wave_amp = $game_map.reflect_options[0]
     
    sign = @character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
    else
      @cw = bitmap.width / 12
      @ch = bitmap.height / 8
    end
    self.ox = @cw / 2
    self.oy = @ch
  end
 
  def update_position
    self.x = @character.screen_x
    jump = @character.jumping? ? @character.jump_height * 2 : 0
    alt = @character.altitude ? @character.altitude * 2 : 0
    self.y = @character.screen_y - 3 + jump + alt
  end
 
  def update_other
    self.blend_type = @character.blend_type
    self.visible = !@character.transparent
  end
   
  def update_src_rect
    if @character.reflect_sprite
      index = @character.reflect_sprite[1]
    else
      index = @character.character_index
    end
    pattern = @character.pattern < 3 ? @character.pattern : 1
    sx = (index % 4 * 3 + pattern) * @cw
    sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
end # Sprite_Reflect < Sprite_Character
 
 
#-------------------------------------------------------------------------------
#  Sprite_Mirror
#-------------------------------------------------------------------------------
 
class Sprite_Mirror < Sprite_Character
  def initialize(viewport, character = nil)
    @distance = 0
    super(viewport, character)
  end
 
  def update
    super
  end
   
  def update_balloon; end
  def setup_new_effect; end
   
  def set_character_bitmap
    if @character.reflect_sprite
      self.bitmap = Cache.character(@character.reflect_sprite[0])
    else
      self.bitmap = Cache.character(@character_name)
    end
    self.mirror = true
    self.opacity = 255
    self.z = Galv_CEffects::REFLECT_Z
     
    sign = @character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
    else
      @cw = bitmap.width / 12
      @ch = bitmap.height / 8
    end
    self.ox = @cw / 2
    self.oy = @ch
  end
 
  def update_src_rect
    if @character.reflect_sprite
      index = @character.reflect_sprite[1]
    else
      index = @character.character_index
    end
    pattern = @character.pattern < 3 ? @character.pattern : 1
    sx = (index % 4 * 3 + pattern) * @cw
    sy = (index / 4 * 4 + (10 - @character.direction - 2) / 2) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
   
  def get_mirror_y
    20.times {|i|
      if $game_map.region_id(@character.x, @character.y - i) == Galv_CEffects::MIRROR_REGION
        @distance = (i - 1) * 0.05
        @display = @character.y - i - $game_map.display_y + $game_map.height
        self.opacity = 255
        return (@character.y - i + 1 - $game_map.display_y) * 32 - i * 4
      end
    }
    self.opacity = 0
    return @ch
  end
   
  def update_position
    self.x = @character.screen_x
    self.y = get_mirror_y - 6
    self.zoom_x = 1 - @distance
    self.zoom_y = 1 - @distance
  end
 
  def update_other
    self.blend_type = @character.blend_type
    self.visible = !@character.transparent
  end
end # Sprite_Mirror < Sprite_Character
 
 
#-------------------------------------------------------------------------------
#  Sprite_Shadow
#-------------------------------------------------------------------------------
 
class Sprite_Shadow < Sprite_Character
  def initialize(viewport, character = nil, source)
    @flicker = 0
    @famount = 0
    @aamount = 0
    @source = source
    super(viewport, character)
  end
  
  def update_balloon; end
  def setup_new_effect; end
 
  def update
    super
    update_bitmap
    update_src_rect
    update_position
    update_other
    update_facing
  end
  
  def set_character_bitmap
    self.bitmap = Cache.character(@character_name)
    
    self.color = Color.new(0, 0, 0, 255)
    self.z = Galv_CEffects::SHADOW_Z
    self.wave_amp = 1 if $game_map.shadow_options[2]
    self.wave_speed = 1000
     
    sign = @character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
    else
      @cw = bitmap.width / 12
      @ch = bitmap.height / 8
    end
    self.ox = @cw / 2
    self.oy = @ch
  end
 
  def update_position
    self.x = @character.screen_x
    self.y = @character.screen_y - 10
    get_angle
  end
   
  def get_angle
    x = $game_map.light_source[@source][0] - @character.real_x
    y = $game_map.light_source[@source][1] - @character.real_y
    self.opacity = $game_map.shadow_options[0] - 
      Math::sqrt(x * x + y * y) * $game_map.shadow_options[1]
     
    if x == 0 && y == 0 || self.opacity <= 0
      self.opacity = 0
    else 
      self.angle = Math::atan2(x, y) * 180 / Math::PI + @aamount
    end
  end
  
  def update_facing
    if @character.y < $game_map.light_source[@source][1]
      self.mirror = false
    else
      self.mirror = true
    end
  end
   
  def update_other
    self.blend_type = @character.blend_type
    self.visible = !@character.transparent
  end
end # Sprite_Shadow < Sprite_Character
 
 
#-------------------------------------------------------------------------------
#  Sprite_Icon
#-------------------------------------------------------------------------------
 
class Sprite_Icon < Sprite_Character
  def initialize(viewport, character = nil)
    @icon_sprite ||= Sprite.new
    @icon_sprite.bitmap ||= Cache.system("Iconset")
    @icon = nil
    super(viewport, character)
  end
 
  def dispose
    super
    if @icon_sprite
      @icon_sprite.dispose
      @icon_sprite = nil
    end
  end
   
  def update
    super
    update_icon
  end
   
  def update_icon
    return if !@character.icon
    draw_icon(@character.icon)
  end
   
  def draw_icon(icon_index)
    return if !@icon.nil?
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    @icon_sprite.src_rect  = rect
    @icon = icon_index
  end
   
  def update_position
    @icon_sprite.x = @character.screen_x - 12
    @icon_sprite.y = @character.screen_y + Galv_CEffects::ICON_OFFSET
  end
 
  def update_other
    self.blend_type = @character.blend_type
    @icon_sprite.visible = !@character.transparent
  end
end # Sprite_Icon < Sprite_Character
 
 
#-------------------------------------------------------------------------------
#  Other Stuff
#-------------------------------------------------------------------------------
 
 
class Game_Character < Game_CharacterBase
  attr_reader    :altitude
  attr_accessor  :reflect
  attr_accessor  :reflect_sprite
  attr_accessor  :shadow
  attr_accessor  :icon
  attr_accessor  :icon_offset
end
 
 
class Game_Event < Game_Character
  alias galv_reflect_ge_initialize initialize
  def initialize(map_id, event)
    @reflect = false
    @shadow = false
    @icon_offset = [0,0]
    galv_reflect_ge_initialize(map_id, event)
  end
end # Game_Event < Game_Character
 
 
class Game_Vehicle < Game_Character
  attr_reader :map_id
   
  alias galv_reflect_gv_initialize initialize
  def initialize(type)
    @reflect = true
    @shadow = true
    @icon_offset = [0,0]
    galv_reflect_gv_initialize(type)
  end
end # Game_Vehicle < Game_Character
 
 
class Game_Follower < Game_Character
  alias galv_reflect_gf_initialize initialize
  def initialize(member_index, preceding_character)
    galv_reflect_gf_initialize(member_index, preceding_character)
    @reflect = true
    @shadow = true
  end
   
  alias galv_reflect_gf_refresh refresh
  def refresh
    galv_reflect_gf_refresh
    return if actor.nil?
    @reflect = actor.reflect
    @reflect_sprite = actor.reflect_sprite
    @icon = actor.icon
    if SceneManager.scene_is?(Scene_Map)
      SceneManager.scene.spriteset.refresh_effects
    end
  end
end # Game_Follower < Game_Character
 
 
class Game_Player < Game_Character
  alias galv_reflect_gp_initialize initialize
  def initialize
    galv_reflect_gp_initialize
    @reflect = true
    @shadow = true
  end
   
  alias galv_reflect_gp_refresh refresh
  def refresh
    galv_reflect_gp_refresh
    @reflect = actor.reflect
    @reflect_sprite = actor.reflect_sprite
    @icon = actor.icon
    if SceneManager.scene_is?(Scene_Map)
      SceneManager.scene.spriteset.refresh_effects
    end
  end
end # Game_Player < Game_Character
 
 
class Scene_Map < Scene_Base
  attr_accessor :spriteset
end # Scene_Map
 
 
class Game_Map
  attr_accessor :char_effects
  attr_accessor :light_source
  attr_accessor :shadow_options
  attr_accessor :reflect_options
   
  alias galv_reflect_game_map_initialize initialize
  def initialize
    @light_source = []
    @shadow_options = [80,10,false]
    @reflect_options = [0]
    @char_effects = [false,false,false,false]
    #[reflect,shadow,mirror,icon]
    galv_reflect_game_map_initialize
  end
  
   
  alias galv_reflect_game_map_setup setup
  def setup(map_id)
    galv_reflect_game_map_setup(map_id)
    reset_char_effects
    do_all_chareffects
    if SceneManager.scene_is?(Scene_Map)
      SceneManager.scene.spriteset.refresh_effects
    end
  end
   
  def reset_char_effects
    @light_source = []
    @events.values.each { |e|
      e.reflect = false
      e.icon = nil }
  end
end # Game_Map
 
 
class Game_Actor < Game_Battler
  attr_accessor :reflect
  attr_accessor :reflect_sprite
  attr_accessor :icon
   
  alias galv_reflect_game_actor_initialize initialize
  def initialize(actor_id)
    galv_reflect_game_actor_initialize(actor_id)
    @reflect = $data_actors[actor_id].reflect
    @reflect_sprite = $data_actors[actor_id].reflect_sprite
    @icon_offset = [0,0]
  end
end # Game_Actor < Game_Battler
 
 
class RPG::Actor
  def reflect_sprite
    if @reflect_sprite.nil?
      if @note =~ /<reflect_sprite:[ ](.*),(.*)>/i
        @reflect_sprite = [$1.to_s,$2.to_i]
      else
        @reflect_sprite = nil
      end
    end
    @reflect_sprite
  end
  def reflect
    if @reflect.nil?
      if @note =~ /<no_reflect>/i
        @reflect = false
      else
        @reflect = true
      end
    end
    @reflect
  end
end # RPG::Actor