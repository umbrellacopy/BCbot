
local BASE_URL = 'https://api.telegram.org/bot' .. bot_api_key

local function sendRequest(url)
	local dat,code = HTTPS.request(url)
	
	if not dat then
	api.sendMessage(bot_sudo, '#request_err.Url : '..url..'\nDesc : Not Desc\nCode : '..code)
	return false, code 
	end
	
	local tab = json:decode(dat)
	--actually, this rarely happens
	if not tab.ok then
			api.sendMessage(bot_sudo, '#request_err.Url : '..url..'\nDesc : \n'..tab.description..'\nCode : '..tab.error_code)
		return false, tab.description
	end
	
	return tab

end

local function getMe()

	local url = BASE_URL .. '/getMe'

	return sendRequest(url)

end

local function getUpdates(offset)

	local url = BASE_URL .. '/getUpdates?timeout=20'

	if offset then
		url = url .. '&offset=' .. offset
	end

	return sendRequest(url)

end

local function rsendMessage(chat_id, text, use_markdown, disable_web_page_preview, reply_to_message_id, send_sound,keyboard)
		--print(text)
	local url = BASE_URL .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)

	url = url .. '&disable_web_page_preview=true'

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end
	
	if use_markdown then
		url = url .. '&parse_mode=Markdown'
	end
	
	if not send_sound then
		url = url..'&disable_notification=true'--messages are silent by default
	end
	if keyboard then
	url = url..'&reply_markup='..json:encode(keyboard)
	end
	local res, code = sendRequest(url)
	return res, code --return false, and the code
end
--by jan123
local function sendMessage(chat_id, text, use_markdown, disable_web_page_preview, reply_to_message_id, send_sound,key_board)
	local text_max = 4096
    local text_len = string.len(text)
    local num_msg = math.ceil(text_len / text_max)
    if num_msg <= 1 then
    return rsendMessage(chat_id, text, use_markdown, disable_web_page_preview, reply_to_message_id, send_sound,key_board)
    else
    local my_text = string.sub(text, 1, text_max)
    rsendMessage(chat_id, my_text, use_markdown, disable_web_page_preview, reply_to_message_id, send_sound,key_board)
    local rest = string.sub(text, text_max, text_len)
    return sendMessage(chat_id, rest, use_markdown, disable_web_page_preview, reply_to_message_id, send_sound,key_board)
end
end

local function sendReply(msg, text, markd, send_sound)

	return sendMessage(msg.chat.id, text, markd, msg.message_id, send_sound)

end

local function editMessageText(chat_id, message_id, text, keyboard, markdown)
	
	local url = BASE_URL .. '/editMessageText?chat_id=' .. chat_id .. '&message_id='..message_id..'&text=' .. URL.escape(text)
	
	if markdown then
		url = url .. '&parse_mode=Markdown'
	end
	
	url = url .. '&disable_web_page_preview=true'
	
	if keyboard then
		url = url..'&reply_markup='..json:encode(keyboard)
	end
	
	local res, code = sendRequest(url)
	
	return res, code --return false, and the code

end

local function answerCallbackQuery(callback_query_id, text, show_alert)
	
	local url = BASE_URL .. '/answerCallbackQuery?callback_query_id=' .. callback_query_id .. '&text=' .. URL.escape(text)
	
	if show_alert then
		url = url..'&show_alert=true'
	end
	
	return sendRequest(url)
	
end

local function sendChatAction(chat_id, action)
 -- Support actions are typing, upload_photo, record_video, upload_video, record_audio, upload_audio, upload_document, find_location

	local url = BASE_URL .. '/sendChatAction?chat_id=' .. chat_id .. '&action=' .. action
	return sendRequest(url)

end

local function sendLocation(chat_id, latitude, longitude, reply_to_message_id)

	local url = BASE_URL .. '/sendLocation?chat_id=' .. chat_id .. '&latitude=' .. latitude .. '&longitude=' .. longitude

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	return sendRequest(url)

end

local function forwardMessage(chat_id, from_chat_id, message_id)

	local url = BASE_URL .. '/forwardMessage?chat_id=' .. chat_id .. '&from_chat_id=' .. from_chat_id .. '&message_id=' .. message_id

	return sendRequest(url)
	
end

local function getFile(file_id)
	
	local url = BASE_URL .. '/getFile?file_id='..file_id
	
	return sendRequest(url)
	
end
local function downloadFile(file_patch, download_path)
  local download_file_path = download_path
  local download_file = io.open(download_file_path, "w")
    HTTPS.request{
      url = file_patch,
	  sink = ltn12.sink.file(download_file)
    }
    return download_file_path
end
----------------------------By Id-----------------------------------------

