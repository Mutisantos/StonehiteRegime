#==============================================================================
# Found this script here:
#http://rm-vx-ace.de/WBB4/index.php/Thread/565-YSA-Battle-System-Predicted-Charge-Turn-Battle-BROKEN/
#==============================================================================
# ▼ YSA Battle System: Predicted Charge Turn Battle
# -- Last Updated: 2012.03.17
# -- Level: Easy, Normal
# -- Requires: n/a
#
#==============================================================================

$imported = {} if $imported.nil?
$imported["YSA-PCTB"] = true

#==============================================================================
# ▼ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.03.17 - Compatible Issue: YEA - Battle Engine Ace.
# - Stand Alone fixed.
# 2012.02.20 - Reduced lag a little.
# 2012.02.19 - Fixed: Press Left/Right when choose action for actor.
# - Script now can work alone, without YEA - Battle Engine Ace.
# 2012.02.16 - Finished Script.
# 2012.02.07 - Started Script.
#
#==============================================================================
# ▼ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Battle Type: Predicted CTB.
#
#==============================================================================
# ▼ Instructions
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials/素材 but above ▼ Main. Remember to save.
#
# To get this work with YEA - Ace Battle Engine, set the default battle system
# for your game to be :pctb by either going to the Ace Battle Engine script and
# setting DEFAULT_BATTLE_SYSTEM as :pctb or by using the following script call:
#
# $game_system:set_battle_system(:pctb)
#
# -----------------------------------------------------------------------------
# Skill and Item Database
# -----------------------------------------------------------------------------
# SPEED FIX
# ~ When set SPEED FIX to a number larger than 0, battler's Speed will be reseted
# by value, equal to SPEED_FIX * :speed_rate.
# ~ When set SPEED FIX to a number smaller than 0, battler's Speed will be
# reduced by value, equal to SPEED_FIX * :speed_rate. This Skill/Item will be
# counted as a charging skill/item.
#
# -----------------------------------------------------------------------------
# Skill and Item Notetags
# -----------------------------------------------------------------------------
# <charge rate: x%>
# Change battler's speed rate when charging a skill or item.
#
# <ctb cost: x%> or <ctb cost: x>
# Decide how much Speed will be reduced after an action.
# If it's a percent, Battler's Speed will be reduced x percents of Max Threshold.
# If it's a normal value, Battler's Speed will be reduced by x.
# Default: CTB COST 100% in percent and 0 in value
#
# <ctb change: +x%> or <ctb change: +x>
# <ctb change: -x%> or <ctb change: -x>
# Change target's Speed when use this skill/item.
# If it's a percent, Battler's Speed will be increase or decrease x percents of
# Max Threshold.
# If it's a normal value, Battler's Speed will be increase or decrease by x.
#
#==============================================================================
# ▼ Compatibility
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# This script is made strictly for RPG Maker VX Ace. It is highly unlikely that
# it will run with RPG Maker VX without adjusting.
#
# This script is compatible with Yanfly Engine Ace - Ace Battle Engine v1.15+
# and the script must be placed under Ace Battle Engine in the script listing.
#
#==============================================================================

#==============================================================================
# ▼ Configuration
#==============================================================================

module YSA
  module PCTB
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Mechanic Configuration -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    CTB_MECHANIC = { # Start
      :dyn_threshold => true,
      # Threshold Offset. If Dynamic Threshold is set to false, this will be
      # threshold
      :threshold_offset => 400,
      # For Dynamic Threshold
      :threshold_min => 800,
      :threshold_rate => 4.0,
      # Ticks per turn
      :turn_ctr => 32,
      :wait_after_turn => 5, # Frames
      # Predict Type
      # Type 0: Show Battlers Order only.
      # Type 1: Show Battlers Order and Re-order when active battler chooses
      # an action.
      # Type 2: Show Battlers Order in X Turns (FFX Style).
      :predict => 2,
      :pre_turns => 5,
    } # Do not remove this.

    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Battler Configuration -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    BATTLER_RULES = { # Start
      # Speed offset when reset, multiply with Skill/Item speed
      :speed_rate => 16.0,
      :speed_limit => 0.75, # Set to 0 to disable limit.
      # Initialize speed
      :initial => 0.10,
      :surprise => 0.75,
      :random_rate => 8.0, # Multiply with AGI.
      # Charging Term
      :charge_text => "%s is charging %s!",
      :charge_text_dur => 4,
      # Can't take action Term
      :cant_text => "%s cannot take an action!",
      :cant_text_dur => 4,
      :show_cant_text => true,
    } # Do not remove this.

    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    # - Event Configuration -
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    CTB_COMMON_EVENT = { # Start
      # Set to 0 to disable this.
      :turn_update => 0, # Run common event whenever turn updates.
      :end_action => 0, # Run common event whenever an action finishes.
    } # Do not remove this.
  end
