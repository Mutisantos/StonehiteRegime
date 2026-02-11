#==============================================================================
# 
# ▼ Yanfly Engine Ace - Target Manager v1.03
# -- Last Updated: 2012.01.13
# -- Level: Normal, Hard
# -- Requires: n/a
# 
#==============================================================================

$imported = {} if $imported.nil?
$imported["YEA-TargetManager"] = true

#==============================================================================
# ▼ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.01.13 - Bug Fixed: AoE removing targets.
# 2012.01.04 - Compatibility Update: Area of Effect
# 2012.01.02 - Started Script and Finished.
#            - Compatibility Update: Lunatic Targets
# 
#==============================================================================
# ▼ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script provides the ability to expand the targeting scope for skills and
# items. This script provides the ability to up the number of maximum hits
# past 9, expand the targeting range to target different types of groups, and 
# give more control over random targeting.
# 
#==============================================================================
# ▼ Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
# 
# -----------------------------------------------------------------------------
# Skill Notetags - These notetags go in the skills notebox in the database.
# -----------------------------------------------------------------------------
# <total hits: x>
# Sets the total hits performed to x. This value can exceed 9, the limit RPG
# Maker VX Ace imposes.
# 
# <targets: everybody>
# Sets the targeting scope to hit all alive actors and all alive enemies.
# 
# <targets: target all foes>
# Sets the targeting scope to hit the selected target foe first and then the
# remaining foes.
# 
# <targets: target x random foes>
# Sets the targeting scope to hit the selected target foe first and then hit
# x random foes.
# 
# <targets: x random foes>
# Sets the targeting scope to random. This will hit x random foes.
# 
# <targets: all but user>
# Targets all allies except for the user.
# 
# <targets: target all allies>
# Sets the targeting scope to hit the selected target ally first and then the
# remaining allies.
# 
# <targets: target x random allies>
# Sets the targeting scope to hit the selected target ally first and then hit
# x random allies.
# 
# <targets: x random allies>
# Sets the targeting scope to random. This will hit x random allies.
# 
# -----------------------------------------------------------------------------
# Item Notetags - These notetags go in the items notebox in the database.
# -----------------------------------------------------------------------------
# <total hits: x>
# Sets the total hits performed to x. This value can exceed 9, the limit RPG
# Maker VX Ace imposes.
# 
# <targets: everybody>
# Sets the targeting scope to hit all alive actors and all alive enemies.
# 
# <targets: target all foes>
# Sets the targeting scope to hit the selected target foe first and then the
# remaining foes.
# 
# <targets: target x random foes>
# Sets the targeting scope to hit the selected target foe first and then hit
# x random foes.
# 
# <targets: x random foes>
# Sets the targeting scope to random. This will hit x random foes.
# 
# <targets: all but user>
# Targets all allies except for the user.
# 
# <targets: target all allies>
# Sets the targeting scope to hit the selected target ally first and then the
# remaining allies.
# 
# <targets: target x random allies>
# Sets the targeting scope to hit the selected target ally first and then hit
# x random allies.
# 
# <targets: x random allies>
# Sets the targeting scope to random. This will hit x random allies.

# 
#==============================================================================
# ▼ Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
# 
# This script is compatible with Yanfly Engine Ace - Ace Battle Engine v1.12+.
# Place this script under Ace Battle Engine in the script listing. Also, for
# maximum compatibility with Yanfly Engine Ace - Lunatic Targets, place this
# script under Yanfly Engine Ace - Lunatic Targets as well.
# 
#==============================================================================

module YEA
  module TARGET
    
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - General Targeting Settings -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # These settings adjust how targeting operates in your game. Here, you can
    # choose to have random targeting redirect to a different target if the
    # selected target is dead, change the default settings used for area of
    # effects, and more.
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # This setting, if true, will redirect the target of a random attack to an
    # alive target if the current target is dead. If there are no alive targets
    # then nothing happens.
    RANDOM_REDIRECT = true
    
  end # TARGET
end # YEA

#==============================================================================
# ▼ Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

module YEA
  module REGEXP
  module USABLEITEM
    
    TOTAL_HITS = /<(?:TOTAL_HITS|total hits):[ ](\d+)>/i
    TARGETS = /<(?:TARGETS|target):[ ](.*)>/i
    
  end # USABLEITEM
  end # REGEXP
