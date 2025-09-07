module Cirno
  module Persistence
    WRITE_FUNC = Win32API.new("Kernel32.dll", "WritePrivateProfileString",
      "pppp", "i")
    READ_FUNC = Win32API.new("Kernel32.dll", "GetPrivateProfileString",
      "pppplp", "l")
    
    def self.read_general_setting(flag)
      a = "\0" * 256
      res = READ_FUNC.call("General", flag, 0, a, 256, "./Game.ini")
      if res == 0
        a = general_setting_default_values[flag].to_s
        write_general_setting(flag, a)
      else
        a = a.unpack("Z*")[0]
      end
      a
    end
    
    def self.write_general_setting(flag, data)
      WRITE_FUNC.call("General", flag, data, "./Game.ini")
    end
    
    def self.apply_general_settings
      Graphics.fullscreen = (read_general_setting("Run in Fullscreen") == "true")
      Graphics.vsync = (read_general_setting("Enable VSync") == "true")
      
      t = read_general_setting("Window Resize").to_i + 1
      Graphics.resize_window(Graphics.width * t, Graphics.height * t)
      
      Audio.master_volume_music = read_general_setting("Music Volume").to_i
      Audio.master_volume_sound = read_general_setting("Sound Volume").to_i
      # LanguageFileSystem::self.language = read_general_setting("Language")
    end
      
    def self.write_keyboard_settings
      for flag in keys
        keycodes = Input.get_keys_from_flag(flag)
        WRITE_FUNC.call("Keys", flag, keycodes.join(","), "./Game.ini")
      end
    end
    
    def self.read_keyboard_settings
      a = "\0" * 256
      res = READ_FUNC.call("Keys", "Up", 0, a, 256, "./Game.ini")
      if res == 0
        write_keyboard_settings
      end
      
      for flag in keys
        keycodes = Input.get_keys_from_flag(flag)
        a = "\0" * 256
        READ_FUNC.call("Keys", flag, 0, a, 256, "./Game.ini")
        a = a.unpack("Z*")[0]
        a = a.split(",").map { |item| item.to_i }
        Input.set_keys_from_flag(flag, a)
      end
    end
  end
end

module Audio
  @@master_volume_music = 100
  @@master_volume_sound = 100
  @@bgm_name = nil
  @@bgs_name = nil
  def self.master_volume_music
    @@master_volume_music
  end
  def self.master_volume_sound
    @@master_volume_sound
  end
  def self.master_volume_music=(val)
    @@master_volume_music = [[val.to_i, 0].max, 100].min
    update_audio_volume
  end
  def self.master_volume_sound=(val)
    @@master_volume_sound = [[val.to_i, 0].max, 100].min
    update_audio_volume
  end
  
  class << self
    alias cirno_20181212_bgm_play bgm_play
    alias cirno_20181212_bgm_stop bgm_stop
    alias cirno_20181212_bgs_play bgs_play
    alias cirno_20181212_bgs_stop bgs_stop
    alias cirno_20181212_me_play me_play
    alias cirno_20181212_se_play se_play
    
  
    def update_audio_volume
      if @@bgm_name && @@bgm_volume && @@bgm_pitch
        bgm_play(@@bgm_name, @@bgm_volume, @@bgm_pitch)
      end
      if @@bgs_name && @@bgs_volume && @@bgs_pitch
        bgs_play(@@bgs_name, @@bgs_volume, @@bgs_pitch)
      end
    end
    
    def bgm_play(filename, volume = 100, pitch = 100, pos = 0)
      @@bgm_name = filename
      @@bgm_volume = volume
      @@bgm_pitch = pitch
      volume = @@master_volume_music * volume / 100
      cirno_20181212_bgm_play(filename, volume, pitch, pos)
    end
    
    def bgm_stop
      @@bgm_name = nil
      cirno_20181212_bgm_stop
    end
    
    def bgs_play(filename, volume = 100, pitch = 100, pos = 0)
      @@bgs_name = filename
      @@bgs_volume = volume
      @@bgs_pitch = pitch
      volume = @@master_volume_sound * volume / 100
      cirno_20181212_bgs_play(filename, volume, pitch, pos)
    end
    
    def bgs_stop
      @@bgs_name = nil
      cirno_20181212_bgs_stop
    end
    
    def me_play(filename, volume = 100, pitch = 100)
      volume = @@master_volume_music * volume / 100
      cirno_20181212_me_play(filename, volume, pitch)
    end
    
    def se_play(filename, volume = 100, pitch = 100)
      volume = @@master_volume_sound * volume / 100
      cirno_20181212_se_play(filename, volume, pitch)
    end
  end
