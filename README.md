# A Játék elérési útja: https://drive.google.com/file/d/1VL7TZYSGmKLJMLnieDQHcH3JY0LS2Z6t/view?usp=drive_link
# Assetek elérhetőek innen: https://drive.google.com/drive/folders/1UcTV6qOxPjwW5SJyaYRz0vBs6nU3VCsm?usp=drive_link
---
# A Játék fejlesztése

-pullolja le a gitről a jelen lévő asseteket

-rakja hozzá a fileba a fönt látható drive linken elérhető asset mappát

-töltse le a godot engine-t

-nyissa meg majd az import fülön töltse be a mappában található project.godot file-t

-majd fejlesztheti is a játékot

---
# 🎮 Játék Menete

## 1. **Főmenü**
- **Új játék:**
  - Elindítja az új kalandot, ahol a játékos megismeri a történetet és a világot.
- **Betöltés:**
  - Betölti a korábban mentett játékállást.
- **Beállítások:**
  - Lehetővé teszi a hangerő, grafikai beállítások és irányítás módosítását.
- **Kilépés:**
  - Kilép a játékból.



## 2. **Játék Indítása**
- **Tutorial:**
  - Bemutatja a játék alapmechanikáit, például a mozgást, interakciót NPC-kkel, és harc mechanikát.
- **Első Küldetés:**
  - A játékos feladata, hogy találkozzon egy fontos NPC-vel, aki bevezeti a fő történetbe.



## 3. **Játékmenet**
- **Fedezd fel a világot:**
  - A játékos szabadon mozoghat a játék területén.
- **Interakció NPC-kkel:**
  - A játékos különböző NPC-kkel találkozhat, akik küldetéseket adnak, információt osztanak meg, vagy segítenek a játékosnak.
- **Küldetések:**
  - Küldetések teljesítése során a játékos egy feladadot kap. (Mentse meg a faluját)
- **Achievementek:**
  - A játékos achievementeket szerezhet különböző feladatok teljesítésekor, amelyek láthatóak az oldalon is.


## 4. **Harci Mechanika**
- **Ellenfelek:**
  - A játék során különböző típusú ellenfelekkel találkozhatunk (pl. szörnyek).
- **Harci lehetőségek:**
  - A játékos különböző támadási lehetőségeket használhat.



## 5. **Befejezés**
- **Végső küldetés:**
  - A játékosnak teljesítenie kell a végső küldetést, amely a fő történet csúcspontja, és meg kell küzdenie a végső ellenféllel.
---


# 🔌 Backend Kommunikáció

## 🌐 Backend Végpontok
```gdscript
var backend_url_login = "/api/auth/login"
var backend_url_user = "/api/user/userprofile"
var backend_url_achivements = "/api/achievements/userachievements"
var backend_url_all_achivements = "/api/achievements/all"
```
> Ezek az alapértelmezett (relatív) végpont URL-ek. A `GameManeger.szerverIp`-hez kapcsolódnak `_ready()` során, hogy teljes URL-t képezzenek.



## 🔑 Bejelentkezés

### `func _on_login_button_pressed()`
- **Cél:** Felhasználó bejelentkezése e-mail és jelszó alapján.
- **Adatformátum:** JSON objektum: `{ "email": ..., "psw": ... }`
- **HTTP metódus:** POST
- **Válasz kezelés:** A `_on_request_completed()` függvény dolgozza fel.
- **Hiba esetén:** Hibaüzenet jelenik meg a `Login` panelen.



## 👤 Felhasználói profil lekérdezése

### Feltétel:
```gdscript
if GameManeger.token!="" and GameManeger.uid==0 and keres!="jatekosadat"
```

### `keres = "jatekosadat"`
### Kérés:
- **Végpont:** `/api/user/userprofile`
- **HTTP metódus:** GET
- **Fejlécek:**
  ```gdscript
  "Content-Type: application/json",
  "Cookie: auth_token=" + GameManeger.token
  ```

### Válasz feldolgozása:
- `GameManeger.uid` és `GameManeger.username` értékeket beállítja
- Átirányítás a `user` menüpontra



## 🏆 Felhasználói teljesítmények lekérdezése

### `keres = "teljesitmeny"`
- **Végpont:** `/api/achievements/userachievements`
- **HTTP metódus:** GET
- **Fejlécek:**
  ```gdscript
  "Content-Type: application/json",
  "Cookie: auth_token=" + GameManeger.token
  ```

