
% need the following functions: 
% saveCurGraphs
% outlineBounds
% boundedLine
% and "previous_file.mat" somewhere on your path
 load('previous_file.mat')
    [ref_file, ref_folder_name] = uigetfile('*.xlsx','Click on your xls file.',previous_file);
    if isdir(ref_folder_name)
        previous_file = fullfile(ref_folder_name, ref_file);
        save('previous_file', 'previous_file')
    else
        display('You did not pick a folder.')
        return
    end

    cd(ref_folder_name);
    
joh1 = xlsread(fullfile(ref_folder_name,ref_file),2);

figure(1); clf; 

nbTracks = floor(size(joh1,2)/5);

xIntmin = 0.1;

subplot(2,1,1)

hold on;

    plot(joh1(:,2),joh1(:,3));



for n = 1:nbTracks

    figure(1); hold on;
    plot(joh1(:,2+5*n),joh1(:,3+5*n));
end

set(gca,'FontSize',15)
set(gca,'box','on')
xlabel('Time (s)');
ylabel('Intensity (AU)')
xlim([-3 17])

% figure(2); clf;
 
subplot(2,1,2)
plot(joh1(:,2),joh1(:,4).*65);

for n = 1:nbTracks

    figure(1); hold on;
    subplot(2,1,2)
    plot(joh1(:,2+5*n),joh1(:,4+5*n).*65);
end

set(gca,'FontSize',15)
xlabel('Time (s)');
ylabel('Internalization (nm)')
xlim([-3 17])

allTracks  = nan(size(joh1,1)*2,nbTracks);
allDistances = nan(size(joh1,1)*2,nbTracks);

%%
for n = 1:nbTracks

% n = 1;

% x0 = joh1(:,47);
% y0 = joh1(:,48);
% 
% x0 = x0(~isnan(x0));
% y0 = y0(~isnan(y0));

x1 = joh1(:,2+5*(n-1));
y1 = joh1(:,3+5*(n-1));
y2 = joh1(:,4+5*(n-1));

x1 = x1(~isnan(x1));
y1 = y1(~isnan(y1));
y2 = y2(~isnan(y2));

xs = transpose(round(min(x1),1):0.1:max(x1));

% xs = xs(~isnan(x1));
interpolated = interp1(x1,y1,xs,'linear','extrap');
interpolatedDistance = interp1(x1(2:end),y2,xs,'linear','extrap');
% interpolatedDistance = [0; interpolatedDistance];

allTimes(1:length(xs),n)  = xs;
allTracks(1:length(interpolated),n) = interpolated;
allDistances(1:length(interpolatedDistance),n) = interpolatedDistance;

end

alignmentMin = min(allTimes(1,:))-1
% alignmentMinIndex = alignmentMin/0.1

allTracksAlign = nan(size(joh1,1)*2,nbTracks);
allDistancesAlign = nan(size(joh1,1)*2,nbTracks);

%%
for n = 1:nbTracks
%
%     n = 1;
    alignmentCurrent = min(allTimes(1,n));
%     alignmentCurrentIndex = alignmentCurrent./alignmentMinIndex
    
    offsetIndex = (alignmentCurrent-alignmentMin)*10
    
    curTrack = allTracks(:,n);
    curTrack = curTrack(~isnan(curTrack))
%     curTrack = allTracks(~isnan(allTracks(:,n)));    
    allTracksAlign(offsetIndex:length(curTrack)+offsetIndex-1,n) = curTrack;

    curDistance = allDistances(:,n);
    curDistance = curDistance(~isnan(curDistance))
%     curDistance = allDistances(~isnan(allDistances(:,n)))
    allDistancesAlign(offsetIndex:length(curDistance)+offsetIndex-1,n) = curDistance;
    
end
%%
avgTracks = nanmean(allTracksAlign,2)
avgDistances = nanmean(allDistancesAlign,2)

% allTracksNotNan = allTracks(~isnan(allTracks));

stdTracks = nanstd(allTracksAlign,[],2)
stdDistances = nanstd(allDistancesAlign,[],2)


% avgTracks = nanmean(

% stdTracks = std(allTracks,2)

% figure(2); clf;
% subplot(2,1,1);
% plot(0.1:0.1:length(avgTracks)/10,avgTracks)
% 
% subplot(2,1,2);
% plot(0.1:0.1:length(avgDistances)/10,avgDistances.*65)

%%
figure(3); clf;
subplot(2,1,1);
[h,p] = boundedline((0.1+alignmentMin:0.1:(length(avgTracks)/10)+alignmentMin)',avgTracks',stdTracks','.k', 'alpha')
xlim([0 14])
    outlinebounds(h,p)
set(gca,'FontSize',15)
set(gca,'box','on')
xlabel('Time (s)')
ylabel('Intensity (AU)')
    
subplot(2,1,2);
% plot(0.1:0.1:length(avgDistances)/10,avgDistances.*65)
[h2,p2] = boundedline((0.1+alignmentMin:0.1:(length(avgDistances)/10)+alignmentMin)',avgDistances'.*65,stdDistances'.*65,'.k', 'alpha')
xlim([0 14])
ylim([0 500])
    outlinebounds(h2,p2)
    set(gca,'FontSize',15)
xlabel('Time (s)')
set(gca,'box','on')
ylabel('Internalization (nm)')
%%
figure(4); clf;

[h,p] = boundedline((0.1+alignmentMin:0.1:(length(avgTracks)/10)+alignmentMin)',avgTracks',stdTracks','.b', 'alpha');
xlim([0 14])
    outlinebounds(h,p)

hold on;

[h2,p2] = boundedline((0.1+alignmentMin:0.1:(length(avgDistances)/10)+alignmentMin)',avgDistances./6',stdDistances./6','.r', 'alpha');
xlim([0 14])
% ylim([0 500])
    outlinebounds(h2,p2)
    
    set(gca,'FontSize',15)
    set(gca,'box','on')
ylabel('Intensity or internalization')
xlabel('Time (s)')

times = (0.1+alignmentMin:0.1:(length(avgTracks)/10)+alignmentMin);

alignedData = [times', avgTracks, stdTracks, avgDistances, stdDistances];
    
csvwrite(strcat(ref_file(1:end-5), '_alignedData.csv'),alignedData)
csvwrite(strcat(ref_file(1:end-5), '_alignedIntensities.csv'),allTracksAlign)
csvwrite(strcat(ref_file(1:end-5), '_alignedDistances.csv'),allDistancesAlign)

saveCurGraphs(strcat(ref_file(1:end-5), 'alignedIntensityDistance'), [1 3 4])