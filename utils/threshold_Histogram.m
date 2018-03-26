% This function takes an image (2D array) and returns a two 1D array of int 
% and floats. One array has the frequency and the other array has the binwidth
% % It computes the uniform binwidth using the Scotts rule. As the final
% output it returns the threshold based on the interval size defined by the user

% Input : 2D array
% Outputof first function: 1D araay of frequency
%                          1D array of lower bin Value
% Final Output: Threshold  

function thresh = threshold_Histogram(image,interval_size,flag)

% if(numel(size(image)) ~=2)
%     error('The input is not a 2D array');
% end

magGrad = canny_edge_histogram(image);              % computes the gradient mag image

N=size(magGrad,1)*size(magGrad,2);
binWidth=3.49*std(magGrad(:))/(N^(1/3));            % Scotts rule

maxValue=max(magGrad(:)) + binWidth;
minValue=min(magGrad(:));

range=maxValue-minValue;                            % range of values

binTotal=round(range/binWidth);                     % Total number of bins

freq = zeros(binTotal,1);
bins = zeros(binTotal,1);

tic
parfor i=1:binTotal
    
    low = minValue + (i-1)*binWidth ;
    high = low + binWidth;
    
    freq(i) = numel(find((magGrad>=low) & (magGrad<high)));   % computing the frequency between low and high
    bins(i) = low;
end

thresh = compute_Threshold(freq,bins,interval_size); 
fprintf('Time for computing threshold is %f secs \n',toc) 

thresh=gather(thresh);

if(flag==true)
    figure,plot(freq);
end

end

% Doing a search in the freq array to find the threshold. Find the index whose 
% value doesnt change over a fixed interval defined by user.

function threshold = compute_Threshold(freq,bins,interval_size)

for i=interval_size+1 : length(freq)-interval_size
    
    count=0; 
    for j= i-interval_size : i+interval_size
        if ( abs(freq(i)-freq(j))>12)                      % 12 is the error which can be tolerated. Emperically found.
            break;
        else
            count=count+1;
        end
    end
    
    if(count==1+(2*interval_size))
        threshold = bins(i);
        return
    end
    
end

error('threshold was not computed as the interval size was too big');
end

