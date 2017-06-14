function varargout = GUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
import java.awt.Robot;        %importing the robot class
import java.awt.event.*;
handles.mouse=Robot;
axes(handles.Video);
handles.vid = videoinput('winvideo');
flushdata(handles.vid);
set(handles.vid, 'FramesPerTrigger', Inf);
set(handles.vid, 'ReturnedColorspace', 'rgb')
handles.vid.FrameGrabInterval = 5;
start(handles.vid)
handles.y=0;
handles.x=0;
handles.data1=0;

% Update handles structure
guidata(hObject, handles);


function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Track.
function Track_Callback(hObject, eventdata, handles)
import java.awt.event.*;
while(handles.y==0)         %an infinite loop(breaks when user press stop)
    try
    handles.data1 = getsnapshot(handles.vid);   
    catch                   %if video object failed
        break;
    end
    data2=flipdim(handles.data1,2);     %flipping of image
    
    %for red color
    diff_imr = imsubtract(data2(:,:,1), rgb2gray(data2));  %color extraction
    diff_imr = medfilt2(diff_imr, [3 3]); %removal of noise
    diff_imr = im2bw(diff_imr,0.24); 
    diff_imr = bwareaopen(diff_imr,300);  %convert to binary
    
    %for green color
    diff_img = imsubtract(data2(:,:,2), rgb2gray(data2));
    diff_img = medfilt2(diff_img, [3 3]);
    diff_img = im2bw(diff_img,0.03);
    diff_img = bwareaopen(diff_img,300);
    
    %for blue color
    diff_imb = imsubtract(data2(:,:,3), rgb2gray(data2));
    diff_imb = medfilt2(diff_imb, [3 3]);
    diff_imb = im2bw(diff_imb,0.15);
    diff_imb = bwareaopen(diff_imb,300);
    
    %extracting location of the colored object
    bwr = bwlabel(diff_imr, 8);
    bwg = bwlabel(diff_img, 8);
    bwb = bwlabel(diff_imb, 8);
    statsr = regionprops(bwr, 'BoundingBox', 'Centroid');
    handles.statsr=statsr;
    statsg = regionprops(bwg, 'BoundingBox', 'Centroid');
     handles.statsg=statsg;
    statsb = regionprops(bwb, 'BoundingBox', 'Centroid');
     handles.statsb=statsb;
    imshow(data2); %showing the flipped image as output
   
    hold on
    if(handles.x==1)  %If user presses 'start mouse' button
      if(length(statsr)==1) %hovering of mouse for red color
       cen=statsr.Centroid;
       x=round(cen(1));
       y=round(cen(2));
       handles.mouse.mouseMove(x,y);
     end
     if( length(statsb)==1)   %right click
         handles.mouse.mousePress(InputEvent.BUTTON3_MASK);
         handles.mouse.mouseRelease(InputEvent.BUTTON3_MASK);
     end
     if(length(statsg)==1)   %left click
         handles.mouse.mousePress(InputEvent.BUTTON1_MASK);
         handles.mouse.mouseRelease(InputEvent.BUTTON1_MASK);
     end
    end
    for object = 1:length(statsr)
        bbr = statsr(object).BoundingBox;
        bcr = statsr(object).Centroid;
        rectangle('Position',bbr,'EdgeColor','r','LineWidth',2)
        plot(bcr(1),bcr(2), '-m+')
        ar=text(bcr(1)+15,bcr(2), strcat('X: ', num2str(round(bcr(1))), '    Y: ', num2str(round(bcr(2)))));
        set(ar, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
    end
    
     for object = 1:length(statsg)
        bbg = statsg(object).BoundingBox;
        bcg = statsg(object).Centroid;
        rectangle('Position',bbg,'EdgeColor','g','LineWidth',2)
        plot(bcg(1),bcg(2), '-m+')
        ag=text(bcg(1)+15,bcg(2), strcat('X: ', num2str(round(bcg(1))), '    Y: ', num2str(round(bcg(2)))));
        set(ag, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
     end
    
      for object = 1:length(statsb)
        bbb = statsb(object).BoundingBox;
        bcb = statsb(object).Centroid;
        rectangle('Position',bbb,'EdgeColor','b','LineWidth',2)
        plot(bcb(1),bcb(2), '-m+')
        ab=text(bcb(1)+15,bcb(2), strcat('X: ', num2str(round(bcb(1))), '    Y: ', num2str(round(bcb(2)))));
        set(ab, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
    end
    hold off
    flushdata(handles.vid);
end

stop(handles.vid);
flushdata(handles.vid);
clear handles.vid;
close

% --- Executes on button press in Mouse.
function Mouse_Callback(hObject, eventdata, handles)
handles.x=1;
guidata(hObject, handles);
Track_Callback(hObject,eventdata,handles);

% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.y=1;
guidata(hObject, handles);
Track_Callback(hObject,eventdata,handles);
