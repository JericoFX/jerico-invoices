local QBCore = exports["qb-core"]:GetCoreObject()
local PlayerData = nil
local random = math.random
local function uuid()
    local template = 'xyxyxxyx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('QBCore:Client:SetPlayerData', function(val)
    PlayerData = val
end)


RegisterCommand("createInvoice", function(source, args)
    local input = lib.inputDialog(('Factura: %s'):format(PlayerData.job.label), {
        { type = 'input', label = "Bill's ID", description = 'ID of the bill', disabled = true, default = uuid() },
        {
            type = "input", label = "Character ID", description = "Bill Target", required = true
        },
        {
            type = "number", label = "Bill amount", description = "Amount to pay", required = true, min = 1
        },
        {
            type = "select",
            label = "Type of payment",
            required = true,
            options = {
                {
                    label = "Cash", value = "cash"
                },
                {
                    label = "Bank", value = "bank"
                }
            },
            default = "cash"
        },
        {
            type = "textarea",
            label = "Additional Information",
            description =
            "Any additional information you want to add to the bill",
        }
    })
    if not input then return end
    TriggerServerEvent("fx-factura::server::crearFactura", input, PlayerData.job.name)
end, false)


RegisterNetEvent("fx-factura::client::enviarFacturaACliente", function(data, job, fullname, citizenid, _job)
    if source == "" then return end
    local confirmacion = lib.alertDialog({
        header = ("Bill:%s"):format(data[1]),
        overflow = true,
        centered = true,
        content = ("### A bill was sended  \n From Job: **%s**  \n Name: **%s**  \n Amount: **$%s**  \n Payment Type: **%s**  \n Additional Info: **%s**")
            :format(job, fullname, data[3], data[4] == "cash" and "Cash" or "Bank", data[5] or "No additional info"),
    })
    if confirmacion == "confirm" then
        local await = lib.callback.await("fx-factura::server::pagarFactura", false, data[4], data[3], citizenid, _job,
            data[1])
    end
end)
local function checkFactura(id)
    local check = lib.callback.await("fx-factura::server::checkForBill", false, id, PlayerData.job.name)
    if not check then
        return
    end
    lib.registerContext({
        id = "check_factura_" .. PlayerData.job.name,
        title = "Bills to pay",
        options = check
    })
    lib.showContext("check_factura_" .. PlayerData.job.name)
end
RegisterCommand("checkInvoice", function(source, args)
    local input = lib.inputDialog("Add Id", {
        {
            type = "input", label = "Player ID", required = true
        }
    })
    if not input then return end
    checkFactura(input[1])
end, false)

RegisterNetEvent("fx-factura::client::sendFacturaAgain", function(data)
    local input = {}
    input[1] = data.uid
    input[2] = data.id
    input[3] = data.monto
    input[4] = data.retirar
    input[5] = data.agregado
    TriggerServerEvent("fx-factura::server::crearFactura", input, PlayerData.job.name)
end)
