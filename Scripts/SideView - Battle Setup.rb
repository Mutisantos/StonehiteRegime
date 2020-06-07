#==============================================================================
# ■ SideView Battler Setup Ver100
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
# 　Actions made in Action Setup can be set for the Battler here.
# 　Battler Setup
#==============================================================================
class SideView
  #--------------------------------------------------------------------------
  # ● Cell config for Battlers = [Horizontal, Vertical]
  #   If no animation is used, use [1, 1]
  #--------------------------------------------------------------------------
  def max_pattern
    # Single ID Check
    case id
    when  1 # Flamrose
      return [ 3, 4]
    when -1 # Enemigos 
      return [ 3, 4]
    else # Ranged ID Check
      return [ 3, 4] if id > 0 # Cada Actor
      return [ 3, 4] if id < 0 # Cada Enemigo
    end
  end 
  #--------------------------------------------------------------------------
  # ● Shadow Filename
  #   Place Shadow file in the "Characters" folder.
  #   Use false for no shadow.
  #--------------------------------------------------------------------------
  def shadow
    return "shadow01" if id > 0 # Actores
    return false      if id < 0 # Enemigos
  end 
 #--------------------------------------------------------------------------
  # ● Battler Invert Settings
  #   Set to true if you want to flip.
  #--------------------------------------------------------------------------
  def graphic_mirror_flag
    return false if id > 0 # Actores
    return true  if id < 0 # Enemigos
  end 
  #--------------------------------------------------------------------------
  # ● Fixed Image Battler
  #   Battler index must be set to "" if true.
  #--------------------------------------------------------------------------
  def graphic_fix
    return false if id > 0 # Cada Actor
    return true  if id < 0 # Cada Enemigo
  end 
   #--------------------------------------------------------------------------
  # ● Normal Idle/Standby
  #-------------------------------------------------------------------------- 
  def normal
    return "Idle"   ##Todos tienen su respectivo "Idle"
    ## if id > 0 # Cada Actor Nota 1: El ID de los personajes es positivo, el de los enemigos es negativo. 
    ## return "Wait(Fixed) WT" if id < 0 # Cada Enemigo  Nota 2: los que esten abajo del 3 enemigo, no se animaran
  end
  #--------------------------------------------------------------------------
  # ● Weak Idle/Standy
  #   Plays only if you have 1/4 of your HP is left.
  #-------------------------------------------------------------------------- 
  def pinch
    return "Weak Stance" if id < 0 # Cada Actor
    return "Weak Stance" if id > 0 # Cada Actor
  end
  #--------------------------------------------------------------------------
  # ● State Action
  #   If multiple states are overlapping, the top most priority is done.
  # ANIMACION DE ESTADOS
  #-------------------------------------------------------------------------- 
  def state(state_id)
    # Estados por ID
    case state_id 
    when 1 #Muerte
      return "Dead"     if id > 0 # Cada Actor
      return "Collapse Enemy"   if id < 0 # Cada Enemigo
    when 2 #Veneno
      return "Poison Stance"
    when 6 #Sueño
      return "Sleep Stance"
    when 3,4,5,7,8,28
      return "General Abnormal Stance"
    when 26
      return "Quemadura"
    when 29
      return "Congelado"
    when 9 
      return "Defense Stance"
    end
  end
  #--------------------------------------------------------------------------
  # ● After Skill Input Action
  #-------------------------------------------------------------------------- 
  def command
    # Branch for Skill ID
    case skill_id 
    when 2
      return "Command Defend"
    end
    # Branch for Skill Type
    case skill_type
    when 1 # 特技
      return "Command Skill"
    when 2 # 魔法
      return "Command Magic"
    end
  end
 #--------------------------------------------------------------------------
  # ● Entrance Action
  #-------------------------------------------------------------------------- 
  def first_action
    return "Battle Start Ally" if id > 0 # Cada Actor
    return "Wait(Fixed) WT"   if id < 0 # Cada Enemigo
  end
 #--------------------------------------------------------------------------
  # ● Victory Action
  #-------------------------------------------------------------------------- 
  def win
    case id
    when  1,2,3 # Actors No. 2,7 and 10
      return "Victory Backward Somersault"
    else # 上記以外
      return "Victory Pose"
    end
  end
  #--------------------------------------------------------------------------
  # ● Exit Action
  #   Action made if the party is changed
  #-------------------------------------------------------------------------- 
  def remove_action
    return "Ally Exit"
  end
  #--------------------------------------------------------------------------
  # ● Escape Action
  #-------------------------------------------------------------------------- 
  def escape
    return "Escape"   if id > 0 # All actors
    return "Enemy Escape" if id < 0 # All enemies
  end
  #--------------------------------------------------------------------------
  # ● Escape Fail Action
  #-------------------------------------------------------------------------- 
  def escape_ng
    return "Escape Fail"
  end
  #--------------------------------------------------------------------------
  # ● Command Input Start Action
  #-------------------------------------------------------------------------- 
  def command_b
    return "Command"
  end
  #--------------------------------------------------------------------------
  # ● Command Input End Action
  #-------------------------------------------------------------------------- 
  def command_a
    return "Command End"
  end
  #--------------------------------------------------------------------------
  # ● Damage Action
  #-------------------------------------------------------------------------- 
  def damage(attacker)
    # If critical damage
    if critical? 
      return "Big Damage"
    # If healed
    elsif recovery? 
      # Use return only if there isn't any action
      return
    end
    # Branch Skill ID
    case damage_skill_id 
    when 1 # Skill ID 1
      return "Damage"
    when 136 # Use return only if there isn't any action
      return 
    end
    # Branch Item ID (If an action is set on recovery then it is already set
    #                 by the recovery branch)
    case damage_item_id 
    when 1 # Item ID 1
      return
    else
      # If item other than above
      if damage_item_id != 0
        return
      end  
    end
    # Damage is 0 (Buff / Debuff magic, defend, an enemy's escape, etc. )
    if damage_zero?
      return
    end 
    # None of the above
    return "Damage"
  end
  #--------------------------------------------------------------------------
  # ● Evade Action 
  #   Branch the same as the damage action is possible
  #-------------------------------------------------------------------------- 
  def evasion(attacker)
    return "Shield Guard" if shield? # If equipped with a shield
    return "Evade"
  end
  #--------------------------------------------------------------------------
  # ● Miss Action
  #   Branch the same as the damage action is possible
  #-------------------------------------------------------------------------- 
  def miss(attacker)
    return "Shield Guard" if shield? # If equipped with a shield
    return "Evade"
  end
  #--------------------------------------------------------------------------
  # ● Weapon Action
  #   Specify the action used in each weapon.
  #   You can set the weapons of the enemy below.
  # CONFIGURACION DE EFECTOS PARA LAS ARMAS DE PERSONAJES
  #-------------------------------------------------------------------------- 
  def weapon_action 
    # ID del arma
    case weapon_id
    when 0 # No Weapon / Bare Hands
      return "Normal Attack"
    when 1 # Weapon ID 1
      return "Slash Attack"
    end
    # Tipo del arma, todas las armas con cierto tipo cumplen el mismo comportamiento
    case weapon_type 
    when 1 # Armas cortantes
      return "Slash Attack"
    when 4,5,7,9,12,13,14,15,16,20 # Armas cortantes
      return "Slash Attack"
    when 2
      return "Fist Attack"
    when 3
      return "Thrust Attack"
    when 6
      return "Bow Attack" #Arcos y armas de flechas
    when 10,11
      return "Gun" #Pistolas y armas con municion
    when 17 
      return "Cerb"#Cerbatana
    when 18
      return "Arrojadiza"
    when 19
      return "Rckt" # Misiles
    when 8
      return "Hamr" #Martillos
    end
  end
  #--------------------------------------------------------------------------
  # ● Enemy Right Hand Weapon
  #   Specify the Right Hand weapon of the enemy.
  #--------------------------------------------------------------------------
  # ARMAS ENEMIGAS
  #--------------------------------------------------------------------------
  def enemy_weapon1_id 
    case id
    when -1 # Coboot Prueba
      return 64 
    when -2 #Tzimitl
        return 1 #Lanza Tzimitil
    when -3 #Inspil Bloque
        return 67 #Mordizco
    when -4 #Inspil Bloque
        return 67 #Mordizco    
    when -5 #Guerrera Araña
      return 14 #Cerbatana simple
    when -6 #Cynspil
      return 67 #Mordizco
    when -7 #StonebotT1
      return 62 #Taladro Robot
    when -8 #Bizzer
      return 12 #Rasguño
    when -9 #Sirakuri
      return 9 #Dardo Venenoso
    when -10 #Sirakiru
        return 9 #Dardo venenoso
    when -11 # Stonebot R1
      return 63 #llave
    when -12 # Stonebot Mono1
        return 68 #llave
    when -13 # Lancero Tatama
      return 12
    when -14 #Rhysorog
      return 65 #Gran Martillo
    else
      return 10
    end
  end
  #--------------------------------------------------------------------------
  # ● Enemy Left Hand Weapon
  #   Specify the Left Hand weapon of the enemy.
  #--------------------------------------------------------------------------
  def enemy_weapon2_id
    case id
    when -1 # Coboot Prueba
      return 64
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # ● Enemy Shield
  #   Specify the shield of the enemy. Overrides the Left Hand weapon.
  #--------------------------------------------------------------------------
  def enemy_shield_id
    return 0
  end
  #--------------------------------------------------------------------------
  # ● Weapon Graphics
  #--------------------------------------------------------------------------
  # In the settings of the weapon action [1: Single Image] [2: 2k3 Style]
  # return "001-Weapon01" ← Filename of the weapon.
  #                         Should be in the "Characters" folder.
  # Use an empty filename to hide the weapon instead.
  def weapon_graphic(weapon_id, weapon_type)
    # 武器IDで指定
    case weapon_id
    when 1 # Weapon ID 1
      return ""
    end
    # Weapon Type
    case weapon_type 
    when 6,17 # Weapon Type 6
      return "bow01"
    when 10,11
      return "gun01"
    end
  end
  #--------------------------------------------------------------------------
  # ● Shield Graphics
  #--------------------------------------------------------------------------
  # In the settings of the weapon action [1: Single Image] [2: 2k3 Style]
  # The weapon action shield display option must be set to true to display.
  # 
  # return "001-Shield01" ← Filename of the shield.
  #                         Should be in the "Characters" folder.
  def shield_graphic(weapon_id, shield_type)
    # 防具IDで指定
    case shield_id
    when 41 # 防具41番(バックラー)の画像ファイル名
      return ""
    end
    # 防具タイプで指定
    case shield_type 
    when 5 # 防具タイプ5番(小型盾)の画像ファイル名
      return ""
    end
  end 
  
   #--------------------------------------------------------------------------
  # ● Skill Action
  #-------------------------------------------------------------------------- 
  def skill_action
    # スキルIDで指定
    case skill_id 
    when 1 # Skill ID 1 (Normal Attack - Use Weapon Action)
      return weapon_action
    when 2 # Skill ID 2 (Defend)
      return "Defend"
    when 3,4,5 # Skill ID 3/4/5 (Multi-Attack)
      return weapon_action
    when 6 # Skill ID 6 (Enemy Escape)
      return escape
    when 7 # Skill ID 7 (Wait)
      return "Standby"
    when 9 # Llama Soplete
      return "SopleteLlama"
    when 10 # Danza Llamas
      return "DanzaFlama"
    when 11 # Dardos Pluma
      return "Dardo Pluma" 
    when 12 # Salto Elevado
      return "Salto invertido"
    when 18 # Nado Rapido
      return "NadoRapido"
    when 19 # Patada Hidraulica
      return "Patada Hidraulica"
    when 20 # Acuasfera
      return "Acuasphere"
    when 21 # Disparo Oculto
      return "Multi Attack"
    when 23 # Flujo Subterraneo
      return "Flujo Subterraneo"
    when 27 # Cabezazo Casco
      return "Salto"
    when 29 # Barrido nevado
      return "Derrape"
    when 30 # Ventisca Oscilante
      return "Ventisca"
    when 31 # Ventisca Oscilante
      return "Impulso"
    when 93 # Rastreo Ancestral
      return "GolpeFlama"
    when 139 # Corte Lateral (Flamrose)
      return "Skill Attack" 
    when 140 # Golpe Resorte (Hutch)
      return "Skill Attack" 
    when 141 # Lanza Ski (Pengralle)
      return "Skill Attack" 
    when 172 # Doble Cuchillada
      return "Directo"
    when 173 # Mordida Insecta
      return "Directo"
    when 176 # Dardo Venenoso       
      return "BalaEsp"
    when 178 #Derribo Insecto
      return "Derribo"
    when 180 #Protocolo Reparador
      return "Directo"
    when 182 #Protocolo Explosivo
      return "Derribo"
    when 128 #System 
      return "Water Gun"
    when 129 #System 
      return "Throw Weapon"
    when 130 #System 
      return "Attack 5 Times"
    when 131
      return "Cut-in Attack"
    when 132 #System 
      return "Movie Attack"
    when 133 #System 
      return "Wolf Transformation"
    when 134 #System 
      return "Derived Skill"
    when 135 #System 
      return "Dim Attack"
    when 136 #System 
      return "Air Attack"
    when 194 #Impacto Paleoceno
      return "Placaje"
    when 195 #Taladro Radiactivo
      return "Directo"
    when 196 #Pisoton Paleoceno
      return "Salto Pesado"
    
    end
    # Skill Name (Recommended to use Skill ID instead)
    case skill_name 
    when "Starstorm"
      return "Background Change Attack"
    when "Sacred Tome"
      return "Picture Attack"
    end
    # Skill Type
    case skill_type 
    when 1 # Special
      return "Generic Skill"
    when 2 # Magic
      return "Generic Magic"
    end
    # None of the above
    return "Generic Skill"
  end
  #--------------------------------------------------------------------------
  # ● Item Action
  #-------------------------------------------------------------------------- 
  def item_action
    case item_id # アイテムIDで指定
    when 1 
      return "Use Item"
    else
      return "Use Item"
    end
  end