end


class Window_ConfigCommand < Window_HorzCommand

  def initialize
    super(0, 0)
  end

  def window_width
    Graphics.width
  end
  
  def window_height
    64
  end
  
  def item_height
    32
  end

  def col_max
    return 2
  end

  def make_command_list
    add_command(Cirno::ConfigSettings::CHOICE_GENERAL_SETTING, :general)
    add_command(Cirno::ConfigSettings::CHOICE_KEY_SETTING, :controls)
  end
end


class Window_ConfigGeneral < Window_Selectable
  def initialize(w, h)
    super((Graphics.width - w) / 2, Graphics.height - h, w, h)
    select(0)
    set_handler(:ok, method(:on_select))
    setup_settings
    refresh
  end
  
  def setup_settings(reset_flag = false)
    @setting_values = {}
    for i in 0 ... config_count
      flag = config_data[i][0]
      type = config_data[i][1]
      s = Cirno::Persistence.read_general_setting(flag)
      if s == "" || reset_flag
        s = default_settings[flag]
        Cirno::Persistence.write_general_setting(flag, s.to_s)
      else
        if type == :bool
          s = (s == "true")
        elsif type == :percentage
          s = s.to_i
        elsif type.is_a?(Array)
          s = s.to_i
        end
      end
      @setting_values[flag] = s
    end
  end
  
  def save_settings
    for i in 0 ... config_count
      flag = config_data[i][0]
      s = @setting_values[flag].to_s
      Cirno::Persistence.write_general_setting(flag, s)
    end
  end
  
  def update
    super
    if @index < config_count && config_data[@index][1] == :percentage
      update_lr_percentage
    end
    if @index < config_count && config_data[@index][1].is_a?(Array)
      update_lr_list
    end
  end
  
  def update_lr_percentage
    flag = config_data[@index][0]
    lrflag = false
    if Input.repeat?(:LEFT)
      lrflag = true
      @setting_values[flag] -= 5 if @setting_values[flag] > 0
      refresh
    elsif Input.repeat?(:RIGHT)
      @setting_values[flag] += 5 if @setting_values[flag] < 100
      lrflag = true
      refresh
    end
    if lrflag
      apply_audio_change
    end
  end
  
  def apply_audio_change
    Audio.master_volume_music = @setting_values["Music Volume"]
    Audio.master_volume_sound = @setting_values["Sound Volume"]
  end
  
  def update_lr_list
    lrflag = false
    flag = config_data[@index][0]
    type = config_data[@index][1]
    if Input.repeat?(:LEFT)
      lrflag = true
      @setting_values[flag] = (@setting_values[flag] - 1) % type.length
    elsif Input.repeat?(:RIGHT)
      lrflag = true
      @setting_values[flag] = (@setting_values[flag] + 1) % type.length
    end
    if lrflag
      if flag == "Window Resize"
        t = @setting_values[flag] + 1
        Graphics.resize_window(Graphics.width * t, Graphics.height * t)
      end
      refresh
    end
  end
  
  def config_data
    Cirno::Persistence.general_settings
  end
  
  def default_settings
    Cirno::Persistence.general_setting_default_values
  end
  
  def col_max
    return 1
  end
  
  def item_max
    config_count + 2
  end
  
  def config_count
    config_data.size
  end
  
  def draw_item(index)
    rect = item_rect_for_text(index)
    if index == item_max - 2
      draw_text(rect, Cirno::ConfigSettings::GENERAL_SETTING_CONFIRM)
      return
    elsif index == item_max - 1
      draw_text(rect, Cirno::ConfigSettings::GENERAL_SETTING_RESET)
      return
    end
    
    flag = config_data[index][0]
    type = config_data[index][1]
    desc = Cirno::ConfigSettings::GENERAL_SETTING_NAMES[flag]
    value = @setting_values[flag]
    
    change_color(system_color)
    draw_text(rect, desc, 0)
    change_color(normal_color)
    if type == :percentage
      draw_text(rect, "#{value}%", 2)
    elsif type == :bool
      draw_text(rect, value ? 
        Cirno::ConfigSettings::GENERAL_SETTING_ON : 
        Cirno::ConfigSettings::GENERAL_SETTING_OFF, 2)
    elsif type.is_a?(Array)
      draw_text(rect, type[value].to_s, 2)
    else
      draw_text(rect, value.to_s, 2)
    end
  end
  
  def on_select
    if index == item_max - 2
      # save changes
      save_settings
      Cirno::Persistence.apply_general_settings
      call_cancel_handler
      return
    elsif index == item_max - 1
      # reset
      setup_settings(true)
      save_settings
      Cirno::Persistence.apply_general_settings
      refresh
      activate
      return
    end
    
    flag = config_data[index][0]
    type = config_data[index][1]
    if type == :bool
      @setting_values[flag] = !@setting_values[flag]
      if flag == "Run in Fullscreen"
        Graphics.fullscreen = @setting_values[flag]
      elsif flag == "Enable VSync"
        Graphics.vsync = @setting_values[flag]
      end
      refresh
    elsif type == :percentage
      @setting_values_old ||= {}
      if @setting_values_old.has_key?(flag)
        @setting_values[flag] = @setting_values_old[flag]
        @setting_values_old.delete(flag)
      else
        @setting_values_old[flag] = @setting_values[flag]
        @setting_values[flag] = 0
      end
      apply_audio_change
      refresh
    elsif type.is_a?(Array)
      @setting_values[flag] = (@setting_values[flag] + 1) % type.length
      if flag == "Window Resize"
        t = @setting_values[flag] + 1
        Graphics.resize_window(Graphics.width * t, Graphics.height * t)
      end
      refresh
    end
    activate
  end
  
  def process_cancel
    Sound.play_cancel
    Input.update
    deactivate
    save_settings
    call_cancel_handler
  end
