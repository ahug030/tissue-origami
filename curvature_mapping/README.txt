Run "Hughes_StackToCurvatureSurface.m”, takes as input a set of example images for a miura object, 100.tif-130.tif
	--You will have to read through and change various parameters relating to 
	your particular image stack.
	--Depends on compiled versions of smoothpatch_curvature_double.c, 
	smoothpatch_inversedistance_double.c, and vertex_neighbors_double.c,
	(see code in Hughes_StackToCurvatureSurface.m:
	% Compile c-code functions from matlab package "Smooth Triangulated Mesh"
	%by Dirk Jan Kroon
	% mex smoothpatch_curvature_double.c -v
	% mex smoothpatch_inversedistance_double.c -v
	% mex vertex_neighbours_double.c -v
	)
	--This will depend on your OS.. see:
	https://www.mathworks.com/help/matlab/matlab_external/what-you-need-to-build-mex-files.html
