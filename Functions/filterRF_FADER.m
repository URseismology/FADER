function [flted] = filterRF_FADER(rrfAmpArray,timeAxisHD,tlag,r0,smoothopt)
% function [flted] = filterRF_FADER(rrfAmpArray,timeAxisHD,tlag,r0)
%
% Author: Evan Zhang
%
% Filter receiver functions [rrfAmpArray, each row is one trace] with given
% parameters [tlag] and [r0].
% [tlag] and [r0] can be a single value (apply the same value to all
% traces) or a vector (same length as size(rrfAmpArray,1)).
% [timeAxisHD] contains the time vector.

clear i;

% frequency setup
Dt = timeAxisHD(2) - timeAxisHD(1);
N = length(timeAxisHD);

fmax = 1/(2.0*Dt);
df = fmax/(N/2);
f = df*[0:N/2,-N/2+1:-1]';
Nf = N/2+1;
dw = 2.0*pi*df;
w = dw*[0:N/2,-N/2+1:-1]';


flted = zeros(size(rrfAmpArray,1),size(rrfAmpArray,2));
for iRF = 1:size(rrfAmpArray,1)
    
    % tlag & r0
    if length(tlag) > 1
        thistlag = tlag(iRF);
    else
        thistlag = tlag;
    end
    
    if length(r0) > 1
        thisr0 = r0(iRF);
    else
        thisr0 = r0;
    end
    
    % build the filter
    Dall = rrfAmpArray(iRF,:);
    Dall = Dall';
    flt = (1+thisr0*exp(-1i*w*thistlag));
    flted(iRF,:) = real( ifft(fft(Dall).*flt) );
    flted(iRF,:) = flted(iRF,:) ./ max(flted(iRF,:));
    
end

if smoothopt
    flted = smoothdata(flted,2);
end

end

