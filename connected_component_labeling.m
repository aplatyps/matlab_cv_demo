%------------------------------------------------------------------------
% Connected Component Labeling 
% with recursive labeling algorithm
%  
% @input arg: binary image
% @return: labeled image
% 
%------------------------------------------------------------------------

% main function
function LB = connected_component_labeling(B)
    B = negate(B);
    LB = find_components(B, 0);
end

% negate by scanning for 1s with double for-loop
function neg_B = negate(B)
    for r = 1:size(B, 1)
        for c = 1:size(B, 2) 
            if B(r,c) == 1
                B(r,c) = -1;
            end
        end
    end
    neg_B = B;
end

% find components by scanning for -1s with double for-loop
% increase label for every -1 found
function LB = find_components(B, lb)
     for i = 1:size(B, 1)
        for j = 1:size(B, 2)
            if B(i, j) == -1
                lb = lb + 1;
                B = search(B, lb, i, j);
            end
        end
     end
    LB = B;
end

% recurse within component until all -1s are labeled
function B = search(B, lb, i2, j2)
    disp(B)
    B(i2, j2) = lb;
    nset = neighbour(i2, j2);
    for n = 1:size(nset,1)
        x = nset(n, 1);
        y = nset(n, 2);
        if B(x, y) == -1
            B = search(B, lb, x, y);    
        end
    end
end

% 4-neighbour position in matrix
function nset = neighbour(x, y)
    nset = [];
    if x-1 ~=0
        nset = [nset; x-1, y];
    end
    if y-1 ~=0
        nset = [nset; x, y-1];
    end
    if y+1 <= 8
        nset = [nset; x, y+1];
    end
    if x+1 <= 8
        nset = [nset; x+1, y];
    end
end