end

#==============================================================================
# ▼ Editting anything past this point may potentially result in causing
# computer damage, incontinence, explosion of user's head, coma, death, and/or
# halitosis so edit at your own risk.
#==============================================================================

module YSA
  module REGEXP
    module USABLEITEM
      CHARGE_RATE = /<(?:CHARGE_RATE|charge rate):[ ](\d+)?([%％])>/i
      CTB_COST_PER = /<(?:CTB_COST|ctb cost):[ ](\d+)?([%％])>/i
      CTB_COST_VAL = /<(?:CTB_COST|ctb cost):[ ](\d+)?>/i

      CHANGE_CTB_PER = /<(?:CTB_CHANGE|ctb change):[ ]([\+\-]\d+)([%％])?>/i
      CHANGE_CTB_VAL = /<(?:CTB_CHANGE|ctb change):[ ]([\+\-]\d+)?>/i
    end # USABLEITEM
  end # REGEXP
end # YSA

#==============================================================================
# ■ DataManager
#==============================================================================

module DataManager

  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class << self; alias load_database_pctb load_database; end
  def self.load_database
    load_database_pctb
    load_notetags_pctb
  end

  #--------------------------------------------------------------------------
  # new method: load_notetags_pctb
  #--------------------------------------------------------------------------
  def self.load_notetags_pctb
    groups = [$data_skills, $data_items]
    for group in groups
      for obj in group
        next if obj.nil?
        obj.load_notetags_pctb
      end
    end
  end
end # DataManager

#==============================================================================
# ■ RPG::UsableItem
#==============================================================================

class RPG::UsableItem < RPG::BaseItem

  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :charge_rate
  attr_accessor :ctb_cost
  attr_accessor :ctb_cost_val
  attr_accessor :ctb_change
  attr_accessor :ctb_change_val

  #--------------------------------------------------------------------------
  # common cache: load_notetags_pctb
  #--------------------------------------------------------------------------
  def load_notetags_pctb
    @charge_rate = 100
    @ctb_cost = 100
    @ctb_cost_val = 0
    @ctb_change = 0
    @ctb_change_val = 0
    #---
    self.note.split(/[\r\n]+/).each { |line|
      case line
      #---
      when YSA::REGEXP::USABLEITEM::CHARGE_RATE
        @charge_rate = $1.to_i
      when YSA::REGEXP::USABLEITEM::CTB_COST_PER
        @ctb_cost = $1.to_i
      when YSA::REGEXP::USABLEITEM::CTB_COST_VAL
        @ctb_cost_val = $1.to_i
      when YSA::REGEXP::USABLEITEM::CHANGE_CTB_PER
        @ctb_change = $1.to_i
      when YSA::REGEXP::USABLEITEM::CHANGE_CTB_VAL
        @ctb_change_val = $1.to_i
        #---
      end
    } # self.note.split
    #---
    @charge_rate = 100 if @charge_rate <= 0
    @ctb_cost = 100 if @ctb_cost > 100
  end
end # RPG::UsableItem

#==============================================================================
# ■ BattleManager
#==============================================================================

