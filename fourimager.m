function varargout = fourimager(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @baslamaFcn, ...
    'gui_OutputFcn',  @esiklemeOFcn, ...
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
function varargout = esiklemeOFcn(hObject, eventdata, handles)
return
function baslamaFcn(hObject, eventdata, handles)

global FotoAd;
global axes2_foto;
global binsToSuppress;
global Foto;
global axes1_foto;
binsToSuppress = [];
Foto =[];
FotoAd ='';
axes1_foto = [];
axes2_foto = [];
set(handles.secOzel,'Value',0);
set(handles.Xekseni,'Value',0);
sliderOF(handles, {'off','off','off'},{' ',' ',' '});
WarnUser(sprintf('Programin Calismasiyla ilgili bir kac not:\n1-Bazi filtreler bazi filtrelerin uzerine uygulanamaz bu durumda RESET yapip tekrar filtreyi uygulayabilirsiniz\n2-Filtrenin basarili bir sekilde uygulandigi zaman BILGI\nKisminda bildiriliyor, bilgilendirma cikana kadar lutfen BEKLEYIN bazi filtreler agir calismaktadir\nTESEKKURLER'));
%-------------------------------------------------
%% ============Slider Fonksiyonlari===============
function slider_Max_Callback(hObject, eventdata, handles)
global g_Floating;
global MaxThrd;
global MinThrd;
global g_LastThresholdedColorBand;
global islemTuru;
global axes2_foto;global axes1_foto;
global AsagiYukari;global SagSol;global h;global sigma;global bandSayisi
global ch1;global ch2;global ch3;
global PrewittImg;
global ust;global alt;global laplaceFoto;
switch islemTuru
    case 'esiklenme' 
        g_LastThresholdedColorBand = 0;
        try
            maxSliderValue = get(hObject,'Value');
            if g_Floating == 0
                maxSliderValue = round(maxSliderValue);
            end
            if (maxSliderValue < MinThrd)
                maxSliderValue = MinThrd;
                set(hObject,'Value', maxSliderValue);
            end
            if (maxSliderValue >= MinThrd)
                MaxThrd = maxSliderValue;
                set(handles.edit_Max, 'string', num2str(round(255 * maxSliderValue)));
            end
            guidata(hObject, handles);
            ShowThresholdedBinaryImage(hObject, eventdata, handles);
        catch ME
            errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
                ME.stack(1).name, ME.stack(1).line, ME.message);
            WarnUser(errorMessage);
        end
    case 'logDonusumu'
        try
            a=double(axes1_foto)/255;
            
            c=get(handles.slider_Max,'Value');
            axes2_foto = c*log(1 + (a));
            imshow(axes2_foto, 'Parent', handles.axes2);
            set(handles.edit_Max,'String', num2str(c));
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
        catch Me
            set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
            errorMessage = sprintf('Bir hata olustu! Tekrar deneyin');
            WarnUser(errorMessage);
        end
    case 'mean'
        try
            set(handles.edit_Max,'String',round(get(handles.slider_Max,'Value')));
            if(size(axes1_foto,3)>1)
                axes1_foto=rgb2gray(axes1_foto);
            end
            c=round(get(handles.slider_Max,'Value'));
            
            h=fspecial('average',round(c));
            axes2_foto=imfilter(axes1_foto,h);
            imshow(axes2_foto, 'Parent', handles.axes2);
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
        catch Me
            errorMessage = sprintf('Bir hata olustu! Tekrar deneyin');
            WarnUser(errorMessage);set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
        end
    case 'gauss'
        try
            SagSol=get(handles.slider_Max,'Value');
            set(handles.edit_Max,'string',SagSol);
            [h1, h2]=meshgrid(-(SagSol-1)/2:(SagSol-1)/2, -(AsagiYukari-1)/2:(AsagiYukari-1)/2);
            hg= exp(-(h1.^2+h2.^2)/(2*sigma^2));
            h=hg ./sum(hg(:));
            switch bandSayisi
                case 1
                    blur1=conv2(ch1, h);
                    axes2_foto = cat(1,uint8(blur1));
                    imshow(axes2_foto, 'Parent', handles.axes2);
                    
                case 2
                    blur1=conv2(ch1, h);
                    blur2=conv2(ch2, h);
                    axes2_foto = cat(2,uint8(blur1),uint8(blur2));
                    imshow(axes2_foto, 'Parent', handles.axes2);
                    
                case 3
                    blur1=conv2(ch1, h);
                    blur2=conv2(ch2, h);
                    blur3=conv2(ch3, h);
                    axes2_foto = cat(3,uint8(blur1),uint8(blur2),uint8(blur3));
                    imshow(axes2_foto, 'Parent', handles.axes2);
            end
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
            
        catch ME
            errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
                ME.stack(1).name, ME.stack(1).line, ME.message);
            WarnUser(errorMessage);    set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
            
        end
    case 'prewitt'
        try
            thresholdValue = round(get(handles.slider_Max,'Value'));
            set(handles.edit_Max,'string',thresholdValue);
            axes2_foto = max(PrewittImg, thresholdValue);
            axes2_foto(axes2_foto == round(thresholdValue)) = 0;
            axes2_foto = imbinarize(axes2_foto);
            imshow(axes2_foto, 'Parent', handles.axes2);
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
            
        catch ME
            errorMessage = sprintf('Filtre uygulanirken bir sorun olustu\nError fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
                ME.stack(1).name, ME.stack(1).line, ME.message);
            WarnUser(errorMessage);set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
        end
    case 'laplace'
        try
            ust=round(get(handles.slider_Max,'Value'));
            if(ust>0)
                kernal = [0,-1,0;-1,ust,-1;0,-1,0]/alt;
            elseif(ust<0)
                kernal = [0,1,0;1,ust,1;0,1,0]/alt;
            else 
                ust = 1;
                kernal = [0,-1,0;-1,ust,-1;0,-1,0]/alt;
            end
            set(handles.edit_Max,'string',ust);
            
            axes2_foto = imfilter(double(laplaceFoto), kernal);
            handles = guidata(hObject);
            axes(handles.axes2);
            imshow(axes2_foto,[min(axes2_foto(:)) max(axes2_foto(:))]);
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
        catch ME
            errorMessage = sprintf('Filtre uygulanirken bir sorun olustu\nError fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
                ME.stack(1).name, ME.stack(1).line, ME.message);
            WarnUser(errorMessage);    set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
        end
    case 'median'
        set(handles.txtInfo,'string', 'Bekleyin');
        pause(0.001);
        try
            noise=get(handles.slider_Max,'Value');
            axes1_foto = im2gray(axes1_foto);
            Z = imnoise(axes1_foto,'salt & pepper',noise);
            axes2_foto = medfilt2(Z);
            set(handles.edit_Max,'string',noise);
%             axes2_foto = double(Z);
%             [row, col] = size(axes2_foto);
%             for x = 2:1:row-1
%                 for y = 2:1:col-1
%                     a1 = [axes2_foto(x-1,y-1) axes2_foto(x-1,y) axes2_foto(x-1,y+1) axes2_foto(x,y-1) axes2_foto(x,y) axes2_foto(x,y+1)...
%                         axes2_foto(x+1,y-1) axes2_foto(x+1,y) axes2_foto(x+1,y+1)];
%                     a2 = sort(a1);
%                     med = a2(5);
%                     axes2_foto(x,y) = med;
%                 end
%             end
%             axes2_foto=uint8(axes2_foto);
            imshow(axes2_foto, 'Parent', handles.axes2);
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
        catch ME
            set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
            disp(ME);
        end
end
return

