#==============================================================================
# ** Change Graphic by Equipment
# by: Jeneeus Guruman
#------------------------------------------------------------------------------
#  This script allows to change sprite and face graphics depending on the
# Equipment.
#
#   How to insert:
#
#     * Plug-n-play
#     * Place this below default and non-aliased scripts.
#   
#   How to use:
#
#     To use this, you need to put the following notetags:
#
#       To change sprites:
#
#       <ge: actor_id, sprite_name, sprite_index>
#
#       actor_id: The ID of the actor to be change graphics.
#       sprite_name: The filename of the sprite graphic to be placed.
#       sprite_index: The index of the sprite graphic to be placed.
#
#       To change face:
#
#       <fe: actor_id, face_name, face_index>
#
#       actor_id: The ID of the actor to be change face.
#       face_name: The filename of the face graphic to be placed.
#       face_index: The index of the face graphic to be placed.
#
#       Notes: 
#       * If you use a single-sprite file (files with $ at the 
#       beginning), you may also add it but the index must be 0.
#       * If the notetag is not fit in a single line, shorten the filename or 
#       use the other method below.
#       * You may put many notetags for the different actors at the same 
#       equipment.
#       
#==============================================================================

module Jene
  #--------------------------------------------------------------------------
  # * CHANGE_DEFAULT_GRAPHIC
  #     Change default graphic if changed using "Change Actor Graphic" command.
  #--------------------------------------------------------------------------
  CHANGE_DEFAULT_GRAPHIC = true
  #--------------------------------------------------------------------------
  # * CHANGE_DEFAULT_GRAPHIC_SWITCH
  #     Switch used to change default graphic if changed using "Change Actor 
  #   Graphic" command. CHANGE_DEFAULT_GRAPHIC must be "true" (without quotes) 
  #   to enable this. Put "0" (without quotes) to disable using the switch and
  #   always changing the default graphics.
  #--------------------------------------------------------------------------
  CHANGE_DEFAULT_GRAPHIC_SWITCH = 1
  #--------------------------------------------------------------------------
  # * PRIORITY_EQUIP
  #     The priority of what equipment type will be the bases on changing 
  #   the sprites and faces. This is from the least to greatest priority.
  #     0 = Weapon;         3 = Body Armor;
  #     1 = Shield;         4 = Accessory;
  #     2 = Headgear;
  #--------------------------------------------------------------------------
  PRIORITY_EQUIP = [0, 4, 1, 2, 3]
  #--------------------------------------------------------------------------
  # * graphic_equip
  #     Used to change sprites.
  #     when item_id
  #       return [[actor_id, sprite_name, sprite_index]]
  #
  #     Add another bonus by adding a comma (,) and another parameter array
  #   before the last bracket.
  #
  #     Example: when 20
  #                return [[1, Actor2, 2], [2, Actor2, 3]]
  #
  #     In this example, if Actor 1 will equip the item with the ID 20
  #   (Saint Robe in Default), that actor will change its sprite graphic to
  #   the sprite in actor 2 at index 2 (Bennett's Sprite) and if Actor 2 will 
  #   equip the item with the ID 20 (Saint Robe in Default), that actor will 
  #   change its sprite graphic to the sprite in actor 2 at index 3 
  #   (the sprite at Bennett's Right).
  #--------------------------------------------------------------------------
  def self.graphic_equip(id)
    case id
    when 1
      return [[0, nil, 0]]
    end
    return [[0, nil, 0]]
  end
  #--------------------------------------------------------------------------
  # * face_equip
  #     Used to change faces.
  #     when item_id
  #       return [[actor_id, sprite_name, sprite_index]]
  #
  #     Add another bonus by adding a comma (,) and another parameter array
  #   before the last bracket.
  #
  #     Example: when 20
  #                return [[1, Actor2, 2], [2, Actor2, 3]]
  #
  #     In this example, if Actor 1 will equip the item with the ID 20
  #   (Saint Robe in Default), that actor will change its face graphic to
  #   the face in actor 2 at index 2 (Bennett's Face) and if Actor 2 will 
  #   equip the item with the ID 20 (Saint Robe in Default), that actor will 
  #   change its face graphic to the face in actor 2 at index 3 
  #   (the face at Bennett's Right).
  #--------------------------------------------------------------------------
  def self.face_equip(id)
    case id
    when 1
      return [[0, nil, 0]]
    end
    return [[0, nil, 0]]
  end
  
#----------------------------------------------------------------------------
# * Do not edit below here
#----------------------------------------------------------------------------

  GRAPHIC_EQUIP = /<ge[:]?\s*(\d+)\s*[,]?\s*([$]*\w+)?\s*[,]?\s*(\d+)\s*>/i
  FACE_EQUIP = /<fe[:]?\s*(\d+)\s*[,]?\s*(\w+)?\s*[,]?\s*(\d+)\s*>/i
end

