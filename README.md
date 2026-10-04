# EventFlow — Pakiet aplikacji (Backend, Web, Mobile)

Projekt składa się z trzech komponentów:
1. **`eventflow server`** — Backend w Laravel 13 (REST API na porcie `8000`, WebSocket Reverb na porcie `8080`, baza SQLite).
2. **`eventflow-webowe`** — Panel organizatora i monitoringu w React + Vite + Tailwind (dostępny na porcie `5173`).
3. **`eventflow-mobilna`** — Aplikacja mobilna w React Native + Expo Router (serwer deweloperski Expo na porcie `8081`).

---

## Szybkie uruchomienie jednym kliknięciem

### Opcja 1: Plik wsadowy `.bat` (Najprostsza)
Wystarczy dwukrotnie kliknąć plik **`start.bat`** (lub uruchomić w wierszu poleceń / PowerShell):
```cmd
start.bat
```
lub:
```cmd
start-all.bat
```

Skrypt automatycznie:
1. Sprawdzi dostępność PHP, Composer i Node.js.
2. Przygotuje pliki `.env` oraz bazę SQLite (jeśli jeszcze nie istnieją).
3. Zainstaluje zależności (`composer install`, `npm install`) dla wszystkich 3 projektów.
4. Uruchomi migracje bazy danych w Laravelu.
5. Otworzy 3 osobne, dedykowane okna konsoli dla Backendu, Weba i Aplikacji Mobilnej.
6. Zaproponuje otwarcie frontendu w przeglądarce pod adresem [http://localhost:5173](http://localhost:5173).

---

### Opcja 2: PowerShell (`start.ps1`)
Możesz uruchomić skrypt z poziomu PowerShell:
```powershell
.\start.ps1
```

Dostępne parametry:
- `.\start.ps1 -SkipInstall` — pomija instalację zależności (szybki start).
- `.\start.ps1 -OnlyInstall` — tylko instaluje zależności bez uruchamiania serwerów.
- `.\start.ps1 -NoBrowser` — nie pyta o otwarcie przeglądarki.

---

### Opcja 3: NPM (z poziomu katalogu głównego)
```bash
npm start
```

---

## Adresy i porty usług

| Usługa | Adres URL | Opis |
|---|---|---|
| **Frontend Web** | [http://localhost:5173](http://localhost:5173) | Panel WWW dla organizatorów i monitoringu |
| **Backend API** | [http://127.0.0.1:8000/api/v1](http://127.0.0.1:8000/api/v1) | Endpointy REST API w Laravelu |
| **Reverb WebSockets** | [http://localhost:8080](http://localhost:8080) | Transmisja danych na żywo (Echo) |
| **Expo Dev Server** | [http://localhost:8081](http://localhost:8081) | Expo Metro Bundler |

---

## Obsługa aplikacji mobilnej (Expo)

W oknie konsoli **EventFlow - Mobile**:
- Naciśnij klawisz **`w`**, aby otworzyć aplikację mobilną w przeglądarce jako Web.
- Naciśnij klawisz **`a`**, aby uruchomić aplikację na emulatorze Androida.
- Zeskanuj wyświetlony kod QR aplikacją **Expo Go** (Android/iOS) będąc w tej samej sieci Wi-Fi.

---

## Zatrzymywanie usług

Aby jednym poleceniem zamknąć wszystkie działające procesy na portach `8000`, `8080`, `8081`, `5173`, uruchom:
```cmd
stop.bat
```
lub w PowerShell:
```powershell
.\stop.ps1
```
