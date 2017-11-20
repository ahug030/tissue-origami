%choose the directory containing a set of binary z slices describing a 3D object
folder_name = uigetdir('','choose directory to segmented z slices');
cd(folder_name)
clear all;
close all;

% Compile c-code functions from matlab package "Smooth Triangulated Mesh"
%by Dirk Jan Kroon
% mex smoothpatch_curvature_double.c -v
% mex smoothpatch_inversedistance_double.c -v
% mex vertex_neighbours_double.c -v

%Have to start with an image set that's an appropriate xy size, probably
%not much larger than 500x500

%input image size
xsize=659;
ysize=697;
%To do with how base images are named
numoffset=100;
numslices=31;
%microns per z slice
slice2microns=40;
%binning factor for input images
bin=4;
%original microns/pixel in x,y. 
xy2microns=bin*2.67;
%This is just a value between white and black for the segmented images
isovalue=0.5;
%Raw mesh smoothing, more iterations are expensive!
smoothiters=250;
%Downsampling patch returned by marching cubes prior to further processing
reducepatchfactor=0.1;
%initial view settings
viewaz=340;
viewel=70;
%sets limits of curvature range plotted onto final surface
curvegate=0.004;

%Creating raw surface via marching cubes (MarchingCubes.m by Peter Hammer)
C=zeros(ysize,xsize,numslices);
for i=numoffset:(numoffset+numslices-1),
    instring=sprintf('%d.tif',i);
    Cmember=imread(instring);
    C(:,:,i-99)=Cmember;
end;
[X,Y,Z]=meshgrid(1:xsize,1:ysize,1:numslices);
[F,VV]=MarchingCubes(X,Y,Z,C,isovalue);
V(:,3)=VV(:,3).*slice2microns;
V(:,2)=(max(VV(:,2))-VV(:,2)).*xy2microns;
V(:,1)=(max(VV(:,1))-VV(:,1)).*xy2microns;
fprintf('Marching cubes done...')

%Plot raw surface
figure
trimesh(F,V(:,1),V(:,2),V(:,3))
axis equal
axis vis3d
view(viewaz,viewel)

FV.faces=F;
FV.vertices=V;
%smoothing raw surface
FV2=smoothpatch(FV,1,smoothiters,1);
fprintf('Smoothing done...')
%simplifying mesh
FV2red=reducepatch(FV2,reducepatchfactor);
Fsmoothred=FV2red.faces;
Vsmoothred=FV2red.vertices;
%Plot smoothed, simplified mesh
figure
trimesh(Fsmoothred,Vsmoothred(:,1),Vsmoothred(:,2),Vsmoothred(:,3))
axis equal
axis vis3d
view(viewaz,viewel)

%Calculate local mesh curvatures using patchcurvature.m by Dirk Jan Kroon
[Cmean,Cgaussian,Dir1,Dir2,Lambda1,Lambda2]=patchcurvature(FV2red,true);
fprintf('Patch curvature done...')

