function [cc,rlgpsd] = cceps_man(tvec, dvec)
% function [cc,rlgpsd] = cceps_man(tvec, dvec)
%
% Author: Evan Zhang
%
% Perform cepstrum analysis manually with high-pass liftering on the log
% spectrum.


%% compute power spectra


% generic t/f setup

N = length(tvec);
Dt = tvec(2) - tvec(1);
srate = 1.0 / Dt;

t = Dt*[0:N-1]';
tmax = Dt*(N-1);
fmax = 1/(2.0*Dt);
Df = fmax/(N/2);
f = Df*[0:N/2,-N/2+1:-1]';
Nf = floor(N/2)+1;

sratef = 1.0/Df;

% qmax = 1/(2.0*Df);
% Dq = qmax/(Nf/2);
% q = Dq*[0:Nf/2,-Nf/2+1:-1]';
% Nq = floor(Nf/2)+1;

%% simple version

psd = fft(dvec);
lgpsd = log(abs(psd));

[ah,nd] = rcunwrap(angle(psd));
logh = log(abs(psd))+1i*ah;
co = [0.1 0.9/(2.0*Df)]; % up to 0.9*Nyquist

% high pass liftering
% logh = BandPassButterFilter(logh,sratef/2,co(1),co(2));
logh = highpass(logh,1,sratef);
% lgpsd = BandPassButterFilter(lgpsd,sratef/2,co(1),co(2));

% Hamming filter
% W=0.54-0.46*cos(2*pi*[0:length(logh)-1]'/(length(logh)-1)); 
% logh = W' .* logh;

cc = real(ifft(logh));
rlgpsd = real(lgpsd);
rlgpsd = rlgpsd - mean(rlgpsd);

% visualize

% figure(1);
% set(gcf,'Position',[100,100,1800,1000]);
% clf;
% 
% subplot(2,1,1);
% 
% plot(f(2:Nf), rlgpsd(2:Nf), 'k-', 'linewidth',2);
% hold on;
% % rlogl = real(logl);
% % rlogl = rlogl - mean(rlogl);
% % plot(f(2:Nf), rlogl(2:Nf), 'r-', 'linewidth',2);
% 
% xlabel('Frequency (Hz)');
% xlim([0 10]);

% visualize

% figure(1);
% subplot(2,1,2);
% 
% plot(t(1:N),cc(1:N),'k-','linewidth',2);
% hold on;
% xlabel('Quefrency (s)');
% 
% % plot theoratical arrival
% 
% H = 0.5;
% v = 0.5;
% td = (2 * H / v) * (1:1:10);
% 
% H2 = 4.0;
% v2 = 1.5;
% td2 = (2 * H2 / v2) * (1:1:10);
% 
% for ix = 1:length(td)
%     xline(td(ix),'k:');
%     xline(td2(ix),'b:');
%     hold on;
% end
% 
% xlim([0 10]);

% subplot(3,1,3);
% plot(q(2:Nq),ccorig(2:Nq),'k-','linewidth',2);
% xlabel('Quefrency');

% pause;

%--------------------------------------------------------------------------
function [y,nd] = rcunwrap(x)
%RCUNWRAP Phase unwrap utility used by CCEPS.
%   RCUNWRAP(X) unwraps the phase and removes phase corresponding
%   to integer lag.  See also: UNWRAP, CCEPS.

n = length(x);
y = unwrap(x);
nh = fix((n+1)/2);

idx = nh+1; 
% Special case the index for scalar input.
if length(y) == 1
  idx = 1;
end
nd = round(y(idx)/pi);
y(:) = y(:)' - pi*nd*(0:(n-1))/nh;
% Cast to 'double' to enforce precision rules
nd = double(nd); % output nd has no bearing on single precision rules
%--------------------------------------------------------------------------
function chkinput(x)
% Check for valid input signal

signal.internal.sigcheckfloattype(x,'','cceps','X');
if isempty(x) || issparse(x) || ~isreal(x)
    error(message('signal:cceps:invalidInput', 'X'));
end

