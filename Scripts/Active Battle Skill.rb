# ================================================= =============================
# VXA - RGSS3 - Active Commands Skills [Ver1.0.0] by Mutisantos
# Based on: XP-RGSS-33 command skills [Ver.2.3.0] by Claimh
# ------------------------------------------------- -----------------------------
# To activate the skill by command input.
# If you fail to command input, power decrease (& animation change)
# 
# ================================================= =============================
$imported = {} if $imported.nil?
$imported["Muti-ActiveSkill"] = true

module CommandSkill
  #Define input keys for combinations
  A = Input::C # keyboard: Z
  B = Input::B # Keyboard: X
  C = Input::A # keyboard: C
  X = Input::X # keyboard: A
  Y = Input::Y # keyboard: S
  Z = Input::Z # keyboard: D
  L = Input::L # keyboard: Q
  R = Input::R # keyboard: W
  UP = Input::UP
  DOWN = Input::DOWN
  LEFT = Input::LEFT
  RIGHT = Input::RIGHT
  RAND = "?" # Random key
  DIR = "->" #Random Direccionales
  RKEY = "K" #Random de Z,X,A,S 
# ================================================= =============================
# □ customize START
# ================================================= =============================
  # Input time per key
  KEY_SEC = 1.0

  # Bar of the file name to be displayed when the key input
  T_BAR_NAME = "Graphics/System/note_bar.png"

  # Command display type
  # True: game pad type e.g. A = Z
  # False: keyboard type e.g. Z = Z
  KEY_TYPE = false

  # Whole of the target at the time of command input success (true: Enable | false: disabled)
  ALL_ATK = false
  # Skill ID for whole of
  ALL_ATK_SK = [57, 61]

  # SE of success combo
  COMP_SE = "correct"
  # SE of failure combo
  MISS_SE = "Buzzer1"
  # Changing the target side of animation at the time of failure (true: Enable | false: disabled)
  MISS_ANIME = false

  # Character spacing at the time of the command display
  TEXT_W = 25
  
  # Damage multiplier game variable
  DAMAGE_MULTIPLIER = 102

  # Skill set
  T_SKILL = {
  # SkillID => [[key 1, key 2,...], Failure of power (%) (]
        7  => [[UP, DOWN], 50],
        8  => [[X, A, Z], 50],
        12 => [[LEFT, UP, RIGHT, DOWN], 50], #Salto Elevado
        13 => [[UP, RIGHT], 50],
        14 => [[L, Z, A], 50],
        15 => [[R, X, X, DOWN], 50],
        16 => [[DOWN, RIGHT], 50],
        17 => [[A, B, C], 50],
        18 => [[Y, X, DOWN, B], 50],
        19 => [[LEFT, DOWN,X,Y], 50],
        20 => [[A,B,A,B,A,B,LEFT,LEFT], 50],
        21 => [[A,LEFT,A,LEFT,A,LEFT], 50],
        22 => [[RIGHT, DOWN], 50],
        23 => [[A, B, R], 50],
        24 => [[X, Y, LEFT, R], 50],
        25 => [[LEFT, RIGHT], 50],
        26 => [[X, L, B], 50],
        28 => [[LEFT, DOWN], 50],
        57 => [[RAND, RAND], 10]
  }
  #Global variable for multiplying in case of success or failure
  $multiplier = 1.0
  
# ================================================= =============================
# □ customize END
# ================================================= =============================
  R_KEYS = [A, B, C, X, Y, Z, L, R, UP, DOWN, LEFT, RIGHT] # key sequence to use for the random key
  ALT_KEYS = [C,B,X,Y] #Solo los botones basicos
  D_KEYS = [UP,DOWN,LEFT,RIGHT] #Direccionales unicamente
  # ------------------------------------------------- -------------------------
  # ● key list acquisition
  # ------------------------------------------------- -------------------------
  def self.get_key_list (skill_id)
    return nil if T_SKILL[skill_id].nil?
    return nil if T_SKILL[skill_id][0].nil?
    return T_SKILL[skill_id][0]
  end
  # ------------------------------------------------- -------------------------
  # ● random key conversion
  # ------------------------------------------------- -------------------------
  def self.change_rand (list)
    ret_list = []
    for i in 0 ... list.size
       ret_list.push(list[i] == RAND ? R_KEYS[rand(R_KEYS.size)] : list[i])
    end
    return ret_list
  end
  #Botones basicos
  def self.change_arand (list)
    ret_list = []
    for i in 0 ... list.size
       ret_list.push(list[i] == RKEY ? ALT_KEYS[rand(ALT_KEYS.size)] : list[i])
    end
    return ret_list
  end
  #Botones direccionales
  def self.change_drand (list)
    ret_list = []
    for i in 0 ... list.size
       ret_list.push(list[i] == DIR ? D_KEYS[rand(D_KEYS.size)] : list[i])
    end
    return ret_list
  end
  
  
  
