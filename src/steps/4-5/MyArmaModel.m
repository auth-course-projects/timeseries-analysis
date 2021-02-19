classdef MyArmaModel
    %MYARMAMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ArmaModel
        P
        Q
        
        MeanX
        StdX
        
        IndexFrom
        IndexTo
        DataLength
    end
    
    methods
        function obj = MyArmaModel(arma_model, mu, std, from, to)
            obj.ArmaModel = arma_model;
            obj.P = arma_model.na;
            obj.Q = arma_model.nc;
            obj.MeanX = mu;
            obj.StdX = std;
            obj.IndexFrom = from;
            obj.IndexTo = to;
            obj.DataLength = to - from + 1;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

