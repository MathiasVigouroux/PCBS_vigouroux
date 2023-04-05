
    % Link between Inter Trial Intervals and Foreperiods
    figure(1)
    scatter(transpose(ITI), transpose(Whole_expe))
    grid on
    title('Correlation FP & ITI')  
    xlabel('Inter Trial Interval')
    ylabel('Foreperiods (negatives foreperiods were replaced by 0')
    
    % Link between the theoretical foreperiods and presented foreperiods
    actual_fp = total_target_start - total_cue_stop;
    diff = actual_fp - Whole_expe;
    
    figure(2)
    plot(transpose(diff))
    grid on
    title('Dependence between the theoretical foreperiods and presented foreperiods') 
    xlabel('Trial n° (per block)')
    ylabel('Difference in actual - theoretical FP the beep are 0.08 long')
    
    % Link between the difference and the presented foreperiod
    figure(3)
    scatter(transpose(diff),transpose(Whole_expe))
    grid on
    title('Dependence between the diff and theoretical FP') 
    xlabel('Difference in actual - theoretical FP the beep are 0.08 long')
    ylabel('Theoretical foreperiod')
    
    
    % Link between the difference and the presented foreperiod
    figure(4)
    plot(transpose(actual_fp))
    grid on
    title('Checking if the the presented FP are positive') 
    xlabel('Trial n° per block')
    ylabel('Presented foreperiod')
    
    
    
    % Link RT and std of the latent distribution
    figure(5)
    scatter(sigma_list, mean(transpose(total_rt)))
    grid on
    title('Depends of the variation on the rt ') 
    xlabel('Variance of the latente distribution')
    ylabel('Mean of the Response Time')

