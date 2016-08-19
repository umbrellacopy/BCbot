function bencode(data)
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
function bdecode(data)
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local function kmakerow(texts)
local row = {}
for i=1 , #texts do
row[i] = {text=URL.escape(texts[i])}
end
return row
end
local function kmake(rows)
local kb = {}
kb.keyboard = rows
kb.resize_keyboard = true
kb.selective = true
return kb
end
local function make_menu()
local rw1_texts = {'QR Code Reader'}
local rw2_texts = {'QR Code Maker','BarCode Maker'}
local rw3_texts = {'Encode Hash','Decode Hash'}
local rw4_texts = {'About','Help'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts),kmakerow(rw4_texts)}
return kmake(rows)
end
local function action(msg)
if msg.text == '/start' then
api.sendMessage(msg.chat.id, 'Robot is *Started*', true, true,msg.message_id, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')
elseif msg.text == '🔲🔳\n🔳🔲' then
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,msg.message_id, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')
elseif msg.text == '/init' and msg.from.id == bot_sudo then
bot_init(true)
api.sendReply(msg, '*Reloaded!*', true)
elseif msg.text == '/stats' and msg.from.id == bot_sudo then
api.sendReply(msg, 'Users:'..db:hlen('bot:waiting'), true)
elseif msg.text and msg.text:match('^/s2a .*$') and msg.from.id == bot_sudo then
local pm = msg.text:match('^/s2a (.*)$')
local suc = 0
local ids = db:hkeys('bot:waiting')
if ids then
for i=1,#ids do
local ok,desc = api.sendMessage(ids[i], pm)
print('Sent', ids[i])
if ok then
suc = suc +1
end
end
api.sendReply(msg, 'Msg sended to '..#ids..'user, '..suc..' success and '..(#ids - suc)..' fail!')
else
api.sendReply(msg, 'No User Found!')
end
else
local setup = db:hget('bot:waiting',msg.from.id)
if setup == 'main' then
if msg.text == 'QR Code Reader' then
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rows ={kmakerow(rw1_texts)}
api.sendMessage(msg.chat.id, 'You can *Take a Photo of QR Code* or *Select From Gallery* and send to me...', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'reader')
elseif msg.text == 'QR Code Maker' then
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'Telegram Contact QR Code'}
local rw3_texts = {'Telegram Sticker'}
local rw4_texts = {'JPG Image','PNG Image'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts),kmakerow(rw4_texts)}
api.sendMessage(msg.chat.id, 'Select *Image Type:*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'qrmain')

elseif msg.text == 'BarCode Maker' then
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'Code 2of5 (Numic)','Code 128C (Numic)'}
local rw3_texts = {'Code 128B','Code 128A','Code 39'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts)}
api.sendMessage(msg.chat.id, 'Select *Barcode Algorithm:*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'brmain')
elseif msg.text == 'Encode Hash' then
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'Base 64','UmbH UmbH (Umbrella Hash)'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts)}
api.sendMessage(msg.chat.id, 'Select *Hash Algorithm:*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'encode')
elseif msg.text == 'Decode Hash' then
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'Base 64','UmbH UmbH (Umbrella Hash)'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts)}
api.sendMessage(msg.chat.id, 'Select *Hash Algorithm:*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'decode')
elseif msg.text == 'Help' then
local help = [[_BarCodeCopy Robot_ *(Inline)*
 
*Inline Mode*
     `enter this robot username (@uc_BCbot) in the Input Text Box and press Space button and wait for show Inline Keyboard, if you have Username, in Inline Keyboard show a button for make QR Code for you'r username. You can enter text after this robot username for make QR Core of input text.`
 
 
*QR Code Reader*
     `for read a qr code in this option, you can send a QR code image from you'r gallery or take photo of a QR code and send.`
 
 
*QR Code Maker:*
you have 4 option for make QR Code:

     _Telegram Contact QR Code:_
     `in this option you can make QR Code of telegram Usernames`
  
     _Telegram Sticker:_
     `in this option you can make QR Code of Texts or URls in telegram Sticker format`
  
     _JPG Image:_
     `in this option you can make QR Code of Texts or URls in Jpeg image format`
  
     _PNG Image:_
     `in this option you can make QR Code of Texts or URls in PNG image format`
 
 
*BarCode Maker:*
you have 5 algorithm for make Barcode:
 
     _Code 2of5:_
     `in this option you can make normal Numic barcode`
  
     _Code 128C:_
     `in this option you can make normal Numic barcode`
  
     _Code 128B:_
     `in this option you can make barcode of Texts`
  
     _Code 128A:_
     `in this option you can make barcode of Texts`
  
     _Code 39:_
     `in this option you can make barcode of Texts`
  
 
*Encode Hash:*
you have 2 algorithm for make Hash Code:
 
     _Base 64:_
     `you can send utf-8 texts for encode hash to algorithm base 64`
  
     _Umbrella:_
     `you can send utf-8 texts for encode hash to algorithm umbrella`
 
 
*Decode Hash:*
you have 2 algorithm for Decode Hash:
 
     _Base 64:_
     `you can send base 64 hash code for decode to utf-8 text`
  
     _Umbrella:_
     `you can send umbrella hash code for decode to utf-8 text`]]
api.sendReply(msg, help, true)
elseif msg.text == 'About' then
local pms = [[*BarCodeCopy Robot* v1.0

   _- Read QR Code_
   _- Make QR Code_
   _- Make BarCode_
   _- Encode Hash Algorithms_
   _- Decode Hash Algorithms_
   _- & More..._

*Created by *[UmbrellaCopy Team](https://telegram.me/umbrellacopy)]]
local keyboard = {}
    keyboard.inline_keyboard = {
{
{text = "Admin" , url = 'https://telegram.me/kingprogram'}
},
{
{text = "RoBoT" , url = 'https://telegram.me/uc_bcbot'}
},
{
{text = "Channel" , url = 'https://telegram.me/UmbrellaCopy'}
},
{
{text = "Source" , url = 'https://github.com/UmbrellaCopy/bcbot'}
}
}
api.sendMessage(msg.chat.id, pms, true, true,msg.message_id, true,keyboard)
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif setup == 'encode' then
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rows ={kmakerow(rw1_texts)}
api.sendMessage(msg.chat.id, 'Send *Text:*', true, true,msg.message_id, true,kmake(rows))
if msg.text == 'Base 64' then
db:hset('bot:waiting',msg.from.id,'encodeb')
elseif msg.text == 'UmbH UmbH (Umbrella Hash)' then
db:hset('bot:waiting',msg.from.id,'encodeu')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif setup == 'encodeb' then
api.sendReply(msg,bencode(msg.text)..'\n\n@uc_bcbot')
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,nil, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')
elseif setup == 'encodeu' then
api.sendReply(msg,bencode(bencode(msg.text))..'\n\n@uc_bcbot')
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,nil, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')

elseif setup == 'decode' then
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rows ={kmakerow(rw1_texts)}
api.sendMessage(msg.chat.id, 'Send *Text:*', true, true,msg.message_id, true,kmake(rows))
if msg.text == 'Base 64' then
db:hset('bot:waiting',msg.from.id,'decodeb')
elseif msg.text == 'UmbH UmbH (Umbrella Hash)' then
db:hset('bot:waiting',msg.from.id,'decodeu')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif setup == 'decodeb' then
api.sendReply(msg,bdecode(msg.text)..'\n\n@uc_bcbot')
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,nil, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')
elseif setup == 'decodeu' then
api.sendReply(msg,bdecode(bdecode(msg.text))..'\n\n@uc_bcbot')
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,nil, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')



elseif setup == 'reader' then
if msg.photo then
local dat = json:decode(HTTP.request('http://api.qrserver.com/v1/read-qr-code/?fileurl='..URL.escape('https://api.telegram.org/file/bot'..bot_api_key..'/'..api.getFile(msg.photo[1].file_id).result.file_path)))[1]
if dat.symbol[1].data then
api.sendReply(msg, 'QR Code Data:\n\n______________________________\n'..dat.symbol[1].data..'\n\n@uc_bcbot')
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,nil, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')
else
api.sendMessage(msg.chat.id, 'You\'r file *is NOT QR Code!*', true, true,msg.message_id, true)
end
else
api.sendMessage(msg.chat.id, 'You\'r file *is NOT Photo!*', true, true,msg.message_id, true)
end
elseif setup == 'br1' then
local sntable = {'Small','Medium','Large','Extra'}
local stable = {'width=100&height=50','width=200&height=70','width=300&height=100','width=500&height=170'}
local suc = 0
for i,v in pairs(sntable) do
if msg.text == v then
local mytable = json:decode(db:hget('bot:bcreate',msg.from.id))
mytable.size=stable[i]
db:hset('bot:bcreate',msg.from.id,json:encode(mytable))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'True','False'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts)}
api.sendMessage(msg.chat.id, 'Select *Image Border:*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'br2')
suc = 1
end
end
if suc == 0 then
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif setup == 'br2' then
if msg.text == 'True' or msg.text == 'False' then
if msg.text == 'True' then
local mytable = json:decode(db:hget('bot:bcreate',msg.from.id))
mytable.boarder= '1'
db:hset('bot:bcreate',msg.from.id,json:encode(mytable))
else
local mytable = json:decode(db:hget('bot:bcreate',msg.from.id))
mytable.boarder= '0'
db:hset('bot:bcreate',msg.from.id,json:encode(mytable))
end
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rows ={kmakerow(rw1_texts)}
local cbase = json:decode(db:hget('bot:bcreate',msg.from.id)).cbase
if cbase == 'i2of5' or  cbase == 'c128c' then
api.sendMessage(msg.chat.id, 'Send Only *Number:*', true, true,msg.message_id, true,kmake(rows))
else
api.sendMessage(msg.chat.id, 'Send a *Word* or *a Number:*', true, true,msg.message_id, true,kmake(rows))
end
db:hset('bot:waiting',msg.from.id,'br3')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end

elseif setup == 'br3' then
local cbase = json:decode(db:hget('bot:bcreate',msg.from.id)).cbase
if cbase == 'i2of5' or  cbase == 'c128c' then
if msg.text and msg.text:match('^%d+$') then
local data = json:decode(db:hget('bot:bcreate',msg.from.id))
local file = HTTP.request('http://www.barcodes4.me/barcode/'..data.cbase..'/'..msg.text..'.png?'..data.size..'&IsTextDrawn=1&IsBorderDrawn='..data.boarder)
io.open('./images/bc.png','w'):write(file):close()
api.sendPhoto(msg.chat.id,'./images/bc.png','@uc_bcbot',msg.message_id)
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,nil, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif msg.text then
local data = json:decode(db:hget('bot:bcreate',msg.from.id))
local file = HTTP.request('http://www.barcodes4.me/barcode/'..data.cbase..'/'..msg.text..'.png?'..data.size..'&IsTextDrawn=1&IsBorderDrawn='..data.boarder)
io.open('./images/bc.png','w'):write(file):close()
api.sendPhoto(msg.chat.id,'./images/bc.png','@uc_bcbot',msg.message_id)
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,nil, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end

elseif setup == 'brmain' then
local aln = {'Code 2of5 (Numic)','Code 128C (Numic)','Code 128B','Code 128A','Code 39'}
local al = {'i2of5','c128c','c128b','c128a','c39'}
local suc = 0
for i,v in pairs(aln) do
if msg.text == v then
db:hset('bot:bcreate',msg.from.id,json:encode({cbase=al[i]}))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'Small','Medium'}
local rw3_texts = {'Large','Extra'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts)}
api.sendMessage(msg.chat.id, 'Select *Image Size:*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'br1')
suc = 1
end
end
if suc == 0 then
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif setup == 'qrmain' then
if msg.text == 'Telegram Contact QR Code' then
if msg.from.username then
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'@'..msg.from.username}
local rw3_texts = {'Other'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts)}
api.sendMessage(msg.chat.id, 'Select a Key:', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'qrcontact1')
else
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rows ={kmakerow(rw1_texts)}
api.sendMessage(msg.chat.id, 'Send target *Username*\n`example: @UmbrellaCopy`', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'qrcontact2')
end
elseif msg.text == 'Telegram Sticker' then
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'0','1'}
local rw3_texts = {'2','3'}
local rw4_texts = {'4','5'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts),kmakerow(rw4_texts)}
api.sendMessage(msg.chat.id, 'Select *Image Border:*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'sticker1')

elseif msg.text == 'JPG Image' or msg.text == 'PNG Image' then
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'Small','Medium'}
local rw3_texts = {'Large','Extra'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts)}
api.sendMessage(msg.chat.id, 'Select *Image Size:*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'image1')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif setup == 'qrcontact1' then
if msg.text == '@'..msg.from.username and msg.from.username then
api.sendPhoto(msg.chat.id,api.downloadFile('http://api.qrserver.com/v1/create-qr-code/?data=https://telegram.me/'..msg.from.username..'&color=0FA0EF&size=512x512','./images/username.png'),'@uc_bcbot',msg.message_id)
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,nil, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')
elseif msg.text == 'Other' then
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rows ={kmakerow(rw1_texts)}
api.sendMessage(msg.chat.id, 'Send target *Username*\n`example: @UmbrellaCopy`', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'qrcontact2')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif setup == 'qrcontact2' then
if msg.text and msg.text:match('^@[a-zA-Z0-9_]*$') then
api.sendPhoto(msg.chat.id,api.downloadFile('http://api.qrserver.com/v1/create-qr-code/?data=https://telegram.me/'..msg.text:gsub('^@','')..'&color=0FA0EF&size=512x512','./images/username.png'),'@uc_bcbot',msg.message_id)
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,nil, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif setup == 'sticker1' then
local suc = 0
for i=0,5 do
if msg.text == tostring(i) then
db:hset('bot:screate',msg.from.id,json:encode({boarder=i}))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'White','Gray'}
local rw3_texts = {'Green','Blue'}
local rw4_texts = {'Yellow','Red'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts),kmakerow(rw4_texts)}
api.sendMessage(msg.chat.id, 'Select *Background Color* from *Keyboard* or send *HEX Codes:*\n`example: #afafaf`', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'sticker2')
suc = 1
end
end
if suc == 0 then
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif setup == 'sticker2' then
local ctable = {'White','Gray','Green','Blue','Yellow','Red'}
local htable = {'fff','AAAAAA','AAFFAA','AAABFE','FFFFA9','FEA9AC'}
local suc = 0
for i,v in pairs(ctable) do
if msg.text == v then
local mytable = json:decode(db:hget('bot:screate',msg.from.id))
mytable.bgcolor=htable[i]
db:hset('bot:screate',msg.from.id,json:encode(mytable))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'Black','Gray'}
local rw3_texts = {'Green','Blue'}
local rw4_texts = {'Yellow','Red'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts),kmakerow(rw4_texts)}
api.sendMessage(msg.chat.id, 'Select *Texture Color* from *Keyboard* or send *HEX Codes:*\n`example: #cc0030`', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'sticker3')
suc = 1
end
end
if suc == 0 then
if msg.text and (msg.text:match('^#([A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])$') or msg.text:match('^#([A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])$')) then
local mytable = json:decode(db:hget('bot:screate',msg.from.id))
mytable.bgcolor=msg.text:gsub('^#','')
db:hset('bot:screate',msg.from.id,json:encode(mytable))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'Black','Gray'}
local rw3_texts = {'Green','Blue'}
local rw4_texts = {'Yellow','Red'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts),kmakerow(rw4_texts)}
api.sendMessage(msg.chat.id, 'Select *Texture Color* from *Keyboard* or send *HEX Codes:*\n`example: #cc0030`', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'sticker3')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
end
elseif setup == 'sticker3' then
local ctable = {'Black','Gray','Green','Blue','Yellow','Red'}
local htable = {'000','505050','00FF01','0000FE','FFFF00','FE0000'}
local suc = 0
for i,v in pairs(ctable) do
if msg.text == v then
local mytable = json:decode(db:hget('bot:screate',msg.from.id))
mytable.color=htable[i]
db:hset('bot:screate',msg.from.id,json:encode(mytable))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rows ={kmakerow(rw1_texts)}
api.sendMessage(msg.chat.id, 'Send you\'r *Text, URL & more...*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'sticker4')
suc = 1
end
end
if suc == 0 then
if msg.text and (msg.text:match('^#([A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])$') or msg.text:match('^#([A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])$')) then
local mytable = json:decode(db:hget('bot:screate',msg.from.id))
mytable.color=msg.text:gsub('^#','')
db:hset('bot:screate',msg.from.id,json:encode(mytable))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rows ={kmakerow(rw1_texts)}
api.sendMessage(msg.chat.id, 'Send you\'r *Text, URL & more...*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'sticker4')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
end
elseif setup == 'sticker4' then
local sdata = json:decode(db:hget('bot:screate',msg.from.id))
api.sendSticker(msg.chat.id,api.downloadFile('http://api.qrserver.com/v1/create-qr-code/?margin='..(tonumber(sdata.boarder) * 10)..'&color='..sdata.color..'&bgcolor='..sdata.bgcolor..'&size=512x512&data='..msg.text,'./images/sticker.png'),msg.message_id)
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,nil, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')
elseif setup == 'image1' then
local sntable = {'Small','Medium','Large','Extra'}
local stable = {'50x50','200x200','500x500','1000x1000'}
local suc = 0
for i,v in pairs(sntable) do
if msg.text == v then
db:hset('bot:screate',msg.from.id,json:encode({size=stable[i]}))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'0','1'}
local rw3_texts = {'2','3'}
local rw4_texts = {'4','5'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts),kmakerow(rw4_texts)}
api.sendMessage(msg.chat.id, 'Select *Image Border:*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'image2')
suc = 1
end
end
if suc == 0 then
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif setup == 'image2' then
local suc = 0
for i=0,5 do
if msg.text == tostring(i) then
local mytable = json:decode(db:hget('bot:screate',msg.from.id))
mytable.boarder=i
db:hset('bot:screate',msg.from.id,json:encode(mytable))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'White','Gray'}
local rw3_texts = {'Green','Blue'}
local rw4_texts = {'Yellow','Red'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts),kmakerow(rw4_texts)}
api.sendMessage(msg.chat.id, 'Select *Background Color* from *Keyboard* or send *HEX Codes:*\n`example: #afafaf`', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'image3')
suc = 1
end
end
if suc == 0 then
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
elseif setup == 'image3' then
local ctable = {'White','Gray','Green','Blue','Yellow','Red'}
local htable = {'fff','AAAAAA','AAFFAA','AAABFE','FFFFA9','FEA9AC'}
local suc = 0
for i,v in pairs(ctable) do
if msg.text == v then
local mytable = json:decode(db:hget('bot:screate',msg.from.id))
mytable.bgcolor=htable[i]
db:hset('bot:screate',msg.from.id,json:encode(mytable))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'Black','Gray'}
local rw3_texts = {'Green','Blue'}
local rw4_texts = {'Yellow','Red'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts),kmakerow(rw4_texts)}
api.sendMessage(msg.chat.id, 'Select *Texture Color* from *Keyboard* or send *HEX Codes:*\n`example: #cc0030`', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'image4')
suc = 1
end
end
if suc == 0 then
if msg.text and (msg.text:match('^#([A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])$') or msg.text:match('^#([A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])$')) then
local mytable = json:decode(db:hget('bot:screate',msg.from.id))
mytable.bgcolor=msg.text:gsub('^#','')
db:hset('bot:screate',msg.from.id,json:encode(mytable))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rw2_texts = {'Black','Gray'}
local rw3_texts = {'Green','Blue'}
local rw4_texts = {'Yellow','Red'}
local rows ={kmakerow(rw1_texts),kmakerow(rw2_texts),kmakerow(rw3_texts),kmakerow(rw4_texts)}
api.sendMessage(msg.chat.id, 'Select *Texture Color* from *Keyboard* or send *HEX Codes:*\n`example: #cc0030`', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'image4')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
end

