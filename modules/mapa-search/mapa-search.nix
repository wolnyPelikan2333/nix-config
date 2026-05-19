{ pkgs }:

pkgs.writeShellApplication {
  name = "mapa-search";

  # Programy, które muszą być dostępne podczas działania naszego skryptu
  runtimeInputs = with pkgs; [
    findutils # Dostarcza komendę 'find'
    fzf       # Nasz interaktywny filtr
    emacs     # Dostarcza komendę 'emacsclient'
    coreutils # Podstawowe narzędzia systemowe (echo, mkdir itp.)
  ];

  # Treść naszego skryptu w czystym Bashu
 text = ''
    MAPA_DIR="/home/michal/mapa"

    if [ ! -d "$MAPA_DIR" ]; then
      echo "❌ Błąd: Katalog $MAPA_DIR nie istnieje!"
      exit 1
    fi

    # Menu wyboru akcji za pomocą fzf
    AKCJA=$(echo -e "🔍 [w] Wyszukaj notatkę\n📝 [n] Utwórz nową notatkę" | fzf --prompt="Co chcesz zrobić? > " | awk '{print $2}')

    # Jeśli użytkownik wyszedł przez ESC
    if [ -z "$AKCJA" ]; then
      echo "Anulowano."
      exit 0
    fi

    # ==========================================
    # OPCJA: WYSZUKAJ NOTATKĘ
    # ==========================================
    if [ "$AKCJA" = "[w]" ]; then
      FILE=$(find "$MAPA_DIR" -type f \( -name "*.org" -o -name "*.md" \) | sed "s|$MAPA_DIR/||" | fzf --prompt="🗺️ Mapa > ")
      
      if [ -z "$FILE" ]; then
        echo "Anulowano."
        exit 0
      fi

      FULL_PATH="$MAPA_DIR/$FILE"
      echo "🚀 Otwieranie $FILE w Emacsie..."
      emacsclient -n -c "$FULL_PATH" 2>/dev/null || emacs "$FULL_PATH"

    # ==========================================
    # OPCJA: UTWÓRZ NOWĄ NOTATKĘ
    # ==========================================
    elif [ "$AKCJA" = "[n]" ]; then
      echo -n "📝 Podaj nazwę nowej notatki (np. bazy-danych): "
      read -r NOWA_NAZWA

      if [ -z "$NOWA_NAZWA" ]; then
        echo "❌ Anulowano: Nazwa pliku nie może być pusta."
        exit 1
      fi

      # Automatycznie dodajemy rozszerzenie .org, jeśli użytkownik go nie wpisał
      if [[ ! "$NOWA_NAZWA" =~ \.(org|md)$ ]]; then
        NOWA_NAZWA="$NOWA_NAZWA.org"
      fi

      FULL_PATH="$MAPA_DIR/$NOWA_NAZWA"

     # Jeśli plik jeszcze nie istnieje, tworzymy go i dodajemy podstawowy szablon Org-mode
      if [ ! -f "$FULL_PATH" ]; then
        CURR_DATE=$(date "+%Y-%m-%d %H:%M")
        
        # Porządne, pojedyncze przekierowanie całego bloku tekstowego
        {
          echo "#+TITLE: ''${NOWA_NAZWA%.*}"
          echo "#+DATE: <$CURR_DATE>"
          echo ""
          echo "* "
          echo "✨ Utworzono nową notatkę."
        } > "$FULL_PATH"
      fi

      echo "🚀 Otwieranie nowej notatki w Emacsie..."
      emacsclient -n -c "$FULL_PATH" 2>/dev/null || emacs "$FULL_PATH"
    fi
  '';
}
