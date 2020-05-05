# Apuntes de Scripts para mecanicas de combate activo

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


### Prueba 1: Simular fire orb

1. Iniciar el Timeout de ataque

2. Iniciar un Ciclo, cada que se oprima el boton de acción, realizar la accion especial. Establecer el limite por medio de una variable (que podria irse mejorando con el tiempo)

2. 
