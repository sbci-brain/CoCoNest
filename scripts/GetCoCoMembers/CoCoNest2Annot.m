function result = CoCoNest2Annot(name,kseq,cocoPath)

    
    % Add CoCoNest Path
    coco_path = genpath(cocoPath); 
    addpath(coco_path)

    % Load Tree Data
    load(name+"_prune_struct.mat")

    % Load SBCI Data
    load("sbci_mapping.mat") 

    for k = str2num(kseq)

        % Prune Tree
        tree_idx = tree2IDX(prune_struct,k);
        
        % Change CC label from 4 to 0 
        tree_idx(tree_idx == 4) = 0; 
       
        % Upsample Labels
        tree_labs = upsample_data(sbci_mapping,tree_idx); 
        
        %%% Create Annot File Stuff %%%
        for hemi = ["L","R"]

            if hemi == "L"
                idx = tree_labs(1:32492); % Left Hemi
            else
                idx = tree_labs(32493:end); % Right Hemi
            end

            n_labels = length(unique(idx)); 
            vertices = 0:(length(idx)-1); 
        
            % Create Color Table
            colors = round(distinguishable_colors(n_labels) * 255); 
            ct.numEntries = n_labels; 
            ct.orig_tab = 'Random Colors'; 
            ct.struct_names = arrayfun(@(x) sprintf('Cluster %d', x), unique(idx), ...
                'UniformOutput',false); 
            integer_values = int32(colors(:,1) + colors(:,2)*2^8 + colors(:,3)*2^16);

            % Remap IDX to Integer Values
            mapping = containers.Map(unique(idx), unique(integer_values,'stable')); 
            remap_idx = arrayfun(@(x) mapping(x), idx); 
            ct.table = [colors, zeros(n_labels,1), integer_values];

            
            if ((length(unique(tree_idx))-1) ~= k)
                disp("CoCoNest Member with " + string(k) + " parcels not available");
                k = length(unique(tree_idx))-1
            end

            % Write Annot
            write_annotation(strcat(cocoPath,'/scripts/output/labels/',hemi,'_',name,'_',...
                string(k),'_fslr32k.annot'), vertices, remap_idx, ct);    
        end

        % Save new k to temp file 
        fileID = fopen('temp_k.txt','a'); 
        fprintf(fileID, '%d\n', k);
        fclose(fileID);
    end

    result = 1; 
end

