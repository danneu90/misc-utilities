function instrcloseall()
%myctrl.instrcloseall()
%
% Closes output of instrfindall if it is not empty.

    instr = instrfindall;
    
    if ~isempty(instr)
        fclose(instr);
    end
    
end