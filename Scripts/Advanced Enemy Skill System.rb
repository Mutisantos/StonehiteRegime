#==============================================================================
# Advanced Enemy Skill System
# Author: mutisantos
#------------------------------------------------------------------------------
# Version: 1.0
# 
# This script provides advanced enemy skill selection and learning capabilities:
# - Intelligence-based skill selection (1-100 scale)
# - Skill effectiveness tracking and learning
# - Adaptive skill usage based on battle experience
# - Target-specific skill effectiveness memory
#
# Installation:
# Place this script below Advanced Enemy Targeting System and above Main
#
# Usage:
# Add this tag to enemy notes in the database:
# <enemy_intelligence: 50>  - Intelligence level (1-100)
#
# Intelligence Levels:
# 1-20:   Random/Basic skill selection
# 21-50:  Basic effectiveness consideration
# 51-80:  Advanced effectiveness tracking
# 81-100: Sophisticated adaptive skill selection
#==============================================================================

module EnemySkillSystem
  #--------------------------------------------------------------------------
  # ● Configuration
  #--------------------------------------------------------------------------
  # Default intelligence if not specified
  DEFAULT_INTELLIGENCE = 30
  
  # Learning rate multiplier (how quickly enemies learn)
  LEARNING_RATE = 1.0
  
  # Minimum uses before a skill is considered "learned"
  MIN_SKILL_USES_FOR_LEARNING = 2
  
  # Effectiveness decay rate (how quickly old data becomes less relevant)
  EFFECTIVENESS_DECAY = 0.95
  
  # Global skill effectiveness database (shared across all enemies)
  @@global_skill_effectiveness = {}
  
  #--------------------------------------------------------------------------
  # ● Access Global Effectiveness Data
  #--------------------------------------------------------------------------
  def self.global_skill_effectiveness
    @@global_skill_effectiveness
  end
  
  #--------------------------------------------------------------------------
  # ● Clear Global Effectiveness Data (call at battle start)
  #--------------------------------------------------------------------------
  def self.clear_global_effectiveness
    @@global_skill_effectiveness = {}
  end
  
  #--------------------------------------------------------------------------
  # ● Intelligence Level Definitions
  #--------------------------------------------------------------------------
  INTELLIGENCE_TIERS = {
    very_low:   { range: 1..20,   description: "Random/Basic" },
    low:        { range: 21..50,  description: "Basic Consideration" },
    medium:     { range: 51..80,  description: "Advanced Tracking" },
    high:       { range: 81..100, description: "Sophisticated Adaptive" }
  }
  
  #--------------------------------------------------------------------------
  # ● Skill Effectiveness Tracking
  #--------------------------------------------------------------------------
  module SkillEffectiveness
    # Initialize skill effectiveness tracking
    def initialize_skill_effectiveness
      @skill_effectiveness = {}
      @skill_uses = {}
      @target_type_effectiveness = {}
    end
    
    # Record skill usage and results
    def record_skill_usage(skill_id, target, damage, success)
      return unless skill_id && skill_id > 0
      
      @skill_uses[skill_id] ||= 0
      @skill_uses[skill_id] += 1
      
      @skill_effectiveness[skill_id] ||= 0
      
      # Calculate effectiveness score
      effectiveness = calculate_effectiveness_score(target, damage, success)
      @skill_effectiveness[skill_id] += effectiveness * LEARNING_RATE
      
      # Track effectiveness against target types
      record_target_type_effectiveness(skill_id, target, effectiveness)
      
      # Update global effectiveness for enemy learning
      update_global_skill_effectiveness(skill_id, target, effectiveness)
      
      p("Enemy #{self.name} used skill #{skill_id} with effectiveness: #{effectiveness}")
    end
    
    # Calculate effectiveness score based on results
    def calculate_effectiveness_score(target, damage, success)
      return 0 unless success
      
      score = 0
      
      # Damage contribution
      if damage && damage > 0
        # Higher damage = higher effectiveness
        score += damage * 0.1
        
        # Bonus for percentage of target's HP
        hp_ratio = damage.to_f / target.mhp
        score += hp_ratio * 50
      elsif damage && damage < 0
        # Healing effectiveness
        score += damage.abs * 0.15
        hp_ratio = damage.abs.to_f / target.mhp
        score += hp_ratio * 40
      end
      
      # Base success bonus
      score += 10
      
      # Intelligence bonus (smarter enemies get better feedback)
      score *= (1 + intelligence_level * 0.01)
      
      score
    end
    
    # Record effectiveness against specific target types
    def record_target_type_effectiveness(skill_id, target, effectiveness)
      target_type = determine_target_type(target)
      
      @target_type_effectiveness[skill_id] ||= {}
      @target_type_effectiveness[skill_id][target_type] ||= 0
      @target_type_effectiveness[skill_id][target_type] += effectiveness
    end
    
    # Determine target type for effectiveness tracking
    def determine_target_type(target)
      return :unknown unless target.is_a?(Game_Actor)
      
      if healer?(target)
        :healer
      elsif mage?(target)
        :mage
      elsif tank?(target)
        :tank
      elsif dps?(target)
        :dps
      else
        :generic
      end
    end
    
    # Update global skill effectiveness database
    def update_global_skill_effectiveness(skill_id, target, effectiveness)
      enemy_type = self.enemy_type
      
      @@global_skill_effectiveness[enemy_type] ||= {}
      @@global_skill_effectiveness[enemy_type][skill_id] ||= 0
      @@global_skill_effectiveness[enemy_type][skill_id] += effectiveness * 0.5
    end
    
    # Get effectiveness score for a skill
    def get_skill_effectiveness(skill_id)
      @skill_effectiveness[skill_id] || 0
    end
    
    # Get effectiveness against specific target type
    def get_target_type_effectiveness(skill_id, target)
      target_type = determine_target_type(target)
      
      if @target_type_effectiveness[skill_id] && @target_type_effectiveness[skill_id][target_type]
        @target_type_effectiveness[skill_id][target_type]
      else
        0
      end
    end
    
    # Get global effectiveness for this enemy type
    def get_global_skill_effectiveness(skill_id)
      enemy_type = self.enemy_type
      
      if @@global_skill_effectiveness[enemy_type] && @@global_skill_effectiveness[enemy_type][skill_id]
        @@global_skill_effectiveness[enemy_type][skill_id]
      else
        0
      end
    end
    
    # Check if skill is sufficiently learned
    def skill_learned?(skill_id)
      (@skill_uses[skill_id] || 0) >= MIN_SKILL_USES_FOR_LEARNING
    end
    
    # Decay effectiveness over time (battle turns)
    def decay_effectiveness
      @skill_effectiveness.each do |skill_id, score|
        @skill_effectiveness[skill_id] = score * EFFECTIVENESS_DECAY
      end
      
      @target_type_effectiveness.each do |skill_id, types|
        types.each do |target_type, score|
          @target_type_effectiveness[skill_id][target_type] = score * EFFECTIVENESS_DECAY
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Intelligent Skill Selection
  #--------------------------------------------------------------------------
  module IntelligentSelection
    # Select best skill based on intelligence and effectiveness
    def select_intelligent_skill(action_list)
      intel = intelligence_level
      
      case intelligence_tier(intel)
      when :very_low
        select_random_skill(action_list)
      when :low
        select_basic_effective_skill(action_list)
      when :medium
        select_advanced_effective_skill(action_list)
      when :high
        select_sophisticated_skill(action_list)
      else
        select_random_skill(action_list)
      end
    end
    
    # Determine intelligence tier
    def intelligence_tier(level)
      INTELLIGENCE_TIERS.each do |tier, data|
        return tier if data[:range].include?(level)
      end
      :very_low
    end
    
    # Random skill selection (very low intelligence)
    def select_random_skill(action_list)
      p("-------selecting random skill (very low intelligence)")
      action_list.sample
    end
    
    # Basic effectiveness consideration (low intelligence)
    def select_basic_effective_skill(action_list)
      p("-------selecting basic effective skill (low intelligence)")
      # Consider global effectiveness for this enemy type
      scored_skills = action_list.map do |action|
        skill = $data_skills[action.skill_id]
        effectiveness = get_global_skill_effectiveness(action.skill_id)
        [action, effectiveness]
      end
      
      # Add some randomness based on intelligence
      scored_skills.each do |action, effectiveness|
        scored_skills[scored_skills.index([action, effectiveness])] = 
          [action, effectiveness + rand(50)]
      end
      
      best = scored_skills.max_by { |action, score| score }
      best ? best[0] : action_list.sample
    end
    
    # Advanced effectiveness tracking (medium intelligence)
    def select_advanced_effective_skill(action_list)
      p("-------selecting advanced effective skill (medium intelligence)")
      # Consider both personal and global effectiveness
      scored_skills = action_list.map do |action|
        skill = $data_skills[action.skill_id]
        personal_effectiveness = get_skill_effectiveness(action.skill_id)
        global_effectiveness = get_global_skill_effectiveness(action.skill_id)
        combined = personal_effectiveness * 0.7 + global_effectiveness * 0.3
        
        # Consider skill cost (MP/TP)
        cost_penalty = skill.mp_cost * 0.5 + skill.tp_cost * 0.3
        
        [action, combined - cost_penalty]
      end
      
      # Add strategic consideration
      target = select_strategic_target(opponents_unit.alive_members)
      if target
        scored_skills.each_with_index do |(action, score), i|
          target_effectiveness = get_target_type_effectiveness(action.skill_id, target)
          scored_skills[i] = [action, score + target_effectiveness * 0.5]
        end
      end
      
      best = scored_skills.max_by { |action, score| score }
      best ? best[0] : action_list.sample
    end
    
    # Sophisticated adaptive skill selection (high intelligence)
    def select_sophisticated_skill(action_list)
      p("-------selecting sophisticated skill (high intelligence)")
      # Comprehensive evaluation
      scored_skills = action_list.map do |action|
        skill = $data_skills[action.skill_id]
        score = 0
        
        # Personal effectiveness (weighted highest)
        score += get_skill_effectiveness(action.skill_id) * 0.5
        
        # Global effectiveness for enemy type
        score += get_global_skill_effectiveness(action.skill_id) * 0.2
        
        # Target-specific effectiveness
        target = select_strategic_target(opponents_unit.alive_members)
        if target
          score += get_target_type_effectiveness(action.skill_id, target) * 0.3
          
          # Consider target's state and weaknesses
          score += evaluate_target_vulnerability(target, skill) * 0.2
          
          # Consider skill scope vs target situation
          score += evaluate_scope_appropriateness(skill, target) * 0.1
        end
        
        # Cost-effectiveness analysis
        cost_ratio = (skill.mp_cost + skill.tp_cost).to_f / [skill.damage.eval(self, target, $game_variables), 1].max
        score -= cost_ratio * 10 if cost_ratio > 0
        
        # Skill variety bonus (avoid spamming same skill)
        recent_uses = @skill_uses[action.skill_id] || 0
        score -= recent_uses * 2
        
        [action, score]
      end
      
      # Add minimal randomness for unpredictability
      scored_skills.each_with_index do |(action, score), i|
        scored_skills[i] = [action, score + rand(10)]
      end
      
      best = scored_skills.max_by { |action, score| score }
      best ? best[0] : action_list.sample
    end
    
    # Evaluate target's vulnerability to specific skill
    def evaluate_target_vulnerability(target, skill)
      score = 0
      
      # Check elemental weakness
      if skill.damage.element_id > 0
        element_rate = target.element_rate(skill.damage.element_id)
        score += (element_rate - 1.0) * 50
      end
      
      # Check state susceptibility
      skill.effects.each do |effect|
        if effect.code == Game_Battler::EFFECT_ADD_STATE
          state_rate = target.state_rate(effect.data_id)
          score += (state_rate - 1.0) * 30
        end
      end
      
      # Check if target has states that skill can exploit
      target.states.each do |state|
        # Some skills might be more effective against certain states
        score += 10 if state.id == 2 # Poison example
      end
      
      score
    end
    
    # Evaluate if skill scope is appropriate for situation
    def evaluate_scope_appropriateness(skill, target)
      score = 0
      
      # Consider number of alive opponents
      opponent_count = opponents_unit.alive_members.size
      
      if skill.for_all?
        # AoE skills are better when many opponents
        score += opponent_count * 5
      elsif skill.for_one?
        # Single target skills are better for focused damage
        score += 10 if opponent_count <= 2
      end
      
      score
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Note Tag Parsing
  #--------------------------------------------------------------------------
  module NoteTags
    def parse_intelligence_notes
      return @intelligence_level if @intelligence_level
      
      enemy_obj = enemy
      notes = enemy_obj.note
      @intelligence_level = EnemySkillSystem::DEFAULT_INTELLIGENCE
      
      # Parse intelligence level
      if notes =~ /<enemy_intelligence:\s*(\d+)>/i
        level = $1.to_i
        @intelligence_level = [[level, 1].max, 100].min # Clamp between 1-100
      end
      
      @intelligence_level
    end
    
    def intelligence_level
      parse_intelligence_notes
    end
  end