function slider_Min_Callback(hObject, eventdata, handles)
global g_Floating;
global MaxThrd;
global MinThrd;
global g_LastThresholdedColorBand;
global islemTuru;global axes2_foto;global axes1_foto;
global AsagiYukari;global SagSol;global h;
global ch1;global ch2;global ch3;global bandSayisi;global sigma;
global alt;global ust;global laplaceFoto;
g_LastThresholdedColorBand=0;
switch islemTuru
    case 'esiklenme'
        try
            handles = guidata(hObject);
            minSliderValue = get(hObject,'Value');
            if g_Floating == 0
                minSliderValue = round(minSliderValue);
            end
            
            
            if (minSliderValue > MaxThrd)
                minSliderValue = MaxThrd;
                set(hObject,'Value', minSliderValue);
            end
            if (minSliderValue <= MaxThrd)
                MinThrd = minSliderValue;
                set(handles.edit_Min, 'string', num2str(round( 255 * MinThrd)));
            end
            guidata(hObject, handles);
            ShowThresholdedBinaryImage(hObject, eventdata, handles);
        catch ME
            errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
                ME.stack(1).name, ME.stack(1).line, ME.message);
            WarnUser(errorMessage);
        end
    case 'gauss'
        try
            AsagiYukari=get(handles.slider_Min,'Value');
            set(handles.edit_Min,'string',AsagiYukari);
            [h1, h2]=meshgrid(-(SagSol-1)/2:(SagSol-1)/2, -(AsagiYukari-1)/2:(AsagiYukari-1)/2);
            hg= exp(-(h1.^2+h2.^2)/(2*sigma^2));
            h=hg ./sum(hg(:));
            switch bandSayisi
                case 1
                    blur1=conv2(ch1, h);
                    axes2_foto = cat(1,uint8(blur1));
                    imshow(axes2_foto, 'Parent', handles.axes2);
                    
                case 2
                    blur1=conv2(ch1, h);
                    blur2=conv2(ch2, h);
                    axes2_foto = cat(2,uint8(blur1),uint8(blur2));
                    imshow(axes2_foto, 'Parent', handles.axes2);
                    
                case 3
                    blur1=conv2(ch1, h);
                    blur2=conv2(ch2, h);
                    blur3=conv2(ch3, h);
                    axes2_foto = cat(3,uint8(blur1),uint8(blur2),uint8(blur3));
                    imshow(axes2_foto, 'Parent', handles.axes2);
            end
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
            
        catch ME
            errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
                ME.stack(1).name, ME.stack(1).line, ME.message);
            WarnUser(errorMessage);set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
            
        end
    case 'laplace'
        try
            alt=round(get(handles.slider_Min,'Value'));
            if(alt == 0)
                alt = 1;
            end
            set(handles.edit_Min,'string',alt);
            if(ust>0)
                kernal = [0,-1,0;-1,ust,-1;0,-1,0]/alt;
            elseif(ust<0)
                kernal = [0,1,0;1,ust,1;0,1,0]/alt;
            else 
                ust = 1;
                kernal = [0,-1,0;-1,ust,-1;0,-1,0]/alt;
            end
            axes2_foto = imfilter(double(laplaceFoto), kernal);
            handles = guidata(hObject);
            axes(handles.axes2);
            imshow(axes2_foto,[min(axes2_foto(:)) max(axes2_foto(:))]);
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
        catch ME
            errorMessage = sprintf('Filtre uygulanirken bir sorun olustu\nError fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
                ME.stack(1).name, ME.stack(1).line, ME.message);
            WarnUser(errorMessage);    set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
        end
end
return

function slider_Sigma_Callback(hObject, eventdata, handles)
global AsagiYukari;global SagSol;global h;
global ch1;global ch2;global ch3;global bandSayisi;global sigma;
global axes2_foto;
try
    handles = guidata(hObject);
    sigma=get(handles.slider_Sigma,'Value');
    set(handles.edit_Sigma,'string',sigma);
    [h1, h2]=meshgrid(-(SagSol-1)/2:(SagSol-1)/2, -(AsagiYukari-1)/2:(AsagiYukari-1)/2);
    hg= exp(-(h1.^2+h2.^2)/(2*sigma^2));
    h=hg ./sum(hg(:));
    switch bandSayisi
        case 1
            blur1=conv2(ch1, h);
            axes2_foto = cat(1,uint8(blur1));
            imshow(axes2_foto, 'Parent', handles.axes2);
            
        case 2
            blur1=conv2(ch1, h);
            blur2=conv2(ch2, h);
            axes2_foto = cat(2,uint8(blur1),uint8(blur2));
            imshow(axes2_foto, 'Parent', handles.axes2);
        case 3
            blur1=conv2(ch1, h);
            blur2=conv2(ch2, h);
            blur3=conv2(ch3, h);
            axes2_foto = cat(3,uint8(blur1),uint8(blur2),uint8(blur3));
            imshow(axes2_foto, 'Parent', handles.axes2);
    end
    set(handles.txtInfo,'string', 'Filtre Uygulandi');
    
catch ME
    errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    WarnUser(errorMessage);set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
end
return

function edit_Max_Callback(hObject, eventdata, handles)
global MaxThrd;
global MinThrd;
global g_LastThresholdedColorBand;
try
    g_LastThresholdedColorBand=0;
    max_value = str2double(get(handles.edit_Max,'string'));
    if (max_value <= 255) && (max_value >= MinThrd) && isnan(max_value) == false
        MaxThrd = max_value;
        set(handles.slider_Max,'Value',MaxThrd);
    end
    set(handles.edit_Max,'string',MaxThrd);
    guidata(hObject, handles);
    ShowThresholdedBinaryImage(hObject, eventdata, handles);
catch ME
    errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    WarnUser(errorMessage);
end
return;

function edit_Min_Callback(hObject, eventdata, handles)
global MaxThrd;
global MinThrd;
global g_LastThresholdedColorBand;
try
    g_LastThresholdedColorBand = 0;
    
    min_value = str2double(get(handles.edit_Min,'string'));
    if (min_value >= 0) && (min_value <= MaxThrd) && isnan(min_value) == false
        MinThrd = min_value;
        set(handles.slider_Min,'Value',MinThrd);
    end
    set(handles.edit_Min,'string',MinThrd);
    guidata(hObject, handles);
    ShowThresholdedBinaryImage(hObject, eventdata, handles);
catch ME
    errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    WarnUser(errorMessage);
end
return;
%-------------------------------------------------------


%----------------------------------------------------------
%% ============Dosya Islemleri Fonksiyonlari===============
function LoadFile(handles, filename)
global FotoAd;
global axes1_foto;
try
    try
        axes1_foto = imread(filename);
        imshow(axes1_foto, 'Parent', handles.axes1);
        FotoAd = filename;
        set(handles.txtInfo,'string', 'Fotograf Basariyla Yuklendi');
        
    catch ME
        errorMessage = sprintf('Error fotograf okunamadi\.fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
            ME.stack(1).name, ME.stack(1).line, ME.message);
        WarnUser(errorMessage);
        set(handles.txtInfo,'string', 'Fotograf Yuklenemedi');
    end
catch ME
    errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    WarnUser(errorMessage);
end
return;

function ShowThresholdedBinaryImage(hObject, eventdata, handles)
global MaxThrd;
global MinThrd;
global axes1_foto;
global axes2_foto;
global g_LastThresholdedColorBand;
global ColorBandSayisi;
global axesShowingInMiddleImage;
try
    handles = guidata(hObject);
    axes(handles.axes2);
    colorBand = 1;
    if (colorBand ~= 1) || (ColorBandSayisi == 1)
        axes2_foto = (MinThrd <= axes1_foto) & (axes1_foto <= MaxThrd);
        try
            imshow(axes2_foto, []);
        catch ME
            set(handles.txtInfo,'string','Fotograf axeste gosterirken bir sorunla karsilandi');
            errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
                ME.stack(1).name, ME.stack(1).line, ME.message);
            WarnUser(errorMessage);
        end
        g_LastThresholdedColorBand = 0;
    end
    axesShowingInMiddleImage = 2;
catch ME
    errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    WarnUser(errorMessage);
end

guidata(hObject, handles);
return;

function goruntukaydetme_Callback(hObject, eventdata, handles)
global axes2_foto;
global FotoAd;

try
    if ~isempty(axes2_foto)
        
        [folder, ad, ~] = fileparts(FotoAd);
        [fileName, folder] = uiputfile({'*.jpg';'*.gif';'*.png';'*.ppm';'*.pgm'},[folder '\foto'], strcat(ad,'_edited'));
        NameOfFileToSave = fullfile(folder, fileName);
        imwrite(axes2_foto, NameOfFileToSave);
        set(handles.txtInfo,'string',['Fotograf kaydedildi ' NameOfFileToSave]);
    end
