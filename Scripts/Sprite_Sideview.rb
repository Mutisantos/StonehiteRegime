#==============================================================================
# ■ Sprite_Weapon
#------------------------------------------------------------------------------
# 　ウエポン表示用のスプライトです。
#==============================================================================
class Sprite_Weapon < Sprite_Base
    #--------------------------------------------------------------------------
    # ● 公開インスタンス変数　
    #--------------------------------------------------------------------------
    attr_reader   :index                       # ウエポン画像配列のインデックス
    attr_reader   :battler                     # 画像が参照しているバトラー
    attr_reader   :move_time                   # 画像が目標に到達するまでの時間
    attr_reader   :through                     # 貫通フラグ
    attr_reader   :action_end                  # 武器アクション終了フラグ
    attr_reader   :action_end_cancel                  # 武器アクション終了フラグ
    attr_reader   :hit_position                # 画像が目標に到達した時の座標
    attr_accessor :hit_anime_id                # 画像が目標に到達した時のアニメID
    #--------------------------------------------------------------------------
    # ● オブジェクト初期化 
    #--------------------------------------------------------------------------
    def initialize(viewport, index, battler)
      super(viewport)
      @index = index
      @battler = battler
      @position_x = @position_y = 0
      @o = 0
      @real_x = @real_y = 0
      @mirror = @battler.sv.mirror
      reset
      set_action
    end
    #--------------------------------------------------------------------------
    # ● 初期化
    #--------------------------------------------------------------------------
    def reset
      @z_plus = 0
      @weapon_data = []
      @move_data = []
      @move_x = 0
      @move_y = 0
      @orbit = []
      @through = false
      @distanse_move = false
      @weapon_width = 0
      @weapon_height = 0
      @anime_time = 0
      @anime_position = 1
      @move_time = 0
      @hit_anime_id = 0
      @move_anime = true
      @action_end = false
      @action_end_cancel = false
      reset_position
    end  
    #--------------------------------------------------------------------------
    # ● アクションをセット
    #--------------------------------------------------------------------------
    def set_action
      return if @battler.sv.effect_data == []
      weapon_anime if @battler.sv.effect_data[0][0] == "wp"
      move_anime if @battler.sv.effect_data[0][0] == "m_a"
      @battler.sv.effect_data.shift
    end
    #--------------------------------------------------------------------------
    # ● 武器アニメ実行
    #--------------------------------------------------------------------------
    def weapon_anime
      @weapon_data = @battler.sv.effect_data[0].dup
      set_graphics
      set_ox
      set_weapon_move
    end
    #--------------------------------------------------------------------------
    # ● アニメ移動実行
    #--------------------------------------------------------------------------
    def move_anime
      @move_data = @battler.sv.effect_data[0].dup
      # ターゲットを取得
      @target_battler = [@battler.sv.m_a_targets.shift]
      @target_battler = N03.get_targets(@move_data[3], @battler) if @move_data[3] < 0
      set_move
      return if @move_data[16] == ""
      weapon_data = N03::ACTION[@move_data[16]]
      return if weapon_data == nil
      @weapon_data = weapon_data.dup
      set_graphics
      set_ox
      set_weapon_move
    end
    #--------------------------------------------------------------------------
    # ● 武器画像を取得
    #--------------------------------------------------------------------------  
    def set_graphics
      if @weapon_data[13] != ""
        self.bitmap = Cache.character(@weapon_data[13]).dup
        @weapon_width = self.bitmap.width
        @weapon_height = self.bitmap.height
        return
      end
      # 武器を取得
      weapon = @battler.weapons[0]
      # Is using instead Shield or Secondary Weapon
      if @weapon_data[10]
        weapon = nil
        for armor in @battler.armors do break weapon = armor if armor.is_a?(RPG::Armor) && armor.etype_id == 1 end
        weapon = @battler.weapons[1] if !weapon
      end
      
      #Is an Item
      if(@battler.actions[0] != nil)
        if (@battler.actions[0].item.is_a?(RPG::Item))
          weapon = @battler.actions[0].item
        end
      end
      # 武器がなければ処理をキャンセル
      return if weapon == nil
      # インデックスを取得
      file_index = @weapon_data[12]
      # アイコンを利用するなら
      if @weapon_data[1] == 0
        icon_index = weapon.icon_index
        self.bitmap = Cache.system("Iconset" + file_index).dup
        self.src_rect.set(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
        @weapon_width = @weapon_height = 24
      # 独自画像指定 
      else
        file_name = @battler.sv.weapon_graphic(weapon.id, weapon.wtype_id) if weapon.is_a?(RPG::Weapon)
        file_name = @battler.sv.shield_graphic(weapon.id, weapon.atype_id) if weapon.is_a?(RPG::Armor)
        p(file_name)
        self.bitmap = Cache.character(file_name + file_index).dup
        @weapon_width = self.bitmap.width
        @weapon_height = self.bitmap.height
        return if @weapon_data[1] == 1
        # 2003仕様の武器アニメ
        @weapon_width /= @battler.sv.max_pattern[0]
      end
    end
    #--------------------------------------------------------------------------
    # ● 画像の原点を取得
    #--------------------------------------------------------------------------  
    def set_ox
      # 反転時は設定を逆に
      if @mirror
        case @weapon_data[6]
        when 1 ; @weapon_data[6] = 2 # 左上→右上に
        when 2 ; @weapon_data[6] = 1 # 右上→左上に
        when 3 ; @weapon_data[6] = 4 # 左下→右下に
        when 4 ; @weapon_data[6] = 3 # 右下→左下に
        end
      end
      # 原点を設定
      case @weapon_data[6]
      when 0 # 中心
        self.ox = @weapon_width / 2
        self.oy = @weapon_height / 2
      when 1 # 左上
        self.ox = 0
        self.oy = 0
      when 2 # 右上
        self.ox = @weapon_width
        self.oy = 0
      when 3 # 左下
        self.ox = 0
        self.oy = @weapon_height
      when 4 # 右下
        self.ox = @weapon_width
        self.oy = @weapon_height
      when 5 # バトラーと同じ
        self.ox = @weapon_width / 2
        self.oy = @weapon_height
      end
    end  
    #--------------------------------------------------------------------------
    # ● バトラーの座標を取得
    #--------------------------------------------------------------------------  
    def set_battler_position
      @position_x = @battler.sv.x + @weapon_data[3][0] * N03.mirror_num(@mirror) * 100
      @position_y = (@battler.sv.y - @battler.sv.h - @battler.sv.j - @battler.sv.c - @battler.sv.oy_adjust) + @weapon_data[3][1] * 100
      reset_position
    end
    #--------------------------------------------------------------------------
    # ● 座標を初期化
    #--------------------------------------------------------------------------  
    def reset_position
      @real_x = @position_x / 100
      @real_y = @position_y / 100
      @real_zoom_x = 1
      @real_zoom_y = 1
    end
    #--------------------------------------------------------------------------
    # ● 戦闘アニメを表示
    #--------------------------------------------------------------------------  
    def set_animation(anime_id)
      return if $data_animations[anime_id] == nil
      @anime_position = $data_animations[anime_id].position
      @horming = true
      @horming = false if @anime_position == 3
      @anime_camera_zoom = true
      @anime_no_mirror = false
      start_animation($data_animations[anime_id], @mirror)
      timings = $data_animations[anime_id].timings
    end
    #--------------------------------------------------------------------------
    # ● ヒット時の戦闘アニメ実行
    #--------------------------------------------------------------------------  
    def set_hit_animation(position_data, hit_anime_id, target)
      return if $data_animations[hit_anime_id] == nil
      @real_x = position_data[0]
      @real_y = position_data[1]
      @position_x = position_data[0] * 100
      @position_y = position_data[1] * 100
      self.z = position_data[2]
      @z_plus = 1000
      @action_end = false
      @horming = true
      set_animation(hit_anime_id)
      @anime_time = $data_animations[hit_anime_id].frame_max * 4
      @timing_targets = [target]
      @move_time = @hit_anime_id = 0
      @weapon_data = []
    end
    #--------------------------------------------------------------------------
    # ● タイミングバトラー追加
    #--------------------------------------------------------------------------  
    def timing_battler_set(target)
      @timing_targets.push(target)
    end
    #--------------------------------------------------------------------------
    # ● 武器の動きを取得
    #--------------------------------------------------------------------------  
    def set_weapon_move
      # 開始位置を取得
      set_battler_position if @move_time == 0
      @z_plus = 50 if @z_plus == 0 && @weapon_data[9]
      self.z = @battler.sv.z + @z_plus
      # 反転処理
      @mirror = !@mirror if @weapon_data[7]
      self.mirror = @mirror
      # 更新パターンをセット
      set_pattern
      @max_pattern = 2 if @max_pattern == 1
      # 動きを計算
      @weapon_move_data = []
      @weapon_angle_data = []
      @weapon_zoom_data = []
      num = N03.mirror_num(@mirror)
      for i in 0...@max_pattern
        move_data_x = @weapon_data[2][0] * num * 100 * i / (@max_pattern - 1)
        move_data_y = @weapon_data[2][1] * 100 * i / (@max_pattern - 1)
        move_angle = @weapon_data[4] * num + (@weapon_data[5] * num - @weapon_data[4] * num) * i / (@max_pattern - 1)
        move_zoom_x = 1 + (@weapon_data[8][0] - 1) * i / (@max_pattern - 1)
        move_zoom_y = 1 + (@weapon_data[8][1] - 1) * i / (@max_pattern - 1)
        @weapon_move_data.push([move_data_x, move_data_y])
        @weapon_angle_data.push(move_angle)
        @weapon_zoom_data.push([move_zoom_x, move_zoom_y])
      end
    end  
    #--------------------------------------------------------------------------
    # ● 更新パターン
    #--------------------------------------------------------------------------
    def set_pattern
      if @weapon_data[11] == -1
        return @max_pattern = @battler.sv.max_pattern[0] if @battler.sv.pattern_type != 0
        @count = @battler.sv.pattern_time
        @max_count = @battler.sv.pattern_time
        @max_pattern = @battler.sv.max_pattern[0]
        @repeat = false
      else
        @count = @weapon_data[11][0]
        @max_count = @weapon_data[11][0]
        @max_pattern = @weapon_data[11][1]
        @repeat = @weapon_data[11][2]
      end
      @pattern = 0
    end
    #--------------------------------------------------------------------------
    # ● 移動実行
    #--------------------------------------------------------------------------
    def set_move
      # 戦闘アニメを取得
      set_animation(@move_data[1][0]) if $data_animations[@move_data[1][0]] != nil && $data_animations[@move_data[1][0]].position != 3
      @anime_camera_zoom = @move_data[13]
      @loop = @move_data[14]
      @loop = false if @move_data[1][0] == 0
      @anime_no_mirror = @move_data[15]
      @se_flag = @move_data[17]
      # 開始位置を取得
      start_position
      @z_plus = 1000 if @move_data[9]
      # ターゲットバトラー画像にこのアニメのSEとタイミング設定を反映させる
      @timing_targets = @target_battler
      # 座標計算
      @move_x = @move_data[5][0] * 100 * N03.mirror_num(@mirror)
      @move_y = @move_data[5][1] * 100
      # 時間計算か速度計算か
      @distanse_move = true if @move_data[6] > 0
      @move_time = @move_data[6].abs
      # 時間0の場合、アニメが設定されていればアニメ表示時間に合わせる
      if @move_time == 0
        @move_time = $data_animations[@move_data[1][0]].frame_max * 4 if $data_animations[@move_data[1][0]]
        @move_time = 1 if !$data_animations[@move_data[1][0]]
        @distanse_move = false
      end
      # 貫通タイプの場合
      @through = true if @move_data[7] == 1
      @auto_through_flag = false
      @auto_through_flag = true if @move_data[7] == 0
      # ターゲット座標計算
      if @target_battler == nil
        @target_x = @move_x * 100
        @target_x = (Graphics.width - @move_x) * 100 if @mirror
        @target_y = @move_y * 100
      else
        move_data_set
      end
      # ターゲットに到達するまでの時間を計算
      @move_time = distanse_calculation(@move_time, @target_x, @target_y)
      # 円軌道計算
      orbit
      # バトラーのウエイト設定
      @battler.sv.wait = @move_time - 1 if @move_data[10][0]
      @move_horming = @move_data[12]
    end  
    #--------------------------------------------------------------------------
    # ● 速度を時間に変換
    #--------------------------------------------------------------------------
    def distanse_calculation(time, target_x, target_y)
      return time if !@distanse_move
      distanse_x = @position_x - @target_x
      distanse_x = @target_x - @position_x if @target_x > @position_x
      distanse_y = @position_y - @target_y
      distanse_y = @target_y - @position_y if @target_y > @position_y
      distanse = [distanse_x, distanse_y].max
      return distanse / (time * 100) + 1
    end 
    #--------------------------------------------------------------------------
    # ● 移動目標の更新
    #--------------------------------------------------------------------------
    def move_data_set
      return if @target_battler == nil
      position = N03.get_targets_position(@target_battler, true, @anime_position)
      @target_x = position[0] + @move_x
      @target_y = position[1] - position[2] + @move_y
    end 
    #--------------------------------------------------------------------------
    # ● 開始位置を計算
    #--------------------------------------------------------------------------
    def start_position
      starter = [@battler.sv.m_a_starter.shift]
      starter = N03.get_targets(@move_data[2], @battler) if @move_data[2] < 0
      position = [0, 0]
      position = N03.get_targets_position(starter, true, @anime_position) if starter != nil
      @position_x = position[0] + @move_data[4][0] * 100
      @position_y = position[1] + position[2] + @move_data[4][1] * 100
      @position_z = @position_y
    end  
    #--------------------------------------------------------------------------
    # ● 円軌道計算
    #--------------------------------------------------------------------------
    def orbit
      orbit_data = @move_data[8].dup
      orbit_data[0] *= 100
      orbit_data[1] *= 100
      orbit_d = []
      for i in 0...@move_time / 2
        @orbit[i] = orbit_data[0]
        orbit_data[0] /= 2
        orbit_d[i] = orbit_data[1]
        orbit_data[1] /= 2
      end
      @orbit = @orbit + orbit_d.reverse!
      @orbit.reverse!
    end  
    #--------------------------------------------------------------------------
    # ● フレーム更新
    #--------------------------------------------------------------------------
    def update
      update_hit_anime if @anime_time != 0
      update_move if @move_time != 0
      update_weapon_move if @weapon_data != []
      update_position
      update_color
      self.visible = @battler.sv.weapon_visible
      super
    end
    #--------------------------------------------------------------------------
    # ● ヒット時の戦闘アニメ
    #--------------------------------------------------------------------------
    def update_hit_anime
      @anime_time -= 1
      @action_end = true if @anime_time == 0
    end
    #--------------------------------------------------------------------------
    # ● 移動の更新
    #--------------------------------------------------------------------------
    def update_move
      move_data_set if @move_horming && !@hit_position
      through_set(@move_time, @target_x, @target_y) if @move_time == 1 && !@hit_position
      @o += @orbit[@move_time - 1] if @orbit[@move_time - 1] != nil
      @position_x = (@position_x * (@move_time - 1) + @target_x) / @move_time
      @position_y = (@position_y * (@move_time - 1) + @target_y) / @move_time + @o
      reset_position
      set_animation(@move_data[1][0]) if @loop && !animation?
      @move_time -= 1
      return if @move_time != 0
      @action_end = true if !@action_end_cancel
    end
    #--------------------------------------------------------------------------
    # ● 武器の動きを更新
    #--------------------------------------------------------------------------
    def update_weapon_move
      pattern = update_pattern
      set_battler_position if @move_time == 0 && !@action_end_cancel
      @real_x = @position_x / 100 + @weapon_move_data[pattern][0] / 100
      @real_y = @position_y / 100 + @weapon_move_data[pattern][1] / 100
      @real_zoom_x = @weapon_zoom_data[pattern][0]
      @real_zoom_y = @weapon_zoom_data[pattern][1]
      self.angle = @weapon_angle_data[pattern]
      self.src_rect.set(@weapon_width * pattern, 0, @weapon_width, @weapon_height) if @weapon_data[1] == 2
    end
    #--------------------------------------------------------------------------
    # ● パターンを更新
    #--------------------------------------------------------------------------
    def update_pattern
      return @battler.sv.pattern_w if @count == nil
      @count -= 1
      return @pattern if @count != 0
      @count = @max_count
      @pattern += 1
      if !@repeat && @pattern == @max_pattern
        @pattern = @max_pattern - 1
      elsif @pattern == @max_pattern
        @pattern = 0
      end
      return @pattern
    end
    #--------------------------------------------------------------------------
    # ● 座標を更新
    #--------------------------------------------------------------------------
    def update_position
      self.x = (@real_x - $sv_camera.x) * $sv_camera.convert / 1000
      self.y = (@real_y - $sv_camera.y) * $sv_camera.convert / 1000
      self.x += $sv_camera.sx / 100 unless @battler.sv.h != 0 && @weapon_data != []
      self.y += $sv_camera.sy / 100 unless @battler.sv.h != 0 && @weapon_data != []
      self.z = @battler.sv.z + @z_plus - 10
      self.zoom_x = @real_zoom_x * $sv_camera.zoom
      self.zoom_y = @real_zoom_y * $sv_camera.zoom
      self.opacity = @battler.sv.opacity if @battler.sv.opacity_data[4]
    end
    #--------------------------------------------------------------------------
    # ● 貫通の処理
    #--------------------------------------------------------------------------
    def through_set(time, target_x, target_y)
      @hit_anime_id = N03.get_attack_anime_id(@move_data[1][1], @battler)
      @battler.sv.wait = N03.get_anime_time(@hit_anime_id) if @move_data[10][1]
      moving_x = (target_x / 100 - @position_x / 100) / time
      moving_y = (target_y / 100 - @position_y / 100) / time
      goal_x = $sv_camera.max_left - 100 if moving_x < 0
      goal_x = Graphics.width + $sv_camera.max_right + 100 if moving_x > 0
      goal_y = $sv_camera.max_top - 100 if moving_y < 0
      goal_y = Graphics.height + $sv_camera.max_bottom + 100 if moving_y > 0
      if goal_x == nil &&  goal_y == nil
        time = 0 
        reset_position
      else
        time = move_calculation(moving_x, moving_y, goal_x, goal_y)
      end
      target_x = @position_x + moving_x * time * 100
      target_y = @position_y + moving_y * time * 100
      @pre_data = [time, target_x, target_y]
      @battler.sv.m_a_data.push([@move_data[11], @target_battler, @index, @auto_through_flag, []])
      @action_end_cancel = true
      @hit_position = [@real_x, @real_y, self.z]
    end  
    #--------------------------------------------------------------------------
    # ● 到達時間試算
    #--------------------------------------------------------------------------
    def move_calculation(moving_x, moving_y, goal_x, goal_y)
      move_x = @position_x / 100
      move_y = @position_y / 100
      time = 0
      loop do
        move_x += moving_x
        move_y += moving_y
        time += 1
        return time if moving_x < 0 && move_x < goal_x
        return time if moving_x > 0 && move_x > goal_x
        return time if moving_y < 0 && move_y < goal_y
        return time if moving_y > 0 && move_y > goal_y
      end
    end   
    #--------------------------------------------------------------------------
    # ● ミス時に消える処理から貫通処理に変換
    #--------------------------------------------------------------------------
    def through_change
      @action_end_cancel = false
      @through = true
      @move_time = @pre_data[0]
      @target_x = @pre_data[1]
      @target_y = @pre_data[2]
      @pre_data = nil
    end  
    #--------------------------------------------------------------------------
    # ● SE とフラッシュのタイミング処理
    #--------------------------------------------------------------------------
    def animation_process_timing(timing)
      return if !@timing_targets
      se_flag = true
      se_flag = @se_flag if @se_flag != nil
      for target in @timing_targets
        target.sv.timing.push([se_flag, timing.dup])
        se_flag = false if @animation.position == 3
      end  
    end
    #--------------------------------------------------------------------------
    # ● 色調の更新
    #--------------------------------------------------------------------------
    def update_color
      return if @battler.sv.color == []
      self.color.set(@battler.sv.color[0], @battler.sv.color[1], @battler.sv.color[2], @battler.sv.color[3])
    end
    #--------------------------------------------------------------------------
    # ● 解放
    #--------------------------------------------------------------------------
    def dispose
      super
      self.bitmap.dispose if self.bitmap != nil
    end
  end 
  
  #==============================================================================
  # ■ Sprite_Battle_Picture
  #------------------------------------------------------------------------------
  # 　ピクチャ表示用のスプライトです。
  #==============================================================================
  class Sprite_Battle_Picture < Sprite
    #--------------------------------------------------------------------------
    # ● 公開インスタンス変数　
    #--------------------------------------------------------------------------
    attr_accessor   :action_end           # 終了フラグ
    #--------------------------------------------------------------------------
    # ● オブジェクト初期化
    #--------------------------------------------------------------------------
    def initialize(viewport = nil)
      super(viewport)
      @action_end = false
      self.ox = 0
    end
    #--------------------------------------------------------------------------
    # ● セット
    #--------------------------------------------------------------------------
    def set(battler)
      @battler = battler
      @data = @battler.sv.effect_data.shift
      @time = @data[4]
      @mirror = $sv_camera.mirror
      @mirror = false if !@data[8]
      self.opacity = @data[6][0]
      @s_x = @data[2][0] if @data[2] != []
      @s_x = Graphics.width - @data[2][0]  if @data[2] != [] && @mirror
      @s_y = @data[2][1] if @data[2] != []
      @e_x = @data[3][0] if @data[3] != []
      @e_x = Graphics.width - @data[3][0] if @data[3] != [] && @mirror
      @e_y = @data[3][1] if @data[3] != []
      @s_x = self.x if @data[2] == []
      @s_y = self.y if @data[2] == []
      @e_x = self.x if @data[3] == []
      @e_y = self.y if @data[3] == []
      self.x = @s_x
      self.y = @s_y
      return @action_end = true if @time == 0
      @move_x = (@e_x * 1.0 - @s_x) / @time
      @move_y = (@e_y * 1.0 - @s_y) / @time
      self.z = @data[5]
      return set_plane(battler) if @data[7] != []
      self.bitmap = Cache.picture(@data[9]) if !bitmap or @data[9] != ""
      return @action_end = true if !bitmap
      self.mirror = @mirror
      self.ox = self.bitmap.width if @mirror
    end
    #--------------------------------------------------------------------------
    # ● プレーン移行
    #--------------------------------------------------------------------------
    def set_plane(battler)
      @viewport = Viewport.new(@data[2][0],@data[2][1],@data[7][0],@data[7][1]) if !@viewport
      viewport = @viewport
      @plane = Plane.new(viewport) if !@plane
      @plane.bitmap = Cache.picture(@data[9]) if !@plane.bitmap or @data[9] != ""
      return @action_end = true if !@plane.bitmap
      @plane.ox = @data[7][0]
      @plane.oy = @data[7][1]
      @plane.opacity = @data[6][0]
      @move_x = @remain_move[0] if @data[2] == @data[3]
      @move_y = @remain_move[1] if @data[2] == @data[3]
      @remain_move = [@move_x, @move_y]
    end
    #--------------------------------------------------------------------------
    # ● フレーム更新
    #--------------------------------------------------------------------------
    def update
      @action_end = true if !@battler.sv.picture
      return if @time == 0
      return if @action_end
      @time -= 1
      return plane_update if @plane
      super
      self.x += @move_x
      self.y += @move_y
      self.opacity += @data[6][1]
      return if @time != 1
      self.x = @e_x
      self.y = @e_y
      @time = 0
    end
    #--------------------------------------------------------------------------
    # ● フレーム更新
    #--------------------------------------------------------------------------
    def plane_update
      @plane.ox += @move_x
      @plane.oy += @move_y
      @plane.opacity += @data[6][1]
      @time = @data[4] if @time == 0
    end
    #--------------------------------------------------------------------------
    # ● 解放
    #--------------------------------------------------------------------------
    def dispose
      bitmap.dispose if bitmap
      @plane.dispose if @plane
      @viewport.dispose if @viewport
      super
    end
  end
  
  #==============================================================================
  # ■ Sprite_Back_Picture
  #------------------------------------------------------------------------------
  # 　周期ピクチャ用のスプライトです。
  #==============================================================================
  class Sprite_Back_Picture < Plane
    #--------------------------------------------------------------------------
    # ● 公開インスタンス変数　
    #--------------------------------------------------------------------------
    attr_accessor   :action_end           # 終了フラグ
    #--------------------------------------------------------------------------
    # ● オブジェクト初期化
    #--------------------------------------------------------------------------
    def initialize(viewport = nil, index)
      super(viewport)
      @index = index
      @real_x = 0
      @real_y = 0
      @real_opacity = 0
      @move_x = 0
      @move_y = 0
      @move_opacity = 0
      @time = 0
      @switche = 0
      @action_end = false
    end
    #--------------------------------------------------------------------------
    # ● セットアップ
    #--------------------------------------------------------------------------
    def setup(data)
      self.bitmap = Cache.picture(data[9])
      self.z = data[6]
      @switche = data[1]
      mirror = $sv_camera.mirror
      mirror = false if !data[8]
      @move_x = data[3][0]
      @move_x *= -1 if mirror
      @move_y = data[3][1]
      @time = data[4]
      @time = -1 if @time == 0
      @real_opacity = (data[5][0] + 1) * 100
      @move_opacity = data[5][1]
      @start_opacity = data[5][0]
      @shake_ok = data[7]
    end
    #--------------------------------------------------------------------------
    # ● フレーム更新
    #--------------------------------------------------------------------------
    def update
      update_picture if @time != 0
      self.ox = $sv_camera.x - @real_x
      self.oy = $sv_camera.y - @real_y
      if @shake_ok
        self.ox -= $sv_camera.sx / 100
        self.oy -= $sv_camera.sy / 100
      end
      self.ox *= $sv_camera.zoom
      self.oy *= $sv_camera.zoom
      self.zoom_x = @zoom_x * $sv_camera.zoom
      self.zoom_y = @zoom_y * $sv_camera.zoom
      self.opacity = @real_opacity / 100
      @move_opacity *= -1 if self.opacity == 255 or self.opacity <= @start_opacity
      @switche
      @action_end = true if @switche > 0 && !$game_switches[@switche]
      @action_end = true if @switche < 0 && !$sv_camera.switches[@switche.abs]
    end
    #--------------------------------------------------------------------------
    # ● ピクチャの更新
    #--------------------------------------------------------------------------
    def update_picture
      @real_x += @move_x / 100
      @real_y += @move_y / 100
      @real_x = 0 if @real_x >= self.bitmap.width or @real_x <= -self.bitmap.width
      @real_y = 0 if @real_y >= self.bitmap.height or @real_y <= -self.bitmap.height
      @zoom_x = 1
      @zoom_y = 1
      @real_opacity += @move_opacity
      @time -= 1
      @time = -1 if @time < -100
    end
  end
  
  #==============================================================================
  # ■ Sprite_Back_Picture
  #------------------------------------------------------------------------------
  # 　ダメージ表示のスプライトです。
  #==============================================================================
  class Sprite_Damage < Sprite
    #--------------------------------------------------------------------------
    # ● 公開インスタンス変数　
    #--------------------------------------------------------------------------
    attr_reader   :action_end                  # POP終了フラグ
    #--------------------------------------------------------------------------
    # ● オブジェクト初期化
    #--------------------------------------------------------------------------
    def initialize(viewport = nil, battler)
      super(viewport)
      @battler = battler
      @time = 0
      return @action_end = true if !@battler
      @direction = -1
      @direction *= -1 if @battler.actor?
      @direction *= -1 if $sv_camera.mirror
      set_state
      set_damage
      update
    end 
    #--------------------------------------------------------------------------
    # ● ステート表示
    #--------------------------------------------------------------------------
    def set_state
      return if !N03::STATE_POP
      states = @battler.result.added_state_objects
      states.delete($data_states[@battler.death_state_id]) if @battler.result.hp_damage != 0
      return if states == []
      return if @battler.sv.add_state == @battler.result.added_state_objects
      @battler.sv.add_state = states.dup
      @st = []
      @st_base = []
      for i in 0...states.size
        @st[i] = Sprite.new
        bitmap_state(@st[i], states[i])
        @st_base[i] = []
        @st_base[i][0] = @direction * (-20 + 5 * i) + @battler.sv.x / 100
        @st_base[i][1] = -40 - @state_height * i + (@battler.sv.y - @battler.sv.h - @battler.sv.j - @battler.sv.oy_adjust)/ 100
        @st[i].z = 1000 + i
        @st[i].opacity = 0
      end
      @time = @pop_time = 80
    end   
    #--------------------------------------------------------------------------
    # ● ステート画像
    #--------------------------------------------------------------------------
    def bitmap_state(state, state_object)
      name = state_object.name
      state.bitmap = Cache.system("Iconset").dup
      state.src_rect.set(state_object.icon_index % 16 * 24, state_object.icon_index / 16 * 24, 24, 24)
      @state_height = 24
    end
    #--------------------------------------------------------------------------
    # ● ダメージ表示
    #--------------------------------------------------------------------------
    def set_damage
      return @action_end = true if !N03::DAMAGE_POP
      damage = @battler.result.hp_damage if @battler.result.hp_damage != 0
      damage = @battler.result.hp_drain  if @battler.result.hp_drain  != 0
      damage = @battler.result.mp_damage if @battler.result.mp_damage != 0
      damage = @battler.result.mp_drain  if @battler.result.mp_drain  != 0
      damage = @battler.result.tp_damage if @battler.result.tp_damage != 0
      if !damage or damage == 0
        @action_end = true if @st == nil
        return # ステートだけPOPする設定を考慮して@action_endは返さない
      end
      @battler.sv.hit = 0
      @hit = 0 #@battler.sv.hit
      @battler.sv.hit += 1 if damage > 0
      file = N03::DAMAGE_PLUS if damage > 0
      file = N03::DAMAGE_MINUS if damage < 0
      add_file = N03::DAMAGE_MP if @battler.result.mp_damage != 0
      add_file = N03::DAMAGE_TP if @battler.result.tp_damage != 0
      adjust_x = N03::DAMAGE_ADJUST
      @num = []
      @num_base = []
      damage = damage.abs
      max_num = damage.to_s.size
      max_num += 1 if add_file != nil
      for i in 0...max_num
        @num[i] = Sprite.new
        if add_file != nil && i == max_num - 1
          @num[i].bitmap = Cache.system(add_file)
          cw = (damage % (10 * 10 ** i))/(10 ** i)
          sw = 0 if sw == nil
        else
          @num[i].bitmap = Cache.system(file)
          cw = (damage % (10 * 10 ** i))/(10 ** i)
          sw = @num[i].bitmap.width / 10
          @num[i].src_rect.set(cw * sw, 0, sw, @num[i].bitmap.height)
        end
        @num_base[i] = []
        @num_base[i][0] = (sw + adjust_x) * i * -1 + (@battler.sv.x / 100)
        @num_base[i][1] =  -(@num[i].bitmap.height / 3) - i * 2 - @hit * 2 + (@battler.sv.y - @battler.sv.h - @battler.sv.j - @battler.sv.oy_adjust)/ 100
        @num_base[i][0] -= @num[i].bitmap.width / 2 - adjust_x if add_file != nil && i == max_num - 1
        @num[i].z = 1000 + i + @hit * 10
      end
      @time = @pop_time = 80
    end
    #--------------------------------------------------------------------------
    # ● フレーム更新
    #--------------------------------------------------------------------------
    def update
      return if @time == 0
      for i in 0...@st.size do update_state_move(@st[i], i) end if @st != nil
      for i in 0...@num.size do update_num_move(@num[i], i) end if @num != nil
      @time -= 1
      @action_end = true if @time == 0
    end
    #--------------------------------------------------------------------------
    # ● ステート画像の更新
    #--------------------------------------------------------------------------
    def update_state_move(state, index)
      min = @pop_time - index * 2
      case @time
      when min-15..min
        @st_base[index][0] += @direction
        state.opacity += 25
      when min-80..min-50
        @st_base[index][0] += @direction
        state.opacity -= 25
      end
      state.x = (@st_base[index][0] - $sv_camera.x) * $sv_camera.zoom
      state.y = (@st_base[index][1] - $sv_camera.y) * $sv_camera.zoom
    end
    #--------------------------------------------------------------------------
    # ● 数値の更新
    #--------------------------------------------------------------------------
    def update_num_move(num, index)
      min = @pop_time - index * 2
      case @time
      when min-1..min
        @num_base[index][0] += @direction * @hit
        @num_base[index][1] -= 5 + @hit * 2
      when min-3..min-2
        @num_base[index][0] += @direction * @hit
        @num_base[index][1] -= 4 + @hit * 2
      when min-6..min-4
        @num_base[index][0] += @direction
        @num_base[index][1] -= 3 + @hit * 2
      when min-14..min-7
        @num_base[index][0] += @direction
        @num_base[index][1] += 2
      when min-17..min-15
        @num_base[index][1] -= 2 + @hit * 2
      when min-23..min-18
        @num_base[index][1] += 1
      when min-27..min-24
        @num_base[index][1] -= 1
      when min-30..min-28
        @num_base[index][1] += 1
      when min-33..min-31
        @num_base[index][1] -= 1
      when min-36..min-34
        @num_base[index][1] += 1
      end
      num.x = (@num_base[index][0] - $sv_camera.x) * $sv_camera.zoom
      num.y = (@num_base[index][1] - $sv_camera.y) * $sv_camera.zoom
      num.opacity = 256 - (12 - @time) * 32
      num.visible = false if @time == 0
    end
    #--------------------------------------------------------------------------
    # ● 解放
    #--------------------------------------------------------------------------
    def dispose
      @battler.sv.hit = 0
      bitmap.dispose if bitmap
      for i in 0...@num.size do @num[i].dispose end if @num != nil
      for i in 0...@st.size do @st[i].dispose end if @st != nil
      super
    end
  end
  
  #==============================================================================
  # ■ Window_Skill_name
  #------------------------------------------------------------------------------
  # 　スキル名を表示するウィンドウです。
  #==============================================================================
  class Window_Skill_name < Window_Base
    #--------------------------------------------------------------------------
    # ● オブジェクト初期化
    #--------------------------------------------------------------------------
    def initialize(text)
      super(0, 0, Graphics.width, line_height + standard_padding * 2)
      draw_text(4, 0, Graphics.width - 64, line_height,text, 1)
    end
  end
  
  #==============================================================================
  # ■ Spriteset_Sideview
  #------------------------------------------------------------------------------
  # 　サイドビュー独自のスプライトをまとめたクラスです。
  #==============================================================================
  class Spriteset_Sideview
    #--------------------------------------------------------------------------
    # ● オブジェクト初期化
    #--------------------------------------------------------------------------
    def initialize(viewport)
      @viewport = viewport
      @weapons = []
      @pictures = []
      @back_pic = []
      @damage = []
      $sv_camera.setup
      N03.camera(nil, N03::BATTLE_CAMERA["Before Turn Start"].dup)
    end
    #--------------------------------------------------------------------------
    # ● フレーム更新
    #--------------------------------------------------------------------------
    def update
      update_battler_data
      update_damage
      update_pictures
      update_back_pic
      update_weapons
    end  
    #--------------------------------------------------------------------------
    # ● バトラーデータの更新
    #--------------------------------------------------------------------------
    def update_battler_data
      for battler in $game_party.battle_members + $game_troop.members
        weapon_end(battler) if battler.sv.weapon_end
        next if battler.sv.effect_data == []
        for effect_data in battler.sv.effect_data do set_effects(battler, effect_data) end
      end
    end
    #--------------------------------------------------------------------------
    # ● ダメージ画像の更新
    #--------------------------------------------------------------------------
    def update_damage
      for i in 0...@damage.size
        next if @damage[i] == nil
        @damage[i].update if @damage[i] != nil
        next if !@damage[i].action_end
        @damage[i].dispose
        @damage[i] = nil
      end
    end
    #--------------------------------------------------------------------------
    # ● ピクチャアクションの更新
    #--------------------------------------------------------------------------
    def update_pictures
      for i in 0...@pictures.size
        next if @pictures[i] == nil
        @pictures[i].update if @pictures[i] != nil
        next if !@pictures[i].action_end
        @pictures[i].dispose
        @pictures[i] = nil
      end
    end
    #--------------------------------------------------------------------------
    # ● 周期ピクチャの更新
    #--------------------------------------------------------------------------
    def update_back_pic
      set_back_pic if $sv_camera.program_picture != []
      for i in 0...@back_pic.size
        next if @back_pic[i] == nil
        @back_pic[i].update if @back_pic[i] != nil
        next if !@back_pic[i].action_end
        @back_pic[i].dispose
        @back_pic[i] = nil
      end
    end
    #--------------------------------------------------------------------------
    # ● 武器アクションの更新
    #--------------------------------------------------------------------------
    def update_weapons
      for i in 0...@weapons.size
        next if @weapons[i] == nil
        @weapons[i].update if @weapons[i] != nil
        next if !@weapons[i].action_end
        @weapons[i].dispose
        @weapons[i] = nil
      end
    end
    #--------------------------------------------------------------------------
    # ● ダメージ実行
    #--------------------------------------------------------------------------
    def set_damage_pop(target)
      for i in 0...@damage.size
        next if @damage[i] != nil
        return @damage[i] = Sprite_Damage.new(@viewport, target)
      end
      @damage.push(Sprite_Damage.new(@viewport, target))
    end
    #--------------------------------------------------------------------------
    # ● 周期ピクチャ実行
    #--------------------------------------------------------------------------
    def set_back_pic
      for data in $sv_camera.program_picture
        if @back_pic[data[2]] != nil
          @back_pic[data[2]].dispose
          @back_pic[data[2]] = nil
        end
        @back_pic[data[2]] = Sprite_Back_Picture.new(@viewport, data[2])
        @back_pic[data[2]].setup(data)
      end
      $sv_camera.program_picture = []
    end
    #--------------------------------------------------------------------------
    # ● エフェクト開始
    #--------------------------------------------------------------------------
    def set_effects(battler, effect_data)
      case effect_data[0]
      when "pic" ; set_pictures(battler, effect_data)
      when  "wp" ; set_weapons(battler,  true)
      when "m_a" ; set_weapons(battler, false)
      end
    end
    #--------------------------------------------------------------------------
    # ● ピクチャアクション実行
    #--------------------------------------------------------------------------
    def set_pictures(battler, effect_data)
      @pictures[effect_data[1]] = Sprite_Battle_Picture.new if @pictures[effect_data[1]] == nil
      @pictures[effect_data[1]].set(battler)
    end
    #--------------------------------------------------------------------------
    # ● 武器アクション実行
    #--------------------------------------------------------------------------
    def set_weapons(battler, weapon_flag, test = true)
      for i in 0...@weapons.size
        next if @weapons[i] != nil
        @weapons[i] = Sprite_Weapon.new(@viewport, i, battler) 
        battler.sv.weapon_index.push(i) if weapon_flag
        return i
      end
      @weapons.push(Sprite_Weapon.new(@viewport, @weapons.size, battler))
      battler.sv.weapon_index.push(@weapons.size - 1) if weapon_flag
      return @weapons.size - 1
    end
    #--------------------------------------------------------------------------
    # ● バトラーの武器アクション終了
    #--------------------------------------------------------------------------
    def weapon_end(battler)
      battler.sv.weapon_end = false
      for index in battler.sv.weapon_index
        weapon_index = battler.sv.weapon_index.shift
        @weapons[weapon_index].dispose if @weapons[weapon_index] != nil
        @weapons[weapon_index] = nil
      end
      battler.sv.weapon_index.compact!
    end  
    #--------------------------------------------------------------------------
    # ● ヒット時の戦闘アニメ実行
    #--------------------------------------------------------------------------
    def set_hit_animation(battler, weapon_index, hit_targets, miss)
      weapon = @weapons[weapon_index]
      for target in hit_targets
        next @weapons[@hit_index].timing_battler_set(target) if @hit_index != nil
        @hit_index = set_weapons(battler, false, false)
        @weapons[@hit_index].set_hit_animation(weapon.hit_position, weapon.hit_anime_id, target)
      end
      @hit_index = nil
      if !weapon.through && !miss
        @weapons[weapon_index].dispose
        @weapons[weapon_index] = nil
      else
        @weapons[weapon_index].through_change
      end
    end
    #--------------------------------------------------------------------------
    # ● サイドビューデータの初期化
    #--------------------------------------------------------------------------
    def reset_sideview
      $sv_camera.reset
      for member in $game_troop.members + $game_party.battle_members do member.sv.reset end
    end  
    #--------------------------------------------------------------------------
    # ● 解放
    #--------------------------------------------------------------------------
    def dispose
      dispose_effects(@weapons)
      dispose_effects(@pictures)
      dispose_effects(@back_pic)
      dispose_effects(@damage)
      reset_sideview
    end
    #--------------------------------------------------------------------------
    # ● エフェクト画像の解放
    #--------------------------------------------------------------------------
    def dispose_effects(effects)
      for i in 0...effects.size
        effects[i].dispose if effects[i] != nil
        effects[i] = nil
      end
    end
  end
  
  
  #==============================================================================
  # ■ Sprite_Battle_Back
  #------------------------------------------------------------------------------
  # 　戦闘背景用のスプライトです。
  #==============================================================================
  class Sprite_Battle_Back < Plane
    #--------------------------------------------------------------------------
    # ● オブジェクト初期化
    #--------------------------------------------------------------------------
    def initialize(viewport = nil, index, battleback_name)
      super(viewport)
      @index = index
      if @index == 1
        data = N03::FLOOR1_DATA[battleback_name]
        data = N03::FLOOR1_DATA["Battlebacks1"] if data == nil
      elsif @index == 2
        data = N03::FLOOR2_DATA[battleback_name]
        data = N03::FLOOR2_DATA["Battlebacks2"] if data == nil
      end    
      data = data.dup
      @adjust_position = data[0]
      @zoom_x = data[1][0] / 100.0
      @zoom_y = data[1][1] / 100.0
      @shake_on = data[2]
      $game_switches[data[3]] = true if data[3] > 0
      $sv_camera.switches[data[3].abs] = true if data[3] < 0
      reset_scroll
      reset_back_data(battleback_name)
    end
    #--------------------------------------------------------------------------
    # ● 背景スクロールを初期化
    #--------------------------------------------------------------------------
    def reset_scroll
      @scroll_x = 0
      @scroll_y = 0
      @move_x = 0
      @move_y = 0
    end
    #--------------------------------------------------------------------------
    # ● 背景データを初期化
    #--------------------------------------------------------------------------
    def reset_back_data(battleback_name)
      @back_data = []
      @active_data = ["scroll",0, @move_x, @move_y, false, battleback_name,""]
      start_back_data(@active_data)
    end  
    #--------------------------------------------------------------------------
    # ● 背景画像のセッティング
    #--------------------------------------------------------------------------
    def set_graphics(new_bitmap)
      self.bitmap = new_bitmap
      @base_x = (self.bitmap.width * @zoom_x - Graphics.width) / 2 + @adjust_position[0]
      @base_y = (self.bitmap.height * @zoom_y - Graphics.height) / 2 + @adjust_position[1]
      # 限界座標を取得
      max_top =  0
      max_bottom = self.bitmap.height * @zoom_y - Graphics.height
      max_left = 0
      max_right = self.bitmap.width * @zoom_x - Graphics.width
      exist = true 
      exist = false if self.bitmap.height == 32 && self.bitmap.width == 32
      $sv_camera.setting(@index, [max_top, max_bottom, max_left, max_right, @base_x, @base_y,exist])
    end
    #--------------------------------------------------------------------------
    # ● フレーム更新
    #--------------------------------------------------------------------------
    def update
      return if !bitmap
      update_back_data
      update_scroll unless @move_x == 0 && @move_y == 0
      update_color
      update_position
      update_back_adjust if @bt_back != nil
      create_back_adjust if @bt_back == nil && !@active_data[10] && @scroll_x == 0 && @scroll_y == 0
    end
    #--------------------------------------------------------------------------
    # ● 背景データを更新
    #--------------------------------------------------------------------------
    def update_back_data
      delete = true if @active_data[1] > 0 && !$game_switches[@active_data[1]]
      delete = true if @active_data[1] < 0 && !$sv_camera.switches[@active_data[1].abs]
      return if !delete
      for i in 0...@back_data.size
        @back_data[i] = nil if @back_data[i][1] > 0 && !$game_switches[@back_data[i][1]]
        @back_data[i] = nil if @back_data[i][1] < 0 && !$sv_camera.switches[@back_data[i][1].abs]
      end
      @back_data.compact!
      next_back_data
    end
    #--------------------------------------------------------------------------
    # ● 次の背景データをセット
    #--------------------------------------------------------------------------
    def next_back_data
      @back_data.delete(@active_data[11]) if @active_data[11] != nil
      @back_data.push(@active_data[11]) if @active_data[11] != nil
      @active_data = nil
      data = @back_data.pop
      @back_data = [@active_data] if @back_data.size == 0
      start_back_data(data)
    end  
    #--------------------------------------------------------------------------
    # ● 背景データを実行
    #--------------------------------------------------------------------------
    def start_back_data(data)
      return if back_data_remain(data)
      bt_back_dispose
      pre_active_data = @active_data
      @active_data[8] = [@back_name, @move_x, @move_y, @scroll_x, @scroll_y] if @active_data != nil
      @back_data.push(@active_data)     if @active_data != nil
      @active_data = data.dup
      @active_data[5] = @back_name      if @active_data[5] == ""
      @active_data[9] = set_back_adjust if @active_data[9] == nil
      back_data_scroll_on               if @active_data[8] == nil && @active_data[9][0] == false
      set_remain_back_data              if @active_data[8] != nil
      create_back(@active_data[5])      if @active_data[9][0] == false
      create_back_adjust                if @active_data[10]
      @active_data[11] = pre_active_data if pre_active_data && @active_data[7] == false
    end  
    #--------------------------------------------------------------------------
    # ● 背景データの保留
    #--------------------------------------------------------------------------
    def back_data_remain(data)
      remain = false
      remain = true if data[6] != "" && @active_data != nil && @active_data[9] != nil && @active_data[9][0] != false
      remain = true if @active_data != nil && @active_data[7] == false
      return remain if !remain
      @remain = true
      @back_data.push(data)
      return remain
    end  
    #--------------------------------------------------------------------------
    # ● 背景変更補正データをセット
    #--------------------------------------------------------------------------
    def set_back_adjust
      bt_adjust = []
      sign = -1
      if @active_data[6] == ""
        reset_scroll if @active_data[3][0] == 0 &&  @active_data[3][1] == 0
        bt_adjust = [false,false,0,0]
        return bt_adjust
      elsif @move_x != 0 or @active_data[3][0] != 0
        sign = 1 if @move_x < 0
        bt_adjust[0] = [self.bitmap.width * @zoom_x * sign, 0]
        bt_adjust[1] = [self.bitmap.width * @zoom_x * sign * 2, 0]
      elsif @move_y != 0 or @active_data[3][1] != 0
        sign = 1 if @move_y < 0
        bt_adjust[0] = [0, self.bitmap.height * @zoom_y * sign]
        bt_adjust[1] = [0, self.bitmap.height * @zoom_y * sign * 2]
      else
        reset_scroll if @active_data[3][0] == 0 &&  @active_data[3][1] == 0
        bt_adjust = [false,false,0,0]
        return bt_adjust
      end
      bt_adjust[2] = [bt_adjust[0][0], bt_adjust[0][1]]
      return bt_adjust
    end
    #--------------------------------------------------------------------------
    # ● 背景スクロールデータを実行
    #--------------------------------------------------------------------------
    def back_data_scroll_on
      mirror = $sv_camera.mirror
      mirror = false if !@active_data[4]
      @move_x = @active_data[3][0]
      @move_x *= -1 if mirror
      @move_y = @active_data[3][1]
    end
    #--------------------------------------------------------------------------
    # ● 保持している背景データを実行
    #--------------------------------------------------------------------------
    def set_remain_back_data
      return back_data_scroll_on if @move_x != 0 or @move_y != 0
      create_back(@active_data[8][0])
      @move_x    = @active_data[8][1]
      @move_y    = @active_data[8][2]
      @scroll_x  = @active_data[8][3]
      @scroll_y  = @active_data[8][4]
    end  
    #--------------------------------------------------------------------------
    # ● 背景画像の作成
    #--------------------------------------------------------------------------
    def create_back(back_name)
      return if back_name == @back_name or back_name == ""
      self.bitmap = Cache.battleback1(back_name) if @index == 1
      self.bitmap = Cache.battleback2(back_name) if @index == 2
      @back_name = back_name
    end  
    #--------------------------------------------------------------------------
    # ● 背景変更補正画像の作成
    #--------------------------------------------------------------------------
    def create_back_adjust
      return if @active_data[9][0] == false
      @active_data[10] = true
      mirror = $sv_camera.mirror
      mirror = false if !@active_data[4]
      @bt_back = []
      @bt_back[0] = Sprite.new(viewport)
      @bt_back[0].bitmap = Cache.battleback1(@active_data[6]) if @index == 1
      @bt_back[0].bitmap = Cache.battleback2(@active_data[6]) if @index == 2
      @bt_back[0].mirror = mirror
      @bt_back[1] = Sprite.new(viewport)
      @bt_back[1].bitmap = Cache.battleback1(@active_data[5]) if @index == 1
      @bt_back[1].bitmap = Cache.battleback2(@active_data[5]) if @index == 2
      @bt_back[1].mirror = mirror
    end
    #--------------------------------------------------------------------------
    # ● 背景スクロールの更新
    #--------------------------------------------------------------------------
    def update_scroll
      @scroll_x += @move_x
      @scroll_y += @move_y
      @scroll_x = 0 if @scroll_x / 100 >= self.bitmap.width * @zoom_x or @scroll_x / 100 <= -self.bitmap.width * @zoom_x
      @scroll_y = 0 if @scroll_y / 100 >= self.bitmap.height * @zoom_y or @scroll_y / 100 <= -self.bitmap.height * @zoom_y
    end
    #--------------------------------------------------------------------------
    # ● 色調変更の更新
    #--------------------------------------------------------------------------
    def update_color
      color_set if $sv_camera.color_set[@index] != nil
      return if @color_data == nil
      @color_data[4] -= 1
      if @color_data[4] == 0 && @color_data[5] != 0
        @color_data[4] = @color_data[5]
        @color_data[5] = 0
        @color_data[6] = [0,0,0,0]
      elsif @color_data[4] == 0
        @remain_color_data = @color_data
        return @color_data = nil
      end  
      for i in 0..3
        @color_data[i] = (@color_data[i] * (@color_data[4] - 1) + @color_data[6][i]) / @color_data[4]
      end  
      self.color.set(@color_data[0], @color_data[1], @color_data[2], @color_data[3])
    end
    #--------------------------------------------------------------------------
    # ● 座標の更新
    #--------------------------------------------------------------------------
    def update_position
      self.ox = $sv_camera.x + @base_x - @scroll_x / 100
      self.oy = $sv_camera.y + @base_y - @scroll_y / 100
      self.ox -= $sv_camera.sx / 100 if @shake_on
      self.oy -= $sv_camera.sy / 100 if @shake_on
      self.zoom_x = @zoom_x * $sv_camera.zoom
      self.zoom_y = @zoom_y * $sv_camera.zoom
      self.ox *= $sv_camera.zoom
      self.oy *= $sv_camera.zoom
      self.z = @index * 10
    end
    #--------------------------------------------------------------------------
    # ● 背景変更補正画像を更新
    #--------------------------------------------------------------------------
    def update_back_adjust
      @active_data[9][0][0] = 0 if @scroll_x == 0
      @active_data[9][0][1] = 0 if @scroll_y == 0
      @active_data[9][1][0] -= @active_data[9][2][0] if @scroll_x == 0
      @active_data[9][1][1] -= @active_data[9][2][1] if @scroll_y == 0
      for i in 0...@bt_back.size
        @bt_back[i].x = -self.ox + @active_data[9][i][0] * $sv_camera.zoom
        @bt_back[i].y = -self.oy + @active_data[9][i][1] * $sv_camera.zoom
        @bt_back[i].zoom_x = self.zoom_x
        @bt_back[i].zoom_y = self.zoom_y
        @bt_back[i].z = self.z + 1
        @bt_back[i].color.set(@color_data[0], @color_data[1], @color_data[2], @color_data[3]) if @color_data != nil
      end
      back_data_scroll_on if @active_data[9][0][0] == 0 && @active_data[9][0][1] == 0
      return unless @active_data[9][1][0] == 0 && @active_data[9][1][1] == 0
      bt_back_dispose
      create_back(@active_data[5])
      @active_data[9][0] = false
      next_back_data if @remain && @back_data.size != 1
      @remain = false
    end
    #--------------------------------------------------------------------------
    # ● 色調変更
    #--------------------------------------------------------------------------
    def color_set
      set = $sv_camera.color_set[@index]
      $sv_camera.color_set[@index] = nil
      set[4] = 1 if set[4] == 0
      @remain_color_data = [0,0,0,0] if @remain_color_data == nil
      @color_data = @remain_color_data
      @color_data[4] = set[4]
      @color_data[5] = set[5]
      @color_data[6] = set
    end
    #--------------------------------------------------------------------------
    # ● 背景変更補正画像の解放
    #--------------------------------------------------------------------------
    def bt_back_dispose
      for i in 0...@bt_back.size do @bt_back[i].dispose end if @bt_back != nil
      @bt_back = nil
    end  
    #--------------------------------------------------------------------------
    # ● 解放
    #--------------------------------------------------------------------------
    def dispose
      bitmap.dispose if bitmap
      bt_back_dispose
      super
    end
  end