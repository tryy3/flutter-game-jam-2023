# Game Loop
## Loop
Start Game -> ( Drawing cards -> ( Player 1 draw -> Player 2 draw)* repeat -> End drawing) * Repeat -> Start over

## State
Drawing Cards - Behöver bara en status att båda spelarna får dra kort

Playing cards - Behöver veta senast spelade. Detta för att kunna ha en delay mellan varje spelande.

## Events
* GameStart - Vid start av spelet
* GameOver - När någon förlorar
* RoundStart - När en runda startas
* TurnStart  - Vid varje turn 