end



# ================================================= =============================
# ■ Input
# ================================================= =============================
module Input
  module_function
  # ------------------------------------------------- -------------------------
  # ● key input determination of other than the specified key
  # ------------------------------------------------- -------------------------
  def n_trigger? (num)
    if trigger? (num)
      return false
    elsif trigger? (A) or trigger? (B) or trigger? (C) or
          trigger? (X) or trigger? (Y) or trigger? (Z) or
          trigger? (L) or trigger? (R) or
          trigger? (UP) or trigger? (DOWN) or trigger? (RIGHT) or trigger? (LEFT)
        return true
    end
    return false # case of a key that does not not enter or use
  end
  # ------------------------------------------------- -------------------------
  # ● key conversion table (for display character acquisition)
  # ------------------------------------------------- -------------------------
  GP_KEY = {# for the game pad conversion table
    A => "A", B => "B", C => "C", X => "X", Y => "Y", Z => "Z", L => "L", R => "R",
    UP => "↑", DOWN => "↓", LEFT => "←", RIGHT => "→"
  }
  KB_KEY = {# conversion table for the keyboard
    A => "C", B => "X", C => "Z", X => "A", Y => "S", Z => "D", L => "Q", R => "W",
    UP => "↑", DOWN => "↓", LEFT => "←", RIGHT => "→"
  }
  def key_converter (key)
    # Game pad type
    if CommandSkill::KEY_TYPE
      ret = GP_KEY[key]
    # Keyboard type
    else
      ret = KB_KEY[key]
    end
    return(ret)
  end
end


# ================================================= =============================
# ■ Window_KeyCounter
# ------------------------------------------------- -----------------------------
# Bar that displays the progress rate
# ================================================= =============================
class Window_KeyCounter < Window_Base
  # ------------------------------------------------- -------------------------
  # ● object initialization
  # Key: key arrangement
  # ------------------------------------------------- -------------------------
  def initialize (a=220 , b=200, c=200)
    super(0,a,b,c)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.opacity = 0
    self.z = 1 # display in the back than the Battler
    refresh(0)
  end
  # ------------------------------------------------- -------------------------
  # ● refresh
  # Current = progress rate (%)
  # ------------------------------------------------- -------------------------
  def refresh (current)
    self.contents.clear
    draw_counter_bar(0, 0, (100 - current)) # progress direction: ←
    #draw_counter_bar(0, 0, current) # Progress Direction: →
  end
  # ------------------------------------------------- -------------------------
  # ● Bar display
  # X: x display position
  # Y: y display position
  # Current: progress rate (%)
  # ------------------------------------------------- -------------------------
  def draw_counter_bar (x, y, current)
    bitmap = Bitmap.new(CommandSkill::T_BAR_NAME)
    cw = (bitmap.width * current) / 120.0
    ch = bitmap.height
    src_rect = Rect.new(0, 0, cw, ch)
    self.contents.blt(x, y, bitmap, src_rect)
  end
end

# ================================================= =============================
# ■ Window_KeyCount
# ------------------------------------------------- -----------------------------
# Window that displays the key to enter.
# ================================================= =============================
class Window_KeyCount <Window_Base
  TEXT_H = 38 # character height
  # ------------------------------------------------- -------------------------
  # Initialize window for key input
  # Key: key arrangement
  # ------------------------------------------------- -------------------------
  def initialize(key, a=220 , b=250, c=80)
    super(0, a, b, c)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.back_opacity = 160 # semi-transparent
    self.z = 0 # display in the back than the progress bar
    @key = key
    @key_count = 0
    refresh
  end
  # ------------------------------------------------- -------------------------
  # ● refresh
  # ------------------------------------------------- -------------------------
  def refresh
    self.contents.clear
    x = CommandSkill::TEXT_W # spacing between characters
    for i in 0 ... @key.size    
      if i <@key_count
        self.contents.font.color = knockout_color
      else
        self.contents.font.color = normal_color
      end
      self.contents.draw_text(x*i, 0, 100, TEXT_H, Input.key_converter(@key[i]))
      
    end
  end
  # ------------------------------------------------- -------------------------
  # ● key count
  # ------------------------------------------------- -------------------------
  def key_in
    @key_count += 1
    refresh
  end
  # ------------------------------------------------- -------------------------
  # ● text display
  # Text: text
  # ------------------------------------------------- -------------------------
  def text_in (text)
    self.contents.clear
    self.contents.draw_text(0, 0, 100, TEXT_H, text, 1)
  end