local function sendMediaId(chat_id, file_id, media, reply_to_message_id)
	local url = BASE_URL
	if media == 'voice' then
		url = url..'/sendVoice?chat_id='..chat_id..'&voice='
	elseif media == 'video' then
		url = url..'/sendVideo?chat_id='..chat_id..'&video='
	elseif media == 'photo' then
		url = url..'/sendPhoto?chat_id='..chat_id..'&photo='
	else
		return false, 'Media passed is not voice/video/photo'
	end
	
	url = url..file_id
	
	if reply_to_message_id then
		url = url..'&reply_to_message_id='..reply_to_message_id
	end
	
	return sendRequest(url)
end

local function sendPhotoId(chat_id, file_id, reply_to_message_id)
	
	local url = BASE_URL .. '/sendPhoto?chat_id=' .. chat_id .. '&photo=' .. file_id
	
	if reply_to_message_id then
		url = url..'&reply_to_message_id='..reply_to_message_id
	end

	return sendRequest(url)
	
end

local function sendDocumentId(chat_id, file_id, reply_to_message_id)
	
	local url = BASE_URL .. '/sendDocument?chat_id=' .. chat_id .. '&document=' .. file_id
	
	if reply_to_message_id then
		url = url..'&reply_to_message_id='..reply_to_message_id
	end

	return sendRequest(url)
	
end

----------------------------To curl--------------------------------------------

local function curlRequest(curl_command)
 -- Use at your own risk. Will not check for success.

	io.popen(curl_command)

end

local function sendPhoto(chat_id, photo, caption, reply_to_message_id)

	local url = BASE_URL .. '/sendPhoto'

	local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "photo=@' .. photo .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if caption then
		curl_command = curl_command .. ' --form-string "caption=' .. caption .. '"'
	end

	return curlRequest(curl_command)

end

local function sendDocument(chat_id, document, reply_to_message_id)

	local url = BASE_URL .. '/sendDocument'

	local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "document=@' .. document .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	return curlRequest(curl_command)

end

local function sendSticker(chat_id, sticker, reply_to_message_id)

	local url = BASE_URL .. '/sendSticker'

	local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "sticker=@' .. sticker .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	return curlRequest(curl_command)

end

local function sendStickerId(chat_id, file_id, reply_to_message_id)
	
	local url = BASE_URL .. '/sendSticker?chat_id=' .. chat_id .. '&sticker=' .. file_id
	
	if reply_to_message_id then
		url = url..'&reply_to_message_id='..reply_to_message_id
	end

	return sendRequest(url)
	
end

local function sendAudio(chat_id, audio, reply_to_message_id, duration, performer, title)

	local url = BASE_URL .. '/sendAudio'

	local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "audio=@' .. audio .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if duration then
		curl_command = curl_command .. ' -F "duration=' .. duration .. '"'
	end

	if performer then
		curl_command = curl_command .. ' -F "performer=' .. performer .. '"'
	end

	if title then
		curl_command = curl_command .. ' -F "title=' .. title .. '"'
	end

	return curlRequest(curl_command)

end

local function sendVideo(chat_id, video, reply_to_message_id, duration, performer, title)

	local url = BASE_URL .. '/sendVideo'

	local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "video=@' .. video .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if caption then
		curl_command = curl_command .. ' -F "caption=' .. caption .. '"'
	end

	if duration then
		curl_command = curl_command .. ' -F "duration=' .. duration .. '"'
	end

	return curlRequest(curl_command)

end

local function sendVoice(chat_id, voice, reply_to_message_id)

	local url = BASE_URL .. '/sendVoice'

	local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "voice=@' .. voice .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end

	if duration then
		curl_command = curl_command .. ' -F "duration=' .. duration .. '"'
	end

	return curlRequest(curl_command)

end
local function sendInline(inline_query_id, results, cache_time, is_personal, next_offset)
	local url = BASE_URL .. '/answerInlineQuery?inline_query_id=' .. inline_query_id ..'&results=' .. json:encode(results)
	if cache_time then
	url = url .. '&cache_time=' .. cache_time
	end
	if is_personal then
	url = url .. '&is_personal=' .. is_personal
	end
	if next_offset then
	url = url .. '&next_offset=' .. next_offset
	end
	return sendRequest(url)
end
return {
sendInline = sendInline,
	sendMessage = sendMessage,
	sendRequest = sendRequest,
	getMe = getMe,
	getUpdates = getUpdates,
	sendVoice = sendVoice,
	sendVideo = sendVideo,
	sendAudio = sendAudio,
	sendSticker = sendSticker,
	sendDocument = sendDocument,
	sendPhoto = sendPhoto,
	curlRequest = curlRequest,
	forwardMessage = forwardMessage,
	sendLocation = sendLocation,
	sendChatAction = sendChatAction,
	sendReply = sendReply,
	editMessageText = editMessageText,
	answerCallbackQuery = answerCallbackQuery,
	sendDocumentId = sendDocumentId,
	sendStickerId = sendStickerId,
	getFile = getFile,
	downloadFile = downloadFile,
	sendPhotoId = sendPhotoId,
	sendMediaId = sendMediaId
}	