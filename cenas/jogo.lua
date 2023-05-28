
local composer = require('composer')

local cena = composer.newScene()

function cena:create(event)
	local grupoJogo = self.view

	local x = display.contentWidth
	local y = display.contentHeight
	local t = (x + y) / 2

	-- DECLARACAO DOS GRUPOS
	local fundoG = display.newGroup( )
	local jogoG = display.newGroup( )
	local GUI = display.newGroup( )
	grupoJogo:insert( fundoG )
	grupoJogo:insert( jogoG )
	grupoJogo:insert( GUI )


	-- DECLARACAO DA FISICA
	local physics = require('physics')
	physics.start()
	physics.setGravity( 0, 100 )
	physics.setDrawMode( 'normal' )

	-- DECLARACAO DAS VARIAVEIS
	local pontos = 0
	local morto = false
	local canos = {}
	local sensores = {}
	local fonte = native.newFont( 'recursos/fontes/font.ttf' )
	local audioMorte = audio.loadSound( 'recursos/audio/die.mp3' )
	local audioClick = audio.loadSound( 'recursos/audio/swoosh.mp3' )
	local audioPonto = audio.loadSound( 'recursos/audio/point.mp3' )
	local audioTransicao = audio.loadSound( 'recursos/audio/wing.mp3' )

	-- RANDOMIZAÇÃO DAS IMAGENS
	local jogadorImagem = {
		'recursos/imagens/yellowbird-downflap.png',
		'recursos/imagens/redbird-downflap.png',
		'recursos/imagens/bluebird-downflap.png'
	}
	local jogadorRandomico = math.random( 1,3 )

	
	local fundoImagem = {
		'recursos/imagens/background-day.png',
		'recursos/imagens/background-night.png'
	}
	local fundoRandomico = math.random( 1,2 )


	local canoImagem = {
		'recursos/imagens/pipe-green.png',
		'recursos/imagens/pipe-red.png',
	}
	local canoRandomico = math.random( 1,2 )


	-- DECLARACAO DOS OBJETOS
	local fundo = display.newImageRect(fundoG, fundoImagem[fundoRandomico], x, y )
	fundo.x = x*0.5
	fundo.y = y*0.5

	local fundo2 = display.newImageRect(fundoG, fundoImagem[fundoRandomico], x, y )
	fundo2.x = x*1.5
	fundo2.y = y*0.5

	local chao = display.newImageRect(jogoG, 'recursos/imagens/base.png', x, y*0.2 )
	chao.x = x*0.5
	chao.y = y*0.9
	physics.addBody(chao, 'static')
	chao.id = 'chaoID'

	local chao2 = display.newImageRect(jogoG, 'recursos/imagens/base.png', x, y*0.2 )
	chao2.x = x*1.5
	chao2.y = y*0.9
	physics.addBody(chao2, 'static')
	chao2.id = 'chao2ID'

	local jogador = display.newImageRect(jogoG, jogadorImagem[jogadorRandomico], t*0.1, t*0.1 )
	jogador.x = x*0.25
	jogador.y = y*0.2
	physics.addBody(jogador, 'dynamic', {radius = t*0.03} )
	jogador.id = 'jogadorID'
	jogador.rotation = 20

	local textoPontos = display.newText(GUI, pontos, x*0.5, y*0.1, fonte, t*0.17 )


	-- DECLARACAO DAS FUNCOES
	function pular( event )
		if (morto == false) then
			if (event.phase == 'began') then
				jogador:setLinearVelocity( 0, -t*0.6 )
				audio.play( audioClick )

				transition.to( jogador, {
					time = 300, rotation = -30,
					onComplete = function()
						transition.to(jogador, {
							time = 300, rotation = 20
						})
					end
				})
			end
		end
	end
	Runtime:addEventListener('touch', pular )


	function gerarMapa( )
		if (morto == false) then
			fundo.x = fundo.x - 5
			fundo2.x = fundo2.x - 5

			if (fundo.x <= -x*0.5) then
				fundo.x = x*1.5
			elseif (fundo2.x <= -x*0.5) then
				fundo2.x = x*1.5
			end

			chao.x = chao.x - 5
			chao2.x = chao2.x - 5

			if (chao.x <= -x*0.5) then
				chao.x = x*1.5
			elseif (chao2.x <= -x*0.5) then
				chao2.x = x*1.5
			end
		end
	end
	Runtime:addEventListener( 'enterFrame', gerarMapa )

	function addObstaculo( )
		if (morto == false) then
			
			local canoBaixo = display.newImageRect(jogoG, 	canoImagem[canoRandomico], x*0.2, y*0.8 )
			canoBaixo.x = x*1.3
			canoBaixo.y = math.random(y*0.7, y*1.15)
			physics.addBody(canoBaixo, 'static')
			canoBaixo.id = 'canoBaixoID'
			table.insert( canos, canoBaixo )

			local canoCima = display.newImageRect(jogoG, 	canoImagem[canoRandomico], x*0.2, y*0.8 )
			canoCima.x = canoBaixo.x
			canoCima.y = canoBaixo.y - canoBaixo.height*1.22
			canoCima.rotation = 180
			physics.addBody(canoCima, 'static')
			canoCima.id = 'canoCimaID'
			table.insert( canos, canoCima )

			local sensor = display.newCircle(jogoG, canoBaixo.x, canoBaixo.y - canoBaixo.height*0.61, t*0.07 )
			physics.addBody(sensor, 'static', {radius = t*0.07})
			sensor.id = 'sensorID'
			table.insert( sensores, sensor )
			sensor.alpha = 0

			transition.to(sensor, {
				time = 4000, x = -x*0.3,
				onComplete = function(  )
					display.remove(sensor)
				end
			})

			transition.to(canoBaixo, {
				time = 4000, x = -x*0.3,
				onComplete = function(  )
					display.remove(canoBaixo)
				end
			})

			transition.to(canoCima, {
				time = 4000, x = -x*0.3,
				onComplete = function(  )
					display.remove(canoCima)
				end
			})

		end
	end
	timer.performWithDelay( 2000, addObstaculo, 0 )


	function verificaColisao(event)
		if (morto == false) then
			if (event.phase == 'began') then
				
				local objeto1 = event.object1
				local objeto2 = event.object2

				function perdeu()
					morto = true
					audio.play(audioMorte)

					local gameOver = display.newImageRect(GUI, 'recursos/imagens/gameover.png', x*0.9, y*0.15 )
					gameOver.x = x*0.5
					gameOver.y = y*0.5

					function reiniciar()
						composer.removeScene( 'cenas.jogo' )
						display.remove( jogador )
						composer.gotoScene( 'cenas.menu', {
							time = 300, effect = 'slideRight'
						} )
						audio.play(audioTransicao)
					end
					timer.performWithDelay( 3000, reiniciar, 1 )

				end

				if (objeto1.id == 'jogadorID' and objeto2.id == 'sensorID') then
					display.remove(objeto2)
					pontos = pontos + 1
					textoPontos.text = pontos
					audio.play( audioPonto )

				elseif (objeto2.id == 'jogadorID' and objeto1.id == 'sensorID') then
					display.remove(objeto1)
					pontos = pontos + 1
					textoPontos.text = pontos
					audio.play( audioPonto )


				elseif (objeto2.id == 'jogadorID' and objeto1.id =='chaoID') then
					perdeu()

				elseif (objeto2.id == 'jogadorID' and objeto1.id =='chao2ID') then
					perdeu()

				elseif (objeto2.id == 'jogadorID' and objeto1.id =='canoBaixoID') then
					perdeu()

				elseif (objeto2.id == 'jogadorID' and objeto1.id =='canoCimaID') then
					perdeu()

				end
			end
		end
	end
	Runtime:addEventListener( 'collision', verificaColisao )
	
end
cena:addEventListener( 'create', cena )
return cena