### Feldolgozás:
- `GameManeger.localachivements` listába bekerülnek az elért achivementek
- `GameManeger.earenedachivements` listába részletes adatokat kapunk
- Az első achivement esetén (ha még nincs megszerezve) példányosít egy értesítést



## 🏅 Összes teljesítmény lekérdezése

### `keres = "mindenteljesitmeny"`
- **Végpont:** `/api/achievements/all`
- **HTTP metódus:** GET
- **Fejlécek:**
  ```gdscript
  "Content-Type: application/json"
  ```

### Feldolgozás:
- Feltölti a `GameManeger.achivements` listát (ID;név;leírás)
- Feltölti a `GameManeger.localachivements`-et `false` értékekkel
- `adatok=true` lesz, majd új lekérdezést indít a `teljesitmeny` adatokra



## 📡 Válasz feldolgozása: `func _on_request_completed(...)`

- A `keres` változó alapján történik a válasz azonosítása.
- Token válasz esetén (`response_data.has("token")`) → `GameManeger.token` beállítása.
- Sikeres válasz után megjeleníti a megfelelő menüpontot, vagy achivement UI-t frissít.



## 🛠 Egyéb kapcsolódó funkciók

### `megjelenites(...)`
Egyszerű helper függvény, amely elrejti az összes UI panelt, és megjeleníti a megadottat.

---

## 🏆 Achievement Handler – Backend integráció

### Fájl: `scripts/achievement.gd`

Ez a script felelős a játékban megszerezhető achievementek (teljesítmények) lekéréséért és regisztrálásáért a backend rendszer felé. Kommunikál a szerverrel, megjeleníti az új achievementet a játékos számára, és frissíti a globális állapotot.



### 📀 Alapvető működés

A `Node2D`-ből származó script az `AnimationTree`-n keresztül kezeli az értesítés animációját, valamint a `HTTPRequest` node segítségével kommunikál a backend API-val.



### 📁 Felhasznált node-ok

| Változó                     | Node útvonal                                 | Funkció                                          |
|----------------------------|----------------------------------------------|--------------------------------------------------
| `control`                  | `$UI/Control`                                | Fő UI konténer                                  |
| `Achivement_name`          | `$UI/Control/.../Achivement_name`            | Achievement neve (UI)                           |
| `Text`                     | `$UI/Control/.../Text`                       | Achievement leírása (UI)                        |
| `http_request`             | `$HTTPRequest`                               | HTTP kommunikációhoz használt node              |
| `icon`                     | `$UI/Control/.../icon`                       | Achievement ikonja                              |



### ⚖️ Fontos változók

| Név               | Típus     | Leírás                                                              |
|------------------|-----------|---------------------------------------------------------------------|
| `backend_url_achivement` | `String`  | API végpont új achievement hozzáadására                          |
| `backend_url_melyachivement` | `String` | API végpont egy adott achievement részletes adatainak lekérésére |
| `ok`              | `bool`    | Jelzi, hogy el kell-e indítani a GET kérést                        |
| `megvan`          | `bool`    | A játékos már megszerezte ezt az achievementet                    |
| `van`             | `bool`    | Az achievement létezik a globális listában                         |
| `ikon`            | `String`  | Ikon neve                                                           |
| `Achivement_Id`   | `int`     | Achievement azonosító (backend alapján)                            |



### ⚙️ Főbb funkciók

#### `_ready()`

- Beállítja a backend URL-eket a `GameManeger.szerverIp` alapján
- Rácsatlakozik a `http_request.request_completed` signal-ra


#### `_on_request_completed(result, response_code, headers, body)`

- Backend válasz feldolgozása
- Ha a válasz érvényes és tartalmaz achievement adatokat:
  - Elmenti az adatokat a `GameManeger.earenedachivements` listába



#### `set_tooltip(Id: int)`

- Beállítja az aktuális achievementet az `Id` alapján
- Ellenőrzi, hogy az achievement már megszerzett-e
- Ha érvényes, POST kérést küld a szervernek
- Az ikon automatikusan betöltésre kerül (`base/ikon_kor.png`), ha van hozzárendelve


---

## 📷 Fájl Szerkezet

