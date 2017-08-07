local = 891 #las variables locales se mantienen en minuscula
@instancia = 12
$global = 100 
CONSTANTE = 1 #Las constantes siempre se llaman con mayúscula primero
#msgbox_p (local) - Como cout en RMVXA

#def es declaracion de métodos, los parametros se pueden generar con valores por defecto
#no hay necesidad de definir tipos de datos de retorno por ser debilmente tipado
def example_method  (valor = "b", palabra = "0", elem = "a") #elem se define por defecto en "a"
    mivar = "hola mundo" + valor + elem + palabra
    #Los arreglos son dinámicos y no tipados
    arreglo = [valor, elem, palabra]
    #Si voy a la siguiente posición del arreglo, puedo meter un elemento siguiente
    arreglo [arreglo.size] = "pusheado"   
    msgbox_p(arreglo)  
end

#Reproducir sonidos
def repsonidos (boolean)
  if(boolean)
    Audio.se_play("Audio/SE/blast13",100,100)
    Audio.bgm_play("Audio/BGM/00-black-hole",100,100)
    Audio.bgs_play("Audio/BGS/Darkness",100,100)
    Audio.me_play("Audio/ME/001-Victory01",100,100)
  #o tambien
  else
    #Se pueden asignar variables a las fuentes de sonido
    bgm = RPG::BGM.new("00-black-hole-tag-power",100,10)
    #Y luego reproducirlas
    bgm.play 
    RPG::BGS.new("Darkness").play
    RPG::ME.new("001-Victory01").play
    RPG::SE.new("blast13").play 
  end
end

#Llamar un metodo
#repsonidos (false)
#example_method("o")


#Clases, deben ser declaradas como Constantes
class Miclase 

  def initialize(numero = 10)#Constructor
    @instancia = numero #variables estáticas en términos de clase
    #msgbox_p("Inicial")  
  end
  def dispose ()#Destructor
  
  end
  def print()
    msgbox_p(@instancia)
  end
  def print_padre()
    msgbox_p("Padre")
  end
end

class Miclase_heredada < Miclase
  def initialize ()
    super #Llamo al metodo que heredo con este nombre
  end
  
  def print()
    super
    #msgbox_p("LOL")
  end
  
  def ciclos ()
    arreglo = [1,2,3,4,5,6]
    #-----------------------------------
    for element in arreglo
      p(element)#imprimir en pantalla
    end
    arreglo.each { |element| 
      p(element)
    }
    #-----------------------------------
    aa = 0
    #-----------------------------------
    6.times { 
      p(arreglo[aa])
      aa +=1
    }
  end
  
end

#miclase = Miclase_heredada.new
#miclase.ciclos()
#miclase.print()
#miclase = Miclase.new
#miclase2 = Miclase.new(2)
#miclase.print()
#miclase2.print()