catch ME
    errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    WarnUser(errorMessage);
    set(handles.txtInfo,'string',['Fotograf kaydedilemedi ' NameOfFileToSave]);
end
return;

function goruntusecme_Callback(hObject, eventdata, handles)
global FotoAd;
global axes2_foto;
global binsToSuppress;
global Foto;
global axes1_foto;
global tamyol;
global dosya;
try
    [dosya, yol]=uigetfile({'*.jpg;*.gif;*.png;*.ppm;*.pgm;*.tiff;*.bmp';'*.*'}, 'Görüntü Dosyasini Sec:');
    tamyol=fullfile(yol,dosya);
    try
        cla(handles.axes2);
        binsToSuppress = [];
        Foto =[];
        FotoAd ='';
        axes1_foto = [];
        axes2_foto = [];
        LoadFile(handles,tamyol);
        set(handles.PanelS,'visible','off');
        set(handles.PanelG,'visible','off');
        sliderOF(handles,{'off','off','off'},{' ',' ',' '});
    catch ME
        WarnUser('Hata olustu');
        disp(ME);
        return
    end
    
catch ME
    WarnUser('Hata olustu');
    set(handles.txtInfo,'string', 'Fotograf Yuklenemedi');
end
return

function esiklemeFcn(hObject, eventdata, handles, ImageFilename)

global Foto;
global axes1_foto;
global MaxThrd;
global MinThrd;
global ColorBandSayisi;
global g_Floating;
global useMinThrd;
global useMaxThrd;
global islemTuru;
islemTuru='esiklenme';
useMinThrd = 1;
useMaxThrd = 1;

try
    warning('off', 'Images:initSize:adjustingMag');
    imageToDisplay = [];
    MinThrd= 0 ;%-800;
    MaxThrd= 0;%10400;
    
    
    
    axes(handles.axes1);
    if isa(ImageFilename, 'char')
        if exist(ImageFilename, 'file')
            LoadFile(handles, ImageFilename);
        else
            errorMessage = sprintf('F:\n%s', ImageFilename);
            msgboxw(errorMessage);
            return;
        end
    else
        ColorBandSayisi = 1;
        Foto = ImageFilename;
        axes1_foto = Foto;
        axes(handles.axes1)
        warning off;
        if ~isempty(imageToDisplay)
            imshow(imageToDisplay, []);
        else
            imshow(Foto, []);
        end
        warning on;
    end
    
    if isa(Foto, 'double') || isa(Foto, 'single') || isa(Foto, 'float')
        g_Floating = 1;
    else
        g_Floating = 0;
    end
    
    if useMinThrd == 0
        set(handles.slider_Min, 'Visible', 'off');
        set(handles.edit_Min, 'Visible', 'off');
        set(handles.text_Min, 'Visible', 'off');
    end
    
    if useMaxThrd == 0
        set(handles.slider_Max, 'Visible', 'off');
        set(handles.edit_Max, 'Visible', 'off');
        set(handles.text_Max, 'Visible', 'off');
    end
    
    maxSliderValue = max(max(Foto));
    minSliderValue = min(min(Foto));
    
    
    if ColorBandSayisi > 1
        maxSliderValue = max(maxSliderValue);
        minSliderValue = min(minSliderValue);
    end
    
    range = maxSliderValue - minSliderValue;
    
    if g_Floating
        slider_step(1) = 0.01;
        slider_step(2) = 0.1;
    else
        if isa(Foto, 'uint8')
            slider_step(1) = 1.0 / double(range);
            slider_step(2) = 10.0 * slider_step(1);
        else
            slider_step(1) = 10.0 / double(range);
            slider_step(2) = 1000.0 / double(range);
        end
    end
    
    
    if MinThrd < minSliderValue || MinThrd > maxSliderValue || useMinThrd == 0
        MinThrd = minSliderValue;
    end
    
    if MaxThrd < minSliderValue || MaxThrd > maxSliderValue || useMaxThrd == 0
        MaxThrd = maxSliderValue;
    end
    
    if MaxThrd == MinThrd
        MaxThrd = maxSliderValue;	% Select bright objects.
    end
    
    set(handles.slider_Min, 'sliderstep',slider_step, 'max',maxSliderValue, 'min', minSliderValue, 'Value',MinThrd);
    set(handles.slider_Max, 'sliderstep',slider_step, 'max',maxSliderValue, 'min', minSliderValue, 'Value',MaxThrd);
    set(handles.edit_Min, 'string',MinThrd);
    set(handles.edit_Max, 'string',MaxThrd);
    ShowThresholdedBinaryImage(hObject, eventdata, handles);
    
    %     set(gcf, 'units','normalized','outerposition',[0 0.04 1 .96]); % Maximize figure.
catch ME
    errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    WarnUser(errorMessage);
end
guidata(hObject, handles);
uiwait();
%---------------------------------------------------------------


%-----------------------------------------------------------
%% ============Filtre Butonlari Fonksiyonlari===============
function esiklenme_Callback(hObject, eventdata, handles)
global axes1_foto;
set(handles.txtInfo,'string', '');
if(size(axes1_foto,3)>1)
    image=rgb2gray(axes1_foto);
else
    image=axes1_foto;
end
try
    gidecekFoto =mat2gray(image);% 20000 * mat2gray(image) - 5000;
    sliderOF(handles, {'on','on','off'},{'Min','Max',' '});
    esiklemeFcn(hObject, eventdata, handles, gidecekFoto);
    set(handles.PanelG,'visible','off');
    set(handles.PanelS,'visible','off');
    set(handles.PanelK,'visible','off');
    set(handles.txtInfo,'string', 'Filtre Uygulandi');
catch ME
    set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
end
return

function logdonusumu_Callback(hObject, eventdata, handles)
global islemTuru
global axes2_foto;global axes1_foto; set(handles.txtInfo,'string', '');

islemTuru='logDonusumu';
if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
sliderOF(handles, {'off','on','off'},{' ','Deger',' '});
set(handles.slider_Max, 'min', 1);
set(handles.slider_Max, 'max', 10);
set(handles.slider_Max, 'Value', 1);
set(handles.edit_Max,'String', 1);
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

function griseviyedonusumu_Callback(hObject, eventdata, handles)
global axes1_foto;global axes2_foto; set(handles.txtInfo,'string', '');

if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
try
    [~, ~, chSayi] = size(axes1_foto);
    if chSayi  == 3
        ch1 = axes1_foto(:, :, 1);
        ch2 = axes1_foto(:, :, 2);
        ch3 = axes1_foto(:, :, 3);
        axes2_foto = .299*double(ch1) + ...
            .587*double(ch2) + ...
            .114*double(ch3);
        axes2_foto = uint8(axes2_foto);
    else
        errorMessage = sprintf('Girdiginiz Forograf RGB Degildir!');
        fprintf(1, '%s\n', errorMessage);
        uiwait(warndlg(errorMessage));
    end
    imshow(axes2_foto, 'Parent', handles.axes2);
    set(handles.txtInfo,'string', 'Filtre Uygulandi');
catch ME
    errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    fprintf(1, '%s\n', errorMessage);
    uiwait(warndlg(errorMessage));
    set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
    
end
set(handles.PanelS,'visible','off');
sliderOF(handles, {'off','off','off'},{'Min','Max',' '});
set(handles.PanelG,'visible','off');
set(handles.PanelK,'visible','off');

function kontrastgerme_Callback(hObject, eventdata, handles)
global axes2_foto;global axes1_foto; set(handles.txtInfo,'string', '');

if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
set(handles.PanelS,'visible','off');
sliderOF(handles, {'off','off','off'},{'Min','Max',' '});
set(handles.PanelG,'visible','off');
set(handles.PanelK,'visible','on');

function histogramesitleme_Callback(hObject, eventdata, handles)
global axes2_foto;global axes1_foto; set(handles.txtInfo,'string', '');

