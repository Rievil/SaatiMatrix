classdef SupSati < handle
    properties
    end
    
    methods
        %Superclass constructor--------------------------------------------
        function obj=SupSati(InT,Columns)
            obj.InTable=InT;
            obj.InT=InT{:,Columns};
            obj.Columns=Columns;            
            obj.Names={InT.Properties.VariableNames{Columns}};
        end
        
        %Save of object----------------------------------------------------
        function save(obj)
            tmp=obj;
            filename=[obj.Path '\SatiMatrixVar.mat'];
            save(filename,'tmp');
        end
        
        %Load of object----------------------------------------------------
        function load(obj)
           filename=[obj.Path '\SatiMatrixVar.mat'];
           load(filename);
           if ~isempty(obj.WUITable)
               if isvalid(obj.WUITable)
                    obj.WUITable.Data=tmp.WTable;
               end
           end
           
           obj.WTable=tmp.WTable;
        end
        
        %export wttable----------------------------------------------------
        function export(obj)
            filename=[obj.Path '\WTable.xlsx'];
            exTable=[table(obj.Names,'VariableNames',"Names"), obj.WTable,...
                table(obj.Si,'VariableNames',"Si"),...
                table(obj.Ri,'VariableNames',"Ri"),...
                table(obj.Fi,'VariableNames',"Fi")];
            
            writetable(exTable,filename);
        end
    end
end