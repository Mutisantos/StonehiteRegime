#==============================================================================
# ■ Sideview Ver100
#------------------------------------------------------------------------------
# Tankentai Sideview Battle System
#       by Enu (http://rpgex.sakura.ne.jp/home/)
# English Translation v1.1
#       by Wishdream (http://wishdream.org/)
#       Help by Okamikurainya
# Version Log:
#    1.1 - All actions, programs and full actions translated.
#    1.0 - Start of project, all documentation translated.
#------------------------------------------------------------------------------
# 　The class that manages the sideview battle system.
#==============================================================================
class SideView
  #--------------------------------------------------------------------------
  # ● Public instance variables
  #--------------------------------------------------------------------------
  attr_accessor   :x                    # X screen coordinate
  attr_accessor   :y                    # Y screen coordinate
  attr_accessor   :z                    # Z screen coordinate
  attr_accessor   :h                    # Height coordinate
  attr_accessor   :j                    # Jump coordinates
  attr_accessor   :c                    # Curve coordinates
  attr_accessor   :ox                   # Horizontal origin
  attr_accessor   :oy                   # Vertical origin
  attr_accessor   :oy_adjust            # Vertical origin adjustment
  attr_accessor   :angle                # Rotation angle
  attr_accessor   :zoom_x               # X zoom
  attr_accessor   :zoom_y               # Y zoom
  attr_accessor   :pattern_w            # Cell horizontal position(rectangle)
  attr_accessor   :pattern_h            # Cell vertical position(rectangle)
  attr_accessor   :sx                   # Cell horizontal position(entire image)
  attr_accessor   :sy                   # Cell vertical position(entire image)
  attr_accessor   :pattern_type         # Cell update type
  attr_accessor   :pattern_time         # Cell update interval
  attr_accessor   :graphic_name         # Battler image filename
  attr_accessor   :graphic_file_index   # Battler image file index
  attr_accessor   :graphic_index        # Battler image index
  attr_accessor   :cw                   # Cell rectangle width
  attr_accessor   :ch                   # Cell rectangle height
  attr_accessor   :shadow_visible       # Shadow display
  attr_accessor   :weapon_visible       # Weapon display
  
  attr_accessor   :wait                 # Following operation wait time
  attr_accessor   :weapon_index         # Weapon display index array
  attr_accessor   :weapon_end           # Weapon animation end flag
  attr_accessor   :force_action         # Force action
  attr_accessor   :target_battler       # Target battler information
  attr_accessor   :second_targets       # Second target information
  attr_accessor   :m_a_targets          # Moving target information
  attr_accessor   :individual_targets   # Individual process target information
  attr_accessor   :effect_data          # Effect Data
  attr_accessor   :anime_id             # Animation ID array
  attr_accessor   :anime_move_id        # Moving Animation ID array
  attr_accessor   :mirror               # Flip Flag
  attr_accessor   :opacity              # Transparency
  attr_accessor   :opacity_data         # Transparency operation information
  attr_accessor   :set_damage           # Damage processing in-battle
  attr_accessor   :m_a_data             # Moving animation information
  attr_accessor   :m_a_starter          # Moving animation start target info
  attr_accessor   :action_end           # Action end of the battle scene
  attr_accessor   :damage_anime_data    # Damage combat animation data
  attr_accessor   :anime_no_mirror      # Battle anim NoFlip flag
  attr_accessor   :anime_horming        # Battle anim Homing flag
  attr_accessor   :anime_camera_zoom    # Battle anim scale to fit on camera
  attr_accessor   :anime_plus_z         # Battle anim Z adjustment
  attr_accessor   :derivation_skill_id  # Derive skill ID
  attr_accessor   :immortal             # Invunerability flag
  attr_accessor   :mirage               # Afterimage data
  attr_accessor   :balloon_data         # Balloon data
  attr_accessor   :timing               # Timing data from another battler
  attr_accessor   :timing_targets       # Pass timing data from another battler
  attr_accessor   :color_set            # Color change data
  attr_accessor   :color                # Color data
  attr_accessor   :change_up            # Image change flag
  attr_accessor   :hit                  # Number of hits
  attr_accessor   :add_state            # Prevent display of additional states
  attr_accessor   :counter_id           # Skill ID on counter
  attr_accessor   :reflection_id        # Skill ID on reflect
  attr_accessor   :result_damage        # HP change data at the end of the turn
  attr_accessor   :active               # Action permission
  attr_accessor   :anime_off            # Combat animation erase
  attr_accessor   :command_action       # Command action flag
    
  attr_accessor   :base_x               # Initial position X coordinate
  attr_accessor   :base_y               # Initial position Y coordinate
  attr_accessor   :base_h               # Initial position height coordinate
  attr_accessor   :max_pattern_w        # The horizontal division number of a cell
  attr_accessor   :max_pattern_h        # The vertical division number of a cell
  
  attr_reader     :collapse             # Collapse flag
  attr_reader     :picture              # Picture display flag
  #--------------------------------------------------------------------------
  # ● Object initialization
  #--------------------------------------------------------------------------
  def initialize(battler)
    @battler = battler
    reset
  end
  #--------------------------------------------------------------------------
  # ● Initialize / Reset
  #--------------------------------------------------------------------------
  def reset
    @x = 0
    @y = 0
    @z = 0
    @h = 0
    @j = 0
    @c = 0
    @jump = []
    @curve = []
    @ox = 0
    @oy = 0
    @oy_adjust = 0
    @z_plus = 0
    @move_time = 0
    @angle = 0
    @angle_time = 0
    @zoom_x = 1
    @zoom_y = 1
    @zoom_time = 0
    @pattern_w = 0
    @pattern_h = 0
    @sx = 0
    @sy = 0
    @pattern_type = 0
    @pattern_time = 0
    @pattern_rest_time = 0
    @graphic_name = ""
    @graphic_file_index = ""
    @graphic_index = 0
    @cw = 0
    @ch = 0
    @shadow_visible = false
    @weapon_visible = true
    
    @wait = 0
    @weapon_index = []
    @weapon_end = true
    @full_action = []
    @action = []
    @force_action = ""
    @target_battler = []
    @second_targets = []
    @individual_targets = []
    @m_a_targets = []
    @effect_data = []
    @anime_id = []
    @anime_move_id = []
    @opacity = 255
    @opacity_data = []
    @set_damage = false
    @m_a_data = []
    @m_a_starter = []
    @action_end = false
    @damage_anime_data = []
    @anime_no_mirror = false
    @anime_horming = false
    @anime_camera_zoom = false
    @anime_plus_z = true
    @derivation_skill_id = 0
    @immortal = false
    @mirage = []
    @play_data = []
    @balloon_data = []
    @picture = false
    @timing = []
    @timing_targets = []
    @color_set = []
    @color = []
    @change_up = false
    @non_motion = false
    @graphics_change = false
    @hit = []
    @add_state = []
    @collapse = false
    @counter_id = 0
    @reflection_id = 0
    @result_damage = [0,0]
    @active = false
    @anime_off = false
    @command_action = false
    
    @base_x = 0
    @base_y = 0
    @base_z = 0
    @base_h = 0
    @max_pattern_w = 0
    @max_pattern_h = 0
    @pattern_kind = 0
    @pattern_count = 0
    @move_time = 0
    @mirror = false
    @battler.set_graphic(@pre_change_data[0], @pre_change_data[1], @pre_change_data[2], @pre_change_data[3]) if @pre_change_data != nil
    @pre_change_data = nil
  end  
  #--------------------------------------------------------------------------
  # ● Setup
  #--------------------------------------------------------------------------
  def setup(bitmap_width, bitmap_height, first_action_flag)
    reset if first_action_flag
    set_data
    set_base_position if !@graphics_change
    set_graphics(bitmap_width, bitmap_height)
    set_target
    setup_graphics_change if @graphics_change
    first_battler_anime_set if first_action_flag
  end  
  #--------------------------------------------------------------------------
  # ● Retrieve Battler Data
  #--------------------------------------------------------------------------
  def set_data
    return if @battler == nil
    if @battler.actor?
      @graphic_name = @battler.character_name
      @graphic_index = @battler.character_index
    else
      @graphic_name = @battler.battler_name
      @graphic_index = 0
    end
    @max_pattern_w = max_pattern[0]
    @max_pattern_h = max_pattern[1]
  end
  #--------------------------------------------------------------------------
  # ● Set base position data = [X-axis, Y-axis, H-axis]
  #   moment_set - current placement
  #--------------------------------------------------------------------------
  def set_base_position(moment_set = true)
    mirroring_reset
    if @battler.actor?
      data = N03::ACTOR_POSITION[@battler.index].dup
      @base_x = data[0] * 100 if !@mirror
      @base_x = (Graphics.width - data[0]) * 100 if @mirror
    else
      data = [@battler.screen_x, @battler.screen_y, 0].dup
      @base_x = data[0] * 100 if !$sv_camera.mirror
      @base_x = (Graphics.width - data[0]) * 100 if $sv_camera.mirror
    end
    @base_y = data[1] * 100
    @base_h = data[2] * 100
    @base_z = @y
    return if !moment_set
    @x = @base_x 
    @y = @base_y
    @z = @base_z
  end
  #--------------------------------------------------------------------------
  # ● Retrieve graphics data
  #--------------------------------------------------------------------------
  def set_graphics(bitmap_width, bitmap_height)
    sign = @graphic_name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap_width / @max_pattern_w
      @ch = bitmap_height / @max_pattern_h
    elsif @max_pattern_w == 1 && @max_pattern_h == 1
      @cw = bitmap_width
      @ch = bitmap_height
    else
      @cw = bitmap_width / (@max_pattern_w * 4)
      @ch = bitmap_height / (@max_pattern_h * 2)
    end
    @ox = @cw / 2
    @oy = @ch
    @sx = (@graphic_index % 4 * @max_pattern_w + @pattern_w) * @cw
    @sy = (@graphic_index / 4 * @max_pattern_h + @pattern_h) * @ch
  end
  #--------------------------------------------------------------------------
  # ● Set target
  #--------------------------------------------------------------------------
  def set_target(target = nil)
    @target_battler = target
    @target_battler = [@battler] if target == nil
    @second_targets = @target_battler
  end
  #--------------------------------------------------------------------------
  # ● Setup graphics change
  #--------------------------------------------------------------------------
  def setup_graphics_change
    @graphics_change = false
    @sx = (@graphic_index % 4 * @max_pattern_w + @pattern_w) * @cw
    @sy = (@graphic_index / 4 * @max_pattern_h + @pattern_h) * @ch
  end  
  #--------------------------------------------------------------------------
  # ● Set idle animation data at the start of the battle
  #--------------------------------------------------------------------------
  def first_battler_anime_set
    loop do
      update
      break if @action_data == nil
      break if @action_data[0] == "motion"
      break if @action_data[0] == "move" && @action_data[8] != ""
      break if @full_action == []
    end
    start_action(first_action) if @battler.movable?
  end
  #--------------------------------------------------------------------------
  # ● Start action
  #--------------------------------------------------------------------------
  def start_action(kind = nil)
    return if @event_fix && $game_troop.interpreter.running?
    # If it is canceled while waiting
    return @wait -= 1 if @wait > 0 && kind == nil
    action_setup(false) if kind != nil
    set_action(kind)
    @action = kind if @action == nil
    # When there is no action, it shifts to action termination processing.
    action_terminate if @action == nil
    # The next action decision 
    @action_data = N03::ACTION[@action]
    next_action
  end
  #--------------------------------------------------------------------------
  # ● Action parameter initialize
  #--------------------------------------------------------------------------
  def action_setup(reset = true)
    @event_fix = false
    @set_damage = false
    @action_end = false
    @balloon_data = []
    @loop_act = []
    angle_reset if reset
    zoom_reset if reset
    opacity_reset if reset
    @curve = []
    @c = 0
    convert_jump
  end  
  #--------------------------------------------------------------------------
  # ● Terminate action
  #--------------------------------------------------------------------------
  def action_terminate
    @mirage = [] if @mirage_end
    mirroring_reset
    @picture = false
    @individual_targets = []
    action_setup if @active
    action_setup(false) if !@active
    # Shift to the idle/standby action
    stand_by_action if !@non_motion
    # Exit control of the battler
    next_battler
  end  
  #--------------------------------------------------------------------------
  # ● Determine the content of the new action
  #--------------------------------------------------------------------------
  def set_action(kind = nil)
    full_act = N03::FULLACTION[kind]
    @full_action = full_act.dup if full_act != nil
    @action = @full_action.shift
    # Intergrate the action into a full action
    full_act2 = N03::FULLACTION[@action]
    @full_action = full_act2.dup + @full_action if full_act2 != nil
  end
  #--------------------------------------------------------------------------
  # ● Next Action
  #--------------------------------------------------------------------------
  def next_action
    @wait = 0
    # Shortcut check
    eval(@action) if @action != nil && @action_data == nil && N03::FULLACTION[@action] == nil
    # Wait setup
    @wait = @action.to_i if @wait == 0 && @action_data == nil
    @wait = rand(@wait.abs + 1) if @wait < 0
    # Start action
    action_play
  end
  #--------------------------------------------------------------------------
  # ● Shift to Idle/Stand by action
  #--------------------------------------------------------------------------
  def stand_by_action
    # Normal Idle
    stand_by_act = normal
    # Weak Idle
    stand_by_act = pinch if @battler.hp <= @battler.mhp / 4
    # State Idle
    stand_by_act = state(@battler.states[0].id) if @battler.states[0] != nil && state(@battler.states[0].id) != nil
    # Command Idle
    stand_by_act = command if @command_action && command != nil
    set_action(stand_by_act)
    @action = stand_by_act if @action == nil
  end
  #--------------------------------------------------------------------------
  # ● Force action start
  #--------------------------------------------------------------------------
  def start_force_action
    return if @active
    start_action(@force_action)
    @force_action = ""
  end  
  #--------------------------------------------------------------------------
  # ● Add action
  #--------------------------------------------------------------------------
  def add_action(kind)
    @full_action.push(kind)
  end  
  #--------------------------------------------------------------------------
  # ● Insert action
  #--------------------------------------------------------------------------
  def unshift_action(kind)
    @full_action.unshift(kind)
  end  
  #--------------------------------------------------------------------------
  # ● Frame Update
  #--------------------------------------------------------------------------
  def update
    # Action start
    start_action
    # Force action start
    start_force_action if @force_action != ""
    # Animation pattern update
    update_pattern
    # Move update
    update_move
    # Rotation update
    update_angle if @angle_time != 0
    # Zoom update
    update_zoom if @zoom_time != 0
    # Transparency update
    update_opacity if @opacity_data != []
  end
  #--------------------------------------------------------------------------
  # ● Animation pattern update
  #--------------------------------------------------------------------------
  def update_pattern
    return @pattern_rest_time -= 1 if @pattern_rest_time != 0
    return if @max_pattern_w == 1 && @max_pattern_h == 1
    @pattern_rest_time = @pattern_time
    # Get the playback start and end cell position
    if @pattern_kind > 0 # During normal playback
      @pattern_start = 0
      @pattern_end = @max_pattern_w - 1
    elsif @pattern_kind < 0 # Play in reverse
      @pattern_start = @max_pattern_w - 1
      @pattern_end = 0
    end
    # Finished playing one way
    @pattern_count += 1 if @pattern_w == @pattern_end && @pattern_kind != 0
    # Loop processing
    case @pattern_type.abs
    when  1,3 # Normal
      @pattern_kind =  0 if @pattern_count != 0 && @pattern_type ==  1
      @pattern_kind =  0 if @pattern_count != 0 && @pattern_type == -1
      @pattern_kind =  1 if @pattern_count != 0 && @pattern_type ==  3
      @pattern_kind = -1 if @pattern_count != 0 && @pattern_type == -3
      @pattern_w = @pattern_start - @pattern_kind if @pattern_count != 0 && @pattern_type.abs == 3
      @pattern_count = 0
    when  2,4 # Ping-pong
      @pattern_kind = -1 if @pattern_count == 1 && @pattern_type ==  2
      @pattern_kind =  1 if @pattern_count == 1 && @pattern_type == -2
      @pattern_kind =  0 if @pattern_count == 2 && @pattern_type ==  2
      @pattern_kind =  0 if @pattern_count == 2 && @pattern_type == -2
      @pattern_kind = -1 if @pattern_count == 1 && @pattern_type ==  4
      @pattern_kind =  1 if @pattern_count == 1 && @pattern_type == -4
      @pattern_kind =  1 if @pattern_count == 2 && @pattern_type ==  4
      @pattern_kind = -1 if @pattern_count == 2 && @pattern_type == -4
      @pattern_count = 0 if @pattern_count == 2
    end
    # Cell Update
    @pattern_w += 1 * @pattern_kind
    @sx = (@graphic_index % 4 * @max_pattern_w + @pattern_w) * @cw
  end
  #--------------------------------------------------------------------------
  # ● Movement Update
  #--------------------------------------------------------------------------
  def update_move
    @z = @y / 100 + @z_plus
    return if @move_time == 0
    target_position_set if @horming_move
    @x = (@x * (@move_time - 1) + @target_x) / @move_time
    @y = (@y * (@move_time - 1) + @target_y) / @move_time
    @h = (@h * (@move_time - 1) + @target_h) / @move_time if @move_h != nil
    @c += @curve[@move_time - 1] if @curve[@move_time - 1] != nil
    @j += @jump[@move_time - 1] if @jump[@move_time - 1] != nil
    @move_time -= 1
    convert_jump if @move_time == 0
  end
  #--------------------------------------------------------------------------
  # ● Update moving target
  #--------------------------------------------------------------------------
  def target_position_set
    target_position = N03.get_targets_position(@move_targets, @horming_move)
    @target_x = target_position[0] + @move_x
    @target_y = target_position[1] + @move_y
    @target_h = target_position[2] + @move_h if @move_h != nil
  end  
  #--------------------------------------------------------------------------
  # ● Rotation update
  #--------------------------------------------------------------------------
  def update_angle
    @angle += @angling
    @angle_time -= 1
    return if @angle_time != 0
    return angle_reset if @angle_data[4] == 0
    angling(@angle_data) if @angle_data[4] == 2
  end  
  #--------------------------------------------------------------------------
  # ● Zoom update
  #--------------------------------------------------------------------------
  def update_zoom
    @zoom_x += @zooming_x
    @zoom_y += @zooming_y
    @zoom_time -= 1
    return if @zoom_time != 0
    return zoom_reset if @zoom_data[4] == 0
    zooming(@zoom_data) if @zoom_data[4] == 2
  end
  #--------------------------------------------------------------------------
  # ● Transparency update
  #--------------------------------------------------------------------------
  def update_opacity
    @opacity += @opacity_data[2]
    @opacity_data[0] -= 1
    return if @opacity_data[0] != 0
    return if !@opacity_data[5]
    @opacity_data[2] *= -1
    @opacity_data[0] = @opacity_data[1]
  end
  #--------------------------------------------------------------------------
  # ● Start action
  #--------------------------------------------------------------------------
  def action_play 
    return if @action_data == nil
    action = @action_data[0]
    # Flip
    return mirroring                    if action == "mirror"
    # Afterimage
    return mirage_set                   if action == "mirage"
    # Rotate
    return angling                      if action == "angle"
    # Zoom
    return zooming                      if action == "zoom"
    # Transparency
    return set_opacity                  if action == "opacity"
    # Battler animation
    return battler_anime                if action == "motion"
    # Movement
    return move                         if action == "move"
    # Weapon
    return weapon_anime([@action_data]) if action == "wp"
    # Moving animation
    return move_anime                   if action == "m_a"
    # Collapse or No collapse
    return set_play_data                if action == "collapse" or action == "no_collapse"
    # Animation  
    return battle_anime                 if action == "anime"
    # Camera
    return camera                       if action == "camera"
    # Screen shake
    return shake                        if action == "shake"
    # Screen color
    return color_effect                 if action == "color"
    # Transition
    return transition                   if action == "ts"
    # Balloon
    return balloon_anime                if action == "balloon"
    # Picture
    return picture_set                  if action == "pic"
    # State
    return state_set                    if action == "sta"
    # FPS
    return fps                          if action == "fps"
    # Change battler graphic
    return graphics_change              if action == "change"
    # Derive
    return derivating_skill             if action == "der"
    # Play BGM/BGS/SE
    return sound                        if action == "sound"
    # Play Movie 
    return movie                        if action == "movie"
    # Switch
    return switches                     if action == "switch"
    # Variable
    return variable                     if action == "variable"
    # Condition (Switch)
    return nece_1                       if action == "n_1"
    # Condition (Variable)
    return nece_2                       if action == "n_2"
    # Condition (State)
    return nece_3                       if action == "n_3"
    # Condition (Skill)
    return nece_4                       if action == "n_4"
    # Condition (Parameter)
    return nece_5                       if action == "n_5"
    # Condition (Equipment)
    return nece_6                       if action == "n_6"
    # Condition (Script)
    return nece_7                       if action == "n_7"
    # Second Target
    return second_targets_set           if action == "s_t"
    # Call common event
    return call_common_event            if action == "common"
    # Clear battle animation
    return @anime_off = true            if action == "anime_off"
    # End Battle
    return BattleManager.process_abort  if action == "battle_end"
    # Screen Fix
    return Graphics.freeze              if action == "graphics_freeze"
    # Damage animation
    return damage_anime                 if action == "damage_anime"
    # Weapon hide
    return @weapon_visible = false      if action == "weapon_off"
    # Weapon show  
    return @weapon_visible = true       if action == "weapon_on"
    # Disable wait
    return @non_motion = true           if action == "non_motion"
    # Enable wait
    return @non_motion = false          if action == "non_motion_cancel"
    # Change base position
    return change_base_position         if action == "change_base_position"
    # Set base position
    return set_base_position(false)     if action == "set_base_position"
    # Force action  
    return force_act                    if action == "force_action"
    # Force action 2
    return force_act2                   if action == "force_action2"
    # Individual start
    return individual_start             if action == "individual_start"
    # Individual end
    return individual_end               if action == "individual_end"
    # Loop start
    return loop_start                   if action == "loop_start"
    # Loop end
    return loop_end                     if action == "loop_end"
    # Update only battler ON
    return only_action_on               if action == "only_action_on"
    # Update only battler OFF
    return only_action_off              if action == "only_action_off"
    # Start next battler immediately
    return next_battler                 if action == "next_battler"
    # Image change flag
    return set_change                   if action == "set_change"
    # Script   
    return eval(@action_data[0])
  end
  #--------------------------------------------------------------------------
  # ● バトラー反転実行
  #--------------------------------------------------------------------------
  def mirroring
    @mirror = !@mirror
  end  
  #--------------------------------------------------------------------------
  # ● 反転初期化
  #--------------------------------------------------------------------------
  def mirroring_reset
    @mirror = false
    mirroring if !@battler.actor? && N03::ENEMY_MIRROR
    mirroring if $sv_camera.mirror
  end  
  #--------------------------------------------------------------------------
  # ● 残像実行
  #--------------------------------------------------------------------------
  def mirage_set
    @mirage = @action_data.dup
    @mirage_end = @mirage[3]
    @mirage = [] if @mirage[1] == 0
  end  
  #--------------------------------------------------------------------------
  # ● 回転実行
  #--------------------------------------------------------------------------
  def angling(data = @action_data)
    @angle_data = data.dup
    @oy = @ch / 2
    @oy_adjust = @ch * 50
    @angle_time = data[1]
    start_angle = data[2] * N03.mirror_num(@mirror)
    end_angle = data[3] * N03.mirror_num(@mirror)
    # 時間が0以下なら即座に最終角度へ
    @angle_time = 1 if @angle_time <= 0
    # 回転時間から1フレームあたりの角度を出す
    @angling = (end_angle - start_angle) / @angle_time
    # 割り切れない余りを初期角度に
    @angle = (end_angle - start_angle) % @angle_time + start_angle
  end 
  #--------------------------------------------------------------------------
  # ● 回転初期化
  #--------------------------------------------------------------------------
  def angle_reset
    @oy = @ch
    @angle = @angle_time = @oy_adjust = 0
  end  
  #--------------------------------------------------------------------------
  # ● 拡大縮小実行
  #--------------------------------------------------------------------------
  def zooming(data = @action_data)
    @zoom_data = data.dup
    @zoom_time = data[1]
    start_zoom_x = data[2][0]
    start_zoom_y = data[2][1]
    end_zoom_x = data[3][0]
    end_zoom_y = data[3][1]
    # 時間が0以下なら即座に最終サイズへ
    @zoom_time = 1 if @zoom_time <= 0
    # 拡大縮小時間から1フレームあたりの拡大縮小率を出す
    @zooming_x = (end_zoom_x - start_zoom_x) / @zoom_time
    @zooming_y = (end_zoom_y - start_zoom_y) / @zoom_time
    # 開始サイズに
    @zoom_x = start_zoom_x
    @zoom_y = start_zoom_y
  end  
  #--------------------------------------------------------------------------
  # ● 拡大縮小初期化
  #--------------------------------------------------------------------------
  def zoom_reset
    @zoom_x = @zoom_y = 1
    @zoom_time = 0
  end  
  #--------------------------------------------------------------------------
  # ● バトラー透明度操作
  #--------------------------------------------------------------------------
  def set_opacity
    data = @action_data.dup
    @opacity = data[2]
    opacity_move = (data[3] - data[2])/ data[1]
    @opacity_data = [data[1], data[1], opacity_move, data[4], data[5], data[6]]
    @wait = data[1] if data[7]
    @wait *= 2 if data[6] && data[7]
  end 
  #--------------------------------------------------------------------------
  # ● 透明度操作初期化
  #--------------------------------------------------------------------------
  def opacity_reset
    @opacity = 255
    @opacity = 0 if @battler.hidden?
    @opacity_data = []
  end
  #--------------------------------------------------------------------------
  # ● バトラーアニメ実行
  #--------------------------------------------------------------------------
  def battler_anime(anime_data = nil)
    anime_data = @action_data.dup if anime_data == nil
    @graphic_file_index = anime_data[1] if !graphic_fix
    @pattern_h = anime_data[2]
    @pattern_w = anime_data[3]
    @pattern_h = 0 if @max_pattern_w == 1
    @pattern_w = 0 if @max_pattern_h == 1
    @pattern_type = anime_data[4]
    @pattern_time = anime_data[5]
    @pattern_rest_time = anime_data[5]
    @pattern_count = 0
    @pattern_kind = 1
    @pattern_kind = -1 if @pattern_type < 0
    @pattern_kind = 0 if @pattern_type == 0
    @sx = (@graphic_index % 4 * @max_pattern_w + @pattern_w) * @cw
    @sy = (@graphic_index / 4 * @max_pattern_h + @pattern_h) * @ch
    @z_plus = anime_data[6]
    @wait = set_anime_wait if anime_data[7]
    @shadow_visible = anime_data[8]
    weapon_anime(anime_data)
  end
  #--------------------------------------------------------------------------
  # ● アニメウエイト計算
  #--------------------------------------------------------------------------
  def set_anime_wait
    if @pattern_type > 0
      pattern_time_a = @max_pattern_w - @pattern_w.abs
    elsif @pattern_type < 0
      pattern_time_a = @pattern_w.abs + 1
    else
      return @pattern_time if @pattern_type == 0
    end
    case @pattern_type
    when 1,-1, 3,-3
      return pattern_time_a * @pattern_time 
    when 2,-2, 4,-4
      return pattern_time_a * @pattern_time + (@max_pattern_w - 2) * @pattern_time
    end
  end  
  #--------------------------------------------------------------------------
  # ● 移動実行
  #--------------------------------------------------------------------------
  def move
    @move_targets = N03.get_targets(@action_data[1].abs, @battler)
    return if @move_targets == []
    @move_targets = [@battler] if @action_data[1].abs == 7
    @move_x = @action_data[2] * 100 * N03.mirror_num(@mirror)
    @move_y = @action_data[3] * 100
    @move_h = @action_data[4] * 100 if @action_data[4] != nil
    @move_h = nil if @action_data[4] == nil
    battler_anime(N03::ACTION[@action_data[8]].dup) if N03::ACTION[@action_data[8]] != nil
    @horming_move = true
    @horming_move = false if @action_data[1] < 0 or @action_data[1].abs == 7
    target_position_set
    target_position = [@target_x, @target_y, @target_z]
    distanse_move = @action_data[5] > 0
    @move_time = N03.distanse_calculation(@action_data[5].abs, target_position, [@x, @y, @z], distanse_move)
    @wait = @move_time
    curve
    jump
    @move_time = 1 if @move_time == 0
    @horming_move = false if !@move_targets or @move_targets.include?(@battler)
    update_move if @move_time == 1
  end  
  #--------------------------------------------------------------------------
  # ● カーブ実行 
  #--------------------------------------------------------------------------
  def curve
    @c = 0
    return if @action_data[6] == 0
    @curve = N03.parabola([@action_data[6], -@action_data[6]], @move_time, 100, 4)
  end  
  #--------------------------------------------------------------------------
  # ● ジャンプ実行
  #--------------------------------------------------------------------------
  def jump
    convert_jump
    return if @action_data[7] == [0,0]
    @jump = N03.parabola(@action_data[7].dup, @move_time, 100)
  end  
  #--------------------------------------------------------------------------
  # ● J座標(ジャンプ高度)をH座標に変換
  #--------------------------------------------------------------------------
  def convert_jump
    @h += @j
    @j = 0
    @jump = []
  end  
  #--------------------------------------------------------------------------
  # ● データベース戦闘アニメ実行
  #--------------------------------------------------------------------------
  def battle_anime
    data = @action_data.dup
    targets = N03.get_targets(data[2], @battler)
    return if targets == []
    data[8] = !data[8] if @mirror
    @set_damage           = data[5]
    @damage_anime_data[0] = N03.get_attack_anime_id(data[1], @battler)
    @damage_anime_data[1] = data[8]
    @damage_anime_data[2] = data[7]
    @damage_anime_data[3] = data[6]
    @damage_anime_data[4] = data[9]
    @wait = N03.get_anime_time(@damage_anime_data[0]) - 2 if data[4]
    return if @set_damage
    for target in targets do display_anime(targets, target, data) end
  end
  #--------------------------------------------------------------------------
  # ● 武器アニメ開始
  #--------------------------------------------------------------------------
  def weapon_anime(anime_data)
    @weapon_end = true
    for i in 9...anime_data.size
      set_effect_data(anime_data[i]) if anime_data[i] != ""
    end
  end
  #--------------------------------------------------------------------------
  # ● アニメ飛ばし開始
  #--------------------------------------------------------------------------
  def move_anime
    @m_a_starter = []
    @m_a_targets = []
    starters = N03.get_targets(@action_data[2], @battler)
    targets = N03.get_targets(@action_data[3], @battler)
    return if starters == [] or targets == []
    single_start = true if starters != nil && @action_data[2] < 0
    single_start = true if @action_data[1][0] != 0 && $data_animations[N03.get_attack_anime_id(@action_data[1][0], @battler)].position == 3
    starters = [starters[0]] if single_start
    single_end = true if targets != nil && @action_data[3] < 0
    single_end = true if @action_data[1][1] != 0 && $data_animations[N03.get_attack_anime_id(@action_data[1][1], @battler)].position == 3
    targets = [targets[0]] if single_end
    se_flag = true
    for starter in starters
      for target in targets
        data = @action_data.dup
        data[17] = se_flag
        @effect_data.push(data)
        @m_a_targets.push(target)
        @m_a_starter.push(starter)
        se_flag = false
      end
    end  
  end
  #--------------------------------------------------------------------------
  # ● スプライトセット通信
  #--------------------------------------------------------------------------
  def set_effect_data(data = @action)
    action_data = N03::ACTION[data]
    return if action_data == nil
    @effect_data.push(action_data.dup)
  end
  #--------------------------------------------------------------------------
  # ● 戦闘シーン通信のデータを格納
  #--------------------------------------------------------------------------
  def set_play_data(data = @action_data)
    @play_data = data.dup
  end
  #--------------------------------------------------------------------------
  # ● 戦闘アニメの表示
  #--------------------------------------------------------------------------
  def display_anime(targets, target, data)
    return if !N03.first_of_all_screen_anime(data[1], target, targets)
    target.animation_id         = N03.get_attack_anime_id(data[1], @battler)
    target.animation_mirror     = data[8]
    target.sv.anime_horming     = data[3]
    target.sv.anime_camera_zoom = data[6]
    target.sv.anime_no_mirror   = data[7]
    target.sv.anime_plus_z      = data[9]
  end
  #--------------------------------------------------------------------------
  # ● 戦闘アニメ拡張データの初期化
  #--------------------------------------------------------------------------
  def reset_anime_data
    @anime_no_mirror = false
    @anime_horming = false
    @anime_camera_zoom = false
    @timing_targets = []
    @anime_plus_z = true
  end  
  #--------------------------------------------------------------------------
  # ● カメラワーク
  #--------------------------------------------------------------------------
  def camera
    data = @action_data.dup
    N03.camera(@battler, data)
    @wait = data[4] if data[5]
  end  
  #--------------------------------------------------------------------------
  # ● 画面のシェイク
  #--------------------------------------------------------------------------
  def shake
    data = @action_data.dup
    $sv_camera.shake(data[1], data[2], data[3])
    @wait = data[3] if data[4]
  end 
  #--------------------------------------------------------------------------
  # ● 画面色調変更
  #--------------------------------------------------------------------------
  def color_effect
    case @action_data[1]
    when 0,1,2,3,4,5
      targets = N03.get_targets(@action_data[1], @battler)
    when 6
      screen = true
    when 7
      targets = [@battler] + @target_battler
    when 8
      screen = true
      targets = $game_troop.members + $game_party.battle_members - [@battler]
    when 9
      screen = true
      targets = $game_troop.members + $game_party.battle_members - [@battler] - @target_battler
    when 10
      screen = true
      targets = $game_troop.members + $game_party.battle_members
    end
    return if screen == nil && targets == []
    for target in targets do target.sv.color_set = @action_data[2] end if targets
    @wait = @action_data[2][4] if @action_data[3]
    return if !screen
    $sv_camera.color_set[1] = @action_data[2]
    $sv_camera.color_set[2] = @action_data[2]
  end  
  #--------------------------------------------------------------------------
  # ● トランジション
  #--------------------------------------------------------------------------
  def transition
    $sv_camera.perform_transition(@action_data)
  end  
  #--------------------------------------------------------------------------
  # ● ふきだしアニメ表示 
  #--------------------------------------------------------------------------
  def balloon_anime
    @balloon_data = @action_data.dup
  end  
  #--------------------------------------------------------------------------
  # ● ピクチャ表示
  #--------------------------------------------------------------------------
  def picture_set
    @picture = true
    set_effect_data
  end
  #--------------------------------------------------------------------------
  # ● ステート操作
  #--------------------------------------------------------------------------
  def state_set
    targets = N03.get_targets(@action_data[1], @battler)
    return if targets == []
    case @action_data[2]
    when 1 ; targets = [targets[rand(targets.size)]]
    when 2 ; targets -= @battler if targets.include?(@battler)
    end
    for target in targets
      for id in @action_data[4]
        target.add_state(id) if @action_data[3] == "+"
        target.remove_state(id) if @action_data[3] == "-"
      end
    end
  end 
  #--------------------------------------------------------------------------
  # ● FPS変更
  #--------------------------------------------------------------------------
  def fps
    Graphics.frame_rate = @action_data[1]
    start_action
  end
  #--------------------------------------------------------------------------
  # ● バトラー画像変更の場合
  #--------------------------------------------------------------------------
  def graphics_change
    @graphics_change = true
    return @battler.graphics_change(@action_data[3]) if !@battler.actor?
    @pre_change_data = [@battler.character_name, @battler.character_index, @battler.face_name, @battler.face_index] if @pre_change_data == nil && !@action_data[1]
    if @action_data[4] == []
      face_name = @battler.face_name
      face_index = @battler.face_index
    else
      face_name = @action_data[4][1]
      face_index = @action_data[4][0]
    end
    @battler.set_graphic(@action_data[3], @action_data[2], face_name, face_index)
  end 
  #--------------------------------------------------------------------------
  # ● スキル派生 
  #--------------------------------------------------------------------------
  def derivating_skill
    # 未修得スキルは派生不可なら
    return if !@action_data[1] && !@battler.skill_learn?($data_skills[@action_data[3]])
    # コスト不足は派生不可なら
    return if !@action_data[2] && !@battler.skill_cost_payable?($data_skills[@action_data[3]])
    # 派生
    @derivation_skill_id = @action_data[3]
    # 以降のアクションをキャンセル
    @full_action = []
  end
  #--------------------------------------------------------------------------
  # ● BGM/BGS/SE演奏
  #--------------------------------------------------------------------------
  def sound
    pitch = @action_data[2] 
    vol   = @action_data[3]
    name  = @action_data[4] 
    case @action_data[1]
    when "se"
      Audio.se_play("Audio/SE/" + name, vol, pitch)
    when "bgm"
      # 名前指定のない場合、現在のBGMを変えないように
      name = RPG::BGM.last.name if @action_data[4] == ""
      Audio.bgm_play("Audio/BGM/" + name, vol, pitch)
    when "bgs"
      name = RPG::BGS.last.name if @action_data[4] == ""
      Audio.bgs_play("Audio/BGS/" + name, vol, pitch)
    end
  end
  #--------------------------------------------------------------------------
  # ● ムービーの再生
  #--------------------------------------------------------------------------
  def movie
    Graphics.play_movie('Movies/' + @action_data[1])
  end
  #--------------------------------------------------------------------------
  # ● ゲームスイッチ操作
  #--------------------------------------------------------------------------
  def switches
    for id in @action_data[1]
      $game_switches[id] = true if id > 0
      $sv_camera.switches[id.abs] = true  if id < 0
    end
    for id in @action_data[2]
      $game_switches[id] = false if id > 0
      $sv_camera.switches[id.abs] = false  if id < 0
    end
    $sv_camera.program_check
  end
  #--------------------------------------------------------------------------
  # ● ゲーム変数操作
  #--------------------------------------------------------------------------
  def variable
    # オペランドチェック
    operand = @action_data[3]
    operand = $game_variables[@action_data[3].abs] if @action_data[3] < 0
    # 変数操作で分岐
    case @action_data[2]
    when 0 ; $game_variables[@action_data[1]] = operand  # 代入
    when 1 ; $game_variables[@action_data[1]] += operand # 加算
    when 2 ; $game_variables[@action_data[1]] -= operand # 減算
    when 3 ; $game_variables[@action_data[1]] *= operand # 乗算
    when 4 ; $game_variables[@action_data[1]] /= operand # 除算
    when 5 ; $game_variables[@action_data[1]] %= operand # 剰余
    end
  end  
  #--------------------------------------------------------------------------
  # ● 条件分岐 (ゲームスイッチ)
  #--------------------------------------------------------------------------
  def nece_1
    judgment = $game_switches[@action_data[1]] == @action_data[2] if @action_data[1] > 0
    judgment = $sv_camera.switches[@action_data[1].abs] == @action_data[2] if @action_data[1] < 0
    action_diverging(judgment, @action_data[3])
  end  
  #--------------------------------------------------------------------------
  # ● 条件分岐 (ゲーム変数)
  #--------------------------------------------------------------------------
  def nece_2
    variable = $game_variables[@action_data[1]]
    num = @action_data[2]
    num = $game_variables[@action_data[2].abs] if num < 0
    case @action_data[3]
    when 0 ; judgment = variable == num
    when 1 ; judgment = variable < num
    when 2 ; judgment = variable > num
    end  
    action_diverging(judgment, @action_data[4])
  end  
  #--------------------------------------------------------------------------
  # ● 条件分岐 (ステート)
  #--------------------------------------------------------------------------
  def nece_3
    targets = N03.get_targets(@action_data[1], @battler)
    return if targets == []
    member_num = @action_data[4]
    member_num = targets.size if @action_data[4] == 0 && targets.size > 1
    hit_count = 0
    miss_count = 0
    for target in targets
      hit_count += 1 if target.state?(@action_data[2])
      miss_count += 1 if !target.state?(@action_data[2])
    end
    case @action_data[3]
    when 0 ; judgment = hit_count >= member_num
    when 1 ; judgment = miss_count >= member_num
    end
    action_diverging(judgment, @action_data[5])
  end  
  #--------------------------------------------------------------------------
  # ● 条件分岐 (スキル)
  #--------------------------------------------------------------------------
  def nece_4
    targets = N03.get_targets(@action_data[1], @battler)
    return if targets == []
    member_num = @action_data[4]
    member_num = targets.size if @action_data[4] == 0 && targets.size > 1
    hit_count = 0
    miss_count = 0
    for target in targets
      hit_count += 1 if target.skill_learn?($data_skills[@action_data[2]]) && target.skill_conditions_met?($data_skills[@action_data[2]])
      miss_count += 1 if !target.skill_learn?($data_skills[@action_data[2]]) or !target.skill_conditions_met?($data_skills[@action_data[2]])
    end
    case @action_data[3]
    when 0 ; judgment = hit_count >= member_num
    when 1 ; judgment = miss_count >= member_num
    end
    action_diverging(judgment, @action_data[5])
  end  
  #--------------------------------------------------------------------------
  # ● 条件分岐 (パラメータ)
  #--------------------------------------------------------------------------
  def nece_5
    targets = N03.get_targets(@action_data[1], @battler)
    return if targets == []
    member_num = @action_data[5]
    member_num = targets.size if @action_data[5] == 0 && targets.size > 1
    hit_count = 0
    for target in targets
      hit_count += 1 if target.comparison_parameter([@action_data[2],@action_data[3],@action_data[4]])
    end
    judgment = hit_count >= member_num
    action_diverging(judgment, @action_data[6])
  end  
  #--------------------------------------------------------------------------
  # ● 条件分岐 (装備)
  #--------------------------------------------------------------------------
  def nece_6
    targets = N03.get_targets(@action_data[1], @battler)
    return if targets == []
    member_num = @action_data[5]
    member_num = targets.size if @action_data[5] == 0 && targets.size > 1
    hit_count = 0
    miss_count = 0
    for target in targets
      hit_count += 1 if target.comparison_equip([@action_data[2],@action_data[3]])
      miss_count += 1 if !target.comparison_equip([@action_data[2],@action_data[3]])
    end
    case @action_data[4]
    when 0 ; judgment = hit_count >= member_num
    when 1 ; judgment = miss_count >= member_num
    end
    action_diverging(judgment, @action_data[6])
  end  
  #--------------------------------------------------------------------------
  # ● 条件分岐 (スクリプト)
  #--------------------------------------------------------------------------
  def nece_7
    judgment = eval(@action_data[2])
    action_diverging(judgment, @action_data[1])
  end  
  #--------------------------------------------------------------------------
  # ● アクション分岐  
  #--------------------------------------------------------------------------
  def action_diverging(judgment, kind)
    result = 0
    if judgment
      result = 1 if kind == 1
      result = 2 if kind == 2
    else
      result = 1 if kind == 0
    end
    # ﾌﾙｱｸｼｮﾝ終了
    return @full_action = []  if result == 2
    # 次のｱｸｼｮﾝを除去
    @full_action.shift if result == 1
    set_action
    # 次のｱｸｼｮﾝを実行
    @action_data = N03::ACTION[@action]
    next_action
  end
  #--------------------------------------------------------------------------
  # ● セカンドターゲット操作
  #--------------------------------------------------------------------------
  def second_targets_set
    targets = N03.get_targets(@action_data[1], @battler)
    for target in targets
      targets.delete(target) if @action_data[2][1] == 1 && target.index != @action_data[2][0]
      targets.delete(target) if @action_data[2][1] == 2 && target.index == @action_data[2][0].abs
      targets.delete(target) if @action_data[3] > 0 && target.id != @action_data[3]
      targets.delete(target) if @action_data[3] < 0 && target.id == @action_data[3].abs
      targets.delete(target) if @action_data[4] > 0 && !target.state?(@action_data[4])
      targets.delete(target) if @action_data[4] < 0 && target.state?(@action_data[4].abs)
      targets.delete(target) if @action_data[5] > 0 && !target.skill_conditions_met?($data_skills[@action_data[5]])
      targets.delete(target) if @action_data[5] < 0 && target.skill_conditions_met?($data_skills[@action_data[5].abs])
      targets.delete(target) if !target.comparison_parameter(@action_data[6])
      targets.delete(target) if !@action_data[7][1].include?(0) && !target.comparison_equip(@action_data[7])
    end
    return @second_targets = [] if targets.size == 0
    case @action_data[8]
    when 1 ; targets = [targets[rand(targets.size)]]
    when 2 ; targets.delete(@battler)
    end
    return @second_targets = [] if targets.size == 0
    @second_targets = targets
    case @action_data[9]
    when 0 ; return
    when 1 ; set_play_data(["second_targets_set"])
    when 2 ; set_play_data(["targets_set"])
    end
    @wait += 1
  end
  #--------------------------------------------------------------------------
  # ● コモンイベント呼び出し
  #--------------------------------------------------------------------------
  def call_common_event
    $game_temp.reserve_common_event(@action_data[1])
    $sv_camera.event = true
    @event_fix = @action_data[2]
  end
  #--------------------------------------------------------------------------
  # ● ダメージアニメ
  #--------------------------------------------------------------------------
  def damage_anime(delay_time = 12)
    anime(N03.get_attack_anime_id(-3, @battler), wait = true)
    action_play
    @wait -= delay_time
    @full_action.unshift("eval('@damage_anime_data = []
    @set_damage = true')")
  end
  #--------------------------------------------------------------------------
  # ● 通常コラプス
  #--------------------------------------------------------------------------
  def normal_collapse
    @collapse = true
    return
  end
  #--------------------------------------------------------------------------
  # ● 初期位置変更
  #--------------------------------------------------------------------------
  def change_base_position
    @base_x = @x
    @base_y = @y
    @base_h = @h
  end  
  #--------------------------------------------------------------------------
  # ● 強制アクション実行
  #--------------------------------------------------------------------------
  def force_act
    target(@full_action.shift)
  end
  #--------------------------------------------------------------------------
  # ● 強制アクション実行 (セカンドターゲット)
  #--------------------------------------------------------------------------
  def force_act2
    target2(@full_action.shift)
  end
  #--------------------------------------------------------------------------
  # ● 個別処理開始
  #--------------------------------------------------------------------------
  def individual_start
    @individual_targets = @target_battler.dup
    @remain_targets = @target_battler.dup
    @target_battler = [@individual_targets[0]]
    # リピート部分のアクションを保持
    @individual_act = @full_action.dup
  end
  #--------------------------------------------------------------------------
  # ● 個別処理終了
  #--------------------------------------------------------------------------
  def individual_end
    @individual_targets.shift
    for target in @individual_targets
      @individual_targets.shift if target.dead?
    end
    # ターゲットが残っているなら行動リピート
    return @target_battler = @remain_targets if @individual_targets.size == 0
    @full_action = @individual_act.dup
    @target_battler = [@individual_targets[0]]
  end
  #--------------------------------------------------------------------------
  # ● ループ開始
  #--------------------------------------------------------------------------
  def loop_start
    # ループ部分のアクションを保持
    @loop_act = @full_action.dup
  end
  #--------------------------------------------------------------------------
  # ● ループ終了
  #--------------------------------------------------------------------------
  def loop_end
    # 行動リピート
    @full_action = @loop_act.dup if @loop_act != []
  end
  #--------------------------------------------------------------------------
  # ● 次の行動者へ移行
  #--------------------------------------------------------------------------
  def next_battler
    @action_end = true
    @active = false
  end
  #--------------------------------------------------------------------------
  # ● 画像変更フラグ
  #--------------------------------------------------------------------------
  def set_change
    @change_up = true
  end
  #--------------------------------------------------------------------------
  # ● 戦闘シーン通信
  #--------------------------------------------------------------------------
  def play_data
    data = @play_data
    @play_data = []
    return data
  end
  #--------------------------------------------------------------------------
  # ● ショートカットコマンド
  #--------------------------------------------------------------------------
  def anime(anime_id, wait = true)
    @action_data = ["anime",anime_id,1,false,wait,false,true,false]
  end
  def anime_me(anime_id, wait = true)
    @action_data = ["anime",anime_id,0,false,wait,false,true,false]
  end
  def se(file, pitch = 100)
    @action_data = ["sound",  "se", pitch, 100, file]
  end
  def target(act)
    for target in @target_battler do target.sv.force_action = act end
  end
  def target2(act)
    for target in @second_targets do target.sv.force_action = act end
  end
  def delay(time)
    @wait = @battler.index * time
  end
  #--------------------------------------------------------------------------
  # ● バトラーのIDを取得
  #--------------------------------------------------------------------------
  def id
    return @battler.id if @battler.actor?
    return -@battler.id
  end
  #--------------------------------------------------------------------------
  # ● 被クリティカルフラグを取得
  #--------------------------------------------------------------------------
  def critical?
    return @battler.result.critical
  end
  #--------------------------------------------------------------------------
  # ● 被回復フラグを取得
  #--------------------------------------------------------------------------
  def recovery?
    recovery = false
    recovery = true if @battler.result.hp_damage < 0
    recovery = true if @battler.result.mp_damage < 0
    recovery = true if @battler.result.tp_damage < 0
    return recovery
  end
  #--------------------------------------------------------------------------
  # ● 被スキルIDを取得
  #--------------------------------------------------------------------------
  def damage_skill_id
    return @damage_skill_id
  end
  #--------------------------------------------------------------------------
  # ● 被アイテムIDを取得
  #--------------------------------------------------------------------------
  def damage_item_id
    return @damage_item_id
  end
  #--------------------------------------------------------------------------
  # ● 装備武器を取得
  #--------------------------------------------------------------------------
  def weapon_id
    return 0 if !@battler.weapons[0]
    return @battler.weapons[0].id
  end
  #--------------------------------------------------------------------------
  # ● 装備武器のタイプを取得
  #--------------------------------------------------------------------------
  def weapon_type
    return 0 if !@battler.weapons[0]
    return @battler.weapons[0].wtype_id
  end
  #--------------------------------------------------------------------------
  # ● 盾を装備しているか
  #--------------------------------------------------------------------------
  def shield?
    for armor in @battler.armors do return true if armor != nil && armor.etype_id == 1 end
    return false
  end
  #--------------------------------------------------------------------------
  # ● ダメージがあるか
  #--------------------------------------------------------------------------
  def damage_zero?
    return @battler.result.hp_damage == 0 && @battler.result.mp_damage == 0 && @battler.result.tp_damage == 0
  end
  #--------------------------------------------------------------------------
  # ● スキルIDを取得
  #--------------------------------------------------------------------------
  def skill_id
    return @counter_id if @counter_id != 0
    return 0 if @battler.current_action == nil or @battler.current_action.item == nil
    return 0 if @battler.current_action.item.is_a?(RPG::Item)
    return @battler.current_action.item.id
  end
  #--------------------------------------------------------------------------
  # ● スキルのタイプを取得
  #--------------------------------------------------------------------------
  def skill_type
    return 0 if skill_id == 0
    return $data_skills[skill_id].stype_id
  end
  #--------------------------------------------------------------------------
  # ● スキル名を取得
  #--------------------------------------------------------------------------
  def skill_name
    return "" if skill_id == 0
    return $data_skills[skill_id].name
  end
  #--------------------------------------------------------------------------
  # ● アイテムIDを取得
  #--------------------------------------------------------------------------
  def item_id
    return 0 if @battler.current_action == nil or @battler.current_action.item == nil
    return @battler.current_action.item.id
  end
  #--------------------------------------------------------------------------
  # ● 攻撃アクション
  #--------------------------------------------------------------------------
  def attack_action(item)
    return skill_action if item.is_a?(RPG::Skill)
    return item_action
  end
  #--------------------------------------------------------------------------
  # ● ダメージアクションベース
  #--------------------------------------------------------------------------
  def damage_action_base(item)
    @damage_skill_id = 0
    @damage_item_id = 0
    @damage_skill_id = item.id if item.is_a?(RPG::Skill)
    @damage_item_id = item.id if item.is_a?(RPG::Item)
  end  
  #--------------------------------------------------------------------------
  # ● ダメージアクション 
  #--------------------------------------------------------------------------
  def damage_action(attacker, item)
    damage_action_base(item)
    act = damage(attacker)
    return if @active
    start_action(act) if act != nil
  end
  #--------------------------------------------------------------------------
  # ● 回避アクション
  #--------------------------------------------------------------------------
  def evasion_action(attacker, item)
    damage_action_base(item)
    act = evasion(attacker)
    return if @active
    start_action(act) if act != nil
  end
  #--------------------------------------------------------------------------
  # ● ミスアクション
  #--------------------------------------------------------------------------
  def miss_action(attacker, item)
    damage_action_base(item)
    act = miss(attacker)
    return if @active
    start_action(act) if act != nil
  end
  #--------------------------------------------------------------------------
  # ● 閃きスクリプト併用処理
  #--------------------------------------------------------------------------
  def flash_action
    return "Flash Self"
  end
  
end

 
#==============================================================================
# ■ module N03
#------------------------------------------------------------------------------
# 　サイドビューバトルのモジュールです。
#==============================================================================
module N03
  #--------------------------------------------------------------------------
  # ● バトラーの敵グループを取得
  #--------------------------------------------------------------------------
  def self.get_enemy_unit(battler)
    return $game_troop if battler.actor?
    return $game_party
  end
  #--------------------------------------------------------------------------
  # ● バトラーの味方グループを取得
  #--------------------------------------------------------------------------
  def self.get_party_unit(battler)
    return $game_party if battler.actor?
    return $game_troop
  end
  #--------------------------------------------------------------------------
  # ● 戦闘アニメ時間の取得
  #--------------------------------------------------------------------------
  def self.get_anime_time(anime_id)
    return 0 if anime_id <= 0
    return $data_animations[anime_id].frame_max * 4
  end
  #--------------------------------------------------------------------------
  # ● 攻撃アニメの取得
  #--------------------------------------------------------------------------
  def self.get_attack_anime_id(kind, battler)
    return $data_skills[battler.sv.counter_id].animation_id if kind == -3 && battler.sv.counter_id != 0
    case kind
    when -1 ; anime_id = battler.atk_animation_id1
    when -2 ; anime_id = battler.atk_animation_id2
    when -3
      if battler.current_action != nil
        anime_id = battler.current_action.item.animation_id if battler.current_action.item != nil
      end
    else    ; anime_id = kind
    end
    case anime_id
    when -1 ; anime_id = battler.atk_animation_id1
    when -2 ; anime_id = battler.atk_animation_id2
    end
    return anime_id if anime_id
    return 0
  end  
  #--------------------------------------------------------------------------
  # ● 戦闘アニメデータをセット
  #--------------------------------------------------------------------------
  def self.set_damage_anime_data(targets, target, data)
    return if !first_of_all_screen_anime(data[0], target, targets)
    target.animation_id         = data[0]
    target.animation_mirror     = data[1]
    target.sv.anime_no_mirror   = data[2]
    target.sv.anime_camera_zoom = data[3]
    target.sv.anime_plus_z      = data[4]
  end    
  #--------------------------------------------------------------------------
  # ● ターゲットの取得 
  #--------------------------------------------------------------------------
  def self.get_targets(kind, battler)
    case kind.abs
    when 0 ; return [battler].dup
    when 1 ; return battler.sv.target_battler.dup
    when 2 ; return get_enemy_unit(battler).members.dup
    when 3 ; return get_party_unit(battler).members.dup
    when 4 ; return $game_troop.members.dup + $game_party.battle_members.dup
    when 5 ; return battler.sv.second_targets.dup
    end
  end  
  #--------------------------------------------------------------------------
  # ● ターゲットの座標を取得
  #--------------------------------------------------------------------------
  def self.get_targets_position(targets, horming, m_a = nil)
    return [0,0,0] if targets == nil && !$sv_camera.mirror
    return [Graphics.width,0,0] if targets == nil && $sv_camera.mirror
    x = y = h = 0
    for i in 0...targets.size
      x += targets[i].sv.base_x if !horming
      y += targets[i].sv.base_y if !horming
      h += targets[i].sv.base_h if !horming
      x += targets[i].sv.x if horming
      y += targets[i].sv.y if horming
      h += targets[i].sv.h if horming
      y -= targets[i].sv.ch * 100 if m_a == 0
      y -= targets[i].sv.ch * 50 if m_a == 1
    end
    return [x / targets.size, y / targets.size, h / targets.size]
  end
  #--------------------------------------------------------------------------
  # ● 速度を時間に変換
  #--------------------------------------------------------------------------
  def self.distanse_calculation(time, target_position, self_position, distanse_move)
    return time if !distanse_move
    distanse_x = self_position[0] - target_position[0]
    distanse_x = target_position[0] - self_position[0] if target_position[0] > self_position[0]
    distanse_y = self_position[1] - target_position[1]
    distanse_y = target_position[1] - self_position[1] if target_position[1] > self_position[1]
    if self_position[2] != nil && target_position[2] != nil
      distanse_h = self_position[2] - target_position[2]
      distanse_h = target_position[2] - self_position[2] if target_position[2] > self_position[2]
    else
      distanse_h = 0
    end
    distanse = [distanse_x, distanse_y, distanse_h].max
    return distanse / (time * 100) + 1
  end
  #--------------------------------------------------------------------------
  # ● 放物線移動計算
  #--------------------------------------------------------------------------
  def self.parabola(data, time, size, type = 1)
    move_data = data
    move_data[0] *= size
    move_data[1] *= size
    move = []
    move_d = []
    for i in 0...time / 2
      move[i] = move_data[0]
      move_d[i] = move_data[1]
      move_data[0] = move_data[0] * type / (1 + type)
      move_data[1] = move_data[1] * type / (1 + type)
    end
    move = move + move_d.reverse!
    move.reverse!
    adjust = move.inject(0) {|result, item| result + item }
    move[move.size - 1] += adjust if data[0] == data[1] && adjust != 0
    move.unshift(0) if time % 2 != 0
    return move
  end
  #--------------------------------------------------------------------------
  # ● 反転値
  #--------------------------------------------------------------------------
  def self.mirror_num(mirror)
    return 1 if !mirror
    return -1
  end  
  #--------------------------------------------------------------------------
  # ● カメラワーク
  #--------------------------------------------------------------------------
  def self.camera(battler, data)
    battler = $game_party.battle_members[0] if !battler
    cx = data[2][0] * 100
    cy = data[2][1] * 100
    return $sv_camera.move(cx, cy, data[3], data[4], true) if data[1] == 6
    targets = self.get_targets(data[1], battler)
    return if targets == nil or targets == []
    position = self.get_targets_position(targets, true)
    $sv_camera.move(position[0], position[1] - position[2], data[3], data[4], false)
  end
  #--------------------------------------------------------------------------
  # ● コラプス禁止
  #--------------------------------------------------------------------------
  def self.immortaling
    # 全員に不死身付与
    for member in $game_party.battle_members + $game_troop.members
      # イベント操作等で不死身設定になっていたら解除を無効にするフラグを立てる
      member.sv.immortal = true if member.state?(N03::IMMORTAL_ID)
      member.add_state(N03::IMMORTAL_ID)
    end
    return true
  end  
  #--------------------------------------------------------------------------
  # ● コラプス許可
  #--------------------------------------------------------------------------
  def self.unimmortaling
    # 全員の不死身化解除(イベント等で不死身設定がされていれば除く)
    for member in $game_party.battle_members + $game_troop.members
      next if member.dead?
      # 不死身ステートが行動中に解除されていた場合、解除無効を解除
      member.sv.immortal = false if !member.state?(N03::IMMORTAL_ID) && member.sv.immortal
      next member.sv.immortal = false if member.sv.immortal
      member.remove_state(N03::IMMORTAL_ID)
      next if member.hp != 0
      member.add_state(1)
      member.perform_collapse_effect
      member.sv.action_terminate
    end
    return false
  end  
  #--------------------------------------------------------------------------
  # ● スキル派生
  #--------------------------------------------------------------------------
  def self.derived_skill(battler)
    battler.force_action(battler.sv.derivation_skill_id, -2)
    BattleManager.unshift_action_battlers(battler)
  end
  #--------------------------------------------------------------------------
  # ● ダメージの作成
  #--------------------------------------------------------------------------
  def self.set_damage(battler, hp_damage, mp_damage)
    battler.result.hp_damage = hp_damage
    battler.result.mp_damage = mp_damage
  end
  #--------------------------------------------------------------------------
  # ● ターゲット生死確認
  #--------------------------------------------------------------------------
  def self.targets_alive?(targets)
    return false if targets == []
    for target in targets do return true if !target.dead? end
    return false
  end
  #--------------------------------------------------------------------------
  # ● ターゲットをセカンドターゲットへ
  #--------------------------------------------------------------------------
  def self.s_targets(battler)
    battler.sv.target_battler = battler.sv.second_targets
    return battler.sv.second_targets
  end  
  #--------------------------------------------------------------------------
  # ● セカンドターゲットをターゲットへ
  #--------------------------------------------------------------------------
  def self.targets_set(battler)
    battler.sv.second_targets = battler.current_action.make_targets.compact
    battler.sv.target_battler = battler.sv.second_targets
  end  
  #--------------------------------------------------------------------------
  # ● 戦闘アニメ実行判定 (対象：画面時は最初のターゲットのみアニメ実行)
  #--------------------------------------------------------------------------
  def self.first_of_all_screen_anime(anime_id, target, targets)
    anime = $data_animations[anime_id]
    return false if !anime
    return true if anime.position != 3
    return false if anime.position == 3 && target != targets[0]
    targets.delete(target)
    target.sv.timing_targets = targets
    return true
  end
  #--------------------------------------------------------------------------
  # ● 戦闘不能付加攻撃か
  #--------------------------------------------------------------------------
  def self.dead_attack?(battler, item)
    for state in battler.atk_states
      return true if state == battler.death_state_id
    end
    for effect in item.effects
      return true if effect.code == 21 && effect.data_id == battler.death_state_id
    end
    return false
  end
end