function [HITind,MISSind,ABOind,HANGind] = getAFCResponseLegend(bitmask)
%Custom function for SanesLab epsych
%
%This function updates parameters during GUI runtime for AFC

%Written by JY & NP 10.04.2018
N       =   length(bitmask);
HITind  =   zeros(N,1);
MISSind =   zeros(N,1);
ABOind  =   zeros(N,1);
HANGind =   zeros(N,1);

for i=1:N
    
    %---HIT---%
    %-Trial Type 0 = Food Tray Right-%
    if bitmask(i) == 165
        HITind(i,1) = 1;
    end
    %-Trial Type 1 = Food Tray Left-%
    if bitmask(i) == 201
        HITind(i,1) = 1;
    end
    
    %---MISS---%
    %-Trial Type 0 = Food Tray Left-%
    if bitmask(i) == 198
        MISSind(i,1) = 1;
    end
    %-Trial Type 1 = Food Tray Right-%
    if bitmask(i) == 170
        MISSind(i,1) = 1;
    end
    
    %---HANG (No Response) "General Miss" (NP)---%
    %-Trial Type 0-%
    if bitmask(i) == 4
        HANGind(i,1) = 1;
    end
    %-Trial Type 1-%
    if bitmask(i) == 8
        HANGind(i,1) = 1;
    end
    
    %---ABORT---%
    %-Trial Type 0-%
    if bitmask(i) == 148
        ABOind(i,1) = 1;
    end
    %-Trial Type 1-%
    if bitmask(i) == 152
        ABOind(i,1) = 1;
    end
    
end

HITind = logical(HITind);
MISSind = logical (MISSind); 
ABOind = logical (ABOind);
HANGind = logical (HANGind);



