#==============================================================================
# ■ SideView Action Setup Ver100
#------------------------------------------------------------------------------
# Tankentai Sideview Battle System
#       by Enu (http://rpgex.sakura.ne.jp/home/)
# English Translation v1.1
#       by Wishdream (http://wishdream.org/)
#       Help by Okamikurainya
# Version Log:
#    1.1 - All actions, programs and full actions translated.
#    1.0 - Start of project, all documentation translated.
#------------------------------------------------------------------------------
# 　System Settings and Action Setup
#==============================================================================
module N03
 #--------------------------------------------------------------------------
 # ● Configuración del Sistema de Batalla Lateral
 #--------------------------------------------------------------------------
  # Actor Initial Start Position 
  #　                       1st          2nd          3rd          4th
  #                     X   Y   H    X   Y   H    X   Y   H    X   Y   H
  ACTOR_POSITION   = [[405,265,0],[440,210, 0],[450,320, 0],[500,280, 0]]
  # Wait time after the end of each action in frames
  ACTION_END_WAIT = 20
  # Wait time after the end of each turn in frames
  TURN_END_WAIT = 12
  # Invert the battle field (left to right) on surprise z
  BACK_ATTACK = true
  # Use the default effect when the actor is damaged
  ACTOR_DAMAGE = false
  # Use the default effect when the enemy is damaged
  ENEMY_DAMAGE = false
  # Automatically reverse the battler of the enemy depending on what side
  ENEMY_MIRROR = true
  # Invunerable or immortal state ID
  IMMORTAL_ID = 10
  
  # Set Battle Log display
  # If the Battle Log is OFF, skill name appears on the top of the screen
  BATTLE_LOG = true
  # Set the skill IDs you want to hide on display
  NO_DISPLAY_SKILL_ID = [1,2,3,4,5,6,7]
  # Enable damage popups
  DAMAGE_POP = false
  # Enable state popups
  STATE_POP = true
  # Filename for Damage Numbers (Inside the System folder)
  DAMAGE_PLUS = "damage_num+"
  # Filename for Recovery Numbers (Inside the System folder)
  DAMAGE_MINUS = "damage_num-"
  # Filename for MP Numbers (Inside the System folder)
  DAMAGE_MP = "damage_mp"
  # Filename for TP Numbers (Inside the System folder)
  DAMAGE_TP = "damage_tp"
  # Adjust character spacing of the damage numbers
  DAMAGE_ADJUST = -4
  
  # Adjust the camera focus of the battle camera by the X-axis and Y-axis
  CAMERA_POSITION = [   0, -40]
  
 #--------------------------------------------------------------------------
 # ● Special Combat Background Configuration
 #--------------------------------------------------------------------------
  # Change the display of a background according to the filename.
  #
  # Background Image - Add animation/parallax to a background in Battlebacks1
  #               "Battlebacks1" is the default set. Used when an image is
  #               not specified.
  #
  # Wall/Floor Image - Add animation/parallax to a background in Battlebacks2
  #               "Battlebacks2" is the default set. Used when an image is
  #               not specified.
  # 
  # Position - [X, Y] (Note, in game development. Y is usually reversed.)
  # Size/Zoom - [X, Y]
  # Shake - Allow shaking on the image.
  # Switch Trigger - Turns on a switch on the start of the battle.
  #                  Use a negative number to turn it on in battle only.
  #                  Using 0 will not do anything.
  
   FLOOR1_DATA = { 
 #-Background File-             Position      Zoom       Shake     Switch
  "Sea_ex01"              => [ [   0, 0], [ 100, 100], false,   -1],
  "Battlebacks1"          => [ [   0, 0],  [ 100, 100],  true,    0],
  }
  
   FLOOR2_DATA = { 
 #-Wall/Floor File-            Position      Zoom       Shake     Switch
  "Ship_ex"               => [ [   0, 120], [ 150, 150],  true,    0],
  "Battlebacks2"          => [ [   0, 0],   [ 100, 100],  true,    0],
  

}  
  