end


# ================================================= =============================
# ■ Game_Battler
# ================================================= =============================
class Game_Battler
  attr_accessor :cmd_miss_flag # command input mistake
  # ------------------------------------------------- -------------------------
  # ● object initialization
  # ------------------------------------------------- -------------------------
  alias initialize_cmd_skill initialize
  def initialize
    initialize_cmd_skill # original
    @cmd_miss_flag = false
  end
  # ------------------------------------------------- -------------------------
  # ● application effect of skills
  # User: the user of the skill
  # Skill: Skills
  # ------------------------------------------------- -------------------------
  alias skill_effect_cmd_skill item_apply
  
  def item_apply(user, skill)
    $multiplier = 1
    if user.cmd_miss_flag
    
      #skill_copy = $data_skills[skill.id].dup
      $multiplier = CommandSkill::T_SKILL[skill.id][1]
      $multiplier = $multiplier / 100.0 #only 100 makes the value trunk to an Integer instead of a float
      #p($multiplier,"multi")
    end
    ret = skill_effect_cmd_skill(user, skill)#Call the original method   
    return ret
  end
   # ------------------------------------------------- -------------------------
  # ● Redefine damage output overwriting the original damage based on multiplier
  # User: the user of the skill 
  # item: Skill
  # ------------------------------------------------- -------------------------

  alias muti_make_damage make_damage_value
  def make_damage_value (user, item)
    value = item.damage.eval(user, self, $game_variables)
    value *= item_element_rate(user, item)
    value *= pdr if item.physical?
    value *= mdr if item.magical?
    value *= rec if item.damage.recover?
    value = apply_critical(value) if @result.critical
    value = apply_variance(value, item.damage.variance)
    value = apply_guard(value)
    # p(value.to_s + '*' + $multiplier.to_s + '*' + $game_variables[CommandSkill::DAMAGE_MULTIPLIER].to_s + "=")
    value = value * $multiplier * $game_variables[CommandSkill::DAMAGE_MULTIPLIER] 
    # p(value.to_s)
    @result.make_damage(value.to_i, item)
    #---For effectiveness popup from Yanfly's Battle Engine
    if($imported["YEA-BattleEngine"] == true)
      rate = item_element_rate(user, item)
      make_rate_popup(rate) unless $game_temp.evaluating
    end
  end
  
end


