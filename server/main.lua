local QBCore = exports["qb-core"]:GetCoreObject()

RegisterNetEvent("fx-factura::server::crearFactura", function(data, job)
    if not data and not data[2] then return end
    local src <const> = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(tonumber(data[2]))
    if src == tonumber(data[2]) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = "ERROR",
            description = "You cant send a bill to yourself",
            type = 'error', --'inform' or 'error' or 'success'or 'warning'
            duration = 5000
        })
        return
    end
    if not Target then
        TriggerClientEvent('ox_lib:notify', src, {
            title = "ERROR",
            description = "Character not found",
            type = 'error', --'inform' or 'error' or 'success'or 'warning'
            duration = 5000
        })
        return
    end
    if not Player.PlayerData.job.name == job then
        TriggerClientEvent('ox_lib:notify', src, {
            title = "ERROR",
            description = ("The bill: %s  \n was sended from the job: %s  \n but the actual job is: %s"):format(
                data[1], job, Player.PlayerData.job.name),
            type = 'error', --'inform' or 'error' or 'success'or 'warning'
            duration = 5000
        })
        return
    end
    local fullname = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    if Player.PlayerData.job.type == "leo" and Target.PlayerData.money[data[4]] <= data[3] then
        MySQL.insert(
            "INSERT INTO fx_facturas (uid,citizenid,monto,retirar,agregado,enviadopor,trabajo) VALUES(?,?,?,?,?,?,?)", {
                data[1],
                Target.PlayerData.citizenid,
                data[3],
                data[4],
                data[5],
                Player.PlayerData.citizenid,
                job
            }, function(cb)

            end)
    end
    if not (Target.PlayerData.money[data[4]] >= data[3]) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = "ERROR",
            description = "The player doesnt have enough money",
            type = 'error', --'inform' or 'error' or 'success'or 'warning'
            duration = 5000
        })
        return
    end

    TriggerClientEvent("fx-factura::client::enviarFacturaACliente", data[2], data, Player.PlayerData.job.label, fullname,
        Player.PlayerData.citizenid, job)
end)

lib.callback.register("fx-factura::server::pagarFactura", function(source, donde, monto, citizenid, job, uid)
    if not source then
        print("Error no source")
        return
    end
    if not citizenid then
        print("No se envio un citizenid Correcto")
        return
    end
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if not Player.PlayerData.job.name == job then
        DropPlayer(source, "Intentando exploitear HDP")
    end
    local Target = QBCore.Functions.GetPlayer(source)
    if not (Target.PlayerData.money[donde] >= monto) then
        TriggerClientEvent('ox_lib:notify', Player.PlayerData.source or Player.source, {
            title = "ERROR",
            description = "The player doesnt have enough money",
            type = 'error', --'inform' or 'error' or 'success'or 'warning'
            duration = 5000
        })
        return false
    end
    TriggerClientEvent('ox_lib:notify', Player.PlayerData.source or Player.source, {
        title = "Payment Bill",
        description = ("The Player: %s  \n **payed the bill**"):format(Target.PlayerData.charinfo.firstname ..
            " " .. Target.PlayerData.charinfo.lastname),
        type = 'success', --'inform' or 'error' or 'success'or 'warning'
        duration = 5000
    })
    TriggerClientEvent('ox_lib:notify', source, {
        title = "Payment Bill",
        description = "You payed the bill",
        type = 'success', --'inform' or 'error' or 'success'or 'warning'
        duration = 5000
    })
    Target.Functions.RemoveMoney(donde, monto)
    Player.Functions.AddMoney("cash", monto * 0.20)
    TriggerClientEvent('ox_lib:notify', Player.PlayerData.source or Player.source, {
        title = "PAGO DE FACTURA",
        description = " You received 20% of the invoice in the form of a bonus.  \n" .. "$" .. monto * 0.20,
        type = 'success', --'inform' or 'error' or 'success'or 'warning'
        duration = 5000
    })
    exports["qb-management"]:AddMoney(Player.PlayerData.job.name, monto)
    if Player.PlayerData.job.type == "leo" then
        MySQL.prepare.await("DELETE FROM fx_facturas WHERE uid = ? and citizenid = ?",
            { uid, Target.PlayerData.citizenid })
    end
    return true
end)

lib.callback.register("fx-factura::server::checkForBill", function(source, id, jobname)
    local options = {}
    local Player = QBCore.Functions.GetPlayer(source)
    local Target = QBCore.Functions.GetPlayer(tonumber(id))
    if not Player.PlayerData.job.name == jobname then
        TriggerClientEvent('ox_lib:notify', source, {
            title = "ERROR",
            description = "You cant check the bills for this job",
            type = 'error', --'inform' or 'error' or 'success'or 'warning'
            duration = 5000
        })
        return false
    end
    local variable = MySQL.prepare.await("SELECT * FROM fx_facturas WHERE citizenid = ? and trabajo = ?",
        { Target.PlayerData.citizenid, jobname })
    if variable and table.type(variable) == "array" and #variable >= 1 then
        local tabla = variable
        for i = 1, #variable do
            local el = tabla[i]
            options[i] = {
                title = "Bill N°: " .. el.uid,
                description = ("Amount **$%s**"):format(el.monto),
                event = "fx-factura::client::sendFacturaAgain",
                args = { id = id, uid = el.uid, citizenid = el.citizend, monto = el.monto, retirar = el.retirar, agregado = el.agregado, enviadopor = el.enviadopor, trabajo = el.trabajo }
            }
        end
    elseif variable and table.type(variable) == "hash" then
        options[#options + 1] = {
            title = "Bill N°: " .. variable.uid,
            description = ("Bill amount $%s"):format(variable.monto),
            event = "fx-factura::client::sendFacturaAgain",
            args = { id = id, uid = variable.uid, citizenid = variable.citizend, monto = variable.monto, retirar = variable.retirar, agregado = variable.agregado, enviadopor = variable.enviadopor, trabajo = variable.trabajo }
        }
    else
        options[#options + 1] = {
            title = "No bills found",
        }
    end
    return options
end)
