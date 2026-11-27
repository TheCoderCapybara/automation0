// Quantos recursos existem agora (todos os tipos juntos)
var resource_count = instance_number(obj_parent_breakable);

if (resource_count < resource_max) {
    // Conta o tempo desde o último recurso gerado
    spawn_timer += 1;

    // O intervalo é recalculado todo frame, então acompanha o número de recursos
    var needed_frames = get_spawn_interval(resource_count) * frames_per_second;

    // Quando o tempo passa do necessário, sorteia o tipo e tenta gerar
    if (spawn_timer >= needed_frames) {
        if (spawn_resource(pick_resource_object())) {
            spawn_timer = 0;
        } else {
            // Sem tile livre: tenta de novo em instantes
            spawn_timer = needed_frames - retry_delay * frames_per_second;
        }
    }
} else {
    // Ilha cheia: o contador recomeça quando faltar um recurso
    spawn_timer = 0;
}
