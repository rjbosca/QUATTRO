function generate(obj)
%generate  Generates the final report
%
%   generate(OBJ) generates the final report based on the current state of the
%   properties of the qt_report object, OBJ

%     if isdeployed %FIXME: this is a temporary solution for the QIBA project
        obj.qiba_generate;
%         return
%     end
% 
%     % Determine the output location
%     isHtml    = strcmpi(obj.format,'html');
%     outputDir = fileparts(obj.reportFile);
%     if isHtml
%         outputDir = fullfile(outputDir,'html');
%         if (exist(outputDir,'dir')~=7)
%             mkdir(outputDir)
%         end
%     end
% 
%     % Write the document title
%     obj.genFile.write('%%%% %s\n\n\n\n',obj.title);
% 
%     % Loop through each of the sections and associated parts, writing the
%     % section title and code
%     origSect = obj.sectIdx;
%     for sIdx = 1:numel(obj.sectNames)
% 
%         % Update the "sectIdx" property and write the section title
%         obj.sectIdx = sIdx;
%         obj.genFile.write('\n\n%%%% %s\n',obj.sectNames{sIdx});
% 
%         % Write the code and visualizations
%         for pIdx = 1:(obj.nextPartIdx-1)
% 
%             % Determine what kind of report type contains the next index
%             codeMask  = (obj.codeInds==pIdx);
%             plotMask  = (obj.plotInds==pIdx);
%             tableMask = (obj.tableInds==pIdx);
%             if any(codeMask)
%                 obj.genFile.write('%s\n',obj.code{sIdx}(codeMask).part2code{:});
%             elseif any(plotMask)
%                 pObj = obj.plots{sIdx}(plotMask);
%                 obj.genFile.write('%s\n',pObj.part2code{:});
%                 if isHtml
%                     imRes    = sprintf('-r%d',pObj.imageRes);
%                     imFrmt   = pObj.imageFormat;
%                     hPlotFig = pObj.preview;
%                     %TODO: use the appropriate image format
%                     plotFile = fullfile(outputDir,...
%                                    sprintf('Figure_%d-%d.%s',sIdx,pIdx,imFrmt));
%                     print(hPlotFig,plotFile,['-d' imFrmt],imRes);
%                     delete(hPlotFig);
%                 end
%             elseif any(tableMask)
%                 obj.genFile.write('%s\n',...
%                                       obj.tables{sIdx}(tableMask).part2code{:});
%             end
% 
%         end
%     end
% 
%     % Restore the original section index
%     obj.sectIdx = origSect;
% 
%     % Close the file
%     obj.genFile.close;
% 
%     % Cache the current directory and change to the output directory
%     curDir = pwd;
%     cd( fileparts(obj.genFile.file) );
% 
%     % Publish the code
%     try
%         opts = struct('format',obj.format,...
%                       'outputDir',outputDir,...
%                       'showCode',false,...
%                       'useNewFigure',true);
%         publish(obj.genFile.file,opts);
%     catch ME
%     end
% 
%     % Rreturn to the previous working directory
%     cd( curDir )

end %qt_report.generate