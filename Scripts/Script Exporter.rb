=begin
================================================================================
Easy Script Importer-Exporter                                       Version 2.0
by KK20                                                             May 20 2017
--------------------------------------------------------------------------------

[ Introduction ]++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Ever wanted to export your RPG Maker scripts to .rb files, make changes to
  them in another text editor, and then import them back into your project?
  Look no further, fellow scripters. ESIE is easy to use!
  
[ Instructions ]++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  Place this script at the top of your script list to ensure it runs first.
  Make any changes to the configuration variables below if desired.
  Run your game and a message box will prompt success and close the game.
  
  If exporting, you can find the folder containing a bunch of .rb files in your
  project folder. A new file called "!script_order.csv" will tell this script
  in what order to import your script files back into RPG Maker. As such, you
  can create new .rb files and include its filename into "!script_order.csv"
  without ever having to open RPG Maker!
  
  If importing, please close your project (DO NOT SAVE IT) and re-open it.
  
[ Compatibility ]+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  This script already has methods to ensure it will run properly on any RPG
  Maker version. This script does not rely on nor makes changes to any existing
  scripts, so it is 100% compatible with anything.
  
[ Credits ]+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  KK20 - made this script
  GubiD - referenced his VXA Script Import/Export
  FiXato and HIRATA Yasuyuki - referenced VX/VXA Script Exporter
  ForeverZer0 - suggesting and using Win32API to read .ini file

================================================================================
=end

#******************************************************************************
# B E G I N   C O N F I G U R A T I O N
#******************************************************************************
#------------------------------------------------------------------------------
# Set the script's mode. Will export the scripts, import the scripts, or do
# absolutely nothing.
#       ACCEPTED VALUES:
#       0 = Disable (pretends like this script doesn't even exist)
#       1 = Export
#       2 = Import
#       3 = Playtest (import scripts from folder to playtest game; does not
#                     replace or create a 'Scripts.r_data' file)
#------------------------------------------------------------------------------
IMPORT_EXPORT_MODE = 1
#------------------------------------------------------------------------------
# Folder name where scripts are imported from and exported to
#------------------------------------------------------------------------------
FOLDER_NAME = "Scripts"
#------------------------------------------------------------------------------
# If true, will ignore creating files for scripts that have no code in them.
# Turning this to false is helpful if you like to categorize your script list
# for easier viewing. Useless for importing.
#------------------------------------------------------------------------------
SKIP_EMPTY = false
#------------------------------------------------------------------------------
# Will delete all files in the folder prior to exporting. Recommended to stay
# true unless you know what you're doing. Useless for importing.
#------------------------------------------------------------------------------
DELETE_OLD_CONTENTS = true
#------------------------------------------------------------------------------
# Creates a duplicate of the Scripts.r_data file to ensure you don't break your
# project. The duplicate will be placed in the Data folder as "Copy - Scripts".
# Recommended to stay true. Useless for exporting.
#------------------------------------------------------------------------------
CREATE_SCRIPTS_COPY = true
#------------------------------------------------------------------------------
# If true, converts any instances of tab characters (\t) into two spaces. This
# is extremely helpful if writing code from an external editor and moving it
# back into RPG Maker where tab characters are instantly treated as two spaces.
#------------------------------------------------------------------------------
TABS_TO_SPACES = true
#******************************************************************************
# E N D   C O N F I G U R A T I O N
#******************************************************************************
#------------------------------------------------------------------------------
if IMPORT_EXPORT_MODE != 0

RGSS = (RUBY_VERSION == "1.9.2" ? 3 : defined?(Hangup) ? 1 : 2)

if RGSS == 3
  def p(*args)
    msgbox_p *args
  end
end

# From GubiD's script
INVALID_CHAR_REPLACE = {
  '\\'=> '&',
  '/' => '&',
  ':' => ';',
  '*' => '°',
  '?' => '!',
  '<' => '«',
  '>' => '»',
  '|' => '¦',
  '"'=> '\''
}