end

class Window_ConfigKeys < Window_Selectable
  def initialize(w, h)
    super((Graphics.width - w) / 2, Graphics.height - h, w, h)
    select(0)
    set_handler(:ok, method(:on_select))
    @waiting = false
    @key_waiting = false
    
    ww = Graphics.width
    wh = 64
    wx = (Graphics.width - ww) / 2
    wy = (Graphics.height - wh) / 2
    @waiting_window = Window_Base.new(wx, wy, ww, wh)
    @waiting_window.visible = false
    
    @button_data = {}
    for flag in setting_keys
      key_data = []
      keys = Input.get_keys_from_flag(flag)
      for i in 0 ... key_options
        if keys[i]
          key_data << keys[i]
        end
      end
      @button_data[flag] = key_data
    end
    
    refresh
  end
  
  def wait_for_input(message)
    deactivate
    @waiting = true
    @waiting_window.visible = true
    @waiting_window.contents.clear
    @waiting_window.contents.draw_text(0, 0, 
    @waiting_window.contents_width, @waiting_window.contents_height,
      message, 1)
  end
  
  def dispose
    @waiting_window.dispose
    super
  end
  
  def setting_keys
    Cirno::Persistence.keys
  end
  
  def key_options
    Cirno::ConfigSettings::KEY_COLUMNS
  end
  
  def item_width
    iw = super
    iw -= 48
    iw
  end
  
  def item_rect(index)
    rect = super
    rect.x += 128
    #rect.y += 32
    rect.y += 8
    rect.width += 24
    rect
  end
  
  def update_padding_bottom
    #surplus = (height - standard_padding * 2) % item_height
    #self.padding_bottom = padding + surplus
    self.padding_bottom = 0
  end
  
  def contents_height
    height - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return key_options
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    setting_keys.size * key_options + 3
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    @waiting_window.z = self.z + 1
    if @waiting == true
      rt = Input.recent_triggered
      if rt != 0
        @waiting = false
        if @key_waiting
          @key_waiting = false
          key = setting_keys[index / key_options]
          @button_data[key][index % key_options] = rt
          for i in 0 ... (key_options * setting_keys.size)
            ikey = setting_keys[i / key_options]
            if i != @index && @button_data[ikey][i % key_options] == rt
              @button_data[ikey][i % key_options] = nil
            end
          end
        end
        refresh
        @waiting_window.visible = false
        activate
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.font.size = 18
    super
    
    change_color(system_color)
    
    #for i in 0 ... key_options
    #  rect = item_rect(i)
    #  rect.x += 4
    #  rect.y -= (item_height + 4)
    #  draw_text(rect, "Key" + (i+1).to_s)
    #end
    
    text_left = setting_keys.map { |kf| Cirno::ConfigSettings::KEY_NAMES[kf] }
    for i in 0 ... text_left.length
      rect = item_rect(i * key_options)
      rect.width += 48
      rect.x -= (rect.width + 8)
      draw_text(rect, text_left[i], 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    if index == item_max - 3
      change_color(normal_color)
      text = Cirno::ConfigSettings::KEY_TEXT_CONFIRM
    elsif index == item_max - 2
      change_color(normal_color)
      text = Cirno::ConfigSettings::KEY_TEXT_CANCEL
    elsif index == item_max - 1
      change_color(normal_color)
      text = Cirno::ConfigSettings::KEY_TEXT_RESET
    else
      keyflag = setting_keys[index / key_options]
      key = @button_data[keyflag][index % key_options]
      if key
        change_color(normal_color)
        text = Input.get_key_name(key)
      else
        change_color(normal_color, false)
        text = Cirno::ConfigSettings::KEY_TEXT_UNASSIGNED
      end
    end
    draw_text(item_rect_for_text(index), text)
  end
  
  def on_select
    if @index == item_max - 3
      # OK
      for i in 0 ... setting_keys.length
        key = setting_keys[i]
        arr = @button_data[key].reject { |e| !e }
        if arr.empty?
          msg = sprintf(Cirno::ConfigSettings::KEY_MESSAGE_NOT_SET, 
            Cirno::ConfigSettings::KEY_NAMES[setting_keys[i]])
          wait_for_input(msg)
          return
        end
      end
      save_config
      call_cancel_handler
    elsif @index == item_max - 2
      # Cancel
      call_cancel_handler
    elsif @index == item_max - 1
      # Reset
      @button_data = Cirno::Persistence.default_key_mapping
      refresh
      activate
    else
      Input.update
      @key_waiting = true
      msg = sprintf(Cirno::ConfigSettings::KEY_MESSAGE_ANY_KEY,
        Cirno::ConfigSettings::KEY_NAMES[setting_keys[@index / key_options]])
      wait_for_input(msg)
      refresh
    end
  end
  
  def save_config
    for i in 0 ... setting_keys.size
      data = []
      key = setting_keys[i]
      for op in 0 ... key_options
        if @button_data[key][op]
          data << @button_data[key][op]
        end
      end
      Input.set_keys_from_flag(setting_keys[i], data)
    end
    Cirno::Persistence.write_keyboard_settings
  end
end

class Scene_Config < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    create_windows
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    #$game_map.refresh
  end
  #--------------------------------------------------------------------------
  # * Create Left Window
  #--------------------------------------------------------------------------
  def create_windows
    @command_window = Window_ConfigCommand.new
    @command_window.set_handler(:general, method(:on_general))
    @command_window.set_handler(:controls, method(:on_key))
    @command_window.set_handler(:cancel, method(:return_scene))
    @command_window.activate
  end
  
  def create_general_window
    @general_window = Window_ConfigGeneral.new(
      Graphics.width,
      Graphics.height - @command_window.height)
    @general_window.set_handler(:cancel, method(:on_general_return))
    @general_window.visible = false
  end
  
  def create_key_window
    @key_window = Window_ConfigKeys.new(
      Graphics.width,
      Graphics.height - @command_window.height)
    @key_window.set_handler(:cancel, method(:on_key_return))
    @key_window.visible = false
  end
  
  def on_general
    create_general_window
    @command_window.deactivate
    @general_window.activate
    @general_window.visible = true
  end
  
  def on_general_return
    @general_window.deactivate
    @general_window.visible = false
    @general_window = nil
    @command_window.activate
  end
  
  def on_key
    create_key_window
    @command_window.deactivate
    @key_window.activate
    @key_window.visible = true
  end
  
  def on_key_return
    @key_window.deactivate
    @key_window.visible = false
    @key_window = nil
    @command_window.activate
  end
end

class Scene_Map
  alias cirno_20181211_update_scene update_scene
  def update_scene
    cirno_20181211_update_scene
    update_call_config unless scene_changing?
  end
  
  def update_call_config
    SceneManager.call(Scene_Config) if Input.press?(:F1)
  end
end


# =======================================
# Initialize settings when game starts
# =======================================
Cirno::Persistence.apply_general_settings
Cirno::Persistence.read_keyboard_settings
# =======================================