end # YEA


#==============================================================================
# ■ DataManager
#==============================================================================

module DataManager
  
  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_target load_database; end
  def self.load_database
    load_database_target
    load_notetags_target
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_target
  #--------------------------------------------------------------------------
  def self.load_notetags_target
    groups = [$data_skills, $data_items]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_target
      end
    end
  end
  
end # DataManager

#==============================================================================
# ■ RPG::UsableItem
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # common cache: load_notetags_target
  #--------------------------------------------------------------------------
  def load_notetags_target
    @random_hits = [3, 4, 5, 6].include?(@scope) ? @scope - 2 : 0
    #---
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YEA::REGEXP::USABLEITEM::TOTAL_HITS
        @repeats = [$1.to_i, 1].max
      #---
      when YEA::REGEXP::USABLEITEM::TARGETS
        @random_hits = 0
        case $1
        when /ANY/i 
          @original_scope = @scope  # Store original scope before changing
          @scope = :any
        when /EVERYBODY/i
          @scope = :everybody
        when /TARGET ALL FOES/i
          @scope = :target_all_foes
        when /TARGET[ ](\d+)[ ]RANDOM FOE/i
          @scope = :target_random_foes
          @random_hits = $1.to_i
        when /(\d+)[ ]RANDOM FOE/i
          @scope = 3
          @random_hits = $1.to_i
        when /ALL BUT USER/i
          @scope = :all_but_user
        when /TARGET ALL ALLIES/i
          @scope = :target_all_allies
        when /TARGET[ ](\d+)[ ]RANDOM ALL/i
          @scope = :target_random_allies
          @random_hits = $1.to_i
        when /(\d+)[ ]RANDOM ALL/i
          @scope = :random_allies
          @random_hits = $1.to_i
        end
      #---
      end
    } # self.note.split
    #---
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: for_random?
  #--------------------------------------------------------------------------
  def for_random?; return @random_hits > 0; end
  
  #--------------------------------------------------------------------------
  # overwrite method: number_of_targets
  #--------------------------------------------------------------------------
  def number_of_targets; return @random_hits; end
  
  #--------------------------------------------------------------------------
  # alias method: for_opponent?
  #--------------------------------------------------------------------------
  alias rpg_usableitem_for_opponent_target for_opponent?
  def for_opponent?
    return true if @scope == :target_all_foes
    return true if @scope == :target_random_foes
    return true if @scope == :any
    return rpg_usableitem_for_opponent_target
  end
  
  #--------------------------------------------------------------------------
  # alias method: for_friend?
  #--------------------------------------------------------------------------
  alias rpg_usableitem_for_friend_target for_friend?
  def for_friend?
    return true if @scope == :all_but_user
    return true if @scope == :target_all_allies
    return true if @scope == :target_random_allies
    return true if @scope == :random_allies
    return true if @scope == :any
    return rpg_usableitem_for_friend_target
  end
  
  #--------------------------------------------------------------------------
  # alias method: for_all?
  #--------------------------------------------------------------------------
  alias rpg_usableitem_for_all_target for_all?
  def for_all?
    return true if @scope == :all_but_user
    return rpg_usableitem_for_all_target
  end
  
  #--------------------------------------------------------------------------
  # alias method: need_selection?
  #--------------------------------------------------------------------------
  alias rpg_usableitem_need_selection_target need_selection?
  def need_selection?
    return true if @scope == :target_all_foes
    return true if @scope == :target_random_foes
    return true if @scope == :target_all_allies
    return true if @scope == :target_random_allies
    return true if @scope == :any
    return rpg_usableitem_need_selection_target
  end
  
  #--------------------------------------------------------------------------
  # new method: for_custom?
  #--------------------------------------------------------------------------
  def for_custom?
    return !@scope.is_a?(Integer)
  end
  
  #--------------------------------------------------------------------------
  # new method: for_everybody?
  #--------------------------------------------------------------------------
  def for_everybody?
    return @scope == :everybody
  end
  
  #--------------------------------------------------------------------------
  # new method: for_target_all_foes?
  #--------------------------------------------------------------------------
  def for_target_all_foes?
    return @scope == :target_all_foes
  end
  
  #--------------------------------------------------------------------------
  # new method: for_target_random_foes?
  #--------------------------------------------------------------------------
  def for_target_random_foes?
    return @scope == :target_random_foes
  end
  
  #--------------------------------------------------------------------------
  # new method: for_all_but_user?
  #--------------------------------------------------------------------------
  def for_all_but_user?
    return @scope == :all_but_user
  end
  
  #--------------------------------------------------------------------------
  # new method: for_target_all_allies?
  #--------------------------------------------------------------------------
  def for_target_all_allies?
    return @scope == :target_all_allies
  end
  
  #--------------------------------------------------------------------------
  # new method: for_target_random_allies?
  #--------------------------------------------------------------------------
  def for_target_random_allies?
    return @scope == :target_random_allies
  end
  
  #--------------------------------------------------------------------------
  # new method: for_random_allies?
  #--------------------------------------------------------------------------
  def for_random_allies?
    return @scope == :random_allies
  end

  #--------------------------------------------------------------------------
  # new method: for_any?
  #--------------------------------------------------------------------------
  def for_any?
    return @scope == :any
  end

  #--------------------------------------------------------------------------
  # new method: for_original_one?
  #--------------------------------------------------------------------------
  def for_original_one?
    return [1, 2].include?(@original_scope)
  end
  
