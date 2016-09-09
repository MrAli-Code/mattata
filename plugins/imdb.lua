local imdb = {}
local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local functions = require('functions')
function imdb:init(configuration)
	imdb.command = 'imdb <query>'
	imdb.triggers = functions.triggers(self.info.username, configuration.command_prefix):t('imdb', true).table
	imdb.doc = configuration.command_prefix .. 'imdb <query> \nReturns an IMDb entry.'
end
function imdb:action(msg, configuration)
	local input = functions.input(msg.text)
	if not input then
		if msg.reply_to_message and msg.reply_to_message.text then
			input = msg.reply_to_message.text
		else
			functions.send_message(self, msg.chat.id, imdb.doc, true, msg.message_id, true)
			return
		end
	end
	local api = configuration.imdb_api .. URL.escape(input)
	local raw_imdb_result, res = HTTP.request(api)
	if res ~= 200 then
		functions.send_reply(self, msg, configuration.errors.connection)
		return
	end
	local decoded_imdb_result = JSON.decode(raw_imdb_result)
	if decoded_imdb_result.Response ~= 'True' then
		functions.send_reply(self, msg, configuration.errors.results)
		return
	end
	local output = '*' .. decoded_imdb_result.Title .. ' ('.. decoded_imdb_result.Year ..')*\n'
	output = output .. decoded_imdb_result.imdbRating ..'/10 | '.. decoded_imdb_result.Runtime ..' | '.. decoded_imdb_result.Genre ..'\n'
	output = output .. '_' .. decoded_imdb_result.Plot .. '_\n'
	output = output .. '[Read more.](http://imdb.com/title/' .. decoded_imdb_result.imdbID .. ')'
	functions.send_message(self, msg.chat.id, output, true, nil, true)
end
return imdb