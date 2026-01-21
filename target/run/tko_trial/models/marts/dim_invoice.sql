
        

    
        create or replace dynamic table MEDIADMSTAGING.marts.dim_invoice
    target_lag = '1 hour'
    warehouse = COMPUTE_WH
    refresh_mode = AUTO

    initialize = ON_CREATE

    

    

    

    as (
        

select * from MEDIADMSTAGING.intermediate.int_dim_invoice
    )

    


    