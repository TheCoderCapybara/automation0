// Movimento
spd = 5;       // Velocidade máxima (pixels por frame)
acc = 0.5;     // Aceleração ao segurar uma direção (pixels por frame²)
dec_h = 1;     // Desaceleração horizontal ao soltar as teclas (2 * acc)
dec_v = 0.5;   // Desaceleração vertical ao soltar as teclas (1 * acc)
hspd = 0;      // Velocidade horizontal atual
vspd = 0;      // Velocidade vertical atual

// Dash (o alarm[0] controla a recarga)
dash_speed = 12.5;    // Velocidade do dash (pixels por frame)
dash_duration = 18;   // Duração do dash em frames
dash_cooldown = 50;   // Recarga entre dashes em frames, contada desde o início do dash
dash_timer = 0;       // Frames restantes do dash atual
dash_dir = 0;         // Direção do dash em graus
dashing = false;      // true enquanto estiver em dash

// Combate (usado por obj_mouse)
dmg = 20;              // Dano por golpe
range = 224;           // Alcance do golpe em pixels
attack_cooldown = 40;  // Frames entre golpes
