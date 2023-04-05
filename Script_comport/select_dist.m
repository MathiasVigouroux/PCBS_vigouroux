
rng('shuffle')

%% parameters

t = 0:0.001:5;
m = 2.5;
s = logspace(log10(0.04), log10(0.95), 4);
% s = linspace(0.04, 0.95, 5);

n = 120;


%% sample some foreperiods and plot
figure(1);clf;

foreperiods = nan(n,size(s,2));

for i = 1:size(s,2)
    
x = normpdf(t,m,s(i));

foreperiods(:,i) = randsample(t, n, true, x);

plot((i-1)*n+1:i*n, foreperiods(:,i), 'Marker','*','LineStyle','none'); hold all;

end

xlabel('trial')
ylabel('foreperiod [s]')

min(foreperiods)
max(foreperiods)
hline(m,'k');
ylim([0, max(t)])