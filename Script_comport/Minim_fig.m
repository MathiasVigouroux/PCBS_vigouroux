function Minim_fig(Id, mean_,time_string,ITI,Whole_expe,total_target_start,total_cue_stop,sigma_list,total_rt, total_false_alert)
    % Link between Inter Trial Intervals and Foreperiods
    figure(1);
    scatter(transpose(ITI), transpose(Whole_expe));
    grid on;
    title('Correlation FP & ITI')  ;
    xlabel('Inter Trial Interval');
    ylabel('Foreperiods (negatives foreperiods were replaced by 0');
    fig1_name = sprintf('K:/Matlab_Project/Code_behavioral/Data_participants/%s_fig1_mean_%s_time_%s.png',...
        Id, string(mean_),time_string);
    saveas(gcf,fig1_name)
    
    % Link between the theoretical foreperiods and presented foreperiods
    actual_fp = total_target_start - total_cue_stop;
    diff = actual_fp - Whole_expe;
    
    figure(2);
    plot(transpose(diff));
    grid on;
    title('Dependence between the theoretical foreperiods and presented foreperiods') ;
    xlabel('Trial n° (per block)');
    ylabel('Difference in actual - theoretical FP');
    fig2_name = sprintf('K:/Matlab_Project/Code_behavioral/Data_participants/%s_fig2_mean_%s_time_%s.png',...
    Id, string(mean_),time_string);
    saveas(gcf,fig2_name)
    
    % Link between the difference and the presented foreperiod
    figure(3);
    scatter(transpose(diff),transpose(Whole_expe));
    grid on;
    title('Dependence between the diff and theoretical FP') ;
    xlabel('Difference in actual - theoretical FP');
    ylabel('Theoretical foreperiod');
    fig3_name = sprintf('K:/Matlab_Project/Code_behavioral/Data_participants/%s_fig3_mean_%s_time_%s.png',...
        Id, string(mean_),time_string);
    saveas(gcf,fig3_name)

        % Link between the difference and number of pressing
    figure(4);
    scatter(transpose(diff),transpose(total_false_alert));
    grid on;
    title('Dependence between the diff and too early pressing') ;
    xlabel('Difference in actual - theoretical FP');
    ylabel('Number of too early pressing');

    fig4_name = sprintf('K:/Matlab_Project/Code_behavioral/Data_participants/%s_fig4_mean_%s_time_%s.png',...
        Id, string(mean_),time_string);
    saveas(gcf,fig4_name)


        % Link between the difference and number of pressing (zoom)
        figure(5);
    scatter(transpose(diff),transpose(total_false_alert));
    grid on;
    title('Dependence between the diff and too early pressing') ;
    xlabel('Difference in actual - theoretical FP');
    ylabel('Number of too early pressing');
    ylim([-0.01 0.01]);
    fig5_name = sprintf('K:/Matlab_Project/Code_behavioral/Data_participants/%s_fig5_mean_%s_time_%s.png',...
        Id, string(mean_),time_string);
    saveas(gcf,fig5_name)
    
    
    % Link between the difference and the presented foreperiod
    figure(6);
    plot(transpose(actual_fp));
    grid on;
    title('Checking if the the presented FP are positive') ;
    xlabel('Trial n° per block');
    ylabel('Presented foreperiod');
    fig6_name = sprintf('K:/Matlab_Project/Code_behavioral/Data_participants/%s_fig6_mean_%s_time_%s.png',...
        Id, string(mean_),time_string);
    saveas(gcf,fig6_name)
    
    
    
    % Link RT and std of the latent distribution
    figure(7);
    scatter(sigma_list, log(mean(transpose(total_rt))));
    grid on;
    title('Depends of the variation on the rt ') ;
    xlabel('Variance of the latente distribution');
    ylabel('Log Mean of the Reaction Time');
    fig7_name = sprintf('K:/Matlab_Project/Code_behavioral/Data_participants/%s_fig7_mean_%s_time_%s.png',...
        Id, string(mean_),time_string);
    saveas(gcf,fig7_name)

end