end # class RPG::UsableItem

#==============================================================================
# ■ Game_Action
#==============================================================================

class Game_Action
  
  #--------------------------------------------------------------------------
  # alias method: make_targets
  #--------------------------------------------------------------------------
  unless $imported["YEA-LunaticTargets"]
  alias game_action_make_targets_target make_targets
  def make_targets
    if !forcing && subject.confusion?
      targets = [confusion_target]
    elsif item.for_custom?
      targets = make_custom_targets
    else
      targets = game_action_make_targets_target
    end
    targets = aoe_targets(targets) if $imported["YEA-AreaofEffect"]
    return targets
  end
  end # $imported["YEA-LunaticTargets"]
  
  #--------------------------------------------------------------------------
  # compatibility method: default_target_set
  #--------------------------------------------------------------------------
  if $imported["YEA-LunaticTargets"]
  def default_target_set
    if !forcing && subject.confusion?
      targets = [confusion_target]
    elsif item.for_custom?
      targets = make_custom_targets
    else
      targets = game_action_make_targets_ltar
    end
    targets = aoe_targets(targets) if $imported["YEA-AreaofEffect"]
    return targets
  end
  end # $imported["YEA-LunaticTargets"]
  
  #--------------------------------------------------------------------------
  # new method: make_custom_targets
  #--------------------------------------------------------------------------
  def make_custom_targets
    array = []
    if item.for_everybody?
      array |= opponents_unit.alive_members
      array |= friends_unit.alive_members
    elsif item.for_target_all_foes?
      array |= [opponents_unit.smooth_target(@target_index)]
      array |= opponents_unit.alive_members
    elsif item.for_target_random_foes?
      array |= [opponents_unit.smooth_target(@target_index)]
      array += Array.new(item.number_of_targets) { opponents_unit.random_target }
    elsif item.for_all_but_user?
      array |= friends_unit.alive_members
      array -= [subject]
    elsif item.for_target_all_allies?
      array |= [friends_unit.smooth_target(@target_index)]
      array |= friends_unit.alive_members
    elsif item.for_target_random_allies?
      array |= [friends_unit.smooth_target(@target_index)]
      array += Array.new(item.number_of_targets) { friends_unit.random_target }
    elsif item.for_random_allies?
      array += Array.new(item.number_of_targets) { friends_unit.random_target }
    elsif item.for_any?
      array |= opponents_unit.alive_members
      array |= friends_unit.alive_members
      if item.for_original_one?
        # Handle special indexing for :any scope
        if @target_index >= 1000
          # Actor selected (1000 + actor_index)
          actor_index = @target_index - 1000
          return [friends_unit.members[actor_index]] if actor_index < friends_unit.members.size
        elsif @target_index >= 0
          # Enemy selected
          return [opponents_unit.members[@target_index]] if @target_index < opponents_unit.members.size
        end
        return [array.sample]
      end
    end
    return array
  end
  
