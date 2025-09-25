import morsek/morse
import std/net

# Protokol Sabitleri
const
  MagicNumber: uint32 = 0x4D4F5253 # "MORS"
  Version: uint8 = 0x01
  MessageTypeText: uint8 = 0x01


# --- 1. Bitleri Baytlara Paketleme (Bit Packing) ---
proc packBits(bits: seq[int]): seq[byte] =
  ## 1'lerden ve 0'lardan oluşan diziyi en verimli şekilde bayt dizisine paketler.
  var bytes: seq[byte] = @[]
  var currentByte: byte = 0
  var bitIndex = 7 # En yüksek bit (7) ile başla

  for bit in bits:
    if bit == 1:
      # Sadece 1 ise biti ayarla (OR işlemi)
      currentByte = currentByte or (1.byte shl bitIndex)
    
    # İndeksi azalt
    bitIndex.dec()

    # Bir bayt dolduğunda veya son bite ulaşıldığında
    if bitIndex < 0:
      bytes.add(currentByte)
      currentByte = 0 # Yeni bayt için sıfırla
      bitIndex = 7 # Yeni baytın en yüksek bitiyle başla

  # Kalan kısım varsa, tamamlanmamış son baytı ekle
  if bitIndex != 7:
    bytes.add(currentByte)
    
  return bytes

# --- 2. Başlık ve Gövdeyi Birleştirme (Serileştirme) ---

proc serializeMessage(text: string): seq[byte] =
  ## Metni Mors koduna çevirir, paketler ve M-NET başlığıyla birleştirir.

  # 1. Metni Mors sinyali bitlerine çevir
  let (bits, bitLength) = encodeMorse(text)

  # 2. Bitleri Baytlara Paketle (Bit Packing)
  let payloadBytes = packBits(bits)
  let payloadByteLength = payloadBytes.len.uint32

  # 3. Başlık Oluşturma (Big-Endian formatında)
  var header: seq[byte] = @[]

  # Magic Number (4 Bayt) - Convert to big endian manually
  header.add((MagicNumber shr 24).byte)
  header.add((MagicNumber shr 16).byte)
  header.add((MagicNumber shr 8).byte)
  header.add(MagicNumber.byte)

  # Version (1 Bayt)
  header.add(Version)

  # Message Type (1 Bayt)
  header.add(MessageTypeText)
  
  # Payload Byte Length (4 Bayt)
  header.add((payloadByteLength shr 24).byte)
  header.add((payloadByteLength shr 16).byte)
  header.add((payloadByteLength shr 8).byte)
  header.add(payloadByteLength.byte)

  # Payload Bit Length (4 Bayt)
  let bitLenU32 = bitLength.uint32
  header.add((bitLenU32 shr 24).byte)
  header.add((bitLenU32 shr 16).byte)
  header.add((bitLenU32 shr 8).byte)
  header.add(bitLenU32.byte)

  # 4. Başlık ve Gövdeyi Birleştir
  return header & payloadBytes

# --- Örnek Kullanım (Sunucu ve İstemci için temel) ---

proc startClient*() =
  let client = newSocket()
  client.connect("127.0.0.1", 9999.Port)
  
  let userMessage = "NIM MORS PROTOKOLU"
  echo "Gönderilen Cümle: " & userMessage
  
  let fullMessage = serializeMessage(userMessage)
  
  echo "Gönderilen toplam bayt: ", fullMessage.len
  # Gönderim işlemi
  discard client.send(addr fullMessage[0], fullMessage.len) 

  client.close()

proc startServer*() =
  let server = newSocket()
  server.bindAddr(9999.Port)
  server.listen()
  echo "M-NET Sunucusu 9999 portunda dinliyor..."

  while true:
    var client: Socket
    server.accept(client)
    # 9 baytlık sabit başlığı okumayı ve ardından değişken uzunluktaki gövdeyi okumayı 
    # (yani deserialize işlemini) buraya ekleyeceğiz.
    
    # Şimdilik basitçe ilk 14 baytı okuyalım (Magic, Version, Type, 2x Length)
    var headerBytes = newSeq[byte](14)
    discard client.recv(addr headerBytes[0], 14)
    
    echo "Başlık Alındı: ", $headerBytes
    
    client.close()

# Tekrar başlatmak istediğinizde, ya sunucuyu ya da istemciyi çalıştırın.
# startClient()
# startServer()

# Basit bir test:
when isMainModule:
  let msg = "Merhaba Dünya"
  let (bits, bitLen) = encodeMorse(msg)
  echo "Orijinal Bitler (" & $bitLen & " adet): ", $bits
  let packed = packBits(bits)
  echo "Paketlenmiş Baytlar (" & $packed.len & " adet): ", $packed

  # Serileştirilmiş mesajı test et
  let fullMsg = serializeMessage(msg)
  # Başlığın doğru oluşup oluşmadığını kontrol etmek için ilk 14 baytı yazdır.
  echo "Serileştirilmiş Toplam Bayt: ", fullMsg.len
  echo "Başlık (İlk 14 Bayt): ", $fullMsg[0..13]

