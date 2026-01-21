
  create or replace   view MEDIADMSTAGING.intermediate.int_customer_airlines_agg
  
  
  
  
  as (
    

SELECT
    C.Id as CustomerId,
    -- Address Airlines
    (SELECT LISTAGG(DISTINCT R.Description, ', ') WITHIN GROUP (ORDER BY R.Description)
     FROM MediaDMStaging.dbo.CustomerAddress CA
     JOIN MediaDMStaging.dbo.CustomerAddressAirline CAA ON CA.Id = CAA.CustomerAddressId
     JOIN MediaDMStaging.dbo.Rights_lu R ON CAA.AirlineId = R.Id
     WHERE CA.CustomerId = C.Id
    ) as CustomerAddressAirline,
    
    -- In Flight Defaults Airline
    (SELECT LISTAGG(DISTINCT R.Description, ', ') WITHIN GROUP (ORDER BY R.Description)
     FROM MediaDMStaging.dbo.CustomerInFlightDefaults cifd
     JOIN MediaDMStaging.dbo.CustomerInFlightDefaultsAirline cifda ON cifd.Id = cifda.CustomerInFlightDefaultsId
     JOIN MediaDMStaging.dbo.Rights_lu R ON R.Id = cifda.AirlineId
     WHERE cifd.CustomerId = C.Id
    ) as CustomerInFlightDefaultsAirline,

    -- In Flight Defaults Currency
    (SELECT LISTAGG(DISTINCT clu.Code, ', ') WITHIN GROUP (ORDER BY clu.Code)
     FROM MediaDMStaging.dbo.CustomerInFlightDefaults cifd
     JOIN MediaDMStaging.dbo.CustomerInFlightDefaultsAirline cifda ON cifd.Id = cifda.CustomerInFlightDefaultsId
     JOIN MediaDMStaging.dbo.Currency_lu clu ON clu.Id = cifd.CurrencyId
     WHERE cifd.CustomerId = C.Id
    ) as CustomerInFlightDefaultsCurrency,

    -- In Flight Rights Airline
    (SELECT LISTAGG(DISTINCT R.Description, ', ') WITHIN GROUP (ORDER BY R.Description)
     FROM MediaDMStaging.dbo.CustomerInFlightRights cifr
     JOIN MediaDMStaging.dbo.CustomerInFlightRightsAirline cifra ON cifr.Id = cifra.CustomerInFlightRightsId
     JOIN MediaDMStaging.dbo.Rights_lu R ON R.Id = cifra.AirlineId
     WHERE cifr.CustomerId = C.Id
    ) as CustomerInFlightRightsAirline,

    -- Contact Airlines
    (SELECT LISTAGG(DISTINCT R.Description, ', ') WITHIN GROUP (ORDER BY R.Description)
     FROM MediaDMStaging.dbo.CustomerContact CC
     JOIN MediaDMStaging.dbo.CustomerContactAirline CCA ON CC.Id = CCA.CustomerContactId
     JOIN MediaDMStaging.dbo.Rights_lu R ON CCA.AirlineId = R.Id
     WHERE CC.CustomerId = C.Id
    ) as CustomerContactAirline

FROM MediaDMStaging.dbo.Customer C
  );

