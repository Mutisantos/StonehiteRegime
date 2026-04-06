$imported = {} if $imported.nil?
$imported["YEL-MenuLuna"] = true

#==============================================================================
# ■ SpriteMenu_Main
#==============================================================================

class SpriteMenu_Main < Sprite_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset, setting)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @main = ""
    @highlight = 12
    @fade = 0
    @setting = setting
    init_visible
  end
  
  #--------------------------------------------------------------------------
  # init_visible
  #--------------------------------------------------------------------------
  def init_visible
    return unless setting[:collapse]
    if setting[:collapse_type] == 0
      self.opacity = @battler.dead? ? 0 : 255
    elsif setting[:collapse_type] == 1
      self.tone = @battler.dead? ? Tone.new(0, 0, 0, 255) : Tone.new(0, 0, 0, 0)
    end
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if main_change?
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
    #---
    update_highlight
    update_collapse
  end
  
  #--------------------------------------------------------------------------
  # update_highlight
  #--------------------------------------------------------------------------
  def update_highlight
    update_tone
    window = @spriteset.actor_window
    return unless window
    is_select = window.index == @battler.index || window.cursor_all
    return reset_tone if !window.active
    return reset_tone if !is_select
    return reset_tone unless setting[:highlight]
    @highlight = (@highlight + 1) % 24
    self.opacity = @battler.dead? ? 128 : 255
  end
  
  #--------------------------------------------------------------------------
  # update_tone
  #--------------------------------------------------------------------------
  def update_tone
    gray = self.tone.gray
    highlight = (12 - @highlight).abs * 3
    self.tone = Tone.new(highlight, highlight, highlight, gray)
  end
  
  #--------------------------------------------------------------------------
  # reset_tone
  #--------------------------------------------------------------------------
  def reset_tone
    gray = self.tone.gray
    self.tone = Tone.new(0, 0, 0, gray)
    init_visible
  end
  
  #--------------------------------------------------------------------------
  # update_collapse
  #--------------------------------------------------------------------------
  def update_collapse
    return unless setting[:collapse]
    rate = @battler.dead? ? 6 : -12
    if setting[:collapse_type] == 0
      @fade += rate
      @fade = 0 if @fade < 0
      @fade = 255 if @fade > 255
      #---
      self.blend_type = @battler.dead? ? 1 : 0
      if @battler.dead?
        self.color.set(255, 128, 128, 128)
      else
        self.color.set(0, 0, 0, 0)
      end
    elsif setting[:collapse_type] == 1
      gray = self.tone.gray
      self.tone.gray += rate
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    @main = real_name
    #---
    self.bitmap = Cache.system(@main)
  end
  
  #--------------------------------------------------------------------------
  # main_change?
  #--------------------------------------------------------------------------
  def main_change?
    @main != real_name
  end
  
  #--------------------------------------------------------------------------
  # main_change?
  #--------------------------------------------------------------------------
  def real_name
    result = setting[:filename]
    result += "_#{@battler.actor.id}" if setting[:base_actor]
    result += "_#{@battler.class.id}" if setting[:base_class]
    result
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    case @setting
    when :mainmenu
      MenuLuna::MainMenu::BATTLER_STATUS[:main]
    when :itemmenu
      MenuLuna::ItemMenu::BATTLER_STATUS[:main]
    when :skillmenu
      MenuLuna::SkillMenu::BATTLER_STATUS[:main]
    when :skillmenusub
      MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:main]
    else
      MenuLuna::MainMenu::BATTLER_STATUS[:main]
    end
  end
  
  #--------------------------------------------------------------------------
  # setting=
  #--------------------------------------------------------------------------
  def setting=(setting)
    @setting = setting
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity - @fade
  end
  
end # SpriteMenu_Main

#==============================================================================
# ■ SpriteMenu_Select
#==============================================================================

class SpriteMenu_Select < Sprite_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset, setting)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @select = ""
    @setting = setting
    @frame = 0
    @tick = self.setting[:fps]
    @sx = 0
    @sy = 0
  end
    
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if select_change?
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    #---
    update_visible
    update_frame
  end
  
  #--------------------------------------------------------------------------
  # update_visible
  #--------------------------------------------------------------------------
  def update_visible
    return reset_visible unless @spriteset.actor_window
    return reset_visible unless @spriteset.actor_window.active
    cursor = (@spriteset.actor_window.actor == @battler || @spriteset.actor_window.cursor_all)
    return reset_visible unless cursor
    self.visible = true
  end
  
  #--------------------------------------------------------------------------
  # update_frame
  #--------------------------------------------------------------------------
  def update_frame
    @tick -= 1
    return unless @tick <= 0
    @tick  = setting[:fps]
    @frame = (@frame + 1) % setting[:frame]
    self.src_rect.set(@frame * @sx, 0, @sx, @sy)
  end
  
  #--------------------------------------------------------------------------
  # reset_visible
  #--------------------------------------------------------------------------
  def reset_visible
    self.visible = false
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    @select = real_name
    #---
    self.bitmap = Cache.system(@select)
    #---
    @sx = self.bitmap.width / setting[:frame]
    @sy = self.bitmap.height
    #---
    self.src_rect.set(0, 0, @sx, @sy)
  end
  
  #--------------------------------------------------------------------------
  # select_change?
  #--------------------------------------------------------------------------
  def select_change?
    @select != real_name
  end
  
  #--------------------------------------------------------------------------
  # main_change?
  #--------------------------------------------------------------------------
  def real_name
    result = setting[:filename]
    result += "_#{@battler.actor.id}" if setting[:base_actor]
    result += "_#{@battler.class.id}" if setting[:base_class]
    result
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    case @setting
    when :mainmenu
      MenuLuna::MainMenu::BATTLER_STATUS[:select]
    when :itemmenu
      MenuLuna::ItemMenu::BATTLER_STATUS[:select]
    when :skillmenu
      MenuLuna::SkillMenu::BATTLER_STATUS[:select]
    else
      MenuLuna::MainMenu::BATTLER_STATUS[:select]
    end
  end
  
  #--------------------------------------------------------------------------
  # setting=
  #--------------------------------------------------------------------------
  def setting=(setting)
    @setting = setting
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
end # SpriteMenu_Select

#==============================================================================
# ■ SpriteMenu_Face
#==============================================================================

class SpriteMenu_Face < Sprite_Base
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset, setting)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @face = ["", 0]
    @highlight = 12
    @fade = 0
    @setting = setting
    init_visible
  end
  
  #--------------------------------------------------------------------------
  # init_visible
  #--------------------------------------------------------------------------
  def init_visible
    return unless setting[:collapse]
    if setting[:collapse_type] == 0
      self.opacity = @battler.dead? ? 0 : 255
    elsif setting[:collapse_type] == 1
      self.tone = @battler.dead? ? Tone.new(0, 0, 0, 255) : Tone.new(0, 0, 0, 0)
    end
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if face_change?
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
    #---
    update_highlight
    update_collapse
  end
  
  #--------------------------------------------------------------------------
  # update_highlight
  #--------------------------------------------------------------------------
  def update_highlight
    update_tone
    window = @spriteset.actor_window
    return unless window
    is_select = window.index == @battler.index || window.cursor_all
    return reset_tone if !window.active
    return reset_tone if !is_select
    return reset_tone unless setting[:highlight]
    @highlight = (@highlight + 1) % 24
    self.opacity = @battler.dead? ? 128 : 255
  end
  
  #--------------------------------------------------------------------------
  # update_tone
  #--------------------------------------------------------------------------
  def update_tone
    gray = self.tone.gray
    highlight = (12 - @highlight).abs * 3
    self.tone = Tone.new(highlight, highlight, highlight, gray)
  end
  
  #--------------------------------------------------------------------------
  # reset_tone
  #--------------------------------------------------------------------------
  def reset_tone
    gray = self.tone.gray
    self.tone = Tone.new(0, 0, 0, gray)
    init_visible
  end
  
  #--------------------------------------------------------------------------
  # update_collapse
  #--------------------------------------------------------------------------
  def update_collapse
    return unless setting[:collapse]
    rate = @battler.dead? ? 6 : -12
    if setting[:collapse_type] == 0
      @fade += rate
      @fade = 0 if @fade < 0
      @fade = 255 if @fade > 255
      #---
      self.blend_type = @battler.dead? ? 1 : 0
      if @battler.dead?
        self.color.set(255, 128, 128, 128)
      else
        self.color.set(0, 0, 0, 0)
      end
    elsif setting[:collapse_type] == 1
      gray = self.tone.gray
      self.tone.gray += rate
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    case setting[:type]
    when 0; refresh_type0
    when 1; refresh_type1
    when 2; refresh_type2
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh_type0
  #--------------------------------------------------------------------------
  def refresh_type0
    @face.clear
    @face = faceset_name
    face_name = @face[0]
    face_index = @face[1]
    #---
    bitmap = Bitmap.new(96, 96)
    face_bitmap = Cache.face(face_name)
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
    bitmap.blt(0, 0, face_bitmap, rect)
    face_bitmap.dispose
    #---
    self.bitmap.dispose if self.bitmap
    self.bitmap = bitmap
  end
  
  #--------------------------------------------------------------------------
  # refresh_type1
  #--------------------------------------------------------------------------
  def refresh_type1
    @face.clear
    @face = [real_name, 0]
    #---
    self.bitmap = Cache.face(real_name)
  end
  
  #--------------------------------------------------------------------------
  # refresh_type2
  #--------------------------------------------------------------------------
  def refresh_type2
    @face.clear
    @face = [@battler.face_name, @battler.face_index]
    #---
    self.bitmap = Cache.face(real_name)
  end
  
  #--------------------------------------------------------------------------
  # face_change?
  #--------------------------------------------------------------------------
  def face_change?
    case setting[:type]
    when 0
      return faceset_name != @face
    when 1
      return @face[0] != real_name
    when 2
      return @face[0] + "_" + @face[1].to_s != real_name
    end
  end
  
  #--------------------------------------------------------------------------
  # faceset_name
  #--------------------------------------------------------------------------
  def faceset_name
    [@battler.face_name, @battler.face_index]
  end
  
  #--------------------------------------------------------------------------
  # real_name
  #--------------------------------------------------------------------------
  def real_name
    result = ""
    if setting[:type] == 1
      result = setting[:type_1][:filename]
      result += "_#{@battler.actor.id}" if setting[:type_1][:base_actor]
      result += "_#{@battler.class.id}" if setting[:type_1][:base_class]
    elsif setting[:type] == 2
      result = "#{@battler.face_name}_#{@battler.face_index}"
    end
    result
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    case @setting
    when :mainmenu
      MenuLuna::MainMenu::BATTLER_STATUS[:face]
    when :itemmenu
      MenuLuna::ItemMenu::BATTLER_STATUS[:face]
    when :skillmenu
      MenuLuna::SkillMenu::BATTLER_STATUS[:face]
    when :skillmenusub
      MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:face]
    else
      MenuLuna::MainMenu::BATTLER_STATUS[:face]
    end
  end
  
  #--------------------------------------------------------------------------
  # setting=
  #--------------------------------------------------------------------------
  def setting=(setting)
    @setting = setting
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity - @fade
  end
  
  #--------------------------------------------------------------------------
  # highlight_time
  #--------------------------------------------------------------------------
  def highlight_time
    45
  end
  
  #--------------------------------------------------------------------------
  # highlight_rate
  #--------------------------------------------------------------------------
  def highlight_rate
    60
  end
  
end # SpriteMenu_Face

#==============================================================================
# ■ SpriteMenu_Name
#==============================================================================

class SpriteMenu_Name < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset, setting)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @name = ""
    @setting = setting
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if name_change?
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    color = setting[:color]
    out = setting[:outline]
    @name = @battler.name
    #---
    bitmap = Bitmap.new(setting[:width], setting[:height])
    bitmap.font.name = setting[:font]
    bitmap.font.size = setting[:size]
    bitmap.font.bold = setting[:bold]
    bitmap.font.italic = setting[:italic]
    if color.is_a?(String)
      bitmap.font.color = eval(color)
    else
      bitmap.font.color = Color.new(color[0], color[1], color[2], color[3])
    end
    if out.is_a?(String)
      bitmap.font.out_color = eval(out)
    else
      bitmap.font.out_color = Color.new(out[0], out[1], out[2], out[3])
    end
    bitmap.draw_text(0, 0, bitmap.width, bitmap.height, @name, setting[:align])
    #---
    self.bitmap.dispose if self.bitmap
    self.bitmap = bitmap
  end
  
  #--------------------------------------------------------------------------
  # name_change?
  #--------------------------------------------------------------------------
  def name_change?
    @name != @battler.name
  end
    
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    case @setting
    when :mainmenu
      MenuLuna::MainMenu::BATTLER_STATUS[:name]
    when :itemmenu
      MenuLuna::ItemMenu::BATTLER_STATUS[:name]
    when :skillmenu
      MenuLuna::SkillMenu::BATTLER_STATUS[:name]
    when :skillmenusub
      MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:name]
    else
      MenuLuna::MainMenu::BATTLER_STATUS[:name]
    end
  end
  
  #--------------------------------------------------------------------------
  # setting=
  #--------------------------------------------------------------------------
  def setting=(setting)
    @setting = setting
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
end # SpriteMenu_Name

#==============================================================================
# ■ SpriteMenu_Level
#==============================================================================

class SpriteMenu_Level < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset, setting)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @level = 0
    @setting = setting
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if level_change?
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    color = setting[:color]
    out = setting[:outline]
    @level = @battler.level
    #---
    text = setting[:vocab]
    text = sprintf(text, @level)
    bitmap = Bitmap.new(setting[:width], setting[:height])
    bitmap.font.name = setting[:font]
    bitmap.font.size = setting[:size]
    bitmap.font.bold = setting[:bold]
    bitmap.font.italic = setting[:italic]
    if color.is_a?(String)
      bitmap.font.color = eval(color)
    else
      bitmap.font.color = Color.new(color[0], color[1], color[2], color[3])
    end
    if out.is_a?(String)
      bitmap.font.out_color = eval(out)
    else
      bitmap.font.out_color = Color.new(out[0], out[1], out[2], out[3])
    end
    #bitmap.draw_text(0, 0, bitmap.width, bitmap.height, text, setting[:align])
    #---
    self.bitmap.dispose if self.bitmap
    self.bitmap = bitmap
    draw_text_ex(0, 0, text)
  end
  
  #--------------------------------------------------------------------------
  # level_change?
  #--------------------------------------------------------------------------
  def level_change?
    @level != @battler.level
  end
    
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    case @setting
    when :mainmenu
      MenuLuna::MainMenu::BATTLER_STATUS[:level]
    when :itemmenu
      MenuLuna::ItemMenu::BATTLER_STATUS[:level]
    when :skillmenu
      MenuLuna::SkillMenu::BATTLER_STATUS[:level]
    when :skillmenusub
      MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:level]
    else
      MenuLuna::MainMenu::BATTLER_STATUS[:level]
    end
  end
  
  #--------------------------------------------------------------------------
  # setting=
  #--------------------------------------------------------------------------
  def setting=(setting)
    @setting = setting
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
end # SpriteMenu_Level

