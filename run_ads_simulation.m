% simCmd = './run_ads_wrapper.sh'; % Linux ADS wrapper script
simCmd = './run_ads_wrapper.bat'; % Windows ADS wrapper script

[status, output] = system(simCmd);
if status ==0
    fprintf('Simulation completed successfully\n');
else
    fprintf('Simulation failed with status %d\n', status);
    fprintf('Error output: %s\n', output);
end 