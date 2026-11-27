// Fim do jogo (janela fechada): salva se o jogo estava rodando.
// Pausado já foi salvo ao pausar; em fim de jogo o save já foi apagado.
if (state == "playing") {
    save_game();
}
