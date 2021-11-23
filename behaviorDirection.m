function angle = behaviorDirection(H,V)

AVE_WINDOW = 10;

angle = angleWithPositiveXAxis(nanmean(H(:,end-AVE_WINDOW:end),2) - nanmean(H(:,1:AVE_WINDOW),2),....
        nanmean(V(:,end-AVE_WINDOW:end),2) - nanmean(V(:,1:AVE_WINDOW),2));