function res = atcore(d, settings, flags);
% Usage: res = atcore(d, settings, flags)
% inputs: 'd' , a structure containing atleast all of the fields below
%            .t
%            .ssense
%            .qpd
%            .info
%         'settings' , a structure containing following fields
%            .testrange - the range in seconds for the test data
%            .fitrange - the range in seconds for the data to fit Jacobian on
%            .order - the order of jacobian to be fit
%            .LPHz - the cutoff frequency of lowpass filter, if used
%            .HPHz - the cutoff frequency of Highpass filter, if used
%         'flags' , a structure containing following binary flags
%            .fixskew - do we want to compensate for skew
%            .HPstage - do we want to apply HP filter to stage sensed data
%            .HPqpd - do we want to apply HP filter to QPD data
%            .LPstage - do we want to apply LP filter to stage sensed data
%            .LPqpd - do we want to apply LP filter to QPD data
%            .LPresid - do we want to apply LP filter to residuals
% outputs: 'res' , a result structure with following fields
%             .residrms - rms value of residuals for 3 axis
%             .stagerms - rms value of stagesensed positions
%             .ratio - ratio of the two rms values
    
dbstop if error
% mt = d.t - d.t(1);
mt = d.t;
ms = d.ssense - repmat(d.ssense(1,:),size(d.ssense,1),1);
mq = d.qpd;

%%--------------------Resampling at 20KHz ---------------------------
% Data is not guaranteed to be sampled evenly so resampling at 20kHz
% This preprocessing should also be done to testbed data, since it is 
% bringing the data closer to the truth, without losing any information.
srate = 20000;
if (settings.testrange(1,1) >= settings.testrange(1,2))
    disp('atcore:: inappropriate setting for range of test data. entering in debug mode');
    keyboard;
elseif(settings.testrange(1,1) >= settings.testrange(1,2))
    disp('atcore:: inappropriate setting for range of fit data. entering in debug mode');
    keyboard;
end
ttest = (settings.testrange(1,1):(1/srate):settings.testrange(1,2))';
tfit = (settings.fitrange(1,1):(1/srate):settings.fitrange(1,2))';
% attempt to adjust for sequential sampling in the daq board
if flags.fixskew
    % order measurements are made 
    qtimeoffset = 12.5e-6 * [ 0, 1, 2, 3 ];
    stimeoffset = 12.5e-6 * [ 6, 5, 7 ];
    sfit = []; stest = [];
    for i = 1:3
        stest(:,i) = interp1(mt+stimeoffset(i), ms(:,i), ttest);
        sfit(:,i) = interp1(mt+stimeoffset(i), ms(:,i), tfit);
    end
    qfit = []; qtest = [];
    for i = 1:4
        qtest(:,i) = interp1(mt+qtimeoffset(i), mq(:,i), ttest);
        qfit(:,i) = interp1(mt+qtimeoffset(i), mq(:,i), tfit);
    end
else
    stest = interp1(mt, ms, ttest);
    qtest = interp1(mt, mq, ttest);
    sfit = interp1(mt, ms, tfit);
    qfit = interp1(mt, mq, tfit);
end
clear mt ms mq %free up memory as we go
%%------------------------------------------------------------------
if flags.usereciprocals
%     qfit = [ qfit, 1./qfit ];   
%     qtest = [ qtest, 1./qtest];
    
    qfit = 1 ./ qfit;
    qtest = 1 ./ qtest;       
end
% use a high-pass filter or simply subtract off a trend.
if flags.HPstage
    [b,a] = butter(2, settings.HPhz*2/srate, 'high');
    for i = 1:3
        sfit(:,i) = filtfilt(b,a,sfit(:,i));
        stest(:,i) = filtfilt(b,a,stest(:,i));% ????SHOULD WE REALLY FILTER THE TESTBED DATA HERE????
    end
else    % subtract the linear trend from the stage reports
    for i = 1:3
        ps = polyfit(tfit, sfit(:,i), 1);
        sfit(:,i) = sfit(:,i) - polyval(ps, tfit);
        ps = polyfit(ttest, stest(:,i), 1);
        stest(:,i) = stest(:,i) - polyval(ps, ttest);% ????SHOULD WE REALLY FILTER THE TESTBED DATA HERE????
    end
end

if flags.HPqpd
    [b,a] = butter(2, settings.HPhz*2/srate, 'high');
    for i = 1:size(qfit,2)
        qfit(:,i) = filtfilt(b,a,qfit(:,i));
        qtest(:,i) = filtfilt(b,a,qtest(:,i));% ????SHOULD WE REALLY FILTER THE TESTBED DATA HERE????
    end    
