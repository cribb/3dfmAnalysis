function [res, Jac] = atcore(d, settings, flags);
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
version_str = '1.2 - 13th Sep 05';
% disp(['atcore version: ', version_str]);
dbstop if error

mt = d.t; %do not subtract out the offset in timing. 
ms = d.ssense - repmat(d.ssense(1,:),size(d.ssense,1),1);
mq = d.qpd;

%%--------------------Resampling at 20KHz ---------------------------
% If i didnt choose to log at high-bandwidth, then data will be logged at
% highly variable software-loop rate. So resampling at 20kHz
% This preprocessing should also be done to testbed data, since it is 
% bringing the data closer to the truth, without losing any information.
if range(diff(d.t)) > 1e-6
    disp('Timestamps were uneven, will resample data at 20000Hz');
    srate = 20000;
else
    srate = 1/mean(diff(d.t));
end

if (settings.testrange(1,1) >= settings.testrange(1,2))
    disp('atcore:: inappropriate setting for range of test data. entering in debug mode');
    keyboard;
end
if(settings.fitrange(1,1) >= settings.fitrange(1,2))
    disp('atcore:: inappropriate setting for range of fit data. entering in debug mode');
    keyboard;
end
if(settings.quietrange(1,1) >= settings.quietrange(1,2))
    disp('atcore:: inappropriate setting for range of quiet data. entering in debug mode');
    keyboard;
end

ttest = (settings.testrange(1,1):(1/srate):settings.testrange(1,2))';
tfit = (settings.fitrange(1,1):(1/srate):settings.fitrange(1,2))';
tquiet = (settings.quietrange(1,1):(1/srate):settings.quietrange(1,2))';
% attempt to adjust for sequential sampling in the daq board
if flags.fixskew
    % order measurements are made 
    qtimeoffset = 12.5e-6 * [ 0, 1, 2, 3 ];
    stimeoffset = 12.5e-6 * [ 6, 5, 7 ];
    sfit = []; stest = []; squiet = [];
    for i = 1:3
        stest(:,i) = interp1(mt+stimeoffset(i), ms(:,i), ttest);
        sfit(:,i) = interp1(mt+stimeoffset(i), ms(:,i), tfit);
        squiet(:,i) = interp1(mt+stimeoffset(i), ms(:,i), tquiet);
    end
    qfit = []; qtest = []; qquiet = [];
    for i = 1:4
        qtest(:,i) = interp1(mt+qtimeoffset(i), mq(:,i), ttest);
        qfit(:,i) = interp1(mt+qtimeoffset(i), mq(:,i), tfit);
        qquiet(:,i) = interp1(mt+qtimeoffset(i), mq(:,i), tquiet);
    end
else
    stest = interp1(mt, ms, ttest);
    qtest = interp1(mt, mq, ttest);
    sfit = interp1(mt, ms, tfit);
    qfit = interp1(mt, mq, tfit);
    squiet = interp1(mt, ms, tquiet);
    qquiet = interp1(mt, mq, tquiet);
end
clear mt ms mq %free up memory as we go
%%------------------------------------------------------------------
if flags.usereciprocals
%     RecForm = 3; %change this to use different methods of reciprocals
    switch settings.RecForm
        case 1
            qfit = [ qfit, 1./qfit ];
            qtest = [ qtest, 1./qtest];
            qquiet = [qquiet, 1./qquiet];
        case 2
            qfit = 1 ./ qfit;
            qtest = 1 ./ qtest;
            qquiet = 1 ./ qquiet;
        case 3
            qfit = [ qfit, 1./sum(qfit,2) ];
            qtest = [qtest, 1./sum(qtest,2)];
            qquiet = [qquiet, 1./sum(qquiet,2)];
        otherwise
            disp('atcore ERROR: unrecoginized form for reciprocals');
    end          
end
% use a high-pass filter or simply subtract off a trend.
% have to do this after handling reciprocals otherwise get 1/0 issue
% settings.HPhz = 30; %cheap hack
if flags.HPstage
    [b,a] = butter(2, settings.HPhz*2/srate, 'high');
    for i = 1:3
        sfit(:,i) = filtfilt(b,a,sfit(:,i));
        stest(:,i) = filtfilt(b,a,stest(:,i));% ????SHOULD WE REALLY FILTER THE TESTBED DATA HERE????
        squiet(:,i) = filtfilt(b,a,squiet(:,i));
    end
else    % subtract the linear trend from the stage reports
    for i = 1:3
        ps = polyfit(tfit, sfit(:,i), 1);
        sfit(:,i) = sfit(:,i) - polyval(ps, tfit);
        ps = polyfit(ttest, stest(:,i), 1);
        stest(:,i) = stest(:,i) - polyval(ps, ttest);% ????SHOULD WE REALLY FILTER THE TESTBED DATA HERE????
        ps = polyfit(tquiet, squiet(:,i), 1);
        squiet(:,i) = squiet(:,i) - polyval(ps, tquiet);
    end
end

if flags.HPqpd
    [b,a] = butter(2, settings.HPhz*2/srate, 'high');
    for i = 1:size(qfit,2)
        qfit(:,i) = filtfilt(b,a,qfit(:,i));
        qtest(:,i) = filtfilt(b,a,qtest(:,i));% ????SHOULD WE REALLY FILTER THE TESTBED DATA HERE????
        qquiet(:,i) = filtfilt(b,a,qquiet(:,i));
    end    
