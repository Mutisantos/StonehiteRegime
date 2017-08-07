#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● フレーム更新（基本）
  #--------------------------------------------------------------------------
  alias update_basic_scene_battle_n03 update_basic
  def update_basic
    update_basic_scene_battle_n03
    $sv_camera.update
    $sv_camera.wait = N03::TURN_END_WAIT + 1 if $sv_camera.win_wait
    camera_wait
  end
  #--------------------------------------------------------------------------
  # ● カメラウェイト
  #--------------------------------------------------------------------------
  def camera_wait
    process_event if $sv_camera.event
    $sv_camera.event = false if $sv_camera.event
    while $sv_camera.wait != 0
      Graphics.update
      Input.update
      update_all_windows
      $game_timer.update
      $game_troop.update
      $sv_camera.update
      @spriteset.update
      update_info_viewport
      update_message_open
      $sv_camera.wait -= 1 if $sv_camera.wait > 0
      $sv_camera.wait = 1 if $sv_camera.wait == 0 && @spriteset.effect?
      BattleManager.victory if $sv_camera.win_wait && $sv_camera.wait == 0
    end
  end
  #--------------------------------------------------------------------------
  # ● カメラウェイトのセット
  #--------------------------------------------------------------------------
  def set_camera_wait(time)
    $sv_camera.wait = time
    camera_wait
  end  
  #--------------------------------------------------------------------------
  # ● エフェクト実行が終わるまでウェイト ★再定義
  #--------------------------------------------------------------------------
  def wait_for_effect
  end
  #--------------------------------------------------------------------------
  # ● ターン開始
  #--------------------------------------------------------------------------
  alias turn_start_scene_battle_n03 turn_start
  def turn_start
    turn_start_scene_battle_n03
    N03.camera(nil, N03::BATTLE_CAMERA["After Turn Start"].dup)
  end
  #--------------------------------------------------------------------------
  # ● ターン終了
  #--------------------------------------------------------------------------
  alias turn_end_scene_battle_n03 turn_end
  def turn_end
    turn_end_scene_battle_n03
    for member in $game_troop.members + $game_party.members
      N03.set_damage(member, member.sv.result_damage[0],member.sv.result_damage[1])
      member.sv.result_damage = [0,0]
      @spriteset.set_damage_pop(member) if member.result.hp_damage != 0 or member.result.mp_damage != 0
    end
    set_camera_wait(N03::TURN_END_WAIT)
    N03.camera(nil, N03::BATTLE_CAMERA["Before Turn Start"].dup) if $game_party.inputable?
    @log_window.clear
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用 ★再定義
  #--------------------------------------------------------------------------
  def use_item
    item = @subject.current_action.item
    display_item(item)
    @subject.use_item(item)
    refresh_status
    @targets = @subject.current_action.make_targets.compact
    @targets = [@subject] if @targets.size == 0
    set_substitute(item)
    for time in item.repeats.times do play_sideview(@targets, item) end
    end_reaction(item)
    display_end_item
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテム名の表示
  #--------------------------------------------------------------------------
  def display_item(item)
    return @log_window.display_use_item(@subject, item) if N03::BATTLE_LOG
    @log_window.off
    @skill_name_window = Window_Skill_name.new(item.name) unless N03::NO_DISPLAY_SKILL_ID.include?(item.id) && item.is_a?(RPG::Skill)
  end  
  #--------------------------------------------------------------------------
  # ● スキル／アイテム名の表示終了
  #--------------------------------------------------------------------------
  def display_end_item
    @skill_name_window.dispose if @skill_name_window != nil
    @skill_name_window = nil
    set_camera_wait(N03::ACTION_END_WAIT) if @subject.sv.derivation_skill_id == 0
    @log_window.clear if N03::BATTLE_LOG
  end  
  #--------------------------------------------------------------------------
  # ● 反撃／魔法反射／身代わり処理
  #--------------------------------------------------------------------------
  def end_reaction(item)
    end_substitute if @substitute != nil
    set_reflection(item) if @reflection_data != nil
    set_counter_attack if @counter_attacker != nil
  end  
  #--------------------------------------------------------------------------
  # ● 反撃の発動 ★再定義
  #--------------------------------------------------------------------------
  def invoke_counter_attack(target, item)
    return if @subject.sv.counter_id != 0
    @counter_attacker = [] if @counter_attacker == nil
    return apply_item_effects(apply_substitute(target, item), item) if !target.movable?
    @log_window.add_text(sprintf(Vocab::CounterAttack, target.name)) if N03::BATTLE_LOG
    target.sv.counter_id = target.sv.counter_skill_id
    @counter_attacker.push(target)
  end
  #--------------------------------------------------------------------------
  # ● 魔法反射の発動 ★再定義
  #--------------------------------------------------------------------------
  def invoke_magic_reflection(target, item)
    return if @subject.sv.reflection_id != 0
    @log_window.add_text(sprintf(Vocab::MagicReflection, target.name)) if N03::BATTLE_LOG
    target.sv.reflection_id = target.sv.reflection_anime_id
  end
  #--------------------------------------------------------------------------
  # ● 身代わりの適用 ★再定義
  #--------------------------------------------------------------------------
  def apply_substitute(target, item)
    return target if @substitute == nil
    return target if !check_substitute(target, item)
    return @substitute
  end
  #--------------------------------------------------------------------------
  # ● 身代わりセット
  #--------------------------------------------------------------------------
  def set_substitute(item)
    @substitute = N03.get_enemy_unit(@subject).substitute_battler
    return if @substitute == nil
    s_targets = []
    for i in 0...@targets.size
      next if @targets[i] == @substitute
      next if !check_substitute(@targets[i], item)
      @log_window.add_text(sprintf(Vocab::Substitute, @substitute.name, @targets[i].name))
      @targets[i].sv.start_action(@targets[i].sv.substitute_receiver_start_action)
      s_targets.push(@targets[i])
      @targets[i] = @substitute
    end
    return @substitute = nil if s_targets == []
    @substitute.sv.set_target(s_targets)
    @substitute.sv.start_action(@substitute.sv.substitute_start_action)
  end  
  #--------------------------------------------------------------------------
  # ● 身代わり終了
  #--------------------------------------------------------------------------
  def end_substitute
    for member in @substitute.sv.target_battler
      member.sv.start_action(member.sv.substitute_receiver_end_action)
    end  
    @substitute.sv.start_action(@substitute.sv.substitute_end_action)
    @substitute = nil
  end
  #--------------------------------------------------------------------------
  # ● 反撃
  #--------------------------------------------------------------------------
  def set_counter_attack
    pre_subject = @subject
    for attacker in @counter_attacker
      @subject = attacker
      item = $data_skills[attacker.sv.counter_skill_id]
      play_sideview([pre_subject], item) 
    end
    # 同一カウンター者を考慮してカウンターIDの初期化はアクション後に実行
    for attacker in @counter_attacker do attacker.sv.counter_id = 0 end
    @subject = pre_subject
    @counter_attacker = nil
  end
  #--------------------------------------------------------------------------
  # ● 魔法反射
  #--------------------------------------------------------------------------
  def set_reflection(item)
    @log_window.back_to(1)
    for data in @reflection_data
      @subject.sv.damage_action(@subject, item)
      N03.set_damage_anime_data([@subject], @subject, data)
      apply_item_effects(@subject, item)
      @spriteset.set_damage_pop(@subject)
    end
    set_camera_wait(N03.get_anime_time(@reflection_data[0][0]))
    @reflection_data = nil
  end
  #--------------------------------------------------------------------------
  # ● サイドビューアクション実行
  #--------------------------------------------------------------------------
  def play_sideview(targets, item)
    @subject.sv.set_target(targets)
    return if @subject.sv.attack_action(item) == nil
    return if !@subject.movable?
    return if item.scope != 9 && item.scope != 10 && !N03.targets_alive?(targets)
    @subject.sv.start_action(@subject.sv.attack_action(item))
    @subject.sv.unshift_action(@subject.sv.flash_action) if @subject.flash_flg
    @subject.sv.active = true
    @subject.sv.command_action = false
    loop do
      update_basic
      data = @subject.sv.play_data
      @targets = N03.s_targets(@subject) if data[0] == "second_targets_set"
      N03.targets_set(@subject)          if data[0] == "targets_set"
      @immortal = N03.immortaling        if data[0] == "no_collapse" && !N03.dead_attack?(@subject, item)
      @immortal = N03.unimmortaling      if data[0] == "collapse"
      next set_move_anime(item)          if @subject.sv.m_a_data != []
      set_damage(item)                   if @subject.sv.set_damage
      break N03.derived_skill(@subject)  if @subject.sv.derivation_skill_id != 0
      break                              if @subject.sv.action_end or @subject.hidden?
    end
    @immortal = N03.unimmortaling        if @immortal
  end
  #--------------------------------------------------------------------------
  # ● ダメージの実行
  #--------------------------------------------------------------------------
  def set_damage(item)
    targets = @targets
    targets = [@subject.sv.individual_targets[0]] if @subject.sv.individual_targets.size != 0
    for target in targets do damage_anime(targets.dup, target, item) end
    @subject.sv.set_damage = false
    @subject.sv.damage_anime_data = []
  end
  #--------------------------------------------------------------------------
  # ● ダメージ戦闘アニメ処理
  #--------------------------------------------------------------------------
  def damage_anime(targets, target, item)
    @log_window.back_to(1) if @log_window.line_number == 5
    return if item.scope != 9 && item.scope != 10 && target.dead?
    @miss = false
    invoke_item(target,item)
    if target.result.missed
      target.sv.miss_action(@subject, item)
      return @miss = true
    elsif target.result.evaded or target.sv.counter_id != 0
      target.sv.evasion_action(@subject, item)
      return @miss = true
    elsif target.sv.reflection_id != 0
      N03.set_damage_anime_data(targets, target, [target.sv.reflection_id, false, false, true])
      target.sv.reflection_id = 0
      @reflection_data = [] if @reflection_data == nil
      return @reflection_data.push([N03.get_attack_anime_id(-3, @subject), false, false, true])
    end
    target.sv.damage_action(@subject, item)
    N03.set_damage(@subject, -target.result.hp_drain, -target.result.mp_drain) if target != @subject
    @spriteset.set_damage_pop(target)
    @spriteset.set_damage_pop(@subject) if target != @subject && @subject.result.hp_damage != 0 or @subject.result.mp_damage != 0
    N03.set_damage_anime_data(targets, target, @subject.sv.damage_anime_data) if @subject.sv.damage_anime_data != []
  end
  #--------------------------------------------------------------------------
  # ● 飛ばしアニメ処理
  #--------------------------------------------------------------------------
  def set_move_anime(item)
    for data in @subject.sv.m_a_data
      @subject.sv.damage_anime_data = data[4]
      hit_targets = []
      for target in data[1]
        damage_anime(data[1], target, item) if data[0]
        hit_targets.push(target) if !@miss
      end
      @miss = false if !data[3]
      @spriteset.set_hit_animation(@subject, data[2], hit_targets, @miss)
    end
    @subject.sv.set_damage = false
    @subject.sv.m_a_data = []
  end
