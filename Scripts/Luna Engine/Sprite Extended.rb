#==============================================================================
# ■ Sprite
#==============================================================================

class Sprite
  
  #--------------------------------------------------------------------------
  # new method: text_color
  #--------------------------------------------------------------------------
  def text_color(n)
    Cache.system("Window").get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
  end
  
  #--------------------------------------------------------------------------
  # new methods: window colors
  #--------------------------------------------------------------------------
  def normal_color;      text_color(0);   end;    # Normal
  def system_color;      text_color(16);  end;    # System
  def crisis_color;      text_color(17);  end;    # Crisis
  def knockout_color;    text_color(18);  end;    # Knock out
  def gauge_back_color;  text_color(19);  end;    # Gauge background
  def hp_gauge_color1;   text_color(20);  end;    # HP gauge 1
  def hp_gauge_color2;   text_color(21);  end;    # HP gauge 2
  def mp_gauge_color1;   text_color(22);  end;    # MP gauge 1
  def mp_gauge_color2;   text_color(23);  end;    # MP gauge 2
  def mp_cost_color;     text_color(23);  end;    # TP cost
  def power_up_color;    text_color(24);  end;    # Equipment power up
  def power_down_color;  text_color(25);  end;    # Equipment power down
  def tp_gauge_color1;   text_color(28);  end;    # TP gauge 1
  def tp_gauge_color2;   text_color(29);  end;    # TP gauge 2
  def tp_cost_color;     text_color(29);  end;    # TP cost
  
  #--------------------------------------------------------------------------
  # new method: text_size
  #--------------------------------------------------------------------------
  def text_size(str)
    bitmap.text_size(str)
  end
  
  #--------------------------------------------------------------------------
  # new method: line_height
  #--------------------------------------------------------------------------
  def line_height
    24
  end
  
  #--------------------------------------------------------------------------
  # new method: actor_name
  #--------------------------------------------------------------------------
  def actor_name(n)
    actor = n >= 1 ? $game_actors[n] : nil
    actor ? actor.name : ""
  end

  #--------------------------------------------------------------------------
  # new method: party_member_name
  #--------------------------------------------------------------------------
  def party_member_name(n)
    actor = n >= 1 ? $game_party.members[n - 1] : nil
    actor ? actor.name : ""
  end
  
  #--------------------------------------------------------------------------
  # new method: calc_line_height
  #--------------------------------------------------------------------------
  def calc_line_height(text, restore_font_size = true)
    result = [line_height, bitmap.font.size].max
    last_font_size = bitmap.font.size
    text.slice(/^.*$/).scan(/\e[\{\}]/).each do |esc|
      make_font_bigger  if esc == "\e{"
      make_font_smaller if esc == "\e}"
      result = [result, bitmap.font.size].max
    end
    bitmap.font.size = last_font_size if restore_font_size
    result
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_text_ex
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    return unless self.bitmap
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end

  #--------------------------------------------------------------------------
  # new method: convert_escape_characters
  #--------------------------------------------------------------------------
  def convert_escape_characters(text)
    result = text.to_s.clone
    result.gsub!(/\\/)            { "\e" }
    result.gsub!(/\e\e/)          { "\\" }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eV\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/\eN\[(\d+)\]/i) { actor_name($1.to_i) }
    result.gsub!(/\eP\[(\d+)\]/i) { party_member_name($1.to_i) }
    result.gsub!(/\eG/i)          { Vocab::currency_unit }
    result
  end

  #--------------------------------------------------------------------------
  # new method: process_character
  #--------------------------------------------------------------------------
  def process_character(c, text, pos)
    case c
    when "\n"   # New line
      process_new_line(text, pos)
    when "\e"   # Control character
      process_escape_character(obtain_escape_code(text), text, pos)
    else        # Normal character
      process_normal_character(c, pos)
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: process_normal_character
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    text_width = text_size(c).width
    bitmap.draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
    pos[:x] += text_width
  end
  
  #--------------------------------------------------------------------------
  # new method: process_new_line
  #--------------------------------------------------------------------------
  def process_new_line(text, pos)
    pos[:x] = pos[:new_x]
    pos[:y] += pos[:height]
    pos[:height] = calc_line_height(text)
  end
  
  #--------------------------------------------------------------------------
  # new method: obtain_escape_code
  #--------------------------------------------------------------------------
  def obtain_escape_code(text)
    text.slice!(/^[\$\.\|\^!><\{\}\\]|^[A-Z]+/i)
  end
  
  #--------------------------------------------------------------------------
  # new method: obtain_escape_param
  #--------------------------------------------------------------------------
  def obtain_escape_param(text)
    text.slice!(/^\[\d+\]/)[/\d+/].to_i rescue 0
  end
  
  #--------------------------------------------------------------------------
  # new method: process_escape_character
  #--------------------------------------------------------------------------
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'C'
      #change_color(text_color(obtain_escape_param(text)))
    when 'I'
      process_draw_icon(obtain_escape_param(text), pos)
    when '{'
      make_font_bigger
    when '}'
      make_font_smaller
    end
  end
  
  #--------------------------------------------------------------------------
  # new method: process_draw_icon
  #--------------------------------------------------------------------------
  def process_draw_icon(icon_index, pos)
    draw_icon(icon_index, pos[:x], pos[:y])
    pos[:x] += 24
  end
  
  #--------------------------------------------------------------------------
  # new method: draw_icon
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y, enabled = true)
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.bitmap.blt(x, y, bitmap, rect, enabled ? 255 : translucent_alpha)
  end
  
  #--------------------------------------------------------------------------
  # new method: make_font_bigger
  #--------------------------------------------------------------------------
  def make_font_bigger
    bitmap.font.size += 8 if bitmap.font.size <= 64
  end
  
  #--------------------------------------------------------------------------
  # new method: make_font_smaller
  #--------------------------------------------------------------------------
  def make_font_smaller
    bitmap.font.size -= 8 if bitmap.font.size >= 16
  end
  
end # Sprite