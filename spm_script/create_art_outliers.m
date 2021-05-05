function create_art_outliers(job_info)

    movement_params = dir([job_info.func_dir 'art_regression_outliers*']);
    movement = load([job_info.func_dir movement_params(1).name]);
    outliers = load([job_info.func_dir movement_params(2).name]);

    if isempty(outliers.R)
        outliers=zeros(size(outliers.R,1),1);
    end

    params = cat(2,movement.R,outliers);
    filename = [job_info.func_dir 'regression_params_and_outliers.txt'];
    fid = fopen(filename, 'wt');
    if fid > 0
         fprintf(fid,'%d %d %d %d %d %d %d %d\n',params');
         fclose(fid);
    end
end