end

#==============================================================================
# ■ DataManager
#------------------------------------------------------------------------------
# 　データベースとゲームオブジェクトを管理するモジュールです。
#==============================================================================
module DataManager
  #--------------------------------------------------------------------------
  # ● 各種ゲームオブジェクトの作成 ★再定義
  #--------------------------------------------------------------------------
  def self.create_game_objects
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_timer         = Game_Timer.new
    $game_message       = Game_Message.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    $sv_camera          = Battle_Camera.new
  end
end

#==============================================================================
# ■ BattleManager
#------------------------------------------------------------------------------
# 　戦闘の進行を管理するモジュールです。
#==============================================================================
module BattleManager
  #--------------------------------------------------------------------------
  # ● エンカウント時の処理 ★再定義
  #--------------------------------------------------------------------------
  def self.on_encounter
    @preemptive = (rand < rate_preemptive)
    @surprise = (rand < rate_surprise && !@preemptive)
    $sv_camera.mirror = @surprise if N03::BACK_ATTACK
  end
  #--------------------------------------------------------------------------
  # ● 勝利の処理 ★再定義
  #--------------------------------------------------------------------------
  def self.process_victory
    
    $sv_camera.win_wait = true
  end  
  #--------------------------------------------------------------------------
  # ● 勝利
  #--------------------------------------------------------------------------
  def self.victory
    $sv_camera.win_wait = false 
    N03.camera(nil, N03::BATTLE_CAMERA["End of Battle"].dup)
    for member in $game_party.members do member.sv.start_action(member.sv.win) if member.movable? end
    play_battle_end_me
    SceneManager.scene.abs_wait(100)##ESPERAR
    replay_bgm_and_bgs
    $game_message.add(sprintf(Vocab::Victory, $game_party.name))
    display_exp
    gain_gold
    gain_drop_items
    gain_exp
    SceneManager.return
    battle_end(0)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 逃走の処理 ★再定義
  #--------------------------------------------------------------------------
  def self.process_escape
    $game_message.add(sprintf(Vocab::EscapeStart, $game_party.name))
    success = @preemptive ? true : (rand < @escape_ratio)
    Sound.play_escape
    if success
      process_abort
      for member in $game_party.members do member.sv.start_action(member.sv.escape) if member.movable? end
    else
      @escape_ratio += 0.1
      $game_message.add('\.' + Vocab::EscapeFailure)
      $game_party.clear_actions
      for member in $game_party.members do member.sv.start_action(member.sv.escape_ng) if member.movable? end
    end
    wait_for_message
    return success
  end
  #--------------------------------------------------------------------------
  # ● 次のコマンド入力へ ★再定義
  #--------------------------------------------------------------------------
  def self.next_command
    begin
      if !actor || !actor.next_command
        $game_party.battle_members[@actor_index].sv.command_action = true
        @actor_index += 1
        if @actor_index >= $game_party.members.size
          for member in $game_party.battle_members.reverse
            break member.sv.start_action(member.sv.command_a) if member.inputable?
          end
          return false 
        end
      end
    end until actor.inputable?
    actor.sv.start_action(actor.sv.command_b) if actor != nil && actor.inputable?
    if pre_actor
      pre_actor.sv.start_action(pre_actor.sv.command_a) if pre_actor != nil && pre_actor.inputable?
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 前のコマンド入力へ ★再定義
  #--------------------------------------------------------------------------
  def self.prior_command
    begin
      if !actor || !actor.prior_command
        $game_party.battle_members[@actor_index].sv.command_action = false
        @actor_index -= 1
        if @actor_index < 0
          for member in $game_party.battle_members
            break member.sv.start_action(member.sv.command_a) if member.inputable?
          end
          return false 
        end
      end
    end until actor.inputable?
    actor.make_actions if actor.inputable?
    actor.sv.start_action(actor.sv.command_b) if actor.inputable?
    after_actor.sv.start_action(after_actor.sv.command_a) if after_actor != nil && after_actor.inputable?
    return true
  end
  #--------------------------------------------------------------------------
  # ● コマンド入力前のアクターを取得
  #--------------------------------------------------------------------------
  def self.pre_actor
    return if @actor_index == 0
    $game_party.members[@actor_index - 1]
  end
  #--------------------------------------------------------------------------
  # ● コマンド入力後のアクターを取得
  #--------------------------------------------------------------------------
  def self.after_actor
    $game_party.members[@actor_index + 1]
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動者を前に追加
  #--------------------------------------------------------------------------
  def self.unshift_action_battlers(battler)
    @action_battlers.unshift(battler)
  end
