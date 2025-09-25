import tables, strutils

# Karakteri Mors Sinyaline Eşleme Tablosu
# '.' -> Dot (1 bit)
# '-' -> Dash (3 bit)
# ' ' -> Kelime Boşluğu (7 bit) -- Burada Mors sinyali *temsilini* kullanıyoruz.
# '/' -> Harf Boşluğu (3 bit)

const MorseCodes = {
  'A': ".-",  'B': "-...",  'C': "-.-.", 'D': "-..", 'E': ".",
  'F': "..-.", 'G': "--.", 'H': "....", 'I': "..",  'J': ".---",
  'K': "-.-", 'L': ".-..", 'M': "--",  'N': "-.",  'O': "---",
  'P': ".--.", 'Q': "--.-", 'R': ".-.", 'S': "...", 'T': "-",
  'U': "..-", 'V': "...-", 'W': ".--", 'X': "-..-", 'Y': "-.--",
  'Z': "--..",
  '0': "-----", '1': ".----", '2': "..---", '3': "...--", '4': "....-",
  '5': ".....", '6': "-....", '7': "--...", '8': "---..", '9': "----.",
  ' ': "/" # Kelime Boşluğu ayıracı (7 birim boşluk olacak)
}.toTable

# Sinyal Temsili (Tüm boşluklar dahil)
# '.' -> 1
# '-' -> 111
# Element Boşluğu (aynı harf içinde) -> 0
# Karakter Boşluğu (harfler arası) -> 000
# Kelime Boşluğu (boşluk karakteri) -> 0000000

proc encodeMorse*(text: string): tuple[bits: seq[int], bitLength: int] =
    ## Verilen metni ikili mors sinyali temsilisine (1s ve 0s) kodlar.

    var bits: seq[int] = @[]
    var firstChar = true # ilk karakter için karakter boşluğu eklenmesini engeller

    for char in text.toUpper():
        if not firstChar:
            # Önceki karakter ile bu karakter arasına karakter boşluğu (3 birim 0) ekle
            bits.add(0)
            bits.add(0)
            bits.add(0)

        # Karakteri morsa çevir
        let morseCode = MorseCodes.getOrDefault(char, "")

        if morseCode == "/": # Kelime boşluğu
            # Kelime boşluğu (7 birim 0)
            bits.add(0)
            bits.add(0)
            bits.add(0)
            bits.add(0)
            bits.add(0)
            bits.add(0)
            bits.add(0)
            firstChar = true # Kelime boşluğundan sonra ilk harfi bekle
            continue
        
        for i, morseUnit in morseCode:
            case morseUnit:
                of '.': # dot (1 birim 1)
                    bits.add(1)
                of '-': # dash (3 birim 1)
                    bits.add(1)
                    bits.add(1)
                    bits.add(1)
                else:
                    # geçersiz karakteri atla
                    continue
            
            # Aynı harf içindeki Dot/Dash arasına element boşluğu (1 birim 0) ekle
            if i < morseCode.len - 1:
                bits.add(0)

        firstChar = false

    # Bit dizisini ve toplam uzunluğunu döndür
    return (bits: bits, bitLength: bits.len)    