#==============================================================================
# ■ Action
#------------------------------------------------------------------------------
# 　ACTION are single actions done by a battler. Used in combination to create
#  a FULL ACTION. ACTIONS are useless by itself.
#==============================================================================
 # Please do not touch or rename this, this is required by the script.
  ACTION = {
  
 #--------------------------------------------------------------------------
 # ● Battler Frame/Cell Animations
 #--------------------------------------------------------------------------
  # This area controls the animation graphic of the character itself.
  # 
  # NOTE:
  # Multiple characters are inside one character file by default
  # If you want to add another image to the character, be sure to
  # have the image fit to the character set and positioned to the
  # right character.
  # It's preferred to have just one character on one image by using
  # "$" at the beginning of the filename.
  #
  # Type       - always use "motion", this determines that it's a character
  #              motion.
  #
  # Index Name - Battler graphic file used.
  #                 "": Normal Battler Graphic. In case of the Actors, it
  #                     refers to the walking graphic.
  #                 "_1": "Character Name + _1", "_1" refers to the filename
  #                     extension.
  #                 The actor files are placed in the "Characters" folder.
  #                 The enemy files are placed in the "Battlers" folder.
  #
  # Vertical   - Vertical position of the cell within the graphics file. 
  #                 Starts from the top from 0 to 3. 
  # Horizontal - Horizontal position of the cell within the graphics file. 
  #                 Starts from the left from 0 to 3.
  #              NOTE: You can go over but you'll need to change the cell setup
  #                    in the Battler Setup.
  #
  # Pattern    - 0: Fixed Cell
  #              1: One Way
  #              2: Ping-Pong
  #              3: One-way Loop
  #              4: Ping-pong Loop
  #
  # Speed      - Update speed of the animation. The lower the value, the faster.
  # Z          - Position in the Z-axis/order of display.
  #              The bottom of the screen usually appears in the front.
  # Wait       - Waits for the action to finish before shifting to the next act.
  # Shadow     - Enable or disable the shadow under the actor.
  # Weapon     - Weapon animation displayed, use "" for no weapon.
  #                 Multiple weapon animations can be played by adding
  #                 more at the end of the array.
  
  # Stand By
  # -Action Name-      Type   Index   Vert  Horz  Pattern Speed  Z  Wait Shadow Weapon
  "Wait"             => ["motion",   "",    1,   0,   4,   12,   0, true, true, "" ],
  "Wait(Fixed) WT"   => ["motion",   "",    1,   1,   0,   12,   0, true, true, "" ],
  "Wait(Fixed)"      => ["motion",   "",    1,   1,   0,   12,   0,false, true, "" ],
  "Fallen"           => ["motion", "_1",    0,   0,   0,   12,   0, true,false, "" ],
  "Right"            => ["motion",   "",    2,   0,   4,   12,   0, true, true, "" ],
  # Movement
  # -Action Name-        Type    Index     Vert Horz  Pattern Speed  Z  Wait Shadow Weapon
  "Move Left"       => ["motion",   "",    1,   0,   4,     6,    10, true, true,  "" ],
  "Move Right"      => ["motion",   "",    2,   0,   4,     6,    10, true, true,  "" ],
  #Cell Rotate
  "Front Rotate"    => ["motion",   "",    0 ,   0,   4,     6,    10, true, true,  "" ],
  # Pause
  # -Action Name-      Type   Index   Vert  Horz  Pattern Speed  Z  Wait Shadow Weapon
  "Wpn Raised"      => ["motion",   "",    1,   0,   1,    2, 200,false, true, "Raised" ],
  
   # Attack
  # -Action Name-            Type   Index   Vert  Horz  Pattern Speed  Z  Wait Shadow Weapon
  "Wpn Swing R"       => ["motion",   "",    1,   0,   1,    2, 200,false, true, "Vert Swing"],
  "Wpn Swing L"       => ["motion",   "",    1,   0,   1,    2, 200,false, true, "Vert Swing L"],
  "Wpn Swing LR"      => ["motion",   "",    1,   0,   1,    2, 200,false, true, "Vert Swing","Vert Swing L"],
  "Shield Defense"    => ["motion",   "",    1,   0,   1,    2, 200,false, true, "Shield"],
  "Thrust Fist Weapon"=> ["motion",   "",    1,   0,   1,    2, 200,false, true, "Thrust Fist" ],
  "Thrust Weapon"     => ["motion",   "",    1,   0,   1,    2, 200,false, true, "Thrust" ],
  "Bow Shot"          => ["motion",   "",    1,   0,   1,    2, 200,false, true, "Bow"],
  "GunPoint"          => ["motion",   "",     1,   0,   1,     2, 200,false, true, "GunShow"],
  "Cerbatana"         => ["motion",   "",     1,   0,   1,     2, 200,false, true, "CerbatanaShow"],
  "RocketPoint"       => ["motion",   "",     1,   0,   1,     2,   0,false, true, "RocketShow"],
  "Hammer"            => ["motion",   "",     1,   0,   1,     2,   0,false, true, "Martillo"],
 #--------------------------------------------------------------------------
 # ● Battler Movement
 #--------------------------------------------------------------------------
  # This area controls the movement of the characters.
  #
  # Target - Defines the origin of movement based on the target.
  #          1 unit = 1 pixel
  #          [ -7: Start Position ]
  #          [  0: Current Position ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  #          [  5: Second / Next Target  ]
  #          [  6: Screen; (0,0) is at upper-left of screen ]
  #          
  # X - X-axis pixels from target.
  # Y - Y-axis pixels from target.
  # H - Height/H-axis pixels from target. (From the ground)
  #     Using nil won't change the H axis and will move you in the XY axis only.
  #
  # Speed - Postive number gives the number of pixels to move in one frame.
  #       - Negative number gives the frames needed to complete the movement.
  # Curve - Curves the movement in an orbit upwards on positive
  #         and below on negative.
  # Jump - Jump parabolic trajectory. [From the ground to the trajectory then
  #        back to the ground.]
  # Anime - The name of the animation used from "motion".
 
  # System Based
  # -Action Name-              Type  Target X    Y    H  Speed Curve Jump    Anime
  "Before Battle Entry"    => ["move",-7, 180,   0,   0,  0,   0, [  0,  0], "Move Left"],
  "Exit"                   => ["move",-7, 180,   0,   0,  7,   0, [  0,  0], "Move Right"],
  "Escape Middle"          => ["move",-7,  80,   0,   0,  7,   0, [  0,  0], "Move Right"],
  "Command Input"          => ["move",-7, -20,   0, nil,-10,   0, [  0,  0], "Move Left"],
  "Damage Pull"            => ["move", 0,  20,   0, nil,-10,   0, [  0,  0], ""],
  "Damage Levantamiento"   => ["move", 0, 150,   0, nil,-15,   0, [  0, 40], ""],
  "Move to Field Center"   => ["move", 4,  10,   0, nil,-15,   0, [  0,  0], ""],
  "Large Damage Pull"      => ["move", 0,  60,   0, nil,-10,   0, [  0,  0], ""],
  
  # -Action Name-               Type  Target X    Y   H  Speed Curve Jump      Anime
  "Coordinate Reset Fast"   => ["move",-7,   0,   0,   0,-10,   0, [  0,  0], "Move Right"],
  "Coordinate Reset"        => ["move",-7,   0,   0,   0,-20,   0, [  0,  0], "Move Right"],
  "Coordinate Reset Curve"  => ["move",-7,   0,   0,   0,-20,  -2, [  0,  0], "Move Right"],
  "Coordinate Reset Left"   => ["move",-7,   0,   0,   0,-20,   0, [  0,  0], "Move Left"],
  
  # -Action Name-            Type  Target X     Y    H  Speed Curve Jump    Anime
  "One Step Before Move"  => ["move", 0, -20,   0,   0,-10,   0, [  0,  0], "Move Left"],
  "One Step After Move"   => ["move", 0,  20,   0,   0,-10,   0, [  0,  0], "Move Left"],
  "One Step Before Jump"  => ["move", 0, -30,   0,   0,-10,   0, [ 20,-20], "Move Left"],
  "One Step After Jump"   => ["move", 0,  30,   0,   0,-10,   0, [ 20,-20], "Move Left"],
  "Victory Jump"          => ["move", 0,  10,   0,   0,-25,   0, [ 30,-30], "Wait(Fixed)"],
  "Victory Jump Weapon"   => ["move", 0,   0,   0,   0,-15,   0, [ 20,  0], "Wpn Raised"],
  "Victory Jump Land"     => ["move",-7,   0,   0,   0,-10,   0, [  0,  0], "Wpn Swing R"],
  "Pitch 01"              => ["move", 0,   0,   0,  20, -2,   0, [  0,  0], ""],
  "Pitch 02"              => ["move", 0,   0,   0, -20, -2,   0, [  0,  0], ""],
  
  # -Action Name-           Type  Target X    Y    H  Speed Curve   Jump    Anime
  "Move Before Enemy"   => ["move", 1,  30,   0,   0,  -20,   0, [  0,  0], "Move Left"],
  "Move to Enemy"       => ["move", 1,  10,   2,   0,  -20,   0, [  0,  0], "Move Left"],  
  "Move near Enemy"     => ["move", 1,  70,   2,   0,  -20,   0, [  0,  0], "Move Left"],  
  "Move After Enemy"    => ["move", 1, -60,   0,   0,  -20,   0, [  0,  0], "Move Left"],
  
  #Barrido
  "Move Enemy Fast"     => ["move", 1,   0,   0,   0,-10,   0, [  0,  0], "Move Left"],
  #Trayectoria parabolica del salto
  "Before Jump Slam"    => ["move",-1,   0,   0, 100,-20,   0, [ 40,-20], "Wpn Raised"],
  "Before salto"        => ["move",-1,   0,   0, 100,-20,   0, [ 40,-20], ""],
  "Slammed"             => ["move",-1,   0,   0,   0,-10,   0, [  0,  0], "Wpn Swing R"],
  
 #--------------------------------------------------------------------------
 # ● Weapon Action
 #--------------------------------------------------------------------------
  # This is where all weapon actions lie.
  #
  # 1 Animation Type    - Type of graphic used.
  #                     [ 0: Iconset ]
  #                     [ 1: Single Image ]
  #                     [ 2: Animation Cell / 2k3 Style ]
  #                     NOTE: 1 & 2 refers an image on the "Characters" folder
  # 2 Move              - Distance to move the image. [X, Y]
  # 3 Adjustment        - Adjustment of the initial coordinates. [X, Y]
  # 4 Start Angle       - Starting angle of the weapon. Value runs on 0~360.
  #                     Positive will move it counter-clockwise.
  #                     Negative will move it clockwise.  
  # 5 End Angle         - Ending angle of the weapon.
  # 6 Origin            - Origin of the image.
  #                     [ 0: Center ]
  #                     [ 1: Upper Left ]
  #                     [ 2: Upper Right ]
  #                     [ 3: Lower Left ]
  #                     [ 4: Lower Right ]
  #                     [ 5: Same as Battler (Under image w/ vertical half) ]
  # 7 Invert            - Invert the weapon display.
  # 8 Zoom              - Image Zoom [X, Y] Also accepts decimal values.
  # 9 Z                 - Set to true to display the weapon in front.
  # 10 Secondary         - Display the second weapon or shield.
  #                     If you don't want to use the icon, setup the icon at
  #                     Battler Setup.
  # 11 Update            - Set -1 to sync with the battler.
  #                     [Update Interval, Pattern Number , Loop?]
  # 12 Index             - Even if the shield refers to a graphics file, if there
  #                     is an index used. The graphics of the shield file +
  #                     plus the index will be used.
  #                     It's only used when a weapon has multiple images.
  #                     e.g.) The index of "VertSwing" is "" => IconSet
  #                           The index of "VertSwing2" is "_1" => IconSet_1
  #                     For Cell and Image, use the Characters folder.
  #                     For Icons, use the System folder.
  # 13 Image             - If you ignore the image file was set in the weapons,
  #                     shields and the index, to directly specify the weapon
  #                     image, set the graphics' file name used here.
  #                     The file should be in Characters.
  
  # -Action Name-              Type Anim  Move     Adjust Start End Orig Invert  Zoom    Z    2nd   Update Index Image   Item
  #Items
  "ItemShow"               => ["wp", 0,[  0, 9],[  0,  0],  0, 360,  5,   true, [1.2,1.2], true, false,  -1,   "",    "", false],
  # Armas Generales 
  "Vert Swing"             => ["wp", 0,[  6, 0],[ -4,-20], -45,  45,  4, false, [1,1], true, false,   -1,   "",    ""],
   #Escudo 
  "Shield"                 => ["wp", 0,[  0, 0],[  0,-20],   0, -45,  0, false, [1,1],  true,  true,   -1,   "",    ""],
   #Segunda Arma
  "Vert Swing L"           => ["wp", 0,[  6, 0],[  0, -8],-135,  45,  4, false, [1,1],  true,  true,   -1,   "",    ""],
   #Armas de Impacto
  "Thrust Fist"            => ["wp", 0,[-20, 0],[  5,  5], -45, -45,  4, false, [1,1], false, false,   -1,   "",    ""],
   #Lanzas
  "Thrust"                 => ["wp", 0,[-25, 0],[ 25,-10],  45,  45,  4, false, [1,1], false, false,   -1,   "",    ""],
   #Invocacion de hechizos
  "Raised"                 => ["wp", 0,[  6,-4],[ -4,-10],  90, -45,  4, false, [1,1], false, false,   -1,   "",    ""],
   #Armas de Fuego
  "GunShow"                => ["wp", 0,[ 3, 0],[ 2,-20], 90, 45, 4, false, [1,1], true, false, -1, "",  ""],
   #Cerbatanas
  "CerbatanaShow"          => ["wp", 0,[ 6, 0],[ -15,-25], 100, 45, 5, false, [1,1], false, false, -1, "",  ""],
   #Lanzamisiles
  "RocketShow"             => ["wp", 0,[ 6, 0],[ -4,-10], -45, 25, 4, false, [1,1], false, false, -1, "",  ""],
  #Arco
  "Bow"                    => ["wp", 2,[  0, 0],[  0,  0],   0,   0,  5, false, [1,1],  true, false,   -1,   "",    ""],
  #Flecha
  "Arrow"                  => ["wp", 0,[  0, 0],[  0,  0],   0,  45,  0, false, [1,1],  true, false,[2,6,false],   "",    "arrow01"],
  "Rotation"               => ["wp", 0,[  0, 0],[  0,  0],   0, 360,  0, false, [1,1],  true, false,[1,8, true],   "",    ""],
  #Bala
  "Bullet"                 => ["wp", 0,[ 0, 0],[ 0, 0], 0, 60, 0, false, [1,1], true, false,[2,6,false], "",  "Bullet"],
  #Cerbatana
  "Cerb"                   => ["wp", 0,[ 0, 0],[ 0, 0], 0, 60, 0, false, [1,1], true, false,[2,6,false], "",  "arrow01"],
  "Rocket"                 => ["wp", 0,[ 0, 0],[ 0, 0], 0, 0, 0, false, [1,1], true, false,[2,6,false], "",  "rocket"],
                                          #Rotacion
  # Martillo Enorme 
  "Martillo"               => ["wp", 0,[  6, 0],[ 10,-40], -90,  70,  4, false, [1,1], true, false,   -1,   "",    "hammer"],

  #--------------------------------------------------------------------------
 # ● Moving Animation
 #--------------------------------------------------------------------------
  # This section controls the movement for animations and weapons. e.g. Missile
  #
  # 1 ID - Animation ID [Move Animation, Hit Animation]
  #       0 - Hide Animation, -1 - Use Weapon Animation
  #
  # 2 Start - Start target of the movement.
  # 3 End   - End target of the movement.
  #         FOR START AND END:
  #         If negative is used, the animation will play on multiple targets.
  #          [  0: Current Position ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  #          [  5: Second / Next Target  ]
  #          [  6: Screen; (0,0) is at upper-left of screen ]
  #
  # 4 Start Position - Position from start target. [X, Y]
  # 5 End Position   - Position from end target. [X, Y]
  #                X is automatically flipped for the enemy.
  # 6 Speed - Postive no. sets the number of X pixels to move in 1 frame.
  #       - Negative no. sets it to the time and speed depends on the distance.
  # 7 End Type - What happens after the animation hits.
  #             [ 0: Disappears (Sets to pass-through on miss) ]
  #             [ 1: Pass-through ]
  #             [ 2: Disappears (Regardless of miss) ]
  # 8 Orbit - Movement trajectory. [From the start to the trajectory then back to
  #                               the end.]
  # 9 Z - Set to true to display the animation in front.
  # 10 Wait - Wait for the animation to end before changing.
  #        [ Wait for the move animation, wait for the hit animation ]
  # 11 Damage - Apply damage calculation on hit if set to true.
  # 12 Homing/Follow - Homes/follows the target on a moving target.
  # 13 Camera - Set the scale of the animation to match the zoom of the camera.
  # 14 Loop - Loop the animation after it ends.
  # 15 NoFlip - Does not flip the animation under any circumstances.
  # 16 Weapon - Use weapon action. Leave "" if not used.
  
  # -Action Name-            Type   ID   Start End StartPos EndPos Speed EType Orbit   Z     Wait         Damage  Homing Camera Loop  NoFlip Weapon
  "Arrow Fire WT"      => ["m_a",[ 0,-1], 0,  1, [ 0, 0], [ 0, 0], 10,  2, [-3,-3], true, [ true, true],  true,  true,  true, false, false,  "Arrow"],
  "Arrow Fire"         => ["m_a",[ 0,-1], 0,  1, [ 0, 0], [ 0, 0], 10,  2, [-3,-3], true, [false,false],  true,  true,  true, false, false,  "Arrow"],
  "Water Gun Fire"     => ["m_a",[69,69], 0,  1, [ 0, 0], [ 0, 0], 10,  0, [ 0, 0], true, [ true, true],  true,  true,  true,  true, false,  ""],
  "Acuaesfera Fire"    => ["m_a",[144,120], 0,  1, [ 0, 0], [ 0, 0], 10,  0, [ 0, 0], true, [ true, true],  true,  true,  true,  true, false,  ""],
  
  
  
  "Wpn Throw Start"    => ["m_a",[ 0,-1], 0,  1, [ 4,-6], [ 0, 0], 10,  2, [-3,-3], true, [ true,false],  true,  true,  true, false, false,  "Rotation"],
  "Wpn Throw Return"   => ["m_a",[ 0, 0], 1,  0, [ 0, 0], [ 4,-6], 10,  0, [ 3, 3], true, [ true,false], false,  true,  true, false, false,  "Rotation"],
  
  "SwiftNado"          => ["m_a",[69,120], 0,  1, [ 0, 0], [ 4,-6], 10,  0, [ 3, 3], true, [ false,true], true,  true,  true, false, false,  ""],
  "BolaNieve"          => ["m_a",[137,163], 0,  1, [ 0, 0], [ 4,-6], 10,  0, [ 3, 3], true, [ true,false], true,  true,  true, false, false,  ""],

  
  "BullerWT"           => ["m_a",[ 0,-1], 0, 1, [ 0, 0], [ 0, 0], 10, 2, [0,0], true, [ true, true], true, true, true, false, false, "Bullet"],
  "CerbWT"             => ["m_a",[ 0,-1], 0, 1, [ 0, 0], [ 0, 0], 10, 2, [0,0], true, [ true, true], true, true, true, false, false, "Cerb"],
  "RocketWT"           => ["m_a",[ 0,-1], 0, 1, [ 0, 0], [ 0, 0], 10, 2, [0,0], true, [ true, true], true, true, true, false, false, "Rocket"],
  "HammerWT"           => ["m_a",[ 0,-1], 0, 0, [ 0, 0], [ 0, 0], 10, 2, [0,0], true, [ true, true], true, true, true, false, false, "Martillo"],
  "ItemWT"             => ["m_a",[ 0, 0], 0, 1, [ 0,-6], [ 0,-6], 2, 2, [-3,-3], true, [ true,false],  true,  true,  true, false, false,  "Rotation"],
 
#--------------------------------------------------------------------------
 # ● Battle Animation
 #--------------------------------------------------------------------------
  # This section allows the display of animations during battle.
  # "m_a" means moving animation, it moves from one point to another.
  # "anime" means battle animation, it stays with just one target.
  # So don't get confused between the two.
  #
  # ID - Animation ID.
  #         -1 - Weapon animation ID
  #         -2 - Secondary weapon animation ID.
  #         -3 - Skill animation ID.
  # Target - Target of the animation to play on.
  #          [  0: Current Battler ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  #          [  5: Second / Next Target  ]
  # Homing/Follow - Follow the movement of the target.
  # Wait - Wait for the animation to finish.
  # Damage - Apply damage calculation on play.
  # Camera - Set the scale of the animation to match the zoom of the camera.
  # NoFlip - Don't automatically flip the animation depending on what side.
  # Flip - Display the animation flipped.
  # Z - Set to true to display the animation in front.
  
  # Damage Based
  # -Action Name-         Type     ID Target Homing Wait   Damage Camera NoFlip  Flip     Z
  "Weapon Anim"      => ["anime",  -1,  1, false, false,  true,  true, false,  false,  true], 
  "Weapon Anim WT"    => ["anime",  -1,  1, false,  true,  true,  true, false,  false,  true], 
  "Weapon Anim LWT"   => ["anime",  -2,  1, false,  true,  true,  true, false,  false,  true], 
  "Skill Anim"          => ["anime",  -3,  1, false, false,  true,  true, false,  false,  true], 
  "Skill Anim WT"        => ["anime",  -3,  1, false,  true,  true,  true, false,  false,  true], 
  # Actor Based
  # -Action Name-         Type     ID Target Homing Wait   Damage Camera NoFlip  Flip     Z
  "Magic Chant"          => ["anime", 113,  0,  true,  true, false,  true, false,  false,  true], 
  "Skill Prepare"          => ["anime", 114,  0,  true,  true, false,  true, false,  false,  true], 
  "Magic Active Anim"      => ["anime", 115,  0, false,  true, false,  true, false,  false, false], 
  "Skill Active Anim"      => ["anime", 116,  0, false,  true, false,  true, false,  false, false], 
  
 #--------------------------------------------------------------------------
 # ● Camera Control
 #--------------------------------------------------------------------------
  # This area controls the camera which allows you to zoom and move the camera.
  #
  # Target - The focus target of the camera.
  #          [  0: Current Position ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  #          [  5: Second / Next Target  ]
  #          [  6: Screen; (0,0) is at upper-left of screen ]
  # Adjust - Position from the target. [X add →, Y add ↓]
  # Time - Time to move and zoom towards the point.
  # Zoom - Zoom factor of the camera, measured by percent. No zoom at 100.
  # Wait - Wait until the camera is adjusted.
  
  # -Action Name-         Type  Target   Adjust  Time  Zoom  Wait
  "Reset Camera"=> ["camera",   6, [   0,   0], 100,  40, false],
  "Zoom In"    => ["camera",   6, [   0, 100], 120,  40, false],
  "Zoom Out"  => ["camera",   6, [   0,   0],  80,  40, false],
  
 #--------------------------------------------------------------------------
 # ● Screen Shake
 #--------------------------------------------------------------------------
  # This area controls the screen shake. If the battler is in the air (H is 0
  # or more), the screen does not shake.
  #
  # Direction - The distance of the shake in the [X, Y] position.
  # Speed - The speed of the shake. The smaller it is, the faster.
  # Time - How long the shake will take. The distance gets weaker over time.
  # Wait - Wait until the shake ends.
  
  # -Action Name-      Type  Direction Speed Time   Wait
  "Small Shake"     => ["shake", [  0, 4],  2,    16, false],
  "Medium Shake"     => ["shake", [  0, 6],  3,    30, false],
  "Hard Shake"     => ["shake", [  0,12],  3,    40, false],
  
 #--------------------------------------------------------------------------
 # ● Screen Color Change
 #--------------------------------------------------------------------------
  # This section here controls the color change of the background and the
  # battlers.
  #
  # Target - Subject of the color change.
  #          [  0: Current Battler ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  #          [  5: Second / Next Target  ]
  #          [  6: Background ]
  #          [  7: Current Battler + Target ]
  #          [  8: Everyone else than the current battler ]
  #          [  9: Everyone else than the target ]
  #          [ 10: All ]
  # Tone - [ Red, Green, Blue, Alpha(Intensity), Change Time, Return Time]
  #        Return Time - Time to return to the original color after change is
  #                      done. 0 to not return to original color.
  # Wait - Wait until change is done.
  
  # -Action Name-                           Type   Target   R    G    B    A   CT    RT  Wait
  "Hue Default"                      => ["color",  10, [   0,   0,   0,   0,  30,   0], false],
  "Danger Tone"                      => ["color",   0, [ 255,  50,  50, 100,  40,  40], false],
  "Poison Tone"                      => ["color",   0, [ 170,  50, 255, 170,  30,  30], false],
  "BurningColor"                     => ["color",   0, [ 250,  50, 0, 170,  30,  30], false],  
  "FreezeColor"                     => ["color",   0,  [ 200, 240, 255, 170,  30,  30], false],  
  "Generic Status Abnormal Tone"     => ["color",   0, [ 255, 255,  50, 170,  40,  40], false],
  "Dim Background"                   => ["color",   6, [   0,   0,   0, 255,  30,   0], false],
  "Dim All Except Target"            => ["color",   9, [   0,   0,   0, 255,  30,   0], false],
   
 #--------------------------------------------------------------------------
 # ● Transition Control
 #--------------------------------------------------------------------------
  # This section runs controls the transition that runs after a screen fix.
  # Be sure to run a screen fix first before you run an action in this section.
  #
  # Bounds - The clarity of the boundary. The higher, the more unclear it is.
  # Time - Transition time. Game screen is frozen during the transition.
  # Filename - The filename of the transition. The transition should be in the
  #            "Pictures" folder.
  
  # -Action Name-     Type  Bounds Time Filename
  "Circle"         => ["ts",  40,   60,  "circle"],
  "Diamond"         => ["ts",  40,   60,  "diamond"],
  "Brick"         => ["ts",  40,   60,  "brick"],
  
 #--------------------------------------------------------------------------
 # ● Afterimage Control
 #--------------------------------------------------------------------------
  # This section controls the afterimage that appears on the battler.
  # Number - Number of afterimages. Use 0 to turn off. CPU load higher the more
  #          you afterimages you use.
  # Time - Lifetime of afterimage in frames. The smaller, the shorter.
  # Process - Post-processing of the afterimage. Make the afterimage disappear
  #           after the FULL ACTION if set to true.
  # Alpha - Transparency of the afterimage. Range from 0-255.
  
  # -Action Name-        Type     No. Time Process Alpha
  "Afterimage ON"        => ["mirage",  4,   3,  true,  160], #Barrido
  "Afterimage OFF"       => ["mirage",  0,   0,  true,    0],
  
#--------------------------------------------------------------------------
 # ● Battler Rotation
 #-------------------------------------------------------------------------- 
  # This is where you can rotate the battler to your own demise.
  # The spin is reset when the FULL ACTION is done.
  # The spin point of the image is always at the center.
  # Flip and weapon action are unaffected by this action.
  # 
  # Time - Rotation time. Immediately displayed on 0.
  #
  # Units in 0~360 degrees. Positive is clockwise, negative counter-clockwise.
  # Reversed calculation for the enemy.
  # Start - Starting angle.
  # End - Ending angle.
  # Type - After rotation process.
  #         [ 0: Reset Rotation ]
  #         [ 1: Maintain Rotation ]
  #         [ 2: Loop Rotation ]
 
  # -Action Name-          Type    Time  Start  End  Type
  "Rotate Right Once"  => ["angle",  12,    0, -360,   0], #Rotacion Derecha
  "Rotate Left Once"   => ["angle",  12,    0,  360,   0], #Rotacion Izquierda
  "Rotar 180"          => ["angle",  24,    0,  180,   1], #Rotar Medio
  "Rotar 0"            => ["angle",  12,    180,  0,   1], #DesRotar Medio
  "Rotar 90"           => ["angle",  12,    0,  90,   1], #Rotar acostado
  "Rotar -90"          => ["angle",  12,    90,  0,   1], #Rotar acostado
  
  
 #--------------------------------------------------------------------------
 # ● Battler Scale
 #-------------------------------------------------------------------------- 
  # This is where you can re-scale your battler. e.g. Godzilla Mode
  # After FULL ACTION is done, the scaling is reset.
  # Flip and weapon action are unaffected by this action.
  # 
  # Time - The time it takes to scale the battler.
  # Start - Starting size. Please use decimal values. [X(Horz), Y(Vert)]
  # End - Ending size. Please use decimal values. [X(Horz), Y(Vert)]
  # Type - After scaling process.
  #         [ 0: Reset Scale ]
  #         [ 1: Maintain Scale ]
  #         [ 2: Loop Scale ]
 
  # -Action Name-              Type    Time   Start        End      Type
  "Shink Horizontally"         => ["zoom",  12,  [1.0, 1.0],  [0.5, 1.0],  0],
  "Shink Vertically"           => ["zoom",  12,  [1.0, 1.0],  [1.0, 0.5],  0],

#--------------------------------------------------------------------------
 # ● Battler Transparency/Opacity
 #-------------------------------------------------------------------------- 
  # This is the location of the battler transparency control.
  # Once the FULL ACTION is done, the transparency is reset.
  # 
  # Time - The time it takes to change the transparency.
  #
  # Start - The starting transparency.
  # End - The ending transparency.
  # 0 makes it disappear completely and 255 full opaque.
  #
  # Shadow - Set true if you want the shadow to be affected.
  # Weapon - Set true if you want the weapon to be affected.
  # Loop - Loop the transparency by reversing the transparency process.
  # Wait - Wait until the transparency ends before moving to the next action.
  
  # -Action Name-      Type       Time  Start  End   Shadow Weapon  Loop  Wait
  "Escape Fade"         => ["opacity",   30,  255,   0,  true,  true, false, false],
  "Transparent"           => ["opacity",   60,  255,   0,  true,  true, false, false],
  "Transparent WT"         => ["opacity",   60,  255,   0,  true,  true, false,  true],
  "Clear Transparent"       => ["opacity",   60,    0, 255,  true,  true, false, false],
  "Clear Transparent WT"     => ["opacity",   60,    0, 255,  true,  true, false,  true],
  
 #--------------------------------------------------------------------------
 # ● Balloon Animation
 #--------------------------------------------------------------------------
  # This is where you display the speech bubble icon for an event.
  #
  # ID Type - Specify what type of balloon you want to display from 0~9.
  # Speed - Update rate of the balloon. Cell will be played from the 2nd frame.
  # Size - Size of the balloon. 1.0 for normal size.
  
  # -Action Name-             Type       ID  Speed  Size
  "Abnormal State/Generic"   => ["balloon",   6,  10,  0.6],
  "Abnormal State/Weak" => ["balloon",   5,  10,  0.6],
  "Abnormal State/Sleep"   => ["balloon",   9,  10,  0.6],
  
 #--------------------------------------------------------------------------
 # ● Picture Display
 #--------------------------------------------------------------------------
  # This here you can control the display of pictures. e.g. Cut-Ins
  #
  # Number - This is basically the ID number of the picture. Just like the
  #          events, the ID number is used to manage the picture itself.
  #          The picture will be automatically be erased (release the bitmap)
  #          after the FULL ACTION is done.
  # Start - Movement start position. [X, Y] Origin is at the top-left [0, 0].
  #         If there is already a picture, use [] to start at the position of
  #         the pre-existing picture.
  # End - Movement end position. Will only display if the value is the same as
  #       the start. Movement speed will be maintained both start and end
  #       values are made into [].
  # Time - Time it takes to move the picture. 0 will clear the picture
  # Z - Z display. If 100 or more are used, it will be displayed to the front
  #     of the window.
  # Alpha - Picture transparency. [Starting opacity, Opacity added per frame]
  # Plane - Rectangle plane of the picture. (Image is tiled in the plane.)
  #         If the plane is not used, use [] instead.
  # BAReverse - Image and movement will be flipped on back attack on true.
  #             If the Plane is used, only the X-axis will be flipped but not
  #             the image.
  # Filename - Filename of the picture.
 
  # -Action Name-        Type   No.  Start      End     Time   Z  Alpha    Plane   BAFlip  Filename
  "Cut-in A1"       => ["pic",  0, [-300,   8], [ 100,   8],  30, 90, [  0, 10],        [],  true, "Actor4-1"],
  "Cut-in A2"       => ["pic",  0, [-300,   8], [ 100,   8],  30, 90, [  0, 10],        [],  true, "Actor4-2"],
  "Cut-in A3"       => ["pic",  0, [-300,   8], [ 100,   8],  30, 90, [  0, 10],        [],  true, "Actor5-2"],
  "Cut-in A4"       => ["pic",  0, [-300,   8], [ 100,   8],  30, 90, [  0, 10],        [],  true, "Actor5-3"],
  "Cut-in End"      => ["pic",  0,          [], [ 600,   8],  30, 90, [255,  0],        [],  true, ""],
  "Cut-in BG Start" => ["pic",  1, [   0,   8], [ 100,   8],  10, 80, [  0, 10], [544,288],  true, "cutin_back"],
  "Cut-in BG End"   => ["pic",  1,          [],          [],  10, 80, [255, -7], [544,288],  true, ""],
  "White Fade-In"       => ["pic",  0, [   0,   0], [   0,   0],  50,500, [  0,  6],        [], false, "white"],
  "White Fade-Out"      => ["pic",  0, [   0,   0], [   0,   0],  50,500, [255, -6],        [], false, "white"],
  
 #--------------------------------------------------------------------------
 # ● State Operations
 #--------------------------------------------------------------------------
  # This is where you can control adding and removing of states.
  #
  # Target - State target.
  #          [  0: Current Battler ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  #          [  5: Second / Next Target  ]
  # Extend - Extension of the target area.
  #          [  0: No expansion   ]
  #          [  1: Random Target  ]
  #          [  2: Except Current Battler  ]
  # Operation - Add state with "+", Remove state with "-".
  # ID - State ID used. Use an array of states to add or remove.
  #      e.g. [2,3] gives Poison and Blind. [1] gives Death.
  
  # -Action Name-          Type Target Extend Opt ID
  "Apply Death"         => ["sta",  0,   0, "+",  [1]],
  
 #--------------------------------------------------------------------------
 # ● FPS Modified (Change the speed of the whole game)
 #--------------------------------------------------------------------------
  # This area changes the speed of the /ENTIRE/ game. Timers and update speed
  # are affected by this also.
  # The default speed of the game is 60.
  # Any lower than 60 will slow down the game. Doing otherwise will speed up.
  # Be sure to reset the FPS when done.
  #
  # FPS - Set FPS of the game.
  
  # -Action Name-     Type   FPS
  "Slow Play"   => ["fps",  15],
  "CasiNormal Play"   => ["fps",  45],
  "Normal Play"     => ["fps",  60],
  
 #--------------------------------------------------------------------------
 # ● Battler Image Change
 #--------------------------------------------------------------------------
  # This area here allows you to change the image referenced by the battle.
  # e.g. Transformation Effects
  #
  # Maintain - Maintain form even after combat if set to true.
  # Index - Index of the character image in the character file.
  #         Use 0 if using the "$" or single character setup.
  #           [0][1][2][3]
  #           [4][5][6][7]
  # Filename - The filename of the image.
  #            Actors are in the Characters folder.
  #            Enemies are in the Battlers folder.
  # Face - In case of the actor, you can also change the face graphic.
  #        Use 0 if using the "$" or single character setup in the Face Index.
  #        [Face Index, Filename]
  #        If you don't want to change, use [].
  
  # -Action Name-         Type     Maintain Index Filename   Face
  "Wolf Transform"    => ["change", false,    6,    "Animal", [0, "Actor4"]],

 #--------------------------------------------------------------------------
 # ● Derive/Chain Skill
 #--------------------------------------------------------------------------
  # This section lets you chain or derive a skill from the database.
  #
  # Learned - Perform even if the skill is not learned.
  # Cost - Perform even if the cost of the skill is not enough.
  # ID - Skill ID used.
  
  # -Action Name-                   Type    Learned Cost    ID
  "Derive Multi-Stage Attack"   => ["der",  true,  false,   1],
 #--------------------------------------------------------------------------
 # ● Play Sound/Music
 #--------------------------------------------------------------------------
  # This portion allows you to play music or sound on the battle field.
  #
  # Sound Type - The type of the sound used.
  #        "se" - Sound Effect
  #        "bgm" - Background Music
  #        "bgs" - Background Sound
  # Pitch - Change pitch. Use 50~150. 100 is the default.
  # Volume - Change volume. Use 50~150. 100 is the default.
  # Filename - Filename of the sound. Use "" for no BGM/BGS.
  
  # -Action Name-     Type   SType Pitch Volume Filename
  "Bow1"          => ["sound",  "se", 100,  80, "Bow1"], #Sonido Predefinido
  "Gun1"   => ["sound", "se", 100, 80, "Gun1"],
  "Cerb1"          => ["sound",  "se", 100,  80, "Bow1"],
  "Rocket1"        => ["sound",  "se", 100,  80, "rocket_launcher0"],
  "throw_se"        => ["sound",  "se", 100,  80, "smrpg_enemy_throw"],
  
  
 #--------------------------------------------------------------------------
 # ● Play Movie
 #--------------------------------------------------------------------------
  # This area here allows you to play *.ogv files in which are movie files.
  #
  # Filename - The filename of the movie.
  #            Should be placed in the "Movies" folder.
  
  # -Action Name-          Type    Filename
  "Death Flag Movie" => ["movie", "sample1"],
  
 #--------------------------------------------------------------------------
 # ● Switch Control
 #--------------------------------------------------------------------------
  # This allows you to change the modes of the switches during battle.
  # Using a negative value will change the switch to apply only in-battle.
  # Otherwise, it will change it outside of the battle too.
  #
  # ON - Set an array of switches to ON.
  # OFF - Set an array of switches to OFF.
  # e.g. [2,3] affects Switch 2 and 3, [1] only affects switch 1.
  # 
  
  # -Action Name-                 Type      ON      OFF  
  "Switch No1 / ON"  => ["switch",  [ 1],   []],
  "Change Space Background"=> ["switch",  [-4],   []],
  "Remove Space Background"  => ["switch",    [],   [-4]],
  "Magic Square ON"        => ["switch",  [-5],   []],
  "Magic Square OFF"       => ["switch",    [],   [-5]],
  
 #--------------------------------------------------------------------------
 # ● Variable Control
 #--------------------------------------------------------------------------
  # This section allows you to change the variables during battle.
  #
  # ID - ID of the variable you want to modify.
  # Operation - Operation used in the variable.
  #             [ 0: Assign  ]
  #             [ 1: Add  ]
  #             [ 2: Subtract  ]
  #             [ 3: Multiply  ]
  #             [ 4: Divide  ]
  #             [ 5: Remainder  ]
  # Operand - Value set into the variable with the operation. Using a
  #           negative value will give the absolute value of the number.
  
  # -Action Name-           Type        ID  Operation Operand
  "Variable No1 /+1"     => ["variable",   1,     1,     1],
  
 #--------------------------------------------------------------------------
 # ● Conditional Branch (Switch)
 #--------------------------------------------------------------------------
  # This is where you can use an IF conditional branch on your actions with
  # switches.
  #
  # ID - Switch ID. Use negative to operate only in battle.
  # Condition - Condition used. Use TRUE if ON, FALSE if OFF.
  # Branch - Branch processing if condition is met.
  #             [ 0: The next action is executed ]
  #             [ 1: The next action is cancelled ]
  #             [ 2: The FULL ACTION is exited ]
  
  # -Action Name-            Type    ID    Cond  Branch
  "Run at Switch No1=ON" => ["n_1",   1,   true,   0],
  "If Timed Hit"         => ["n_1",  101,  true,   0],
  "If Blocked Hit"       => ["n_1",  103,  true,   0],
  
  
 #--------------------------------------------------------------------------
 # ● Conditional Branch (Variable)
 #--------------------------------------------------------------------------
  # This is where you can use a IF conditional branch on your actions with
  # variables.
  #
  # ID - Variable ID.
  # Value - Value checked in the variable. Using a negative value will
  #         give the absolute value of the number.
  # Condition - Condition used.
  #             [ 0: Equal to ]
  #             [ 1: Lower than ]
  #             [ 2: Larger than ]
  # Branch - Branch processing if condition is met.
  #             [ 0: The next action is executed ]
  #             [ 1: The next action is cancelled ]
  #             [ 2: The FULL ACTION is exited ]

  # -Action Name-                 Type    ID    Value  Cond  Branch
  "Run at Variable No1=1"      => ["n_2",   1,    1,    0,    0],
 
 #--------------------------------------------------------------------------
 # ● Conditional Branch (State)
 #--------------------------------------------------------------------------
  # This is where you can use a IF conditional branch on your actions if a
  # state is active.
  # Target - State target.
  #          [  0: Current Battler ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  #          [  5: Second / Next Target  ]
  # ID - State ID to check.
  # Condition - Condition used. [0: Inflicted] [1: Non-Inflicted]
  # Number - The required number of battlers to fulfil the condition.
  #          If the target is a group, the number of members becomes 0.
  # Branch - Branch processing if condition is met.
  #             [ 0: The next action is executed ]
  #             [ 1: The next action is cancelled ]
  #             [ 2: The FULL ACTION is exited ]
  
  # -Action Name-                Type    Target ID   Cond    No. Branch
  "Death Confirm"             => ["n_3",   1,    1,    0,     1,   1],
 
 #--------------------------------------------------------------------------
 # ● Conditional Branch (Skill)
 #--------------------------------------------------------------------------
  # This is where you can use a IF conditional branch on your actions if a
  # state is performed.
  #
  # Target - Skill target.
  #          [  0: Current Battler ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  #          [  5: Second / Next Target  ]
  # ID - Skill ID to check.
  # Condition - Condition used. [0: Used] [1: Not Used]
  # Number - The required number of battlers to fulfil the condition.
  #          If the target is a group, the number of members becomes 0.
  # Branch - Branch processing if condition is met.
  #             [ 0: The next action is executed ]
  #             [ 1: The next action is cancelled ]
  #             [ 2: The FULL ACTION is exited ]
  
  # -Action Name-                   Type  Target ID   Cond   No. Branch
  "Strong Attack Confirm"       => ["n_4",  0,   80,    0,    1,   0],
 
 #--------------------------------------------------------------------------
 # ● Conditional Branch (Parameter)
 #--------------------------------------------------------------------------
  # This is where you can use a IF conditional branch on your actions if a
  # parameter is reached.
  #
  # Target - Parameter target.
  #          [  0: Current Battler ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  #          [  5: Second / Next Target  ]
  # Stat - Stats to check.
  #          [ 1: Level ] [ 2: MaxHP ] [ 3: MaxMP ] [ 4: HP ] [ 5: MP ]
  #          [ 6: TP ] [ 7: ATK ] [ 8: DEF ] [ 9: MATK ] [ 10: MDEF ]
  #          [ 11: AGI ] [ 12: LUK ]
  # Value - Value checked in the variable. Using a negative value will
  #         use percentage. (HP, MP and TP only)
  # Condition - Condition used.
  #             [ 0: Equal to ]
  #             [ 1: Lower than ]
  #             [ 2: Larger than ]
  # Number - The required number of battlers to fulfil the condition.
  #          If the target is a group, the number of members becomes 0.
  # Branch - Branch processing if condition is met.
  #             [ 0: The next action is executed ]
  #             [ 1: The next action is cancelled ]
  #             [ 2: The FULL ACTION is exited ]

  # -Action Name-           Type  Target Stat Value Cond   No. Branch
  "+HP50% Confirm"      => ["n_5",  0,    4,  -50,    2,    1,   0],
 
 #--------------------------------------------------------------------------
 # ● Conditional Branch (Equipment)
 #--------------------------------------------------------------------------
  # This is where you can use a IF conditional branch on your actions if an
  # item is equipped.
  #
  # Target - Equipment target.
  #          [  0: Current Battler ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  #          [  5: Second / Next Target  ]
  # Equip Type - The type of equipment to check. [ 0: Weapon ] [ 1: Armor ]
  # ID - Item ID. Use an array of items to check. Use negative to refer to type.
  # Condition - Condition used. [0: Equipped] [1: Not Equipped]
  # Number - The required number of battlers to fulfill the condition.
  #          If the target is a group, the number of members becomes 0.
  # Branch - Branch processing if condition is met.
  #             [ 0: The next action is executed ]
  #             [ 1: The next action is cancelled ]
  #             [ 2: The FULL ACTION is exited ]
  
  # -Action Name-          Type  Target Equip   ID   Cond   No. Branch
  "Hand Axe Limit"      => ["n_6",  0,    0,    [1],    0,    1,   0],
  "Fist Limit"          => ["n_6",  0,    0,   [-2],    0,    1,   0],
  "Fist Exclude"        => ["n_6",  0,    0,   [-2],    0,    1,   1],
  "Bow Limit"           => ["n_6",  0,    0,   [-6],    0,    1,   0],
  "Bow Exclude"         => ["n_6",  0,    0,   [-6],    0,    1,   1],
  "Fist + Bow Exclude"  => ["n_6",  0,    0,[-2,-6],    0,    1,   1],
  "Guns Exclude"        => ["n_6",  0,    0,[-10,-11],  0,    1,   1],
  "Cerbatana Exclude"   => ["n_6",  0,    0,    [-7],   0,    1,   1],
  "Throw Exclude"       => ["n_6",  0,    0,    [-18],  0,    1,   1],
 #--------------------------------------------------------------------------
 # ● Conditional Branch (Script)
 #--------------------------------------------------------------------------
  # This is where you can use a IF conditional branch on your actions if a
  # script returns true or false.
  #
  # Branch - Branch processing if condition is met.
  #             [ 0: The next action is executed ]
  #             [ 1: The next action is cancelled ]
  #             [ 2: The FULL ACTION is exited ]
  # Script - Script code that should return true or false.
  "50% Probability"      => ["n_7",   0,  "rand(100) < 50"],
  "Actor Limit"         => ["n_7",   0,  "@battler.actor?"],
  "Actor ID1 Limit"      => ["n_7",   0,  "@battler.actor? && @battler.actor_id == 1"],
  "Actor ID2 Limit"      => ["n_7",   0,  "@battler.actor? && @battler.actor_id == 2"],
  "Actor ID6 Limit"      => ["n_7",   0,  "@battler.actor? && @battler.actor_id == 6"],
  "Actor ID7 Limit"      => ["n_7",   0,  "@battler.actor? && @battler.actor_id == 7"],
  "Enemy Limit"         => ["n_7",   0,  "!@battler.actor?"],
  "Enemy Exclude"         => ["n_7",  1,  "!@battler.actor?"],
  "Enemy Abort"         => ["n_7",   2,  "!@battler.actor?"],
  "Dual Wield Limit"    => ["n_7",   0,  "@battler.dual_wield?"],
  
#--------------------------------------------------------------------------
 # ● Second Target Control
 #--------------------------------------------------------------------------
  # This is where you can control the second target.
  # The second target is separate from the first target.
  # If you do not set the second target, usually the second target is the
  # same as the first target.
  # 
  # Target - Set the target.
  #          [  0: Current Battler ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  #          [  5: Second / Next Target  ]
  # 
  # Index - Narrow down by index of the party. Index = [Index, Type]
  #         Index - Index value of the party.
  #         Type - Set the condition type.
  #             [0: Don't narrow down][1: Set to index][2: Index is removed]
  #
  # ID - Narrow down the target by actor(enemy) ID.
  #      Using a negative value will exclude the absolute value of the ID.
  #      Doesn't narrow down if set to 0.
  #
  # State - Narrow down the target by state ID.
  #         Using a negative value will add the ones who doesn't have the state.
  #         Doesn't narrow down if set to 0.
  # 
  # Skill - Narrow down the target by skill ID.
  #         Using a negative value will add the ones who doesn't use the skill.
  #         Doesn't narrow down if set to 0.
  # 
  # Parameter - Narrow down the target by parameters.
  #             Parameter = [Stats, Value, Cond]
  #             Stat - Stats to check. [ 0: Don't Narrow ]
  #                 [ 1: Level ] [ 2: MaxHP ] [ 3: MaxMP ] [ 4: HP ] [ 5: MP ]
  #                 [ 6: TP ] [ 7: ATK ] [ 8: DEF ] [ 9: MATK ] [ 10: MDEF ]
  #                 [ 11: AGI ] [ 12: LUK ]
  #             Value - Value checked in the variable. Using a negative value
  #                     will use percentage. (HP, MP and TP only)
  #             Condition - Condition used.
  #                 [ 0: Equal to ]
  #                 [ 1: Lower than ]
  #                 [ 2: Larger than ]
  #
  # Equip - Narrow down the target by equipment. Equip = [Type, ID]
  #       Equip Type - The type of equipment to check.
  #                   [ 0: Weapon ] [ 1: Armor ]
  #       ID - Item ID. Use an array of items to check.
  #            Use negative to refer to type. Doesn't narrow down if set to 0.
  #
  # Extend - Extension of the target area.
  #          [  0: No expansion   ]
  #          [  1: Random Target  ]
  #          [  2: Except Current Battler  ]
  # Operation - Modify target control
  #          [  0: No change   ]
  #          [  1: Switch second target with the first target  ]
  #          [  2: Set both first and second target  ]           
  
  # -Action Name-            Type Target Index ID State Skill Parameter Equip   Extend Operation
  "All Members Except Self"=> ["s_t", 3, [ 0, 0], 0,  0,   0, [ 0, 0, 0], [ 0,[0]],  2,   0],
  "Whole Field"          => ["s_t", 4, [ 0, 0], 0, -1,   0, [ 0, 0, 0], [ 0,[0]],  0,   1],
  
 #--------------------------------------------------------------------------
 # ● Call Common Event
 #--------------------------------------------------------------------------
  # This section allows you to call a common event.
  # ID - Common Event ID
  # Wait - Stop the action while executing the event.
  # 
  
  # -Action Name-                Type    ID    Wait
  "Timer Hit Starter"         => ["common",  1,  true], 
  "Timer Hit Stopper"         => ["common",  2,  true], 
  "Timer Hit Flow"            => ["common",  3,  true], 
  "Timer Block Flow"          => ["common",  6,  true], 
  "Reduce Damage Multiplier"  => ["common",  7,  true], 
  "Increase Damage Multiplier"=> ["common",  9,  true], 
  
  
  
 #--------------------------------------------------------------------------
 # ● Script Control
 #--------------------------------------------------------------------------
  # This section just simply allows you to execute a script.
  # Simply place the script in the array between quotes.
  
  # -Action Name-    Script
  "Test Script" => ["p = 1 "],
  
 #--------------------------------------------------------------------------
 # ● Other - Special Modifiers (DO NOT CHANGE)
 #--------------------------------------------------------------------------
  # This is where all the other types of actions you can use in FULL ACTION.
  #
  # Erase Battle Anim - Erases Battle Animation.
  #                    (Flight and animation is not cleared)
  # Force End - Immediately ends the battle.
  # Screen Fix - Freezes the screen to be prepared for a transition.
  # Damage Animation - Plays the skill animation and displays the damage popup
  #                    before skill is finished.
  # Flip - The battler and the weapon is flipped. Can be flipped again or resets
  #        when the FULL ACTION is ended.
  # Hide Weapon - Hides the weapon.
  # Show Weapon - Shows the weapon.
  # Collapse Enemy - Run the death effect on the enemy. Mainly used for
  #                  invunerable enemies.
  # Don't Collapse - Prevent collapse on 0 HP of the target.
  # Collapse - Disables "Don't Collapse" and enemy dies if HP is 0.
  # Disable Wait - Disables and cancel all the wait actions.
  # Enable Wait - Enables all wait actions.
  # Change Base Position - Base position is changed into the current position.
  # Reset Base Position - Base position is changed back into the default position.
  # Force Action - Force the action of the target. (Reaction)
  # Force Action 2 - Force the action of the 2nd target. (Reaction)
  # Next Battler - The next battler will start immediately once the action of
  #                the current battler is done.
  # Solo Start - Start behavior for the battler to solo and to attack
  #                    two or more target attacks.
  # Solo End - End behavior for the battler to solo and to attack
  #                    two or more target attacks.
  # Loop Start - Loop start, loops between the start and the end.
  # Loop End - Loop end, loops between the start and the end.
    
  # -Action Name-      Function
  "Erase Battle Anim"    => ["anime_off"],
  "Force End"      => ["battle_end"],
  "Screen Fix"          => ["graphics_freeze"],
  "Damage Animation"    => ["damage_anime"],
  "Flip"              => ["mirror"],
  "Hide Weapon"          => ["weapon_off"],
  "Show Weapon"      => ["weapon_on"],
  "Collapse Enemy"        => ["normal_collapse"],
  "Don't Collapse"      => ["no_collapse"],
  "Collapse"  => ["collapse"],
  "Disable Wait"    => ["non_motion"],
  "Enable Wait"=> ["non_motion_cancel"],
  "Change Base Position"      => ["change_base_position"],
  "Reset Base Position"  => ["set_base_position"],
  "Force Action"              => ["force_action"],
  "Force Action 2"             => ["force_action2"],
  "Next Battler"      => ["next_battler"],
  "Solo Start"          => ["individual_start"],
  "Solo End"          => ["individual_end"],
  "Loop Start"        => ["loop_start"],
  "Loop End"        => ["loop_end"],
  
 #--------------------------------------------------------------------------
 # ● Wait
 #--------------------------------------------------------------------------
  # This section explains how to let you wait before the next action.
  # If the action is only numbers, that is most likely a wait time.
  # Example: "20" - This will wait for 20 frames before the next action.
  # 
  # Using a negative number will randomate the wait time from 0 to the
  # absolute number of the value.
  # Example: "-20" - This waits for a random no. of frames between 0~20.
   
 #--------------------------------------------------------------------------
 # ● Shortcut commands
 #--------------------------------------------------------------------------
  # This section explains how to put in commands directly than using
  # registers. Allows you to conserve time and possibly reduce work and space.
  # It's recommended to use registers for more flexibility unless it does not
  # need much modifications.
  # 
  # [Combat Animation]
  # Example:
  #     "anime(20)" - Play animation on target ID 20, wait.
  #     "anime(20, false)" - Play animation on target ID 20, no wait.
  #     "anime_me(20)" - Play animation on self ID 20, wait.
  #     "anime_me(20, false)" - Play animation on self ID 20, no wait.
  # 
  # [Wait index delay]　Wait multiplies by party index
  # Example:
  #     "delay(12)" The wait of Index 1 is 0, Index 2 is 12, Index 3 is 24
  # 
  # [Sound Effect]
  # Example:
  #     "se('Bow1')" - Plays the sound effect "Bow1".
  #     "se('Bow1',50)" - Plays the sound effect "Bow1" with Pitch "50".
  # 
  # [Force Action (Full Action)]
  # Example:
  #     "target('Normal Attack')" - Forces normal attack on the target.
  #     "target2('Damage')" - Forces damage on the second target.
   
  }  