#==============================================================================
# ■ SpriteMenu_Class
#==============================================================================

class SpriteMenu_Class < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset, setting)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @class = ""
    @setting = setting
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if class_change?
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    color = setting[:color]
    out = setting[:outline]
    @class = @battler.class.name
    #---
    text = setting[:vocab]
    text = sprintf(text, @class)
    bitmap = Bitmap.new(setting[:width], setting[:height])
    bitmap.font.name = setting[:font]
    bitmap.font.size = setting[:size]
    bitmap.font.bold = setting[:bold]
    bitmap.font.italic = setting[:italic]
    if color.is_a?(String)
      bitmap.font.color = eval(color)
    else
      bitmap.font.color = Color.new(color[0], color[1], color[2], color[3])
    end
    if out.is_a?(String)
      bitmap.font.out_color = eval(out)
    else
      bitmap.font.out_color = Color.new(out[0], out[1], out[2], out[3])
    end
    #bitmap.draw_text(0, 0, bitmap.width, bitmap.height, text, setting[:align])
    #---
    self.bitmap.dispose if self.bitmap
    self.bitmap = bitmap
    draw_text_ex(0, 0, text)
  end
  
  #--------------------------------------------------------------------------
  # level_change?
  #--------------------------------------------------------------------------
  def class_change?
    @class != @battler.class.name
  end
    
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    case @setting
    when :mainmenu
      MenuLuna::MainMenu::BATTLER_STATUS[:class]
    when :itemmenu
      MenuLuna::ItemMenu::BATTLER_STATUS[:class]
    when :skillmenu
      MenuLuna::SkillMenu::BATTLER_STATUS[:class]
    when :skillmenusub
      MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:class]
    else
      MenuLuna::MainMenu::BATTLER_STATUS[:class]
    end
  end
  
  #--------------------------------------------------------------------------
  # setting=
  #--------------------------------------------------------------------------
  def setting=(setting)
    @setting = setting
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
end # SpriteMenu_Class

#==============================================================================
# ■ SpriteMenu_Bar
#==============================================================================

class SpriteMenu_Bar < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset, symbol, setting)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @symbol = symbol
    @rate = real_rate
    @text = Sprite.new(viewport)
    @setting = setting
    refresh
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    update_rate if real_opacity > 0
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
    #---
    return if setting[:type] != 0
    @text.update
    @text.x = text_x; @text.y = text_y; @text.z = text_z
    @text.opacity = real_opacity
    @text.visible = @spriteset.visible
  end
  
  #--------------------------------------------------------------------------
  # update_rate
  #--------------------------------------------------------------------------
  def update_rate
    rate = [(@rate - real_rate).abs, setting[:ani_rate]].min
    @rate += @rate > real_rate ? -rate : rate
    refresh if rate > 0
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    case setting[:type]
    when 0; refresh_type0
    when 1; refresh_type1
    when 2; refresh_type2
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh_type0
  #--------------------------------------------------------------------------
  def refresh_type0
    self.bitmap ||= Bitmap.new(setting_type[:length], setting_type[:height])
    self.bitmap.clear
    #---
    rect = self.bitmap.rect
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
    back_color = setting_type[:back_color]
    if back_color.is_a?(String)
      back_color = eval(back_color)
    else
      back_color = Color.new(back_color[0], back_color[1], back_color[2], back_color[3])
    end
    outline = setting_type[:outline]
    if outline.is_a?(String)
      outline = eval(outline)
    else
      outline = Color.new(outline[0], outline[1], outline[2], outline[3])
    end
    self.bitmap.fill_rect(rect, outline)
    rect.x += 1; rect.y += 1; rect.width -= 2; rect.height -= 2
    self.bitmap.fill_rect(rect, back_color)
    if setting[:vertical]
      rect.height = rect.height * @rate
    else
      rect.width = rect.width * @rate
    end
    self.bitmap.gradient_fill_rect(rect, color1, color2)
    #---
    if @text.bitmap.nil?
      type = setting_type
      color = type[:tcolor]
      out = type[:toutline]
      @text.bitmap = Bitmap.new(setting_type[:length], 32)
      @text.bitmap.font.name = type[:font]
      @text.bitmap.font.size = type[:size]
      @text.bitmap.font.bold = type[:bold]
      @text.bitmap.font.italic = type[:italic]
      @text.bitmap.font.color = Color.new(color[0], color[1], color[2], color[3])
      @text.bitmap.font.out_color = Color.new(out[0], out[1], out[2], out[3])
      @text.bitmap.draw_text(0, 0, @text.bitmap.width, @text.bitmap.height, type[:text], type[:align])
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh_type1
  #--------------------------------------------------------------------------
  def refresh_type1
    self.bitmap = Cache.system(setting_type[:filename]) if self.bitmap.nil?
    #---
    width = self.bitmap.width
    height = self.bitmap.height
    if setting[:vertical]
      height = height * @rate
    else
      width = width * @rate
    end
    self.src_rect.set(0, 0, width, height)
  end
  
  #--------------------------------------------------------------------------
  # refresh_type2
  #--------------------------------------------------------------------------
  def refresh_type2
    self.bitmap = Cache.system(setting_type[:filename]) if self.bitmap.nil?
    #---
    frames = setting_type[:frames]
    rate   = 1.0 / frames
    width  = self.bitmap.width / frames
    height = self.bitmap.height
    x      = [(@rate / rate).floor, frames - 1].min * width
    self.src_rect.set(x, 0, width, height)
  end
    
  #--------------------------------------------------------------------------
  # real_rate
  #--------------------------------------------------------------------------
  def real_rate
    case @symbol
    when :hp_bar; return @battler.hp_rate
    when :mp_bar; return @battler.mp_rate
    when :tp_bar; return @battler.tp_rate
    end
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    case @setting
    when :mainmenu
      MenuLuna::MainMenu::BATTLER_STATUS[@symbol]
    when :itemmenu
      MenuLuna::ItemMenu::BATTLER_STATUS[@symbol]
    when :skillmenu
      MenuLuna::SkillMenu::BATTLER_STATUS[@symbol]
    when :skillmenusub
      MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[@symbol]
    else
      MenuLuna::MainMenu::BATTLER_STATUS[@symbol]
    end
  end
  
  #--------------------------------------------------------------------------
  # setting=
  #--------------------------------------------------------------------------
  def setting=(setting)
    @setting = setting
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # text_x
  #--------------------------------------------------------------------------
  def text_x
    @spriteset.screen_x + setting_type[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # text_y
  #--------------------------------------------------------------------------
  def text_y
    @spriteset.screen_y + setting_type[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # text_z
  #--------------------------------------------------------------------------
  def text_z
    @spriteset.screen_z + setting_type[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @text.dispose
  end
  
end # SpriteMenu_Bar

#==============================================================================
# ■ SpriteMenu_Numbers
#==============================================================================

class SpriteMenu_Numbers < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset, symbol, setting)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @symbol = symbol
    @number = real_number
    @max_number = 0
    @setting = setting
    refresh
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    update_rate if real_opacity > 0
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
  end
  
  #--------------------------------------------------------------------------
  # update_rate
  #--------------------------------------------------------------------------
  def update_rate
    case @symbol
    when :hp; rate = @battler.mhp * setting[:ani_rate]
    when :mp; rate = @battler.mmp * setting[:ani_rate]
    when :tp; rate = @battler.max_tp * setting[:ani_rate]
    when :mhp; rate = @battler.mhp * setting[:ani_rate]
    when :mmp; rate = @battler.mmp * setting[:ani_rate]
    when :mtp; rate = @battler.max_tp * setting[:ani_rate]
    end
    case @symbol
    when :hp; max = @battler.mhp
    when :mp; max = @battler.mmp
    when :tp; max = @battler.max_tp
    end
    rate = [(@number.to_i - real_number.to_i).abs, rate.to_i].min
    @number += @number > real_number ? -rate : rate
    refresh if rate > 0
    return unless setting[:with_max]
    refresh if max != @max_number
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    case setting[:type]
    when 0; refresh_type0
    when 1; refresh_type1
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh_type0
  #--------------------------------------------------------------------------
  def refresh_type0
    case @symbol
    when :hp; @max_number = @battler.mhp
    when :mp; @max_number = @battler.mmp
    when :tp; @max_number = @battler.max_tp
    end
    #---
    self.bitmap ||= Bitmap.new(setting_type[:width], setting_type[:height])
    self.bitmap.clear
    #---
    type = setting_type
    color = type[:color]
    out = type[:outline]
    str = sprintf(setting[:text], @number, @max_number) if setting[:text]
    str = setting[:with_max] ? str : @number
    self.bitmap = Bitmap.new(type[:width], type[:height])
    self.bitmap.font.name = type[:font]
    self.bitmap.font.size = type[:size]
    self.bitmap.font.bold = type[:bold]
    self.bitmap.font.italic = type[:italic]
    if color.is_a?(String)
      bitmap.font.color = eval(color)
    else
      bitmap.font.color = Color.new(color[0], color[1], color[2], color[3])
    end
    if out.is_a?(String)
      bitmap.font.out_color = eval(out)
    else
      bitmap.font.out_color = Color.new(out[0], out[1], out[2], out[3])
    end
    self.bitmap.draw_text(0, 0, self.bitmap.width, self.bitmap.height, str, type[:align])
  end
  
  #--------------------------------------------------------------------------
  # refresh_type1
  #--------------------------------------------------------------------------
  def refresh_type1
    num_bitmap = Cache.system(setting_type[:filename])
    #---
    self.bitmap ||= Bitmap.new(setting_type[:width], num_bitmap.height)
    self.bitmap.clear
    #---
    align    = setting_type[:align]
    spacing  = setting_type[:spacing]
    nwidth  = num_bitmap.width / 10
    nheight = num_bitmap.height
    ncount  = @number.to_s.size
    twidth  = ncount * (nwidth + spacing) - spacing
    case align
    when 0; offset_x = 0
    when 1; offset_x = [(setting_type[:width] - twidth) / 2, 0].max
    when 2; offset_x = [setting_type[:width] - twidth, 0].max
    end
    #---
    (0...ncount).each { |index|
      x = offset_x + index * (nwidth + spacing)
      number = @number.to_s[index].to_i
      rect   = Rect.new(nwidth * number, 0, nwidth, nheight)
      self.bitmap.blt(x, 0, num_bitmap, rect)
    }
  end
    
  #--------------------------------------------------------------------------
  # real_number
  #--------------------------------------------------------------------------
  def real_number
    case @symbol
    when :hp; return @battler.hp
    when :mp; return @battler.mp
    when :tp; return @battler.tp
    when :mhp; return @battler.mhp
    when :mmp; return @battler.mmp
    when :mtp; return @battler.max_tp
    end
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    case @setting
    when :mainmenu
      case @symbol
      when :hp; return MenuLuna::MainMenu::BATTLER_STATUS[:hp_num]
      when :mp; return MenuLuna::MainMenu::BATTLER_STATUS[:mp_num]
      when :tp; return MenuLuna::MainMenu::BATTLER_STATUS[:tp_num]
      when :mhp; return MenuLuna::MainMenu::BATTLER_STATUS[:hp_max_num]
      when :mmp; return MenuLuna::MainMenu::BATTLER_STATUS[:mp_max_num]
      when :mtp; return MenuLuna::MainMenu::BATTLER_STATUS[:tp_max_num]
      end
    when :itemmenu
      case @symbol
      when :hp; return MenuLuna::ItemMenu::BATTLER_STATUS[:hp_num]
      when :mp; return MenuLuna::ItemMenu::BATTLER_STATUS[:mp_num]
      when :tp; return MenuLuna::ItemMenu::BATTLER_STATUS[:tp_num]
      when :mhp; return MenuLuna::ItemMenu::BATTLER_STATUS[:hp_max_num]
      when :mmp; return MenuLuna::ItemMenu::BATTLER_STATUS[:mp_max_num]
      when :mtp; return MenuLuna::ItemMenu::BATTLER_STATUS[:tp_max_num]
      end
    when :skillmenu
      case @symbol
      when :hp; return MenuLuna::SkillMenu::BATTLER_STATUS[:hp_num]
      when :mp; return MenuLuna::SkillMenu::BATTLER_STATUS[:mp_num]
      when :tp; return MenuLuna::SkillMenu::BATTLER_STATUS[:tp_num]
      when :mhp; return MenuLuna::SkillMenu::BATTLER_STATUS[:hp_max_num]
      when :mmp; return MenuLuna::SkillMenu::BATTLER_STATUS[:mp_max_num]
      when :mtp; return MenuLuna::SkillMenu::BATTLER_STATUS[:tp_max_num]
      end
    when :skillmenusub
      case @symbol
      when :hp; return MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:hp_num]
      when :mp; return MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:mp_num]
      when :tp; return MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:tp_num]
      when :mhp; return MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:hp_max_num]
      when :mmp; return MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:mp_max_num]
      when :mtp; return MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:tp_max_num]
      end
    else
      case @symbol
      when :hp; return MenuLuna::MainMenu::BATTLER_STATUS[:hp_num]
      when :mp; return MenuLuna::MainMenu::BATTLER_STATUS[:mp_num]
      when :tp; return MenuLuna::MainMenu::BATTLER_STATUS[:tp_num]
      when :mhp; return MenuLuna::MainMenu::BATTLER_STATUS[:hp_max_num]
      when :mmp; return MenuLuna::MainMenu::BATTLER_STATUS[:mp_max_num]
      when :mtp; return MenuLuna::MainMenu::BATTLER_STATUS[:tp_max_num]
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # setting=
  #--------------------------------------------------------------------------
  def setting=(setting)
    @setting = setting
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
end # SpriteMenu_Numbers

#==============================================================================
# ■ SpriteMenu_States
#==============================================================================

