;;; init.el --- Kompletny i poukładany system Michała (MAPA)

;; ==========================================
;; 0. UCIESZANIE OSTRZEŻEŃ (Native Comp & PGTK)
;; ==========================================
(setq warning-minimum-level :error)
(setq native-comp-async-report-warnings-errors-silent t)
(setq display-warning-level :error)

;; Ścieżki systemowe NixOS (stałe, nie zmienią się przy aktualizacji)
(add-to-list 'load-path "/run/current-system/sw/share/emacs/site-lisp")
(add-to-list 'load-path "/run/current-system/sw/share/emacs/site-lisp/mu4e")

;; ==========================================
;; 1. PODSTAWY I PAKIETY
;; ==========================================
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Wygląd
(setq inhibit-startup-message t)
(menu-bar-mode 1) (tool-bar-mode 1) (scroll-bar-mode -1)
(global-display-line-numbers-mode 1)
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-one t)
  (doom-themes-org-config))

;; Naprawa Dired/Dirvish dla NixOS
(setq ls-lisp-use-insert-directory-program nil)
(require 'ls-lisp)

(use-package dirvish
  :ensure t
  :init
  (dirvish-override-dired-mode)
  :config
  (setq dirvish-attributes '(icons file-size))
  (define-key dirvish-mode-map (kbd "+") 'dired-create-directory)
  (define-key dirvish-mode-map (kbd "q") 'dirvish-quit))

(use-package pdf-tools
  :ensure t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-loader-install) ; Ładuje pdf-tools przy otwarciu pliku PDF
  (setq-default pdf-view-display-size 'fit-width) ; Dopasuj do szerokości
  (add-hook 'pdf-view-mode-hook (lambda () (cursor-advancing-mode -1))))

(use-package nov
  :ensure t
  :mode ("\\.epub\\'" . nov-mode)
  :config
  (setq nov-text-width 80) ; Ustawia szerokość tekstu dla wygodnego czytania
  (defun my-nov-font-setup ()
    (face-remap-add-relative 'variable-pitch :family "Liberation Serif" :height 1.5))
  (add-hook 'nov-mode-hook 'my-nov-font-setup))

;; ==========================================
;; 2. SILNIK MAPY (LOGIKA MODLITEWNA)
;; ==========================================

(defun my--eu-date () (format-time-string "%d-%m-%Y"))

(defun my/load-template (template-name)
  "Wczytuje treść szablonu z folderu templates."
  (let ((template-path (expand-file-name (concat template-name ".org") "~/mapa/Modlitwy/templates/")))
    (if (file-exists-p template-path)
        (progn
          (goto-char (point-max))
          (unless (bolp) (insert "\n"))
          (insert-file-contents template-path))
      (insert (format "\n* BŁĄD: Brak pliku templates/%s.org\n" template-name)))))

(defun my/create-prayer-file (sub-dir title template &optional use-iso-date)
  "Uniwersalna funkcja tworząca plik modlitwy."
  (let* ((date-str (if use-iso-date (format-time-string "%Y-%m-%d") (my--eu-date)))
         (dir (concat "~/mapa/Modlitwy/" sub-dir "/"))
         (file (expand-file-name (concat date-str (if use-iso-date "-codziennik" "") ".org") dir)))
    (unless (file-exists-p dir) (make-directory dir t))
    (find-file file)
    (when (= (buffer-size) 0)
      (insert "#+title: " title "\n#+date: " date-str "\n\n")
      (my/load-template template))
    (goto-char (point-max))))

(defun my/get-next-siglum ()
  "Pobiera siglum z pliku .org, szukając pierwszego TODO."
  (let* ((file (expand-file-name "~/mapa/Modlitwy/medytacja/bank_slow.org"))
         (siglum "Dowolny fragment"))
    (if (not (file-exists-p file))
        (progn
          (message "BŁĄD MAPY: Plik %s nie istnieje!" file)
          siglum)
      (with-current-buffer (find-file-noselect file)
        (delay-mode-hooks (org-mode)) ;; Wymuś tryb Org bez zbędnych dodatków
        (save-excursion
          (goto-char (point-min))
          ;; Szukamy nagłówka TODO
          (if (re-search-forward "^\\*\\* TODO \\(.*\\)$" nil t)
              (progn
                (setq siglum (match-string 1))
                (replace-match "** DONE \\1")
                ;; Dodaj właściwości pod nagłówkiem
                (forward-line 1)
                (insert (format "   :PROPERTIES:\n   :LAST_MEDITATION: [%s]\n   :END:\n" 
                                (format-time-string "%Y-%m-%d %a")))
                (save-buffer)
                (message "System Mapa: Pobrano siglum: %s" siglum))
            (message "System Mapa: Nie znaleziono więcej TODO.")))
        siglum))))

(defun my/wstaw-do-rachunku (siglum)
  "Wstrzykuje siglum do dzisiejszego rachunku, tworząc sekcję jeśli jej nie ma."
  (let ((file (expand-file-name (concat (my--eu-date) ".org") "~/mapa/Modlitwy/rachunek/")))
    ;; find-file-noselect otwiera plik w tle bez przerywania medytacji
    (with-current-buffer (find-file-noselect file)
      (goto-char (point-min))
      ;; Szukamy miejsca na wpis (bardziej elastyczne szukanie)
      (if (re-search-forward "DZIEŃ W EWANGELII" nil t)
          (progn 
            (forward-line 1)
            (insert "Siglum: " siglum "\n"))
        ;; Jeśli nie ma sekcji, dodajemy ją na końcu
        (goto-char (point-max))
        (insert "\n* DZIEŃ W EWANGELII\nSiglum: " siglum "\n"))
      (save-buffer))))

;; --- GŁÓWNE KOMENDY INTERAKTYWNE ---

(defun my/medytacja-z-mapy ()
  "Tworzy medytację i przygotowuje wieczorny rachunek."
  (interactive)
  (let ((file (expand-file-name (concat (my--eu-date) ".org") "~/mapa/Modlitwy/medytacja/")))
    (if (file-exists-p file)
        (find-file file) ;; Jeśli plik już jest, po prostu go otwórz
      (let ((siglum (my/get-next-siglum)))
        (my/create-prayer-file "medytacja" "Medytacja" "medytacja")
        (goto-char (point-min))
        (if (re-search-forward "^#\\+date:.*$" nil t)
            (progn (forward-line 2) (insert "Siglum: " siglum "\n"))
          (goto-char (point-min))
          (insert "Siglum: " siglum "\n\n"))
        (my/wstaw-do-rachunku siglum)
        (message "System Mapa: Medytacja gotowa z siglum: %s" siglum)))))

(defun my/codziennik-krawczyka ()
  (interactive)
  (let ((siglum (my/get-next-siglum)))
    (my/create-prayer-file "dni" "Codziennik Biblijny" "codziennik" t)
    (save-excursion (goto-char (point-min)) (forward-line 3) (insert "Siglum: " siglum "\n"))
    (my/wstaw-do-rachunku siglum)))

(defun my/notatki-luzne ()
  (interactive)
  (find-file "~/mapa/Modlitwy/przemyslenia/refleksje.org")
  (goto-char (point-max))
  (insert "\n** " (format-time-string "[%Y-%m-%d %H:%M] ") "--- \n"))

(defun my/rachunek ()
  "Otwiera dzisiejszy plik rachunku sumienia lub tworzy go z szablonu."
  (interactive)
  (let ((dir "~/mapa/Modlitwy/rachunek/"))
    (unless (file-exists-p dir) (make-directory dir t))
    (my/create-prayer-file "rachunek" "Rachunek Sumienia" "rachunek")
    (message "System Mapa: Czas na rachunek sumienia.")))

;; ==========================================
;; 3. DASHBOARD I NARZĘDZIA
;; ==========================================
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-banner-logo-title "Módl się i pracuj, Michale.")
  (setq dashboard-items '((recents . 15) (bookmarks . 10) (projects . 5) (agenda . 5))))

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

(use-package vterm :ensure t)
(use-package projectile :ensure t :init (projectile-mode +1))
(use-package nix-mode :ensure t)

;; ==========================================
;; 4. ORG-CAPTURE (POŁĄCZONE)
;; ==========================================
(setq org-capture-templates
      '(("d" "Diabetyk - Pomiar" table-line 
         (file+headline "~/mapa/zdrowie.org" "Pomiary glukozy")
         "| %U | %^{Moment|Na czczo|Przed posiłkiem|2h po posiłku} | %^{Wynik} | %^{Uwagi} |")
        ("p" "Protokół" entry (file+headline "~/mapa/inbox.org" "Linki z sieci")
         "* %a\n\n  %i\n\n  Dodano: %U" :immediate-finish t)))
; ==========================================
;; 5. GLOBALNE SKRÓTY (NAPRAWIONE)
;; ==========================================

;; Najpierw ogólne narzędzia
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c t") 'vterm)
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-c d") 'dirvish)

;; Nawigacja Alt+p / Alt+n
(global-set-key (kbd "M-p") 'move-line-up)
(global-set-key (kbd "M-n") 'move-line-down)

;; HYDRA - Twoje główne centrum dowodzenia
(use-package hydra :ensure t)

(defhydra hydra-mapa (:color blue :hint nil)
  "
  ^MAPA - Centrum Dowodzenia^
  -----------------------------------------
  _m_: Medytacja (Biblia)   _l_: Luźne notatki
  _b_: Codziennik           _t_: Terminal (vterm)
  _a_: Rachunek Sumienia    _g_: Magit (Git)
  _c_: Capture (Zdrowie/WWW) _q_: Wyjdź
  "
  ("a" my/rachunek)
  ("m" my/medytacja-z-mapy)
  ("b" my/codziennik-krawczyka)
  ("l" my/notatki-luzne)
  ("t" vterm :exit t)
  ("c" org-capture :exit t)
  ("g" magit-status :exit t)
  ("q" nil "cancel"))

;; JEDYNY skrót do Mapy, który musisz pamiętać
(global-set-key (kbd "C-c m") #'hydra-mapa/body)

;; Szybkie skakanie góra/dół
(global-set-key (kbd "M-[") 'beginning-of-buffer)
(global-set-key (kbd "M-]") 'end-of-buffer)

;; Jeśli chcesz mieć bezpośrednie skróty (poza menu), użyj prefiksu C-c C-
(global-set-key (kbd "C-c C-b") #'my/codziennik-krawczyka)
(global-set-key (kbd "C-c C-l") #'my/notatki-luzne)
;; ==========================================
;; 6. ORG-ROAM (Drugi Mózg)
;; ==========================================
(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/mapa/"))
  :bind (("C-c z f" . org-roam-node-find)
         ("C-c z i" . org-roam-node-insert))
  :config
  (org-roam-db-autosync-mode))

;; ==========================================
;; 7. POCZTA (mu4e) - Safe Load
;; ==========================================
(when (fboundp 'mu4e)
  (setq mu4e-maildir "~/Mail"
        mu4e-get-mail-command "mbsync -a"
        mu4e-update-interval 300))

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(dashboard diredfl dirvish doom-themes magit nix-mode nov org-roam
	       pdf-tools projectile treemacs-icons-dired vterm)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(use-package gptel
  :ensure nil
  :config
  ;; Nowoczesna konfiguracja Ollamy dla nowej wersji gptel
  (setq gptel-backend
        (gptel-make-ollama "Ollama"
          :host "localhost:11434"
          :models '("llama3:latest")))
  
  (setq gptel-model "llama3:latest"))

;; --- SKRÓTY KLAWISZOWE DLA GPTEL W ORG-MODE ---

(with-eval-after-load 'org
  ;; 1. Otwórz dedykowany bufor czatu gptel
  (define-key org-mode-map (kbd "C-c g g") 'gptel)

  ;; 2. Wyślij zaznaczony tekst / zapytaj wewnątrz pliku .org (In-place)
  (define-key org-mode-map (kbd "C-c g s") 'gptel-send)

  ;; 3. Otwórz menu gptel (ustawienia, zmiana modelu, prompty)
  (define-key org-mode-map (kbd "C-c g m") 'gptel-menu)

  ;; 4. Dodaj aktywny region jako kontekst
  (define-key org-mode-map (kbd "C-c g c") 'gptel-add))
