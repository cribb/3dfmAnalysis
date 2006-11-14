function varargout = atcore(d, settings, flags);
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
%            .LPhz - the cutoff frequency of lowpass filter, if used
%            .HPhz - the cutoff frequency of Highpass filter, if used
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
version_str = '1.6 - 31st July 06';
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
% This is to remove the frequencies that are within loop bandwidth, because
% this frequencies are present in stage but not seen by QPD.
% have to do this after handling reciprocals otherwise get 1/0 issue
if flags.HPstage
    [b,a] = butter(2, settings.HPhz*2/srate, 'high');
    for i = 1:3
        sfit(:,i) = myfilt(b,a,sfit(:,i));
        stest(:,i) = myfilt(b,a,stest(:,i));
        squiet(:,i) = myfilt(b,a,squiet(:,i));
    end
end    
if flags.detrend% subtract the linear trend from the stage reports
    for i = 1:3
        ps = polyfit(tfit, sfit(:,i), 1);
        sfit(:,i) = sfit(:,i) - polyval(ps, tfit);
        ps = polyfit(ttest, stest(:,i), 1);
        stest(:,i) = stest(:,i) - polyval(ps, ttest);
        ps = polyfit(tquiet, squiet(:,i), 1);
        squiet(:,i) = squiet(:,i) - polyval(ps, tquiet);
    end
end

if flags.HPqpd
    [b,a] = butter(2, settings.HPhz*2/srate, 'high');
    for i = 1:size(qfit,2)
        qfit(:,i) = myfilt(b,a,qfit(:,i));
        qtest(:,i) = myfilt(b,a,qtest(:,i));
        qquiet(:,i) = myfilt(b,a,qquiet(:,i));
    end    
end   
if flags.detrend
    for i = 1:size(qfit,2)
        pq = polyfit(tfit, qfit(:,i), 1);
        qfit(:,i) = qfit(:,i) - polyval(pq, tfit);
        pq = polyfit(ttest, qtest(:,i), 1);
        qtest(:,i) = qtest(:,i) - polyval(pq, ttest);
        pq = polyfit(tquiet, qquiet(:,i), 1);
        qquiet(:,i) = qquiet(:,i) - polyval(pq, tquiet);
    end    
end

% the stage sense signal seems dubious above about 550 Hz
% We should also filter the testbed and quiet data here because
% we know that stage doesn't move beyond 550 Hz and removing those
% high frequencies is always going to bring the data closer to the truth.
if flags.LPstage
    [b,a] = butter(4, settings.LPhz*2/srate);
    for i = 1:3
        sfit(:,i) = myfilt(b,a,sfit(:,i));
        stest(:,i) = myfilt(b,a,stest(:,i));
        squiet(:,i) = myfilt(b,a,squiet(:,i));
    end
end

% Filter QPD signals also. Usually this is not selected.
if flags.LPqpd
    [b,a] = butter(4, settings.LPhz*2/srate);
    for i = 1:size(qfit,2)
        qfit(:,i) = myfilt(b,a,qfit(:,i));
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

