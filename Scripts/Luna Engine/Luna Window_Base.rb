#==============================================================================
# ■ Window_Base
#==============================================================================

class Window_Base < Window
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias luna_menu_mc_initialize initialize
  def initialize(x, y, width, height)
    luna_menu_mc_initialize(x, y, width, height)
    skin = setting_windowskin rescue nil
    return unless skin
    return unless setting[:back_type] == 0
    begin
      self.windowskin = Cache.system(skin)
    rescue
      if setting_type[:skin]
        self.windowskin = Cache.system(setting_type[:skin])
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_windowskin
  #--------------------------------------------------------------------------
  def setting_windowskin
    return nil unless setting[:background_variable]
    return nil unless setting[:background_variable] > 0
    return $game_variables[setting[:background_variable]]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_picture_background
  #--------------------------------------------------------------------------
  def setting_picture_background
    default = setting_type[:picture]
    return default unless setting[:background_variable]
    return default unless setting[:background_variable] > 0
    return $game_variables[setting[:background_variable]]
  end
  
  #--------------------------------------------------------------------------
  # new method: refresh_background
  #--------------------------------------------------------------------------
  def refresh_background
    bt = type rescue setting[:back_type]
    case bt
    when 0; refresh_type0
    when 1; refresh_type1
    when 2; refresh_type2
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: refresh_type0
  #--------------------------------------------------------------------------
  def refresh_type0
    # none
  end
  
  #--------------------------------------------------------------------------
  # new method: refresh_type1
  #--------------------------------------------------------------------------
  def refresh_type1
    return if @bg_sprite
    @bg_sprite = Sprite.new(nil)
    bitmap = Bitmap.new(window_width, window_height)
    color1 = setting_type[:color1]
    if color1.is_a?(String)
      color1 = eval(color1)
    else
      color1 = Color.new(color1[0], color1[1], color1[2], color1[3])
    end
    color2 = setting_type[:color2]
    if color2.is_a?(String)
      color2 = eval(color2)
    else
      color2 = Color.new(color2[0], color2[1], color2[2], color2[3])
    end
    bitmap.gradient_fill_rect(bitmap.rect, color1, color2, setting[:vertical])
    @bg_sprite.bitmap = bitmap
    @bg_sprite.opacity = 0
  end
  
  #--------------------------------------------------------------------------
  # new method: refresh_type2
  #--------------------------------------------------------------------------
  def refresh_type2
    return if @bg_sprite
    default = setting_type[:picture]
    bitmap  = setting_picture_background
    @bg_sprite = Sprite.new(nil)
    begin
      @bg_sprite.bitmap = Cache.system(bitmap)
    rescue
      @bg_sprite.bitmap = Cache.system(default)
    end
    @bg_sprite.opacity = 0
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias luna_menu_update_main update
  def update
    luna_menu_update_main
    update_type
  end
  
  #--------------------------------------------------------------------------
  # new method: update_type
  #--------------------------------------------------------------------------
  def update_type
    bt = type rescue setting[:back_type] rescue nil
    return unless bt
    case bt
    when 0; update_type0
    when 1; update_type1
    when 2; update_type2
    end  
  end
  
  #--------------------------------------------------------------------------
  # new method: update_type0
  #--------------------------------------------------------------------------
  def update_type0
    self.opacity = setting_type[:opacity]
  end
  
  #--------------------------------------------------------------------------
  # new method: update_type1
  #--------------------------------------------------------------------------
  def update_type1
    return unless @bg_sprite
    @bg_sprite.update
    @bg_sprite.x = self.x
    @bg_sprite.y = self.y
    @bg_sprite.z = self.z - 1
    @bg_sprite.opacity = self.openness
    @bg_sprite.visible = self.visible
    @bg_sprite.viewport = self.viewport
    self.opacity = 0
  end
  
  #--------------------------------------------------------------------------
  # new method: update_type2
  #--------------------------------------------------------------------------
  def update_type2
    return unless @bg_sprite
    @bg_sprite.update
    @bg_sprite.x = self.x + setting_type[:offset_x]
    @bg_sprite.y = self.y + setting_type[:offset_y]
    @bg_sprite.z = self.z - 1
    stop = setting_type[:opacity]
    @bg_sprite.opacity = [stop, self.openness].min
    @bg_sprite.visible = self.visible
    @bg_sprite.viewport = self.viewport
    self.opacity = 0
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_lunatic
  #--------------------------------------------------------------------------
  def draw_lunatic(hash, import = {}, x = 0, y = 0)
    return unless hash
    text  = hash[0].to_s rescue ""
    pos   = hash[1]
    pos[0] += x
    pos[1] += y
    align = hash[2] || [0, 0]
    color = hash[3]
    font  = hash[4] || ["", 0]
    outline = hash[5] || [0, 0, 0, 128]
    height = [line_height, font[1]].max
    #align[0] = [align[0], rect.width].min if align.is_a?(Array)
    if text =~ /\$bitmap\[(.*)\]/i
      value = $1.scan(/[^, ]+[^,]*/i)
      bitmap = Cache.cache_extended(value[0], value[1])
      opacity = align.is_a?(Array) ? 255 : align
      bw = bitmap.width; bh = bitmap.height
      rect = color.nil? ? bitmap.rect.clone : Rect.new(eval(color[0].to_s), eval(color[1].to_s), eval(color[2].to_s), eval(color[3].to_s))
      contents.blt(pos[0], pos[1], bitmap, rect, opacity)
    elsif text =~ /\$icon\[(\d+)\]/i
      draw_icon($1.to_i, pos[0], pos[1], align)
    elsif text =~ /\$color\[(.*)\]/i
      value = $1.scan(/\d+/)
      value.collect! { |i| i.to_i }
      opacity = align.is_a?(Array) ? 255 : align
      if color[0] < 1 || color[1] < 1
        # do nothing
      else
        cache = Bitmap.new(color[0], color[1])
        cache.fill_rect(cache.rect, Color.new(value[0], value[1], value[2]))
        contents.blt(pos[0], pos[1], cache, cache.rect.clone, opacity)
      end
    elsif text =~ /\$(.*)grad\[(.*)\]/i
      vertical = $1.downcase == "hor" ? false : true
      value = $2.scan(/\d+/)
      value.collect! { |i| i.to_i }
      opacity = align.is_a?(Array) ? 255 : align
      color1 = Color.new(value[0], value[1], value[2])
      color2 = Color.new(value[3], value[4], value[5])
      if color[0] < 1 || color[1] < 1
        # do nothing
      else
        cache = Bitmap.new(color[0], color[1]) 
        cache.gradient_fill_rect(cache.rect, color1, color2, vertical) 
        contents.blt(pos[0], pos[1], cache, cache.rect.clone, opacity)
      end
    else
      if import[text.upcase]
        import[text.upcase].each do |hash|
          draw_lunatic(hash, import, pos[0], pos[1])
        end
      else
        contents.font.name = font[0] ? font[0] : Font.default_name
        contents.font.size = font[1] ? font[1] : Font.default_size
        contents.font.bold = font[2] ? font[2] : Font.default_bold
        contents.font.italic = font[3] ? font[3] : Font.default_italic
        contents.font.color = Color.new(color[0], color[1], color[2], color[3] || 255)
        contents.font.outline = color[4].nil? ? true : color[4]
        contents.font.out_color = Color.new(outline[0], outline[1], outline[2], outline[3] || 128)
        draw_text_luna(pos[0], pos[1], align[0], height, text, align[1])
