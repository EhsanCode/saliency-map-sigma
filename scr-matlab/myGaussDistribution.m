function gaussFilterTemp = myGaussDistribution(gaussSigma)
halfWide = 3 * gaussSigma;
[xx,yy] = meshgrid(-halfWide:halfWide, -halfWide:halfWide);
gaussFilterTemp = exp(-1/(2*gaussSigma^2) * (xx.^2 + yy.^2));