end  

#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　スプライトや行動に関するメソッドを追加したバトラーのクラスです。
#==============================================================================
class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :sv                     # サイドビューデータ
  attr_accessor :flash_flg              # 閃きフラグ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_game_battler_n03 initialize
  def initialize
    initialize_game_battler_n03
    @sv = SideView.new(self)
  end
  #--------------------------------------------------------------------------
  # ● 現在の戦闘行動を除去
  #--------------------------------------------------------------------------
  alias remove_current_action_game_battler_n03 remove_current_action
  def remove_current_action
    return @sv.derivation_skill_id = 0 if @sv.derivation_skill_id != 0
    remove_current_action_game_battler_n03
  end
  #--------------------------------------------------------------------------
  # ● ターン終了処理
  #--------------------------------------------------------------------------
  alias on_turn_end_game_battler_n03 on_turn_end
  def on_turn_end
    on_turn_end_game_battler_n03
    @sv.add_state = []
    @sv.result_damage = [@result.hp_damage, @result.mp_damage]
  end
  #--------------------------------------------------------------------------
  # ● パラメータ条件比較 data = [種別, 数値, 判別]
  #--------------------------------------------------------------------------
  def comparison_parameter(data)
    return true if data[0][0] == 0
    kind = data[0]
    num = data[1]
    select = data[2]
    case kind
    when  1 ; par = level
    when  2 ; par = mhp
    when  3 ; par = mmp
    when  4 ; par = hp
    when  5 ; par = mp
    when  6 ; par = tp
    when  7 ; par = atk
    when  8 ; par = self.def
    when  9 ; par = mat
    when 10 ; par = mdf
    when 11 ; par = agi
    when 12 ; par = luk
    end
    if num < 0
      case kind
      when  4 ; num = mhp * num / 100
      when  5 ; num = mmp * num / 100
      when  6 ; num = max_tp * num / 100
      end
      num = num.abs
    end  
    case select
    when  0 ; return par == num
    when  1 ; return par < num
    when  2 ; return par > num
    end
  end
  #--------------------------------------------------------------------------
  # ● 装備条件比較 data = [装備種別, タイプID]
  #--------------------------------------------------------------------------
  def comparison_equip(data)
    kind = data[0]
    items = weapons if kind == 0
    items = armors  if kind == 1
    for item in items
      for id in data[1]
        return true if id > 0 && item.is_a?(RPG::Weapon) && item == $data_weapons[id.abs]
        return true if id > 0 && item.is_a?(RPG::Armor) && item == $data_armors[id.abs]
        return true if id < 0 && item.is_a?(RPG::Weapon) && item.wtype_id == id.abs
        return true if id < 0 && item.is_a?(RPG::Armor) && item.stype_id == id.abs
      end
    end
    return false
  end
  
