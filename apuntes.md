# Apuntes de Scripts modificados y añadidos

----------
## SideView- Action Setup

### Call Common Event
Los flujos que llaman los eventos comunes   "Timer Hit Starter","Timer Hit Stopper", "Timer Hit Flow"   y   "Timer Block Flow"  se utilizan en los flujos de ataques normales tanto para personajes como para enemigos. 

### Conditional Branch (Switch)
Las definiciones en este punto definen predicados que evaluan el valor de un Switch (booleano). Si la condicion se cumple, entonces el Branch se ejecuta segun definido (0: se ejecuta la accion siguiente, 1: la accion se cancela, 2: todo el flujo se cancela).

### Special Modifiers (DO NOT CHANGE)
Definiciones por defecto del script, las mas importantes para este caso con Solo Start y Solo End, las cuales inician y finalizan la ejecucion de ataques, incluyendo calculo de daños y demás.

### Timed Hits y Ranged Timed Hit

Aqui se definen las secuencias de ataque normal y secundario de todos los personajes, Jugables y Enemigos por Igual. 
Se usa If Time Hit para evaluar si no se sobrepaso el timeout del golpe activo, para generar una nueva accion. "Attack".

- Modificar doble ataque por aumento de daño
-> Se evita usar "Attack" y en su lugar se llama un evento comun que incrementa el daño entre Solo Start y Solo End


### Advanced Enemy Targeting System 
Este script se hizo con el proposito de sobreescribir el comportamiento usual de los enemigos, dado que deciden sus accciones de manera aleatoria. A través de este script se permite definir un perfil de comportamiento para los enemigos, permitiendo una experiencia más compleja y estratégica dentro del juego. 

### Order Gauge - PCTB

Este script, originalmente de Yami, define una sistema que encola las acciones de los combatientes para configurar el orden en el que estos actuan, en lugar de escoger las acciones y esperar a que vayan ocurriendo sino que los turnos se van ejecutando a medida que cada turno avanza. La estructura actual permite mostrar una cola de actores y enemigos, permitiendole al jugador ver quiénes son los proximos en moverse. Sin embargo, la carga de los personajes solo ocurre al inicio del combate, por lo que para que en caso que ingrese un nuevo combatiente en medio de la pelea, se requiere hacer este llamado de script:
`SceneManager.scene.refresh_order_gauge`