#--------------------------------------------------------------------------
  # ● Counter Skill ID
  #   Skill ID used for a counterattack.
  #-------------------------------------------------------------------------- 
  # ► Two or more times attack set up in the database is not reflected. 
  def counter_skill_id
    return 1
  end
 #--------------------------------------------------------------------------
  # ● Reflect Animation ID
  #   Animation ID used for a magic reflection.
  #-------------------------------------------------------------------------- 
  def reflection_anime_id
    return 118
  end
  #--------------------------------------------------------------------------
  # ● Substitute/Protect Start Action
  #-------------------------------------------------------------------------- 
  def substitute_start_action
    return "Substitute Start"
  end
  #--------------------------------------------------------------------------
  # ● 身代わり終了アクション
  #-------------------------------------------------------------------------- 
  def substitute_end_action
    return "Substitute End"
  end
 #--------------------------------------------------------------------------
  # ● Substitute/Protect Receiver Start
  #-------------------------------------------------------------------------- 
def substitute_receiver_start_action
    return "Substitute Start - Receiver"
  end
  #--------------------------------------------------------------------------
  # ● 身代わりされた側のアクション終了
  #-------------------------------------------------------------------------- 
  def substitute_receiver_end_action
    return "Substitute End - Receiver"
  end
  #--------------------------------------------------------------------------
  # ● Enemy Level
  #   It is intended for the use of conditional branch, etc...
  #   Parameters are not reflected.
  #--------------------------------------------------------------------------  
  def level
    case id
    when -1 # 1番のエネミー
      return 0
    end
    return 0
  end
  
end