elseif setup == 'image4' then
local ctable = {'Black','Gray','Green','Blue','Yellow','Red'}
local htable = {'000','505050','00FF01','0000FE','FFFF00','FE0000'}
local suc = 0
for i,v in pairs(ctable) do
if msg.text == v then
local mytable = json:decode(db:hget('bot:screate',msg.from.id))
mytable.color=htable[i]
db:hset('bot:screate',msg.from.id,json:encode(mytable))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rows ={kmakerow(rw1_texts)}
api.sendMessage(msg.chat.id, 'Send you\'r *Text, URL & more...*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'image5')
suc = 1
end
end
if suc == 0 then
if msg.text and (msg.text:match('^#([A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])$') or msg.text:match('^#([A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])$')) then
local mytable = json:decode(db:hget('bot:screate',msg.from.id))
mytable.color=msg.text:gsub('^#','')
db:hset('bot:screate',msg.from.id,json:encode(mytable))
local rw1_texts = {'🔲🔳\n🔳🔲'}
local rows ={kmakerow(rw1_texts)}
api.sendMessage(msg.chat.id, 'Send you\'r *Text, URL & more...*', true, true,msg.message_id, true,kmake(rows))
db:hset('bot:waiting',msg.from.id,'image5')
else
api.sendMessage(msg.chat.id, 'Input is *False*', true, true,msg.message_id, true)
end
end



elseif setup == 'image5' then
local sdata = json:decode(db:hget('bot:screate',msg.from.id))
api.sendPhoto(msg.chat.id,api.downloadFile('http://api.qrserver.com/v1/create-qr-code/?margin='..(tonumber(sdata.boarder) * 10)..'&color='..sdata.color..'&bgcolor='..sdata.bgcolor..'&size='..sdata.size..'&data='..msg.text,'./images/image.png'),'@uc_bcbot',msg.message_id)
api.sendMessage(msg.chat.id, '*Main Menu:*', true, true,nil, true,make_menu())
db:hset('bot:waiting',msg.from.id,'main')


end
end
end
local function iaction(inline)
if inline.query == '' then
if inline.from.username then
local qresult = {{}}
qresult[1].id = '1'
 qresult[1].type = 'photo'
 qresult[1].photo_url = URL.escape('http://api.qrserver.com/v1/create-qr-code/?data=https://telegram.me/'..inline.from.username..'&color=0FA0EF&margin=15&size=512x512')
 qresult[1].thumb_url = URL.escape('http://api.qrserver.com/v1/create-qr-code/?data=https://telegram.me/'..inline.from.username..'&color=0FA0EF&margin=15&size=512x512')
 qresult[1].caption = URL.escape('QR Code: @'..inline.from.username..'  ('..inline.from.id..')\n\n@uc_bcbot')
 api.sendInline(inline.id, qresult,0)
else
local qresult = {{}}
qresult[1].id = '1'
qresult[1].type = 'article'
qresult[1].description = 'enter text for make QR code'
qresult[1].title = 'Make QR Code'
qresult[1].message_text = 'You haven\'t *Username* for make telegram QR!\n`you can enter text after this bot username (@uc_bcbot) and make QR code of you\'r text`'
qresult[1].parse_mode = 'Markdown'
api.sendInline(inline.id, qresult,0)
end
else
local qresult = {{}}
qresult[1].id = '1'
 qresult[1].type = 'photo'
 qresult[1].photo_url = URL.escape('http://api.qrserver.com/v1/create-qr-code/?data=https://telegram.me/'..inline.query..'&margin=15&size=512x512')
 qresult[1].thumb_url = URL.escape('http://api.qrserver.com/v1/create-qr-code/?data=https://telegram.me/'..inline.query..'&margin=15&size=512x512')
 qresult[1].caption = URL.escape('@uc_bcbot')
 api.sendInline(inline.id, qresult,0)
end
end


return {
action = action,
iaction = iaction
}