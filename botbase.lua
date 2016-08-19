-- @BCbot Copy By @jan_123 thanks to butler team
HTTP = require('socket.http')
HTTPS = require('ssl.https')
ssl = require 'ssl'
URL = require('socket.url')
db = (loadfile "./libs/redis.lua")()
serpent = require('serpent')
ltn12 = require ('ltn12')
json = (loadfile "./libs/JSON.lua")()
version = 'beta'
bot_api_key = '222136994:AAGkGni6NWoCgG2qlzCYgSm7MkFYGVPpSgI' -- set token
bot_sudo = 228347356 -- set sudo
--functions
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
function vtext(value)
  return serpent.block(value, {comment=false})
end
function match_pattern(pattern, text)
  if text then
    local matches = {}
    matches = { string.match(text, pattern) }
    if next(matches) then
    	return matches
    end
  end
end
bot_init = function(on_reload) -- The function run when the bot is started or reloaded.
	if bot_api_key == '' or bot_sudo == 0 then
		print('API KEY Or Sudo MISSING!')
		return
	end
	print('Loading API functions table...')
	api = dofile('methods.lua')
	bot = nil
	while not bot do -- Get bot info and retry if unable to connect.
		bot = api.getMe()
	end
	bot = bot.result

	 
	bot_base = dofile('bot.lua')
	print('BOT RUNNING: @'..bot.username .. ', AKA ' .. bot.first_name ..' ('..bot.id..')')
	print('BOT Sudo: '..bot_sudo)
	if not on_reload then
		api.sendMessage(bot_sudo, '*Bot started!*\n_'..os.date('On %A, %d %B %Y\nAt %X')..'_', true)
	end

	last_update = last_update or 0 -- Set loop variables: Update offset,
	is_started = true -- whether the bot should be running or not.

end
local function get_from(msg)
	local user = msg.from.first_name
	if msg.from.last_name then
		user = user..' '..msg.from.last_name
	end
	if msg.from.username then
		user = user..' [@'..msg.from.username..']'
	end
	user = user..' ('..msg.from.id..')'
	return user
end

local function get_what(msg)
	if msg.sticker then
		return 'sticker'
	elseif msg.photo then
		return 'photo'
	elseif msg.document then
		return 'document'
	elseif msg.audio then
		return 'audio'
	elseif msg.video then
		return 'video'
	elseif msg.voice then
		return 'voice'
	elseif msg.contact then
		return 'contact'
	elseif msg.location then
		return 'location'
	elseif msg.text then
		return 'text'
	else
		return 'service message'
	end
end
on_inline_receive = function(inline)
	if not inline then
		api.sendMessage(bot_sudo, 'Shit, a loop without inline!')
		return
	end
	if bot_base.iaction then
	local success, result = pcall(function()
	return bot_base.iaction(inline)
	end)
	if not success then
    api.sendMessage(bot_sudo, '#inline_err\nDesc : '..result..'\nInline : '..vtext(inline))
	return
	end
	end
	end
on_msg_receive = function(msg) -- The fn run whenever a message is received.
	--vardump(msg)
	if not msg then
		api.sendMessage(bot_sudo, 'Shit, a loop without msg!')
		return
	end
	if bot_base.action then
	local success, result = pcall(function()
	return bot_base.action(msg)
	end)
	if not success then
	api.sendReply(msg, '*This is a bug!*\nPlease report the problem with `@admin <bug>` :)', true)
    api.sendMessage(bot_sudo, '#msg_err\nDesc : '..result..'\nMsg : '..vtext(msg))
	return
	end
	end
	end
local function rethink_reply(msg)
	msg.reply = msg.reply_to_message
	return on_msg_receive(msg)
end
---------WHEN THE BOT IS STARTED FROM THE TERMINAL, THIS IS THE FIRST FUNCTION HE FOUNDS

bot_init() -- Actually start the script. Run the bot_init function.
while is_started do -- Start a loop while the bot should be running.
	local res = api.getUpdates(last_update+1) -- Get the latest updates!
	if res then
		for i,msg in ipairs(res.result) do -- Go through every new message.
			last_update = msg.update_id
			if msg.message then
				if msg.message.reply_to_message then
					rethink_reply(msg.message)
				else
					on_msg_receive(msg.message)
				end
			elseif msg.inline_query then
		on_inline_receive(msg.inline_query)
	end
		end
	else
		print('Connection error')
	end
end

print('Halted.')
