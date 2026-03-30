#==============================================================================
# ■ Advanced Enemy Targeting System
#------------------------------------------------------------------------------
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
  REMEMBER_TARGETS = false      # Enable previous target memory
  RETARGET_CHANCE = 0.8        # 80% chance to target same character again
  
  # Global battle observations for all enemies
  @@global_battle_observations = {
    healing: {},
    magic: {},
    damage: {}
  }
  
  # Access global observations
  def self.global_battle_observations
    @@global_battle_observations
  end
  
  # Clear global observations (call at battle start)
  def self.clear_global_observations
    @@global_battle_observations = {
      healing: {},
      magic: {},
      damage: {}
    }
  end
  
  # Threat calculation weights
  THREAT_WEIGHTS = {
    level: 2.0,        # Level multiplier
    hp: 0.1,          # Current HP contribution
    atk: 1.5,         # Attack power contribution
    mat: 1.2,         # Magic attack contribution
    def: 1.0,         # Defense contribution
    agi: 0.8,         # Agility contribution
    mdf: 0.9,         # Magic defense contribution
  }
  
  # State threat bonuses
  STATE_THREAT_BONUS = {
    # State ID => threat bonus
    2 => 30,   # Poison
    3 => 40,   # Paralysis
    4 => 25,   # Blind
    5 => 35,   # Silence
    9 => 10,   # Defense
    26 => 50,   # Burned
    29 => 51,   # Snowed
    44 => 52,   # Cycloned
    45 => 53,   # Electrified
    46 => 54,   # Soaked
    47 => 55,   # Entangled
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
    opportunistic: {
      description: "Targets characters with status ailments",
      method: :target_opportunistic
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
    },
    revengeful: {
      description: "Always attacks last character that attacked them",
      method: :target_revengeful
    }
  }
  
  #--------------------------------------------------------------------------
  # ● Equipment Type Detection
  #--------------------------------------------------------------------------
  EQUIPMENT_TYPES = {
    protection: [1, 2],     # Shield type IDs (adjust to your database)
    weapon_heavy: [2, 8, 11, 16, 21],  # Heavy weapon types
    weapon_magic: [9, 14, 15, 18, 20],  # Magic weapon types
    armor_heavy: [3, 8, 11],   # Heavy armor types
    armor_light: [5, 6, 12]  # Light armor types
  }
  
  #--------------------------------------------------------------------------
  # ● Role Detection Methods (Observable Only)
  #--------------------------------------------------------------------------
  module RoleDetection
    def healer?(actor)
      return false unless actor.is_a?(Game_Actor)
      # Only detect based on observed healing actions
      observed_healing_actions(actor) >= 1
    end
    
    def mage?(actor)
      return false unless actor.is_a?(Game_Actor)
      # Detect based on observed magic usage or visible magic equipment
      observed_magic_actions(actor) >= 1 || has_visible_magic_equipment?(actor)
    end
    
    def tank?(actor)
      return false unless actor.is_a?(Game_Actor)
      # Detect based on visible high defense or heavy equipment
      actor.def > 100 || has_visible_heavy_equipment?(actor)
    end
    
    def dps?(actor)
      return false unless actor.is_a?(Game_Actor)
      # Detect based on observed damage output or visible weapons
      observed_damage_output(actor) > 50 || has_visible_damage_equipment?(actor)
    end
    
    # Observable behavior tracking
    def observed_healing_actions(actor)
      # Use global observations for enemy access
      return EnemyTargeting.global_battle_observations[:healing][actor.id] || 0
    end
    
    def observed_magic_actions(actor)
      # Use global observations for enemy access
      return EnemyTargeting.global_battle_observations[:magic][actor.id] || 0
    end
    
    def observed_damage_output(actor)
      # Use global observations for enemy access
      return EnemyTargeting.global_battle_observations[:damage][actor.id] || 0
    end
    
    # Global observation recording methods
    def record_global_healing_action(actor, amount)
      p("recording healing action: " + actor.name + " healed " + amount.to_s)
      return unless actor.is_a?(Game_Actor)
      global_obs = EnemyTargeting.global_battle_observations
      global_obs[:healing][actor.id] ||= 0
      global_obs[:healing][actor.id] += 1
    end
    
    def record_global_magic_action(actor)
      return unless actor.is_a?(Game_Actor)
      global_obs = EnemyTargeting.global_battle_observations
      global_obs[:magic][actor.id] ||= 0
      global_obs[:magic][actor.id] += 1
    end
    
    def record_global_damage_action(actor, damage)
      return unless actor.is_a?(Game_Actor)
      global_obs = EnemyTargeting.global_battle_observations
      global_obs[:damage][actor.id] ||= 0
      global_obs[:damage][actor.id] += damage
    end
    
    def record_healing_action(actor, amount)
      return unless actor.is_a?(Game_Actor)
      @battle_observations ||= {}
      @battle_observations[:healing] ||= {}
      @battle_observations[:healing][actor.id] ||= 0
      @battle_observations[:healing][actor.id] += 1
    end
    
    def record_magic_action(actor)
      return unless actor.is_a?(Game_Actor)
      @battle_observations ||= {}
      @battle_observations[:magic] ||= {}
      @battle_observations[:magic][actor.id] ||= 0
      @battle_observations[:magic][actor.id] += 1
    end
    
    def record_damage_action(actor, damage)
      return unless actor.is_a?(Game_Actor)
      @battle_observations ||= {}
      @battle_observations[:damage] ||= {}
      @battle_observations[:damage][actor.id] ||= 0
      @battle_observations[:damage][actor.id] += damage
    end
    
    private
    
    def has_visible_magic_equipment?(actor)
      # Check if actor has any magic-type weapons
      actor.weapons.any? { 
        |w| 
          w && EnemyTargeting::EQUIPMENT_TYPES[:weapon_magic].include?(w.wtype_id)
        }
    end
    
    def has_visible_heavy_equipment?(actor)
      # Check for heavy weapon types and heavy armor types
      heavy_weapons = actor.weapons.any? { |w| 
        w && EnemyTargeting::EQUIPMENT_TYPES[:weapon_heavy].include?(w.wtype_id)
      }
      heavy_armor = actor.armors.any? { |a| 
        a && EnemyTargeting::EQUIPMENT_TYPES[:armor_heavy].include?(a.atype_id)
      }
      shields = actor.armors.any? { |a| 
        a && EnemyTargeting::EQUIPMENT_TYPES[:protection].include?(a.etype_id)
      }
      heavy_weapons || heavy_armor || shields
    end
    
    def has_visible_damage_equipment?(actor)
      # Check if any weapon's attack is 50% higher than actor's base attack
      actor.weapons.any? { |w| 
        w && w.atk > (actor.atk * 1.5)
      }
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Target Selection Methods
  #--------------------------------------------------------------------------
  module TargetSelection
    # Target highest threat character
    def target_aggressive(enemies)
      p("-------evaluating aggressive:" + enemies.max_by { |enemy| calculate_threat_level(enemy) }.to_s)
      enemies.max_by { |enemy| calculate_threat_level(enemy) }
    end
    
    # Target actors with highest ailment-based threat
    def target_opportunistic(enemies)
      p("-------evaluating opportunistic")
      # Calculate state threat for each enemy
      enemies_with_threat = enemies.map do |enemy|
        state_threat = calculate_state_threat(enemy)
        [enemy, state_threat]
      end
      
      # Sort by state threat (highest first) and return the top target
      enemies_with_threat.sort_by! { |enemy, threat| -threat }
      
      # Return the enemy with highest state threat, or random if no threats
      highest_threat_enemy = enemies_with_threat.first
      return highest_threat_enemy[0] if highest_threat_enemy && highest_threat_enemy[1] > 0
      
      # Fallback to random targeting if no state threats
      enemies.sample
    end
    
    # Advanced tactical targeting
    def target_tactical(enemies)
      p("-------evaluating tactical")
      weighted_target_selection(enemies)
    end
    
    # Default random targeting
    def target_random(enemies)
      p("-------evaluating random:" + enemies.sample.to_s)
      enemies.sample
    end
    
    # Always target healers
    def target_healer_focus(enemies)
      healers = enemies.select { |e| healer?(e) }
      p("-------healers found: " + healers.map(&:name).join(", "))
      healers.any? ? healers.sample : enemies.sample
    end
    
    # Target magic users
    def target_mage_focus(enemies)
      mages = enemies.select { |e| mage?(e) }
      p("-------mages found: " + mages.map(&:name).join(", "))
      mages.any? ? mages.sample : enemies.sample
    end
    
    # Target tanks
    def target_tank_focus(enemies)
      tanks = enemies.select { |e| tank?(e) }
      p("-------tanks found: " + tanks.map(&:name).join(", "))
      tanks.any? ? tanks.sample : enemies.sample
    end
    
    # Target weakest character
    def target_weakest_first(enemies)
      p("-------evaluating weakest:" + enemies.min_by(&:hp).name)
      enemies.min_by(&:hp)
    end
    
    # Target strongest character
    def target_strongest_first(enemies)
      p("-------evaluating strongest:" + enemies.max_by(&:level).name)
      enemies.max_by(&:level)
    end
    
    # Target last attacker (revengeful)
    def target_revengeful(enemies)
      if(@last_attacker)
        p("-------evaluating revengeful:" + @last_attacker.name)
      end
      return @last_attacker if @last_attacker && @last_attacker.alive? && enemies.include?(@last_attacker)
      enemies.sample
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
      # Only use observable stats
      threat += target.hp * EnemyTargeting::THREAT_WEIGHTS[:hp]  # HP is observable
      threat += target.def * EnemyTargeting::THREAT_WEIGHTS[:def]  # Defense is observable
      # Level, ATK, MAT, AGI, MDF are NOT directly observable
      threat
    end
    
    def calculate_state_threat(target)
      threat = 0
      target.states.each do |state|
        # Base state threat
        threat += EnemyTargeting::STATE_THREAT_BONUS[state.id] || 0
        
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
        weight += EnemyTargeting::STATE_THREAT_BONUS[state.id] || 0
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
      @last_attacker = nil
      @target_history = []
      @turn_counter = 0
    end
    
    def remember_target(target)
      return unless EnemyTargeting::REMEMBER_TARGETS
      
      @last_target = target
      @target_history << { target: target, turn: @turn_counter }
      
      # Keep only last 5 targets
      @target_history.shift if @target_history.size > 5
    end
    
    def should_retarget_last?(enemies)
      return false unless EnemyTargeting::REMEMBER_TARGETS
      return false unless @last_target
      return false unless @last_target.alive?
      return false unless enemies.include?(@last_target)
      rand < EnemyTargeting::RETARGET_CHANCE
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
      
      enemy_obj = enemy
      # p("enemy object: " + enemy_obj.to_s)
      # p("enemy ID: " + enemy_obj.id.to_s) if enemy_obj.respond_to?(:id)
      
      notes = enemy_obj.note
      # p("enemy notes: " + notes.to_s)
      @target_type = EnemyTargeting::DEFAULT_TARGET_TYPE
      
      # Parse target type
      if notes =~ /<target_type:\s*(\w+)>/i
        type = $1.to_sym
        # p("found target type: " + type.to_s)
        @target_type = type if EnemyTargeting::TARGET_TYPES.key?(type)
      else
        # p("no target type tag found in notes")
      end
      
      # p("final target type: " + @target_type.to_s)
      @target_type
    end
    
    def enemy_type
      # p("calling enemy_type for enemy: #{@enemy_id}")
      result = parse_enemy_notes
      # p("enemy_type returning: " + result.to_s)
      result
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
  alias enemy_targeting_execute_damage execute_damage
  
  #--------------------------------------------------------------------------
  # ● Object Initialization
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    enemy_targeting_initialize(index, enemy_id)
    initialize_target_memory
    initialize_observation_system
  end
  
  #--------------------------------------------------------------------------
  # ● Create Actions
  #--------------------------------------------------------------------------
  def make_actions
    enemy_targeting_make_actions
    update_turn_counter
  end
  #--------------------------------------------------------------------------
  # ● Execute Damage (Override to record observations)
  # This method is called when an Enemy receives an attack
  def execute_damage(user)
    enemy_targeting_execute_damage(user)
    # Record observations about the attacker globally for all enemies
    if user.is_a?(Game_Actor)
      p("Enemy #{self.name} targeted by actor #{user.name}")
      self.record_attacker(user)
      # Record globally for all enemy access
      record_global_damage_action(user, @result.hp_damage)
      # Check if this was a magic action
      if user.current_action && user.current_action.item && user.current_action.item.hit_type == 2
        record_global_magic_action(user)
      end
      # Also record locally for this enemy's personal observations
      record_damage_action(user, @result.hp_damage)
      record_magic_action(user) if user.current_action && user.current_action.item && user.current_action.item.hit_type == 2
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Initialize Observation System
  #--------------------------------------------------------------------------
  def initialize_observation_system
    @battle_observations = {
      healing: {},
      magic: {},
      damage: {}
    }
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
    
    # Get targeting method for this enemy type
    target_type = enemy_type
    method_name = EnemyTargeting::TARGET_TYPES[target_type][:method]
    
    if respond_to?(method_name)
      target = send(method_name, enemies)
      # Ensure we have a valid target
      target && target.alive? ? target : enemies.sample
    else
      enemies.sample
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Record Damage Action
  #--------------------------------------------------------------------------
  def record_damage_action(user, damage)
    @battle_observations[:damage][user.id] ||= 0
    @battle_observations[:damage][user.id] += damage
  end
  
  #--------------------------------------------------------------------------
  # ● Record Healing Action
  #--------------------------------------------------------------------------
  def record_healing_action(user, healing)
    @battle_observations[:healing][user.id] ||= 0
    @battle_observations[:healing][user.id] += healing
  end
  
  #--------------------------------------------------------------------------
  # ● Record Magic Action
  #--------------------------------------------------------------------------
  def record_magic_action(user)
    @battle_observations[:magic][user.id] ||= 0
    @battle_observations[:magic][user.id] += 1
  end
  
  #--------------------------------------------------------------------------
  # ● Record Attacker
  #--------------------------------------------------------------------------
  def record_attacker(attacker)
    if(attacker.is_a?(Game_Actor))
      @last_attacker = attacker
    end
  end
