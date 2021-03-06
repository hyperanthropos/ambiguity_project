function [ matlabbatch ] = create_second_level( input )
% function to create second level batch
%   creates basic batch to be modified for different onsets/pmods

switch input
    case 'BASIC'
        
        %% STANDARD BATCH FOR EACH PMOD
        
        matlabbatch{1}.spm.stats.factorial_design.dir = '<UNDEFINED>';
        matlabbatch{1}.spm.stats.factorial_design.des.pt.pair.scans = '<UNDEFINED>';
        matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'risk > ambi';
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'ambi > risk';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.delete = 1;
        matlabbatch{4}.spm.stats.factorial_design.dir = '<UNDEFINED>';
        matlabbatch{4}.spm.stats.factorial_design.des.t2.scans1 = '<UNDEFINED>';
        matlabbatch{4}.spm.stats.factorial_design.des.t2.scans2 = '<UNDEFINED>';
        matlabbatch{4}.spm.stats.factorial_design.des.t2.dept = 1;
        matlabbatch{4}.spm.stats.factorial_design.des.t2.variance = 1;
        matlabbatch{4}.spm.stats.factorial_design.des.t2.gmsca = 0;
        matlabbatch{4}.spm.stats.factorial_design.des.t2.ancova = 0;
        matlabbatch{4}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{4}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{4}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{4}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{4}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{4}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{4}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{4}.spm.stats.factorial_design.globalm.glonorm = 1;
        matlabbatch{5}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{5}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{5}.spm.stats.fmri_est.method.Classical = 1;
        matlabbatch{6}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{6}.spm.stats.con.consess{1}.tcon.name = 'risk > ambi';
        matlabbatch{6}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
        matlabbatch{6}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{6}.spm.stats.con.consess{2}.tcon.name = 'ambi > risk';
        matlabbatch{6}.spm.stats.con.consess{2}.tcon.weights = [-1 1];
        matlabbatch{6}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{6}.spm.stats.con.consess{3}.tcon.name = 'risk pos';
        matlabbatch{6}.spm.stats.con.consess{3}.tcon.weights = [1 0];
        matlabbatch{6}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        matlabbatch{6}.spm.stats.con.consess{4}.tcon.name = 'ambi pos';
        matlabbatch{6}.spm.stats.con.consess{4}.tcon.weights = [0 1];
        matlabbatch{6}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        matlabbatch{6}.spm.stats.con.consess{5}.tcon.name = 'risk neg';
        matlabbatch{6}.spm.stats.con.consess{5}.tcon.weights = [-1 0];
        matlabbatch{6}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        matlabbatch{6}.spm.stats.con.consess{6}.tcon.name = 'ambi neg';
        matlabbatch{6}.spm.stats.con.consess{6}.tcon.weights = [0 -1];
        matlabbatch{6}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
        matlabbatch{6}.spm.stats.con.consess{7}.fcon.name = 'effects of interest';
        matlabbatch{6}.spm.stats.con.consess{7}.fcon.weights = [1 0; 0 1];
        matlabbatch{6}.spm.stats.con.consess{7}.fcon.sessrep = 'none';
        matlabbatch{6}.spm.stats.con.delete = 1;
        matlabbatch{7}.spm.stats.factorial_design.dir = '<UNDEFINED>';
        matlabbatch{7}.spm.stats.factorial_design.des.t1.scans = '<UNDEFINED>';
        matlabbatch{7}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{7}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{7}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{7}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{7}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{7}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{7}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{7}.spm.stats.factorial_design.globalm.glonorm = 1;
        matlabbatch{8}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{8}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{8}.spm.stats.fmri_est.method.Classical = 1;
        matlabbatch{9}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{9}.spm.stats.con.consess{1}.tcon.name = 'risk>ambi';
        matlabbatch{9}.spm.stats.con.consess{1}.tcon.weights = 1;
        matlabbatch{9}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{9}.spm.stats.con.consess{2}.tcon.name = 'ambi>risk';
        matlabbatch{9}.spm.stats.con.consess{2}.tcon.weights = -1;
        matlabbatch{9}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{9}.spm.stats.con.delete = 1;
        matlabbatch{10}.spm.stats.factorial_design.dir = '<UNDEFINED>';
        matlabbatch{10}.spm.stats.factorial_design.des.t1.scans = '<UNDEFINED>';
        matlabbatch{10}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{10}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{10}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{10}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{10}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{10}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{10}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{10}.spm.stats.factorial_design.globalm.glonorm = 1;
        matlabbatch{11}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{11}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{11}.spm.stats.fmri_est.method.Classical = 1;
        matlabbatch{12}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{12}.spm.stats.con.consess{1}.tcon.name = 'risk pos';
        matlabbatch{12}.spm.stats.con.consess{1}.tcon.weights = 1;
        matlabbatch{12}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{12}.spm.stats.con.consess{2}.tcon.name = 'risk neg';
        matlabbatch{12}.spm.stats.con.consess{2}.tcon.weights = -1;
        matlabbatch{12}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{12}.spm.stats.con.delete = 1;
        matlabbatch{13}.spm.stats.factorial_design.dir = '<UNDEFINED>';
        matlabbatch{13}.spm.stats.factorial_design.des.t1.scans = '<UNDEFINED>';
        matlabbatch{13}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{13}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{13}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{13}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{13}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{13}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{13}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{13}.spm.stats.factorial_design.globalm.glonorm = 1;
        matlabbatch{14}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{13}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{14}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{14}.spm.stats.fmri_est.method.Classical = 1;
        matlabbatch{15}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{14}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{15}.spm.stats.con.consess{1}.tcon.name = 'ambi pos';
        matlabbatch{15}.spm.stats.con.consess{1}.tcon.weights = 1;
        matlabbatch{15}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{15}.spm.stats.con.consess{2}.tcon.name = 'ambi neg';
        matlabbatch{15}.spm.stats.con.consess{2}.tcon.weights = -1;
        matlabbatch{15}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{15}.spm.stats.con.delete = 1;
        
    case 'ANOVA'
        
        %% BATCH FOR COMPARING PMODS
        
        matlabbatch{1}.spm.stats.factorial_design.dir = '<UNDEFINED>';
        matlabbatch{1}.spm.stats.factorial_design.des.anova.icell.scans = '<UNDEFINED>';
        matlabbatch{1}.spm.stats.factorial_design.des.anova.dept = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.anova.variance = 1;
        matlabbatch{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
        matlabbatch{1}.spm.stats.factorial_design.des.anova.ancova = 0;
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
        matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
        matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'effects of interest';
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = '<UNDEFINED>';
        matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.delete = 1;

end

end % end function