else    
    for i = 1:size(qfit,2)
        pq = polyfit(tfit, qfit(:,i), 1);
        qfit(:,i) = qfit(:,i) - polyval(pq, tfit);
        pq = polyfit(ttest, qtest(:,i), 1);
        qtest(:,i) = qtest(:,i) - polyval(pq, ttest); %????SHOULD WE REALLY FILTER THE TESTBED DATA HERE????
    end    
end

% the stage sense signal seems dubious above about 200 Hz
if flags.LPstage
    [b,a] = butter(4, settings.LPhz*2/srate);
    for i = 1:3
        sfit(:,i) = filtfilt(b,a,sfit(:,i));
    end
end
if flags.LPqpd
    [b,a] = butter(4, settings.LPhz*2/srate);
    for i = 1:size(qfit,2)
        qfit(:,i) = filtfilt(b,a,qfit(:,i));
    end
end

% % see if s is dependent on what q was last time...
% Delay = 0;
% newq = qfit;
% for i = 1:Delay
%     k = i * 10;
%     delayq = [ qfit(1:k,:); qfit(1:end-k,:) ];
%     newq = [ newq, delayq ];
% end
% qfit = newq; clear newq;

% see if including reciprocals helps

% this allows (T-B)/sum, (R-L)/sum, sum to be used instead of raw qfit values
if flags.usesumdiff
    nq = sum(qfit,2);
    qfit = [ (qfit(:,1)+qfit(:,2)-qfit(:,3)-qfit(:,4)) ./ nq, (qfit(:,1)-qfit(:,2)+qfit(:,3)-qfit(:,4)) ./ nq, nq ];
end

figure(10);
plot(tfit,sfit);
title('STAGE filtered fitting data')
figure(11);
plot(tfit,qfit);
title('QPD filtered fitting data');

% build the equations for the indicated order
A = buildpoly(qfit,settings.order);
%[uA,dA,vA] = svd(A,0);
%figure(11)
%svds = diag(dA);
%svds = svds / sum(svds);
%semilogy(svds);
%title('Singular Values');

Jac = A \ sfit;
A = buildpoly(qtest,settings.order);
pred = A * Jac;
residual = stest - pred;

if flags.LPresid
    [b,a] = butter(4, LPHz*2/srate);
    for i = 1:3
        residual(:,i) = filtfilt(b,a,residual(:,i));
    end
end    
xyz = 'XYZ';
for i = 1:3
    figure(19+i);
    mypsd([stest(:,i),pred(:,i),residual(:,i)], srate, 10);
    title(['stage psd', xyz(i)]);
    legend('Measrd','Pred','Resid');
end

for i = 1:3
    figure(29+i)
    plot(ttest,stest(:,i),'b',ttest,residual(:,i),'r')
    title(['Residual ', xyz(i)])
    legend('Stage','resid');
end

res.residrms = sqrt(mean(residual.^2));
res.stagerms = sqrt(mean(stest.^2));
res.ratio = res.residrms ./res.stagerms;
res.fudge = 0.0035;
res.ratio_fudged = (res.residrms - res.fudge) ./ (res.stagerms - res.fudge);
figure(12)
for (i = 1:3)
    subplot(3,1,i)
    plot(ttest,stest(:,i), 'b', ttest, pred(:,i),'r'); legend('Measrd', 'Pred');
end

% try to estimate the effect of skew in the data acquisition system
velocity = sqrt(sum(diff(stest).^2, 2))*srate;
skewtime = 100e-6; % 100 microseconds is a full cycle, skew is actually (c-1)/c times that, where c is the # of channels
skew = skewtime * velocity;
res.max_skew = max(skew);
res.mean_skew = mean(skew);
dbclear if error
%--------------------------------------------------------
function A = buildpoly(q,order) % from gb the great, and tested by me.
% q is a NxM matrix, here M = 4 for QPD
A = [ ones(size(q,1), 1) ]; % Nx1 vector all ones
nQ = ones(1, size(q,2));% 1xM vector all ones
for o = 1:order
    Ap = A; %inherit all low order terms from the last order 
    for i = 1:size(q,2) % repeat M times
        Ac = Ap(:,nQ(i):end); 
        nQ(i) = size(A,2) + 1;
        A = [ A, repmat(q(:,i),1,size(Ac,2)).*Ac ];
    end
end