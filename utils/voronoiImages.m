function voronoiImages(DT3)
% This function creates the voronoi images (voronoi vertices and voronoi edges)
%  of the damaged slices. For illustrations kindly look into the miccai paper.

% Construct a set of edges that join the circumcenters of neighboring
% triangles; the additional logic constructs a unique set of such edges.
numt = size(DT3,1);
T = (1:numt)';
neigh = DT3.neighbors();
cc = DT3.circumcenter();
xcc = cc(:,1);
ycc = cc(:,2);
idx1 = T < neigh(:,1);
idx2 = T < neigh(:,2);
idx3 = T < neigh(:,3);
neigh = [T(idx1) neigh(idx1,1); T(idx2) neigh(idx2,2); T(idx3) neigh(idx3,3)]';

% Plot the exterior traingles (if you want)
% figure, triplot(DT3, 'g');
% set (gca,'Ydir','reverse')
% hold on;
figure
% Plot the voronoi edges (medial axis) (brown)
plot(xcc(neigh), ycc(neigh), '-', 'Color',[0.6 0.2 0]);
hold on;

% Plot the voronoi vertices (magenta)
plot(cc(:,1),cc(:,2),'*','MarkerEdgeColor',[0.75 0 0.75],'MarkerSize',0.3)
set (gca,'Ydir','reverse')
set(gca,'visible','off')
hold off;

end