#==============================================================================
# ■ Full Action
#------------------------------------------------------------------------------
# 　A full action is a combination of actions that starts from the left to end.
#  It is possible to insert a FULL ACTION into another FULL ACTION. As well
#  as some parts of it.
#  Such use of it would be using a condition before another FULL ACTION.
#==============================================================================
  FULLACTION = {
  
  # En Espera
  "Idle"        => ["Wait"],
  "Fixed Idle"    => ["Wait(Fixed) WT"],
  "Weak Stance"      => ["Abnormal State/Weak","Danger Tone","Wait","Wait"],
  "Defense Stance"        => ["Wait(Fixed) WT"],
  "Poison Stance"          => ["Abnormal State/Generic","Poison Tone","Wait","Wait","Enemy Limit","80"],
  "Quemadura"       => ["Abnormal State/Generic","BurningColor","Wait","Wait","Enemy Limit","80"],
  "Congelado"       => ["Abnormal State/Generic","FreezeColor","Wait","Wait","Enemy Limit","80"],
  "Sleep Stance"        => ["Abnormal State/Sleep","Enemy Limit","40","Enemy Abort","Fallen","Fallen"],
  "General Abnormal Stance"=> ["Abnormal State/Generic","Generic Status Abnormal Tone","Wait","Wait","Enemy Limit","80"],
  "Standby"          => ["Wait","60"],
  "Dead"        => ["Fallen"],
  
  # ――Basado en el Sistema――
  "Battle Start Ally"    => ["Before Battle Entry","delay(4)","Coordinate Reset Left"],
  "Ally Exit"        => ["Exit"],
  "Escape"            => ["Skill Anim","Reset Camera","delay(4)","Exit"],
  "Enemy Escape"          => ["Skill Anim","Escape Fade","Exit"],
  "Escape Fail"        => ["Reset Camera","delay(4)","Escape Middle","One Step After Move","Coordinate Reset Left"],
  "Command"    => ["Erase Battle Anim","Command Input"],
  "Command End"=> ["Coordinate Reset Fast"],
  "Command Defend"  => ["Wait(Fixed) WT"],
  "Command Magic"  => ["Wait(Fixed)","Magic Chant"],
  "Command Skill"  => ["Wait(Fixed)","Skill Prepare"],
  "Defend"            => ["Skill Anim","Wait(Fixed) WT"],
  "Evade"            => ["Actor Limit","Rotate Right Once","One Step After Jump","10","Coordinate Reset Left"],
  "Weapon Block"        => ["Front Rotate","se('Evasion2')","Wpn Swing R"],
  "Shield Guard"        => ["se('Evasion2')","Shield Defense","60"],
  "Substitute Start"    => ["Move Enemy Fast","Change Base Position"],
  "Substitute End"    => ["Reset Base Position","Coordinate Reset Left"],
  "Substitute Start - Receiver"  => ["One Step After Move","One Step After Move","Wait(Fixed) WT"],
  "Substitute End - Receiver"  => ["Coordinate Reset Left"],
  "Victory Pose"  => ["Erase Battle Anim","Victory Jump Weapon","Victory Jump Land","120"],
  "Victory Backward Somersault"=> ["Erase Battle Anim","Rotate Right Once","Victory Jump","Fist Limit","Thrust Fist Weapon","Fist Exclude","Wpn Swing R","200"],
  "Flash Self"            => ["anime_me(119)","20"],
   # Where the action starts and finishes. Tilt a hint of the timed hit
  "Timer Hit Init"        => ["anime_me(111,false)", 
                              "Timer Hit Starter",
                              "Enemy Exclude",
                              "Timer Hit Flow",
                              "Enemy Limit" ,
                              "Timer Block Flow"
                            ],
  "Block Timed"      => ["Reduce Damage Multiplier","target('Weapon Block')" ],
  # Secuencia de daño
  "Damage"      => ["Damage Pull","Coordinate Reset Left"],
  "Big Damage"    => ["Medium Shake","Large Damage Pull" ,"Coordinate Reset Left"],
  "Transparent"            => ["Transparent","Loop Start","120","Loop End"],
  "Pitching"          => ["Pitch 01","Pitch 02","Pitch 01","Pitch 02","Pitch 01","Pitch 02"],
  
  # Secuencias de Ataques
  "Slash"            => ["Wpn Swing R","Weapon Anim","10"],
  "Fist"             => ["Thrust Fist Weapon","Weapon Anim","10"],
  "Bow"              => ["Bow1","Bow Shot","Arrow Fire","9"],
  "Attack"           => ["Fist Limit","Fist","Bow Limit","Bow","Fist + Bow Exclude","Slash"],
  "Skill Timed Hit"  => ["Wpn Swing R","Skill Anim","10"],

  # Timed Hits  
  "Normal Attack Start"    => [ "Move Before Enemy",
                                "Timer Hit Init",
                                "Don't Collapse",
                                # "If Timed Hit",
                                # "Increase Damage Multiplier",
                                "Solo Start",
                                "Dual Wield Limit",
                                "Slash Left",
                                "If Blocked Hit",
                                "Block Timed"],

  "Normal Attack End"  => ["Death Confirm",
                            "Weapon Anim WT",
                            "Solo End",
                            "If Timed Hit",
                            "Attack",
                            "Collapse",
                            "Next Battler",
                            "Coordinate Reset Curve"],
                            
    # Ranged Timed Hit
    "Ranged Attack Start"  => [ "One Step Before Move",
                                "Timer Hit Init",
                                "Don't Collapse",
                                "Solo Start",
                                "If Timed Hit",
                                "Increase Damage Multiplier"
                                ],

    "Ranged Attack End"  => [ "Solo End",
                              # "If Timed Hit",
                              # "Attack",
                              "Collapse",
                              "Coordinate Reset"],

    "Skill Attack End"  => ["Death Confirm",
                            "Skill Anim WT",
                            "Solo End",
                            "If Timed Hit",
                            "Skill Anim",
                            "Collapse",
                            "Next Battler",
                            "Coordinate Reset Curve"],
    
    "Looped Special Attack" => [],

  "Slash Left"          => ["Wpn Swing L","Weapon Anim LWT"],
  "Skill Motion"        => ["One Step Before Move","Wpn Raised","Skill Active Anim"],
  "Magic Motion"        => ["One Step Before Move","Wpn Raised","Magic Active Anim"],
  "Cut-in"      => ["Cut-in BG Start","Cut-in Branch","70","Cut-in End","Cut-in BG End","20"],
  "Cut-in Branch"  => ["Actor ID1 Limit","Cut-in A1","Actor ID2 Limit","Cut-in A2","Actor ID6 Limit","Cut-in A3","Actor ID7 Limit","Cut-in A4"],
  "Death Flag Video"  => ["White Fade-In","50","Death Flag Movie","White Fade-Out","50"],
  "Space Background"    => ["Zoom Out","se('Blind',70)","Dim Background","All Members Except Self","Force Action 2","Transparent","Transparent","40","Change Space Background","Hue Default"],
  "Space Background Release"    => ["Reset Camera","Dim Background","target2('Clear Transparent WT')","Clear Transparent","40","Remove Space Background","Hue Default"],
  "Magic Square Display"      => ["se('Blind',70)","Screen Fix","Magic Square ON","Circle"],
  "Magic Square Erase"      => ["40","Screen Fix","Magic Square OFF","Circle"],
  
  # Ataques Normales Base
  "Normal Attack"        => ["Normal Attack Start","Wait(Fixed)","Normal Attack End"],
  
  "Slash Attack"         => ["Normal Attack Start","Death Confirm","Wpn Swing R","Normal Attack End"],
  
  "Fist Attack"          => ["Normal Attack Start","Thrust Fist Weapon","Normal Attack End"],
  
  "Thrust Attack"        => ["Normal Attack Start","Thrust Weapon","Normal Attack End"],

  "Hamr"                 => ["Normal Attack Start","Hammer","Normal Attack End"],

  "Skill Attack"         => ["Normal Attack Start","Wait(Fixed)","Skill Attack End"],




  "Bow Attack"          => ["Ranged Attack Start","Bow1","Bow Shot","Arrow Fire WT","Ranged Attack End"],
  
  "Gun"   => ["Ranged Attack Start","Gun1","GunPoint","BullerWT","Ranged Attack End"],
  
  "Rckt"   => ["Ranged Attack Start","Rocket1","RocketPoint","RocketWT","Ranged Attack End"],
  
  "Cerb"   => ["Ranged Attack Start","Cerb1","Cerbatana","CerbWT","Ranged Attack End"],
  

  
  "Multi Attack" => ["Skill Motion","Don't Collapse","Attack","Attack","Attack","Collapse","Coordinate Reset"],

  
  
 

  # Habiliades personalizadas
  
  "Generic Skill"      => ["Skill Motion","Wpn Swing R","Damage Animation","Coordinate Reset"],
  
  "Generic Magic"        => ["Magic Motion","Wpn Swing R","Damage Animation","Coordinate Reset"], 
  
  "Water Gun"     => ["Skill Motion","Wpn Swing R","Water Gun Fire","Wait","Coordinate Reset"],
  
  "Acuasphere"     => ["Skill Motion","Wpn Swing R","anime_me(146,false)","Wait", "Acuaesfera Fire","Coordinate Reset"],
      
  "Throw Weapon"        => ["Skill Motion","Wpn Swing R","6","Wait(Fixed)","Wpn Throw Start","Wpn Throw Return","Coordinate Reset"],  
  
  "Arrojadiza"        => ["Skill Motion","Wpn Swing R","6","Wait(Fixed)","Wpn Throw Start","Coordinate Reset"],  
  
  "Cut-in Attack"  => ["Skill Motion","Cut-in","Attack","Coordinate Reset"],
  
  "Movie Attack"    => ["Skill Motion","Wait(Fixed)","Death Flag Video","Normal Attack Start","Wpn Swing R","Normal Attack End"],
  
  "Wolf Transformation"    => ["Skill Motion","anime(110,false)","Wolf Transform","Wait(Fixed)","120","Coordinate Reset"],
  
  "Attack 5 Times"         => ["Skill Motion","Don't Collapse","Bow Exclude","Attack","Attack","Attack","Collapse","Coordinate Reset"],
  
  # "Skill Motion" Iniciar habilidad hacia el enemigo
  # "Don't Collapse" Prohibir Colapso, obliga al enemigo aguantar la secuencia de golpes
  # "Bow Exclude"
  # "Move Before Enemy" Ir al frente del enemigo
  # "Attack" Impacto/Ataque
  # "Collapse" Permitir el colapso al final
  # "Coordinate Reset" Reiniciar posicion

  "Derived Skill"      => ["Throw Weapon","Derive Multi-Stage Attack","Slash Attack"],
 
  "Background Change Attack"    => ["Magic Motion","Wpn Swing R","Space Background","Damage Animation","Space Background Release","Coordinate Reset"],
  
  "Picture Attack"     => ["Magic Motion","Magic Square Display","Wpn Swing R","anime(80,false)","60","Hard Shake","Skill Anim","Magic Square Erase","Coordinate Reset"],
 
  "Dim Attack"        => ["Skill Motion","Dim All Except Target","se('Laser',150)",
                        "Afterimage ON","Move Before Enemy","anime(35,false)","Move After Enemy","Skill Anim",
                        "Wpn Swing R","20","Hue Default","Coordinate Reset","Afterimage OFF"],
                        
  "GolpeFlama"        => ["Skill Motion","Don't Collapse",
                        "Move Before Enemy","Move After Enemy","Skill Anim",
                        "Wpn Swing R","20","Hue Default","Collapse","Coordinate Reset"], 
                        
  
  "Directo"           => ["Don't Collapse","Skill Motion","Move Before Enemy","Skill Anim",
                          "One Step After Jump","20","Coordinate Reset","Collapse"],
  
  "Air Attack"        => ["Skill Motion","Bow1","One Step Before Jump","Before Jump Slam",
                        "Wait(Fixed)","Rotate Left Once","10","anime(117,false)","Slammed",
                        "Skill Anim","Medium Shake","Force Action","Pitching","20",
                        "One Step After Jump","Coordinate Reset"],
                        
  "Salto Pesado"       => ["Skill Motion","One Step Before Jump","Before Jump Slam",
                        "Wait(Fixed)","Rotate Left Once","10","Slammed",
                        "Skill Anim","Hard Shake","Force Action","Hard Shake","Pitching","20",
                        "One Step After Jump","Hard Shake","Coordinate Reset"],
  "Salto invertido"       => ["Skill Motion","One Step Before Jump","Before Jump Slam",
                        "Wait(Fixed)","Rotate Left Once","10","Slammed",
                        "Skill Anim","Small Shake","Force Action","Pitching","20",
                        "One Step After Jump","Coordinate Reset"],
                        
                        
                        
  "Salto"      =>["Skill Motion",
                  "CasiNormal Play",
                  "se('smrpg_mario_jump',100)",
                  "One Step Before Jump",
                  "Rotar 180",                               
                  "Before salto",
                  "Wait(Fixed)",
                  "Afterimage ON",
                  "Skill Anim",
                  "Slammed",
                  "Medium Shake",
                  "One Step After Jump",
                  "One Step After Jump",
                  "Afterimage OFF",
                  "Force Action",
                  "Pitching",
                  "Rotar 0",
                  "Normal Play",
                  "20",
                  "One Step After Jump",
                  "One Step After Jump",
                  "Coordinate Reset", 
                  ],
       
 "Derrape" => ["Skill Motion",
                "One Step Before Jump",
                "Afterimage ON",
                "se('smrpg_enemy_fastmovement',100)",
                "Move near Enemy",
                "BolaNieve",
                "One Step After Jump",
                "Afterimage OFF",
                "Coordinate Reset"],
                
 "Derribo" => ["Skill Motion","One Step After Jump",
                "Afterimage ON","se('smrpg_enemy_fastmovement',100)",
                 "Move Before Enemy","Move After Enemy","Skill Anim","Medium Shake",     
                "One Step After Jump","Afterimage OFF","Coordinate Reset"], 
                
  "Placaje" => ["Skill Motion","Move to Enemy","target('Damage Levantamiento')","6","Skill Anim",
                "One Step After Jump","Coordinate Reset","target('Coordinate Reset')"],     
                
 "NadoRapido" => [
                  "Don't Collapse",
                  "Skill Motion",
                  "One Step After Jump",
                  "Rotar 90",
                  "SwiftNado",
                  "Move to Enemy",
                  #"anime_me(69,false)",
                  "Rotar -90",
                  "One Step After Jump",
                  #"Skill Anim",
                  "One Step After Move" ,
                  "Collapse",
                  "Coordinate Reset"
                  ],
                  
 
 "BalaEsp"   => ["Skill Motion","Wpn Swing R","6","Wait(Fixed)","Wpn Throw Start","Coordinate Reset"],
                
 "Use Item"  => ["Wait", "throw_se", "ItemWT","6","Wait(Fixed)","Skill Anim WT","Coordinate Reset Left"],
  
  
  
  }
  
 #==============================================================================
