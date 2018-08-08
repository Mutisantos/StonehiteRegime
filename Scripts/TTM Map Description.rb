#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ Tinys Travel Map //#║ **    Confirmation Window Addon#║ By TinyMine#║
#║  First Published/Erstveröffentlicht 08.07.2014#║
#║  Visit : [URL="http://rpgmaker-vx-ace.de/"]http://rpgmaker-vx-ace.de/[/URL] for further Information#║
#║  Suggestions? Support? Bugs? Contact me in [URL="http://rpgmaker-vx-ace.de/"]http://rpgmaker-vx-ace.de/[/URL]#║
#║  Credits required : TinyMine
#║  Commercial Use?  : Contact me in [URL="http://rpgmaker-vx-ace.de/"]http://rpgmaker-vx-ace.de/[/URL]#║  #║  #║ Version : 1.0 // 08.07.2014
#╚═=═=════════════════════════════════════════════════════════════════════════=#
$imported ||= {}
if $imported[:TINY_TTM] == nil  msgbox_p("You need to install <Tiny Travel Map> Main Script to use <Confirmation Window Addon>")
elsif $imported[:TINY_TTM] < 1.41  msgbox_p("You need to install <Tiny Travel Map 1.41> or higher Main Script to use <Confirmation Window Addon>")
else $imported[:TINY_TTM_CW] = 1.0
#╔═=══════════════════════════════════════════════════════════════════════════=##║ ** FEATURES **#║ #║ - Adds a Window with further information of the selected target or a picture#║ - Information Window is also a confirmation window#║ #╚═=═=════════════════════════════════════════════════════════════════════════=#
module TINY # Do not touch  
module TTM_MODE # Do not touch
#╔═=══════════════════════════════════════════════════════════════════════════=#
#║ █ ** EDITABLE REGION ** Defining TTM General Settings ** EDITABLE REGION **
#╚═=═=════════════════════════════════════════════════════════════════════════=#      
# Defining x/y pos of info window; dont forget the brackets []  
INFOPOS      = [350, 100]  
# Defining width/height of info window; dont forget the brackets []  
INFOSIZE     = [190, 200]  
# Defining the Windowskin of your info window; => system folder    
INFOSKIN     = "Window"  
# Defining the font which should be used in info window  
INFOFONT     = "VL Gothic"  
# Defines the info windows opacity ( 255 = fully visible)  
INFOOPACITY  = 192  
# Defines the info windows opacity ( 255 = fully visible)  
INFO_BACKOPACITY  = 192      
# Defines the fonts size of target name in info window  
INFOTTSIZE   = 24  
# Defines if name text is bold  
INFOTTBOLD   = true  
# Defines if name text has shadow  
INFOTTSHADOW = true    
# Defines the fonts size of the info text  
INFOFTSIZE   = 18  
# Defines if info text font is bold  
INFOFTBOLD   = false  
# Defines if info text has shadow  
INFOFTSHADOW = false    
# Defines the fonts size of confirm text in info window  
INFOCTSIZE   = 24  
# Defines if confirm text is bold  
INFOCTBOLD   = false  
# Defines if confirm text has shadow  
INFOCTSHADOW = true    
#═=═=═════════════════════════════════════════════════════════════════════════=#   
end 
# Do not touch  
module TTM_VOCAB 
# Do not touch
#═=═=═════════════════════════════════════════════════════════════════════════=#            
# Confirm Text    
CONFIRM = "Travel"        
#═=═=═════════════════════════════════════════════════════════════════════════=#      
end # Do not touch  
module TTM_TARGETS # Do not touch   
 ADDONS_CW = { # Do not touch
 #═=═=═════════════════════════════════════════════════════════════════════════=#      
 # █ EXAMPLE TARGETS    
 # Use your IDs of your targets for passing a info text to the window    
 # Only Targets that are defined in the Mainscript will be used for this and    
 # can be upgraded by this feature.        
 # ID => Info Text    
 # You can also use PNG Files by their filename which will be drawn into the     
 # center of the window. A Image will be detected by putting .png to the end     
 # of the string/text    
 # Example:   
 #   :desert => "A_Picture.png"        
 :desert     => "Just a dry place;\nSome people say\nthere would be\ntreasures though.",    
 :grassland  => "The wide and bright\nfields of grassland.\nFarmers call this\ntheir home.",    
 :mountain   => "Big mountains seem to\nbe the rulers of\nthe world in this\nplace.",   
 :tundra     => "Eternity rests between\nsnow and ice."    
 #╔═=══════════════════════════════════════════════════════════════════════════=#         
 #║ █ ** END OF EDITABLE REGION ** BEWARE ** END OF EDITABLE REGION ** DONT! **#║ █ **           Dont edit below this line, except... just don't           **
 #╚═=═=════════════════════════════════════════════════════════════════════════=#    
 } 
 # Do not touch  
 end 
 # Do not touch
 end 
 # TINY
 #╔═=══════════════════════════════════════════════════════════════════════════=#
 #║ █ ** OLD Class Scene_TinyMap
 #╚═=═=════════════════════════════════════════════════════════════════════════=#
 class Scene_TinyMap    
 alias_method :create_handler_info_window_addon                ,:create_handler 
 alias_method :create_windows_info_window_addon                ,:create_windows    
 def create_windows    
 create_windows_info_window_addon    
 @info_window = Window_Target_Info.new  
 end      
 def create_handler    
 create_handler_info_window_addon   
 @tar_window.set_handler(:ok,     method(:open_info_window))    
 @tar_window.set_handler(:cancel, method(:return_scene))    
 @info_window.set_handler(:ok,    method(:check_transfer))    
 @info_window.set_handler(:cancel,method(:close_info_window))  
 end    
 def close_info_window   
  @info_window.close   
  @info_window.deactivate   
  @tar_window.activate  
  end   
 def open_info_window    
 @info_window.refresh(@tar_window.all_targets)    
 @info_window.open unless $game_travelmap.targets.empty?    @info_window.activate    @tar_window.deactivate  
 end    
 end 
 # Scene_TinyMap
 #╔═=══════════════════════════════════════════════════════════════════════════=#
 #║ █ ** New Class Window_Target_Info
 #╚═=═=════════════════════════════════════════════════════════════════════════=#
 class Window_Target_Info < Window_Selectable    
 def initialize    
 super(TINY::TTM_MODE::INFOPOS[0], TINY::TTM_MODE::INFOPOS[1],    TINY::TTM_MODE::INFOSIZE[0], TINY::TTM_MODE::INFOSIZE[1])    
 deactivate    
 self.openness = 0    
 @index = 0    
 set_config  
 end    
 def col_max    
 return 1  
 end    
 def item_max    
 return 1  
 end    
 def item_width    
 contents.width  
 end    
 def line_height    
 return TINY::TTM_MODE::INFOFTSIZE  
 end    
 def item_rect(index)    
 rect = Rect.new    
 f = Font.new
 rect.width = contents.text_size(TINY::TTM_VOCAB::CONFIRM).width + 10
 rect.height = TINY::TTM_MODE::INFOCTSIZE    
 rect.x = index % col_max * (item_width + spacing) + (contents.width/2 - rect.width/2)    
 rect.y = contents.height - TINY::TTM_MODE::INFOCTSIZE     
 end    
 def draw_text_ex(x, y, text)
 text = convert_escape_characters(text)    
 pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}    
 process_character(text.slice!(0, 1), text, pos) until text.empty?  end    
 def draw_line(x, y, width)    
 contents.fill_rect(x, y, width, 1, Color.new(255,255,255,160))
 end    
 def set_config    
 self.back_opacity = TINY::TTM_MODE::INFO_BACKOPACITY    
 self.opacity = TINY::TTM_MODE::INFOOPACITY    
 font = Font.new([TINY::TTM_MODE::INFOFONT])    
 font.size = TINY::TTM_MODE::INFOFTSIZE    
 font.out_color = Color.new(0, 0, 0, 128)    
 self.contents.font = font
 end    
 def refresh(item)    
 if $game_travelmap.targets.empty?    
 process_ok    
 return    
 end
 contents.clear
 # Draw Titel stuff (line + name)      
 contents.font.color  = normal_color    
 contents.font.bold   = TINY::TTM_MODE::INFOTTBOLD    
 contents.font.shadow = TINY::TTM_MODE::INFOTTSHADOW    
 contents.font.size   = TINY::TTM_MODE::INFOTTSIZE    
 align_middle_x = contents.width/2 - contents.text_size(TINY::TTM_TARGETS::TARGETS[item][:text]).width/2   
 draw_text_ex(align_middle_x,0, TINY::TTM_TARGETS::TARGETS[item][:text])    
 draw_line(0, contents.font.size, self.width)    
 # Draw Picture or Text     
 begin    
 if TINY::TTM_TARGETS::ADDONS_CW[item][-4, 4].downcase == ".png"      
 bitmap = Cache.map(TINY::TTM_TARGETS::ADDONS_CW[item])      
 x = contents.width/2 - bitmap.width/2      
 y = contents.height/2 - bitmap.height/2      
 contents.blt(x, y, bitmap, bitmap.rect)    
 else      contents.font.bold   = TINY::TTM_MODE::INFOFTBOLD      
 contents.font.shadow = TINY::TTM_MODE::INFOFTSHADOW      
 contents.font.size   = TINY::TTM_MODE::INFOFTSIZE      
 draw_text_ex(0, TINY::TTM_MODE::INFOTTSIZE + 2, TINY::TTM_TARGETS::ADDONS_CW[item])    
 end    
# rescue      p "There was no info to that target #{item}. On purpose?"    
 end    
 # Draw Confirm stuff (selection)   
 contents.font.color  = normal_color    
 contents.font.size   = TINY::TTM_MODE::INFOCTSIZE    
 contents.font.bold   = TINY::TTM_MODE::INFOCTBOLD    
 contents.font.shadow = TINY::TTM_MODE::INFOCTSHADOW    
 align_middle_x = contents.width/2 - contents.text_size(TINY::TTM_VOCAB::CONFIRM).width/2    
 draw_text_ex(align_middle_x, contents.height - contents.font.size, TINY::TTM_VOCAB::CONFIRM)  
 end
 end 
 # Window_Target_Infoend 
 end if
 #╔═=═══════════════════════════════════════════════════════════════════════════╗
 #╠══════════════════════════════▲ END OF SCRIPT ▲══════════════════════════════╣
 #╚═=═=═════════════════════════════════════════════════════════════════════════╝