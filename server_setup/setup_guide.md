# Hetzner Germaniya Serverida VLESS Reality O'rnatish Qo'llanmasi

Ushbu qo'llanma orqali siz **Hetzner Cloud** (Germaniya) serveringizda 5–10 daqiqada eng tezkor, 100% shaxsiy va DPI blokirovkalaridan himoyalangan **VLESS + XTLS-Reality** VPN serverini ishga tushirasiz.

---

## 1-Qadam: Hetzner Cloud'da Server Ochish

1. [Hetzner Cloud Console](https://console.hetzner.cloud/) ga kiring va yangi loyiha (Project) oching.
2. **"Add Server"** tugmasini bosing:
   * **Location (Joylashuv):** `Falkenstein` yoki `Nuremberg` (Germaniya) — O'zbekiston uchun eng past ping (45–65 ms) beradi.
   * **Image (Tizim):** `Ubuntu 24.04 LTS` yoki `Ubuntu 22.04 LTS`.
   * **Type (Tarif):** `Shared vCPU` -> `Arm64 (CAX11)` yoki `x86 (CX22)` (oyiga atigi ~€3.5–€4, 1 Gbps port va 20 TB bepul trafik).
   * **SSH Keys / Root Password:** Parol yoki SSH kalitingizni kiriting.
3. **"Create & Buy Now"** tugmasini bosing. 30 soniyada server tayyor bo'ladi va sizga uning **IP manzili** beriladi.

---

## 2-Qadam: Serverga Kirish va 3X-UI O'rnatish

Kompyuteringiz terminalidan (PowerShell yoki Putty) serverga ulaning:
```bash
ssh root@SERVERINGIZ_IP_MANZILI
```

Server yangilanishlarini o'rnating va 3X-UI avtomatlashtirilgan o'rnatuvchisini ishga tushiring:
```bash
apt update && apt upgrade -y
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

O'rnatish davomida terminal sizdan so'raydi:
* `Do you want to continue? [y/n]`: **y** yozib Enter bosing.
* `Please enter panel username`: O'zingiz uchun login (masalan: `admin`).
* `Please enter panel password`: Xavfsiz parol.
* `Please enter panel port`: Panel porti (masalan: `2053`).

O'rnatish 1 daqiqada yakunlanadi.

---

## 3-Qadam: 3X-UI Veb-Paneliga Kirish

Brauzeringizda quyidagi manzilni oching:
```
http://SERVERINGIZ_IP_MANZILI:2053
```
Belgilagan login va parolingiz bilan panelga kiring.

---

## 4-Qadam: VLESS Reality Inbound (Kalit) Yaratish

1. Chap menyudan **"Inbounds"** (Kirishlar) bo'limiga o'ting.
2. **"+ Add Inbound"** tugmasini bosing va quyidagi parametrlarni kiriting:
   * **Remark:** `🇩🇪 Hetzner Germany Fast`
   * **Protocol:** `vless`
   * **Listening IP:** `0.0.0.0`
   * **Port:** `443` (Muhim: oddiy HTTPS saytlar porti)
   * **Transmission:** `TCP`
   * **Security:** `Reality`
   * **uTLS:** `chrome`
   * **Dest / Target (Niqob sayt):** `www.yahoo.com:443` yoki `gateway.icloud.com:443`
   * **Server Names (SNI):** `www.yahoo.com` (yoki yuqorida tanlangan domen)
   * **Short IDs:** Bo'sh qoldirsangiz o'zi generatsiya qiladi yoki `Get New Cert` bosing.
3. **"Save" (Saqlash)** tugmasini bosing.

---

## 5-Qadam: Kalitni Olish va Flutter Ilovasiga Kiritish

1. Yaratilgan inbound yonidagi **QR-kod** belgisini yoki uch nuqtadan **"Copy Link"** (Havolani nusxalash) ni bosing.
2. Havola quyidagicha ko'rinishda bo'ladi:
   ```
   vless://uuid@server_ip:443?type=tcp&security=reality&pbk=...&fp=chrome&sni=www.yahoo.com&sid=...#🇩🇪%20Hetzner%20Germany%20Fast
   ```
3. Endi Flutter ilovamizda:
   * **"Serverlar Ro'yxati"** -> **"Yangi Server Qo'shish"** tugmasini bosing.
   * **"Joylash (Paste)"** ni bosing yoki telefoningiz kamerasini QR-kodga qarating.
   * **"Saqlash"** tugmasini bosing.

Bo'ldi! Katta quvvat tugmasini bossangiz, ilovangiz darhol Germaniya serveringiz orqali xavfsiz va ultra-tezkor tunnelni faollashtiradi.

---

## 6-Qadam: "0-Log" Maxfiylik Siyosatini Yoqish (Ixtiyoriy)

Agar foydalanuvchilar qaysi saytlarga kirgani server xotirasida umuman saqlanmasligini xohlasangiz:
1. 3X-UI panelida **"Panel Settings"** -> **"Xray Configuration"** bo'limiga o'ting.
2. `Log Level` maydonini **`none`** ga o'zgartiring.
3. **"Save"** va **"Restart Xray"** tugmasini bosing.
Bu orqali serveringiz 100% maxfiy va hech qanday kirish loglarini saqlamaydigan holatga keladi.