class RPG::Armor
  #--------------------------------------------------------------------------
  # * Graphic Equipment
  #--------------------------------------------------------------------------
  def graphic_equip(equip_arr = [])
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Jene::GRAPHIC_EQUIP
        equip_arr.push([$1.to_i, $2.to_s, $3.to_i])
      end
    }
    equip_arr.concat(Jene.graphic_equip(@id))
    return equip_arr
  end
  #--------------------------------------------------------------------------
  # * Face Equipment
  #--------------------------------------------------------------------------
  def face_equip(equip_arr = [])
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Jene::FACE_EQUIP
        equip_arr.push([$1.to_i, $2.to_s, $3.to_i])
      end
    }
    equip_arr.concat(Jene.face_equip(@id))
    return equip_arr
  end
end

class RPG::Weapon
  #--------------------------------------------------------------------------
  # * Graphic Equipment
  #--------------------------------------------------------------------------
  def graphic_equip(equip_arr = [])
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Jene::GRAPHIC_EQUIP
        equip_arr.push([$1.to_i, $2.to_s, $3.to_i])
      end
    }
    equip_arr.concat(Jene.graphic_equip(@id))
    return equip_arr
  end
  #--------------------------------------------------------------------------
  # * Face Equipment
  #--------------------------------------------------------------------------
  def face_equip(equip_arr = [])
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when Jene::FACE_EQUIP
        equip_arr.push([$1.to_i, $2.to_s, $3.to_i])
      end
    }
    equip_arr.concat(Jene.face_equip(@id))
    return equip_arr
  end
end

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It's used within the Game_Actors class
# ($game_actors) and referenced by the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :default_character_name           # character graphic filename
  attr_reader   :default_character_index          # character graphic index
  attr_reader   :default_face_name                # face graphic filename
  attr_reader   :default_face_index               # face graphic index
  #--------------------------------------------------------------------------
  # * Setup
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  alias jene_setup setup
  def setup(actor_id)
    jene_setup(actor_id)
    actor = $data_actors[actor_id]
    @default_character_name = actor.character_name
    @default_character_index = actor.character_index
    @default_face_name = actor.face_name
    @default_face_index = actor.face_index
    refresh_graphic_equip
  end
  #--------------------------------------------------------------------------
  # * Change Equipment (designate object)
  #     equip_type : Equip region (0..4)
  #     item       : Weapon or armor (nil is used to unequip)
  #     test       : Test flag (for battle test or temporary equipment)
  #--------------------------------------------------------------------------
  alias jene_change_equip change_equip
  def change_equip(slot_id, item)
    jene_change_equip(slot_id, item)
    refresh_graphic_equip
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * Graphic Equipment
  #     item  : Weapon or Armor
  #--------------------------------------------------------------------------
  def graphic_equip(item)
    return unless item.is_a?(RPG::Weapon) || item.is_a?(RPG::Armor)
    id = item.id
    for graphic in item.graphic_equip
      if @actor_id == graphic[0]
        set_graphic(graphic[1], graphic[2], @face_name, @face_index)
        break
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Face Equipment
  #     item  : Weapon or Armor
  #--------------------------------------------------------------------------
  def face_equip(item)
    return unless item.is_a?(RPG::Weapon) || item.is_a?(RPG::Armor)
    id = item.id
    for graphic in item.face_equip
      if @actor_id == graphic[0]
        set_graphic(@character_name, @character_index, graphic[1], graphic[2])
        break
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh Graphic Equip
  #--------------------------------------------------------------------------
  def refresh_graphic_equip
    set_graphic(@default_character_name, @default_character_index, 
      @default_face_name, @default_face_index)
    for i in Jene::PRIORITY_EQUIP
      graphic_code = 'graphic_equip(equips[' + i.to_s + '])'
      face_code = 'face_equip(equips[' + i.to_s + '])'
      eval(graphic_code)
      eval(face_code)
    end
  end
  #--------------------------------------------------------------------------
  # * Change Default Graphics
  #--------------------------------------------------------------------------
  def set_default_graphic(character_name, character_index, face_name, face_index)
    @default_character_name = character_name
    @default_character_index = character_index
    @default_face_name = face_name
    @default_face_index = face_index
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
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias jene_initialize initialize
  def initialize
    jene_initialize
    refresh_graphic_equip
  end
  #--------------------------------------------------------------------------
  # * Refresh Graphic Equip
  #--------------------------------------------------------------------------
  def refresh_graphic_equip
    for actor in members
      actor.refresh_graphic_equip
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
  # * Change Actor Graphic
  #--------------------------------------------------------------------------
  alias jene_command_322 command_322
  def command_322
    actor = $game_actors[@params[0]]
    if actor && Jene::CHANGE_DEFAULT_GRAPHIC && 
      ($game_switches[Jene::CHANGE_DEFAULT_GRAPHIC_SWITCH] ||
      Jene::CHANGE_DEFAULT_GRAPHIC_SWITCH == 0)
      actor.set_default_graphic(@params[1], @params[2], @params[3], @params[4])
    end
    jene_command_322
  end
end