end
#==============================================================================
# ■ Game_Action
#==============================================================================
class Game_Action
  alias advanced_targets_for_opponents targets_for_opponents
  # Add targeting methods for actions
  def targets_for_opponents
    if item.for_random?
      Array.new(item.number_of_targets) { opponents_unit.random_target }
    elsif item.for_one?
      num = 1 + (attack? ? subject.atk_times_add.to_i : 0)
      # Always use strategic targeting for enemies that support it
      if subject.is_a?(Game_Enemy) && subject.respond_to?(:select_strategic_target)
        targets = [subject.select_strategic_target(opponents_unit.alive_members)]
        targets.compact! # Remove nil targets
        targets = [opponents_unit.random_target] if targets.empty?
        # Remember the selected target
        subject.remember_target(targets.first) if targets && targets.first
        targets * num
      elsif @target_index < 0
        # Fallback for non-enemy battlers or those without strategic targeting
        [opponents_unit.random_target] * num
      else
        [opponents_unit.smooth_target(@target_index)] * num
      end
    else
      opponents_unit.alive_members
    end
  end
end
#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  # Add role detection methods for actors
  include EnemyTargeting::RoleDetection
  
  #--------------------------------------------------------------------------
  # ● Alias Methods
  #--------------------------------------------------------------------------
  alias actor_targeting_execute_damage execute_damage
  alias actor_targeting_make_damage_value make_damage_value
  
  # Store damage values before result clearing
  attr_accessor :last_hp_damage
  attr_accessor :last_mp_damage
  
  #--------------------------------------------------------------------------
  # ● Make Damage Value (Override to store damage values)
  #--------------------------------------------------------------------------
  def make_damage_value(user, item)
    actor_targeting_make_damage_value(user, item)
    # Store damage values before they get cleared
    @last_hp_damage = @result.hp_damage
    @last_mp_damage = @result.mp_damage
  end
  
  #--------------------------------------------------------------------------
  # ●# Execute Damage (Override to record when actors receive damage from other actors)
  # This method is called when an Actor receives damage/healing from another actor
  def execute_damage(attacker)
    actor_targeting_execute_damage(attacker)
    # Record actor actions globally for enemy observation
    p("Actor #{self.name} targeted by #{attacker.name}")
    if(attacker.is_a?(Game_Actor))
      # Use stored damage values since @result.hp_damage may be cleared
      hp_damage = @last_hp_damage || @result.hp_damage || 0
      p("Stored damage: #{hp_damage}")
      
      # Check if this was a healing action
      if hp_damage < 0
        record_global_healing_action(attacker, hp_damage.abs)
      end
      # Check if this was a magic action
      if attacker.current_action && attacker.current_action.item && attacker.current_action.item.hit_type == 2
        record_global_magic_action(attacker)
      end
      # Record damage output (negative healing becomes positive damage for tracking)
      if hp_damage > 0
        record_global_damage_action(attacker, hp_damage)
      end
    end
  end
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



