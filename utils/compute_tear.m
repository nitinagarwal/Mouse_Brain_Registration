function tear_pt = compute_tear(DT3,alpha)
% input is a trignaulation and alpha (medial axis length - number of edges)
% output is the tear pts on the contour whose medial len > alpha

numt = size(DT3,1);
T = (1:numt)';
neigh = DT3.neighbors();

idx1 = T < neigh(:,1);
idx2 = T < neigh(:,2);
idx3 = T < neigh(:,3);
neigh = [T(idx1) neigh(idx1,1); T(idx2) neigh(idx2,2); T(idx3) neigh(idx3,3)]';
neigh=neigh';       

[ids, medial_len] = compute_graph(neigh);

ids = ids(find(medial_len>alpha));

tear_pts={};        % canditate tear points

for j=1:length(ids)    
    idx=zeros(1,2);
    for i=1:length(ids{j})
         idx(end+1,:)=DT3.Points(DT3.ConnectivityList(ids{j}(i),1),:);
         idx(end+1,:)=DT3.Points(DT3.ConnectivityList(ids{j}(i),2),:);
         idx(end+1,:)=DT3.Points(DT3.ConnectivityList(ids{j}(i),3),:);
    end
    idx(1,:)=[];

tear_pts{j} = unique(idx,'rows');
end

% computing connectivity using DT3 graph itself. 
pts = DT3.Points;
numt = size(DT3.Points,1);
connc = DT3.ConnectivityList;
idx1 = [connc(:,1) connc(:,2)];
idx2 = [connc(:,1) connc(:,3)];
idx3 = [connc(:,2) connc(:,3)];
neigh = [idx1; idx2; idx3];

neigh = unique(neigh,'rows');
reverse = [neigh(:,2) neigh(:,1)];
[~,ia,~]=intersect(neigh, reverse,'rows');
inter = neigh(ia,:);
neigh=setdiff(neigh,reverse,'rows');

for i=1:length(inter)/2
    query=inter(i,:);
    query=fliplr(query);
    [id,~]=ismember(inter,query,'rows');
    inter(find(id==1),:)=[];  
end
neigh=[neigh; inter];

[ids, ~] = compute_graph(neigh);

tear_contour_pts={};

for i=1:length(ids)
 tear_contour_pts{i} = pts(ids{i},:);    
end

% there maybe cases where the voronoi centers might be disconnected
% resulting in partial tear selection. 
tear_pt={};
index=[];

for k=1:length(tear_pts)
    for l=1:length(tear_contour_pts)
        common = intersect(tear_pts{k},tear_contour_pts{l},'rows');
        if(~isempty(common) && length(common)==length(tear_pts{k}))
            if(~ismember(l,index))
                index=[index;l];
                tear_pt{k}=tear_contour_pts{l};
                break;
            end
        end
    end
end

tear_pt=tear_pt(~cellfun('isempty',tear_pt));

end


function [ids, medial_len] = compute_graph(neigh)
% input is edge connectivity

    G=graph(neigh(:,1), neigh(:,2));

    bins=conncomp(G);       % connected component of G. 
    sz = max(bins);
    binsz = zeros(sz, 1);

    for i=1:sz
       binsz(i)=numel(find(bins==i));
    end

    [~,id] = sort(binsz,'descend');

    % selecting top 10 max connected components
    ids={};

    for i=1:10
        ids{i} = find(bins==id(i));
        SG = subgraph(G,ids{i});
        M=distances(SG);
        medial_len(i)=max(M(:));       % dis b/w farthest vertices    
    end

end