module BattleManager

  #--------------------------------------------------------------------------
  # alias method:
  # - make_action_orders
  # - prior_command
  # - next_command
  # - in_turn?
  # - battle_start
  #--------------------------------------------------------------------------
  class << self
    alias pctb_make_action_orders make_action_orders
    alias pctb_prior_command prior_command
    alias pctb_next_command next_command
    alias pctb_next_subject next_subject
    alias pctb_battle_start battle_start
    alias pctb_input_start input_start
    alias pctb_turn_start turn_start
  end

  #--------------------------------------------------------------------------
  # battle_start
  #--------------------------------------------------------------------------
  def self.battle_start
    pctb_battle_start
    if btype?(:pctb)
      make_pctb_action_orders
      make_pctb_threshold
      make_pctb_first_speed
    end
  end

  #--------------------------------------------------------------------------
  # make_action_orders
  #--------------------------------------------------------------------------
  def self.make_action_orders
    return if btype?(:pctb)
    pctb_make_action_orders unless btype?(:pctb)
  end

  #--------------------------------------------------------------------------
  # next_command
  #--------------------------------------------------------------------------
  def self.next_command
    return false if btype?(:pctb)
    pctb_next_command
  end

  #--------------------------------------------------------------------------
  # prior_command
  #--------------------------------------------------------------------------
  def self.prior_command
    return false if btype?(:pctb)
    pctb_prior_command
  end

  #--------------------------------------------------------------------------
  # new method: make_pctb_action_orders
  #--------------------------------------------------------------------------
  def self.make_pctb_action_orders
    @action_battlers = []
  end

  #--------------------------------------------------------------------------
  # new method: make_pctb_threshold
  #--------------------------------------------------------------------------
  def self.make_pctb_threshold
    @threshold = YSA::PCTB::CTB_MECHANIC[:threshold_offset]
    return unless YSA::PCTB::CTB_MECHANIC[:dyn_threshold]
    offset = 0
    battlers = $game_party.members + $game_troop.members
    battlers.each { |battler|
      offset += battler.agi
    }
    @threshold += offset * YSA::PCTB::CTB_MECHANIC[:threshold_rate]
    @threshold = @threshold >= YSA::PCTB::CTB_MECHANIC[:threshold_min] ? @threshold : YSA::PCTB::CTB_MECHANIC[:threshold_min]
  end

  #--------------------------------------------------------------------------
  # new method: make_pctb_first_speed
  #--------------------------------------------------------------------------
  def self.make_pctb_first_speed
    init_value = YSA::PCTB::BATTLER_RULES[:initial] * pctb_threshold
    surprise_value = YSA::PCTB::BATTLER_RULES[:surprise] * pctb_threshold
    battlers = $game_party.members + $game_troop.members
    battlers.each { |battler|
      check = (battler.actor? && @preemptive) || (battler.enemy? && @surprise)
      battler.pctb_speed = init_value
      battler.pctb_speed = surprise_value if check
      random = YSA::PCTB::BATTLER_RULES[:random_rate] * battler.agi + 1
      battler.pctb_speed += rand(random)
    }
  end

  #--------------------------------------------------------------------------
  # new method: pctb_threshold
  #--------------------------------------------------------------------------
  def self.pctb_threshold
    return @threshold
  end

  #--------------------------------------------------------------------------
  # new method: set_actor
  #--------------------------------------------------------------------------
  def self.set_actor(actor_index)
    @actor_index = actor_index
  end

  #--------------------------------------------------------------------------
  # new method: action_list_ctb
  #--------------------------------------------------------------------------
  def self.action_list_ctb
    return @action_battlers
  end

  #--------------------------------------------------------------------------
  # alias method: next_subject
  #--------------------------------------------------------------------------
  def self.next_subject
    return pctb_next_subject unless btype?(:pctb)
    loop do
      battler = @action_battlers[0]
      return nil unless battler
      unless battler.index && battler.alive?
        @action_battlers.shift
        next
      end
      return battler
    end
  end

  #--------------------------------------------------------------------------
  # alias method: input_start
  #--------------------------------------------------------------------------
  def self.input_start
    return pctb_input_start unless btype?(:pctb)
    @phase = :input
    return false
  end

  #--------------------------------------------------------------------------
  # alias method: turn_start
  #--------------------------------------------------------------------------
  def self.turn_start
    return pctb_turn_start unless btype?(:pctb)
    @phase = :turn
    clear_actor
  end

  #--------------------------------------------------------------------------
  # alias method: turn_start
  #--------------------------------------------------------------------------
  def self.sort_battlers(cache = false)
    if btype?(:pctb)
      battlers = []
      for battler in ($game_party.members + $game_troop.members)
        next if battler.dead?
        battlers.push(battler)
      end
      battlers.sort! { |a, b|
        if a.pctb_ctr(cache) != b.pctb_ctr(cache)
          a.pctb_ctr(cache) <=> b.pctb_ctr(cache)
        elsif a.pctb_prediction != b.pctb_prediction
          b.pctb_prediction <=> a.pctb_prediction
        elsif a.agi != b.agi
          b.agi <=> a.agi
        elsif a.screen_x != b.screen_x
          a.screen_x <=> b.screen_x
        else
          a.name <=> b.name
        end
      }
      return battlers
    end
  end

  #--------------------------------------------------------------------------
  # new method: btype?
  #--------------------------------------------------------------------------
  unless $imported["YEA-BattleEngine"]
    def self.btype?(btype)
      return true if btype == :pctb
    end
  end
