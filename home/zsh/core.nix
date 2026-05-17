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

     --- asystent bazy notatek mapa ---
        pytaj-mape() {
          if [ -z "$1" ]; then
              echo "Musisz zadać jakieś pytanie, np: pytaj-mape \"Co mam w notatkach?\""
              return 1
          fi

          # Szukamy w plikach .org tylko linii pasujących do słów kluczowych z zapytania
          # To zapobiegnie zalaniu modelu gigantyczną ilością kodu i konfiguracji
          local slowo_klucz=$(echo "$1" | awk '{print $1}')
          local kontekst=$(${pkgs.findutils}/bin/find ~/mapa -type f ! -name ".*" ! -name "*~" -name "*.org" -exec grep -i "$slowo_klucz" {} + 2>/dev/null | head -n 50)

          echo "Analizuję dopasowania w Mapie (RTX 3050)..."

          # Przekazujemy czysty strumień ze ścisłym, uproszczonym żądaniem
          cat << END_OLLAMA | LD_LIBRARY_PATH=/run/opengl-driver/lib:$LD_LIBRARY_PATH ${pkgs.ollama}/bin/ollama run llama3
Użytkownik pyta o: "$*"
Odpowiedz na to pytanie wyłącznie na podstawie poniższych wycinków z jego notatek.
ODPOWIEDZ WYŁĄCZNIE PO POLSKU. KROTKÓ I NA TEMAT.

WYCINKI Z NOTATEK:
$kontekst
END_OLLAMA
      }

    '';
  };
}
