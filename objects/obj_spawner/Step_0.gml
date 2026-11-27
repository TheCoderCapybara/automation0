// Árvores: o contador só anda enquanto faltar alguma
if (instance_number(obj_tree) < tree_max) {
    tree_timer -= 1;

    // Quando o contador termina, tenta fazer nascer uma árvore
    if (tree_timer <= 0) {
        if (spawn_resource(obj_tree)) {
            tree_timer = tree_interval * frames_per_second;
        } else {
            // Sem tile livre: tenta de novo em instantes
            tree_timer = retry_delay * frames_per_second;
        }
    }
} else {
    // Ilha completa: o contador recomeça quando faltar uma
    tree_timer = tree_interval * frames_per_second;
}

// Pedras: o contador só anda enquanto faltar alguma
if (instance_number(obj_rock) < rock_max) {
    rock_timer -= 1;

    // Quando o contador termina, tenta fazer nascer uma pedra
    if (rock_timer <= 0) {
        if (spawn_resource(obj_rock)) {
            rock_timer = rock_interval * frames_per_second;
        } else {
            // Sem tile livre: tenta de novo em instantes
            rock_timer = retry_delay * frames_per_second;
        }
    }
} else {
    // Ilha completa: o contador recomeça quando faltar uma
    rock_timer = rock_interval * frames_per_second;
}