end # BattleManager

#==============================================================================
# ■ Game_System
#==============================================================================

class Game_System
  if $imported["YEA-BattleEngine"]
    #--------------------------------------------------------------------------
    # alias method: set_battle_system
    #--------------------------------------------------------------------------
    alias pctb_set_battle_system set_battle_system

    def set_battle_system(type)
      case type
      when :pctb; @battle_system = :pctb
      else; pctb_set_battle_system(type)       end
    end

    #--------------------------------------------------------------------------
    # alias method: battle_system_corrected
    #--------------------------------------------------------------------------
    alias pctb_battle_system_corrected battle_system_corrected

    def battle_system_corrected(type)
      case type
      when :pctb; return :pctb
      else; return pctb_battle_system_corrected(type)       end
    end
  end
end # Game_System

#==============================================================================
# ■ Game_Battler
#==============================================================================

class Game_Battler < Game_BattlerBase

  #--------------------------------------------------------------------------
  # public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :pctb_speed
  attr_accessor :pctb_prediction
  attr_accessor :last_obj
  attr_accessor :pctb_forced
  attr_accessor :pctb_speed_cache

  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias pctb_initialize initialize

  def initialize
    pctb_initialize
    @pctb_speed = 0
    @pctb_prediction = 0
    @pctb_speed_cache = 0
  end

  #--------------------------------------------------------------------------
  # new method: base_gain_pctb
  #--------------------------------------------------------------------------
  def base_gain_pctb
    return self.agi
  end

  #--------------------------------------------------------------------------
  # new method: real_gain_pctb
  #--------------------------------------------------------------------------
  def real_gain_pctb
    obj = current_action.item if current_action
    value = base_gain_pctb
    value = value * obj.charge_rate / 100 if obj && @charging_pctb
    return value
  end

  #--------------------------------------------------------------------------
  # new method: pctb_ctr
  #--------------------------------------------------------------------------
  def pctb_ctr(cache = false)
    @pctb_prediction = @pctb_speed unless cache
    @pctb_prediction = @pctb_speed_cache if cache
    return 0 if @pctb_prediction >= BattleManager.pctb_threshold
    value = (BattleManager.pctb_threshold.to_f - @pctb_prediction.to_f) / real_gain_pctb.to_f
    value = value.ceil
    @pctb_prediction += value * real_gain_pctb
    return value
  end

  #--------------------------------------------------------------------------
  # new method: reset_pctb_speed
  #--------------------------------------------------------------------------
  def reset_pctb_speed(cache = false)
    return @pctb_forced = false if @pctb_forced
    if actor?
      obj = input ? input.item : @last_obj
    else
      obj = @last_obj
    end
    real_cache = @pctb_speed
    if obj
      limit_rate = YSA::PCTB::BATTLER_RULES[:speed_limit]
      limit = BattleManager.pctb_threshold * limit_rate
      real_cache -= obj.ctb_cost * BattleManager.pctb_threshold / 100
      real_cache -= obj.ctb_cost_val
      value = YSA::PCTB::BATTLER_RULES[:speed_rate] * obj.speed
      value = [value, 0].max
      value = [value, limit].min if limit > 0
      real_cache += value
    else
      real_cache -= BattleManager.pctb_threshold
    end
    real_cache = [real_cache, 0].max
    @pctb_speed = real_cache if cache == false
    @pctb_speed_cache = real_cache if cache
    @charging_pctb = false unless cache
    @last_obj = nil unless cache
  end

  #--------------------------------------------------------------------------
  # new method: charging_start
  #--------------------------------------------------------------------------
  def charging_start
    return false unless BattleManager.btype?(:pctb)
    return false if @charging_pctb
    return false unless current_action
    obj = current_action.item
    return false unless obj
    return false if obj.speed >= 0
    value = obj.speed * YSA::PCTB::BATTLER_RULES[:speed_rate]
    @pctb_speed += value
    @pctb_speed = [@pctb_speed, 0].max
    BattleManager.action_list_ctb.shift
    @charging_pctb = true
    SceneManager.scene.charging_start(self)
    SceneManager.scene.update_pctb_speed
    return true
  end

  #--------------------------------------------------------------------------
  # new method: pctb_active?
  #--------------------------------------------------------------------------
  def pctb_active?
    return @pctb_speed >= BattleManager.pctb_threshold && movable?
  end

  #--------------------------------------------------------------------------
  # new method: storage_speed
  #--------------------------------------------------------------------------
  def storage_speed
    return if @cache_speed
    @cache_speed = @pctb_speed
  end

  #--------------------------------------------------------------------------
  # new method: restore_speed
  #--------------------------------------------------------------------------
  def restore_speed
    return unless @cache_speed
    @pctb_speed = @cache_speed
    @cache_speed = nil
  end

  #--------------------------------------------------------------------------
  # alias method: update_state_turns
  #--------------------------------------------------------------------------
  alias pctb_update_state_turns update_state_turns

  def update_state_turns
    if BattleManager.btype?(:pctb)
      states.each do |state|
        @state_turns[state.id] -= 1 if @state_turns[state.id] > 0 && state.auto_removal_timing == 2
      end
    else
      pctb_update_state_turns
    end
  end

  #--------------------------------------------------------------------------
  # new method: update_state_actions
  #--------------------------------------------------------------------------
  def update_state_actions
    return unless BattleManager.btype?(:pctb)
    states.each do |state|
      @state_turns[state.id] -= 1 if @state_turns[state.id] > 0 && state.auto_removal_timing == 1
    end
  end

  #--------------------------------------------------------------------------
  # alias method: on_action_end
  #--------------------------------------------------------------------------
  alias pctb_on_action_end on_action_end

  def on_action_end
    pctb_on_action_end
    update_state_actions
  end

  #--------------------------------------------------------------------------
  # alias method: force_action
  #--------------------------------------------------------------------------
  alias pctb_force_action force_action

  def force_action(skill_id, target_index)
    if BattleManager.btype?(:pctb)
      action = Game_Action.new(self, true)
      action.set_skill(skill_id)
      if target_index == -2
        action.target_index = last_target_index
      elsif target_index == -1
        action.decide_random_target
      else
        action.target_index = target_index
      end
      @actions = [action] + @actions
      @pctb_forced = true
    end
    pctb_force_action(skill_id, target_index) unless BattleManager.btype?(:pctb)
  end

  #--------------------------------------------------------------------------
  # alias method: make_action_times
  #--------------------------------------------------------------------------
  alias pctb_make_action_times make_action_times

  def make_action_times
    BattleManager.btype?(:pctb) ? 1 : pctb_make_action_times
  end
