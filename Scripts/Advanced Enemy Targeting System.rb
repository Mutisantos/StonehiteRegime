#==============================================================================
# ■ Advanced Enemy Targeting System
#------------------------------------------------------------------------------
# Author: Custom Script
# Version: 1.0
# 
# This script provides advanced enemy targeting capabilities including:
# - State-based targeting
# - Equipment-based targeting  
# - Level-based targeting
# - Previous attack memory
# - Tactical threat assessment
# - Party composition analysis
# - Weighted target selection
# - Enemy-specific targeting profiles
#
# Installation:
# Place this script below Materials and above Main
#
# Usage:
# Add these tags to enemy notes in the database:
# <target_type: aggressive>  - Targets highest threat
# <target_type: defensive>  - Targets healers first
# <target_type: tactical>   - Uses advanced threat calculation
# <target_type: random>     - Default random targeting
#
# Add these tags to state notes:
# <target_weight: 50>       - Increases targeting priority
# <priority_target: true>   - Always prioritize this state
#
#==============================================================================

module EnemyTargeting
  #--------------------------------------------------------------------------
  # ● Configuration
  #--------------------------------------------------------------------------
  # Default targeting behavior if no specific type is set
  DEFAULT_TARGET_TYPE = :random
  
  # Memory system settings
  REMEMBER_TARGETS = true      # Enable previous target memory
  RETARGET_CHANCE = 0.3        # 30% chance to target same character again
  
  # Threat calculation weights
  THREAT_WEIGHTS = {
    level: 2.0,        # Level multiplier
    hp: 0.1,          # Current HP contribution
    atk: 1.5,         # Attack power contribution
    def: 1.0,         # Defense contribution
    agi: 0.8,         # Agility contribution
    mat: 1.2,         # Magic attack contribution
    mdf: 0.9,         # Magic defense contribution
  }
  
  # State threat bonuses
  STATE_THREAT_BONUS = {
    # State ID => threat bonus
    1 => 50,   # Death state
    2 => 30,   # Poison
    3 => 40,   # Paralysis
    4 => 25,   # Blind
    5 => 35,   # Silence
    # Add more as needed
  }
  
  #--------------------------------------------------------------------------
  # ● Target Type Definitions
  #--------------------------------------------------------------------------
  TARGET_TYPES = {
    aggressive: {
      description: "Targets highest threat character",
      method: :target_aggressive
    },
    defensive: {
      description: "Targets healers and support characters first",
      method: :target_defensive
    },
    tactical: {
      description: "Uses advanced threat calculation",
      method: :target_tactical
    },
    random: {
      description: "Default random targeting",
      method: :target_random
    },
    healer_focus: {
      description: "Always targets healers if available",
      method: :target_healer_focus
    },
    mage_focus: {
      description: "Prioritizes magic users",
      method: :target_mage_focus
    },
    tank_focus: {
      description: "Targets high defense characters",
      method: :target_tank_focus
    },
    weakest_first: {
      description: "Targets lowest HP character",
      method: :target_weakest_first
    },
    strongest_first: {
      description: "Targets highest level character",
      method: :target_strongest_first
    }
  }
  
  #--------------------------------------------------------------------------
  # ● Equipment Type Detection
  #--------------------------------------------------------------------------
  EQUIPMENT_TYPES = {
    shield: [1, 2, 3],     # Shield type IDs (adjust to your database)
    weapon_heavy: [4, 5],  # Heavy weapon types
    weapon_magic: [6, 7],  # Magic weapon types
    armor_heavy: [8, 9],   # Heavy armor types
    armor_light: [10, 11]  # Light armor types
  }
  
  #--------------------------------------------------------------------------
  # ● Role Detection Methods
  #--------------------------------------------------------------------------
  module RoleDetection
    def healer?(actor)
      return false unless actor.is_a?(Game_Actor)
      # Check for healing skills
      actor.skills.any? { |skill| healing_skill?(skill) }
    end
    
    def mage?(actor)
      return false unless actor.is_a?(Game_Actor)
      # Check for magic skills or equipment
      magic_skills = actor.skills.count { |skill| magical_skill?(skill) }
      magic_equipment = actor.weapons.any? { |w| magic_weapon?(w) }
      magic_skills >= 2 || magic_equipment
    end
    
    def tank?(actor)
      return false unless actor.is_a?(Game_Actor)
      # High defense or heavy equipment
      actor.def > 100 || heavy_equipment?(actor)
    end
    
    def dps?(actor)
      return false unless actor.is_a?(Game_Actor)
      # High attack or damage-focused equipment
      actor.atk > 80 || damage_equipment?(actor)
    end
    
    private
    
    def healing_skill?(skill)
      skill.damage.recover? || skill.scope.between?(7, 9)
    end
    
    def magical_skill?(skill)
      skill.damage.magical?
    end
    
    def magic_weapon?(weapon)
      return false unless weapon
      EQUIPMENT_TYPES[:weapon_magic].include?(weapon.wtype_id)
    end
    
    def heavy_equipment?(actor)
      actor.armors.any? { |armor| EQUIPMENT_TYPES[:armor_heavy].include?(armor.atype_id) }
    end
    
    def damage_equipment?(actor)
      actor.weapons.any? { |weapon| EQUIPMENT_TYPES[:weapon_heavy].include?(weapon.wtype_id) }
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Target Selection Methods
  #--------------------------------------------------------------------------
  module TargetSelection
    # Target highest threat character
    def target_aggressive(enemies)
      enemies.max_by { |enemy| calculate_threat_level(enemy) }
    end
    
    # Target healers and support first
    def target_defensive(enemies)
      healers = enemies.select { |e| healer?(e) }
      return healers.sample if healers.any?
      
      supports = enemies.select { |e| support_character?(e) }
      return supports.sample if supports.any?
      
      enemies.sample
    end
    
    # Advanced tactical targeting
    def target_tactical(enemies)
      weighted_target_selection(enemies)
    end
    
    # Default random targeting
    def target_random(enemies)
      enemies.sample
    end
    
    # Always target healers
    def target_healer_focus(enemies)
      healers = enemies.select { |e| healer?(e) }
      healers.any? ? healers.sample : enemies.sample
    end
    
    # Target magic users
    def target_mage_focus(enemies)
      mages = enemies.select { |e| mage?(e) }
      mages.any? ? mages.sample : enemies.sample
    end
    
    # Target tanks
    def target_tank_focus(enemies)
      tanks = enemies.select { |e| tank?(e) }
      tanks.any? ? tanks.sample : enemies.sample
    end
    
    # Target weakest character
    def target_weakest_first(enemies)
      enemies.min_by(&:hp)
    end
    
    # Target strongest character
    def target_strongest_first(enemies)
      enemies.max_by(&:level)
    end
    
    # Support character detection
    def support_character?(actor)
      return false unless actor.is_a?(Game_Actor)
      # Check for buff/debuff skills or support equipment
      support_skills = actor.skills.count { |skill| support_skill?(skill) }
      support_equipment = actor.armors.any? { |armor| support_armor?(armor) }
      support_skills >= 1 || support_equipment
    end
    
    def support_skill?(skill)
      skill.effects.any? { |effect| effect.code == 21 || effect.code == 22 } # Buff/Debuff
    end
    
    def support_armor?(armor)
      return false unless armor
      # Check for armor with support-related features
      armor.features.any? { |feature| feature.code == 22 } # Parameter buff
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Threat Calculation
  #--------------------------------------------------------------------------
  module ThreatCalculation
    def calculate_threat_level(target)
      base_threat = 100
      
      # Calculate base stats threat
      stats_threat = calculate_stats_threat(target)
      
      # Calculate state threat
      state_threat = calculate_state_threat(target)
      
      # Calculate equipment threat
      equip_threat = calculate_equipment_threat(target)
      
      # Calculate role threat
      role_threat = calculate_role_threat(target)
      
      # Calculate HP-based threat
      hp_threat = calculate_hp_threat(target)
      
      total_threat = base_threat + stats_threat + state_threat + 
                    equip_threat + role_threat + hp_threat
      
      # Apply situational modifiers
      total_threat = apply_situational_modifiers(total_threat, target)
      
      total_threat
    end
    
    private
    
    def calculate_stats_threat(target)
      threat = 0
      THREAT_WEIGHTS.each do |stat, weight|
        case stat
        when :level
          threat += target.level * weight
        when :hp
          threat += target.hp * weight
        when :atk
          threat += target.atk * weight
        when :def
          threat += target.def * weight
        when :agi
          threat += target.agi * weight
        when :mat
          threat += target.mat * weight
        when :mdf
          threat += target.mdf * weight
        end
      end
      threat
    end
    
    def calculate_state_threat(target)
      threat = 0
      target.states.each do |state|
        # Base state threat
        threat += STATE_THREAT_BONUS[state.id] || 0
        
        # Custom state threat from notes
        if state.respond_to?(:target_weight)
          threat += state.target_weight
        end
        
        # Priority state bonus
        if state.respond_to?(:priority_target) && state.priority_target
          threat += 100
        end
      end
      threat
    end
    
    def calculate_equipment_threat(target)
      return 0 unless target.is_a?(Game_Actor)
      
      threat = 0
      # Weapon threat
      target.weapons.each do |weapon|
        next unless weapon
        threat += weapon.atk * 0.5
        threat += weapon.mat * 0.3 if weapon.damage.magical?
      end
      
      # Armor threat
      target.armors.each do |armor|
        next unless armor
        threat += armor.def * 0.3
        threat += armor.mdf * 0.2
      end
      
      threat
    end
    
    def calculate_role_threat(target)
      return 0 unless target.is_a?(Game_Actor)
      
      threat = 0
      threat += 40 if healer?(target)
      threat += 30 if mage?(target)
      threat += 25 if tank?(target)
      threat += 20 if dps?(target)
      
      threat
    end
    
    def calculate_hp_threat(target)
      # Lower HP = higher threat (finish them off)
      hp_ratio = target.hp.to_f / target.mhp
      (1 - hp_ratio) * 50
    end
    
    def apply_situational_modifiers(threat, target)
      # Apply battle-specific modifiers
      threat *= 1.2 if target.state?(critical_state_id) # Critical state bonus
      
      # Apply enemy-specific modifiers
      threat *= enemy_threat_modifier(target)
      
      threat
    end
    
    def enemy_threat_modifier(target)
      # Can be overridden by specific enemy types
      case enemy_type
      when :aggressive
        1.2
      when :defensive
        0.8
      else
        1.0
      end
    end
    
    def critical_state_id
      # State ID for critical HP (usually state 1 - Death)
      1
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Weighted Target Selection
  #--------------------------------------------------------------------------
  module WeightedSelection
    def weighted_target_selection(enemies)
      weights = enemies.map { |enemy| [enemy, calculate_target_weight(enemy)] }
      total_weight = weights.sum(&:last)
      
      return enemies.sample if total_weight <= 0
      
      random = rand(total_weight)
      current_weight = 0
      
      weights.each do |enemy, weight|
        current_weight += weight
        return enemy if random < current_weight
      end
      
      enemies.sample
    end
    
    def calculate_target_weight(target)
      weight = 100  # Base weight
      
      # HP-based weighting
      hp_ratio = target.hp.to_f / target.mhp
      weight += (1 - hp_ratio) * 50  # Prioritize damaged targets
      
      # State-based weighting
      target.states.each do |state|
        weight += STATE_THREAT_BONUS[state.id] || 0
        if state.respond_to?(:target_weight)
          weight += state.target_weight
        end
      end
      
      # Role-based weighting
      weight += 30 if healer?(target)
      weight += 20 if mage?(target)
      weight += 15 if tank?(target)
      
      # Equipment weighting
      weight += calculate_equipment_weight(target)
      
      weight
    end
    
    def calculate_equipment_weight(target)
      return 0 unless target.is_a?(Game_Actor)
      
      weight = 0
      target.weapons.each { |w| weight += w.atk * 0.2 if w }
      target.armors.each { |a| weight += a.def * 0.1 if a }
      
      weight
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Memory System
  #--------------------------------------------------------------------------
  module TargetMemory
    def initialize_target_memory
      @last_target = nil
      @target_history = []
      @turn_counter = 0
    end
    
    def remember_target(target)
      return unless REMEMBER_TARGETS
      
      @last_target = target
      @target_history << { target: target, turn: @turn_counter }
      
      # Keep only last 5 targets
      @target_history.shift if @target_history.size > 5
    end
    
    def should_retarget_last?(enemies)
      return false unless REMEMBER_TARGETS
      return false unless @last_target
      return false unless @last_target.alive?
      return false unless enemies.include?(@last_target)
      
      rand < RETARGET_CHANCE
    end
    
    def update_turn_counter
      @turn_counter += 1
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Note Tag Parsing
  #--------------------------------------------------------------------------
  module NoteTags
    def parse_enemy_notes
      return @target_type if @target_type
      
      notes = enemy.note
      @target_type = DEFAULT_TARGET_TYPE
      
      # Parse target type
      if notes =~ /<target_type:\s*(\w+)>/i
        type = $1.to_sym
        @target_type = type if TARGET_TYPES.key?(type)
      end
      
      @target_type
    end
    
    def enemy_type
      parse_enemy_notes
    end
    
    def parse_state_notes(state)
      return unless state.respond_to?(:note)
      
      notes = state.note
      
      # Parse target weight
      if notes =~ /<target_weight:\s*(\d+)>/i
        state.define_singleton_method(:target_weight) { $1.to_i }
      end
      
      # Parse priority target
      if notes =~ /<priority_target:\s*(\w+)>/i
        state.define_singleton_method(:priority_target) { $1.downcase == 'true' }
      end
    end
  end