%Plot curvatures over smoothed, simplfied mesh as a heatmap
%axes are microns
h2=figure('Color',[1 1 1]);
TRONgray=[255,255,255; 253,253,253; 251,251,251; 249,249,249; 247,247,247; 245,245,245; 243,243,243; 241,241,241; 239,239,239; 236,236,236; 234,234,234; 232,232,232; 230,230,230; 228,228,228; 226,226,226; 224,224,224; 222,222,222; 220,220,220; 218,218,218; 216,216,216; 214,214,214; 212,212,212; 210,210,210; 208,208,208; 206,206,206; 203,203,203; 201,201,201; 199,199,199; 197,197,197; 195,195,195; 193,193,193; 191,191,191; 189,189,189; 187,187,187; 185,185,185; 183,183,183; 181,181,181; 179,179,179; 177,177,177; 175,175,175; 173,173,173; 171,171,171; 168,168,168; 166,166,166; 164,164,164; 162,162,162; 160,160,160; 158,158,158; 156,156,156; 154,154,154; 152,152,152; 150,150,150; 148,148,148; 146,146,146; 144,144,144; 142,142,142; 140,140,140; 138,138,138; 135,135,135; 133,133,133; 131,131,131; 129,129,129; 127,127,127; 125,125,125; 123,123,123; 121,121,121; 119,119,119; 117,117,117; 115,115,115; 113,113,113; 112,112,112; 110,110,110; 108,108,108; 106,106,106; 104,104,104; 102,102,102; 100,100,100; 98,98,98; 96,96,96; 94,94,94; 92,92,92; 90,90,90; 88,88,88; 86,86,86; 84,84,84; 82,82,82; 80,80,80; 79,79,79; 77,77,77; 75,75,75; 73,73,73; 71,71,71; 69,69,69; 67,67,67; 65,65,65; 63,63,63; 61,61,61; 59,59,59; 57,57,57; 55,55,55; 53,53,53; 51,51,51; 49,49,49; 48,48,48; 46,46,46; 44,44,44; 42,42,42; 40,40,40; 38,38,38; 36,36,36; 34,34,34; 32,32,32; 30,30,30; 28,28,28; 26,26,26; 24,24,24; 22,22,22; 20,20,20; 18,18,18; 16,16,16; 15,15,15; 13,13,13; 11,11,11; 9,9,9; 7,7,7; 5,5,5; 3,3,3; 1,1,1; 1,0,0; 3,1,0; 5,2,0; 7,3,0; 9,4,0; 11,5,0; 13,6,0; 15,7,0; 17,8,0; 19,9,0; 21,10,0; 23,11,0; 25,12,0; 27,12,0; 29,13,0; 31,14,0; 33,15,0; 35,16,0; 37,17,0; 39,18,0; 41,19,0; 43,20,0; 45,21,0; 47,22,0; 49,23,0; 51,23,0; 53,24,0; 55,25,0; 57,26,0; 59,27,0; 61,28,0; 63,29,0; 65,30,0; 67,31,0; 69,32,0; 71,33,0; 73,34,0; 75,35,0; 77,35,0; 79,36,0; 81,37,0; 82,38,0; 84,39,0; 86,40,0; 88,41,0; 90,42,0; 92,43,0; 94,44,0; 96,45,0; 98,46,0; 100,47,0; 102,47,0; 104,48,0; 106,49,0; 108,50,0; 110,51,0; 112,52,0; 114,53,0; 116,54,0; 118,55,0; 120,56,0; 122,57,0; 124,58,0; 126,58,0; 128,59,0; 130,59,0; 132,60,0; 134,60,0; 136,60,0; 138,60,0; 140,61,0; 142,61,0; 144,61,0; 146,62,0; 148,62,0; 151,62,0; 153,63,0; 155,63,0; 157,63,0; 159,64,0; 161,64,0; 163,64,0; 165,64,0; 167,65,0; 169,65,0; 171,65,0; 173,66,0; 175,66,0; 177,66,0; 179,67,0; 181,67,0; 183,67,0; 185,67,0; 187,68,0; 189,68,0; 191,68,0; 193,69,0; 195,69,0; 197,69,0; 199,70,0; 201,70,0; 203,70,0; 205,70,0; 207,71,0; 209,71,0; 211,71,0; 213,72,0; 215,72,0; 217,72,0; 219,73,0; 221,73,0; 223,73,0; 225,74,0; 227,74,0; 229,74,0; 231,74,0; 234,75,0; 236,75,0; 238,75,0; 240,76,0; 242,76,0; 244,76,0; 246,77,0; 248,77,0; 250,77,0; 252,77,0; 254,78,0; 255,78,0];
TRONgray=TRONgray/255;
colormap(TRONgray)
C=Cmean;
h=patch(FV2red,'FaceColor','interp','FaceVertexCData',C,'edgecolor','none');
axis equal
delete(findall(gcf,'Type','light'))
lightangle(105,60)
h.FaceLighting = 'gouraud';
h.AmbientStrength = 1;
h.DiffuseStrength = 1;
h.SpecularStrength = 0.7;
h.SpecularExponent = 25;

ax=gca;
ax.CLim=[-curvegate curvegate];
view(viewaz,viewel)
axis vis3d

%some specific parameters to make a pretty saved image
axis off
objectcenter=[2680 3204 440];
axis([objectcenter(1)-3500 objectcenter(1)+3500 objectcenter(2)-3500 objectcenter(2)+3500 objectcenter(3)-3500 objectcenter(3)+3500]);
axis off
outstring=sprintf('miurasurf');
print(outstring,'-dpng')

%for writing stl file via stlwrite.m by Sven Holcombe
stlwrite('miurastl.stl', FV2red)