end # Game_Battler

#==============================================================================
# ■ Game_Actor
#==============================================================================

class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------
  # overwrite method: input
  #--------------------------------------------------------------------------
  if $imported["YEA-BattleEngine"]
    def input
      game_actor_input_abe
    end
  end

  #--------------------------------------------------------------------------
  # new method: screen_x | screen_y
  #--------------------------------------------------------------------------
  unless $imported["YEA-BattleEngine"]
    def screen_x
      0
    end

    def screen_y
      0
    end
  end
end # Game_Actor

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # new method: battle_start
  #--------------------------------------------------------------------------
  alias pctb_battle_start battle_start

  def battle_start
    pctb_battle_start
    update_pctb_speed if BattleManager.btype?(:pctb)
  end

  #--------------------------------------------------------------------------
  # new method: charging_start
  #--------------------------------------------------------------------------
  def charging_start(battler)
    @status_window.show
    @status_window.open
    if $imported["YEA-BattleEngine"]
      redraw_current_status
      @status_aid_window.hide
    else
      refresh_status
    end
    @actor_command_window.show
    string = YSA::PCTB::BATTLER_RULES[:charge_text]
    skill = battler.current_action.item
    skill_text = sprintf("\\i[%d]%s", skill.icon_index, skill.name)
    text = sprintf(string, battler.name, skill_text)
    @log_window.add_text(text)
    YSA::PCTB::BATTLER_RULES[:charge_text_dur].times do @log_window.wait end
    @log_window.back_one
  end

  #--------------------------------------------------------------------------
  # new method: update_pctb_speed
  #--------------------------------------------------------------------------
  def update_pctb_speed
    return if scene_changing?
    @clocktick = 0 if @clocktick.nil?
    ctr = YSA::PCTB::CTB_MECHANIC[:turn_ctr]
    #---
    battlers = BattleManager.sort_battlers
    first_battler = battlers[0]
    tick = first_battler.pctb_ctr
    #---
    battlers.each { |battler|
      battler.pctb_speed += tick * battler.real_gain_pctb
    }
    #---
    @clocktick = @clocktick + tick
    pass_turn = @clocktick / ctr
    pass_turn = pass_turn.floor.to_i
    pass_turn.times {
      $game_temp.reserve_common_event(YSA::PCTB::CTB_COMMON_EVENT[:turn_update]) if YSA::PCTB::CTB_COMMON_EVENT[:turn_update] > 0 && $data_common_events[YSA::PCTB::CTB_COMMON_EVENT[:turn_update]]
      process_event
      $game_troop.increase_turn
      turn_end
      wait(YSA::PCTB::CTB_MECHANIC[:wait_after_turn])
    }
    @clocktick = @clocktick % ctr
    #---
    if first_battler.movable?
      BattleManager.action_list_ctb.push(first_battler)
    else
      string = YSA::PCTB::BATTLER_RULES[:cant_text]
      text = sprintf(string, first_battler.name)
      @log_window.add_text(text)
      YSA::PCTB::BATTLER_RULES[:cant_text_dur].times do @log_window.wait end
      @log_window.back_one
      first_battler.clear_actions
      first_battler.reset_pctb_speed
      return update_pctb_speed && update_order_gauge
    end
    #---
    update_order_gauge
    #---
    start_pctb_action
  end

  #--------------------------------------------------------------------------
  # new method: start_pctb_action
  #--------------------------------------------------------------------------
  def start_pctb_action
    battler = BattleManager.action_list_ctb[0]
    battler.make_actions if battler.actions.size == 0
    return if battler.charging_start && battler.enemy?
    if battler.actor? && battler.input && battler.input.item.nil?
      BattleManager.input_start
      BattleManager.set_actor(battler.index)
      start_actor_command_selection
      if $imported["YEA-BattleEngine"]
        redraw_current_status
        @status_aid_window.hide
      else
        refresh_status
      end
      @status_window.show
      @status_window.open
    end
    turn_start if battler.enemy?
    turn_start if battler.actor? && battler.input && battler.input.item
  end

  #--------------------------------------------------------------------------
  # new method: update_order_gauge
  #--------------------------------------------------------------------------
  def update_order_gauge
    battler = BattleManager.action_list_ctb[0]
    return unless $imported["YSA-OrderBattler"]
    BattleManager.make_ctb_battler_order
    @active_order_sprite.battler = battler if @active_order_sprite
    for order in @spriteset_order
      order.make_destination
    end
  end

  #--------------------------------------------------------------------------
  # alias method: execute_action
  #--------------------------------------------------------------------------
  alias scene_battle_execute_action_pctb execute_action

  def execute_action
    scene_battle_execute_action_pctb
    unless BattleManager.action_forced?
      if (@subject.current_action != nil)
        @subject.last_obj = @subject.current_action.item unless @subject.last_obj
      end
    end
  end

  #--------------------------------------------------------------------------
  # alias method: execute_action
  #--------------------------------------------------------------------------
  alias scene_battle_invoke_item_pctb invoke_item

  def invoke_item(target, item)
    scene_battle_invoke_item_pctb(target, item)
    #---
    change_per = item.ctb_change * BattleManager.pctb_threshold / 100
    change_val = item.ctb_change_val
    target.pctb_speed += change_per
    target.pctb_speed = 0 if target.pctb_speed < 0
    target.pctb_speed += change_val
    target.pctb_speed = 0 if target.pctb_speed < 0
    #---
  end

  #--------------------------------------------------------------------------
  # alias method: process_action_end
  #--------------------------------------------------------------------------
  alias scene_battle_process_action_end_pctb process_action_end

  def process_action_end
    scene_battle_process_action_end_pctb
    unless BattleManager.action_forced?
      $game_temp.reserve_common_event(YSA::PCTB::CTB_COMMON_EVENT[:end_action]) if YSA::PCTB::CTB_COMMON_EVENT[:end_action] > 0 && $data_common_events[YSA::PCTB::CTB_COMMON_EVENT[:end_action]]
      process_event
      @subject.restore_speed
      @subject.reset_pctb_speed
      return start_pctb_action if @subject.pctb_active?
      BattleManager.action_list_ctb.shift
      update_pctb_speed
    end
  end

  #--------------------------------------------------------------------------
  # alias method: next_command
  #--------------------------------------------------------------------------
  alias pctb_next_command next_command

  def next_command
    if BattleManager.actor
      if BattleManager.actor != BattleManager.action_list_ctb[0]
        BattleManager.action_list_ctb[0].make_actions
        start_pctb_action
        return
      end
    end
    return @subject = nil if BattleManager.actor && BattleManager.actor.charging_start
    pctb_next_command
  end

  #--------------------------------------------------------------------------
  # alias method: create_actor_command_window
  #--------------------------------------------------------------------------
  alias yctb_create_actor_command_window create_actor_command_window

  def create_actor_command_window
    yctb_create_actor_command_window
    @actor_command_window.set_handler(:cancel, method(:ctb_prior_actor))
    @actor_command_window.set_handler(:dir4, method(:ctb_prior_actor))
    @actor_command_window.set_handler(:dir6, method(:ctb_next_command))
  end

  #--------------------------------------------------------------------------
  # new method: ctb_prior_actor
  #--------------------------------------------------------------------------
  def ctb_prior_actor
    BattleManager.actor.make_actions
    last_index = BattleManager.actor.index
    prior_index = last_index - 1
    if prior_index < 0
      @actor_command_window.close
      @party_command_window.setup
    else
      return ctb_prior_actor if !$game_party.members[prior_index].movable?
      $game_party.members[prior_index].make_actions
      BattleManager.input_start
      BattleManager.set_actor(prior_index)
      start_actor_command_selection
      if $imported["YEA-BattleEngine"]
        redraw_current_status
        @status_aid_window.hide
      else
        refresh_status
      end
      @status_window.show
      @status_window.open
    end
  end

  #--------------------------------------------------------------------------
  # new method: ctb_next_command
  #--------------------------------------------------------------------------
  def ctb_next_command
    BattleManager.actor.make_actions
    last_index = BattleManager.actor.index
    next_index = last_index + 1
    if next_index > ($game_party.members.size - 1)
      return start_confirm_command_selection if $imported["YEA-BattleCommandList"] && YEA::BATTLE_COMMANDS::USE_CONFIRM_WINDOW
      BattleManager.action_list_ctb[0].make_actions
      start_pctb_action
    else
      return ctb_next_command if !$game_party.members[next_index].movable?
      $game_party.members[next_index].make_actions
      BattleManager.input_start
      BattleManager.set_actor(next_index)
      start_actor_command_selection
      if $imported["YEA-BattleEngine"]
        redraw_current_status
        @status_aid_window.hide
      else
        refresh_status
      end
      @status_window.show
      @status_window.open
    end
  end

  #--------------------------------------------------------------------------
  # alias method: command_fight
  #--------------------------------------------------------------------------
  alias command_fight_pctb command_fight

  def command_fight
    return command_fight_pctb unless BattleManager.btype?(:pctb)
    if BattleManager.action_list_ctb[0].nil?
      update_pctb_speed
    else
      BattleManager.action_list_ctb[0].make_actions
      start_pctb_action
    end
  end

  #--------------------------------------------------------------------------
  # alias method: turn_start
  #--------------------------------------------------------------------------
  alias pctb_turn_start turn_start

  def turn_start
    last_subject = @subject if BattleManager.btype?(:pctb)
    pctb_turn_start
    @subject = last_subject if BattleManager.btype?(:pctb)
  end
end # Scene_Battle

#==============================================================================
#
# ▼ End of File
#
#==============================================================================
