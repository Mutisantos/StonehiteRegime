#--------------------------------------------------------------------------
# RGD F1 游戏设置
# F1 Game Config for RGD
#--------------------------------------------------------------------------
# 作者 author: invwindy
# 联系方式 contact me: cirno@live.cn
# 此脚本可被自由使用于商业和非商业游戏中。
# This script can be used freely in commercial and non-commercial games.
#--------------------------------------------------------------------------
# 此脚本用来代替 RGSS3 的 F1 设置。
# 插入此脚本后，在地图界面按下 F1，可以打开设置界面。
# 也可以通过修改脚本代码，把对应的场景插入到标题或菜单中，定制成游戏
# 需要的特定风格。
# This script is intended for replacing F1 config in RGSS3.
# Press F1 on map to enter game config scene after inserting this script.
# Modify script code and insert this scene into title or menu to fit specific
# game design styles.
#--------------------------------------------------------------------------
module Cirno
  #--------------------------------------------------------------------------
  # 用语设置
  # Term settings
  #--------------------------------------------------------------------------
  module ConfigSettings
    #--------------------------------------------------------------------------
    # 语言标记，用来选择下列语言设置中的一组。
    # Language flag. Used for selecting one from several term groups below.
    #--------------------------------------------------------------------------
    LANG = "EN"
    #--------------------------------------------------------------------------
    # 中文界面用语
    #--------------------------------------------------------------------------
    if LANG == "CH"
      CHOICE_GENERAL_SETTING = "基本设置"
      CHOICE_KEY_SETTING = "按键设置"

      GENERAL_SETTING_NAMES = {
        "Run in Fullscreen" => "全屏运行",
        "Enable VSync" => "垂直同步",
        "Window Resize" => "窗口缩放",
        "Music Volume" => "音乐音量",
        "Sound Volume" => "声效音量",
      }
      GENERAL_SETTING_CONFIRM = "保存"
      GENERAL_SETTING_RESET = "重置"
      GENERAL_SETTING_ON = "开启"
      GENERAL_SETTING_OFF = "关闭"

      KEY_NAMES = {
        "Up" => "上",
        "Down" => "下",
        "Left" => "左",
        "Right" => "右",
        "A" => "加速",
        "B" => "取消/菜单",
        "C" => "确认/对话",
        "X" => "功能键X",
        "Y" => "功能键Y",
        "Z" => "功能键Z",
        "L" => "前页",
        "R" => "后页",
      }
      KEY_TEXT_UNASSIGNED = "[无]"
      KEY_TEXT_CONFIRM = "保存"
      KEY_TEXT_CANCEL = "取消"
      KEY_TEXT_RESET = "重置"
      KEY_MESSAGE_NOT_SET = "按键【%s】尚未设置。"
      KEY_MESSAGE_ANY_KEY = "请按任意键设置【%s】。"

      #--------------------------------------------------------------------------
      # Interface Terms in English
      #--------------------------------------------------------------------------
    elsif LANG == :English || LANG == "EN" || LANG == "English"
      CHOICE_GENERAL_SETTING = "General Settings"
      CHOICE_KEY_SETTING = "Input Settings"

      GENERAL_SETTING_NAMES = {
        "Run in Fullscreen" => "Run in Fullscreen",
        "Enable VSync" => "Enable VSync",
        "Window Resize" => "Window Resize",
        "Music Volume" => "Music Volume",
        "Sound Volume" => "Sound Volume",
        "Language" => "Language",
      }
      GENERAL_SETTING_CONFIRM = "Save"
      GENERAL_SETTING_RESET = "Reset"
      GENERAL_SETTING_ON = "ON"
      GENERAL_SETTING_OFF = "OFF"

      KEY_NAMES = {
        "Up" => "Up",
        "Down" => "Down",
        "Left" => "Left",
        "Right" => "Right",
        "A" => "Dash",
        "B" => "Cancel/Menu",
        "C" => "Confirm/Talk",
        "X" => "Key X",
        "Y" => "Key Y",
        "Z" => "Key Z",
        "L" => "Prev Page",
        "R" => "Next Page",
      }
      KEY_TEXT_UNASSIGNED = "[--]" # Say [--] because [unassigned] is complicated enough.
      KEY_TEXT_CONFIRM = "Save"
      KEY_TEXT_CANCEL = "Cancel"
      KEY_TEXT_RESET = "Reset"
      KEY_MESSAGE_NOT_SET = "No key is assigned to [%s]."
      KEY_MESSAGE_ANY_KEY = "Press any key to setup [%s]."
      #--------------------------------------------------------------------------
      # Interface Terms in Spanish
      #--------------------------------------------------------------------------
    elsif LANG == :Spanish || LANG == "ES" || LANG == "Spanish"
      CHOICE_GENERAL_SETTING = "Config. General"
      CHOICE_KEY_SETTING = "Config. de Entrada"

      GENERAL_SETTING_NAMES = {
        "Run in Fullscreen" => "Pantalla Completa",
        "Enable VSync" => "Habilitar VSync",
        "Window Resize" => "Tamaño de Ventana",
        "Music Volume" => "Volumen de Música",
        "Sound Volume" => "Volumen de Efectos",
        "Language" => "Idioma",
      }
      GENERAL_SETTING_CONFIRM = "Guardar"
      GENERAL_SETTING_RESET = "Reiniciar"
      GENERAL_SETTING_ON = "ON"
      GENERAL_SETTING_OFF = "OFF"

      KEY_NAMES = {
        "Up" => "Arriba",
        "Down" => "Abajo",
        "Left" => "Izquierda",
        "Right" => "Derecha",
        "A" => "Correr",
        "B" => "Cancelar/Menu",
        "C" => "Acción",
        "X" => "Boton X",
        "Y" => "Boton Y",
        "Z" => "Boton Z",
        "L" => "Pag. Anterior",
        "R" => "Pag. Siguiente",
      }
      KEY_TEXT_UNASSIGNED = "[--]" # Say [--] because [unassigned] is complicated enough.
      KEY_TEXT_CONFIRM = "Guardar"
      KEY_TEXT_CANCEL = "Cancelar"
      KEY_TEXT_RESET = "Reiniciar"
      KEY_MESSAGE_NOT_SET = "No hay entrada asignada para [%s]."
      KEY_MESSAGE_ANY_KEY = "Presiona botón/tecla para asignar [%s]."
    else
      p (LANG)
    end
    #--------------------------------------------------------------------------
    # 同一个按键的选项数量
    # Option columns for one key
    #--------------------------------------------------------------------------
    KEY_COLUMNS = 4
  end

  module Persistence
    #--------------------------------------------------------------------------
    # 基本设置的选项。
    # 可以加注释符号#以隐藏。
    # 但如果需要添加选项，需要同时修改代码其他地方来实现这个选项。
    # Options in general settings.
    # Add comment symbol # on setting lines to hide.
    # If a new option is added, some modifications on the script is needed for
    # implementing this option.
    #--------------------------------------------------------------------------
    def self.general_settings
      [
        ["Run in Fullscreen", :bool],
        ["Enable VSync", :bool],
        ["Window Resize", ["1x", "2x", "3x", "4x"]],
        ["Music Volume", :percentage],
        ["Sound Volume", :percentage],
        ["Language", ["English", "Spanish"]], 
      ]
    end
    #--------------------------------------------------------------------------
    # 基本选项的默认值。
    # Default value of options in general settings.
    #--------------------------------------------------------------------------
    def self.general_setting_default_values
      {
        "Run in Fullscreen" => false,
        "Enable VSync" => true,
        "Window Resize" => 1,
        "Music Volume" => 100,
        "Sound Volume" => 100,
        "Language" => "Spanish", # Default language
      }
    end
    #--------------------------------------------------------------------------
    # 按键设置中的按键列表。
    # 可以去除其中一部分，或调整次序，这些修改会同时影响界面。
    # Key list in input settings.
    # Removing some keys or adjusting their order will also alter
    # the interface.
    #--------------------------------------------------------------------------
    def self.keys
      ["Up", "Down", "Left", "Right", "C", "B", "A", "X", "Y", "Z", "L", "R"]
    end
    #--------------------------------------------------------------------------
    # 默认按键映射。
    # 右侧数字为 Windows 按键代码，代表键盘上的按键。
    # 详情：https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes
    # Default key mapping.
    # Numbers to the right are Windows key codes, corresponding key buttons
    # on the keyboard.
    # For more detail: https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes
    #--------------------------------------------------------------------------
    def self.default_key_mapping
      {
        "Up" => [38],
        "Down" => [40],
        "Left" => [37],
        "Right" => [39],
        "A" => [16],
        "B" => [27, 88],
        "C" => [13, 32, 67, 90],
        "X" => [65],
        "Y" => [83],
        "Z" => [68],
        "L" => [33, 81],
        "R" => [34, 87],
      }
    end
  end
end
