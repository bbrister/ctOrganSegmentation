function mask = findBonesCT(im, units)
% Find the lungs in a CT scan using thresholding and morphology. Assumes
% that im is in Hounsfield units.

if iscolumn(units)
    units = units';
end;

% Bones window
threshLo = 0; % The most of the bone should be greater than this
threshHi = 250; % This is mostly bone, but also some soft tissues

% Apply the high threshold
mask = im >= threshHi;

% Perform closing to connect bones
mask = closeMm(mask, units, 10);

% The skeleton is the largest CC
mask = largestCC(mask);

% Close again, to fill gaps
mask = closeMm(mask, units, 25);

% Apply the low threshold
mask = mask & (im >= threshLo);

% Fill holes
mask = imfill(mask, 'holes');

end

function im = closeMm(im, units, mm)
% Morphological closing by the given number of mm

closeWidth = ceil(mm ./ units);
im = imclose(im, strel(ones(closeWidth)));

end