end # Game_Action

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias method: invoke_item
  #--------------------------------------------------------------------------
  unless $imported["YEA-BattleEngine"]
  alias scene_battle_invoke_item_target invoke_item
  def invoke_item(target, item)
    target = alive_random_target(target, item) if item.for_random?
    scene_battle_invoke_item_target(target, item)
  end
  end # $imported["YEA-BattleEngine"]
  
  #--------------------------------------------------------------------------
  # new method: alive_random_target
  #--------------------------------------------------------------------------
  def alive_random_target(target, item)
    return target if target.alive?
    return target if target.dead? == item.for_dead_friend?
    return target unless YEA::TARGET::RANDOM_REDIRECT
    if item.for_dead_friend? && target.friends_unit.dead_members.empty?
      return target
    elsif item.for_dead_friend?
      return target.friends_unit.random_dead_target
    elsif target.friends_unit.all_dead?
      return target
    else
      return target.friends_unit.random_target
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_skill_ok
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"]
  alias scene_battle_on_skill_ok_any_abe on_skill_ok
  def on_skill_ok
    @skill = @skill_window.item
    $game_temp.battle_aid = @skill
    BattleManager.actor.input.set_skill(@skill.id)
    BattleManager.actor.last_skill.object = @skill
    if @skill.for_any?
      @skill_window.hide
      select_any_selection
    else
      scene_battle_on_skill_ok_any_abe
    end
  end
  end # $imported["YEA-BattleEngine"]
  
  #--------------------------------------------------------------------------
  # alias method: on_item_ok
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"]
  alias scene_battle_on_item_ok_any_abe on_item_ok
  def on_item_ok
    @item = @item_window.item
    $game_temp.battle_aid = @item
    BattleManager.actor.input.set_item(@item.id)
    if @item.for_any?
      @item_window.hide
      select_any_selection
    else
      scene_battle_on_item_ok_any_abe
    end
    $game_party.last_item.object = @item
  end
  end # $imported["YEA-BattleEngine"]
  
  #--------------------------------------------------------------------------
  # new method: select_any_selection
  #--------------------------------------------------------------------------
  def select_any_selection
    # Use enemy selection window but modify it to show both enemies and actors
    select_enemy_selection
  end
  
end # Scene_Battle

#==============================================================================
# ■ Window_BattleEnemy
#==============================================================================

class Window_BattleEnemy < Window_Selectable
  
  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias window_battle_enemy_refresh_any refresh
  def refresh
    if $game_temp.battle_aid && $game_temp.battle_aid.for_any?
      refresh_any_targets
    else
      window_battle_enemy_refresh_any
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: refresh_any_targets
  #--------------------------------------------------------------------------
  def refresh_any_targets
    @data = []
    @data += $game_troop.alive_members
    @data += $game_party.alive_members
    create_contents
    draw_all_items
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_max
  #--------------------------------------------------------------------------
  alias window_battle_enemy_item_max_any item_max
  def item_max
    if $game_temp.battle_aid && $game_temp.battle_aid.for_any?
      return @data ? @data.size : 0
    else
      window_battle_enemy_item_max_any
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias window_battle_enemy_draw_item_any draw_item
  def draw_item(index)
    if $game_temp.battle_aid && $game_temp.battle_aid.for_any?
      draw_any_item(index)
    else
      window_battle_enemy_draw_item_any(index)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_any_item
  #--------------------------------------------------------------------------
  def draw_any_item(index)
    return unless @data
    target = @data[index]
    if target
      change_color(normal_color)
      draw_text(item_rect_for_text(index), target.name)
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: enemy
  #--------------------------------------------------------------------------
  alias window_battle_enemy_enemy_any enemy
  def enemy
    if $game_temp.battle_aid && $game_temp.battle_aid.for_any?
      return @data ? @data[@index] : nil
    else
      window_battle_enemy_enemy_any
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: enemy_index
  #--------------------------------------------------------------------------
  def enemy_index
    if $game_temp.battle_aid && $game_temp.battle_aid.for_any?
      target = enemy
      return -1 if target.nil?
      
      # For enemies, return their index in the troop
      if target.is_a?(Game_Enemy)
        return target.index
      # For actors, we need to return their index with an offset
      # to distinguish them from enemies
      elsif target.is_a?(Game_Actor)
        # Use a special index scheme: 1000 + actor_index
        # This will be handled in make_custom_targets
        return 1000 + target.index
      end
    else
      return enemy ? enemy.index : -1
    end
  end
  
end # Window_BattleEnemy

#==============================================================================
# 
# ▼ End of File
#