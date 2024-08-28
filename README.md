# Hardware Keyboard Reader
In progress creation of a library of code that is able to read the Amiga 500 keyboard at the hardware level.

###Features
 - Interrupt driven reading of keyboard keycodes.
 - Interrupt driven handling of keyboard ack signal using CIA timers.
 - Keycodes queued into a buffer for later use.
 - Implementation of a method/function to dequeue the keycode.
 - Encapsulation of the code into an include file of linkable library.

##Progress
 - The /src folder contains a VSCode assembly project that uses the code to read the keyboard and output to the screen.

###ToDo
- Encapsulate the code, refactor and separate the keyboard reader library code.
- Make the code configurable to allow the selection of which CIA and Timer to use for the keyboard ack signal.

  