end

#==============================================================================
# ■ Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  include EnemySkillSystem::SkillEffectiveness
  include EnemySkillSystem::IntelligentSelection
  include EnemySkillSystem::NoteTags
  
  #--------------------------------------------------------------------------
  # ● Alias Methods
  #--------------------------------------------------------------------------
  alias enemy_skill_system_initialize initialize
  alias enemy_skill_system_make_actions make_actions
  alias enemy_skill_system_execute_damage execute_damage
  
  #--------------------------------------------------------------------------
  # ● Object Initialization
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    enemy_skill_system_initialize(index, enemy_id)
    initialize_skill_effectiveness
  end
  
  #--------------------------------------------------------------------------
  # ● Create Actions
  #--------------------------------------------------------------------------
  def make_actions
    enemy_skill_system_make_actions
    
    # Apply intelligent skill selection
    if @actions.any?
      intelligent_skill_selection
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Intelligent Skill Selection
  #--------------------------------------------------------------------------
  def intelligent_skill_selection
    # Get available actions from enemy database
    action_list = enemy.actions.select { |a| action_conditions_met?(a) }
    
    if action_list.any?
      # Select best action based on intelligence
      selected_action = select_intelligent_skill(action_list)
      
      # Replace first action with intelligent selection
      if selected_action && @actions[0]
        @actions[0].set_enemy_action(selected_action)
        p("Enemy #{self.name} selected skill #{selected_action.skill_id} (Intelligence: #{intelligence_level})")
      end
    end
    
    # Decay effectiveness at end of turn
    decay_effectiveness
  end
  
  #--------------------------------------------------------------------------
  # ● Check if action conditions are met
  #--------------------------------------------------------------------------
  def action_conditions_met?(action)
    return true unless action.condition_type1
    
    # Simple condition check (can be expanded)
    case action.condition_type1
    when 1 # Always
      true
    when 2 # Turn
      $game_troop.turn_count >= action.condition_param1
    when 3 # HP
      hp_rate <= action.condition_param1
    when 4 # MP
      mp_rate <= action.condition_param1
    when 5 # State
      state?(action.condition_param1)
    when 6 # Party Level
      $game_party.highest_level >= action.condition_param1
    when 7 # Switch
      $game_switches[action.condition_param1]
    else
      true
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Damage (Override to record skill effectiveness)
  #--------------------------------------------------------------------------
  def execute_damage(user)
    enemy_skill_system_execute_damage(user)
    
    # Record skill effectiveness if this enemy used a skill
    if user == self && current_action && current_action.item
      skill_id = current_action.item.id
      
      # Find the target that was hit
      targets = current_action.make_targets
      if targets.any?
        target = targets.first
        damage = @result.hp_damage || 0
        success = @result.hit? || @result.success
        
        record_skill_usage(skill_id, target, damage, success)
      end
    end
  end
end

#==============================================================================
# ■ DataManager
#==============================================================================
module DataManager
  class << self
    alias enemy_skill_system_load_database load_database
  end
  
  def self.load_database
    enemy_skill_system_load_database
    # Clear global effectiveness at database load
    EnemySkillSystem.clear_global_effectiveness
  end
end

#==============================================================================
# ■ BattleManager
#==============================================================================
module BattleManager
  class << self
    alias enemy_skill_system_setup setup
  end
  
  def self.setup(troop_id, can_escape = true, can_lose = false)
    enemy_skill_system_setup(troop_id, can_escape, can_lose)
    # Clear global effectiveness at battle start
    EnemySkillSystem.clear_global_effectiveness
  end
end