end

#==============================================================================
# ■ Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  include EnemyTargeting::RoleDetection
  include EnemyTargeting::TargetSelection
  include EnemyTargeting::ThreatCalculation
  include EnemyTargeting::WeightedSelection
  include EnemyTargeting::TargetMemory
  include EnemyTargeting::NoteTags
  
  #--------------------------------------------------------------------------
  # ● Alias Methods
  #--------------------------------------------------------------------------
  alias enemy_targeting_initialize initialize
  alias enemy_targeting_make_actions make_actions
  
  #--------------------------------------------------------------------------
  # ● Object Initialization
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    enemy_targeting_initialize(index, enemy_id)
    initialize_target_memory
  end
  
  #--------------------------------------------------------------------------
  # ● Create Actions
  #--------------------------------------------------------------------------
  def make_actions
    enemy_targeting_make_actions
    update_turn_counter
  end
  
  #--------------------------------------------------------------------------
  # ● Make Action Targets (Override)
  #--------------------------------------------------------------------------
  def make_action_targets
    targets = super
    
    # Only modify single-target selections
    if action && action.scope == 1 && targets.is_a?(Array) && targets.size == 1
      targets = [select_strategic_target(targets)]
    end
    
    # Remember the target
    remember_target(targets.first) if targets && targets.first
    
    targets
  end
  
  #--------------------------------------------------------------------------
  # ● Strategic Target Selection
  #--------------------------------------------------------------------------
  def select_strategic_target(default_targets)
    enemies = opponents_unit.alive_members
    
    # Check if we should retarget the last target
    if should_retarget_last?(enemies)
      return @last_target
    end
    
    # Get the targeting method for this enemy type
    target_type = enemy_type
    method_name = TARGET_TYPES[target_type][:method]
    
    if respond_to?(method_name)
      send(method_name, enemies)
    else
      default_targets.first
    end
  end
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  # Add role detection methods for actors
  include EnemyTargeting::RoleDetection
end

#==============================================================================
# ■ RPG::State
#==============================================================================
class RPG::State
  # Allow state note parsing
  include EnemyTargeting::NoteTags
end

#==============================================================================
# ■ DataManager
#==============================================================================
module DataManager
  class << self
    alias enemy_targeting_load_database load_database
  end
  
  def self.load_database
    enemy_targeting_load_database
    load_enemy_targeting_notetags
  end
  
  def self.load_enemy_targeting_notetags
    # Load state notetags
    $data_states.compact.each do |state|
      next unless state
      state.parse_state_notes(state)
    end
  end
end