# ■ Battle Program
#------------------------------------------------------------------------------
# 　Manage the display or the program of the battle scene
# 　In-battle effects switch control
#==============================================================================
  BATTLE_PROGRAM = {
  
#--------------------------------------------------------------------------
 # ● Switch Manipulation
 #--------------------------------------------------------------------------
  # This section allows to direct the time to operate the switches.
  # 
  # Switch - The switch that activates the program.
  #          Using a negative number will switch only during battle.
  #          When set to OFF, the program will stop.
  #          All the switches will be turned off at the end of the battle.
  #          To turn on an in-battle switch outside the battle.
  #          Use: $sv_camera.switches[1] = true
  #          1 - Is the switched number, ON = true, OFF = false.
  #
  # ON - Set an array of switches to ON.
  # OFF - Set an array of switches to OFF.
  # e.g. [2,3,-4] affects Switches 2,3 and In-battle 4.
  # Using a negative value will change the switch to apply only in-battle.
  # Otherwise, it will change it outside of the battle too.
  # 
  # Time - Time until the program is executed in frames.
  #        e.g. The program will be executed after 100 frames.
  #        Reference: 30secs... 1800, 1mins... 3600, 5mins... 18000
  #                   10mins... 36000, 1hour... 216000
  # Add - Random frames added to the time in frames.
  #       e.g. If Time is 300 and Add is 300, program will run after 300~600.
   
  # -Program Name-     Type     Switch   ON       OFF   Time     Add
  "Background to Fort"       => ["switch",  -1,   [-2],      [],  1200,     0],
  "Background to Sea"       => ["switch",  -2,   [-3],      [],  2400,     0],
  
 #--------------------------------------------------------------------------
 # ● Play BGM/BGS/SE
 #--------------------------------------------------------------------------
  # This section allows you to change or play BGM/BGS/SE
  #
  # Switch - The switch that activates the program.
  #          Using a negative number will switch only during battle.
  # Sound Type - The type of the sound used.
  #        "se" - Sound Effect
  #        "bgm" - Background Music
  #        "bgs" - Background Sound
  # Pitch - Change pitch. Use 50~150. 100 is the default.
  # Volume - Change volume. Use 50~150. 100 is the default.
  # Filename - Filename of the sound. Use "" for no BGM/BGS.
  #
  # -Program Name-          Type    Switch Type Pitch Volume Filename
  "Sea BGS"            => ["sound",  -1, "bgs",  100,  80, "Sea"],
  
#--------------------------------------------------------------------------
 # ● Background Control
 #--------------------------------------------------------------------------
  # This is where you can change, scroll and modify the background image.
  #
  # Switch - The switch that activates the program.
  # No. - Number of the background to operate. [1:Floor,2:Background]
  # Speed - Speed to move the background [X, Y]
  #            The unit is 100 frames per pixel.
  #            When moving fast, 1000 frames is preferred.
  #
  # BAFlip - Reverse background on back attack.
  # 
  # Image - Change image background. If you don't want to change, use "".
  #         Use the "Battlebacks1" for the floor, "Battlebacks2" for the back.
  #         Changing the background takes over previous background.
  #
  # Link Image - Connecting image on scroll.
  #              If the background changes made while scrolling at the middle,
  #              changes are made by scrolling over.
  #              Does not scroll over diagonally though.
  #
  # Interrupt - Interrupt the previous background with the current background.
  #             True - Connects the background if the background has scroll.
  #             False - When changing backgrounds, the current bg is erased.
  
  # -Program Name-         Type     Switch No. Speed      BAFlip  Image    Link Image     Interrupt
  "Moving Floor"      => ["scroll", -1,  1, [  40,    0],  true,  "",                 "",  true],
  "Change to Sea BG3"   => ["scroll", -2,  1, [ 120,    0],  true,  "Sea_ex03", "Sea_ex02",  true],
  "Change to Sea BG4"   => ["scroll", -3,  1, [  40,    0],  true,  "Sea_ex01", "Sea_ex04",  true],
  "Change to Space1"     => ["scroll", -4,  1, [   0,    0],  true,  "DarkSpace",        "", false],
  "Change to Space2"     => ["scroll", -4,  2, [   0,    0],  true,  "DarkSpace",        "", false],
  
  #--------------------------------------------------------------------------
 # ● Timed Picture
 #--------------------------------------------------------------------------
  # This is where you can display tiled-pictures in the field within a set
  # period with a timer.
  # e.g. Wind and Giant Magic Square
  #
  # Switch - The switch that activates the program.
  # No. - Number/ID of the picture to operate on. You can display multiple
  #       pictures on the battle field.
  #
  # Speed - Speed to move the background [X, Y]
  #            The unit is 100 frames per pixel.
  #            Use 0 to sync with the background.
  # Time - Time for the program to execute per frame. 0 to loop infinitely.
  # Transparency - Transparency/Opacity of the picture.
  #                [Start Opacity, Opacity added per 100 frames]
  #                If the opacity reaches 255, the opacity will return to the
  #                Start Opacity and loop.
  # Z - Z display. If 100 or more are used, it will be displayed to the front
  #     of the window.
  # Shake - Make the picture shake along with the shake action.
  # BAFlip - Reverse background on back attack.
  # Filename - Filename of the picture. Should be located in "Pictures"
    
  # -Program Name-       Type  Switch No.  Speed       Time  Transparency  Z   Shake   BAFlip  Filename
  "Wind"            => ["kpic", -1,  0, [  500,    0],    0, [ 255,   0],  90,   false,  true, "back_wind"],
  "Magic Square"        => ["kpic", -5,  1, [    0,    0],    0, [ 255,   0],  90,    true,  true, "magic_square01"],
  
 #--------------------------------------------------------------------------
 # ● Timed Sound Effect
 #--------------------------------------------------------------------------
  # This is where you can play a sound effect periodically on a timer.
  #
  # Switch - The switch that activates the program.
  # Time - The time period needed per frame before it plays the sound.
  #        The sound will be played periodically with the Time.
  # Add - Random frames added to the time in frames.
  # 
  # Pitch - Change pitch. Use 50~150. 100 is the default.
  # Volume - Change volume. Use 50~150. 100 is the default.
  # Start - Play sound immediately after switch is activated.
  # Filename - Filename of the sound.
  
  # -Program Name-      Type    Switch Time   Add   Pitch Volume Start Filename
  "Seagulls"         => ["keep_se", -1,  400,    100,  150,  60,  false,  "Crow"],
  "Seagulls 2"        => ["keep_se", -1,  300,    200,  140,  45,   true,  "Crow"],
  
#--------------------------------------------------------------------------
 # ● Timed Shake
 #--------------------------------------------------------------------------
  # This is where you can shake the screen periodically on a timer.
  # e.g. On A Train
  #
  # Switch - The switch that activates the program.
  # Time - The time period needed per frame before it plays the sound.
  #        The sound will be played periodically with the Time.
  # Add - Random frames added to the time in frames.
  #
  # Direction - The distance of the shake in the [X, Y] position.
  # Speed - The speed of the shake. The smaller it is, the faster.
  # Fade - How long the shake will take. The distance gets weaker over time.
  # Start - Shake the screen immediately after switch is activated.
    
  # -Program Name-       Type     Switch Time  Add   Dir     Speed Fade  Start
  "Ship Shake"       => ["keep_sk", -1,  130,    0,  [  0, 4], 80,  120,  true],
  
 #--------------------------------------------------------------------------
 # ● Timed Screen Tone
 #--------------------------------------------------------------------------
  # This is where you can change the screen tone periodically on a timer.
  # e.g. Rave Party
  #
  # Switch - The switch that activates the program.
  # Time - The time period needed per frame before it plays the sound.
  #        The sound will be played periodically with the Time.
  # Add - Random frames added to the time in frames.
  #
  #
  # Target - Set the target to which to apply the tone to.
  #          [  0: Background ]
  #          [  1: Selected Target  ]
  #          [  2: All Enemies / Enemy Center Field  ]
  #          [  3: All Allies / Ally Center Field  ]
  #          [  4: Both Allies and Enemies / Battle Field Center  ]
  # Tone - [ Red, Green, Blue, Alpha(Intensity), Change Time, Return Time]
  #        Return Time - Time to return to the original color after change is
  #                      done. 0 to not return to original color.
  # Start - Tone the screen immediately after switch is activated.
  
  # -Program Name-      Type    Switch Time  Add    Target  R     G    B    A     CT   RT   Start
  "Lightning"             => ["keep_c",  0,  300,  100,     4,  [ 255, 255, 255, 255,   8,   8],  true],
  "Emergency" => ["keep_c",  0,  150,    0,     4,  [ 255,   0,   0, 100,  40,  40],  true],
   
} 
#==============================================================================
# ■ Camera Settings
#------------------------------------------------------------------------------
#  These camera settings are actions set separately from the ACTION
# 　Because the camera moves using the action name, do not change the name.
#==============================================================================
  BATTLE_CAMERA = {
#--------------------------------------------------------------------------
 # ● Camera Setup
 #--------------------------------------------------------------------------
  # This area controls the zoom and movement of the screen.
  #
  # Target - Subject of zoom and move
  #          [2: All Enemies] [3: All Allies] [4: Both] [6: Screen]
  # Adjust - Position from the target. [X add →, Y add ↓]
  # Time - Time to move and zoom towards the point.
  # Zoom - Zoom factor of the camera, measured by percent. No zoom at 100.
  
  # -Camera Name-         Type     Target  Adjust     Time Zoom

  "Before Turn Start"   => ["camera",   6, [  40,   0],  95, 40],
  "After Turn Start"   => ["camera",   6, [   0,   0], 100, 40],
  "End of Battle"     => ["camera",   6, [ 100,   0], 100, 50],
  
 
}  
end