# ================================================= =============================
# ■ Scene_Battle
# ================================================= =============================
class Scene_Battle
  # ------------------------------------------------- -------------------------
  # ● CMD Skill initialization
  # ------------------------------------------------- -------------------------
  def init_cmd_skill
    lactor = BattleManager.actor
    return unless lactor != nil
    lactor.cmd_miss_flag = false
    @cmd_skill_ok = false
    @cmd_skill_miss_flag = false
    $game_variables[CommandSkill::DAMAGE_MULTIPLIER] = 1.0
  end
  # ------------------------------------------------- -------------------------
  # ● CMD Skill can be performed?
  # ------------------------------------------------- -------------------------
  def cmd_skill_enable? (skill_id)
    
    return false if skill_id == nil
    # Enemy is not allowed
    return false if CommandSkill.get_key_list(skill_id).nil?
    # Inspiration when no command
    return true
  end
  # ------------------------------------------------- -------------------------
  # ● CMD Skill preprocessing
  # ------------------------------------------------- -------------------------
  def pre_cmd_skill
    init_cmd_skill
    skill_id = BattleManager.actor
    return unless skill_id != nil
    skill_id = BattleManager.actor.input.item
    return if (skill_id.is_a? (RPG::Item)) #If not, combinations would also apply when using items   
    return unless skill_id != nil
    skill_id = BattleManager.actor.input.item.id
    #skill_id = @active_battler.current_action.skill_id
    return unless cmd_skill_enable?(skill_id)
    # Command skills triggered
    make_cmd_skill_skill_result(skill_id) # Call Original
  end
  # ------------------------------------------------- -------------------------
  # ● CMD Skill post-processing
  # ------------------------------------------------- -------------------------
  def after_cmd_skill
    if CommandSkill::ALL_ATK and @cmd_skill_ok
      if CommandSkill::ALL_ATK_SK.include? (@skill_copy.id)
        @skill = $data_skills [@skill_copy.id] = @skill_copy
      end
    end
    #Changing the animation at the time of # Miss
    if CommandSkill::MISS_ANIME and @cmd_skill_miss_flag
      unless CommandSkill::T_SKILL[@skill.id][2].nil?
        @Animation2_id = CommandSkill::T_SKILL[@skill.id][2]
      end
    end
    init_cmd_skill
  end
  # ------------------------------------------------- -------------------------
  # ● command skills Window X position acquisition
  # ------------------------------------------------- -------------------------
  def cmd_skill_window_x
    #Remove comment at the time of # "combat position correction" combination
    #case $ game_party.actors.size
    #when 1
    # Actor_x = 240
    #when 2
    # Actor_x = @active_battler.index * 240 + 120
    #when 3
    # Actor_x = @active_battler.index * 200 + 40
    #when 4
      actor_x = 160
    #end
    return actor_x
  end
  # ------------------------------------------------- -------------------------
  # ● command skills command input loop UPDATE
  # ------------------------------------------------- -------------------------
  def cmd_skill_loop_update
    Graphics.update
    Input.update
    #@Spriteset.update
  end
  # ------------------------------------------------- -------------------------
  # ● command skills command input loop
  # ------------------------------------------------- -------------------------
  def cmd_skill_loop (cmd_list, time)
    key_count = 0
    for i in 0 ... time
      cmd_skill_loop_update
      # Success to the key input?
      if Input.trigger?(cmd_list [key_count])
        key_count += 1
        @window_keycount.key_in
      elsif Input.n_trigger? (cmd_list [key_count]) #press the # key different
        # Miss during the SE performance
        RPG::SE.new(CommandSkill::MISS_SE).play if CommandSkill::MISS_SE != nil
        break
      end
      # Completed all key input
      if key_count >= cmd_list.size
        @window_keycount.text_in ( "Completo")
        # Complete when SE performance
        RPG::SE.new(CommandSkill::COMP_SE).play if CommandSkill::COMP_SE != nil
        @cmd_skill_ok = true
        break
      end
      # Of progress bar update
      @window_counter.refresh ((i * 100 / time).truncate)
    end
  end
  # ------------------------------------------------- -------------------------
  # ● create command skills result
  # ------------------------------------------------- -------------------------
  def make_cmd_skill_skill_result (skill_id)
    # Command list acquisition
    cmd_list = CommandSkill.get_key_list(skill_id)
    cmd_list = CommandSkill.change_rand(cmd_list)
    cmd_list = CommandSkill.change_drand(cmd_list)
    cmd_list = CommandSkill.change_arand(cmd_list)
    time = CommandSkill::KEY_SEC * cmd_list.size * Graphics.frame_rate
    # Key input and count window creation
    @window_keycount = Window_KeyCount.new(cmd_list)
    @window_counter = Window_KeyCounter.new
    @window_keycount.x = @window_counter.x = cmd_skill_window_x
    
    # Command input loop
    cmd_skill_loop(cmd_list, time)
    # Mistake at the time of "Miss" display
    unless @cmd_skill_ok
      @window_keycount.text_in( "Falla")
      BattleManager.actor.cmd_miss_flag = true
      @cmd_skill_miss_flag = true
    end
    # Miss, the wait for the Complete Display
    for i in 0 ... 10
      cmd_skill_loop_update
    end
    @window_keycount.close
    @window_counter.close
  end
# ------------------------------------------------- -----------------------------
  # ------------------------------------------------- -------------------------
  # ● creating skills action result
  # ------------------------------------------------- -------------------------
  alias make_skill_action_result_cmd_skill use_item
  def use_item
    pre_cmd_skill
    make_skill_action_result_cmd_skill # original
    after_cmd_skill
  end
end