end  
#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :actor_id                    # ID
  #--------------------------------------------------------------------------
  # ● ID
  #--------------------------------------------------------------------------
  def id
    return @actor_id
  end
  #--------------------------------------------------------------------------
  # ● スプライトを使うか？ ★再定義
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  #--------------------------------------------------------------------------
  # ● ダメージ効果の実行 ★再定義
  #--------------------------------------------------------------------------
  def perform_damage_effect
    return if !N03::ACTOR_DAMAGE
    $game_troop.screen.start_shake(5, 5, 10)
    @sprite_effect_type = :blink
    Sound.play_actor_damage
  end
  
end

#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　敵キャラを扱うクラスです。
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :enemy_id                    # ID
  #--------------------------------------------------------------------------
  # ● ID
  #--------------------------------------------------------------------------
  def id
    return @enemy_id
  end
  #--------------------------------------------------------------------------
  # ● レベル
  #--------------------------------------------------------------------------
  def level
    return @sv.level
  end
  #--------------------------------------------------------------------------
  # ● ダメージ効果の実行 ★再定義
  #--------------------------------------------------------------------------
  def perform_damage_effect
    return if !N03::ENEMY_DAMAGE
    @sprite_effect_type = :blink
    Sound.play_enemy_damage
  end
  #--------------------------------------------------------------------------
  # ● 武器
  #--------------------------------------------------------------------------
  def weapons
    weapon1 = $data_weapons[@sv.enemy_weapon1_id]
    weapon2 = $data_weapons[@sv.enemy_weapon2_id]
    return [weapon1, weapon2]
  end
  #--------------------------------------------------------------------------
  # ● 防具
  #--------------------------------------------------------------------------
  def armors
    return [$data_armors[@sv.enemy_shield_id]]
  end
  #--------------------------------------------------------------------------
  # ● 二刀流の判定
  #--------------------------------------------------------------------------
  def dual_wield?
    return $data_weapons[@sv.enemy_weapon2_id] != nil
  end
  #--------------------------------------------------------------------------
  # ● バトラー画像変更
  #--------------------------------------------------------------------------
  def graphics_change(battler_name)
    @battler_name = battler_name
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃 アニメーション ID の取得
  #--------------------------------------------------------------------------
  def atk_animation_id1
    return weapons[0].animation_id if weapons[0]
    return weapons[1] ? 0 : 1
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃 アニメーション ID の取得（二刀流：武器２）
  #--------------------------------------------------------------------------
  def atk_animation_id2
    return weapons[1] ? weapons[1].animation_id : 0
  end
end

#==============================================================================
# ■ Sprite_Base
#------------------------------------------------------------------------------
# 　アニメーションの表示処理を追加したスプライトのクラスです。
#==============================================================================
class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # ● アニメーションの座標更新 (ホーミングあり)
  #--------------------------------------------------------------------------
  def update_animation_position_horming
    return if @action_end_cancel
    ani_ox_set if @horming
    camera_zoom = $sv_camera.zoom
    camera_zoom = 1 if @move_anime
    kind = 1
    kind = -1 if @ani_mirror && !@anime_no_mirror
    cell_data = @animation.frames[@animation.frame_max - (@ani_duration + @ani_rate - 1) / @ani_rate].cell_data
    for i in 0..15
      @ani_sprites[i].x = (@ani_ox + cell_data[i, 1] * kind - $sv_camera.x) * camera_zoom if @ani_sprites[i] != nil && cell_data[i, 1] != nil
      @ani_sprites[i].y = (@ani_oy + cell_data[i, 2] - $sv_camera.y) * camera_zoom if @ani_sprites[i] != nil && cell_data[i, 2] != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● アニメーション元の座標をセット
  #--------------------------------------------------------------------------
  def ani_ox_set
    if !SceneManager.scene_is?(Scene_Battle)
      @real_x = x
      @real_y = y
    end
    @ani_ox = @real_x - ox + width / 2
    @ani_oy = @real_y - oy + height / 2
    @ani_oy -= height / 2 if @animation.position == 0
    @ani_oy += height / 2 if @animation.position == 2
  end
  #--------------------------------------------------------------------------
  # ● アニメーションの更新
  #--------------------------------------------------------------------------
  alias update_animation_sprite_base_n03 update_animation
  def update_animation
    update_animation_position_horming if animation? && SceneManager.scene_is?(Scene_Battle) && @animation.position != 3
    update_animation_sprite_base_n03
  end
  #--------------------------------------------------------------------------
  # ● アニメーションの原点設定 ★再定義
  #--------------------------------------------------------------------------
  def set_animation_origin
    return ani_ox_set if @animation.position != 3
    if viewport == nil
      @ani_ox = Graphics.width / 2
      @ani_oy = Graphics.height / 2
    else
      @ani_ox = viewport.rect.width / 2
      @ani_oy = viewport.rect.height / 2
    end
  end
  #--------------------------------------------------------------------------
  # ● アニメーションスプライトの設定 ★再定義
  #--------------------------------------------------------------------------
  def animation_set_sprites(frame)
    camera_zoom = 1
    camera_zoom = $sv_camera.zoom if @anime_camera_zoom && @animation.position != 3 && SceneManager.scene_is?(Scene_Battle)
    camera_x = $sv_camera.x
    camera_y = $sv_camera.y
    camera_x = camera_y = 0 if @animation.position == 3 or !SceneManager.scene_is?(Scene_Battle)
    plus_z = 5
    plus_z = 1000 if @animation.position == 3
    plus_z = -17 if @plus_z != nil && @plus_z == false
    plus_z = -self.z + 10 if @plus_z != nil && @plus_z == false && @animation.position == 3
    cell_data = frame.cell_data
    @ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      if !pattern || pattern < 0
        sprite.visible = false
        next
      end
      sprite.bitmap = pattern < 100 ? @ani_bitmap1 : @ani_bitmap2
      sprite.visible = true
      sprite.src_rect.set(pattern % 5 * 192,
        pattern % 100 / 5 * 192, 192, 192)
      if @ani_mirror && !@anime_no_mirror
        sprite.x = (@ani_ox - cell_data[i, 1] - camera_x) * camera_zoom
        sprite.y = (@ani_oy + cell_data[i, 2] - camera_y) * camera_zoom
        sprite.angle = (360 - cell_data[i, 4])
        sprite.mirror = (cell_data[i, 5] == 0)
      else
        sprite.x = (@ani_ox + cell_data[i, 1] - camera_x) * camera_zoom
        sprite.y = (@ani_oy + cell_data[i, 2] - camera_y) * camera_zoom
        sprite.angle = cell_data[i, 4]
        sprite.mirror = (cell_data[i, 5] == 1)
      end
      sprite.z = self.z + plus_z + i
      sprite.ox = 96
      sprite.oy = 96
      sprite.zoom_x = cell_data[i, 3] * camera_zoom / 100.0
      sprite.zoom_y = cell_data[i, 3] * camera_zoom/ 100.0
      sprite.opacity = cell_data[i, 6] * self.opacity / 255.0
      sprite.blend_type = cell_data[i, 7]
    end
  end
  #--------------------------------------------------------------------------
  # ● 子スプライトフラグ
  #--------------------------------------------------------------------------
  def set(battler, horming, camera_zoom, no_mirror)
    @battler = battler
    @next = true
    self.bitmap = Bitmap.new(@battler.sv.cw, @battler.sv.ch)
    self.ox = bitmap.width / 2
    self.oy = bitmap.height
    @horming = horming
    @anime_camera_zoom = camera_zoom
    @anime_no_mirror = no_mirror
    @battler.sv.reset_anime_data
  end  
  #--------------------------------------------------------------------------
  # ● 子スプライト座標セット
  #--------------------------------------------------------------------------
  def set_position(z, zoom_x, zoom_y, real_x, real_y)
    self.z = z
    self.zoom_x = zoom_x
    self.zoom_y = zoom_y
    @real_x = real_x
    @real_y = real_y
  end
  #--------------------------------------------------------------------------
  # ● 他スプライトへのタイミング処理
  #--------------------------------------------------------------------------
  def other_process_timing(timing)
    se_flag = true
    se_flag = @se_flag if @se_flag != nil
    @battler.sv.timing.push([se_flag, timing.dup])
  end
  #--------------------------------------------------------------------------
  # ● 他バトラーへのタイミング処理
  #--------------------------------------------------------------------------
  def target_battler_process_timing(timing)
    for target in @timing_targets
      target.sv.timing.push([false, timing.dup])
    end  
  end
  #--------------------------------------------------------------------------
  # ● SE とフラッシュのタイミング処理
  #--------------------------------------------------------------------------
  alias animation_process_timing_sprite_base_n03 animation_process_timing
  def animation_process_timing(timing)
    target_battler_process_timing(timing) if @timing_targets && @timing_targets != []
    return other_process_timing(timing) if @next != nil
    animation_process_timing_sprite_base_n03(timing)
  end
  #--------------------------------------------------------------------------
  # ● アニメーションの解放
  #--------------------------------------------------------------------------
  alias dispose_animation_sprite_base_n03 dispose_animation
  def dispose_animation
    dispose_animation_sprite_base_n03
  end
