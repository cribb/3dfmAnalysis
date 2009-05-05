function v = dmbr_compute_mean_curves(table, offsets)
% averages across all sequences.  data are interpolated to 1kHz in order to
% remove the possiblity of discrepancies between the number of availble
% points from sequence to sequence.
% 
% mean creep curves are only valid across sequences of the same bead, and
% for sequences where the net displacement is more or less constant from
% curve to curve.

    dmbr_constants;

    cols = [TIME X Y Z ROLL PITCH YAW J SX SY SJ DX DY DJ SDX SDY SDJ];

    for b = unique(table(:,ID))'

        for s = unique(table(:,SEQ))'

            idx = find(table(:,ID) == b & ...
                       table(:,SEQ) == s );
            oidx = find(offsets(:,ID) == b & ...
                        offsets(:,SEQ) == s );

            foo = table(idx,cols);
            if ~isempty(oidx)
                bar = repmat(offsets(oidx,cols), rows(foo), 1);
            else
                bar = repmat(zeros(1, length(cols)), rows(foo),1);
            end

            if ~exist('sumtable')
                sumtable = foo - bar;
                count = 1;
            else
                try
                    sumtable = sumtable + (foo - bar);
                    count = count + 1;
                catch
                    logentry('something not included in average');
                end
            end

        end

        tmptable(:,cols) = sumtable / count;
%         tmptable(:,SEQ) = s;
        tmptable(:,ID) = b;

        if ~exist('meantable')
            meantable = tmptable;
        else
            meantable = [meantable ; tmptable];
        end

        clear sumtable count;
    end

    v = meantable;

return;


%%%%%%%%%%%%%%%%
% SUBFUNCTIONS %
%%%%%%%%%%%%%%%%

%% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'dmbr_compute_mean_curves: '];
     
     fprintf('%s%s\n', headertext, txt);

     return;

