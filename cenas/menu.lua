
local composer = require('composer')

local cena = composer.newScene()

function cena:create(event)
	local grupoMenu = self.view

	local x = display.contentWidth
	local y = display.contentHeight
	local t = (x + y) / 2

	local musica = audio.loadStream( 'recursos/audio/music.mp3' )
	local audioTransicao = audio.loadSound( 'recursos/audio/wing.mp3' )

	audio.play( musica, {channel = 32, onClomplete = function()
		audio.play( musica, {channel = 32} )
	end} )
	audio.setVolume( 0.5, {channel = 32} )


	local fundoImagem = {
		'recursos/imagens/background-day.png',
		'recursos/imagens/background-night.png'
	}
	local fundoRandomico = math.random( 1,2 )

	local fundo = display.newImageRect(grupoMenu, fundoImagem[fundoRandomico], x, y )
	fundo.x = x*0.5
	fundo.y = y*0.5

	local chao = display.newImageRect(grupoMenu, 'recursos/imagens/base.png', x, y*0.2 )
	chao.x = x*0.5
	chao.y = y*0.9

	local mensagem = display.newImageRect(grupoMenu,'recursos/imagens/message.png', x*0.9, y*0.9 )
	mensagem.x = x*0.5
	mensagem.y = y*0.5

	function toque(event)
		if (event.phase == 'began') then
			composer.gotoScene('cenas.jogo', {time = 500, effect = 'slideLeft'} )
			audio.play( audioTransicao )
		end
	end
	mensagem:addEventListener( 'touch', toque)


end
cena:addEventListener( 'create', cena )
return cena
