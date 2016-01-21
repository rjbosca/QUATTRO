classdef qt_rptobjs
%QUATTRO report base class
%
%   qt_rptvis is an abstract class that defines common properties and methos for
%   report objects
%
%   Type "doc qt_rptobjs" for a summary of all properties and methods that are
%   common to report classes


    %------------------------------- Properties --------------------------------
    properties

        % Graphics data
        %
        %   "data" is a property containing the data used to create part of a
        %   QT_REPORT output, usually the input to a function (e.g. UITABLE or
        %   PLOT). The data type will vary based on the type of part being used.
        %   For example, a QT_CODE object will store a cell array of strings,
        %   while a QT_UITABLE will store a structure.
        data

        % Output format
        %
        %   "format" is a string specifying the requested output format that
        %   must be one of the following: {'html'} or 'pdf'
        format = 'html';

        % Section index
        %
        %   "sectIdx" is a number indicating the section with which this object
        %   is associated
        sectIdx

        % Report part index
        %
        %   "partIdx" is a number indicating the order of the visualization
        %   within a section of a qt_report object
        partIdx

    end

    properties (Access='protected')

        % Data storage file
        %
        %   "dataFile" is a temporary mat_io object that is used to interface
        %   data with published reports (see QT_REPORT)
        dataFile = mat_io([tempname '.mat'],true);

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_rptobjs(varargin)
        %qt_rptobjs  Constructor for qt_rptobjs class
        %
        %   qt_rptobjs is an abstract class and, as such, creating an instance
        %   of this class is not allowed
        end %qt_rptobjs.qt_rptobjs

    end


    %----------------------------- Abstract Methods ----------------------------
    methods (Abstract)

        % Convert a visualization object to publishable code
        %
        %   "part2code" is an abstract method that converts the data of a
        %   qt_rptobjs sub-class into code to be exectued by PUBLISH
        h = part2code(obj)

        % Preview the visualization
        %
        %   "preview" displays a preview of the visualization object
        preview(obj)

    end

end %qt_rptobjs