if flags.puresine %pure sine perturbations
    sfit = sfit - repmat(sfit(1,:),size(sfit,1),1);
    stest = stest - repmat(stest(1,:),size(stest,1),1);
    squiet = squiet - repmat(squiet(1,:),size(squiet,1),1);
    fxyz = [67,61,53]; %perturbation frequencies
    for (c = 1:3)
        tpraw= sin(2*pi*fxyz(c)*tfit); % unscaled, unaligned template
        [xc,xl] = xcorr(tpraw,sfit(:,c));
        phi = xl(find(xc == max(xc)))*2*pi*fxyz(c)/srate; %phase alignment necessary
        tphi = sin(2*pi*fxyz(c)*tfit + phi); % phase aligned template
        [xc,xl] = xcorr(tphi,sfit(:,c));
        [ac,al] = xcorr(tphi,tphi);
        amp(c) = xc(find(xl == 0))/ ac(find(al==0)); %scaling necessary
        template(:,c) = amp(c).*tphi; %scaled and aligned template
        figure(150);
        set(gcf,'name','Template','NumberTitle','Off');
        subplot(3,1,c);
        plot(tfit,sfit(:,c),'r',tfit,template(:,c),'b');
        if c == 1
            title('Pure Sine template fit to stage sensed positions');
        end
    end
    Afit = buildpoly(qfit,settings.order);
    Jac = Afit \ template;
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
    % Now compute the leak factor. Here is the logic:
    % Ps_pert = Ps_quiet + kW, then goal is to estimate k
    % E(W*Ps_pert) = E(W*Ps_quiet) + kE(W*W)
    % We must use the "test" zone for Ps_pert. Also, for accurate
    % estimation of the leak factor, it is preferable that "test" zone is
    % fully spanned by sinusoids (no quiet parts).
    [b,a] = butter(2,25*2/srate,'high');
    for c = 1:3
        % remove low frequencies from all signals, do this only locally
        spert = filtfilt(b,a,stest(:,c));
        ppert = filtfilt(b,a,testresid(:,c));
        pquiet = filtfilt(b,a,quietresid(:,c));
        % align the template W to Ps_quiet.
        tplt = amp(c)*sin(2*pi*fxyz(c)*ttest);
        [xc,xl] = xcorr(tplt,ppert);
        phi = xl(find(xc == max(xc)))*2*pi*fxyz(c)/srate; %phase alignment necessary
        tphi = amp(c)*sin(2*pi*fxyz(c)*ttest + phi); % phase aligned template
        figure(210+c); plot(ttest,[ppert,tphi]);
        testcorr = (1/length(ppert))*(ppert'*tphi);
        % We don't expect a perturbation-frequency sinusoid in the quiet
        % region, so aligning the template won't be helpful
        quietcorr = (1/length(pquiet))*(pquiet'*[amp(c)*sin(2*pi*fxyz(c)*tquiet)]);
        autocorr = (1/length(tplt))*(tplt'*tplt);
        leakfactor(c) = (abs(testcorr) - abs(quietcorr))/autocorr;
    end
    
    
else %old approach where we use filtering to get rid of the effects of feedback
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
end

if flags.LPresid
    [b,a] = butter(4, settings.LPhz*2/srate);
    for i = 1:3
        testresid(:,i) = myfilt(b,a,testresid(:,i));
        fitresid(:,i) = myfilt(b,a,fitresid(:,i));
        quietresid(:,i) = myfilt(b,a,quietresid(:,i));
    end    
end
if flags.HPresid
% a try: hp filter the residuals
    [b,a] = butter(4, settings.HPhz*2/srate,'high');
    for c = 1:3
        testresid(:,c) = filtfilt(b,a,testresid(:,c));
        fitresid(:,c) = filtfilt(b,a,fitresid(:,c));
        quietresid(:,c) = filtfilt(b,a,quietresid(:,c));
    end
end

res.rmsQUIETresid = sqrt(mean(quietresid.^2));
res.rmsQUIETstage = sqrt(mean(squiet.^2));
res.rmsFITresid = sqrt(mean(fitresid.^2));
res.rmsFITstage = sqrt(mean(sfit.^2));
res.blipratio = res.rmsFITresid ./res.rmsQUIETresid;
if flags.puresine, res.leakfactor = leakfactor; end

switch (nargout)
    case 1
        varargout{1} = res;
    case 2
        varargout{1} = res;
        varargout{2} = Jac;
    case 3
        dout.test.s = stest;
        dout.test.q = qtest;
        dout.test.preds = testpred;
        dout.test.t = ttest;
        
        dout.fit.s = sfit;
        dout.fit.q = qfit;
        dout.fit.preds = fitpred;
        dout.fit.t = tfit;        
        
        dout.quiet.s = squiet;
        dout.quiet.q = qquiet;
        dout.quiet.preds = quietpred;
        dout.quiet.t = tquiet;
        
        varargout{1} = res;
        varargout{2} = Jac;
        varargout{3} =  dout;   
    otherwise
        disp('atcore Error: unrecognized number of output arguments');
end
%%%%%%%%% EVERYTHING BELOW IS ONLY PLOTTING ETC, NO ANALYSIS %%%%%%%%% 


%[uA,dA,vA] = svd(Afit,0);
%figure(11)
%svds = diag(dA);
%svds = svds / sum(svds);
%semilogy(svds);
%title('Singular Values');

xyz = 'XYZ';
psdres = max([1, ceil(1/range(ttest))]); 
for i = 1:3
    figure(19+i);
    set(gcf,'name',['PSD test:',xyz(i)],'NumberTitle','Off');
    mypsd([stest(:,i),testpred(:,i),testresid(:,i)], srate, psdres,[],'.-');
    title(['stage psd: Test data ', xyz(i)]);
    legend('Measrd','Pred','Resid',3);    
    zoom on
end
psdres = max([1, ceil(1/range(tquiet))]);
for i = 1:3
    figure(19+3+i);
    set(gcf,'name',['PSD quiet:',xyz(i)],'NumberTitle','Off');
    mypsd([squiet(:,i),quietpred(:,i),quietresid(:,i)], srate, psdres,[],'.-');
    title(['stage psd: Quiet data ', xyz(i)]);
    legend('Measrd','Pred','Resid',3);    
    zoom on
end
psdres = max([1, ceil(1/range(tfit))]);
for i = 1:3
    figure(19+6+i);
    set(gcf,'name',['PSD Fit:',xyz(i)],'NumberTitle','Off');
    mypsd([sfit(:,i),fitpred(:,i),fitresid(:,i)], srate, psdres,[],'.-');
    title(['stage psd: Fitting data ', xyz(i)]);
    legend('Measrd','Pred','Resid');
end
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

figure(32);
set (gcf,'name','Quiet','NumberTitle','Off');
for i = 1:3
    subplot(3,1,i);
    plot(tquiet,squiet(:,i),'b', tquiet, quietpred(:,i), 'g', tquiet,quietresid(:,i),'r')
    title(['Stage: Quiet data', xyz(i)])    
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
%----------------------- a central place for playing around with filtering
function filout = myfilt(b,a,filin)
if (1)
    filout = filtfilt(b,a,filin);
else
    len = floor(size(filin,1)/2);
    padin = [zeros(len,1); filin ; zeros(len,1)];
    padout = filtfilt(b,a,padin);
    filout = padout(len+1:len+size(filin,1),1);
end