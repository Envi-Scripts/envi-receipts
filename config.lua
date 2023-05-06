Config = {}

Config.Framework = 'esx'
-- esx or qb   (esx requires ox_inventory, qb requires qb-inventory)    -- Please submit a PR if you have a different inventory supported.
Config.UseApGovernmentTax = true
 -- If you have ap-government installed, set this to true. If not, set it to false.
Config.TaxPercentage = 0.1
 -- 0.1 = 10% tax (ONLY if UseApGovernmentTax is set to false)

 
function Notify(header, message, type, time)
    lib.notify({
        id = 'terminal',
        title = header,
        description = message,
        position = 'top',
        style = {
            backgroundColor = '#141517',
            color = '#909296'
        },
        icon = 'usd',
        iconColor = '#118C4F',
        length = time
    }) 
end