sliderOF(handles, {'off','off','off'},{' ',' ',' '});
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
try
    L=256;
    if(size(axes1_foto,3)>1)
        HSV = rgb2hsv(axes1_foto);
        Heq = histeq(HSV(:,:,3));
        HSV_mod = HSV;
        HSV_mod(:,:,3) = Heq;
        axes2_foto = hsv2rgb(HSV_mod);
    else
        axes1_foto=rgb2gray(axes1_foto);
        counts=zeros(256,1);
        for i=0:255
            counts(i+1)=sum(sum(axes1_foto==i));
        end
        p=counts/(size(axes1_foto,1)*size(axes1_foto,2));
        s=(L-1)*cumsum(p);
        s=round(s);
        axes2_foto=uint8(zeros(size(axes1_foto)));
        for k=1:size(s,1)
            axes2_foto(axes1_foto==k-1)=s(k);
        end
    end
    imshow(axes2_foto, 'Parent', handles.axes2);
    set(handles.txtInfo,'string', 'Filtre Uygulandi');
    
catch ME
    errorMessage = sprintf('Bir hata olustu! Tekrar deneyin');
    WarnUser(errorMessage);    
    set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
end

function mean_Callback(hObject, eventdata, handles)
global islemTuru;global axes1_foto;global axes2_foto; set(handles.txtInfo,'string', '');

islemTuru='mean';
if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
sliderOF(handles, {'off','on','off'},{' ','Deger',' '});
set(handles.slider_Max, 'min', 1);
set(handles.slider_Max, 'max', 100);
set(handles.slider_Max, 'Value', 50);
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

function median_Callback(hObject, eventdata, handles)
global axes1_foto;global axes2_foto; set(handles.txtInfo,'string', '');
global islemTuru;
islemTuru='median';
if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
sliderOF(handles, {'off','on','off'},{'','Noise Degeri',' '});
set(handles.slider_Max, 'min', 0);
set(handles.slider_Max, 'max', 0.2);
set(handles.slider_Max, 'Value', 0.1);
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

function gauss_Callback(hObject, eventdata, handles)
set(handles.txtInfo,'string', '');

global islemTuru;
global AsagiYukari;
global SagSol;
global sigma;global axes2_foto;global axes1_foto;
SagSol=10;AsagiYukari=10;sigma=3;

global ch1;global ch2;global ch3;global bandSayisi;
islemTuru='gauss';
sliderOF(handles, {'on','on','on'},{'Asagi ve yukari','Saga ve sola','Sigma(efekt) degeri'});
if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end

set(handles.slider_Max, 'min', 1);
set(handles.slider_Max, 'max', 100);
set(handles.slider_Max, 'Value', 20);

set(handles.slider_Min, 'min', 1);
set(handles.slider_Min, 'max', 100);
set(handles.slider_Min, 'Value', 20);

set(handles.slider_Sigma, 'min', 1);
set(handles.slider_Sigma, 'max', 50);
set(handles.slider_Sigma, 'Value', 5);
[~, ~, bandSayisi] = size(axes1_foto);
switch bandSayisi
    case 1
        ch1=axes1_foto(:, :, 1);
    case 2
        ch1=axes1_foto(:, :, 1);
        ch2=axes1_foto(:, :, 2);
    case 3
        ch1=axes1_foto(:, :, 1);
        ch2=axes1_foto(:, :, 2);
        ch3=axes1_foto(:, :, 3);
end
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

function sobel_Callback(hObject, eventdata, handles)
global axes2_foto;global axes1_foto; set(handles.txtInfo,'string', '');

sliderOF(handles, {'off','off','off'},{' ',' ',' '});
if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
try
    if(size(axes1_foto,3)>1)
        axes2_foto=rgb2gray(axes1_foto);
    else
        axes2_foto = axes1_foto;
    end
    C=double(axes2_foto);
    for i=1:size(C,1)-2
        for j=1:size(C,2)-2
            Gx=((2*C(i+2,j+1)+C(i+2,j)+C(i+2,j+2))-(2*C(i,j+1)+C(i,j)+C(i,j+2)));
            Gy=((2*C(i+1,j+2)+C(i,j+2)+C(i+2,j+2))-(2*C(i+1,j)+C(i,j)+C(i+2,j)));
            axes2_foto(i,j)=sqrt(Gx.^2+Gy.^2);
        end
    end
    imshow(axes2_foto, 'Parent', handles.axes2);
    set(handles.txtInfo,'string', 'Filtre Uygulandi');
catch ME
    set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
end
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

function prewitt_Callback(hObject, eventdata, handles)
global axes2_foto;global axes1_foto;global islemTuru;global PrewittImg; set(handles.txtInfo,'string', '');

islemTuru='prewitt';
sliderOF(handles, {'off','on','off'},{' ','Deger',' '});
if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
if(size(axes1_foto,3)>1)
    axes1_foto=rgb2gray(axes1_foto);
end
axes1_foto = double(axes1_foto);
PrewittImg = zeros(size(axes1_foto));
Mx = [-1 0 1; -1 0 1; -1 0 1];
My = [-1 -1 -1; 0 0 0; 1 1 1];
for i = 1:size(axes1_foto, 1) - 2
    for j = 1:size(axes1_foto, 2) - 2
        Gx = sum(sum(Mx.*axes1_foto(i:i+2, j:j+2)));
        Gy = sum(sum(My.*axes1_foto(i:i+2, j:j+2)));
        PrewittImg(i+1, j+1) = sqrt(Gx.^2 + Gy.^2); 
    end
end
set(handles.slider_Max, 'min', 0);
set(handles.slider_Max, 'max', 255);
set(handles.slider_Max, 'value', 100);
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

function laplace_Callback(hObject, eventdata, handles)
global axes1_foto;global axes2_foto;global islemTuru;global alt;global ust;alt=8;ust=8;global laplaceFoto;
islemTuru='laplace'; set(handles.txtInfo,'string', '');

if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
[~, ~, numberOfColorBands] = size(axes1_foto);
if numberOfColorBands > 1
    laplaceFoto = axes1_foto(:, :, 2);
    
else
    laplaceFoto=axes1_foto;
end
sliderOF(handles, {'on','on','off'},{'Ust deger','Alt deger',' '});
set(handles.slider_Max, 'min', -15);set(handles.slider_Min, 'min',-15);
set(handles.slider_Max, 'max', 15);set(handles.slider_Min, 'max', 15);
set(handles.slider_Max, 'value', 8);set(handles.slider_Min, 'value', 8);
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

function roberts_Callback(hObject, eventdata, handles)
global axes1_foto;global axes2_foto;
sliderOF(handles, {'off','off','off'},{' ',' ',' '});
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');
set(handles.txtInfo,'string', '');
if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
try
    [~, ~, chSayi] = size(axes1_foto);
    if chSayi  == 3
        axes1_foto=rgb2gray(axes1_foto);
    end
    axes2_foto=(axes1_foto);
    C=double(axes2_foto);
    for i=1:size(C,1)-2
        for j=1:size(C,2)-2
            %Roberts mask 45 derece yonu icin:
            Gx=(C(i+2,j+1)-C(i+1,j+2));
            %Roberts mask -45 derece yonu icin:
            Gy=(C(i+2,j+2)-C(i+1,j+1));
            axes2_foto(i,j)=sqrt(Gx.^2+Gy.^2);
            
        end
    end
    imshow(axes2_foto,'Parent',handles.axes2);
    set(handles.txtInfo,'string', 'Filtre uygulandi');
catch ME
    set(handles.txtInfo,'string', 'Filtre uygulanamadi');
end

function genisleme_Callback(hObject, eventdata, handles)
global islemTuru;global axes1_foto;global axes2_foto; set(handles.txtInfo,'string', '');
set(handles.secOzel,'Value',0);
set(handles.Xekseni,'Value',0);
if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
islemTuru='genisleme';
set(handles.PanelG,'visible','on');
PanelG_Kontrol(handles, {'on','off','on','off','off'});
sliderOF(handles, {'off','off','off'},{' ',' ',' '});
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

function asinma_Callback(hObject, eventdata, handles)
global islemTuru;global rows;global columns;global axes1_foto;global axes2_foto; set(handles.txtInfo,'string', '');

if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
islemTuru='asinma';
[rows, columns] = size(axes1_foto);
PanelG_Kontrol(handles, {'on','off','off','on','on'});
sliderOF(handles, {'off','off','off'},{' ',' ',' '});
set(handles.PanelG,'visible','on');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

