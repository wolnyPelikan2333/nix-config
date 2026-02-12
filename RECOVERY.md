cd /etc/nixos

# pobierz aktualny stan z GitHuba
git fetch --all --tags

# przełącz repo na złoty build
git checkout golden-gen7

# odbuduj i przełącz system
sudo nixos-rebuild switch --flake /etc/nixos#nixos


📌 Zasada:

git checkout → zmienia konfigurację

nixos-rebuild switch → zmienia system


# 🛟 NixOS Recovery Runbook

Ten dokument opisuje **procedurę przywracania stabilnego (golden) buildu**
systemu NixOS z repozytorium `/etc/nixos`.

---

## 🟢 Złoty build

Aktualny stabilny punkt:
- **Tag:** `golden-gen7`
- **Opis:** Fixed EFI /boot mount, stable boot, working systemd-boot
- **Status:** bootowalny, sprawdzony ręcznie

---

## 🔁 Procedura przywracania (5 minut)

Wykonuj **dokładnie w tej kolejności**:

```bash
cd /etc/nixos
git fetch --all --tags
git checkout golden-gen7
sudo nixos-rebuild switch --flake /etc/nixos#nixos

Po zakończeniu:

jeśli system działa → OK

jeśli nie → reboot i wybór właściwej generacji w bootloaderze

readlink /run/current-system
sudo bootctl status


Jeśli nowe generacje nie bootują

Sprawdź montowanie /boot:

lsblk -f
mount | grep boot


Sprawdź definicję EFI:

/etc/nixos/nixos/hardware-configuration.nix

musi istnieć fileSystems."/boot"

Sprawdź bootloader:

sudo bootctl list
sudo bootctl status

🧠 Zasady bezpieczeństwa

sudo używamy tylko do nixos-rebuild

git uruchamiamy bez sudo

Każda większa zmiana = commit

Stabilny system = tag golden-*

📌 Złota zasada

Jeśli nowe generacje nie bootują, a stare tak — najpierw sprawdź /boot.

# 3️⃣ ZAPISZ RUNBOOK W REPO

Po wklejeniu pliku:

```bash
cd /etc/nixos
git add RECOVERY.md
git commit -m "docs: add recovery runbook"
git push








