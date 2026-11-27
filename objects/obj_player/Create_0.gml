// Movimento
spd = 5;       // Velocidade máxima (pixels por frame)
acc = 0.5;     // Aceleração ao segurar uma direção (pixels por frame²)
dec_h = 1;     // Desaceleração horizontal ao soltar as teclas (2 * acc)
dec_v = 0.5;   // Desaceleração vertical ao soltar as teclas (1 * acc)
hspd = 0;      // Velocidade horizontal atual
vspd = 0;      // Velocidade vertical atual

// Combate (usado por obj_mouse)
dmg = 20;              // Dano por golpe
range = 224;           // Alcance do golpe em pixels
attack_cooldown = 40;  // Frames entre golpes