function acma_Callback(hObject, eventdata, handles)
global islemTuru;global axes1_foto;global axes2_foto;global p;global rows;global columns;global f;
if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
islemTuru='acma'; set(handles.txtInfo,'string', '');

f1=double(axes1_foto);
f=f1(:,:,1);
[rows,columns]=size(f);
p=zeros(rows,columns);axes2_foto=zeros(rows,columns);
PanelG_Kontrol(handles, {'on','off','off','on','on'});
sliderOF(handles, {'off','off','off'},{' ',' ',' '});
set(handles.PanelG,'visible','on');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

function kapama_Callback(hObject, eventdata, handles)
global islemTuru;global axes1_foto;global p;global axes2_foto;global rows;global columns;global f;
if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
islemTuru='kapama'; set(handles.txtInfo,'string', '');

f1=double(axes1_foto);
f=f1(:,:,1);
[rows,columns]=size(f);
p=zeros(rows,columns);axes2_foto=zeros(rows,columns);
PanelG_Kontrol(handles, {'on','off','off','on','on'});
sliderOF(handles, {'off','off','off'},{' ',' ',' '});
set(handles.PanelG,'visible','on');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');

function kayipliSvd_Callback(hObject, eventdata, handles)
global islemTuru;
islemTuru='kayipliSVD'; set(handles.txtInfo,'string', '');

PanelS_Kontrol(handles, {'on','off','off','on','on'});
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','on');
set(handles.PanelK,'visible','off');
sliderOF(handles, {'off','off','off'},{' ',' ',' '});

function kayipliBtc_Callback(hObject, eventdata, handles)
global islemTuru;
islemTuru='kayipliBTC';
set(handles.txtInfo,'string', '');

PanelS_Kontrol(handles, {'on','on','on','off','on'});
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','on');
set(handles.PanelK,'visible','off');
sliderOF(handles, {'off','off','off'},{' ',' ',' '});

function kayipsiz1_Callback(hObject, eventdata, handles)
global axes1_foto;global axes2_foto;global dosya;global tamyol; set(handles.txtInfo,'string', '');

