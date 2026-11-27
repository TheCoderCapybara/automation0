/// @desc Lê um arquivo JSON da pasta de dados do jogo.
/// @param {String} _path Nome do arquivo (ex.: "save.json")
/// @returns {Struct} O conteúdo do arquivo, ou undefined se ele não existe ou está inválido
function json_file_read(_path) {
    // Sem arquivo, não há o que ler
    if (!file_exists(_path)) {
        return undefined;
    }

    // Lê o texto do arquivo
    var text = "";
    try {
        var buff = buffer_load(_path);
        text = buffer_read(buff, buffer_string);
        buffer_delete(buff);
    } catch (_error) {
        return undefined;
    }

    // Converte o texto em struct (um arquivo quebrado não pode derrubar o jogo)
    var data = undefined;
    try {
        data = json_parse(text);
    } catch (_error) {
        return undefined;
    }

    // Só aceita um objeto JSON
    if (!is_struct(data)) {
        return undefined;
    }

    return data;
}

/// @desc Grava uma struct como arquivo JSON na pasta de dados do jogo.
/// @param {String} _path Nome do arquivo (ex.: "save.json")
/// @param {Struct} _data O que será gravado
/// @returns {Bool} true se gravou; false se deu erro
function json_file_write(_path, _data) {
    try {
        // Converte a struct em texto e grava num buffer do tamanho exato (texto + 1 byte final)
        var text = json_stringify(_data);
        var buff = buffer_create(string_byte_length(text) + 1, buffer_fixed, 1);
        buffer_write(buff, buffer_string, text);
        buffer_save(buff, _path);
        buffer_delete(buff);
        return true;
    } catch (_error) {
        return false;
    }
}