end


#==============================================================================
# ■ Sprite_Battler
#------------------------------------------------------------------------------
# 　バトラー表示用のスプライトです。
#==============================================================================
class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数　
  #--------------------------------------------------------------------------
  attr_accessor   :removing             # パーティ離脱中
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_sprite_battler_n03 initialize
  def initialize(viewport, battler = nil)
    initialize_sprite_battler_n03(viewport, battler)
    @real_x = @real_y = 0
    update_bitmap if @battler != nil
  end
  #--------------------------------------------------------------------------
  # ● アニメーションの開始 ★再定義
  #--------------------------------------------------------------------------
  def start_animation(animation, mirror = false)
    return next_animation(animation, mirror) if animation?
    @animation = animation
    if @animation
      @horming = @battler.sv.anime_horming
      @anime_camera_zoom = @battler.sv.anime_camera_zoom
      @anime_no_mirror = @battler.sv.anime_no_mirror
      @timing_targets = @battler.sv.timing_targets
      @plus_z = @battler.sv.anime_plus_z
      @battler.sv.reset_anime_data
      @ani_mirror = mirror
      set_animation_rate
      @ani_duration = @animation.frame_max * @ani_rate + 1
      load_animation_bitmap
      make_animation_sprites
      set_animation_origin
    end
  end
  #--------------------------------------------------------------------------
  # ● 次のアニメを開始
  #--------------------------------------------------------------------------
  def next_animation(animation, mirror)
    @next_anime = [] if @next_anime == nil
    @next_anime.push(Sprite_Base.new(viewport))
    @next_anime[@next_anime.size - 1].set(battler, @battler.sv.anime_horming, @battler.sv.anime_camera_zoom, @battler.sv.anime_no_mirror)
    @next_anime[@next_anime.size - 1].set_position(self.z, self.zoom_x, self.zoom_y, @real_x, @real_y)
    @next_anime[@next_anime.size - 1].start_animation(animation, mirror)
  end
  #--------------------------------------------------------------------------
  # ● 影グラフィック作成
  #--------------------------------------------------------------------------
  def create_shadow
    reset_shadow
    return if @battler.sv.shadow == false
    @shadow = Sprite.new(viewport) if @shadow == nil
    @shadow.bitmap = Cache.character(@battler.sv.shadow)
    @shadow.ox = @shadow.bitmap.width / 2
    @shadow.oy = @shadow.bitmap.height / 2
  end
  #--------------------------------------------------------------------------
  # ● 影グラフィック初期化
  #--------------------------------------------------------------------------
  def reset_shadow
    return if @shadow == nil
    @shadow.dispose
    @shadow = nil
  end  
  #--------------------------------------------------------------------------
  # ● 転送元ビットマップの更新 ★再定義
  #--------------------------------------------------------------------------
  def update_bitmap
    update_bitmap_enemy if !@battler.actor?
    update_bitmap_actor if @battler.actor?
    update_src_rect if @battler != nil
    update_color if @battler != nil
  end
  #--------------------------------------------------------------------------
  # ● 転送元ビットマップ:エネミー
  #--------------------------------------------------------------------------
  def update_bitmap_enemy
    if @battler.battler_name != @battler_name or @battler.battler_hue != @battler_hue
      @battler_name = @battler.battler_name
      @battler_hue = @battler.battler_hue
      @battler_graphic_file_index = @battler.sv.graphic_file_index
      @graphic_mirror_flag = @battler.sv.graphic_mirror_flag
      self.bitmap = Cache.battler(@battler_name + @battler_graphic_file_index, @battler_hue)
      @battler.sv.setup(self.bitmap.width, self.bitmap.height, @battler_id != @battler.id)
      create_shadow
      init_visibility
      @battler_id = @battler.id
    end
  end  
  #--------------------------------------------------------------------------
  # ● 転送元ビットマップ:アクター
  #--------------------------------------------------------------------------
  def update_bitmap_actor
    if @battler.character_name != @battler_name or @battler.character_index != @battler_index
      @battler_name = @battler.character_name
      @battler_index = @battler.character_index
      @battler_graphic_file_index = @battler.sv.graphic_file_index
      @graphic_mirror_flag = @battler.sv.graphic_mirror_flag
      self.bitmap = Cache.character(@battler_name + @battler_graphic_file_index)
      @battler.sv.setup(self.bitmap.width, self.bitmap.height, @battler_id != @battler.id)
      create_shadow
      init_visibility
      @battler_id = @battler.id
    end
  end
  #--------------------------------------------------------------------------
  # ● 可視状態の初期化 ★再定義
  #--------------------------------------------------------------------------
  def init_visibility
    @battler_visible = @battler.alive?
    @battler_visible = true if @battler.sv.state(1) != "Collapse Enemy"
    @battler_visible = false if @battler.hidden?
    @battler.sv.opacity = 0 unless @battler_visible
    self.opacity = 0 unless @battler_visible
    self.opacity = 255 if @battler_visible
    @battler.sv.weapon_visible = @battler_visible
  end
  #--------------------------------------------------------------------------
  # ● 転送元矩形の更新
  #--------------------------------------------------------------------------
  def update_src_rect
    return if @battler.sv.collapse
    if @battler_graphic_file_index != @battler.sv.graphic_file_index
      @battler_graphic_file_index = @battler.sv.graphic_file_index
      self.bitmap = Cache.character(@battler_name + @battler_graphic_file_index) if @battler.actor?
      self.bitmap = Cache.battler(@battler_name + @battler_graphic_file_index, @battler_hue) if !@battler.actor?
      @battler.sv.set_graphics(self.bitmap.width, self.bitmap.height)
    end
    anime_off if @battler.sv.anime_off
    self.src_rect.set(@battler.sv.sx, @battler.sv.sy, @battler.sv.cw, @battler.sv.ch)
    self.opacity = @battler.sv.opacity if @battler_visible
    set_process_timing(@battler.sv.timing) if @battler && @battler.sv.timing != []
  end
  #--------------------------------------------------------------------------
  # ● 位置の更新 ★再定義
  #--------------------------------------------------------------------------
  def update_position
    @real_x = @battler.sv.x / 100
    @real_y = (@battler.sv.y - @battler.sv.h - @battler.sv.j - @battler.sv.c - @battler.sv.oy_adjust)/ 100
    self.x = @real_x - $sv_camera.x
    self.y = @real_y - $sv_camera.y
    self.z = @battler.sv.z - @battler.sv.c / 100
    if @battler.sv.h <= 0
      self.x += $sv_camera.sx / 100
      self.y += $sv_camera.sy / 100
    end  
    self.x *= $sv_camera.zoom
    self.y *= $sv_camera.zoom
  end
  #--------------------------------------------------------------------------
  # ● 原点の更新 ★再定義
  #--------------------------------------------------------------------------
  def update_origin
    return if !bitmap or @battler.sv.collapse
    self.ox = @battler.sv.ox
    self.oy = @battler.sv.oy
    self.angle = @battler.sv.angle
    self.zoom_x = @battler.sv.zoom_x * $sv_camera.zoom
    self.zoom_y = @battler.sv.zoom_y * $sv_camera.zoom
    self.mirror = @battler.sv.mirror if !@graphic_mirror_flag
    self.mirror = !@battler.sv.mirror if @graphic_mirror_flag
  end
  #--------------------------------------------------------------------------
  # ● 影グラフィックの更新
  #--------------------------------------------------------------------------
  def update_shadow
    @shadow.visible = @battler.sv.shadow_visible
    @shadow.opacity = @battler.sv.opacity if @battler.sv.opacity_data[3]
    @shadow.opacity = self.opacity if !@battler.sv.opacity_data[3]
    @shadow.x = @real_x - $sv_camera.x
    @shadow.y = (@battler.sv.y - @battler.sv.c)/ 100 - $sv_camera.y
    @shadow.z = @battler.sv.z - 10
    @shadow.zoom_x = $sv_camera.zoom
    @shadow.zoom_y = $sv_camera.zoom
    @shadow.x += $sv_camera.sx / 100
    @shadow.y += $sv_camera.sy / 100
    @shadow.x *= $sv_camera.zoom
    @shadow.y *= $sv_camera.zoom
    @shadow.color.set(@color_data[0], @color_data[1], @color_data[2], @color_data[3]) if @color_data != nil
  end
  #--------------------------------------------------------------------------
  # ● ふきだしの更新
  #--------------------------------------------------------------------------
  def update_balloon
    if @battler.sv.balloon_data == [] && @balloon
      @balloon_data = []
      @balloon.dispose
      return @balloon = nil
    elsif @battler.sv.balloon_data != [] && @battler.sv.balloon_data != @balloon_data
      @balloon_data = @battler.sv.balloon_data
      @balloon = Sprite.new(self.viewport)
      @balloon.bitmap = Cache.system("Balloon")
      @balloon.zoom_x = @balloon_data[3]
      @balloon.zoom_y = @balloon_data[3]
      @balloon.ox = 32 if @battler.sv.mirror
      @balloon.oy = 16
      @balloon_count = 0
    end
    return if !@balloon
    @balloon.opacity = self.opacity
    @balloon.x = self.x
    @balloon.y = self.y - @battler.sv.ch * $sv_camera.zoom
    @balloon.z = self.z + 20
    @balloon.src_rect.set(32 + @balloon_count / @balloon_data[2] * 32, @balloon_data[1] * 32, 32, 32) if @balloon_count % @balloon_data[2] == 0
    @balloon.color.set(@color_data[0], @color_data[1], @color_data[2], @color_data[3]) if @color_data != nil
    @balloon_count += 1
    @balloon_count = 0 if @balloon_count == @balloon_data[2] * 7
  end
  #--------------------------------------------------------------------------
  # ● 色調変更の更新
  #--------------------------------------------------------------------------
  def update_color
    color_set if @battler.sv.color_set != []
    return if @color_data == nil
    @color_data[4] -= 1
    if @color_data[4] == 0 && @color_data[5] != 0
      @color_data[4] = @color_data[5]
      @color_data[5] = 0
      @color_data[6] = [0,0,0,0]
    elsif @color_data[4] == 0
      @remain_color_data = @color_data
      @battler.sv.color = @color_data.dup
      return @color_data = nil
    end  
    for i in 0..3
      @color_data[i] = (@color_data[i] * (@color_data[4] - 1) + @color_data[6][i]) / @color_data[4]
    end  
    @battler.sv.color = @color_data.dup
    self.color.set(@color_data[0], @color_data[1], @color_data[2], @color_data[3])
  end
  #--------------------------------------------------------------------------
  # ● 残像の更新
  #--------------------------------------------------------------------------
  def update_mirage
    if @battler.sv.mirage == [] && @mirages
      @mirage_data = []
      for mirage in @mirages do mirage.dispose end
      return @mirages = nil
    elsif @battler.sv.mirage != [] && @battler.sv.mirage != @mirage_data
      @mirage_data = @battler.sv.mirage
      @mirages = []
      for i in 0...@mirage_data[1] do @mirages[i] = Sprite.new(self.viewport) end
      @mirage_count = 0
    end
    return if !@mirages
    @mirage_count += 1
    @mirage_count = 0 if @mirage_count == @mirage_data[2] * @mirages.size
    for i in 0...@mirages.size
      mirage_body(@mirages[i], @mirage_data[4]) if @mirage_count == 1 + i * @mirage_data[2]
    end
  end
  #--------------------------------------------------------------------------
  # ● 残像本体
  #--------------------------------------------------------------------------
  def mirage_body(body, opacity)
    body.bitmap = self.bitmap.dup
    body.x = self.x
    body.y = self.y
    body.ox = self.ox
    body.oy = self.oy
    body.z = self.z - 20
    body.mirror = self.mirror
    body.angle = self.angle
    body.opacity = opacity * self.opacity / 255
    body.zoom_x = self.zoom_x
    body.zoom_y = self.zoom_y   
    body.src_rect.set(@battler.sv.sx, @battler.sv.sy, @battler.sv.cw, @battler.sv.ch)
    body.color.set(@color_data[0], @color_data[1], @color_data[2], @color_data[3]) if @color_data != nil
  end   
  #--------------------------------------------------------------------------
  # ● 次のアニメを更新
  #--------------------------------------------------------------------------
  def update_next_anime
    return if !@next_anime
    for anime in @next_anime
      anime.update
      anime.set_position(self.z, self.zoom_x, self.zoom_y, @real_x, @real_y) if @horming
      anime.dispose if !anime.animation?
      @next_anime.delete(anime) if !anime.animation?
    end  
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias update_sprite_battler_n03 update
  def update
    @battler.sv.update if @battler
    update_sprite_battler_n03
    update_next_anime
    update_shadow  if @battler && @shadow
    update_mirage  if @battler
    update_balloon if @battler
    update_remove if @battler && @removing && @battler.sv.change_up
  end
  #--------------------------------------------------------------------------
  # ● 戦闘アニメ消去
  #--------------------------------------------------------------------------
  def anime_off
    @battler.sv.anime_off = false
    dispose_animation
    for anime in @next_anime do anime.dispose_animation end if @next_anime
  end
  #--------------------------------------------------------------------------
  # ● バトラー入れ替え
  #--------------------------------------------------------------------------
  def remove
    @battler.sv.start_action(@battler.sv.remove_action)
    $sv_camera.wait = 40
    @battler.sv.add_action("eval('set_change')")
    @removing = true
  end
  #--------------------------------------------------------------------------
  # ● バトラー入れ替えの更新
  #--------------------------------------------------------------------------
  def update_remove
    @battler.sv.change_up = false
    @removing = false
    @battler = nil
  end  
  #--------------------------------------------------------------------------
  # ● バトラー加入
  #--------------------------------------------------------------------------
  def join(join_battler)
    $sv_camera.wait = 30
    @battler = join_battler
    @battler_name = @battler.character_name
    @battler_index = @battler.character_index
    @battler_graphic_file_index = @battler.sv.graphic_file_index
    self.bitmap = Cache.character(@battler_name)
    @battler.sv.setup(self.bitmap.width, self.bitmap.height, true)
    create_shadow
    init_visibility
  end
  #--------------------------------------------------------------------------
  # ● 通常の設定に戻す ★再定義
  #--------------------------------------------------------------------------
  def revert_to_normal
    self.blend_type = 0
    self.opacity = 255
  end
  #--------------------------------------------------------------------------
  # ● 崩壊エフェクトの更新
  #--------------------------------------------------------------------------
  alias update_collapse_sprite_battler_n03 update_collapse
  def update_collapse
    return if @battler.sv.state(1) != "Collapse Enemy"
    update_collapse_sprite_battler_n03
    @battler.sv.weapon_visible = false
  end
  #--------------------------------------------------------------------------
  # ● ボス崩壊エフェクトの更新 ★再定義
  #--------------------------------------------------------------------------
  def update_boss_collapse
    @effect_duration = @battler.sv.ch if @effect_duration >= @battler.sv.ch
    alpha = @effect_duration * 120 / @battler.sv.ch
    self.ox = @battler.sv.cw / 2 + @effect_duration % 2 * 4 - 2
    self.blend_type = 1
    self.color.set(255, 255, 255, 255 - alpha)
    self.opacity = alpha
    self.src_rect.y -= 1
    Sound.play_boss_collapse2 if @effect_duration % 20 == 19
  end
  #--------------------------------------------------------------------------
  # ● 別スプライトからのタイミング処理
  #--------------------------------------------------------------------------
  def set_process_timing(timing_data)
    for data in timing_data
      set_timing(data[0],data[1])
    end
    @battler.sv.timing = []
  end
  #--------------------------------------------------------------------------
  # ● タイミング処理
  #--------------------------------------------------------------------------
  def set_timing(se_flag, data)
    @ani_rate = 4
    data.se.play if se_flag
    case data.flash_scope
    when 1 ;self.flash(data.flash_color, data.flash_duration * @ani_rate)
    when 2 ;viewport.flash(data.flash_color, data.flash_duration * @ani_rate) if viewport
    when 3 ;self.flash(nil, data.flash_duration * @ani_rate)
    end
  end
  #--------------------------------------------------------------------------
  # ● 色調変更
  #--------------------------------------------------------------------------
  def color_set
    set = @battler.sv.color_set
    @battler.sv.color_set= []
    set[4] = 1 if set[4] == 0
    @remain_color_data = [0,0,0,0] if @remain_color_data == nil
    @color_data = @remain_color_data
    @color_data[4] = set[4]
    @color_data[5] = set[5]
    @color_data[6] = set
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias dispose_sprite_battler_n03 dispose
  def dispose
    dispose_sprite_battler_n03
    @shadow.dispose if @shadow != nil
    @balloon.dispose if @balloon != nil
    for mirage in @mirages do mirage.dispose end if @mirages != nil
    for anime in @next_anime do anime.dispose end if @next_anime
  end