PanelS_Kontrol(handles, {'on','off','off','off','off'});
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','on');
set(handles.PanelK,'visible','off');
sliderOF(handles, {'off','off','off'},{' ',' ',' '});
try
    [~,~,band]=size(axes1_foto);
    if band==3
        I = axes1_foto(:,:,1);
        I = im2double(I);
        T = dctmtx(8);
        B = blkproc(I,[8 8],'P1*x*P2',T,T');
        mask = [1   1   1   1   0   0   0   0
            1   1   1   0   0   0   0   0
            1   1   0   0   0   0   0   0
            1   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0];
        B2 = blkproc(B,[8 8],'P1.*x',mask);
        I2 = blkproc(B2,[8 8],'P1*x*P2',T',T);
        I = axes1_foto(:,:,2);
        I = im2double(I);
        T = dctmtx(8);
        B = blkproc(I,[8 8],'P1*x*P2',T,T');
        mask = [1   1   1   1   0   0   0   0
            1   1   1   0   0   0   0   0
            1   1   0   0   0   0   0   0
            1   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0];
        B2 = blkproc(B,[8 8],'P1.*x',mask);
        I3 = blkproc(B2,[8 8],'P1*x*P2',T',T);
        I = axes1_foto(:,:,3);
        I = im2double(I);
        T = dctmtx(8);
        B = blkproc(I,[8 8],'P1*x*P2',T,T');
        mask = [1   1   1   1   0   0   0   0
            1   1   1   0   0   0   0   0
            1   1   0   0   0   0   0   0
            1   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0];
        B2 = blkproc(B,[8 8],'P1.*x',mask);
        I4 = blkproc(B2,[8 8],'P1*x*P2',T',T);
        axes2_foto(:,:,:)=cat(3,I2, I3, I4);
    elseif band==2
        I = axes1_foto(:,:,1);
        I = im2double(I);
        T = dctmtx(8);
        B = blkproc(I,[8 8],'P1*x*P2',T,T');
        mask = [1   1   1   1   0   0   0   0
            1   1   1   0   0   0   0   0
            1   1   0   0   0   0   0   0
            1   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0];
        B2 = blkproc(B,[8 8],'P1.*x',mask);
        I2 = blkproc(B2,[8 8],'P1*x*P2',T',T);
        I = axes1_foto(:,:,2);
        I = im2double(I);
        T = dctmtx(8);
        B = blkproc(I,[8 8],'P1*x*P2',T,T');
        mask = [1   1   1   1   0   0   0   0
            1   1   1   0   0   0   0   0
            1   1   0   0   0   0   0   0
            1   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0];
        B2 = blkproc(B,[8 8],'P1.*x',mask);
        I3 = blkproc(B2,[8 8],'P1*x*P2',T',T);
        axes2_foto(:,:)=cat(2,I2, I3);
    elseif band==1
        I = axes1_foto(:,:,1);
        I = im2double(I);
        T = dctmtx(8);
        B = blkproc(I,[8 8],'P1*x*P2',T,T');
        mask = [1   1   1   1   0   0   0   0
            1   1   1   0   0   0   0   0
            1   1   0   0   0   0   0   0
            1   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0
            0   0   0   0   0   0   0   0];
        B2 = blkproc(B,[8 8],'P1.*x',mask);
        I2 = blkproc(B2,[8 8],'P1*x*P2',T',T);
        axes2_foto=I2;
    end
    imshow(axes2_foto, 'Parent', handles.axes2);
    temp=strcat('asajd',dosya);
    inf=imfinfo(tamyol);
    set(handles.as,'string',num2str(inf.FileSize/1024));
    imwrite(axes2_foto,temp);
    inf=imfinfo(temp);
    set(handles.sk,'string',num2str(inf.FileSize/1024));
    delete(temp);
    set(handles.txtInfo,'string', 'Filtre Uygulandi');
catch ME
    set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
end

function kayipsiz2_Callback(hObject, eventdata, handles)
global axes1_foto;global axes2_foto;global dosya;global tamyol; set(handles.txtInfo,'string', '');
try
    I=rgb2gray(axes1_foto);
    [m,n]=size(I);
    Totalcount=m*n;
    cnt=1;
    sigma=0;
    for i=0:255
        k=I==i;
        count(cnt)=sum(k(:));
        pro(cnt)=count(cnt)/Totalcount;
        sigma=sigma+pro(cnt);
        cumpro(cnt)=sigma;
        cnt=cnt+1;
    end
    symbols = 0:255;
    dict = huffmandict(symbols,pro);
    vec_size = 1;
    for p = 1:m
        for q = 1:n
            newvec(vec_size) = I(p,q);
            vec_size = vec_size+1;
        end
    end
    hcode = huffmanenco(newvec,dict);
    dhsig1 = huffmandeco(hcode,dict);
    dhsig = uint8(dhsig1);
    dec_row=sqrt(length(dhsig));
    dec_col=dec_row;
    arr_row = 1;
    arr_col = 1;
    vec_si = 1;
    for x = 1:m
        for y = 1:n
            back(x,y)=dhsig(vec_si);
            arr_col = arr_col+1;
            vec_si = vec_si + 1;
        end
        arr_row = arr_row+1;
    end
    [deco, map] = gray2ind(back,256);
    axes2_foto = ind2rgb(deco,map);
    
    PanelS_Kontrol(handles, {'on','off','off','off','off'});
    set(handles.PanelG,'visible','off');
    set(handles.PanelS,'visible','on');
    set(handles.PanelK,'visible','off');
    sliderOF(handles, {'off','off','off'},{' ',' ',' '});
    imshow(axes2_foto, 'Parent', handles.axes2);
    temp=strcat('asajd',dosya);
    inf=imfinfo(tamyol);
    set(handles.as,'string',num2str(inf.FileSize/1024));
    imwrite(axes2_foto,temp);
    inf=imfinfo(temp);
    set(handles.sk,'string',num2str(inf.FileSize/1024));
    delete(temp);
    set(handles.txtInfo,'string', 'Filtre Uygulandi');
catch ME
    set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
end
%-------------------------------------------------------


%----------------------------------------------------------
%% ============Giris Butonlarin Fonksiyonlari===============
function gir_Callback(hObject, eventdata, handles)
global axes2_foto;
global axes1_foto;
global islemTuru;
global columns;global rows;global m;global n;global p;global f;
girilen=get(handles.yapi,'string');
kose={'[',']'};deger=[1 0];
if ismember(kose{1},girilen) && ismember(kose{2},girilen)
    strrep(girilen,kose{1},'');strrep(girilen,kose{2},'');
end
girilen=str2num(girilen);
if isempty(girilen) || all(~ismember(deger,girilen))
    errorMessage = sprintf('Gecerli Bir Matris Girdiginize Emin olunuz\nMatris Sadece 0 1''lerden Olusmasi, Butun Sutun Sayilari Ayni\nVe 3x3 Boyutunda Olmasi Gerek');
    WarnUser(errorMessage);
    return;
end
switch islemTuru
    case 'genisleme'
        try
            g=im2bw(axes1_foto);
            [p, q]=size(girilen);
            [m, n]=size(g);
            axes2_foto= zeros(m,n);
            for i=1:m
                for j=1:n
                    if (g(i,j)==1)
                        for k=1:p
                            for l=1:q
                                if(girilen(k,l)==1)
                                    c=i+k;
                                    d=j+l;
                                    axes2_foto(c,d)=1;
                                end
                            end
                        end
                    end
                end
            end
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
            axes1_foto=axes2_foto;
        catch ME
            set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
        end
    case 'asinma'
        try
            se = logical(girilen);
            [p, q]=size(se);
            halfHeight = floor(p/2);
            halfWidth = floor(q/2);
            axes2_foto = zeros(size(axes1_foto), class(axes1_foto));
            for col = (halfWidth + 1) : (columns - halfWidth)
                for row = (halfHeight + 1) : (rows - halfHeight)
                    row1 = row-halfHeight;
                    row2 = row+halfHeight;
                    col1 = col-halfWidth;
                    col2 = col+halfWidth;
                    thisNeighborhood = axes1_foto(row1:row2, col1:col2);
                    pixelsInSE = thisNeighborhood(se);
                    axes2_foto(row, col) = min(pixelsInSE);
                end
            end
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
            axes1_foto=axes2_foto;
        catch ME
            set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
        end
    case 'acma'
        try
%             axes2_foto = imopen(axes1_foto, (girilen));
            for s=2:rows-2
                for t=2:columns-2
                    w1=[f(s-1,t-1)*girilen(1) f(s-1,t)*girilen(2) f(s-1,t+1)*girilen(3) f(s,t-1)*girilen(4) f(s,t)*girilen(5) f(s,t+1)*girilen(6) f(s+1,t-1)*girilen(7) f(s+1,t)*girilen(8) f(s+1,t+1)*girilen(9)];
                    p(s,t)=max(w1);
                end
            end
            
            [m,n]=size(p);
            for s=2:m-1
                for t=2:n-1
                    w1=[p(s-1,t-1)*girilen(1) p(s-1,t)*girilen(2) p(s-1,t+1)*girilen(3) p(s,t-1)*girilen(4) p(s,t)*girilen(5) p(s,t+1)*girilen(6) p(s+1,t-1)*girilen(7) p(s+1,t)*girilen(8) p(s+1,t+1)*girilen(9)];
                    axes2_foto(s,t)=min(w1);
                end
            end
            axes2_foto=uint8(axes2_foto);
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
        catch ME
            set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
        end
    case 'kapama'
        try
            axes2_foto=imclose(axes1_foto, girilen);
%             for s=2:rows-1
%                 for t=2:columns-1
%                     w12=[f(s-1,t-1)*girilen(1) f(s-1,t)*girilen(2) f(s-1,t+1)*girilen(3) f(s,t-1)*girilen(4) f(s,t)*girilen(5) f(s,t+1)*girilen(6) f(s+1,t-1)*girilen(7) f(s+1,t)*girilen(8) f(s+1,t+1)*girilen(9)];
%                     p(s,t)=min(w12);
%                 end
%             end
%             [r,c]=size(p);
%             for s=2:r-1
%                 for t=2:c-1
%                     w12=[p(s-1,t-1)*girilen(1) p(s-1,t)*girilen(2) p(s-1,t+1)*girilen(3) p(s,t-1)*girilen(4) p(s,t)*girilen(5) p(s,t+1)*girilen(6) p(s+1,t-1)*girilen(7) p(s+1,t)*girilen(8) p(s+1,t+1)*girilen(9)];
%                     axes2_foto(s,t)=min(w12);
%                 end
%             end
%             axes2_foto=uint8(axes2_foto);
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
            axes1_foto=axes2_foto;
        catch ME
            set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
        end
end
imshow(axes2_foto, 'Parent', handles.axes2);

function GirS_Callback(hObject, eventdata, handles)

global islemTuru;global axes1_foto;global axes2_foto;global bandSayisi;global tamyol;global dosya;
switch islemTuru
    case 'kayipliSVD'
        try
            singdeger=str2double(get(handles.SingVal,'string'));
            if ~floor(singdeger)==singdeger
                errorMessage = sprintf('Girilen deger tam sayi olmali');
                WarnUser(errorMessage);
                return
            end
            [~,~,bandSayisi]=size(axes1_foto);
            if bandSayisi==3
                if isa(axes1_foto(:,:,1),'uint8')
                    ch1 = double(axes1_foto(:,:,1));
                    ch2 = double(axes1_foto(:,:,2));
                    ch3 = double(axes1_foto(:,:,3));
                    [u,s,v] = svds(ch1, singdeger);
                    imch1 = uint8(u * s * transpose(v));
                    [u,s,v] = svds(ch2, singdeger);
                    imch2 = uint8(u * s * transpose(v));
                    [u,s,v] = svds(ch3, singdeger);
                    imch3 = uint8(u * s * transpose(v));
                    
                    FotoOut(:,:,1) = imch1;
                    FotoOut(:,:,2) = imch2;
                    FotoOut(:,:,3) = imch3;
                    imshow(FotoOut, 'Parent', handles.axes2);
                    
                elseif isa(axes1_foto(:,:,1),'uint16')
                    ch1 = double(axes1_foto(:,:,1));
                    ch2 = double(axes1_foto(:,:,2));
                    ch3 = double(axes1_foto(:,:,3));
                    
                    [u,s,v] = svds(ch1, singdeger);
                    imch1 = uint16(u * s * transpose(v));
                    
                    [u,s,v] = svds(ch2, singdeger);
                    imch2 = uint16(u * s * transpose(v));
                    
                    [u,s,v] = svds(ch3, singdeger);
                    imch3 = uint16(u * s * transpose(v));
                    
                    FotoOut(:,:,1) = imch1;
                    FotoOut(:,:,2) = imch2;
                    FotoOut(:,:,3) = imch3;
                    
                    imshow(FotoOut, 'Parent', handles.axes2);
                    
                    
                elseif isa(axes1_foto(:,:,1),'double')
                    ch1 = double(axes1_foto(:,:,1));
                    ch2 = double(axes1_foto(:,:,2));
                    ch3 = double(axes1_foto(:,:,3));
                    
                    [u,s,v] = svds(ch1, singdeger);
                    imch1 = (u * s * transpose(v));
                    
                    [u,s,v] = svds(ch2, singdeger);
                    imch2 = (u * s * transpose(v));
                    
                    [u,s,v] = svds(ch3, singdeger);
                    imch3 = (u * s * transpose(v));
                    
                    FotoOut(:,:,1) = imch1;
                    FotoOut(:,:,2) = imch2;
                    FotoOut(:,:,3) = imch3;
                    
                    imshow(FotoOut, 'Parent', handles.axes2);
                end
                
            elseif bandSayisi==1
                
                ddeger=double(axes1_foto);
                
                [u,s,v] = svds(ddeger, singdeger);
                
                if isa(axes1_foto,'uint8')
                    FotoOut = uint8(u * s * transpose(v));
                    
                elseif isa(axes1_foto,'uint16')
                    FotoOut = uint16(u * s * transpose(v));
                    
                    
                elseif isa(axes1_foto,'double')
                    FotoOut = (u * s * transpose(v));
                end
                imshow(FotoOut, 'Parent', handles.axes2);
            end
            axes2_foto=FotoOut;
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
        catch ME
            set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
        end
    case 'kayipliBTC'
        try
            bx=str2double(get(handles.Xblok,'string'));
            by=str2double(get(handles.Yblok,'string'));
            if ~floor(bx)==bx && ~floor(by)==by
                errorMessage = sprintf('Girilen deger tam sayi olmali');
                WarnUser(errorMessage);
                return
            end
            
            if bandSayisi==1
                
                ddeger = double(axes1_foto);
                dx=size(ddeger,1);
                dy=size(ddeger,2);
                modx=mod(dx,bx);
                mody=mod(dy,by);
                ddeger=ddeger(1:dx-modx,1:dy-mody);
                dx=dx-modx;
                dy=dy-mody;
                nbx=size(ddeger,1)/bx;
                nby=size(ddeger,2)/by;
                
                matrice=zeros(bx,by);
                m_u=zeros(nbx,nby);
                m_l=zeros(nbx,nby);
                mat_log=logical(zeros(bx,by));
                
                posbx=1;
                for ii=1:bx:dx
                    posby=1;
                    for jj=1:by:dy
                        blocco=ddeger(ii:ii+bx-1,jj:jj+by-1);
                        m=mean(mean(blocco));
                        blocco_binario=(blocco>=m);
                        K=sum(sum(double(blocco_binario)));
                        mu=sum(sum(double(blocco_binario).*blocco))/K;
                        if K==bx*by
                            ml=0;
                        else
                            ml=sum(sum(double(~blocco_binario).*blocco))/(bx*by-K);
                        end
                        m_u(posbx,posby)=mu;
                        m_l(posbx,posby)=ml;
                        mat_log(ii:ii+bx-1,jj:jj+by-1)=blocco_binario;
                        matrice(ii:ii+bx-1,jj:jj+by-1)=(double(blocco_binario).*mu)+(double(~blocco_binario).*ml);
                        posby=posby+1;
                    end
                    posbx=posbx+1;
                end
                if isa(axes1_foto,'uint8')
                    fotoOut=uint8(matrice);
                    
                    imshow(fotoOut, 'Parent', handles.axes2);
                    
                elseif isa(axes1_foto,'uint16')
                    fotoOut=uint16(matrice);
                    
                    imshow(fotoOut, 'Parent', handles.axes2);
                    
                elseif isa(axes1_foto,'double')
                    fotoOut=(matrice);
                    
                    imshow(fotoOut, 'Parent', handles.axes2);
                end
                
            elseif bandSayisi==3
                double_a=double(axes1_foto);
                ax=size(axes1_foto,1)-mod(size(axes1_foto,1),bx);
                ay=size(axes1_foto,2)-mod(size(axes1_foto,2),by);
                out_rgb=zeros(ax,ay,3);
                ddeger=double_a(:,:,1);
                
                
                dx=size(ddeger,1);
                dy=size(ddeger,2);
                modx=mod(dx,bx);
                mody=mod(dy,by);
                ddeger=ddeger(1:dx-modx,1:dy-mody);
                dx=dx-modx;
                dy=dy-mody;
                nbx=size(ddeger,1)/bx;
                nby=size(ddeger,2)/by;
                matrice=zeros(bx,by);
                m_u=zeros(nbx,nby);
                m_l=zeros(nbx,nby);
                mat_log=logical(zeros(bx,by));
                posbx=1;
                for ii=1:bx:dx
                    posby=1;
                    for jj=1:by:dy
                        blocco=ddeger(ii:ii+bx-1,jj:jj+by-1);
                        m=mean(mean(blocco));
                        blocco_binario=(blocco>=m);
                        K=sum(sum(double(blocco_binario)));
                        mu=sum(sum(double(blocco_binario).*blocco))/K;
                        if K==bx*by
                            ml=0;
                        else
                            ml=sum(sum(double(~blocco_binario).*blocco))/(bx*by-K);
                        end
                        m_u(posbx,posby)=mu;
                        m_l(posbx,posby)=ml;
                        mat_log(ii:ii+bx-1,jj:jj+by-1)=blocco_binario;
                        matrice(ii:ii+bx-1,jj:jj+by-1)=(double(blocco_binario).*mu)+(double(~blocco_binario).*ml);
                        posby=posby+1;
                    end
                    posbx=posbx+1;
                end
                out_rgb(:,:,1)=matrice;
                ddeger=double_a(:,:,2);
                dx=size(ddeger,1);
                dy=size(ddeger,2);
                modx=mod(dx,bx);
                mody=mod(dy,by);
                ddeger=ddeger(1:dx-modx,1:dy-mody);
                dx=dx-modx;
                dy=dy-mody;
                nbx=size(ddeger,1)/bx;
                nby=size(ddeger,2)/by;
                matrice=zeros(bx,by);
                m_u=zeros(nbx,nby);
                m_l=zeros(nbx,nby);
                mat_log=logical(zeros(bx,by));
                posbx=1;
                for ii=1:bx:dx
                    posby=1;
                    for jj=1:by:dy
                        blocco=ddeger(ii:ii+bx-1,jj:jj+by-1);
                        m=mean(mean(blocco));
                        blocco_binario=(blocco>=m);
                        K=sum(sum(double(blocco_binario)));
                        mu=sum(sum(double(blocco_binario).*blocco))/K;
                        if K==bx*by
                            ml=0;
                        else
                            ml=sum(sum(double(~blocco_binario).*blocco))/(bx*by-K);
                        end
                        m_u(posbx,posby)=mu;                            %---> m_u matrisi
                        m_l(posbx,posby)=ml;                            %---> m_l matrisi
                        mat_log(ii:ii+bx-1,jj:jj+by-1)=blocco_binario;  %---> logical matrisi
                        % sikisitirlmis foto
                        matrice(ii:ii+bx-1,jj:jj+by-1)=(double(blocco_binario).*mu)+(double(~blocco_binario).*ml);
                        posby=posby+1;
                    end
                    posbx=posbx+1;
                end
                out_rgb(:,:,2)=matrice;
                ddeger=double_a(:,:,3);
                
                
                dx=size(ddeger,1);
                dy=size(ddeger,2);
                modx=mod(dx,bx);
                mody=mod(dy,by);
                ddeger=ddeger(1:dx-modx,1:dy-mody);
                % boyutlar pixel
                dx=dx-modx;
                dy=dy-mody;
                % ful foto
                nbx=size(ddeger,1)/bx;
                nby=size(ddeger,2)/by;
                
                % output hazir foto
                matrice=zeros(bx,by);
                % data
                m_u=zeros(nbx,nby);
                m_l=zeros(nbx,nby);
                mat_log=logical(zeros(bx,by));
                
                posbx=1;
                for ii=1:bx:dx
                    posby=1;
                    for jj=1:by:dy
                        % blok
                        blocco=ddeger(ii:ii+bx-1,jj:jj+by-1);
                        % avg gray seviyesi
                        m=mean(mean(blocco));
                        % blogun logical matrisi
                        blocco_binario=(blocco>=m);
                        % gray seviyes avgden buyuk olan pixellerin sayisi
                        K=sum(sum(double(blocco_binario)));
                        % gray seviyes avgden ayni olan oixellerin sayisi
                        mu=sum(sum(double(blocco_binario).*blocco))/K;
                        % gray seviyes avgden kucuk olan oixellerin sayisi
                        if K==bx*by
                            ml=0;
                        else
                            ml=sum(sum(double(~blocco_binario).*blocco))/(bx*by-K);
                        end
                        % DATA
                        m_u(posbx,posby)=mu;
                        m_l(posbx,posby)=ml;
                        mat_log(ii:ii+bx-1,jj:jj+by-1)=blocco_binario;
                        % sikistirilmis foto
                        matrice(ii:ii+bx-1,jj:jj+by-1)=(double(blocco_binario).*mu)+(double(~blocco_binario).*ml);
                        posby=posby+1;
                    end
                    posbx=posbx+1;
                end
                out_rgb(:,:,3)=matrice;
                
                if isa(axes1_foto,'uint8')
                    fotoOut=uint8(out_rgb);
                    
                    imshow(fotoOut, 'Parent', handles.axes2);
                    
                elseif isa(axes1_foto,'uint16')
                    fotoOut=uint16(out_rgb);
                    
                    imshow(fotoOut, 'Parent', handles.axes2);
                    
                else
                    fotoOut=(out_rgb);
                    
                    imshow(fotoOut, 'Parent', handles.axes2);
                end
            end
            axes2_foto=fotoOut;
            set(handles.txtInfo,'string', 'Filtre Uygulandi');
        catch ME
            set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
            disp(ME);
            return;
        end
end
temp=strcat('asajd',dosya);
inf=imfinfo(tamyol);
set(handles.as,'string',num2str(inf.FileSize/1024));
imwrite(axes2_foto,temp);
inf=imfinfo(temp);
set(handles.sk,'string',num2str(inf.FileSize/1024));
delete(temp);

function reset_Callback(hObject, eventdata, handles)
global FotoAd;
global axes2_foto;
global axes1_foto;
global Foto;global tamyol;
global binsToSuppress;
binsToSuppress = [];
FotoAd ='';
axes2_foto = [];
axes1_foto = imread(tamyol);
Foto=[];
imshow(axes1_foto, 'Parent', handles.axes1);
sliderOF(handles, {'off','off','off'},{' ',' ',' '});
set(handles.PanelG,'visible','off');
set(handles.PanelS,'visible','off');
set(handles.PanelK,'visible','off');
set(handles.txtInfo,'string', '');
cla(handles.axes2);
clear;

function girK_Callback(hObject, eventdata, handles)
global axes1_foto;global axes2_foto;
try
    s=size(axes1_foto);
    r1=str2double(get(handles.r1,'string'));
    r2=str2double(get(handles.r2,'string'));
    if ~(r1>=0 && r1<=s(1)-1 && r2>=0 && r2<=s(1)-1 && r1<r2)
        errorMessage = sprintf('r degerlerini yanlis girdiniz r2>r1 ve iki degerin de 0 ile %d arasinda olmasi gerek',s(1)-1);
        WarnUser(errorMessage);
    else
        alpha_degree=str2double(get(handles.alphatxt,'string'));
        beta_degree=str2double(get(handles.betatxt,'string'));
        gamma_degree=str2double(get(handles.gamatxt,'string'));
        alpha=(alpha_degree*pi)/180;
        beta=(beta_degree*pi)/180;
        gamma=(gamma_degree*pi)/180;
        % çizgi gradyanlar?
        a1 = tan(alpha);
        a2 = tan(beta);
        a3 = tan(gamma);
        % Bolgelerde kontrast germe
        im1 = floor(a1*axes1_foto);
        im2 = floor(a1*r1 + (a2*(axes1_foto-r1)));
        im3 = floor(a2*r2+(a1-a2)*r1 + (a3*(axes1_foto-r2)));
        % Son foto birlestirme
        axes2_foto = cast(im1+im2+im3,'uint8');
        imshow(axes2_foto, 'Parent', handles.axes2);
        set(handles.txtInfo,'string', 'Filtre Uygulandi');
    end
catch ME
    set(handles.txtInfo,'string', 'Filtre Uygulanamadi');
end
%-------------------------------------------------------


%----------------------------------------------------------
%% ============Kontrol Fonksiyonlari===============
function sliderOF( handles, durum, metin)
if(isequal(durum{1},'on') ||isequal(durum{2},'on') || isequal(durum{3},'on'))
    set(handles.sliderGroup, 'visible', 'on');
else
    set(handles.sliderGroup, 'visible', 'off');
end
set(handles.slider_Min, 'visible',durum{1});
set(handles.edit_Min, 'visible',durum{1});
set(handles.text_Min, 'visible', durum{1});
set(handles.text_Min, 'String', metin{1});
set(handles.slider_Max, 'visible', durum{2});
set(handles.edit_Max, 'visible', durum{2});
set(handles.text_Max, 'visible', durum{2});
set(handles.text_Max, 'String', metin{2});
set(handles.slider_Sigma, 'visible', durum{3});
set(handles.edit_Sigma, 'visible', durum{3});
set(handles.text_Sigma, 'visible', durum{3});
set(handles.text_Sigma, 'String', metin{3});

return

function PanelS_Kontrol(handles, durum)
set(handles.PanelS,'visible',durum{1});
set(handles.Xblok,'visible',durum{2});
set(handles.Yblok,'visible',durum{3});
set(handles.SingVal,'visible',durum{4});
set(handles.GirS,'visible',durum{5});

function PanelG_Kontrol(handles, durum)
set(handles.PanelG,'visible',durum{1});
set(handles.uibuttongroup1,'visible',durum{2});
set(handles.uibuttongroup2,'visible',durum{3});
set(handles.yapi,'visible',durum{4});
set(handles.gir,'visible',durum{5});

function WarnUser(warningMessage)
fprintf('%s\n', warningMessage);
uiwait(warndlg(warningMessage));
return;

function msgboxw(in_strMessage)
uiwait(msgbox(in_strMessage));
return

function figMainWindow_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);
%-------------------------------------------------------


%------------------------------------------------------
%% ============Buton Grup Fonksiyonlari===============
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)
switch get(get(handles.uibuttongroup2,'SelectedObject'),'Tag')
    case 'secEksen'
        set(handles.yapi,'visible','off');
        set(handles.gir,'visible','off');
        set(handles.uibuttongroup1,'visible','on');
    case 'secOzel'
        set(handles.yapi,'visible','on');
        set(handles.gir,'visible','on');
        set(handles.uibuttongroup1,'visible','off');
end
set(handles.Xekseni,'Value',0);

function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
global axes2_foto;
global axes1_foto;
if ~isempty(axes2_foto)
    axes1_foto=axes2_foto;
end
switch get(get(handles.uibuttongroup1,'SelectedObject'),'Tag')
    case 'Xekseni'
        try
            A=im2bw(axes1_foto);
            B=[1 1 1 1 1 1 1;];
            C=padarray(A,[0 3]);
            axes2_foto=false(size(A));
            for i=1:size(C,1)
                for j=1:size(C,2)-6
                    axes2_foto(i,j)=sum(B&C(i,j:j+6));
                end
            end
            imshow(axes2_foto, 'Parent', handles.axes2);
        catch ME
            errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
                ME.stack(1).name, ME.stack(1).line, ME.message);
            WarnUser(errorMessage);
        end
    case 'Yekseni'
        try
            A=im2bw(axes1_foto);
            B2=getnhood(strel('line',7,90));
            m=floor(size(B2,1)/2);
            n=floor(size(B2,2)/2);
            C=padarray(A,[m n]);
            axes2_foto=false(size(A));
            for i=1:size(C,1)-(2*m)
                for j=1:size(C,2)-(2*n)
                    Temp=C(i:i+(2*m),j:j+(2*n));
                    axes2_foto(i,j)=max(max(Temp&B2));
                end
            end
            imshow(axes2_foto, 'Parent', handles.axes2);
        catch ME
            errorMessage = sprintf('Error fonkisyonunda %s() satirinda %d.\n\nError Mesaji:\n%s', ...
                ME.stack(1).name, ME.stack(1).line, ME.message);
            WarnUser(errorMessage);
        end
end
%-------------------------------------------------------


%-----------------------------------------------------
%% ============Create Fonksiyonlari===============
function slider_Sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function edit_Sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function slider10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function yapi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yapi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function SingVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SingVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Yblok_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Yblok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function alphatxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alphatxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function r2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function betatxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to betatxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function gamatxt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gamatxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function Xblok_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xblok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function PanelS_CreateFcn(hObject, eventdata, handles)
%-------------------------------------------------------


%-------------------------------------------------------
%% ============Callback Fonksiyonlari===============
function edit_Sigma_Callback(hObject, eventdata, handles)
function metin_CreateFcn(hObject, eventdata, handles)
function yapi_Callback(hObject, eventdata, handles)
function Xekseni_Callback(hObject, eventdata, handles)
function SingVal_Callback(hObject, eventdata, handles)
function Yblok_Callback(hObject, eventdata, handles)
function Xblok_Callback(hObject, eventdata, handles)
function alphatxt_Callback(hObject, eventdata, handles)
%-------------------------------------------------------