class SpriteMenu_States < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, spriteset, setting)
    super(viewport)
    @spriteset = spriteset
    @battler = spriteset.battler
    @states = []
    @back_sprite = Sprite.new(viewport)
    @index = 0
    @setting = setting
    refresh
    refresh_back
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if states_change?
    update_scroll if setting[:type] == 1
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
    self.opacity = real_opacity
    self.visible = @spriteset.visible
    #---
    @back_sprite.update
    @back_sprite.x = back_x
    @back_sprite.y = back_y
    @back_sprite.z = back_z
    @back_sprite.opacity = real_opacity
    @back_sprite.visible = @spriteset.visible
  end
  
  #--------------------------------------------------------------------------
  # update_scroll
  #--------------------------------------------------------------------------
  def update_scroll
    @states.clear
    @states = @battler.state_icons + @battler.buff_icons
    #---
    @index  = 0 if @index > @states.size - 1
    #---
    @scroll ||= setting_type[:rate]
    @scroll -= 1
    #---
    return unless @states.size > 0
    #---
    return if @scroll > 0
    @index = (@index + 1) % @states.size
    @scroll = setting_type[:rate]
    refresh
  end
    
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    case setting[:type]
    when 0; refresh_type0
    when 1; refresh_type1
    end
  end
  
  #--------------------------------------------------------------------------
  # refresh_type0
  #--------------------------------------------------------------------------
  def refresh_type0
    @states.clear
    @states = @battler.state_icons + @battler.buff_icons
    #---
    w = 24 + setting_type[:spacing]
    width = w * setting_type[:max] - setting_type[:spacing]
    bitmap = Bitmap.new(width, 24)
    icon_bitmap = Cache.system("Iconset")
    @states.each_with_index { |icon_index, i|
      x = i * w
      rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
      bitmap.blt(x, 0, icon_bitmap, rect)
    }
    #---
    self.bitmap.dispose if self.bitmap
    self.bitmap = bitmap
  end
  
  #--------------------------------------------------------------------------
  # refresh_type1
  #--------------------------------------------------------------------------
  def refresh_type1
    @states.clear
    @states = @battler.state_icons + @battler.buff_icons
    #---
    bitmap = Bitmap.new(24, 24)
    icon_bitmap = Cache.system("Iconset")
    icon_index = @states[@index]
    if icon_index.nil?
      self.bitmap.dispose if self.bitmap
      self.bitmap = bitmap
      return false
    end
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    bitmap.blt(0, 0, icon_bitmap, rect)
    #---
    self.bitmap.dispose if self.bitmap
    self.bitmap = bitmap
  end
  
  #--------------------------------------------------------------------------
  # refresh_back
  #--------------------------------------------------------------------------
  def refresh_back
    return unless setting_back[:enable]
    @back_sprite.bitmap = Cache.system(setting_back[:filename])
  end
  
  #--------------------------------------------------------------------------
  # name_change?
  #--------------------------------------------------------------------------
  def states_change?
    @states != @battler.state_icons + @battler.buff_icons
  end
    
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    case @setting
    when :mainmenu
      MenuLuna::MainMenu::BATTLER_STATUS[:states]
    when :itemmenu
      MenuLuna::ItemMenu::BATTLER_STATUS[:states]
    when :skillmenu
      MenuLuna::SkillMenu::BATTLER_STATUS[:states]
    when :skillmenusub
      MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS[:states]
    else
      MenuLuna::MainMenu::BATTLER_STATUS[:states]
    end
  end
  
  #--------------------------------------------------------------------------
  # setting=
  #--------------------------------------------------------------------------
  def setting=(setting)
    @setting = setting
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # setting_back
  #--------------------------------------------------------------------------
  def setting_back
    setting[:back]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    @spriteset.screen_x + setting[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    @spriteset.screen_y + setting[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    @spriteset.screen_z + setting[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # back_x
  #--------------------------------------------------------------------------
  def back_x
    @spriteset.screen_x + setting_back[:offset_x]
  end
  
  #--------------------------------------------------------------------------
  # back_y
  #--------------------------------------------------------------------------
  def back_y
    @spriteset.screen_y + setting_back[:offset_y]
  end
  
  #--------------------------------------------------------------------------
  # back_z
  #--------------------------------------------------------------------------
  def back_z
    @spriteset.screen_z + setting_back[:offset_z]
  end
  
  #--------------------------------------------------------------------------
  # real_opacity
  #--------------------------------------------------------------------------
  def real_opacity
    @spriteset.opacity
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @back_sprite.dispose
  end
  
end # SpriteMenu_States

#==============================================================================
# ■ Spriteset_MenuStatus
#==============================================================================

class Spriteset_MenuStatus
  
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :battler
  attr_accessor :actor_window
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, battler, setting = :mainmenu, index = 0)
    @viewport = viewport
    @battler = battler
    @setting = setting
    @window  = SceneManager.scene.status_window rescue nil
    @index   = index
    @sprites = []
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    result = setting[:x] + eval(setting[:offset_x].to_s)
    return result if setting[:vertical]
    if setting[:center] 
      total_battlers = $game_party.battle_members.size
      total_width = setting[:max_width] / total_battlers
      result += (total_width - setting[:spacing]) * index
      result += [(total_width - setting[:width]), 0].max / 2
    else
      result += (setting[:width] + setting[:spacing]) * index
    end
    result
  end

  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    result = setting[:y] + eval(setting[:offset_y].to_s)
    return result unless setting[:vertical]
    if setting[:center] 
      total_battlers = $game_party.battle_members.size
      total_height = setting[:max_height] / total_battlers
      result += (total_height - setting[:spacing]) * index
      result += [(total_height - setting[:height]), 0].max / 2
    else
      result += (setting[:height] + setting[:spacing]) * index
    end
    result
  end

  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # opacity
  #--------------------------------------------------------------------------
  def opacity
    return 0 if @setting != :skillmenusub && setting[:lunatic]
    return 0 unless @window
    return @window.openness rescue 255
  end
  
  #--------------------------------------------------------------------------
  # visible
  #--------------------------------------------------------------------------
  def visible
    return false if @setting != :skillmenusub && setting[:lunatic]
    return false unless @window
    return @window.visible rescue true
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    case @setting
    when :mainmenu
      MenuLuna::MainMenu::BATTLER_STATUS
    when :itemmenu
      MenuLuna::ItemMenu::BATTLER_STATUS
    when :skillmenu
      MenuLuna::SkillMenu::BATTLER_STATUS
    when :skillmenusub
      MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS
    else
      MenuLuna::MainMenu::BATTLER_STATUS
    end
  end
  
  #--------------------------------------------------------------------------
  # setting=
  #--------------------------------------------------------------------------
  def setting=(setting)
    @setting = setting
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # index
  #--------------------------------------------------------------------------
  def index
    #@battler.index
    @index
  end
  
  #--------------------------------------------------------------------------
  # battler
  #--------------------------------------------------------------------------
  def battler=(battler)
    return if @battler == battler
    @battler = battler
    refresh
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return dispose if @battler.nil?
    refresh if @battler && @sprites.size == 0
    @sprites.each { |sprite| sprite.update }
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    @sprites.each { |sprite| sprite.dispose }
    @sprites.clear
  end
  
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    dispose
    #---
    create_window
    create_main
    create_select
    create_face
    create_name
    create_level
    create_bars
    create_numbers
    create_states
    create_class
    #---
    update
  end
  
  #--------------------------------------------------------------------------
  # create_window
  #--------------------------------------------------------------------------
  def create_window
  end
  
  #--------------------------------------------------------------------------
  # create_main
  #--------------------------------------------------------------------------
  def create_main
    main = SpriteMenu_Main.new(@viewport, self, @setting)
    @sprites.push(main)
  end
  
  #--------------------------------------------------------------------------
  # create_select
  #--------------------------------------------------------------------------
  def create_select
    select = SpriteMenu_Select.new(@viewport, self, @setting)
    @sprites.push(select)
  end
  
  #--------------------------------------------------------------------------
  # create_face
  #--------------------------------------------------------------------------
  def create_face
    face = SpriteMenu_Face.new(@viewport, self, @setting)
    @sprites.push(face)
  end
  
  #--------------------------------------------------------------------------
  # create_name
  #--------------------------------------------------------------------------
  def create_name
    name = SpriteMenu_Name.new(@viewport, self, @setting)
    @sprites.push(name)
  end
  
  #--------------------------------------------------------------------------
  # create_level
  #--------------------------------------------------------------------------
  def create_level
    level = SpriteMenu_Level.new(@viewport, self, @setting)
    @sprites.push(level)
  end
  
  #--------------------------------------------------------------------------
  # create_class
  #--------------------------------------------------------------------------
  def create_class
    clss = SpriteMenu_Class.new(@viewport, self, @setting)
    @sprites.push(clss)
  end
  
  #--------------------------------------------------------------------------
  # create_bars
  #--------------------------------------------------------------------------
  def create_bars
    hp_bar = SpriteMenu_Bar.new(@viewport, self, :hp_bar, @setting)
    mp_bar = SpriteMenu_Bar.new(@viewport, self, :mp_bar, @setting)
    tp_bar = SpriteMenu_Bar.new(@viewport, self, :tp_bar, @setting)
    @sprites.push(hp_bar, mp_bar, tp_bar)
  end
  
  #--------------------------------------------------------------------------
  # create_numbers
  #--------------------------------------------------------------------------
  def create_numbers
    hp = SpriteMenu_Numbers.new(@viewport, self, :hp, @setting)
    mp = SpriteMenu_Numbers.new(@viewport, self, :mp, @setting)
    tp = SpriteMenu_Numbers.new(@viewport, self, :tp, @setting)
    mhp = SpriteMenu_Numbers.new(@viewport, self, :mhp, @setting)
    mmp = SpriteMenu_Numbers.new(@viewport, self, :mmp, @setting)
    mtp = SpriteMenu_Numbers.new(@viewport, self, :mtp, @setting)
    @sprites.push(hp, mp, tp, mhp, mmp, mtp)
  end
  
  #--------------------------------------------------------------------------
  # create_states
  #--------------------------------------------------------------------------
  def create_states
    states = SpriteMenu_States.new(@viewport, self, @setting)
    @sprites.push(states)
  end
  
end # Spriteset_MenuStatus

#==============================================================================
# ■ LunaMenu_Status
#==============================================================================

class LunaMenu_Status
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport, setting = :mainmenu)
    @viewport = viewport
    @spritesets = []
    @setting = setting
    @index = 0
    @limit = 0
    @top   = 0
    case @setting
    when :mainmenu
      @limit = MenuLuna::MainMenu::BATTLER_STATUS[:limit_page]
    when :itemmenu
      @limit = MenuLuna::ItemMenu::BATTLER_STATUS[:limit_page]
    when :skillmenu
      @limit = MenuLuna::SkillMenu::BATTLER_STATUS[:limit_page]
    else
      @limit = MenuLuna::MainMenu::BATTLER_STATUS[:limit_page]
    end
    setup_hud
  end
  
  #--------------------------------------------------------------------------
  # setup_hud
  #--------------------------------------------------------------------------
  def setup_hud
    @limit.times { |i|
      battler = $game_party.members[i]
      spriteset = Spriteset_MenuStatus.new(@viewport, battler, @setting, i)
      @spritesets.push(spriteset)
    }
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    update_top_row
    @spritesets.each_with_index { |spriteset, index|
      spriteset.battler = $game_party.members[index + @top]
    }
    @spritesets.each { |spriteset| spriteset.update }
  end
  
  #--------------------------------------------------------------------------
  # dispose
  #--------------------------------------------------------------------------
  def dispose
    @spritesets.each { |spriteset| spriteset.dispose }
    @spritesets.clear
  end
  
  #--------------------------------------------------------------------------
  # actor_window
  #--------------------------------------------------------------------------
  def actor_window=(window)
    @actor_window = window
    @spritesets.each { |spriteset| spriteset.actor_window = window }
    update_top_row
    update
  end
  
  #--------------------------------------------------------------------------
  # update_top_row
  #--------------------------------------------------------------------------
  def update_top_row
    @index = [@actor_window.index, 0].max
    if @index >= @top + @limit
      @top = @index + 1 - @limit
    elsif @index < @top
      @top = @index
    end
  end
  
end # LunaMenu_Status

#==============================================================================
# ■ Window_MenuStatus
#==============================================================================

class Window_MenuStatusLuna < Window_MenuStatus
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias menu_luna_initialize initialize
  def initialize(x, y)
    menu_luna_initialize(x, y)
    select(0) if lunatic[:autoselect]
    self.arrows_visible = MenuLuna::MainMenu::STATUS_WINDOW[:arrow]
    init_position
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
  end
  
  #--------------------------------------------------------------------------
  # new method: actor
  #--------------------------------------------------------------------------
  def actor
    @index < 0 ? nil : $game_party.members[@index]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    if is_lunatic?
      vertical = lunatic[:vertical]
    else
      vertical = MenuLuna::MainMenu::BATTLER_STATUS[:vertical]
    end
    vertical ? 1 : [1, lunatic[:scroll] ? lunatic[:col_max] : item_max].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    width = MenuLuna::MainMenu::STATUS_WINDOW[:width]
    [width, standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    height = MenuLuna::MainMenu::STATUS_WINDOW[:height]
    [height, standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [lunatic[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    [lunatic[:spacing], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    MenuLuna::MainMenu::STATUS_WINDOW[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    MenuLuna::MainMenu::STATUS_WINDOW[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    MenuLuna::MainMenu::STATUS_WINDOW[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::MainMenu::STATUS_WINDOW
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    MenuLuna::MainMenu::STATUS_WINDOW[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def is_lunatic?
    MenuLuna::MainMenu::BATTLER_STATUS[:lunatic]
  end
  
  #--------------------------------------------------------------------------
  # new method: lunatic
  #--------------------------------------------------------------------------
  def lunatic
    MenuLuna::MainMenu::STATUS_WINDOW[:lunatic]
  end
  
  #--------------------------------------------------------------------------
  # new method: type
  #--------------------------------------------------------------------------
  def type
    MenuLuna::MainMenu::STATUS_WINDOW[:back_type]
  end

  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias menu_luna_refresh refresh
  def refresh
    is_lunatic? ? menu_luna_refresh : contents.clear
  end
    
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    if MenuLuna::MainMenu::STATUS_WINDOW[:cursor]
      menu_luna_update_cursor
    else
      cursor_rect.empty
    end
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: draw_item_background
  #--------------------------------------------------------------------------
  def draw_item_background(index)
    # Temporarily removed.
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: contents_width
  #--------------------------------------------------------------------------
  alias menu_luna_contents_width contents_width
  def contents_width
    if is_lunatic? && !lunatic[:vertical] && lunatic[:scroll]
      return (item_width + spacing) * item_max - spacing
    else
      return menu_luna_contents_width
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: contents_height
  #--------------------------------------------------------------------------
  alias menu_luna_contents_height contents_height
  def contents_height
    if is_lunatic? && !lunatic[:vertical] && lunatic[:scroll]
      return window_height - standard_padding * 2
    else
      return menu_luna_contents_height
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_rect
  #--------------------------------------------------------------------------
  def item_rect(index)
    if !lunatic[:vertical] && lunatic[:scroll]
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index * (item_width + spacing) + lunatic[:item_rect][:x]
      rect.y = lunatic[:item_rect][:y]
      return rect
    else
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index % col_max * (item_width + spacing) + lunatic[:item_rect][:x]
      rect.y = index / col_max * item_height + lunatic[:item_rect][:y]
      return rect
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_width
  #--------------------------------------------------------------------------
  def item_width
    lunatic[:item_rect][:width]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    lunatic[:item_rect][:height]
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(index, actor, contents, item_rect, enable, select, formation)
    MenuLuna::MainMenu.status_text(index, actor, contents, item_rect, enable, select, formation)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    return unless is_lunatic?
    clear_item(index)
    actor = $game_party.members[index]
    rect = item_rect(index)
    enable = $game_party.battle_members.include?(actor)
    select = index == self.index
    formation = index == @pending_index
    return menu_luna_draw_item(index) if texts(index, actor, contents, rect, enable, select, formation).nil?
    reset_font_settings
    hash = texts(index, actor, contents, rect, enable, select, formation)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    if lunatic[:refresh]
      refresh
    else
      draw_item(last_index)
      draw_item(@index)
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    last_index = @index
    @index = index
    draw_item(last_index) if last_index >= 0
    draw_item(@index) if @index >= 0
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # top_col
  #--------------------------------------------------------------------------
  def top_col
    ox / (item_width + spacing)
  end
  
  #--------------------------------------------------------------------------
  # top_col=
  #--------------------------------------------------------------------------
  def top_col=(col)
    if !lunatic[:vertical] && lunatic[:scroll]
      col = 0 if col < 0
      col = col_max - 1 if col > col_max - 1
      self.ox = col * (item_width + spacing)
    else
      col = 0 if col < 0
      col = col
      self.ox = col * (item_width + spacing)
    end
  end
  
  #--------------------------------------------------------------------------
  # bottom_col
  #--------------------------------------------------------------------------
  def bottom_col
    top_col + col_max - 1
  end
  
  #--------------------------------------------------------------------------
  # bottom_col=
  #--------------------------------------------------------------------------
  def bottom_col=(col)
    self.top_col = col - (col_max - 1)
  end
  
  #--------------------------------------------------------------------------
  # ensure_cursor_visible
  #--------------------------------------------------------------------------
  alias menu_luna_ensure_cursor_visible ensure_cursor_visible
  def ensure_cursor_visible
    if !lunatic[:vertical]
      self.top_col = index if index < top_col
      self.bottom_col = index if index > bottom_col
    else
      menu_luna_ensure_cursor_visible
    end
  end
  
end # Window_MenuStatusLuna

#==============================================================================
# ** Window_HorzCommand
#------------------------------------------------------------------------------
#  This is a command window for the horizontal selection format.
#==============================================================================

class Window_HorzCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    return 1
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 4
  end
  #--------------------------------------------------------------------------
  # * Get Spacing for Items Arranged Side by Side
  #--------------------------------------------------------------------------
  def spacing
    return 8
  end
  #--------------------------------------------------------------------------
  # * Calculate Width of Window Contents
  #--------------------------------------------------------------------------
  def contents_width
    (item_width + spacing) * item_max - spacing
  end
  #--------------------------------------------------------------------------
  # * Calculate Height of Window Contents
  #--------------------------------------------------------------------------
  def contents_height
    item_height
  end
  #--------------------------------------------------------------------------
  # * Get Leading Digits
  #--------------------------------------------------------------------------
  def top_col
    ox / (item_width + spacing)
  end
  #--------------------------------------------------------------------------
  # * Set Leading Digits
  #--------------------------------------------------------------------------
  def top_col=(col)
    col = 0 if col < 0
    col = col_max - 1 if col > col_max - 1
    self.ox = col * (item_width + spacing)
  end
  #--------------------------------------------------------------------------
  # * Get Trailing Digits
  #--------------------------------------------------------------------------
  def bottom_col
    top_col + col_max - 1
  end
  #--------------------------------------------------------------------------
  # * Set Trailing Digits
  #--------------------------------------------------------------------------
  def bottom_col=(col)
    self.top_col = col - (col_max - 1)
  end
  #--------------------------------------------------------------------------
  # * Scroll Cursor to Position Within Screen
  #--------------------------------------------------------------------------
  def ensure_cursor_visible
    self.top_col = index if index < top_col
    self.bottom_col = index if index > bottom_col
  end
  #--------------------------------------------------------------------------
  # * Get Rectangle for Displaying Items
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = super
    rect.x = index * (item_width + spacing)
    rect.y = 0
    rect
  end
  #--------------------------------------------------------------------------
  # * Get Alignment
  #--------------------------------------------------------------------------
  def alignment
    return 1
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Down
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Up
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Move Cursor One Page Down
  #--------------------------------------------------------------------------
  def cursor_pagedown
  end
  #--------------------------------------------------------------------------
  # * Move Cursor One Page Up
  #--------------------------------------------------------------------------
  def cursor_pageup
  end
end


#==============================================================================
# ■ Window_MenuCommand
#==============================================================================

class Window_MenuCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias battle_luna_initialize initialize
  def initialize
    battle_luna_initialize
    self.arrows_visible = setting[:arrow]
    init_position
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    setting[:item_height]
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    eval(setting[:x].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    setting[:vertical] ? 1 : [item_max, 1].max
  end

  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    8
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: alignment
  #--------------------------------------------------------------------------
  def alignment
    setting[:align]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::MainMenu::WINDOW_COMMANDS
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    setting[:cursor] ? menu_luna_update_cursor : cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(index, contents, rect, enable, select)
    MenuLuna::MainMenu.command_text(index, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    clear_item(index)
    rect = item_rect(index)
    enable = command_enabled?(index)
    select = index == self.index
    return menu_luna_draw_item(index) if texts(index, contents, rect, enable, select).nil?
    reset_font_settings
    hash = texts(index, contents, rect, enable, select)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    last_index = @index
    @index = index
    draw_item(last_index) if last_index >= 0
    draw_item(@index) if @index >= 0
    update_cursor
    call_update_help
  end
  
end # Window_MenuCommand

#==============================================================================
# ■ Window_MenuGold
#==============================================================================

class Window_MenuGold < Window_Gold
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize
    super
    self.width  = window_width
    self.height = window_height
    create_contents
    refresh
    refresh_background
    init_position
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    eval(setting[:x].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::MainMenu::WINDOW_GOLD
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts(contents)
    MenuLuna::MainMenu::gold_text(contents)
  end
  
  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias menu_luna_refresh refresh
  def refresh
    return menu_luna_refresh if texts(contents).nil?
    contents.clear
    reset_font_settings
    hash = texts(contents)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_MenuGold

#==============================================================================
# ■ SpriteMenu_Playtime
#==============================================================================

class SpriteMenu_Playtime < Sprite
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    @playtime = 0
    refresh
  end
  
  #--------------------------------------------------------------------------
  # update
  #--------------------------------------------------------------------------
  def update
    return unless setting[:enable]
    #---
    super
    refresh if playtime_change?
    #---
    self.x = screen_x; self.y = screen_y; self.z = screen_z
  end
      
  #--------------------------------------------------------------------------
  # refresh
  #--------------------------------------------------------------------------
  def refresh
    return unless setting[:enable]
    color = setting[:color]
    out = setting[:outline]
    @playtime = $game_system.playtime
    #---
    bitmap = Bitmap.new(setting[:width], setting[:height])
    bitmap.font.name = setting[:font]
    bitmap.font.size = setting[:size]
    bitmap.font.bold = setting[:bold]
    bitmap.font.italic = setting[:italic]
    if color.is_a?(String)
      bitmap.font.color = eval(color)
    else
      bitmap.font.color = Color.new(color[0], color[1], color[2], color[3])
    end
    if out.is_a?(String)
      bitmap.font.out_color = eval(out)
    else
      bitmap.font.out_color = Color.new(out[0], out[1], out[2], out[3])
    end
    bitmap.draw_text(0, 0, bitmap.width, bitmap.height, $game_system.playtime_s, setting[:align])
    #---
    self.bitmap.dispose if self.bitmap
    self.bitmap = bitmap
  end
  
  #--------------------------------------------------------------------------
  # name_change?
  #--------------------------------------------------------------------------
  def playtime_change?
    @playtime != $game_system.playtime
  end
    
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::MainMenu::PLAYTIME_SPRITE
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
    
end # SpriteMenu_Playtime

#==============================================================================
# ■ Scene_Menu
#==============================================================================

class Scene_Menu < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # alias method: start
  #--------------------------------------------------------------------------
  alias menu_luna_start start
  def start
    menu_luna_start
    create_menu_status
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_command_window
  #--------------------------------------------------------------------------
  alias menu_luna_create_command_window create_command_window
  def create_command_window
    menu_luna_create_command_window
    @command_window.init_position
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_status_window
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_MenuStatusLuna.new(@command_window.width, 0)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_gold_window
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_MenuGold.new
    @gold_window.update
  end
  
  #--------------------------------------------------------------------------
  # new method: create_menu_status
  #--------------------------------------------------------------------------
  def create_menu_status
    @menu_status = LunaMenu_Status.new(@command_window.viewport)
    @menu_status.actor_window = @status_window
    @menu_status.update
    #---
    @playtime = SpriteMenu_Playtime.new(@viewport)
    @playtime.update
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias menu_luna_update update
  def update
    menu_luna_update
    @menu_status.update
    @playtime.update
  end
  
  #--------------------------------------------------------------------------
  # alias method: terminate
  #--------------------------------------------------------------------------
  alias menu_luna_terminate terminate
  def terminate
    menu_luna_terminate
    @menu_status.dispose
    @playtime.dispose
  end
  
  #--------------------------------------------------------------------------
  # new method: status_window
  #--------------------------------------------------------------------------
  def status_window
    @status_window
  end
  
end # Scene_Menu

#==============================================================================
# ■ Window_ItemHelp
#==============================================================================

class Window_ItemHelp < Window_Help
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(line_number)
    init_position
    update_padding
    create_contents
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(line_number) + setting[:height_buff]
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ItemMenu::WINDOW_HELP
  end
  
  #--------------------------------------------------------------------------
  # line_number
  #--------------------------------------------------------------------------
  def line_number
    setting[:line_number]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_BattleHelp

#==============================================================================
# ■ Window_ItemCategoryMenu
#==============================================================================

class Window_ItemCategoryMenu < Window_ItemCategory
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias battle_luna_initialize initialize
  def initialize
    battle_luna_initialize
    self.arrows_visible = setting[:arrow]
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    setting[:item_height]
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    setting[:enable] ? eval(setting[:x].to_s) : 999
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    setting[:vertical] ? 1 : [item_max, 1].max
  end
  
  #--------------------------------------------------------------------------
  # alias method: contents_height
  #--------------------------------------------------------------------------
  alias menu_luna_contents_height contents_height
  def contents_height
    setting[:vertical] ? [super - super % item_height, row_max * item_height].max : menu_luna_contents_height
  end

  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    8
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: alignment
  #--------------------------------------------------------------------------
  def alignment
    setting[:align]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ItemMenu::WINDOW_CATEGORY
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(index, contents, rect, enable, select)
    MenuLuna::ItemMenu.category_text(index, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    clear_item(index)
    rect = item_rect(index)
    enable = command_enabled?(index)
    select = index == self.index
    return menu_luna_draw_item(index) if texts(index, contents, rect, enable, select).nil?
    reset_font_settings
    hash = texts(index, contents, rect, enable, select)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    setting[:cursor] ? menu_luna_update_cursor : cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    draw_item(@index) if current_data
    @index = index
    draw_item(@index) if current_data
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # cursor_down
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    if index < item_max - col_max || (wrap && col_max == 1)
      select((index + col_max) % item_max)
    end
  end
  
  #--------------------------------------------------------------------------
  # cursor_up
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    if index >= col_max || (wrap && col_max == 1)
      select((index - col_max + item_max) % item_max)
    end
  end
  
  #--------------------------------------------------------------------------
  # contents_width
  #--------------------------------------------------------------------------
  alias menu_luna_contents_width contents_width
  def contents_width
    setting[:vertical] ? width - standard_padding * 2 : menu_luna_contents_width
  end
  
  #--------------------------------------------------------------------------
  # item_rect
  #--------------------------------------------------------------------------
  alias menu_luna_item_rect item_rect
  def item_rect(index)
    if setting[:vertical]
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index % col_max * (item_width + spacing)
      rect.y = index / col_max * item_height
      return rect
    else
      return menu_luna_item_rect(index)
    end
  end
  
  #--------------------------------------------------------------------------
  # ensure_cursor_visible
  #--------------------------------------------------------------------------
  alias menu_luna_ensure_cursor_visible ensure_cursor_visible
  def ensure_cursor_visible
    if setting[:vertical]
      self.top_row = row if row < top_row
      self.bottom_row = row if row > bottom_row
    else
      menu_luna_ensure_cursor_visible
    end
  end
  
end # Window_ItemCategoryMenu

#==============================================================================
# ■ Window_ItemListLuna
#==============================================================================

class Window_ItemListLuna < Window_ItemList
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #-------------------------------------------------------------------------- 
  def initialize(x, y, width, height)
    super(screen_x, screen_y, window_width, window_height)
    self.arrows_visible = setting[:arrow]
    refresh_background
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
    refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    [line_height, setting[:item_height]].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def col_max
    [1, setting[:column]].max
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ItemMenu::WINDOW_ITEM
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # alias method: include?
  #--------------------------------------------------------------------------
  alias menu_luna_include? include?
  def include?(item)
    category_enable = MenuLuna::ItemMenu::WINDOW_CATEGORY[:enable]
    category_enable ? menu_luna_include?(item) : true
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: select_last
  #--------------------------------------------------------------------------
  def select_last
    last = $game_party.last_item.object
    last ? select(@data.index(last) || 0) : select(0)
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(item, contents, rect, enable, select)
    MenuLuna::ItemMenu.item_text(item, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    clear_item(index)
    item = @data[index]
    select = index == self.index
    if item
      rect = item_rect(index)
      enable = enable?(item)
      return menu_luna_draw_item(index) if texts(item, contents, rect, enable, select).nil?
      reset_font_settings
      hash = texts(item, contents, rect, enable, select)
      hash[0].each { |val|
        draw_lunatic(val, hash[1])
      }
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
#~     p [self.ox, self.oy, self]
    setting[:cursor] ? menu_luna_update_cursor : do_luna_update_cursor
  end
  
  def do_luna_update_cursor
    cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    draw_item(@index) if @index >= 0
    @index = index
    draw_item(@index) if @index >= 0
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_rect
  #--------------------------------------------------------------------------
  alias menu_luna_item_rect item_rect
  def item_rect(index)
    return menu_luna_item_rect(index) unless setting[:item_rect][:custom]
    rect = Rect.new
    item_width = setting[:item_rect][:width]
    item_height = setting[:item_rect][:height]
    spacing_ver = setting[:item_rect][:spacing_ver]
    spacing_hor = setting[:item_rect][:spacing_hor]
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing_hor)
    rect.y = index / col_max * (item_height + spacing_ver)
    rect
  end
  
end # Window_ItemListLuna

#==============================================================================
# ■ Window_ItemMenuActor
#==============================================================================

class Window_ItemMenuActor < Window_MenuActor
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias menu_luna_initialize initialize
  def initialize
    menu_luna_initialize
    self.arrows_visible = MenuLuna::ItemMenu::STATUS_WINDOW[:arrow]
    select(0) if lunatic[:autoselect]
    init_position
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
  end
  
  #--------------------------------------------------------------------------
  # new method: actor
  #--------------------------------------------------------------------------
  def actor
    @index < 0 ? nil : $game_party.members[@index]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    if is_lunatic?
      vertical = lunatic[:vertical]
    else
      vertical = MenuLuna::MainMenu::BATTLER_STATUS[:vertical]
    end
    vertical ? 1 : [1, lunatic[:scroll] ? lunatic[:col_max] : item_max].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    width = MenuLuna::ItemMenu::STATUS_WINDOW[:width]
    [width, standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    height = MenuLuna::ItemMenu::STATUS_WINDOW[:height]
    [height, standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [lunatic[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    [lunatic[:spacing], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    MenuLuna::ItemMenu::STATUS_WINDOW[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    MenuLuna::ItemMenu::STATUS_WINDOW[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    MenuLuna::ItemMenu::STATUS_WINDOW[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ItemMenu::STATUS_WINDOW
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    MenuLuna::ItemMenu::STATUS_WINDOW[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def is_lunatic?
    MenuLuna::ItemMenu::BATTLER_STATUS[:lunatic]
  end
  
  #--------------------------------------------------------------------------
  # new method: lunatic
  #--------------------------------------------------------------------------
  def lunatic
    MenuLuna::ItemMenu::STATUS_WINDOW[:lunatic]
  end
  
  #--------------------------------------------------------------------------
  # new method: type
  #--------------------------------------------------------------------------
  def type
    MenuLuna::ItemMenu::STATUS_WINDOW[:back_type]
  end

  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias menu_luna_refresh refresh
  def refresh
    is_lunatic? ? menu_luna_refresh : contents.clear
  end
    
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    if MenuLuna::ItemMenu::STATUS_WINDOW[:cursor]
      menu_luna_update_cursor
    else
      cursor_rect.empty
    end
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: draw_item_background
  #--------------------------------------------------------------------------
  def draw_item_background(index)
    # Temporarily removed.
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: contents_width
  #--------------------------------------------------------------------------
  alias menu_luna_contents_width contents_width
  def contents_width
    if is_lunatic? && !lunatic[:vertical] && lunatic[:scroll]
      return (item_width + spacing) * item_max - spacing
    else
      return menu_luna_contents_width
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: contents_height
  #--------------------------------------------------------------------------
  alias menu_luna_contents_height contents_height
  def contents_height
    if is_lunatic? && !lunatic[:vertical] && lunatic[:scroll]
      return window_height - standard_padding * 2
    else
      return menu_luna_contents_height
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_rect
  #--------------------------------------------------------------------------
  def item_rect(index)
    if !lunatic[:vertical] && lunatic[:scroll]
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index * (item_width + spacing) + lunatic[:item_rect][:x]
      rect.y = lunatic[:item_rect][:y]
      return rect
    else
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index % col_max * (item_width + spacing) + lunatic[:item_rect][:x]
      rect.y = index / col_max * item_height + lunatic[:item_rect][:y]
      return rect
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_width
  #--------------------------------------------------------------------------
  def item_width
    lunatic[:item_rect][:width]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    lunatic[:item_rect][:height]
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(index, actor, contents, item_rect, enable, select, formation)
    MenuLuna::ItemMenu.status_text(index, actor, contents, item_rect, enable, select, formation)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    return unless is_lunatic?
    clear_item(index)
    actor = $game_party.members[index]
    rect = item_rect(index)
    enable = $game_party.battle_members.include?(actor)
    select = index == self.index
    formation = index == @pending_index
    return menu_luna_draw_item(index) if texts(index, actor, contents, rect, enable, select, formation).nil?
    reset_font_settings
    hash = texts(index, actor, contents, rect, enable, select, formation)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    return unless is_lunatic?
    if lunatic[:refresh]
      refresh
    else
      draw_item(last_index)
      draw_item(@index)
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    last_index = @index
    @index = index
    draw_item(last_index) if last_index >= 0
    draw_item(@index) if @index >= 0
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # top_col
  #--------------------------------------------------------------------------
  def top_col
    ox / (item_width + spacing)
  end
  
  #--------------------------------------------------------------------------
  # top_col=
  #--------------------------------------------------------------------------
  def top_col=(col)
    if !lunatic[:vertical] && lunatic[:scroll]
      col = 0 if col < 0
      col = col_max - 1 if col > col_max - 1
      self.ox = col * (item_width + spacing)
    else
      col = 0 if col < 0
      col = col
      self.ox = col * (item_width + spacing)
    end
  end
  
  #--------------------------------------------------------------------------
  # bottom_col
  #--------------------------------------------------------------------------
  def bottom_col
    top_col + col_max - 1
  end
  
  #--------------------------------------------------------------------------
  # bottom_col=
  #--------------------------------------------------------------------------
  def bottom_col=(col)
    self.top_col = col - (col_max - 1)
  end
  
  #--------------------------------------------------------------------------
  # ensure_cursor_visible
  #--------------------------------------------------------------------------
  alias menu_luna_ensure_cursor_visible ensure_cursor_visible
  def ensure_cursor_visible
    if !lunatic[:vertical]
      self.top_col = index if index < top_col
      self.bottom_col = index if index > bottom_col
    else
      menu_luna_ensure_cursor_visible
    end
  end
  
end # Window_ItemMenuActor

#==============================================================================
# ■ Window_ItemDescription
#==============================================================================

class Window_ItemDescription < Window_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize(window_item)
    super(init_screen_x, init_screen_y, window_width, window_height)
    self.width  = window_width
    self.height = window_height
    @window_item = window_item
    create_contents
    refresh
    refresh_background
    init_position
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: window_item
  #--------------------------------------------------------------------------
  def window_item=(window)
    contents.clear
    @window_item = window
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    setting[:enable] ? eval(setting[:x].to_s) : 999
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ItemMenu::WINDOW_DESCRIPTION
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts(item, contents)
    MenuLuna::ItemMenu::description_text(item, contents)
  end
  
  #--------------------------------------------------------------------------
  # new method: refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @window_item
    return if @window_item.item.nil?
    return if texts(@window_item.item, contents).nil?
    reset_font_settings
    hash = texts(@window_item.item, contents)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias luna_menu_update update
  def update
    luna_menu_update
    #---
    if @window_item && (@item != @window_item.item || !@window_item.active)
      @item = @window_item.item
      refresh
    end
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_ItemDescription

#==============================================================================
# ■ Scene_Item
#==============================================================================

class Scene_Item < Scene_ItemBase
  
  #--------------------------------------------------------------------------
  # alias method: start
  #--------------------------------------------------------------------------
  alias menu_luna_start start
  def start
    menu_luna_start
    create_menu_status
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_actor_window
  #--------------------------------------------------------------------------
  def create_actor_window
    @actor_window = Window_ItemMenuActor.new
    @actor_window.viewport = @viewport
    @actor_window.set_handler(:ok,     method(:on_actor_ok))
    @actor_window.set_handler(:cancel, method(:on_actor_cancel))
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_help_window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_ItemHelp.new
    @help_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_category_window
  #-------------------------------------------------------------------------- 
  def create_category_window
    @category_window = Window_ItemCategoryMenu.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @help_window.height
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:return_scene))
    @category_window.init_position
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_item_window
  #--------------------------------------------------------------------------
  def create_item_window
    @item_window = Window_ItemListLuna.new(0, 0, Graphics.width, Graphics.height)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @category_window.item_window = @item_window
    #---
    @description_window = Window_ItemDescription.new(@item_window)
    @description_window.viewport = @viewport
    #---
    init_category
  end
  
  #--------------------------------------------------------------------------
  # new method: create_menu_status
  #--------------------------------------------------------------------------
  def create_menu_status
    @menu_status = LunaMenu_Status.new(@viewport, :itemmenu)
    @menu_status.actor_window = @actor_window
    @menu_status.update
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias menu_luna_update update
  def update
    menu_luna_update
    @menu_status.update
  end
  
  #--------------------------------------------------------------------------
  # alias method: terminate
  #--------------------------------------------------------------------------
  alias menu_luna_terminate terminate
  def terminate
    menu_luna_terminate
    @menu_status.dispose
  end
  
  #--------------------------------------------------------------------------
  # new method: init_category
  #--------------------------------------------------------------------------
  def init_category
    return if MenuLuna::ItemMenu::WINDOW_CATEGORY[:enable]
    @category_window.deactivate
    @item_window.activate
    @item_window.select_last
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_item_cancel
  #--------------------------------------------------------------------------
  alias menu_luna_on_item_cancel on_item_cancel
  def on_item_cancel
    category_enable = MenuLuna::ItemMenu::WINDOW_CATEGORY[:enable]
    category_enable ? menu_luna_on_item_cancel : return_scene
    @item_window.unselect
    @item_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: show_sub_window
  #--------------------------------------------------------------------------
  def show_sub_window(window)
    window.show.activate
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: hide_sub_window
  #--------------------------------------------------------------------------
  def hide_sub_window(window)
    window.hide.deactivate
    activate_item_window
  end
  
  #--------------------------------------------------------------------------
  # new method: status_window
  #--------------------------------------------------------------------------
  def status_window
    @actor_window
  end
  
end # Scene_Item

#==============================================================================
# ■ Window_SkillHelp
#==============================================================================

class Window_SkillHelp < Window_Help
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(line_number)
    init_position
    update_padding
    create_contents
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(line_number) + setting[:height_buff]
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::SkillMenu::WINDOW_HELP
  end
  
  #--------------------------------------------------------------------------
  # line_number
  #--------------------------------------------------------------------------
  def line_number
    setting[:line_number]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_SkillHelp

#==============================================================================
# ■ Window_SkillCommand
#==============================================================================

class Window_SkillCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias battle_luna_initialize initialize
  def initialize(x, y)
    battle_luna_initialize(x, y)
    self.arrows_visible = setting[:arrow]
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    setting[:item_height]
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    setting[:enable] ? eval(setting[:x].to_s) : 999
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    setting[:vertical] ? 1 : [item_max, 1].max
  end

  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    8
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: alignment
  #--------------------------------------------------------------------------
  def alignment
    setting[:align]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::SkillMenu::WINDOW_CATEGORY
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(index, contents, rect, enable, select)
    MenuLuna::SkillMenu.category_text(index, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    clear_item(index)
    rect = item_rect(index)
    enable = command_enabled?(index)
    select = index == self.index
    return menu_luna_draw_item(index) if texts(index, contents, rect, enable, select).nil?
    reset_font_settings
    hash = texts(index, contents, rect, enable, select)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    setting[:cursor] ? menu_luna_update_cursor : cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    draw_item(@index) if current_data
    @index = index
    draw_item(@index) if current_data
    update_cursor
    call_update_help
  end
  
end # Window_SkillCommand

#==============================================================================
# ■ Window_SkillListLuna
#==============================================================================

class Window_SkillListLuna < Window_SkillList
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #-------------------------------------------------------------------------- 
  def initialize(x, y, width, height)
    super(screen_x, screen_y, window_width, window_height)
    self.arrows_visible = setting[:arrow]
    refresh_background
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
    refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def col_max
    [1, setting[:column]].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    [line_height, setting[:item_height]].max
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::SkillMenu::WINDOW_ITEM
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # alias method: include?
  #--------------------------------------------------------------------------
  alias menu_luna_include? include?
  def include?(item)
    category_enable = MenuLuna::SkillMenu::WINDOW_CATEGORY[:enable]
    category_enable ? menu_luna_include?(item) : item
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: select_last
  #--------------------------------------------------------------------------
  def select_last
    last = @actor.last_skill.object
    last ? select(@data.index(last) || 0) : select(0)
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(item, contents, rect, enable, select)
    MenuLuna::SkillMenu.skill_text(item, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    clear_item(index)
    item = @data[index]
    select = index == self.index
    if item
      rect = item_rect(index)
      enable = enable?(item)
      return menu_luna_draw_item(index) if texts(item, contents, rect, enable, select).nil?
      reset_font_settings
      hash = texts(item, contents, rect, enable, select)
      hash[0].each { |val|
        draw_lunatic(val, hash[1])
      }
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    setting[:cursor] ? menu_luna_update_cursor : cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    draw_item(@index) if @index >= 0
    @index = index
    draw_item(@index) if @index >= 0
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_rect
  #--------------------------------------------------------------------------
  alias menu_luna_item_rect item_rect
  def item_rect(index)
    return menu_luna_item_rect(index) unless setting[:item_rect][:custom]
    rect = Rect.new
    item_width = setting[:item_rect][:width]
    item_height = setting[:item_rect][:height]
    spacing_ver = setting[:item_rect][:spacing_ver]
    spacing_hor = setting[:item_rect][:spacing_hor]
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing_hor)
    rect.y = index / col_max * (item_height + spacing_ver)
    rect
  end
  
end # Window_SkillListLuna

#==============================================================================
# ■ Window_SkillMenuActor
#==============================================================================

class Window_SkillMenuActor < Window_MenuActor
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias menu_luna_initialize initialize
  def initialize
    menu_luna_initialize
    self.arrows_visible = MenuLuna::SkillMenu::STATUS_WINDOW[:arrow]
    select(0) if lunatic[:autoselect]
    init_position
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
  end
  
  #--------------------------------------------------------------------------
  # new method: actor
  #--------------------------------------------------------------------------
  def actor
    @index < 0 ? nil : $game_party.members[@index]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    if is_lunatic?
      vertical = lunatic[:vertical]
    else
      vertical = MenuLuna::MainMenu::BATTLER_STATUS[:vertical]
    end
    vertical ? 1 : [1, lunatic[:scroll] ? lunatic[:col_max] : item_max].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    width = MenuLuna::SkillMenu::STATUS_WINDOW[:width]
    [width, standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    height = MenuLuna::SkillMenu::STATUS_WINDOW[:height]
    [height, standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [lunatic[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    [lunatic[:spacing], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    MenuLuna::SkillMenu::STATUS_WINDOW[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    MenuLuna::SkillMenu::STATUS_WINDOW[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    MenuLuna::SkillMenu::STATUS_WINDOW[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::SkillMenu::STATUS_WINDOW
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    MenuLuna::SkillMenu::STATUS_WINDOW[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def is_lunatic?
    MenuLuna::SkillMenu::BATTLER_STATUS[:lunatic]
  end
  
  #--------------------------------------------------------------------------
  # new method: lunatic
  #--------------------------------------------------------------------------
  def lunatic
    MenuLuna::SkillMenu::STATUS_WINDOW[:lunatic]
  end
  
  #--------------------------------------------------------------------------
  # new method: type
  #--------------------------------------------------------------------------
  def type
    MenuLuna::SkillMenu::STATUS_WINDOW[:back_type]
  end

  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias menu_luna_refresh refresh
  def refresh
    is_lunatic? ? menu_luna_refresh : contents.clear
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    if MenuLuna::SkillMenu::STATUS_WINDOW[:cursor]
      menu_luna_update_cursor
    else
      cursor_rect.empty
    end
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: draw_item_background
  #--------------------------------------------------------------------------
  def draw_item_background(index)
    # Temporarily removed.
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: contents_width
  #--------------------------------------------------------------------------
  alias menu_luna_contents_width contents_width
  def contents_width
    if is_lunatic? && !lunatic[:vertical] && lunatic[:scroll]
      return (item_width + spacing) * item_max - spacing
    else
      return menu_luna_contents_width
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: contents_height
  #--------------------------------------------------------------------------
  alias menu_luna_contents_height contents_height
  def contents_height
    if is_lunatic? && !lunatic[:vertical] && lunatic[:scroll]
      return window_height - standard_padding * 2
    else
      return menu_luna_contents_height
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_rect
  #--------------------------------------------------------------------------
  def item_rect(index)
    if !lunatic[:vertical] && lunatic[:scroll]
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index * (item_width + spacing) + lunatic[:item_rect][:x]
      rect.y = lunatic[:item_rect][:y]
      return rect
    else
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index % col_max * (item_width + spacing) + lunatic[:item_rect][:x]
      rect.y = index / col_max * item_height + lunatic[:item_rect][:y]
      return rect
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_width
  #--------------------------------------------------------------------------
  def item_width
    lunatic[:item_rect][:width]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    lunatic[:item_rect][:height]
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(index, actor, contents, item_rect, enable, select, formation)
    MenuLuna::SkillMenu.status_text(index, actor, contents, item_rect, enable, select, formation)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    return unless is_lunatic?
    clear_item(index)
    actor = $game_party.members[index]
    rect = item_rect(index)
    enable = $game_party.battle_members.include?(actor)
    select = index == self.index
    formation = index == @pending_index
    return menu_luna_draw_item(index) if texts(index, actor, contents, rect, enable, select, formation).nil?
    reset_font_settings
    hash = texts(index, actor, contents, rect, enable, select, formation)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    return unless is_lunatic?
    if lunatic[:refresh]
      refresh
    else
      draw_item(last_index)
      draw_item(@index)
    end
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    last_index = @index
    @index = index
    draw_item(last_index) if last_index >= 0
    draw_item(@index) if @index >= 0
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # top_col
  #--------------------------------------------------------------------------
  def top_col
    ox / (item_width + spacing)
  end
  
  #--------------------------------------------------------------------------
  # top_col=
  #--------------------------------------------------------------------------
  def top_col=(col)
    if !lunatic[:vertical] && lunatic[:scroll]
      col = 0 if col < 0
      col = col_max - 1 if col > col_max - 1
      self.ox = col * (item_width + spacing)
    else
      col = 0 if col < 0
      col = col
      self.ox = col * (item_width + spacing)
    end
  end
  
  #--------------------------------------------------------------------------
  # bottom_col
  #--------------------------------------------------------------------------
  def bottom_col
    top_col + col_max - 1
  end
  
  #--------------------------------------------------------------------------
  # bottom_col=
  #--------------------------------------------------------------------------
  def bottom_col=(col)
    self.top_col = col - (col_max - 1)
  end
  
  #--------------------------------------------------------------------------
  # ensure_cursor_visible
  #--------------------------------------------------------------------------
  alias menu_luna_ensure_cursor_visible ensure_cursor_visible
  def ensure_cursor_visible
    if !lunatic[:vertical]
      self.top_col = index if index < top_col
      self.bottom_col = index if index > bottom_col
    else
      menu_luna_ensure_cursor_visible
    end
  end
  
end # Window_SkillMenuActor

#==============================================================================
# ■ Window_SkillStatus
#==============================================================================

class Window_SkillStatus < Window_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @actor = nil
    refresh_background
    init_position
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    setting[:enable] ? eval(setting[:x].to_s) : 999
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::SkillMenu::CURRENT_ACTOR_WINDOW
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def refresh
    # Removed.
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_SkillStatus

#==============================================================================
# ■ Spriteset_SkillStatus
#==============================================================================

class Spriteset_SkillStatus < Spriteset_MenuStatus
  
  #--------------------------------------------------------------------------
  # overwrite method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end

  #--------------------------------------------------------------------------
  # overwrite method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::SkillMenu::CURRENT_ACTOR_STATUS
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_select
  #--------------------------------------------------------------------------
  def create_select
    # Removed.
  end
  
  #--------------------------------------------------------------------------
  # opacity
  #--------------------------------------------------------------------------
  def opacity
    255
  end
  
  #--------------------------------------------------------------------------
  # visible
  #--------------------------------------------------------------------------
  def visible
    setting[:enable] ? true : false
  end
  
end # Spriteset_SkillStatus

#==============================================================================
# ■ Window_SkillDescription
#==============================================================================

class Window_SkillDescription < Window_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize(window_item)
    super(init_screen_x, init_screen_y, window_width, window_height)
    self.width  = window_width
    self.height = window_height
    @window_item = window_item
    create_contents
    refresh
    refresh_background
    init_position
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: window_item
  #--------------------------------------------------------------------------
  def window_item=(window)
    contents.clear
    @window_item = window
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    setting[:enable] ? eval(setting[:x].to_s) : 999
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::SkillMenu::WINDOW_DESCRIPTION
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts(item, contents)
    MenuLuna::SkillMenu::description_text(item, contents)
  end
  
  #--------------------------------------------------------------------------
  # new method: refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @window_item
    return if @window_item.item.nil?
    return if texts(@window_item.item, contents).nil?
    reset_font_settings
    hash = texts(@window_item.item, contents)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias luna_menu_update update
  def update
    luna_menu_update
    #---
    if @window_item && (@item != @window_item.item || !@window_item.active)
      @item = @window_item.item
      refresh
    end
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_SkillDescription

#==============================================================================
# ■ Scene_Skill
#==============================================================================

class Scene_Skill < Scene_ItemBase
  
  #--------------------------------------------------------------------------
  # alias method: start
  #--------------------------------------------------------------------------
  alias menu_luna_start start
  def start
    menu_luna_start
    create_menu_status
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_actor_window
  #--------------------------------------------------------------------------
  def create_actor_window
    @actor_window = Window_SkillMenuActor.new
    @actor_window.viewport = @viewport
    @actor_window.set_handler(:ok,     method(:on_actor_ok))
    @actor_window.set_handler(:cancel, method(:on_actor_cancel))
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_help_window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_SkillHelp.new
    @help_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_status_window
  #--------------------------------------------------------------------------
  alias menu_luna_create_status_window create_status_window
  def create_status_window
    menu_luna_create_status_window
    @current_status = Spriteset_SkillStatus.new(@viewport, @actor, :skillmenusub)
    @current_status.setting = :skillmenusub
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_command_window
  #--------------------------------------------------------------------------
  alias menu_luna_create_command_window create_command_window
  def create_command_window
    menu_luna_create_command_window
    @command_window.init_position
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_item_window
  #--------------------------------------------------------------------------
  def create_item_window
    @item_window = Window_SkillListLuna.new(0, 0, Graphics.width, Graphics.height)
    @item_window.viewport = @viewport
    @item_window.actor = @actor
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @command_window.skill_window = @item_window
    #---
    @description_window = Window_SkillDescription.new(@item_window)
    @description_window.viewport = @viewport
    #---
    init_category
  end
  
  #--------------------------------------------------------------------------
  # new method: create_menu_status
  #--------------------------------------------------------------------------
  def create_menu_status
    @menu_status = LunaMenu_Status.new(@viewport, :skillmenu)
    @menu_status.actor_window = @actor_window
    @menu_status.update
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias menu_luna_update update
  def update
    menu_luna_update
    @menu_status.update
    @current_status.update
  end
  
  #--------------------------------------------------------------------------
  # alias method: terminate
  #--------------------------------------------------------------------------
  alias menu_luna_terminate terminate
  def terminate
    menu_luna_terminate
    @menu_status.dispose
    @current_status.dispose
  end
  
  #--------------------------------------------------------------------------
  # new method: init_category
  #--------------------------------------------------------------------------
  def init_category
    return if MenuLuna::SkillMenu::WINDOW_CATEGORY[:enable]
    @command_window.deactivate
    @item_window.activate
    @item_window.select_last
    @item_window.set_handler(:pagedown, method(:next_actor))
    @item_window.set_handler(:pageup,   method(:prev_actor))
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_item_cancel
  #--------------------------------------------------------------------------
  alias menu_luna_on_item_cancel on_item_cancel
  def on_item_cancel
    category_enable = MenuLuna::SkillMenu::WINDOW_CATEGORY[:enable]
    category_enable ? menu_luna_on_item_cancel : return_scene
    @item_window.unselect
    @item_window.refresh
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: show_sub_window
  #--------------------------------------------------------------------------
  def show_sub_window(window)
    window.show.activate
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: hide_sub_window
  #--------------------------------------------------------------------------
  def hide_sub_window(window)
    window.hide.deactivate
    activate_item_window
  end
  
  #--------------------------------------------------------------------------
  # new method: status_window
  #--------------------------------------------------------------------------
  def status_window
    @actor_window
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_actor_change
  #--------------------------------------------------------------------------
  alias menu_luna_on_actor_change on_actor_change
  def on_actor_change
    menu_luna_on_actor_change
    @current_status.battler = @actor
  end
  
end # Scene_Skill

#==============================================================================
# ■ Window_Status
#==============================================================================

class Window_Status < Window_Selectable
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 0, window_width, window_height)
    @actor = actor
    refresh
    refresh_background
    init_position
    activate
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    eval(setting[:x].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end

  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    8
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::StatusMenu::STATUS_WINDOW
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts(actor, contents)
    MenuLuna::StatusMenu::status_text(actor, contents)
  end
  
  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias menu_luna_refresh refresh
  def refresh
    return menu_luna_refresh if texts(@actor, contents).nil?
    contents.clear
    reset_font_settings
    hash = texts(@actor, contents)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_Status

#==============================================================================
# ■ Window_EquipHelp
#==============================================================================

class Window_EquipHelp < Window_Help
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(line_number)
    init_position
    update_padding
    create_contents
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(line_number) + setting[:height_buff]
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::EquipMenu::WINDOW_HELP
  end
  
  #--------------------------------------------------------------------------
  # line_number
  #--------------------------------------------------------------------------
  def line_number
    setting[:line_number]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_SkillHelp

#==============================================================================
# ■ Window_EquipItem
#==============================================================================

class Window_EquipItem < Window_ItemList
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #-------------------------------------------------------------------------- 
  def initialize(x, y, width, height)
    super(screen_x, screen_y, window_width, window_height)
    self.arrows_visible = setting[:arrow]
    @slot_id = 0
    refresh_background
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
    refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    [line_height, setting[:item_height]].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def col_max
    [1, setting[:column]].max
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::EquipMenu::WINDOW_ITEM
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end

  #--------------------------------------------------------------------------
  # overwrite method: select_last
  #--------------------------------------------------------------------------
  def select_last
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(item, contents, rect, enable, select)
    MenuLuna::EquipMenu.item_text(item, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    clear_item(index)
    item = @data[index]
    select = index == self.index
    if item
      rect = item_rect(index)
      enable = enable?(item)
      return menu_luna_draw_item(index) if texts(item, contents, rect, enable, select).nil?
      reset_font_settings
      hash = texts(item, contents, rect, enable, select)
      hash[0].each { |val|
        draw_lunatic(val, hash[1])
      }
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    setting[:cursor] ? menu_luna_update_cursor : cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    draw_item(@index) if @index >= 0
    @index = index
    draw_item(@index) if @index >= 0
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: include?
  #--------------------------------------------------------------------------
  def include?(item)
    return true if item == nil
    return false unless @actor
    return false unless item.is_a?(RPG::EquipItem)
    return false if @slot_id < 0
    return false if item.etype_id != @actor.equip_slots[@slot_id]
    return @actor.equippable?(item)
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_rect
  #--------------------------------------------------------------------------
  alias menu_luna_item_rect item_rect
  def item_rect(index)
    return menu_luna_item_rect(index) unless setting[:item_rect][:custom]
    rect = Rect.new
    item_width = setting[:item_rect][:width]
    item_height = setting[:item_rect][:height]
    spacing_ver = setting[:item_rect][:spacing_ver]
    spacing_hor = setting[:item_rect][:spacing_hor]
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing_hor)
    rect.y = index / col_max * (item_height + spacing_ver)
    rect
  end
  
end # Window_EquipItem

#==============================================================================
# ■ Window_EquipCommand
#==============================================================================

class Window_EquipCommand < Window_HorzCommand
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias battle_luna_initialize initialize
  def initialize(x, y, width)
    battle_luna_initialize(init_screen_x, init_screen_y, window_width)
    self.arrows_visible = setting[:arrow]
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    setting[:item_height]
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    setting[:enable] ? eval(setting[:x].to_s) : 999
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    setting[:vertical] ? 1 : [item_max, 1].max
  end
  
  #--------------------------------------------------------------------------
  # contents_width
  #--------------------------------------------------------------------------
  alias menu_luna_contents_width contents_width
  def contents_width
    setting[:vertical] ? width - standard_padding * 2 : menu_luna_contents_width
  end
  
  #--------------------------------------------------------------------------
  # alias method: contents_height
  #--------------------------------------------------------------------------
  alias menu_luna_contents_height contents_height
  def contents_height
    setting[:vertical] ? [super - super % item_height, row_max * item_height].max : menu_luna_contents_height
  end

  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    8
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: alignment
  #--------------------------------------------------------------------------
  def alignment
    setting[:align]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::EquipMenu::WINDOW_COMMANDS
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(index, contents, rect, enable, select)
    MenuLuna::EquipMenu.command_text(index, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    clear_item(index)
    rect = item_rect(index)
    enable = command_enabled?(index)
    select = index == self.index
    return menu_luna_draw_item(index) if texts(index, contents, rect, enable, select).nil?
    reset_font_settings
    hash = texts(index, contents, rect, enable, select)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    setting[:cursor] ? menu_luna_update_cursor : cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    draw_item(@index) if current_data
    @index = index
    draw_item(@index) if current_data
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # cursor_down
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    if index < item_max - col_max || (wrap && col_max == 1)
      select((index + col_max) % item_max)
    end
  end
  
  #--------------------------------------------------------------------------
  # cursor_up
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    if index >= col_max || (wrap && col_max == 1)
      select((index - col_max + item_max) % item_max)
    end
  end
  
  #--------------------------------------------------------------------------
  # item_rect
  #--------------------------------------------------------------------------
  alias menu_luna_item_rect item_rect
  def item_rect(index)
    if setting[:vertical]
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index % col_max * (item_width + spacing)
      rect.y = index / col_max * item_height
      return rect
    else
      return menu_luna_item_rect(index)
    end
  end
  
  #--------------------------------------------------------------------------
  # ensure_cursor_visible
  #--------------------------------------------------------------------------
  alias menu_luna_ensure_cursor_visible ensure_cursor_visible
  def ensure_cursor_visible
    if setting[:vertical]
      self.top_row = row if row < top_row
      self.bottom_row = row if row > bottom_row
    else
      menu_luna_ensure_cursor_visible
    end
  end
  
end # Window_EquipCommand

#==============================================================================
# ■ Window_EquipSlot
#==============================================================================

class Window_EquipSlot < Window_Selectable
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #-------------------------------------------------------------------------- 
  def initialize(x, y, width)
    super(screen_x, screen_y, window_width, window_height)
    @actor = nil
    refresh_background
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
    refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def col_max
    1
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    [line_height, setting[:item_height]].max
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::EquipMenu::WINDOW_SLOT
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias luna_menu_update update
  def update
    luna_menu_update
    @item_window.slot_id = index if @item_window
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
    
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(index, item, contents, rect, enable, select)
    MenuLuna::EquipMenu.slot_text(index, item, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    clear_item(index)
    return unless @actor
    rect = item_rect(index)
    enable = enable?(index)
    select = self.index == index
    item = @actor.equips[index]
    return menu_luna_draw_item(index) if texts(index, item, contents, rect, enable, select).nil?
    reset_font_settings
    hash = texts(index, item, contents, rect, enable, select)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    setting[:cursor] ? menu_luna_update_cursor : cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    draw_item(@index) if @index >= 0
    @index = index
    draw_item(@index) if @index >= 0
    update_cursor
    call_update_help
  end
  
end # Window_EquipSlot

#==============================================================================
# ■ Window_EquipStatus
#==============================================================================

class Window_EquipStatus < Window_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @actor = nil
    @temp_actor = nil
    refresh_background
    init_position
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    eval(setting[:x].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::EquipMenu::STATUS_WINDOW
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts(actor, temp_actor, contents)
    MenuLuna::EquipMenu::status_text(actor, temp_actor, contents)
  end
  
  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias menu_luna_refresh refresh
  def refresh
    return menu_luna_refresh if texts(@actor, @temp_actor, contents).nil?
    contents.clear
    reset_font_settings
    hash = texts(@actor, @temp_actor, contents)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
end # Window_EquipStatus

#==============================================================================
# ■ Window_EquipDescription
#==============================================================================

class Window_EquipDescription < Window_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize(window_item)
    super(init_screen_x, init_screen_y, window_width, window_height)
    self.width  = window_width
    self.height = window_height
    @window_item = window_item
    create_contents
    refresh
    refresh_background
    init_position
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: window_item
  #--------------------------------------------------------------------------
  def window_item=(window)
    contents.clear
    @window_item = window
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    setting[:enable] ? eval(setting[:x].to_s) : 999
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::EquipMenu::WINDOW_DESCRIPTION
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts(item, contents)
    MenuLuna::EquipMenu::description_text(item, contents)
  end
  
  #--------------------------------------------------------------------------
  # new method: refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @window_item
    return if @window_item.item.nil?
    return if texts(@window_item.item, contents).nil?
    reset_font_settings
    hash = texts(@window_item.item, contents)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: update
  #--------------------------------------------------------------------------
  alias luna_menu_update update
  def update
    luna_menu_update
    #---
    if @window_item && (@item != @window_item.item || !@window_item.active)
      @item = @window_item.item
      refresh
    end
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_EquipDescription

#==============================================================================
# ■ Scene_Equip
#==============================================================================

class Scene_Equip < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # alias method: start
  #--------------------------------------------------------------------------
  alias menu_luna_start start
  def start
    menu_luna_start
    create_description_window
    init_commands
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_help_window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_EquipHelp.new
    @help_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_description_window
  #--------------------------------------------------------------------------
  def create_description_window
    @description_window = Window_EquipDescription.new(@item_window)
    @description_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # new method: init_commands
  #--------------------------------------------------------------------------
  def init_commands
    return if MenuLuna::EquipMenu::WINDOW_COMMANDS[:enable]
    @command_window.deactivate
    @slot_window.activate
    @slot_window.set_handler(:pagedown, method(:next_actor))
    @slot_window.set_handler(:pageup,   method(:prev_actor))
    @slot_window.select(0)
    @description_window.window_item = @slot_window
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_item_ok
  #--------------------------------------------------------------------------
  alias menu_luna_on_item_ok on_item_ok
  def on_item_ok
    menu_luna_on_item_ok
    @description_window.window_item = @slot_window
  end

  #--------------------------------------------------------------------------
  # alias method: on_item_cancel
  #--------------------------------------------------------------------------
  alias menu_luna_on_item_cancel on_item_cancel
  def on_item_cancel
    menu_luna_on_item_cancel
    @description_window.window_item = @slot_window
  end

  #--------------------------------------------------------------------------
  # alias method: on_slot_ok
  #--------------------------------------------------------------------------
  alias menu_luna_on_slot_ok on_slot_ok
  def on_slot_ok
    menu_luna_on_slot_ok
    @description_window.window_item = @item_window
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_slot_cancel
  #--------------------------------------------------------------------------
  alias menu_luna_on_slot_cancel on_slot_cancel
  def on_slot_cancel
    return_scene unless MenuLuna::EquipMenu::WINDOW_COMMANDS[:enable]
    menu_luna_on_slot_cancel
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_actor_change
  #--------------------------------------------------------------------------
  alias menu_luna_on_actor_change on_actor_change
  def on_actor_change
    menu_luna_on_actor_change
    init_commands
  end
  
end # Scene_Equip

#==============================================================================
# ■ Window_SaveHelp
#==============================================================================

class Window_SaveHelp < Window_Help
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(line_number)
    init_position
    update_padding
    create_contents
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(line_number) + setting[:height_buff]
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::SaveMenu::WINDOW_HELP
  end
  
  #--------------------------------------------------------------------------
  # line_number
  #--------------------------------------------------------------------------
  def line_number
    setting[:line_number]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_SaveHelp

#==============================================================================
# ■ Window_SaveFile
#==============================================================================

class Window_SaveFile < Window_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize(height, index)
    super(0, index * window_height, window_width, window_height)
    @file_index = index
    @selected = false
    refresh
    refresh_background
    init_position
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def standard_padding
    setting[:padding]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::SaveMenu::WINDOW_SAVE
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts(contents)
    MenuLuna::SaveMenu::save_text(@file_index, contents, @selected)
  end
  
  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias menu_luna_refresh refresh
  def refresh
    return menu_luna_refresh if texts(contents).nil?
    contents.clear
    reset_font_settings
    hash = texts(contents)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def selected=(selected)
    @selected = selected
    update_cursor
    refresh
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update_cursor
  #--------------------------------------------------------------------------
  def update_cursor
    cs = setting[:cursor]
    if @selected && cs[:enable]
      cursor_rect.set(cs[:x], cs[:y], eval(cs[:width].to_s), eval(cs[:height].to_s))
    else
      cursor_rect.empty
    end
  end
  
end # Window_SaveFile

#==============================================================================
# ■ Scene_File
#==============================================================================

class Scene_File < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # overwrite method: create_savefile_viewport
  #--------------------------------------------------------------------------
  def create_savefile_viewport
    @savefile_viewport = Viewport.new
    @savefile_viewport.z = setting[:z]
    @savefile_viewport.rect.x = setting[:x]
    @savefile_viewport.rect.y = setting[:y]
    height = setting[:item_max] * MenuLuna::SaveMenu::WINDOW_SAVE[:height]
    @savefile_viewport.rect.height = height
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: visible_max
  #--------------------------------------------------------------------------
  def visible_max
    return setting[:item_max]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::SaveMenu::SAVE_VIEWPORT
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_help_window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_SaveHelp.new
    @help_window.viewport = @viewport
    @help_window.set_text(help_window_text)
  end
  
end # Scene_File

#==============================================================================
# ■ Window_ShopHelp
#==============================================================================

class Window_ShopHelp < Window_Help
  
  #--------------------------------------------------------------------------
  # initialize
  #--------------------------------------------------------------------------
  def initialize
    super(line_number)
    init_position
    update_padding
    create_contents
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
  end
  
  #--------------------------------------------------------------------------
  # window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # window_height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(line_number) + setting[:height_buff]
  end
  
  #--------------------------------------------------------------------------
  # setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ShopMenu::WINDOW_HELP
  end
  
  #--------------------------------------------------------------------------
  # line_number
  #--------------------------------------------------------------------------
  def line_number
    setting[:line_number]
  end
  
  #--------------------------------------------------------------------------
  # screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_ShopHelp

#==============================================================================
# ■ Window_ShopCommand
#==============================================================================

class Window_ShopCommand < Window_HorzCommand
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias battle_luna_initialize initialize
  def initialize(window_width, purchase_only)
    battle_luna_initialize(window_width, purchase_only)
    self.arrows_visible = setting[:arrow]
    refresh_background
    init_position
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    setting[:item_height]
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    eval(setting[:x].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    setting[:vertical] ? 1 : [item_max, 1].max
  end

  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    8
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: alignment
  #--------------------------------------------------------------------------
  def alignment
    setting[:align]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ShopMenu::WINDOW_COMMANDS
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(index, contents, rect, enable, select)
    MenuLuna::ShopMenu.command_text(index, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    clear_item(index)
    rect = item_rect(index)
    enable = command_enabled?(index)
    select = index == self.index
    return menu_luna_draw_item(index) if texts(index, contents, rect, enable, select).nil?
    reset_font_settings
    hash = texts(index, contents, rect, enable, select)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    setting[:cursor] ? menu_luna_update_cursor : cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    draw_item(@index) if current_data
    @index = index
    draw_item(@index) if current_data
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # cursor_down
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    if index < item_max - col_max || (wrap && col_max == 1)
      select((index + col_max) % item_max)
    end
  end
  
  #--------------------------------------------------------------------------
  # cursor_up
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    if index >= col_max || (wrap && col_max == 1)
      select((index - col_max + item_max) % item_max)
    end
  end
  
  #--------------------------------------------------------------------------
  # contents_width
  #--------------------------------------------------------------------------
  alias menu_luna_contents_width contents_width
  def contents_width
    setting[:vertical] ? width - standard_padding * 2 : menu_luna_contents_width
  end
  
  #--------------------------------------------------------------------------
  # alias method: contents_height
  #--------------------------------------------------------------------------
  alias menu_luna_contents_height contents_height
  def contents_height
    setting[:vertical] ? [super - super % item_height, row_max * item_height].max : menu_luna_contents_height
  end
  
  #--------------------------------------------------------------------------
  # item_rect
  #--------------------------------------------------------------------------
  alias menu_luna_item_rect item_rect
  def item_rect(index)
    if setting[:vertical]
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index % col_max * (item_width + spacing)
      rect.y = index / col_max * item_height
      return rect
    else
      return menu_luna_item_rect(index)
    end
  end
  
end # Window_ShopCommand

#==============================================================================
# ■ Window_ItemCategoryShop
#==============================================================================

class Window_ItemCategoryShop < Window_ItemCategory
  
  #--------------------------------------------------------------------------
  # alias method: initialize
  #--------------------------------------------------------------------------
  alias battle_luna_initialize initialize
  def initialize
    battle_luna_initialize
    self.arrows_visible = setting[:arrow]
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    setting[:item_height]
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    setting[:enable] ? eval(setting[:x].to_s) : 999
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: col_max
  #--------------------------------------------------------------------------
  def col_max
    setting[:vertical] ? 1 : [item_max, 1].max
  end

  #--------------------------------------------------------------------------
  # overwrite method: spacing
  #--------------------------------------------------------------------------
  def spacing
    8
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: alignment
  #--------------------------------------------------------------------------
  def alignment
    setting[:align]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ShopMenu::WINDOW_CATEGORY
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(index, contents, rect, enable, select)
    MenuLuna::ShopMenu.category_text(index, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    clear_item(index)
    rect = item_rect(index)
    enable = command_enabled?(index)
    select = index == self.index
    return menu_luna_draw_item(index) if texts(index, contents, rect, enable, select).nil?
    reset_font_settings
    hash = texts(index, contents, rect, enable, select)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    setting[:cursor] ? menu_luna_update_cursor : cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    draw_item(@index) if current_data
    @index = index
    draw_item(@index) if current_data
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # cursor_down
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
    if index < item_max - col_max || (wrap && col_max == 1)
      select((index + col_max) % item_max)
    end
  end
  
  #--------------------------------------------------------------------------
  # cursor_up
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
    if index >= col_max || (wrap && col_max == 1)
      select((index - col_max + item_max) % item_max)
    end
  end
  
  #--------------------------------------------------------------------------
  # contents_width
  #--------------------------------------------------------------------------
  alias menu_luna_contents_width contents_width
  def contents_width
    setting[:vertical] ? width - standard_padding * 2 : menu_luna_contents_width
  end
  
  #--------------------------------------------------------------------------
  # alias method: contents_height
  #--------------------------------------------------------------------------
  alias menu_luna_contents_height contents_height
  def contents_height
    setting[:vertical] ? [super - super % item_height, row_max * item_height].max : menu_luna_contents_height
  end
  
  #--------------------------------------------------------------------------
  # item_rect
  #--------------------------------------------------------------------------
  alias menu_luna_item_rect item_rect
  def item_rect(index)
    if setting[:vertical]
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index % col_max * (item_width + spacing)
      rect.y = index / col_max * item_height
      return rect
    else
      return menu_luna_item_rect(index)
    end
  end
  
end # Window_ItemCategoryShop

#==============================================================================
# ■ Window_ShopBuy
#==============================================================================

class Window_ShopBuy < Window_Selectable
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #-------------------------------------------------------------------------- 
  def initialize(x, y, height, shop_goods)
    super(screen_x, screen_y, window_width, window_height)
    self.arrows_visible = setting[:arrow]
    @shop_goods = shop_goods
    @money = 0
    select(0)
    refresh_background
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
    refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    [line_height, setting[:item_height]].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def col_max
    [1, setting[:column]].max
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ShopMenu::WINDOW_ITEM_BUY
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(item, contents, rect, enable, select)
    MenuLuna::ShopMenu.buy_text(item, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    return unless @data
    clear_item(index)
    item = @data[index]
    select = index == self.index
    if item
      rect = item_rect(index)
      enable = enable?(item)
      return menu_luna_draw_item(index) if texts(item, contents, rect, enable, select).nil?
      reset_font_settings
      hash = texts(item, contents, rect, enable, select)
      hash[0].each { |val|
        draw_lunatic(val, hash[1])
      }
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    setting[:cursor] ? menu_luna_update_cursor : cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    draw_item(@index) if @index >= 0
    @index = index
    draw_item(@index) if @index >= 0
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_rect
  #--------------------------------------------------------------------------
  alias menu_luna_item_rect item_rect
  def item_rect(index)
    return menu_luna_item_rect(index) unless setting[:item_rect][:custom]
    rect = Rect.new
    item_width = setting[:item_rect][:width]
    item_height = setting[:item_rect][:height]
    spacing_ver = setting[:item_rect][:spacing_ver]
    spacing_hor = setting[:item_rect][:spacing_hor]
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing_hor)
    rect.y = index / col_max * (item_height + spacing_ver)
    rect
  end
  
end # Window_ShopBuy

#==============================================================================
# ■ Window_ItemListShop
#==============================================================================

class Window_ItemListShop < Window_ShopSell
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #-------------------------------------------------------------------------- 
  def initialize(x, y, width, height)
    super(screen_x, screen_y, window_width, window_height)
    self.arrows_visible = setting[:arrow]
    refresh_background
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = screen_x
    self.y = screen_y
    self.z = screen_z
    self.width = window_width
    self.height = window_height
    refresh
  end
  
  #--------------------------------------------------------------------------
  # new method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: item_height
  #--------------------------------------------------------------------------
  def item_height
    [line_height, setting[:item_height]].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def col_max
    [1, setting[:column]].max
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ShopMenu::WINDOW_ITEM_SELL
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_x
  #--------------------------------------------------------------------------
  def screen_x
    setting[:x]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_y
  #--------------------------------------------------------------------------
  def screen_y
    setting[:y]
  end
  
  #--------------------------------------------------------------------------
  # new method: screen_z
  #--------------------------------------------------------------------------
  def screen_z
    setting[:z]
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # alias method: include?
  #--------------------------------------------------------------------------
  alias menu_luna_include? include?
  def include?(item)
    category_enable = MenuLuna::ShopMenu::WINDOW_CATEGORY[:enable]
    category_enable ? menu_luna_include?(item) : true
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: select_last
  #--------------------------------------------------------------------------
  def select_last
    last = $game_party.last_item.object
    last ? select(@data.index(last) || 0) : select(0)
  end
  
  #--------------------------------------------------------------------------
  # new method: texts
  #--------------------------------------------------------------------------
  def texts(item, contents, rect, enable, select)
    MenuLuna::ShopMenu.sell_text(item, contents, rect, enable, select)
  end
  
  #--------------------------------------------------------------------------
  # alias method: draw_item
  #--------------------------------------------------------------------------
  alias menu_luna_draw_item draw_item
  def draw_item(index)
    clear_item(index)
    item = @data[index]
    select = index == self.index
    if item
      rect = item_rect(index)
      enable = enable?(item)
      return menu_luna_draw_item(index) if texts(item, contents, rect, enable, select).nil?
      reset_font_settings
      hash = texts(item, contents, rect, enable, select)
      hash[0].each { |val|
        draw_lunatic(val, hash[1])
      }
    end
  end
  
  #--------------------------------------------------------------------------
  # alias method: update_cursor
  #--------------------------------------------------------------------------
  alias menu_luna_update_cursor update_cursor
  def update_cursor
    setting[:cursor] ? menu_luna_update_cursor : cursor_rect.empty
    ensure_cursor_visible
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: process_cursor_move
  #--------------------------------------------------------------------------
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    return if @index == last_index
    draw_item(last_index)
    draw_item(@index)
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: index=
  #--------------------------------------------------------------------------
  def index=(index)
    draw_item(@index) if @index >= 0
    @index = index
    draw_item(@index) if @index >= 0
    update_cursor
    call_update_help
  end
  
  #--------------------------------------------------------------------------
  # alias method: item_rect
  #--------------------------------------------------------------------------
  alias menu_luna_item_rect item_rect
  def item_rect(index)
    return menu_luna_item_rect(index) unless setting[:item_rect][:custom]
    rect = Rect.new
    item_width = setting[:item_rect][:width]
    item_height = setting[:item_rect][:height]
    spacing_ver = setting[:item_rect][:spacing_ver]
    spacing_hor = setting[:item_rect][:spacing_hor]
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * (item_width + spacing_hor)
    rect.y = index / col_max * (item_height + spacing_ver)
    rect
  end
  
end # Window_ItemListShop

#==============================================================================
# ■ Window_ShopDummy
#==============================================================================

class Window_ShopDummy < Window_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, window_height)
    refresh_background
    init_position
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    setting[:enable] ? eval(setting[:x].to_s) : 9999
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end

  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ShopMenu::WINDOW_DUMMY
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_ShopDummy

#==============================================================================
# ■ Window_ShopGold
#==============================================================================

class Window_ShopGold < Window_Gold
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize
    super
    self.width  = window_width
    self.height = window_height
    create_contents
    refresh
    refresh_background
    init_position
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    eval(setting[:x].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ShopMenu::WINDOW_GOLD
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts(contents)
    MenuLuna::ShopMenu::gold_text(contents)
  end
  
  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias menu_luna_refresh refresh
  def refresh
    return menu_luna_refresh if texts(contents).nil?
    contents.clear
    reset_font_settings
    hash = texts(contents)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_MenuGold

#==============================================================================
# ■ Window_ShopNumber
#==============================================================================

class Window_ShopNumber < Window_Selectable
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, height)
    super(x, y, window_width, window_height)
    @item = nil
    @max = 1
    @price = 0
    @number = 1
    @currency_unit = Vocab::currency_unit
    refresh_background
    init_position
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    eval(setting[:x].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ShopMenu::WINDOW_NUMBER
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts(item, number, price, contents)
    MenuLuna::ShopMenu::number_text(item, number, price, contents)
  end
  
  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias menu_luna_refresh refresh
  def refresh
    return menu_luna_refresh if texts(@item, @number, @price, contents).nil?
    contents.clear
    reset_font_settings
    hash = texts(@item, @number, @price, contents)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias luna_menu_update update
  def update
    luna_menu_update
    #---
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: update_cursor
  #--------------------------------------------------------------------------
  def update_cursor
    cur = setting[:cursor]
    return cursor_rect.empty unless cur[:enable]
    cursor_rect.set(cur[:x], cur[:y], cur[:width], cur[:height])
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: cursor_x
  #--------------------------------------------------------------------------
  def cursor_x
    setting[:cursor][:x]
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: cursor_x
  #--------------------------------------------------------------------------
  def item_y
    setting[:cursor][:y]
  end
  
end # Window_ShopNumber

#==============================================================================
# ■ Window_ShopGold
#==============================================================================

class Window_ShopStatus < Window_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(init_screen_x, init_screen_y, window_width, window_height)
    init_position
    @item = nil
    @page_index = 0
    @lunatic_default = false
    refresh
    refresh_background
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    eval(setting[:x].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ShopMenu::WINDOW_STATUS
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts(index, item, actor, equippable, cur_item, possesion, contents)
    MenuLuna::ShopMenu::status_text(index, item, actor, equippable, cur_item, possesion, contents)
  end
  
  #--------------------------------------------------------------------------
  # alias method: refresh
  #--------------------------------------------------------------------------
  alias menu_luna_refresh refresh
  def refresh
    return menu_luna_refresh if texts(0, nil, nil, nil, nil, nil, contents).nil?
    contents.clear
    draw_equip_info(0, 0)
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: draw_equip_info
  #--------------------------------------------------------------------------
  def draw_equip_info(x, y)
    status_members.each_with_index do |actor, i|
      if texts(0, @item, nil, nil, nil, nil, contents).nil?
        draw_actor_equip_info(x, y + line_height * (i * 2.4), actor)
      else
        draw_actor_equip_info_luna(i, actor)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_actor_equip_info_luna
  #--------------------------------------------------------------------------
  def draw_actor_equip_info_luna(index, actor)
    if @item
      enabled = actor.equippable?(@item)
      cur_item = current_equipped_item(actor, @item.etype_id) rescue nil
      possession = $game_party.item_number(@item)
      reset_font_settings
      hash = texts(index, @item, actor, enabled, cur_item, possession, contents)
      hash[0].each { |val|
        draw_lunatic(val, hash[1])
      }
    end
  end
  
end # Window_MenuGold

#==============================================================================
# ■ Window_ShopDescription
#==============================================================================

class Window_ShopDescription < Window_Base
  
  #--------------------------------------------------------------------------
  # overwrite method: initialize
  #--------------------------------------------------------------------------
  def initialize(window_item)
    super(init_screen_x, init_screen_y, window_width, window_height)
    self.width  = window_width
    self.height = window_height
    @window_item = window_item
    create_contents
    refresh
    refresh_background
    init_position
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: window_item
  #--------------------------------------------------------------------------
  def window_item=(window)
    contents.clear
    @window_item = window
    refresh
    update
  end
  
  #--------------------------------------------------------------------------
  # new method: init_position
  #--------------------------------------------------------------------------
  def init_position
    self.x = init_screen_x
    self.y = init_screen_y
    self.z = init_screen_z
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_width
  #--------------------------------------------------------------------------
  def window_width
    [setting[:width], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: window_height
  #--------------------------------------------------------------------------
  def window_height
    [setting[:height], standard_padding * 2 + line_height].max
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: standard_padding
  #--------------------------------------------------------------------------
  def standard_padding
    [setting[:padding], 0].max
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_x
  #--------------------------------------------------------------------------
  def init_screen_x
    setting[:enable] ? eval(setting[:x].to_s) : 999
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_y
  #--------------------------------------------------------------------------
  def init_screen_y
    eval(setting[:y].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: init_screen_z
  #--------------------------------------------------------------------------
  def init_screen_z
    eval(setting[:z].to_s)
  end
  
  #--------------------------------------------------------------------------
  # new method: setting
  #--------------------------------------------------------------------------
  def setting
    MenuLuna::ShopMenu::WINDOW_DESCRIPTION
  end
  
  #--------------------------------------------------------------------------
  # new method: setting_type
  #--------------------------------------------------------------------------
  def setting_type
    type = setting[:back_type]
    setting[eval(":type_#{type}")]
  end
  
  #--------------------------------------------------------------------------
  # new method: text
  #--------------------------------------------------------------------------
  def texts(item, contents)
    MenuLuna::ShopMenu::description_text(item, contents)
  end
  
  #--------------------------------------------------------------------------
  # new method: refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @window_item
    return if @window_item.item.nil?
    return if texts(@window_item.item, contents).nil?
    reset_font_settings
    hash = texts(@window_item.item, contents)
    hash[0].each { |val|
      draw_lunatic(val, hash[1])
    }
  end
  
  #--------------------------------------------------------------------------
  # alias method: update
  #--------------------------------------------------------------------------
  alias luna_menu_update update
  def update
    luna_menu_update
    #---
    if @window_item && (@item != @window_item.item || !@window_item.active)
      @item = @window_item.item
      refresh
    end 
  end
    
  #--------------------------------------------------------------------------
  # overwrite method: dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    @bg_sprite.dispose if @bg_sprite
  end
  
end # Window_ShopDescription

#==============================================================================
# ■ Scene_Shop
#==============================================================================

class Scene_Shop < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # alias method: start
  #--------------------------------------------------------------------------
  alias menu_luna_start start
  def start
    menu_luna_start
    create_description_window
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_help_window
  #--------------------------------------------------------------------------
  def create_description_window
    @description_window = Window_ShopDescription.new(nil)
    @description_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_help_window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_ShopHelp.new
    @help_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_command_window
  #-------------------------------------------------------------------------- 
  alias menu_luna_create_command_window create_command_window 
  def create_command_window
    menu_luna_create_command_window
    @command_window.init_position
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_gold_window
  #-------------------------------------------------------------------------- 
  def create_gold_window
    @gold_window = Window_ShopGold.new
    @gold_window.viewport = @viewport
    @gold_window.update
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_dummy_window
  #-------------------------------------------------------------------------- 
  def create_dummy_window
    @dummy_window = Window_ShopDummy.new
    @dummy_window.viewport = @viewport
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_category_window
  #-------------------------------------------------------------------------- 
  def create_category_window
    @category_window = Window_ItemCategoryShop.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @dummy_window.y
    @category_window.hide.deactivate
    @category_window.update
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:on_category_cancel))
    @category_window.init_position
  end
  
  #--------------------------------------------------------------------------
  # alias method: create_buy_window
  #-------------------------------------------------------------------------- 
  alias luna_menu_create_buy_window create_buy_window
  def create_buy_window
    luna_menu_create_buy_window
    @buy_window.update
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: create_sell_window
  #--------------------------------------------------------------------------  
  def create_sell_window
    @sell_window = Window_ItemListShop.new(0, 0, Graphics.width, Graphics.height)
    @sell_window.viewport = @viewport
    @sell_window.help_window = @help_window
    @sell_window.hide
    @sell_window.update
    @sell_window.set_handler(:ok,     method(:on_sell_ok))
    @sell_window.set_handler(:cancel, method(:on_sell_cancel))
    @category_window.item_window = @sell_window
  end
  
  #--------------------------------------------------------------------------
  # alias method: command_buy
  #--------------------------------------------------------------------------
  alias menu_luna_command_buy command_buy
  def command_buy
    menu_luna_command_buy
    @description_window.window_item = @buy_window
  end
  
  #--------------------------------------------------------------------------
  # alias method: command_sell
  #--------------------------------------------------------------------------
  alias menu_luna_command_sell command_sell
  def command_sell
    category_enable = MenuLuna::ShopMenu::WINDOW_CATEGORY[:enable]
    menu_luna_command_sell
    @category_window.show.activate if category_enable
    @sell_window.activate.select(0) unless category_enable
    @description_window.window_item = @sell_window
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_buy_cancel
  #--------------------------------------------------------------------------
  alias menu_luna_on_buy_cancel on_buy_cancel
  def on_buy_cancel
    menu_luna_on_buy_cancel
    @description_window.window_item = nil
  end
  
  #--------------------------------------------------------------------------
  # alias method: on_sell_cancel
  #--------------------------------------------------------------------------
  alias menu_luna_on_sell_cancel on_sell_cancel
  def on_sell_cancel
    category_enable = MenuLuna::ShopMenu::WINDOW_CATEGORY[:enable]
    category_enable ? menu_luna_on_sell_cancel : on_category_cancel
    @description_window.window_item = nil
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: on_buy_ok
  #--------------------------------------------------------------------------
  def on_buy_ok
    option = MenuLuna::ShopMenu::WINDOW_NUMBER[:options]
    @item = @buy_window.item
    @buy_window.hide if option[:hide_list]
    @number_window.set(@item, max_buy, buying_price, currency_unit)
    @number_window.show.activate
    return unless option[:item_pos]
    @number_window.x = @buy_window.item_rect(@buy_window.index).x + option[:offset_x]
    @number_window.y = @buy_window.item_rect(@buy_window.index).y + option[:offset_y]
    @number_window.x += @buy_window.x + @buy_window.standard_padding
    @number_window.y += @buy_window.y + @buy_window.standard_padding
    @number_window.x -= @buy_window.ox
    @number_window.y -= @buy_window.oy
  end
  
  #--------------------------------------------------------------------------
  # overwrite method: on_sell_ok
  #--------------------------------------------------------------------------
  def on_sell_ok
    option = MenuLuna::ShopMenu::WINDOW_NUMBER[:options]
    @item = @sell_window.item
    @status_window.item = @item
    if option[:hide_list]
      @category_window.hide
      @sell_window.hide
    end
    @number_window.set(@item, max_sell, selling_price, currency_unit)
    @number_window.show.activate
    @status_window.show
    return unless option[:item_pos]
    @number_window.x = @sell_window.item_rect(@sell_window.index).x + option[:offset_x]
    @number_window.y = @sell_window.item_rect(@sell_window.index).y + option[:offset_y]
    @number_window.x += @sell_window.x + @sell_window.standard_padding
    @number_window.y += @sell_window.y + @sell_window.standard_padding
    @number_window.x -= @sell_window.ox
    @number_window.y -= @sell_window.oy
  end
    
end # Scene_Shop