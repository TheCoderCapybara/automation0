// Gerador de recursos: faz nascer árvores, pedras e o que mais existir,
// sempre em tiles de grama livres (nunca sobre o mar).
// O ritmo depende de quantos recursos já existem (todos os tipos juntos) e
// o tipo de cada novo recurso é sorteado por porcentagem, conforme a qualidade.

// Configurações gerais
frames_per_second = game_get_speed(gamespeed_fps); // Frames por segundo do jogo
tile_size = 64;       // Tamanho de cada tile da ilha (pixels)
spawn_attempts = 20;  // Tiles sorteados em cada tentativa antes de desistir
retry_delay = 1;      // Segundos para tentar de novo quando não há tile livre

// Quantidade e ritmo (somando todos os tipos de recurso)
resource_max = 8;     // Máximo de recursos na ilha ao mesmo tempo
min_interval = 10;    // Segundos até o próximo recurso com a ilha vazia
max_interval = 80;    // Segundos até o próximo recurso com a ilha cheia (a curva é linear)
spawn_timer = 0;      // Frames desde o último recurso gerado

// Tipos de recurso
// Quanto maior a qualidade, melhor é o recurso e menor a chance de ele nascer
resource_types = [
    { resource_object: obj_tree, quality: 1 },
    { resource_object: obj_rock, quality: 2 }
];

// Calcula a chance (%) de cada tipo, proporcional a 1 / qualidade
var total_weight = 0;
for (var i = 0; i < array_length(resource_types); i++) {
    total_weight += 1 / resource_types[i].quality;
}
for (var i = 0; i < array_length(resource_types); i++) {
    resource_types[i].chance = (1 / resource_types[i].quality) / total_weight * 100;
}

/// Segundos até o próximo recurso, de acordo com quantos já existem
/// Quanto mais cheia a ilha, mais devagar nasce o próximo
get_spawn_interval = function(_resource_count) {
    // Proporção da ilha já ocupada (0 = vazia, 1 = cheia)
    var fill = _resource_count / resource_max;

    // Vai do menor ao maior intervalo conforme a ilha enche
    return lerp(min_interval, max_interval, fill);
};

/// Sorteia o tipo do próximo recurso de acordo com a chance (%) de cada um
pick_resource_object = function() {
    var roll = random(100);
    var accumulated = 0;

    // Soma as chances até passar do número sorteado
    for (var i = 0; i < array_length(resource_types); i++) {
        accumulated += resource_types[i].chance;
        if (roll < accumulated) {
            return resource_types[i].resource_object;
        }
    }

    // Segurança contra arredondamento: devolve o último tipo
    return resource_types[array_length(resource_types) - 1].resource_object;
};

/// Verifica se o tile centrado em (_x, _y) ainda não tem recurso nem caixa de venda
is_tile_free = function(_x, _y) {
    // Verifica se já existe um recurso neste tile
    for (var i = 0; i < instance_number(obj_parent_breakable); i++) {
        var resource = instance_find(obj_parent_breakable, i);
        if (point_distance(_x, _y, resource.x, resource.y) < tile_size / 2) {
            return false;
        }
    }

    // Verifica se a caixa de venda está neste tile
    for (var i = 0; i < instance_number(obj_sell_box); i++) {
        var box = instance_find(obj_sell_box, i);
        if (point_distance(_x, _y, box.x, box.y) < tile_size / 2) {
            return false;
        }
    }

    return true;
};

/// Verifica se a área desenhada da instância está completamente sobre grama
is_on_grass = function(_instance) {
    // Calcula a área do sprite com a escala aplicada
    var left = _instance.x - _instance.sprite_xoffset * _instance.image_xscale;
    var top = _instance.y - _instance.sprite_yoffset * _instance.image_yscale;
    var right = left + _instance.sprite_width - 1;
    var bottom = top + _instance.sprite_height - 1;

    // Testa pontos a cada 16 pixels, incluindo as bordas
    var step = 16;
    for (var check_x = left; check_x < right + step; check_x += step) {
        for (var check_y = top; check_y < bottom + step; check_y += step) {
            // O último ponto de cada linha e coluna é limitado à borda
            var point_x = min(check_x, right);
            var point_y = min(check_y, bottom);

            // Basta um ponto fora da grama para recusar
            if (!position_meeting(point_x, point_y, obj_chao_grama)) {
                return false;
            }
        }
    }

    return true;
};

/// Cria um recurso (_object) em um tile de grama livre. Retorna true se conseguiu
spawn_resource = function(_object) {
    var grass_count = instance_number(obj_chao_grama);
    if (grass_count == 0) {
        return false;
    }

    for (var i = 0; i < spawn_attempts; i++) {
        // Sorteia um tile de grama e calcula o centro dele
        var grass = instance_find(obj_chao_grama, irandom(grass_count - 1));
        var tile_x = grass.x - grass.sprite_xoffset + grass.sprite_width / 2;
        var tile_y = grass.y - grass.sprite_yoffset + grass.sprite_height / 2;

        // Ignora o tile se já estiver ocupado
        if (!is_tile_free(tile_x, tile_y)) {
            continue;
        }

        // Cria o recurso e confere se ele cabe inteiro sobre a grama
        var resource = instance_create_layer(tile_x, tile_y, "Instances", _object);
        if (is_on_grass(resource)) {
            return true;
        }

        // Não coube: remove sem executar o evento Destroy (para não soltar itens)
        instance_destroy(resource, false);
    }

    return false;
};
