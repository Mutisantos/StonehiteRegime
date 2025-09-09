#--------------------------------------------------------------------------
# author: mutisantos
# This script can be used freely in commercial and non-commercial games.
#--------------------------------------------------------------------------
# This scripts override the current Title scene menu to add "Settings" option
# This option will call the Config scene created by the "Config Window Settings" script
# Requires: "Config Window Settings" script by invwindy
#--------------------------------------------------------------------------
$imported = {} if $imported.nil?
$imported["ConfigTitleWindow"] = true

module Cirno
  #--------------------------------------------------------------------------
  # Title settings
  #--------------------------------------------------------------------------
  module TitleSettings
    #--------------------------------------------------------------------------
    # Flag to enable/disable the "Settings" option in the title menu
    #--------------------------------------------------------------------------
    SETTINGS_LABEL = "Settings"
    CONTROLS_LABEL = "Controles"
  end
end

class Scene_Title < Scene_Base
  alias cirno_orig_create_command_window create_command_window
  def create_command_window
    cirno_orig_create_command_window
    @command_window.x = YEA::CORE::RESIZE_WIDTH/2 - @command_window.window_width/2
    @command_window.y = 20
    @command_window.set_handler(:settings, method(:command_settings))
    @command_window.set_handler(:controls, method(:controls_settings))
  end

  def command_settings
    close_command_window if respond_to?(:close_command_window)
    SceneManager.call(Scene_System)
  end

  def controls_settings
    close_command_window if respond_to?(:close_command_window)
    SceneManager.call(Scene_Config)
  end
end

class Window_TitleCommand < Window_Command
  alias cirno_make_command_list make_command_list
  def make_command_list
    cirno_make_command_list
    add_command(Cirno::TitleSettings::SETTINGS_LABEL, :settings)
    add_command(Cirno::TitleSettings::CONTROLS_LABEL, :controls)
  end
end