end


#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
# 　バトル画面のスプライトをまとめたクラスです。
#==============================================================================
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● 戦闘背景（床）スプライトの作成 ★再定義
  #--------------------------------------------------------------------------
  def create_battleback1
    @back1_sprite = Sprite_Battle_Back.new(@viewport1, 1, battleback1_name)
    @back1_sprite.set_graphics(battleback1_bitmap) if battleback1_name != nil
    @back1_sprite.z = 0
  end
  #--------------------------------------------------------------------------
  # ● 戦闘背景（壁）スプライトの作成 ★再定義
  #--------------------------------------------------------------------------
  def create_battleback2
    @back2_sprite = Sprite_Battle_Back.new(@viewport1, 2, battleback2_name)
    @back2_sprite.set_graphics(battleback2_bitmap) if battleback2_name != nil
    @back2_sprite.z = 1
  end
  #--------------------------------------------------------------------------
  # ● アクタースプライトの作成 ★再定義
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = []
    for i in 0...$game_party.max_battle_members
      @actor_sprites[i] = Sprite_Battler.new(@viewport1, $game_party.members[i])
    end
    @effect_sprites = Spriteset_Sideview.new(@viewport1)
  end
  #--------------------------------------------------------------------------
  # ● アクタースプライトの更新 ★再定義
  #--------------------------------------------------------------------------
  def update_actors
    @actor_sprites.each_with_index do |sprite, i|
      sprite_join($game_party.members[i], sprite) if sprite.battler == nil && sprite.battler != $game_party.members[i]
      sprite.remove if sprite.battler != nil && !sprite.removing && sprite.battler != $game_party.members[i]
      sprite.update
    end
    @effect_sprites.update
    update_program
  end
  #--------------------------------------------------------------------------
  # ● メンバーを加える
  #--------------------------------------------------------------------------
  def sprite_join(member, sprite)
    for sp in @actor_sprites
      sp.update_remove if member == sp.battler && !sp.battler.sv.change_up
    end
    sprite.join(member)
  end 
  #--------------------------------------------------------------------------
  # ● バトルプログラムの更新
  #--------------------------------------------------------------------------
  def update_program
    return if $sv_camera.program_scroll == []
    for data in  $sv_camera.program_scroll
      @back1_sprite.start_back_data(data) if data[2] == 1
      @back2_sprite.start_back_data(data) if data[2] == 2
    end
    $sv_camera.program_scroll = []
  end
  #--------------------------------------------------------------------------
  # ● ヒット時の戦闘アニメ実行
  #--------------------------------------------------------------------------
  def set_hit_animation(battler, weapon_index, hit_targets, miss)
    @effect_sprites.set_hit_animation(battler, weapon_index, hit_targets, miss)
  end
  #--------------------------------------------------------------------------
  # ● ダメージPOP
  #--------------------------------------------------------------------------
  def set_damage_pop(target)
    @effect_sprites.set_damage_pop(target)
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias dispose_spriteset_battle_n03 dispose
  def dispose
    dispose_spriteset_battle_n03
    @effect_sprites.dispose
  end
  
  
  
