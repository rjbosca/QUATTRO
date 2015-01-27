function initialize(src,eventdata)
%initialize  qt_exam object data initialization event
%
%   initialize(SRC,EVENT) initializes properties of the qt_exam object OBJ. Most
%   importantly, this event handler performs consistency checks on the meta-data
%   for each image, forcing consistent meta-data structures where necessary.

    % Images are the minimum necessary data. Also, validate the calling event
    if ~src.exists.images.any || ~strcmpi(eventdata.EventName,'initializeExam')
        return
    end

    % Get the image meta data
    imgs = src.imgs;
    hdrs = reshape( cell2mat({imgs.metaData}), size(imgs) );
    
    % Create the generic display information
    dispFrmt = {'Loc: %s %3.3f'
                'Im: %d'
                'Series: %d'
                'FOV:%5.0f mm'
                'TR/TE/FA/NEX:%5.1f / %3.1f / %2.0f / %1.0f'};
    [dispFlds{[2:4 6:9]}] = deal('SliceLocation','InstanceNumber',...
                                  'SeriesNumber','RepetitionTime',...
                                  'EchoTime','FlipAngle','NumberOfAverages');
    switch lower(hdrs(1).Manufacturer)
        case 'siemens'
        case 'ge medical systems'
            [dispFlds{[1 5]}] = deal(dicomlookup('0027','1040'),...
                                     dicomlookup('0018','1100'));
        case 'philips medical systems'
            [dispFlds{[1 5]}] = deal(dicomlookup('2001','108b'),...
                                     dicomlookup('0018','1100'));
        otherwise
            dispFlds([1 5]) = [];
            dispFrmt{1}     = 'Loc: %3.3f';
            dispFrmt(4)     = [];
    end

    % Update display information
    [imgs(:).dispFormat] = deal(dispFrmt);
    [imgs(:).dispFields] = deal(dispFlds); %#ok - these are image objects that
                                           %don't require storage

    % Sort the qt_exam object before continuing
    src.sort;

    % Prepare some exam specific options
    switch lower(src.type)
        case 'dce'

            % Use the imaging data on the center slice to attempt to determine
            % the arrival of the bolus
            slCenter = round( size(src.imgs,1)/2 );
            imData   = permute( src.imgs(slCenter,:).img2mat,[3 1 2] );
            [src.opts.preEnhance,ok] = detect_bolus_arrival( imData );
            if ~ok
                warning(['qt_exam:' mfilename ':undetectableBolusArrTime'],...
                        ['Unable to automatically detect the bolus arrival\n',...
                         'time. Setting the "preEnhance" option to the\n',...
                         'frame: %d\n'],src.opts.preEnhance);
                if src.guiDialogs
                    h = warndlg({'Unable to detect bolus arrival time. Please set',...
                                 '"Base Images" under DCE Options.'},'Unknown BAT','modal');
                    add_logo(h);
                end
            end


        case 'dsc'
            src.opts.preEnhance = detect_bolus_arrival({src.imgs.image},false);
        case 'multiflip'
            hdrs = reshape(cell2mat({src.imgs(:).metaData}),size(src.imgs));
            trs  = unique( cell2mat( {hdrs(1,:).RepetitionTime} ) );
            tes  = unique( cell2mat( {hdrs(1,:).EchoTime} ) );
            if numel( trs ) > 1
                warning(['qt_exam:' mfilename ':tooManyTrs'],...
                        ['More than one TR was detected for this multiple\n',...
                         'flip angle exam, but modeling assumes only one.\n']);
                if src.guiDialogs
                    errordlg('Multiple TRs found; expected only one.',...
                             'ERROR: Variable Flip Angle Exam','modal');
                end
            end
            if numel( tes ) > 1
                warning(['qt_exam:' mfilename ':tooManyTes'],...
                        ['More than one TE was detected for this multiple\n',...
                         'flip angle exam, but modeling assumes only one.\n']);
                if src.guiDialogs
                    errordlg('Multiple TEs found; expected only one.',...
                             'ERROR: Variable Flip Angle Exam','modal');
                end
            end
        case 'surgery'
            src.calc_ijk2ras
    end

end %qt_exam.initialize