res://  
├── assets  
│   ├── achievements  
│   │   ├── active              # Zöld alapú teljesítmény ikonok  
│   │   ├── base                # Fekete alapú teljesítmény ikonok  
│   │   └── inactive            # Szürke alapú teljesítmény ikonok  
│   ├── fonts  
│   │   └── keania_one  
│   │       └── KeaniaOne_Regular.ttf  
│   ├── forest_background  
│   │   ├── 1.png  
│   │   ├── 2.png  
│   │   ├── 3.png  
│   │   └── 4.png  
│   ├── player  
│   │   ├── attack              # Támadás animáció képkockái  
│   │   ├── death               # Halál animáció képkockái  
│   │   ├── idle                # Alap animáció képkockái  
│   │   ├── run                 # Futás animáció képkockái    
│   │   ├── walk                # Séta animáció képkockái  
│   │   └── walk_begin          # Séta kezdő animáció képkockái  
│   ├── pngs                    # Egyéb képek a projekthez  
│   └── videos                  # Szükséges videók (.ogv formátumban)  
├── levels  
│   ├── scripts  
│   │   ├── level_1.gd  
│   │   ├── level_2.gd  
│   │   └── level_tutorial.gd  
│   ├── level_1.tscn  
│   ├── level_2.tscn  
│   ├── level_test.tscn  
│   └── level_tutorial.tscn  
├── scenes  
│   ├── main_menu  
│   │   ├── achievement.tscn  
│   │   ├── level.tscn  
│   │   ├── login.tscn  
│   │   ├── map_selection.tscn  
│   │   └── save.tscn  
│   ├── map_scene  
│   │   ├── enemy  
│   │   │   ├── boss_base.tscn  
│   │   │   ├── enemy.tscn  
│   │   │   ├── enemy_1.tscn  
│   │   │   └── enemy_2.tscn  
│   │   ├── npc  
│   │   │   └── talkable_npc.tscn  
│   │   ├── tracks  
│   │   │   ├── area_dialog.tscn  
│   │   │   ├── check_point.tscn  
│   │   │   ├── cut_scene.tscn  
│   │   │   ├── death_area.tscn  
│   │   │   ├── spawner.tscn  
│   │   │   └── teleport.tscn  
│   │   ├── camera.tscn  
│   │   └── player.tscn  
│   └── other  
│       ├── dialog.tscn  
│       ├── explosion.tscn  
│       ├── game_manager.tscn  
│       ├── hit_box.tscn  
│       ├── hurt_box.tscn  
│       ├── loading_screen.tscn  
│       ├── new_achievement.tscn  
│       └── ui.tscn  
├── scripts  
│   ├── achievement.gd  
│   ├── area_dialog.gd  
│   ├── camera.gd  
│   └── # Egyéb GDScript fájlok  
├── resources  
│   ├── pause_btn_hover.tres  
│   ├── pause_btn_pressed.tres  
│   ├── pause_btn_normal.tres  
│   └──# Egyéb kinézeti beállítások (.tres fájlok)  

---

# 🧪 Fejlesztői Környezet

A játékfejlesztés Godot motorban történik. Az alábbi szerkesztőfelületek kiemelten fontosak a projekt karbantartásához és fejlesztéséhez.

### 🧭 Scene Tree (Jelenetfa)
A bal oldalon található a Scene Tree, ahol a jelenetek (scene-ek) hierarchikusan vannak felépítve. Minden elem egy node, amelyek egymás alá vagy fölé rendezhetők. A jelenetfa struktúrája határozza meg az objektumok viszonyait.

### 🧙‍♂️ Inspector
A jobb oldali panel, ahol a kiválasztott node tulajdonságai szerkeszthetők. Itt módosíthatók a pozíciók, szkriptekhez tartozó változók, animációhoz kapcsolódó paraméterek, stb.

### 🪄 Script Editor
A Godot beépített kódszerkesztője. Támogatja a GDScript nyelvet, automatikus kiegészítést, szintaxiskiemelést és hibakeresést. Itt történik a játékmenet logikájának implementálása.

### 🖼 Szerkesztő Ablak
A középső szerkesztőfelület, amely lehetővé teszi a vizuális tervezést. A node-ok elhelyezése, szintek szerkesztése és jelenet-előnézetek itt valósulnak meg.

![Godot szerkesztő képernyő](https://zkm.de/system/files/styles/img_node_media_detail_zoom/private/field_media_image/2023/03/13/143425/ui_of_godot_game_engine.jpeg?itok=Dy0rsqlb)

---