else    
    for i = 1:size(qfit,2)
        pq = polyfit(tfit, qfit(:,i), 1);
        qfit(:,i) = qfit(:,i) - polyval(pq, tfit);
        pq = polyfit(ttest, qtest(:,i), 1);
        qtest(:,i) = qtest(:,i) - polyval(pq, ttest); %????SHOULD WE REALLY FILTER THE TESTBED DATA HERE????
        pq = polyfit(tquiet, qquiet(:,i), 1);
        qquiet(:,i) = qquiet(:,i) - polyval(pq, tquiet);
    end    
end

% the stage sense signal seems dubious above about 200 Hz
% I DONT THINK WE SHOULD FILTER TESTBED OR QUIET DATA HERE.
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
    nq = sum(qtest,2);
    qfit = [ (qtest(:,1)+qtest(:,2)-qtest(:,3)-qtest(:,4)) ./ nq, (qtest(:,1)-qtest(:,2)+qtest(:,3)-qtest(:,4)) ./ nq, nq ];
    nq = sum(qquiet,2);
    qquiet = [ (qquiet(:,1)+qquiet(:,2)-qquiet(:,3)-qquiet(:,4)) ./ nq, (qquiet(:,1)-qquiet(:,2)+qquiet(:,3)-qquiet(:,4)) ./ nq, nq ];
end

figure(10);set(gcf, 'Name','stage','NumberTitle','Off');
plot(tfit,sfit);
title('STAGE filtered fitting data')
figure(11);set(gcf, 'Name','qpd','NumberTitle','Off');
plot(tfit,qfit);
title('QPD filtered fitting data');

% build the equations for the indicated order
Afit = buildpoly(qfit,settings.order);
Jac = Afit \ sfit;
fitpred = Afit * Jac;
fitresid = sfit - fitpred;
% Now apply this Jacobian to the test data to see how well can we predict
% stage position
Atest = buildpoly(qtest,settings.order);
testpred = Atest * Jac;
testresid = stest - testpred;

Aquiet = buildpoly(qquiet,settings.order);
quietpred = Aquiet * Jac;
quietresid = squiet - quietpred;

res.rmsQUIETresid = sqrt(mean(quietresid.^2));
res.rmsQUIETstage = sqrt(mean(squiet.^2));
res.rmsFITresid = sqrt(mean(fitresid.^2));
res.rmsFITstage = sqrt(mean(sfit.^2));
res.blipratio = res.rmsFITresid ./res.rmsQUIETresid;

% res.fudge = 0.0035;
% res.ratio_fudged = (res.residrms - res.fudge) ./ (res.stagerms - res.fudge);

% % try to estimate the effect of skew in the data acquisition system
% velocity = sqrt(sum(diff(stest).^2, 2))*srate;
% skewtime = 100e-6; % 100 microseconds is a full cycle, skew is actually (c-1)/c times that, where c is the # of channels
% skew = skewtime * velocity;
% res.max_skew = max(skew);
% res.mean_skew = mean(skew);

%[uA,dA,vA] = svd(Afit,0);
%figure(11)
%svds = diag(dA);
%svds = svds / sum(svds);
%semilogy(svds);
%title('Singular Values');
if flags.LPresid
    [b,a] = butter(4, LPHz*2/srate);
    for i = 1:3
        testresid(:,i) = filtfilt(b,a,testresid(:,i));
        fitresid(:,i) = filtfilt(b,a,fitresid(:,i));
    end    
end    
xyz = 'XYZ';
psdres = max([1, ceil(1/range(ttest))]); 
for i = 1:3
    figure(19+i);
    set(gcf,'name',['PSD:',xyz(i)],'NumberTitle','Off');
    mypsd([stest(:,i),testpred(:,i),testresid(:,i)], srate, psdres);
    title(['stage psd: Test data ', xyz(i)]);
    legend('Measrd','Pred','Resid',3);    
    zoom on
end
% for i = 1:3
% figure(19+3+i);
%     mypsd([sfit(:,i),fitpred(:,i),fitresid(:,i)], srate, 1);
%     title(['stage psd: Fitting data ', xyz(i)]);
%     legend('Measrd','Pred','Resid');
% end
figure(30);
set (gcf,'name','Fitting','NumberTitle','Off');
for i = 1:3
    subplot(3,1,i);
    plot(tfit,sfit(:,i),'b', tfit, fitpred(:,i), 'g', tfit,fitresid(:,i),'r')
    title(['Stage: Fitting data', xyz(i)])
end
zoom on
legend('Measrd','Pred','resid',0);

figure(31);
set (gcf,'name','Testbed','NumberTitle','Off');
for i = 1:3
    subplot(3,1,i);
    plot(ttest,stest(:,i),'b', ttest, testpred(:,i), 'g', ttest,testresid(:,i),'r')
    title(['Stage: Testbed data', xyz(i)])    
end
zoom on
legend('Measrd','Pred','resid',0);
% figure(12)
% for (i = 1:3)
%     subplot(3,1,i)
%     plot(ttest,stest(:,i), 'b', ttest, pred(:,i),'r'); legend('Measrd', 'Pred');
% end
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