end


#==============================================================================
# ■ Window_BattleLog
#------------------------------------------------------------------------------
# 　戦闘の進行を実況表示するウィンドウです。
#==============================================================================
class Window_BattleLog < Window_Selectable
  #--------------------------------------------------------------------------
  # ● ウェイト ★再定義
  #--------------------------------------------------------------------------
  def wait
  end
  #--------------------------------------------------------------------------
  # ● ウェイトとクリア ★再定義
  #--------------------------------------------------------------------------
  def wait_and_clear
    $sv_camera.wait = 10
  end
  #--------------------------------------------------------------------------
  # ● 行動結果の表示 ★再定義
  #--------------------------------------------------------------------------
  def display_action_results(target, item)
    if target.result.used
      last_line_number = line_number
      display_critical(target, item)
      display_damage(target, item)
      display_affected_status(target, item)
      display_failure(target, item)
    end
    off if !N03::BATTLE_LOG
  end
  #--------------------------------------------------------------------------
  # ● ウインドウ非表示
  #--------------------------------------------------------------------------
  def off
    @back_sprite.visible = self.visible = false
  end
end
#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● スイッチの操作
  #--------------------------------------------------------------------------
  alias command_121_game_interpreter_n03 command_121
  def command_121
    command_121_game_interpreter_n03
    $sv_camera.program_check
  end
end