#==============================================================================
# ■ Battle_Camera
#------------------------------------------------------------------------------
# 　戦闘カメラやバトルプログラムを扱うクラスです。 
#==============================================================================
class Battle_Camera
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数　
  #--------------------------------------------------------------------------
  attr_reader   :sx                 # シェイクX座標
  attr_reader   :sy                 # シェイクY座標
  attr_reader   :max_top            # 上限界座標
  attr_reader   :max_bottom         # 下限界座標
  attr_reader   :max_left           # 左限界座標
  attr_reader   :max_right          # 右限界座標
  attr_accessor :switches           # サイドビュー専用スイッチ
  attr_accessor :color_set          # 色調変更データ
  attr_accessor :wait               # 戦闘シーンの強制ウエイト
  attr_accessor :win_wait           # 戦闘勝利前のウエイト
  attr_accessor :mirror             # 画面反転フラグ
  attr_accessor :program_scroll     # バトルプログラム 背景の自動スクロール
  attr_accessor :program_picture    # バトルプログラム 周期ピクチャ
  attr_accessor :event              # コモンイベント呼び出し
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化 
  #--------------------------------------------------------------------------
  def initialize
    @switches = []
    @max_data = []
    @color_set = []
    @wait = 0
    @win_wait = false
    @mirror = false
    @event = false
    setup
  end
  #--------------------------------------------------------------------------
  # ● カメラX座標
  #--------------------------------------------------------------------------
  def x
    return @x / 100
  end
  #--------------------------------------------------------------------------
  # ● カメラY座標
  #--------------------------------------------------------------------------
  def y
    return @y / 100
  end
  #--------------------------------------------------------------------------
  # ● ズーム率 
  #--------------------------------------------------------------------------
  def zoom
    return @zoom * 0.001
  end
  #--------------------------------------------------------------------------
  # ● ズーム率による座標変換
  #--------------------------------------------------------------------------
  def convert
    return @zoom
  end
  #--------------------------------------------------------------------------
  # ● カメラセットアップ
  #--------------------------------------------------------------------------
  def setup
    @x = 0
    @y = 0
    @sx = 0
    @sy = 0
    @zoom = 1000
    @time = 0
    @shake_time = 0
    program_setup
  end
  #--------------------------------------------------------------------------
  # ● カメラ初期化
  #--------------------------------------------------------------------------
  def reset
    @switches = []
    @max_data = []
    @color_set = []
    @wait = 0
    @win_wait = false
    @mirror = false
    program_setup(false)
  end  
  #--------------------------------------------------------------------------
  # ● バトルプログラムのセットアップ
  #--------------------------------------------------------------------------
  def program_setup(check = true)
    @played_program  = []
    @program_switch  = []
    @program_sound   = []
    @program_scroll  = []
    @program_se      = []
    @program_shake   = []
    @program_color   = []
    @program_picture = []
    @program_base = N03::BATTLE_PROGRAM.values.dup
    program_check if check
  end  
  #--------------------------------------------------------------------------
  # ● バトルプログラムのチェック
  #--------------------------------------------------------------------------
  def program_check
    for data in @program_base
      if program_start?(data) && !@played_program.include?(data)
        @played_program.push(data.dup)
        @program_scroll.push(data.dup)  if data[0] == "scroll"
        @program_picture.push(data.dup) if data[0] == "kpic"
        start_sound(data.dup)           if data[0] == "sound"
        start_program_switch(data.dup)  if data[0] == "switch"
        start_program_se(data.dup)      if data[0] == "keep_se"
        start_program_shake(data.dup)   if data[0] == "keep_sk"
        start_program_color(data.dup)   if data[0] == "keep_c"
      else
        @played_program.delete(data)  if !program_start?(data)
        @program_scroll.delete(data)  if data[0] == "scroll"
        @program_picture.delete(data) if data[0] == "kpic"
        @program_switch.delete(data)  if data[0] == "switch"
        @program_sound.delete(data)   if data[0] == "sound"
        @program_se.delete(data)      if data[0] == "keep_se"
        @program_shake.delete(data)   if data[0] == "keep_sk"
        @program_color.delete(data)   if data[0] == "keep_c"
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● バトルプログラムの開始
  #--------------------------------------------------------------------------
  def program_start?(data)
    start = false
    start = true if $game_switches[data[1].abs] && data[1] > 0
    start = true if @switches[data[1].abs] && data[1] < 0
    return start
  end  
  #--------------------------------------------------------------------------
  # ● バトルプログラム スイッチ操作の開始
  #--------------------------------------------------------------------------
  def start_program_switch(data)
    data[4] = data[4] + rand(data[5] + 1)
    data[4] = 1 if data[4] <= 0
    @program_switch.push(data)
  end
  #--------------------------------------------------------------------------
  # ● スイッチ操作の更新
  #--------------------------------------------------------------------------
  def update_program_switch
    for data in @program_switch
      data[4] -= 1
      next @program_switch.delete(data) if data[1] > 0 && !$game_switches[data[1]]
      next @program_switch.delete(data) if data[1] < 0 && !@switches[data[1].abs]
      next if data[4] != 0
      for id in data[2]
        $game_switches[id] = true if id > 0
        @switches[id.abs] = true  if id < 0
      end
      for id in data[3]
        $game_switches[id] = false if id > 0
        @switches[id.abs] = false  if id < 0
      end
      @program_switch.delete(data)
      program_check
    end  
  end
  #--------------------------------------------------------------------------
  # ● バトルプログラム BGM/BGSの開始
  #--------------------------------------------------------------------------
  def start_sound(data)
    @program_sound.push(data)
    name = data[5]
    case data[2]
    when "se"
      Audio.se_play("Audio/SE/" + name, data[4], data[3])
    when "bgm"
      name = RPG::BGM.last.name if data[5] == ""
      Audio.bgm_play("Audio/BGM/" + name, data[4], data[3])
    when "bgs"
      name = RPG::BGS.last.name if data[5] == ""
      Audio.bgs_play("Audio/BGS/" + name, data[4], data[3])
    end
  end
  #--------------------------------------------------------------------------
  # ● バトルプログラム 周期SEの開始
  #--------------------------------------------------------------------------
  def start_program_se(data)
    data[3] = [data[2], data[3]]
    data[2] = data[3][0] + rand(data[3][1] + 1)
    @program_se.push(data)
    Audio.se_play("Audio/SE/" + data[7], data[5], data[4]) if data[6]
  end
  #--------------------------------------------------------------------------
  # ● 周期SEの更新
  #--------------------------------------------------------------------------
  def update_program_se
    for data in @program_se
      data[2] -= 1
      next @program_se.delete(data) if data[1] > 0 && !$game_switches[data[1]]
      next @program_se.delete(data) if data[1] < 0 && !@switches[data[1].abs]
      next if data[2] != 0
      Audio.se_play("Audio/SE/" + data[7], data[5], data[4])
      data[2] = data[3][0] + rand(data[3][1] + 1)
    end  
  end
  #--------------------------------------------------------------------------
  # ● バトルプログラム 周期シェイクの開始
  #--------------------------------------------------------------------------
  def start_program_shake(data)
    data[3] = [data[2], data[3]]
    data[2] = data[3][0] + rand(data[3][1] + 1)
    @program_shake.push(data)
    shake(data[4], data[5], data[6]) if data[7]
  end
  #--------------------------------------------------------------------------
  # ● 周期シェイクの更新
  #--------------------------------------------------------------------------
  def update_program_shake
    for data in @program_shake
      data[2] -= 1
      next @program_shake.delete(data) if data[1] > 0 && !$game_switches[data[1]]
      next @program_shake.delete(data) if data[1] < 0 && !@switches[data[1].abs]
      next if data[2] != 0
      shake(data[4], data[5], data[6])
      data[2] = data[3][0] + rand(data[3][1] + 1)
    end  
  end
  #--------------------------------------------------------------------------
  # ● バトルプログラム 周期色調変更の開始
  #--------------------------------------------------------------------------
  def start_program_color(data)
    data[3] = [data[2], data[3]]
    data[2] = data[3][0] + rand(data[3][1] + 1)
    data[7] = true if data[4] == 0 or data[4] == 4
    case data[4]
    when 1   ;data[4] = $game_troop.members
    when 2   ;data[4] = $game_party.battle_members
    when 3,4 ;data[4] = $game_troop.members + $game_party.battle_members
    else ;data[4] = []
    end
    @program_color.push(data)
    return if !data[6]
    for target in data[4] do target.sv.color_set = data[5] end if data[4] != []
    @color_set[1] = data[5] if data[7]
    @color_set[2] = data[5] if data[7]
  end
  #--------------------------------------------------------------------------
  # ● 周期色調変更の更新
  #--------------------------------------------------------------------------
  def update_program_color
    for data in @program_color
      data[2] -= 1
      next @program_color.delete(data) if data[1] > 0 && !$game_switches[data[1]]
      next @program_color.delete(data) if data[1] < 0 && !@switches[data[1].abs]
      next if data[2] != 0
      for target in data[4] do target.sv.color_set = data[5] end if data[4] != []
      @color_set[1] = data[5] if data[7]
      @color_set[2] = data[5] if data[7]
      data[2] = data[3][0] + rand(data[3][1] + 1)
    end 
  end
  #--------------------------------------------------------------------------
  # ● トランジション実行
  #--------------------------------------------------------------------------
  def perform_transition(data)
    Graphics.transition(data[2], "Graphics/Pictures/" + data[3], data[1])
  end  
  #--------------------------------------------------------------------------
  # ● 背景からカメラの限界値を取得  data = [max_top, max_bottom, max_left, max_right]
  #--------------------------------------------------------------------------
  def setting(index, data)
    @max_data[index - 1] = data
    return if index != 2
    setup
    # カメラの中心座標
    @center_x     = (Graphics.width / 2 + N03::CAMERA_POSITION[0]) * 100
    @center_y     = (Graphics.height / 2 + N03::CAMERA_POSITION[1]) * 100
    # 上下左右の移動限界距離
    @max_top    = [@max_data[0][5], @max_data[1][5]].min * -1
    @max_bottom = [@max_data[0][1], @max_data[1][1]].min + @max_top
    @max_left   = [@max_data[0][4], @max_data[1][4]].min  * -1
    @max_right  = [@max_data[0][3], @max_data[1][3]].min + @max_left
    exist_data = @max_data[0] if !@max_data[1][6]
    exist_data = @max_data[1] if !@max_data[0][6]
    @max_top    = exist_data[5] * -1        if exist_data != nil
    @max_bottom = exist_data[1] + @max_top  if exist_data != nil
    @max_left   = exist_data[4] * -1        if exist_data != nil
    @max_right  = exist_data[3] + @max_left if exist_data != nil
    @max_top = @max_bottom = @max_left = @max_right = 0 if !@max_data[1][6] && !@max_data[0][6]
    @max_width    = @max_right - @max_left + Graphics.width
    @max_height   = @max_bottom - @max_top + Graphics.height
    # ズームアウト限界値
    max_zoom_x    = 100 * Graphics.width / @max_width
    max_zoom_y    = 100 * Graphics.height / @max_height
    @max_zoom_out = [max_zoom_x, max_zoom_y].max
  end
  #--------------------------------------------------------------------------
  # ● カメラ移動
  #--------------------------------------------------------------------------
  def move(target_x, target_y, zoom, time, screen = true)
    # 戦闘背景以上のサイズまでズームアウトしないよう調整
    if(@max_zoom_out == nil)
      @max_zoom_out = 100.00
    end
    @target_zoom = [zoom * 0.01, @max_zoom_out * 0.01].max
    target_x *= -1 if screen && @mirror
    # ズーム分の中心座標補正
    if screen && @target_zoom != 1
      target_x = target_x + @center_x
      target_y = target_y + @center_y
    end
    adjust_x = @center_x * (@target_zoom - 1) / (@target_zoom ** 2 - @target_zoom)
    adjust_y = @center_y * (@target_zoom - 1) / (@target_zoom ** 2 - @target_zoom)
    adjust_x = 0 if adjust_x.nan?
    adjust_y = 0 if adjust_y.nan?
    adjust_x = @center_x if !screen && adjust_x == 0
    adjust_y = @center_y if !screen && adjust_y == 0
    @target_x = target_x - adjust_x.to_i
    @target_y = target_y - adjust_y.to_i
    @target_zoom = (@target_zoom * 1000).to_i
    @zoom = @zoom.to_i
    limit_test
    # 時間0の場合は即実行
    return @time = time.abs if time != 0
    @time = 1
    update
  end
  #--------------------------------------------------------------------------
  # ● 限界座標の試算
  #--------------------------------------------------------------------------
  def limit_test
    new_width = @max_width * @target_zoom / 1000
    new_height = @max_height * @target_zoom / 1000
    new_max_right = @max_right - (@max_width - new_width)
    new_max_bottom = @max_bottom - (@max_height - new_height)
    # 画面の移動先が限界の場合、限界座標をセット
    if @target_x < @max_left * 100
      @target_x = @max_left * 100
    end 
    if @target_x > new_max_right * 100
      @target_x = new_max_right * 100
    end
    if @target_y < @max_top * 100
      @target_y = @max_top * 100
    end
    if @target_y > new_max_bottom * 100
      @target_y = new_max_bottom * 100
    end
  end
  #--------------------------------------------------------------------------
  # ● 画面のシェイク
  #--------------------------------------------------------------------------
  def shake(power, speed, time)
    @shake_x = power[0] * 100
    @shake_y = power[1] * 100
    @power_time_base = @power_time = speed
    @shake_time = time
    update_shake
  end
  #--------------------------------------------------------------------------
  # ● シェイクの更新
  #--------------------------------------------------------------------------
  def update_shake
    @sx = (@sx * (@power_time - 1) + @shake_x) / @power_time
    @sy = (@sy * (@power_time - 1) + @shake_y) / @power_time
    @power_time -= 1
    @shake_time -= 1
    return @sx = @sy = 0 if @shake_time == 0
    return if @power_time != 0
    @power_time = @power_time_base
    @shake_x = @shake_x * -4 / 5
    @shake_y = @shake_y * -4 / 5
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    update_shake if @shake_time != 0
    update_program
    return if @time == 0
    @x = (@x * (@time - 1) + @target_x) / @time
    @y = (@y * (@time - 1) + @target_y) / @time
    @zoom = (@zoom * (@time - 1) + @target_zoom) / @time
    @time -= 1
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update_program
    update_program_switch if @program_switch != []
    update_program_se     if @program_se != []
    update_program_shake  if @program_shake != []
    update_program_color  if @program_color != []
  end
end