#~         draw_text_ex(pos[0], pos[1], text)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_text_luna
  #--------------------------------------------------------------------------
  def draw_text_luna(x, y, width, height, text, align = 0)
    # y buffer
    y = y + (height - contents.font.size) / 2
    
    # x buffer
    case align
    when 1
      x = x + (width - text_size(text).width) / 2
    when 2
      x = x + width - text_size(text).width
    end
    
    draw_text_ex_luna(x, y, text)
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_text_ex_luna
  #--------------------------------------------------------------------------
  def draw_text_ex_luna(x, y, text)
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  
  #--------------------------------------------------------------------------
  # alias method: show
  #--------------------------------------------------------------------------
  alias luna_menu_show show
  def show
    w = luna_menu_show
    update_type
    w
  end
  
  #--------------------------------------------------------------------------
  # alias method: hide
  #--------------------------------------------------------------------------
  alias luna_menu_hide hide
  def hide
    w = luna_menu_hide
    update_type
    w
  end
  
  #--------------------------------------------------------------------------
  # new method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max rescue 0
  end
  
  #--------------------------------------------------------------------------
  # new method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max rescue 0
  end
  
  #--------------------------------------------------------------------------
  # alias method: standard_padding
  #--------------------------------------------------------------------------
  alias luna_engine_standard_padding standard_padding
  def standard_padding
    begin
      [setting[:padding], 0].max
    rescue
      luna_engine_standard_padding
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    eval(setting[:x].to_s) rescue 0
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s) rescue 0
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s) rescue 0
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    eval(setting[:x].to_s) rescue 0
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    eval(setting[:y].to_s) rescue 0
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    eval(setting[:z].to_s) rescue 0
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    nil
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")] rescue nil
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts
    nil
  end
  
