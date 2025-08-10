#=============================================================================#
#-----------------------------------------------------------------------------#
#---------------------IBG Flash Screen/Skip Title V1.3------------------------#
#=============================================================================#
#--------------------------------Free to use----------------------------------#			
#-----------------------------No credit needed--------------------------------#
#----------Special Thanks to Doctor Todd for his contribution on BGM----------#
#=============================================================================#
#-----------------------------------Setup-------------------------------------#
#---Just place below materials and specify image to be used as flash screen.--#
#-------------------(Must be in Graphics/System folder)-----------------------#
#=============================================================================#
class IBG_PT < Scene_Base
  module IBG

	Flash  = "logohamburgueson"  # Name of flash screen image in Graphics\System folder.
	Flash2 = "dark"	  # Second flash image in. (nil if not using)
	Flash3 = nil	  # Third  flash image. (nil if not using)
	Flash4 = nil	  # Fourth flash image. (nil if not using)
	Flash5 = nil	  # Fifth flash image. (nil if not using)
	Delay  = 80	  # Duration of flash screen in frames.
	Skip   = false  # Skip title if no save file exists?
	Show   = true	 # Display flash screen\s. (for play testing)
	MUS	= true	 # Play BGM.
	FAD	= true	 # Fadeout BGM before Title.
	NumF   = 2		# Number of Flash Screens. (up to five)
	BGM	= "000_Morsa_Hamburguesona" #(DoctorTodd edit)Name of the music to play.



  end

#=============================================================================#
#---------------------------------Processing----------------------------------#
#=============================================================================#

  def initialize
	@time  = IBG::Delay
	@shown = 0
  end

  def start
	super  
	if IBG::Show
	  create_background
	  if IBG::MUS
		Audio.bgm_play("Audio/BGM/" + IBG::BGM, 100, 100) #(DoctorTodd edit)
	  end
	else
	  goto_title
	end
  end

  def create_background
	@sprite = Sprite.new
	@sprite.bitmap = Cache.system(IBG::Flash)
	@shown += 1
  end

  def create_background2
	@time = IBG::Delay
	@sprite = Sprite.new
	@sprite.bitmap = Cache.system(IBG::Flash2)
	@shown += 1
  end

  def create_background3
	@time = IBG::Delay
	@sprite = Sprite.new
	@sprite.bitmap = Cache.system(IBG::Flash3)
	@shown += 1
  end

  def create_background4
	@time = IBG::Delay
	@sprite = Sprite.new
	@sprite.bitmap = Cache.system(IBG::Flash4)
	@shown += 1
  end

  def create_background5
	@time = IBG::Delay
	@sprite = Sprite.new
	@sprite.bitmap = Cache.system(IBG::Flash5)
	@shown += 1
  end

  def update
	super
	if @time == 0 and @shown == IBG::NumF
	 goto_title
	else
	  if @time == 0 and IBG::NumF >= 2 and @shown == 1
		create_background2
	  elsif @time == 0 and IBG::NumF >= 3 and @shown == 2
		create_background3
	  elsif @time == 0 and IBG::NumF >= 4 and @shown == 3
		create_background4
	  elsif @time == 0 and IBG::NumF == 5 and @shown == 4
		create_background5
	  else
		@time -= 1
	  end
	end
  end

  def dispose_background
	@sprite.bitmap.dispose
	@sprite.dispose
  end

  def goto_title
	if IBG::Skip
	  if DataManager.save_file_exists?
		if IBG::FAD
		  fadeout_all
		end
		SceneManager.goto(Scene_Title)
	  else
		DataManager.setup_new_game
		if IBG::FAD
		  fadeout_all
		end
		$game_map.autoplay
		SceneManager.goto(Scene_Map)
	  end
	else
	  DataManager.save_file_exists?
	  if IBG::FAD
		fadeout_all
	  end
	  SceneManager.goto(Scene_Title)
	end
  end
end

module SceneManager

  def self.first_scene_class
	$BTEST ? Scene_Battle : IBG_PT
  end
end