begin
  # Get project's script file
  ini = Win32API.new('kernel32', 'GetPrivateProfileString','PPPPLP', 'L')
  scripts_filename = "\0" * 256
  ini.call('Game', 'Scripts', '', scripts_filename, 256, '.\\Game.ini')
  scripts_filename.delete!("\0")
  
  counter = 0
  # Exporting?
  if IMPORT_EXPORT_MODE == 1
    # Remove any script files present in the export/import folder
    if DELETE_OLD_CONTENTS && File.exists?(FOLDER_NAME)
      Dir['Scripts/*'].each { |file| File.delete(file) }
    end
    Dir.mkdir(FOLDER_NAME) unless File.exists?(FOLDER_NAME)
    # Create script order list
    script_order = File.open("#{FOLDER_NAME}/!script_order.csv", 'w')
    script_names = {}
    # Load the raw script data
    scripts = load_data(scripts_filename)
    scripts.each_index{|index| 
      script = scripts[index]
      id, name, code = script
      next if id.nil?
      # Replace invalid filename characters with valid characters
      name = name.split('').map{ |chr| INVALID_CHAR_REPLACE[chr] || chr }.join
      # Convert script data to readable format
      code = Zlib::Inflate.inflate(code)
      next if SKIP_EMPTY && code.size == 0
      code.gsub!(/\t/) {'  '} if TABS_TO_SPACES
      # If this script name has been used more than once
      if script_names.key?(name)
        script_names[name] += 1
        name = "#{name}~@#{script_names[name]}"
      # Make sure blank script names have a filename
      elsif name == ''
        script_names[''] = 1
        name = '~@1'
      else
        script_names[name] = 0
      end
      # Output script to file
      script_order.write("#{name}\n")
      File.open("#{FOLDER_NAME}/#{name}.rb", 'wb') do |f| 
        f.write code
      end
      counter += 1
    }
    script_order.close
    p "#{counter} files successfully exported."
    exit
  end
  # If importing or play-testing
  if IMPORT_EXPORT_MODE >= 2
    # If strictly importing, we want to replace the data directly in the scripts
    # data file. Otherwise, just override the scripts global variable.
    if IMPORT_EXPORT_MODE == 2
      scripts_file = File.open(scripts_filename, 'rb')
      import_obj = Marshal.load(scripts_file)
    else
      import_obj = $RGSS_SCRIPTS
    end
    # If strictly importing, create a copy of the scripts file in case something
    # goes wrong with the import.
    if IMPORT_EXPORT_MODE == 2 && CREATE_SCRIPTS_COPY
      base_name = File.basename(scripts_filename)
      dir_name = File.dirname(scripts_filename)
      copy = File.open(dir_name + "/Copy - " + base_name, 'wb')
      Marshal.dump(import_obj, copy)
      copy.close
    end
    # Load each script file
    File.open("Scripts/!script_order.csv", 'r') { |list| 
      list = list.read.split("\n")
      list.each { |filename|
        script_name = filename.gsub(/(.*?)(?:~@\d+)?$/) {$1}
        code = File.open("Scripts/#{filename}.rb", 'r') { |f| f.read }
        code.gsub!(/\t/) {'  '} if TABS_TO_SPACES
        # If strictly importing, compress script. Otherwise, keep script in
        # readable format.
        if IMPORT_EXPORT_MODE == 2
          z = Zlib::Deflate.new(6)
          data = z.deflate(code, Zlib::FINISH)
        else
          data = code
        end
        # If strictly importing, replaces entries in the scripts file data with
        # the newly-compressed imported scripts. Otherwise, replace entries in
        # $RGSS_SCRIPTS with imported scripts.
        import_obj[counter] = [counter] if import_obj[counter].nil?
        import_obj[counter][1] = script_name
        import_obj[counter][IMPORT_EXPORT_MODE] = data
        counter += 1
      }
    }
    # Dump imported file data to a new Scripts file and close the program.
    if IMPORT_EXPORT_MODE == 2
      data = File.open(scripts_filename, 'wb')
      Marshal.dump(import_obj[0, counter], data)
      data.close
      p "#{counter} files successfully imported. Please close your RPG Maker " +
      "now without saving it. Re-open your project to find the scripts imported."
      exit
    end
  end
end

end # if IMPORT_EXPORT_MODE != 0