end # Window_Base

#==============================================================================
# ■ Window_Selectable
#==============================================================================

class Window_Selectable < Window_Base
  
  #--------------------------------------------------------------------------
  # alias method: item_height
  #--------------------------------------------------------------------------
  alias luna_engine_item_height item_height
  def item_height
    begin
      [line_height, setting[:item_height]].max
    rescue
      luna_engine_item_height
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: col_max
  #--------------------------------------------------------------------------
  alias luna_engine_col_max col_max
  def col_max
    begin
      [1, setting[:column]].max
    rescue
      luna_engine_col_max
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias luna_engine_update_cursor update_cursor
  def update_cursor
    begin
      if !SceneManager.scene_is?(Scene_Battle)
        setting[:cursor] ? luna_engine_update_cursor : do_luna_update_cursor
      else 
        setting[:cursor] ? do_luna_update_cursor : luna_engine_update_cursor
      end     
    rescue
      luna_engine_update_cursor
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: do_luna_update_cursor
  #--------------------------------------------------------------------------
  def do_luna_update_cursor
    cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
#~   def process_cursor_move
#~     return unless cursor_movable?
#~     last_index = @index
#~     cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
#~     cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
#~     cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
#~     cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
#~     cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
#~     cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
#~     Sound.play_cursor if @index != last_index
#~     return if @index == last_index
#~     draw_item(last_index)
#~     draw_item(@index)
#~   end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
#~   def index=(index)
#~     draw_item(@index) if @index >= 0
#~     @index = index
#~     draw_item(@index) if @index >= 0
#~     update_cursor
#~     call_update_help
#~   end
  
  #--------------------------------------------------------------------------
  # alias method: item_rect
  #--------------------------------------------------------------------------
#~   alias luna_engine_item_rect item_rect
#~   def item_rect(index)
#~     begin
#~       return luna_engine_item_rect(index) unless setting[:item_rect][:custom]
#~     rescue
#~       return luna_engine_item_rect(index)
#~     end
#~     rect = Rect.new
#~     item_width = setting[:item_rect][:width]
#~     item_height = setting[:item_rect][:height]
#~     spacing_ver = setting[:item_rect][:spacing_ver]
#~     spacing_hor = setting[:item_rect][:spacing_hor]
#~     rect.width = item_width
#~     rect.height = item_height
#~     rect.x = index % col_max * (item_width + spacing_hor)
#~     rect.y = index / col_max * (item_height + spacing_ver)
#~     rect
#~   end
  
end # Window_Selectable

#==============================================================================
# ■ Window_Command
#==============================================================================

class Window_Command < Window_Selectable
  
  #--------------------------------------------------------------------------
  # alias method: window_width
  #--------------------------------------------------------------------------
  alias luna_engine_window_width window_width
  def window_width
    begin
      [setting[:width], standard_padding * 2 + line_height].max
    rescue
      luna_engine_window_width
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: window_height
  #--------------------------------------------------------------------------
  alias luna_engine_window_height window_height
  def window_height
    begin
      [setting[:height], standard_padding * 2 + line_height].max
    rescue
      luna_engine_window_height
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: alignment
  #--------------------------------------------------------------------------
  alias luna_engine_alignment alignment
  def alignment
    begin
      setting[:align]
    rescue
      luna_engine_alignment
    end
  end
  
end # Window_Command

#==============================================================================
# ■ Window_HorzCommand
#==============================================================================

class Window_HorzCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # alias method: alignment
  #--------------------------------------------------------------------------
  alias luna_engine_alignment alignment
  def alignment
    begin
      setting[:align]
    rescue
      luna_engine_alignment
    end
  end
  
end # Window_HorzCommand