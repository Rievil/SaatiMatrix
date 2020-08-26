classdef SatiMatrix < SupSati
    properties (SetAccess = public)        
        InTable table;
        WTable table;
        Score (:,1);
        OutTable; 
        ScoreMat (:,:) double;
        
    end

    properties (Hidden)
        InT double;
        Names (:,1) string;
        Demand (:,1) string;
        Min (:,1);
        Max (:,1);
        Wheights table;
        Si (:,1);
        Ri (:,1);
        Fi (:,1);       
        ParamCount (1,1);
        ObservCount (1,1);
        Columns;
        WFig;
        WUITable;     
        SelRow;
        SelCol;
        Path char;        
    end
    
    methods (Access = public)
        %Object constructor------------------------------------------------
        function obj=SatiMatrix(InT,Columns,Path)
            obj@SupSati(InT,Columns);
            obj.Path=Path;
            %obj.Columns=Columns;
            
            %obj.Names=Names;
            obj.ParamCount=size(obj.InT,2);
            obj.ObservCount=size(obj.InT,1);
            
            for i=1:obj.ParamCount
                obj.Min(i,1)=min(obj.InT(:,i));
                obj.Max(i,1)=max(obj.InT(:,i));
            end
        end
        
        %Count all score in saati matrix-----------------------------------
        function out=CountSaati(obj)
            for i=1:obj.ParamCount
                num=obj.WTable{i,1:end-1};
                b=num(1);
                for j=1:obj.ParamCount
                    b=b*num(j);
                end
                obj.Si(i,1)=b;
                obj.Ri(i,1)=obj.Si(i,1)^(1/obj.ParamCount);
            end
            
            for i=1:obj.ParamCount
                obj.Fi(i,1)=obj.Ri(i,1)/sum(obj.Ri);
            end
            
            score=zeros(obj.ObservCount,obj.ParamCount);
            for row=1:obj.ObservCount
                for col=1:obj.ParamCount
                    score(row,col)=GetScore(obj,row,col);
                end
            end
            obj.ScoreMat=score;
            obj.Score=sum(score,2);
            obj.OutTable=[obj.InTable, table(obj.Score,'VariableNames',"Score")];
            out=obj.OutTable;
        end
        
        %Count a single score----------------------------------------------
        function score=GetScore(obj,row,col)
            if strcmp(obj.WTable{col,end},"Min")
                score=obj.Fi(col)*((obj.InT(row,col)-obj.Min(col))/(obj.Max(col)-obj.Min(col)));
            else
                score=obj.Fi(col)*((obj.Max(col)-obj.InT(row,col))/(obj.Max(col)-obj.Min(col)));
            end
        end
        
        %Create a wheight table--------------------------------------------
        function DrawTable(obj)
            
            demmand=categorical(["Min","Max"]);
            obj.WTable=table('RowNames',obj.Names);
            for i=1:obj.ParamCount
                NewTtable=table(linspace(1,1,obj.ParamCount)','VariableNames',obj.Names(i,1));
                obj.WTable=[obj.WTable, NewTtable];
            end
            
            dem(1:obj.ParamCount,1)=demmand(1);
            obj.WTable=[obj.WTable, table(dem,'VariableNames',"Demmand")];
            
            pos=[200 200 obj.ParamCount*100 obj.ParamCount*25];
            posTab=[0 0 pos(3) pos(4)];
            
            obj.WFig=uifigure('Name','Wheight table','Position',pos,...
                'CloseRequestFcn',@(src,event) DeleteFig(obj,event));
            
            obj.WUITable=uitable(obj.WFig,'Data',obj.WTable,...
                'Position',posTab,...
                'ColumnEditable',true(1:obj.ParamCount+1),...
                'DisplayDataChangedFcn',@(src,event)ChangedCell(obj,event),...
                'CellSelectionCallback',@(src,event)SelectedTable(obj,event));
            
            s = uistyle('BackgroundColor','yellow');
            coor(:,1)=double(1:obj.ParamCount);
            diagonal=[coor,coor];
            addStyle(obj.WUITable,s,'cell',diagonal);
            if isfile([obj.Path '\SatiMatrixVar.mat'])
                load(obj);
            end
        end
        
        %Callback for selection in table-----------------------------------
        function SelectedTable(obj,event)
            obj.SelRow=event.Indices(1,1);
            obj.SelCol=event.Indices(1,2);
        end
        
        %Callback for change in uitable------------------------------------
        function ChangedCell(obj,event)
            if obj.SelCol<(obj.ParamCount+1)
                if obj.SelRow==obj.SelCol
                    obj.WUITable.Data{obj.SelRow,obj.SelCol}=1;
                else
                    obj.WUITable.Data{obj.SelCol,obj.SelRow}=1/obj.WUITable.Data{obj.SelRow,obj.SelCol};
                end
            end
        end
        
        %Delete prompt for uifigure----------------------------------------
        function DeleteFig(obj,event)
            obj.WTable=obj.WUITable.Data;
            
            
            answer = questdlg('Do you want to save in current folder?', ...
                'Saving window','Yes','No','No');
            % Handle response
            switch answer
                case 'Yes'
                    delete(obj.WFig);
                    save(obj);
                case 'No'
                    delete(obj.WFig);
            end
            
        end
    end
end