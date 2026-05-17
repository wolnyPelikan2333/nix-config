{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    initContent = lib.mkAfter ''
      # sen — sudo nvim helper
      sen() {
        if [ "$#" -eq 0 ]; then
          sudo -E nvim .
        else
          sudo -E nvim "$@"
        fi
      }

      mklesson-bulk() {
        [[ -f TEMPLATE.md ]] || { echo "Brak TEMPLATE.md"; return 1; }

        for d in */; do
          [[ ! -s "$d/README.md" ]] && cp TEMPLATE.md "$d/README.md"
        done
      }
      
      # --- auto tmux main session ---
      if command -v tmux >/dev/null \
        && [ -z "$TMUX" ] \
        && [ -n "$PS1" ]; then
        tmux new -A -s main
      fi

      # --- asystent bazy notatek mapa ---
      pytaj-mape() {
        if [ -z "$1" ]; then
            echo "Musisz zadać jakieś pytanie, np: pytaj-mape \"Co mam w notatkach?\""
            return 1
        fi

        # Filtrujemy pliki tymczasowe Emacsa bezpośrednio w locie
        local kontekst=$(${pkgs.findutils}/bin/find ~/mapa -type f ! -name ".*" ! -name "*~" -name "*.org" -exec cat {} +)

        echo "Analizuję całą Mapę (RTX 3050)..."

     # Wstrzykujemy sterowniki GPU i przekazujemy dane jako czysty kontekst
        cat << END_OLLAMA | LD_LIBRARY_PATH=/run/opengl-driver/lib:$LD_LIBRARY_PATH ${pkgs.ollama}/bin/ollama run llama3 --system "Jesteś polskim asystentem bazy notatek. Twoim jedynym zadaniem jest przeczytanie dostarczonego kontekstu i wyciągnięcie z niego odpowiedzi na pytanie użytkownika. Odpowiadasz wyłącznie po polsku, krótko i na temat. Jeśli w tekście nie ma informacji o chlebie lub medytacji, napisz po polsku: Nie znalazłem tego w Mapie."
DANE Z BAZY NOTATEK:
$kontekst

PYTANIE UŻYTKOWNIKA:
$*
END_OLLAMA
      }

    '';
  };
}
