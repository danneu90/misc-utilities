function val_out = nan_to_null( val_in )
    
    assert(isnumeric(val_in),'Input type must be numeric!')
    if isnan(val_in)
        val_out = "NULL";
    else
        val_out = val_in;
    end

end