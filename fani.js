// Анимация лица
var fani;
(function() {
"use strict";
///////////////// UTILS

const log=true;  // выводить console.log
const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
const gainNode = audioCtx.createGain();
var changeImg, saveImg, nameImg; // кнопки, надпись
var rx=[];       // результат функции find
var vol=0.3;     // Громкость речи
var bits=16;     // число бит на семпл звука
var freq=22050;  // частота
var played=false;// играется зкук
var startSoundTime; // время начала проигрывания звука
var source;         // звук
var scaleValue=30;  // значение TrackBar масштаб
var imageAuto=0, ito=null;// автоматически менять картинки через сек и timeOut
var adjust=true;    // показывать компоненты настроек: trackBar и др.
var error=false;    // ошибка недопустимая

// Разные полезные функции
function find(s,r) {rx=r.exec(s); return rx!=null}  // Поиск регулярного выражения r в строке s
function id(name)  {return document.getElementById(name)}
function l (s)     {if (log) console.log(s)}
function rand(min, max) {return Math.random() * (max - min + 0.001) + min;} // случайное число от min до max

function toNumberArray(name) { // Разбиваем строку по разделителям и отбрасываем пустые подстроки.
    let s=files[name];
    if (!s) {if (!error) alert('В файле files.js нет данных файла '+name); error=true; return [];}
    return s.split(/[ \r\n]+/).filter(s => s.length > 0).map(s => Number(s));
}

/**
 * Возвращает массив из q значений, плавно переходящих от v1 к v2.
 * Переход выполнен по сигмоидной функции (S-curve).
 *
 * @param {number} q  - количество значений (>=1)
 * @param {number} v1 - начальное значение
 * @param {number} v2 - конечное значение
 * @returns {number[]} массив из q float
 */
function spread(q, v1, v2) {
  if (v2==null) v2=v1;
  const result = [];

  // Небольшая защита от неверных входов
  if (q <= 1) {            // 0 или 1 точки - просто v1
    result.push(v1);
    return result;
  }

  // Степень крутизны сигмоиды (чем больше - тем «резче» переход)
  const k = 10; // можно менять, если хочется более/меньше плавности

  // Значения сигмоиды в точках t = 0 и t = 1
  const base = 1 / (1 + Math.exp(k / 2));
  const denom = 1 - 2 * base;

  for (let i = 0; i < q; i++) {
    const t = i / (q - 1);                         // нормированное t от 0 до 1

    // Сигмоидная функция Пѓ(t) = 1/(1+exp(-k*(t-0.5)))
    const sigma = 1 / (1 + Math.exp(-k * (t - 0.5)));

    // Нормируем к [0, 1] так, чтобы Пѓ(0)=0, Пѓ(1)=1
    const normalized = (sigma - base) / denom;

    // Масштабируем к диапазону [v1, v2]
    const value = v1 + (v2 - v1) * normalized;

    result.push(value);
  }
  return result;
}

/**
 * Создаёт контейнер-div с подписью справа и трек-баром (range-slider) слева.
 *
 * @param {Object} p               - Параметры для создания элемента.
 * @param {number} p.min           - Минимальное значение трек-бара.
 * @param {number} p.max           - Максимальное значение трек-бара.
 * @param {number} p.value         - Текущее (начальное) значение трек-бара.
 * @param {string} p.title         - Текст подписи, который будет слева от трек-бара.
 *
 * @returns {HTMLDivElement}       - Готовый контейнер <div>.
 */
function cTB(p) {
    //  Проверка входных параметров
    if (typeof p !== 'object' || p === null) {
        throw new TypeError('Argument "p" must be a non-null object');
    }

    const { min = 0, max = 100, value = 0, title = '', inputId=''} = p;

    // --- 2. Создаём корневой div -------------------------------------------
    const container = document.createElement('div');
    // позиционирование в абсолютном режиме
    container.style.position = 'absolute';
    // небольшие стили, чтобы элементы выглядели аккуратно
    container.style.display = adjust?'flex':'none';
    container.style.alignItems = 'center';
    container.style.gap = '8px';          // отступ между подписью и ползунком
    container.style.whiteSpace = 'nowrap';

    // --- 3. Создаём надпись -------------------------------------------------
    const label = document.createElement('label');
    label.textContent = title;
    label.style.fontFamily = 'Arial, sans-serif';
    label.style.fontSize = '14px';

    // --- 4. Создаём трек-бар (input type="range") ---------------------------
    const range = document.createElement('input');
    range.type = 'range';
    range.id = inputId;
    range.min = min;
    range.max = max;
    range.value = value;
    range.style.width='100px';
    // запрет клавишей
    range.addEventListener('keydown', function(event) {
            event.preventDefault(); // Запрещает стандартное действие клавиш
      //      event.stopPropagation(); // Предотвращает дальнейшее распространение события
    });
    range.style.outline='none';
    //range.setAttribute('tabindex', -1)

    // --- 5. Собираем всё в контейнер ----------------------------------------
    container.appendChild(range);
    container.appendChild(label);
    document.body.appendChild(container);
    container.addEventListener('change', e => {label.textContent=title+' '+range.value});

    // --- 6. Возвращаем готовый элемент ---------------------------------------
    return container;
}

/**
 * Создаёт контейнер-div с подписью справа и checkBox слева.
 *
 * @param {string} title         - Текст подписи, который будет слева от трек-бара.
 * @param {bool}   checked       - Галочка есть.
 *
 * @returns {HTMLDivElement}     - Готовый контейнер <div>.
 */
function cCB(title, checked=false) {
    // --- 1. Создаём корневой div -------------------------------------------
    const container = document.createElement('div');
    // позиционирование в абсолютном режиме
    container.style.position = 'absolute';
    // небольшие стили, чтобы элементы выглядели аккуратно
    container.style.display = adjust?'flex':'none';
    container.style.alignItems = 'center';
    container.style.gap = '8px';          // отступ между подписью и ползунком
    container.style.whiteSpace = 'nowrap';

    // --- 2. Создаём надпись -------------------------------------------------
    const label = document.createElement('label');
    // Чтобы label было привязано к input, задаём id
    const inputId = `trackbar-${Math.random().toString(36).substr(2, 9)}`;
    label.htmlFor = inputId;
    label.textContent = title;
    label.style.fontFamily = 'Arial, sans-serif';
    label.style.fontSize = '14px';

    // --- 3. Создаём checkBox (input type="checkbox") ---------------------------
    const cb = document.createElement('input');
    cb.type = 'checkbox';
    cb.checked = checked;

    // --- 4. Собираем всё в контейнер ----------------------------------------
    container.appendChild(cb);
    container.appendChild(label);
    container.checked=(c)=>{
        if (c) cb.checked=c=='Y'; // для установки checked из container
        return cb.checked};       // для получения checked из container
    document.body.appendChild(container);
    // --- 6. Возвращаем готовый элемент ---------------------------------------
    return container;
}

function cb(p) { // Создание кнопки
  var b=document.createElement('input');  b.type='button';  b.value=p.v;  b.onclick=p.f;
  if (p.id) b.id=p.id;
  b.style.cssText='position:absolute';
  document.body.appendChild(b)
  if (!adjust) b.style.display='none';
  return b
}
function cl(p) { // Создание надписи
  var s=document.createElement('span');
  s.textContent = p.t;
  s.style.cssText='position:absolute';
  document.body.appendChild(s);
  if (!adjust) s.style.display='none';
  return s
}
// Регуляторы:
var tbVol,tbI,tbX,tbZ,tbY,tbG,tbW,tbB,tbV,tbA,tbR,tbU,tbS,tbP,tbT,tbN,tbM,tbC,tbE, cbG,cbE,cbS,cbM,cbD,cbL;

function createUI() { // создание визуальных компонентов: trackBar, checkBox, button
    changeImg=cb({v:'Картинка', f:()=>{changeImage(null,+1)}})
    saveImg  =cb({v:'В JPG', f:canvasToJpg})
    nameImg  =cl({});
    tbVol=cTB({title:'Громкость', min:0, value:vol*100, inputId:'tbVolume'});
    tbI=cTB({title:'Менять',min:0,max:20, inputId:'tbImage'});
    tbX=cTB({title:'X',     min:- 60});
    tbZ=cTB({title:'Z',     min:-100});
    tbY=cTB({title:'Y',     min:-100});

    tbG=cTB({title:'Глаза', min:-60});
    tbW=cTB({title:'Взгляд',min:-100});

    tbB=cTB({title:'Брови', min:-100});
    tbV=cTB({title:'Наклон',min:-100});
    tbA=cTB({title:'Выше',  min:-100,max:50});

    tbR=cTB({title:'Рот',    min:-20 });
    tbU=cTB({title:'Улыбка', min:-80 });
    tbS=cTB({title:'Ширина', min:-100,max:60});

    tbP=cTB({title:'Плечи',  min:-100,max:1000});
    tbT=cTB({title:'Верх',   min:-100});
    tbN=cTB({title:'Низ',    min:-100});

    tbM=cTB({title:'масштаб',  min:0, value:scaleValue, inputId:'tbScale'});

    cbG=cCB('Говорить');       tbE=cTB({title:'Сила',     value:50});  cbE=cCB('Сервер');
    cbS=cCB('Шевелиться');     tbC=cTB({title:'Скорость', value:50});
    cbD=cCB('Дышать');
    cbL=cCB('Сетка');

// создание обработчиков изменений компонентов
    tbI.addEventListener  ('input', e => {imageAuto=e.target.value; startChangeImage()});
    tbVol.addEventListener('input', e => {vol=e.target.value/100; gainNode.gain.value = -1+vol});

    tbX.addEventListener('input', e => {startTB(); d.x_= e.target.value/100-d.x});
    tbY.addEventListener('input', e => {startTB(); d.y_=-e.target.value/100-d.y});
    tbZ.addEventListener('input', e => {startTB(); d.z_=-e.target.value/600-d.z});

    tbB.addEventListener('input', e => {startTB(); d.b_=-e.target.value/180-d.b});
    tbV.addEventListener('input', e => {startTB(); d.v_=-e.target.value/70 -d.v});
    tbA.addEventListener('input', e => {startTB(); d.a_=-e.target.value/300 -d.a});

    tbG.addEventListener('input', e => {startTB(); d.g_=-e.target.value/100-d.g});
    tbW.addEventListener('input', e => {startTB(); d.w_=-e.target.value/200-d.w});

    tbR.addEventListener('input', e => {startTB(); d.r_=-e.target.value/100-d.r});
    tbU.addEventListener('input', e => {startTB(); d.u_=-e.target.value/100-d.u});
    tbS.addEventListener('input', e => {startTB(); d.s_=-e.target.value/300-d.s});

    tbP.addEventListener('input', e => {startTB(); d.p_=-e.target.value/10000-d.p});
    tbT.addEventListener('input', e => {startTB(); d.t_=-e.target.value/200 -d.t});
    tbN.addEventListener('input', e => {startTB(); d.n_=-e.target.value/100 -d.n});

    tbM.addEventListener('input', e => {startTB(); scaleValue=e.target.value; d.m_=scaleValue/100-d.m});
    tbC.addEventListener('input', e => {let s=e.target.value/100-0.5; speed=s>0?(1+s*4):(0.5+s); startNewAnimation()});
    tbE.addEventListener('input', e => {let s=e.target.value/100-0.5; exp  =s>0?(1+s*2):(0.5+s);});
//    tbE.addEventListener('input', e => {startTB(); d.Y_=-e.target.value/100 -d.Y;});

    cbG.addEventListener('change', startVoice);
    cbS.addEventListener('change', e => {ani   =cbS.checked()});
    cbE.addEventListener('change', e => {server=cbE.checked()});
    cbD.addEventListener('change', changeBreath);
    cbL.addEventListener('change', e => {drawLines=cbL.checked(); changeImage(image)});
}

function resizeCanvas() { // расстановка видимых компонентов справа от canvas
   canvas.height = window.innerHeight;
   canvas.width = Math.round(canvas.height * wh);
   //console.log('wh='+wh+'   canvas.width,canvas.height='+canvas.width+','+canvas.height);
   // при изменении размеров нужно обновить viewport
   gl.viewport(0, 0, canvas.width, canvas.height);

   canvas.style.left='0px';
   nameImg.style.width='300px';
   saveImg.style.width='50px';

   let w10=canvas.width+10, l=w10, l2=l+120+'px', left=l+'px', w=128, t=8, r=22, p=20;

   changeImg.style.left = left;       changeImg.style.top =t+'px';
   saveImg.style.left   = l+90+'px';  saveImg.style.top   =t+'px';
   nameImg.style.left   = l+150+'px'; nameImg.style.top   =t+4+'px'; t+=p+6;

   tbI.style.left       = left;   tbI.style.top       =t+'px';   t+=r+p;

   tbVol.style.left=left; tbVol.style.top=t+'px'; t+=r+p;

   tbX.style.left=left; tbX.style.top=t+'px';  t+=r;
   tbY.style.left=left; tbY.style.top=t+'px';  t+=r;
   tbZ.style.left=left; tbZ.style.top=t+'px';  t+=r+p;

   tbB.style.left=left; tbB.style.top=t+'px';  t+=r;
   tbV.style.left=left; tbV.style.top=t+'px';  t+=r;
   tbA.style.left=left; tbA.style.top=t+'px';  t+=r+p;

   tbG.style.left=left; tbG.style.top=t+'px';  t+=r;
   tbW.style.left=left; tbW.style.top=t+'px';  t+=r+p;

   tbR.style.left=left; tbR.style.top=t+'px';  t+=r;
   tbU.style.left=left; tbU.style.top=t+'px';  t+=r;
   tbS.style.left=left; tbS.style.top=t+'px';  t+=r+p;

   tbP.style.left=left; tbP.style.top=t+'px';  t+=r;
   tbT.style.left=left; tbT.style.top=t+'px';  t+=r;
   tbN.style.left=left; tbN.style.top=t+'px';  t+=r+p;
   tbM.style.left=left; tbM.style.top=t+'px';  t+=r+p;

   cbG.style.left=left; cbG.style.top=t+'px';
   tbE.style.left=l+120+'px'; tbE.style.top=t+'px'; cbE.style.left=l+300+'px'; cbE.style.top=t+'px'; t+=r;

   cbS.style.left=left; cbS.style.top=t+'px';  tbC.style.left=l+120+'px'; tbC.style.top=t+'px'; t+=r;
   cbD.style.left=left; cbD.style.top=t+'px';  t+=r;
   cbL.style.left=left; cbL.style.top=t+'px';
}

// Загрузка данных для анимации

const FPS=25;    // число кадров в сек.
var drawLines=0  // рисовать границы треугольников
var images=[]    // имена файлов картинок
var backes=[]    // имена файлов фонов
var waves =[]    // имена файлов речи wav
var breathIn=[],breathOut=[], nWav; // имена файлов звуков дыхания
var wav;  // звук для воспроизведения в base64
var ni=0; // номер показанной картинки
var nb=0; // номер показанного фона
var image='image.jpg'; // показанная картинка
var back ='back.jpg';  // показанный фон
var vertices, vertices0, texI, indices; // координаты вершин и текстур, их индексы в треугольниках
var voice =false,ka; // произносится речь
var breath=false;    // дышит
var wl,hl;           // ширина и высота лица
var wh,whBack;       // w/h картинки, фона
var mB,mV,mG,mW,mR,mS,mU,mA,mX// морфы - массивы изменения вершин относительно размеров лица
//  Анимация
var ani=false; // анимация работает
var k1,kt, d={},q,kp,t,xc,rf,yc,y8,y33,x33,y69,y83;
var speed=1.0;     // скорость анимации  0.25-4
var exp=1.0;       // сила анимации при говорении
var tBreath, qBreath, sBreath=0, pBreath=0, pause; // дыхание номер кадра и стадия 0 пауза, вдох - 1, выдох - 4
var blink=[0,50,120,90,75,60,50,40,30,20,10,0], nBlink=0; // амплитуда мигания - закрытия глаз по кадрам
var trans=0; // вид прозрачности 0-нет, 1-зелёный цыет, 2-альфа

function extractNames() {
for (let name in files) // выделение имен картинок и звуков из имён в files
    if (find(name,/(^back.*\.(jpg|webp)$)/))    backes.push(rx[1]);    else
    if (find(name,/vertices-(.+?.(jpg|webp))/)) images.push(rx[1]);    else
    if (find(name,/(^speech.+wav$)/))    waves.push (rx[1]);    else
    if (find(name,/(^вдох.+wav$)/))      breathIn.push (rx[1]); else
    if (find(name,/(^выдох.+wav$)/))     breathOut.push(rx[1]);
}
// пересчет морфов из относительных в абсолютные по размеру лица т.к. они одинаковые для разных картонок
function norm(m) {for (let i=0; i<m.length;) {m[i++]*=wl; m[i++]*=hl}}

function filesToArrays() {  // загрузка файлов в массивы
    // X, Y,   U, V  (4 компонента у каждой вершины - координаты вершины -1..+1 и текстуры 0..1)
    vertices = new Float32Array(toNumberArray('vertices-'+image+'.txt'));
    indices  = new Uint16Array (toNumberArray('indices-' +image+'.txt'));
        texI=new Float32Array(vertices.length/2);
    let posI=new Float32Array(vertices.length/2);
    for (let i=0,j=0; i<vertices.length; i+=4, j+=2) {
         posI[j]=vertices[i];   posI[j+1]=vertices[i+1];
         texI[j]=vertices[i+2]; texI[j+1]=1-vertices[i+3];
    }
    vertices = posI.slice(0); // для анимации
    vertices0= posI.slice(0); // исходные координаты для анимации

    wl=Math.abs(vertices[16*2]-vertices[0]);            // ширина лица
    hl=Math.abs(vertices[8*2+1]-(vertices[19*2+1]+vertices[24*2+1])/2); // высота лица

    // загрузка морфов и нормализация
    mB   = new Float32Array(toNumberArray('брови.txt'));        norm(mB);
    mV   = new Float32Array(toNumberArray('брови наклон.txt')); norm(mV);

    mG   = new Float32Array(toNumberArray('глаза.txt'));        norm(mG);
    mW   = new Float32Array(toNumberArray('глаза взгляд.txt')); norm(mW);

    mR   = new Float32Array(toNumberArray('рот.txt'));          norm(mR);
    mS   = new Float32Array(toNumberArray('рот сжатие.txt'));   norm(mS);
    mU   = new Float32Array(toNumberArray('улыбка.txt'));       norm(mU);
    mA   = new Float32Array(toNumberArray('брови выше.txt'));   norm(mA);
    mX   = new Float32Array(toNumberArray('наклон.txt'));       norm(mX);
}


// параметры позы
d.z=0;   // текущее значение
d.z_=0;  // изменение значения
d.y=d.y_=d.x=d.x_=d.r=d.r_=d.w_=d.w=d.g=d.g_=d.b=d.b_=d.a=d.a_=d.v=d.v_=
d.u=d.u_=d.s=d.s_=d.p=d.p_=d.n=d.n_=d.t=d.t_=d.m=d.m_=d.d=d.d_=0;
d.X=d.X_=d.Y=d.Y_=0; // смещение головы

function writeIni() { // Сохранение настроек
  localStorage.setItem('fani', 'image='+image+';back='+back+
    ';Шевелиться='+cbS.checked()+';Говорить='+cbG.checked()+';Дышать='+cbD.checked()+';Громкость='+vol+
    ';Масштаб='+scaleValue+';'+';Менять='+imageAuto+';');
}

function readIni() { // Чтение настроек
   let fani=null;
   try {
       if (!localStorage) return;
       fani=localStorage.getItem('fani');
   } catch (error) {return}
   if (!fani) return;
   if (find(fani,/image=(.+?);/))     {ni=images.indexOf(rx[1]); if (ni<0||ni>images.length) ni=0; image=images[ni];}
   if (find(fani,/back=(.+?);/))      {nb=backes.indexOf(rx[1]); if (nb<0||nb>backes.length) nb=0; back =backes[nb];}
   if (find(fani,/Громкость=(.+?);/)) {vol=parseFloat(rx[1]); id('tbVolume').value=vol*100; gainNode.gain.value=-1+vol}
   if (find(fani,/Масштаб=(.+?);/))   {scaleValue=id('tbScale').value=parseInt(rx[1]); d.m=scaleValue/100;}
   if (find(fani,/Менять=(.+?);/))     imageAuto =id('tbImage').value=parseInt(rx[1]);
   if (find(fani,/Шевелиться=(.+?);/) && rx[1]=='true') {cbS.checked('Y'); ani=true; startNewAnimation()}
   if (find(fani,/Говорить=(.+?);/)   && rx[1]=='true')  cbG.checked('Y');
   if (find(fani,/Дышать=(.+?);/)     && rx[1]=='true') {cbD.checked('Y'); changeBreath()}
}

var text, nText=0,nWav=0; // номер произносимого предложения из text и waves
function extractText() {
   text = files['text.txt'];      // текст для разговоров
   if (!text) text=[]; else text
     .replace(/[\r\n«»#]+/gm,' ') // удалить не произносимое
     .replace(/([А-ЯЁ])/gm,'#$1') // пометка начал предложений
     .split('#')                  // разделение по предложениям
     .filter(s => s.length >= 4); // удаление пустых
}


// Инициализация webGL -----------------------------------

// Переменные для вывода webGL
var gl, backPosBuf, backTexBuf, backIdxBuf;
var imgPosBuf, imgTexBuf, imgIdxBuf,  pos,tex, indBack, canvas;
var u_trans,aPos,aTex,uTex;

function glBind() {// связь webGL с вершинами vertices и их индексами по треугольникам indices
//  Буферы для заднего плана (back)
    gl.bindBuffer(gl.ARRAY_BUFFER, backPosBuf);
    gl.bufferData(gl.ARRAY_BUFFER, pos, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, backTexBuf);
    gl.bufferData(gl.ARRAY_BUFFER, tex, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, backIdxBuf);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indBack, gl.STATIC_DRAW);

// Буферы для переднего изображения (front)
    gl.bindBuffer(gl.ARRAY_BUFFER, imgPosBuf);
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, imgTexBuf);
    gl.bufferData(gl.ARRAY_BUFFER, texI, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, imgIdxBuf);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);
}

function createTexture(gl){ // создание текстуры
    let tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    return tex
}

function ini3D() {
   canvas = document.createElement('canvas'); //document.getElementById('glcanvas');
   document.body.appendChild(canvas);
   gl     = canvas.getContext('webgl', {
     preserveDrawingBuffer: true,  // для сохранения картинки в файл
  // premultipliedAlpha: false,    // отключаем предумноженную прозрачность?
     alpha: false,                 // чтоб не был виден canvas при прозрачности https://webglfundamentals.org/webgl/lessons/ru/webgl-and-alpha.html
     antialias: true,              // опционально
   });
   if (!gl) alert('WebGL не поддерживается');

// ---------- 2. Шейдеры ----------
const vsSource = `
      attribute vec2 a_position;   // позиция вершины в NDC
      attribute vec2 a_texCoord;   // UV
      varying   vec2 v_texCoord;
      void main() {
          gl_Position = vec4(a_position, 0.0, 1.0);
          v_texCoord  = a_texCoord;
      }
`;

const fsSource = `
     precision mediump float;
     uniform   sampler2D u_texture;
     varying   vec2      v_texCoord;
     uniform   int       u_trans; // устанавливается в JS, 0-нет прозрачности
     void main() {
         vec4 col = texture2D(u_texture, v_texCoord);
         if (u_trans==2) {  // прозрачность альфа канал
             gl_FragColor = vec4(col.r, col.g, col.b, col.a); // col.a: 0-прозрачно, 1-не прозрачно
         }
         else
         if (u_trans==1) {  // прозрачность по зелёности
             float gb=col.g-col.b;
             float gr=col.g-col.r;
             float a;
             if (gb>0.3 && gr>0.3) a=0.0;  else
             if (gb+gr>0.1 && col.b+col.r<0.9) a=(gb+gr)*0.1; else a=1.0;
             if ((gb+gr)>0.1) col.g=col.g*0.7;
             gl_FragColor = vec4(col.r, col.g, col.b, a); // a: 0-прозрачно, 1-не прозрачно
         }
         else gl_FragColor=col; // нет прозрачности - back
     }
`;

// Компиляция программы шейдеров
function compile(src, type) {
    const sh = gl.createShader(type);
    gl.shaderSource(sh, src);
    gl.compileShader(sh);
    if (!gl.getShaderParameter(sh, gl.COMPILE_STATUS)) {
        console.error('Shader error:', gl.getShaderInfoLog(sh));
        gl.deleteShader(sh);
        return null;
    }
    return sh;
}

const program = gl.createProgram();

gl.attachShader(program, compile(vsSource, gl.VERTEX_SHADER));
gl.attachShader(program, compile(fsSource, gl.FRAGMENT_SHADER));
gl.linkProgram(program);

if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    console.error('Program link error:', gl.getProgramInfoLog(program));
}

gl.useProgram(program);
gl.uniform1i(u_trans, 0); // нет прозрачности

// переменные в шейдерах:
u_trans = gl.getUniformLocation(program, 'u_trans');
aPos    = gl.getAttribLocation(program,  'a_position');
aTex    = gl.getAttribLocation(program,  'a_texCoord');
uTex    = gl.getUniformLocation(program, 'u_texture');

// Для фона прямоугольник из двух треугольников
pos = new Float32Array([
  -1.0, -1.0,   // 0 - левый-нижний
   1.0, -1.0,   // 1 - правый-нижний
  -1.0,  1.0,   // 2 - левый-верхний
   1.0,  1.0    // 3 - правый-верхний
]);
tex = new Float32Array([     // UV-координаты (0-1)
   0.0, 1.0,
   1.0, 1.0,
   0.0, 0.0,
   1.0, 0.0 ]);

indBack = new Uint16Array([0,1,2, 2,1,3]); // Индексы, образующие два треугольника (0-1-2 и 2-1-3) для фона

backPosBuf = gl.createBuffer();
backTexBuf = gl.createBuffer();
backIdxBuf = gl.createBuffer();

imgPosBuf  = gl.createBuffer();
imgTexBuf  = gl.createBuffer();
imgIdxBuf  = gl.createBuffer();

glBind();
gl.enable(gl.BLEND); gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);// для полупрозрачности
}  //ini3D

// Текстуры из файлов из Base64 (files.js)
let textures = {};  // { back: WebGLTexture, front: WebGLTexture }
let loaded   = 0;     // сколько текстур уже загружено

function drawMesh(img1,indices,vertices,lines) {
// выдаёт canvas для создания текстуры возможно с линиями треугольников
// создаём off-screen canvas того же размера, что и исходное изображение
    const offCanvas = document.createElement('canvas');
    offCanvas.width  = img1.width;
    offCanvas.height = img1.height;
    const ctx = offCanvas.getContext('2d');
    // копируем исходное изображение
    ctx.drawImage(img1, 0, 0);
    const imageData = ctx.getImageData(0,0,1,1); // левый верхний угол зелёный или прозрачный?
    const red   = imageData.data[0];
    const green = imageData.data[1];
    const blue  = imageData.data[2];
    const alfa  = imageData.data[3];
    if (alfa==0) trans=2; else
    if (red<64 && green>232 && blue<64) trans=1; else trans=0;//l('trans='+trans+'  red='+red+'  green='+green+'  blue='+blue+'  alfa='+alfa);

    if (!lines) return offCanvas;

    // функция, переводящая координаты в NDC в пиксели canvas-а
    function ndcToPixel(xNdc, yNdc) {
        const x = (xNdc + 1) * 0.5 * offCanvas.width;
        const y = (1 - (yNdc + 1) * 0.5) * offCanvas.height; // Y-ось вниз
        return [x, y];
    }
    // Рисуем границы треугольников на изображении
    ctx.strokeStyle = 'blue';
    ctx.lineWidth   = 1;

    for (let i = 0; i < indices.length; i += 3) {
        const i0 = indices[i]   * 2;   // *2 - потому что в vertices 2 компоненты
        const i1 = indices[i+1] * 2;
        const i2 = indices[i+2] * 2;

        const p0 = ndcToPixel(vertices[i0],   vertices[i0+1]);
        const p1 = ndcToPixel(vertices[i1],   vertices[i1+1]);
        const p2 = ndcToPixel(vertices[i2],   vertices[i2+1]);

        ctx.beginPath();
        ctx.moveTo(p0[0], p0[1]);
        ctx.lineTo(p1[0], p1[1]);
        ctx.lineTo(p2[0], p2[1]);
        ctx.closePath();
        ctx.stroke();
    }
    return offCanvas;
}

function makeTexture(nameTex, nameImage) {// создание текстуры в textures из files[nameImage] в base64
   const img = new Image();
   img.onload = function () {
      textures[nameTex] = createTexture(gl);
      if (nameTex=='image') {
          gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, drawMesh(img,indices,vertices,drawLines));
          wh = img.width/img.height;
          resizeCanvas();
          nameImg.innerHTML=nameImage;
      }
      else gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
      if (nameTex=='back') {whBack = img.width/img.height; back=nameImage;}

      if (++loaded === 3) { // все текстуры готовы  -  запуск движения
         setInterval(render, 1000/FPS);
         setTimeout(startBlink, rand(1000,4000)); // запуск мигания
         setTimeout(startEyes,  rand(1000,4000)); // запуск движения глаз
         setTimeout(startDown,  rand(1000,4000)); // запуск движения низа
         startChangeImage()  // запуск смены картинки
         setTimeout(sendKey,1000);
      }
  };
  img.onerror = () => {loaded++;console.error('Не удалось загрузить изображение из files.js: '+nameTex+' - '+nameImage);}
  img.src = 'data:image/jpeg;base64,' + files[nameImage];
}

// Вспомогательные функции  для вывода webGL
function setAttrib(buffer, location, size) {
   gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
   gl.enableVertexAttribArray(location);
   gl.vertexAttribPointer(location, size, gl.FLOAT, false, 0, 0);
}

function drawPlane(posBuf, texBuf, idxBuf, texture, begin, size) {
   setAttrib(posBuf, aPos, 2); // установка позиций вершин   в шейдере
   setAttrib(texBuf, aTex, 2); // установка позиций текстуры в шейдере
   gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, idxBuf);
   gl.activeTexture(gl.TEXTURE0);
   gl.bindTexture(gl.TEXTURE_2D, texture);
   gl.uniform1i(uTex, 0);
   gl.drawElements(gl.TRIANGLES, size, gl.UNSIGNED_SHORT, begin*Uint16Array.BYTES_PER_ELEMENT);
}

// Вывод всего webGL
function drawScene() {
   gl.clearColor(1,1,1,1);
   gl.clear(gl.COLOR_BUFFER_BIT);

   if (trans && textures.back) {
   // Фон
      let w; // расширение viewport для фона, чтобы не искажался
      w=(whBack-wh)*canvas.height/2;
      gl.viewport(-w, 0, canvas.width+2*w, canvas.height);
      gl.uniform1i(u_trans, 0);
      drawPlane(backPosBuf, backTexBuf, backIdxBuf, textures.back, 0, indBack.length);
      gl.viewport(0, 0, canvas.width, canvas.height);
   }

   gl.uniform1i(u_trans, trans);
   // рот
   drawPlane(imgPosBuf, imgTexBuf, imgIdxBuf, textures.mouth, indices.length-6,6);
   // Передний слой - зелёные пиксели отбрасываются в фрагмент-шейдере
   drawPlane(imgPosBuf, imgTexBuf, imgIdxBuf, textures.image, 0,indices.length-6);
   if (trans) gl.uniform1i(u_trans, 0);
}

// Функции для картинки
function canvasToJpg() { // Сохранение картинки в файл через <a download>
    canvas.toBlob(function(blob) {
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `Fani-${image}-${Date.now()}.jpg`;
        a.click();
        URL.revokeObjectURL(url); // Очистка:
    }, 'image/jpeg', 0.9);
}

function changeImage(img=null, d=0) { // смена картинки
    ni+=d;
    if (ni<0) ni=images.length-1;
    if (ni>=images.length) ni=0;
    image=img||images[ni];
    filesToArrays();
    iniAni();
    loaded = 0;
    if (backes.length>0) {nb++; if (nb>=backes.length) nb=0; makeTexture('back', backes[nb]);}
    makeTexture('image', image);
    glBind();
    startChangeImage()
}

function startChangeImage() { // запуск смены картинки через время imageAuto из регулятора
    if (ito) clearTimeout(ito); ito=null;
    if (imageAuto>0) ito=setTimeout(changeImage, imageAuto*1000, null,+1)
}


//  АНИМАЦИЯ ---------------------------------

// параметры перехода позы
t=1;  // текущий кадр анимации
kp=0; // прошлое значение

function startTB(time=100) { // начало установки d за время time милиСек.
    kp=0; // прошлое значение
    t=1;  // текущий кадр анимации
    q=(time/FPS) | 0;
    d.x_=d.y_=d.z_=d.g_=d.w_= d.b_=d.v_=d.a_= d.r_=d.u_=d.s_=d.p_=d.n_=d.t_=d.m_=d.X_=d.Y_=0;
}

function startBlink() {// запуск мигания в случайное время
   nBlink=1; setTimeout(startBlink, rand(5000,10000)) // время между миганиями
}
var headX=[...spread(27,0,40),...spread(23,39,0),...spread(21,0,-40),...spread(17,-39,0)], nHeadX=0; // амплитуда движения головы по кадрам
var headY=[...spread(20,0,50),...spread(20,49,0),...spread(20,0,-50),...spread(20,-49,0)], nHeadY=0; // амплитуда движения головы по кадрам

var eyes=[0,10,20, ...spread(40,50), 20,10,0], nEyes=0, vEyes=0.01; // амплитуда движения глаз по кадрам
var down=[...spread(40,0,40), ...spread(40,40,-40), ...spread(40,-40,0)], nDown;// амплитуда движения низа  туловища по кадрам

function startEyes() {// запуск движения глаз в случайное время и силу
   vEyes=rand(-0.015,+0.015); // сила
   nEyes=1; setTimeout(startEyes, rand(6000,10000)) // время между движениями
}
function startTop() {// запуск движения Верха в случайное время
   nTop=1; setTimeout(startTop, rand(8000,16000)) // время между движениями
}
function startDown() {// запуск движения низа в случайное время
   nDown=1; setTimeout(startDown, rand(6000,10000)) // время между движениями
}

function startBreath(n,v,s) { // запуск звука дыхания номер n, силой v, состояние s
    nWav=n;
    const wBreath= files[breathIn[n]];
    playBase64(wBreath,vol*0.1);
    qBreath=wBreath.length/(bits==16?2:1)/(freq/FPS)*1.2;  // число кадров звука
    tBreath=1; pBreath=0;
    d.d_=v;
    sBreath=s;
    if (sBreath==1) d.r_=-0.4-d.r; else if (sBreath==4) d.r_=0-d.r;
}

function changeBreath() {
    stop();
    breath=cbD.checked();
    if (breath) voice=false; else startVoice();
    if (sto) {clearTimeout(sto); sto=null}
    sBreath=0
}

function startNewAnimation() {  // создание новой позы и запуск перехода в неё
    let s=voice? 60  : 60
    startTB(voice?  400 : rand(500,3000)/speed);
    if (!voice) {
        d.r_=rand(-s,s*0.2)/200-d.r;
        d.u_=rand(-s*1,5,s)/120-d.u;  // улыбка, не улыбка
        d.s_=rand(-s,s*2.5)/200-d.s;  // губы растянуты, сжаты
        d.y_=rand(-s,s)/ 80-d.y;
        d.t_=rand(-s,s)/ 80-d.t;
    }
    else d.u_=-d.u;

    let mt=scaleValue/100+rand(-0.01, +0.01); // изменение масштаба
    if (mt>1) mt=1; else if (mt<0) mt=0;
    d.m_=mt-d.m;

    d.x_=rand(-s,s*2) /100-d.x;
    d.v_=rand(-s/2, s)/ 60-d.v;
    d.b_=rand(-1,   1)*0.4-d.b;
    d.g_=rand(-0.5,0.07)-d.g; // глаза закрыты, открыты

    d.z_=rand(-s,s)/(voice? 800:800)-d.z;
    d.y_=rand(-s, s)/100-d.y;
    d.p_=rand(-1, 0)/(voice?60:20) -d.p;
}

function iniAni() {  // расчёт параметров анимации в начале и смене картинки
    y8=vertices0[8*2+1];    // подбородок
    y33=vertices0[33*2+1];  // нос Y
    x33=vertices0[33*2  ];  // нос X
    y69=vertices0[69*2+1];  // верх картинки
    y83=vertices0[83*2+1];  // низ подбородка
    xc=vertices0[8*2]//-0.5;  // xc,yc - центр поворота головы
    rf=y33-y8; yc=y8-rf;
}

function render() { // изменение координат точек в каждом кадре
    if (played) tna=(performance.now()-startSoundTime)/(1000/FPS) | 0// текущий кадр анимации речи
    voice=played && tna<qma;

    kt=t/q;  // расчеты параметров перехода в текущем кадре
    if (kt<=1) {// в новую позу переход не завершён
        kt=(1-(kt-1)**4)**4;   // для плавного начала и остановки в 0..1
        // другие (1-(x-1)  ^2)^2; Math.sin(Math.PI*(kt-0.5))/2+0.5; https://umath.ru/calc/graph/?&scale=0.5;2&func=(1-(x-1)%5E2)%5E2;
        k1=kt-kp;  // часть перехода в текущем кадре
        kp=kt;
        t++;
    }
    else { // кончился перехов в позу, запуск новой
        if (ani) startNewAnimation() // самостоятельное движение
        k1=0;
    }

// Расчёт текущих деформаций по нужным изменениям и их доли k1 в текущем кадре
    d.x+=d.x_ * k1; d.y+=d.y_ * k1; d.z+=d.z_ * k1;
    d.b+=d.b_ * k1; d.v+=d.v_ * k1; d.a+=d.a_ * k1;
    d.g+=d.g_ * k1; d.w+=d.w_ * k1;
    d.u+=d.u_ * k1;
    d.t+=d.t_ * k1; d.n+=d.n_ * k1;
    d.m+=d.m_ * k1; //d.X+=d.X_ * k1; d.Y+=d.Y_ * k1;
    if (ani) {
       if (nBlink) {d.g=-blink[nBlink++]*0.01;  if (nBlink >=blink.length) nBlink=0}
       if (nEyes)  {d.w=-eyes [nEyes++ ]*vEyes; if (nEyes  >=eyes.length ) nEyes=0}
       if (nDown)  {d.n=-down [nDown++ ]*0.01;  if (nDown  >=down.length ) nDown=0}
    }

    if (voice && !breath) {// выполняется произнесение голосом - деформация рта пропорционально громкости
        ka=ma[tna]/max;
        d.s+=( (ka-0.1)*1.4*exp -d.s)*0.4// сила скорость;
        d.x+=( ka*5   -d.x)*0.1 // голова
        d.p+=( ka*    -d.p)*0.02// плечи
        d.r+=(-ka*2*exp   -d.r)*0.5
        if (nHeadX>=headX.length) nHeadX=0; d.X=headX[nHeadX++]*0.003*exp; nHeadX++; nHeadX++
        if (nHeadY>=headY.length) nHeadY=0; d.Y=headY[nHeadY++]*0.003*exp; nHeadY++; nHeadY++
    }
    else {
        d.r+=d.r_ * k1;
        d.s+=d.s_ * k1;
        d.p+=d.p_ * k1;
    }

    let kon=vertices.length, v,v0,sx,sy, scale=1+d.m;
    const offsetY=y69*(1-scale);// смещение по вертикали, чтобы вверх картинки, т.е. лицо, был виден при любом масштабе
    const yp=yc*scale+offsetY;
    const cos=Math.cos(d.z);
    const sin=Math.sin(d.z);

    if (breath && !speech) { // дыхание --------------------
        if (sBreath==0) startBreath(rand(0,10)<6?0:rand(0,breathIn.length-1)|0, -0.6, 1);  // идёт вдох
        if (sBreath==3) startBreath(nWav, -(d.d-0.2), 4); // идёт выдох

        if (played) tBreath=(performance.now()-startSoundTime)/(1000/FPS)// текущий кадр анимации звука дыхания
        kt=tBreath/qBreath;     // расчеты параметров перехода в текущем кадре
        if (kt<=1 && played) {  // в новую позу переход не завершён
           kt=(1-(kt-1)**2)**2; // для плавного начала и остановки в 0..1
           k1=kt-pBreath;       // часть перехода в текущем кадре
           pBreath=kt;
           d.d+=d.d_ * k1;
           d.r+=d.r_ * k1;
        }
        else { // закончилась фаза дыхания со звуком
           if (sBreath==2 && --pause<=0) sBreath=3; // пауза закончилась, далее выдох
           if (sBreath==5 && --pause<=0) sBreath=0; // пауза закончилась, далее вдох
           if (sBreath==1) {pause=20; sBreath=2;}   // пауза в конце вдоха
           if (sBreath==4) {pause=50; sBreath=5;}   // пауза в конце выдоха
        }
    }

    if (d.r>0.2) d.r=0.2; // ограничение рта

// цикл по вершинам
    for (let i=0, i1=1, nt=1, x,y, x0,k; i<kon; i+=2,i1+=2, nt++) {
        x0=vertices0[i]*scale;
        x=x0;
        y=vertices0[i1]*scale+offsetY;

        sx=sy=0;               // смещение вершины накапливается по всем морфам
        if (d.y!=0 && (nt<=68 || nt==70 || nt>=92)) { // поворот вокруг оси y
            k=wl*0.6-Math.abs(x0-x33);  // близость к центру
            if (k>0) sx+=d.y*k/15;
            sx+=d.X*0.04; sy+=d.Y*0.02;  // голова смещение
        }

        if (nt<=68) {
           sx+=mB[i]*d.b; sy+=mB[i1]*d.b;  // брови
           sx+=mV[i]*d.v; sy+=mV[i1]*d.v;
           sx+=mA[i]*d.a; sy+=mA[i1]*d.a;

           sx+=mG[i]*d.g; sy+=mG[i1]*d.g;  // глаза
           sx+=mW[i]*d.w; sy+=mW[i1]*d.w;
        }

        sx+=mR[i]*d.r; sy+=mR[i1]*d.r;  // рот
        sx+=mU[i]*d.u; sy+=mU[i1]*d.u;
        sx+=mS[i]*d.s; sy+=mS[i1]*d.s;


        sy+=mX[i1]*d.x; // Наклон головы

        if (d.p!=0 && nt>=72 && nt<=79 && !breath) { // плечи вверх-вниз
            if (nt==78) {sy+=d.p; sx+=d.p*0.4;} else
            if (nt==79) {sy+=d.p; sx-=d.p*0.4;} else

            if (nt==76) {sy+=d.p*0.5; sx+=d.p*0.5;} else // края картинки
            if (nt==72) {sy+=d.p*0.5; sx-=d.p*0.5;}
        }

        if (d.n!=0 && (nt>=80 && nt<=82 || nt>=73 && nt<=75)) { // низ - бёдра
            sx+=d.n*0.05;
            if (nt==81) sy-=d.n*0.05; else
            if (nt==82) sy+=d.n*0.05;
        }
        if (d.t!=0 && nt>=77 && nt<=79) { // верх - плечи
            sx+=d.t*0.05;
            if (nt==78) sy-=d.t*0.05; else
            if (nt==79) sy+=d.t*0.05;
        }

        if (breath && nt>=77 && nt<=79) sy+=d.d/(nt==77?10:20); // дыхание

        x-=sx; y-=sy;
        if (d.z!=0 && y>=yp && nt!=76 && nt!=72 ) { // наклон вокруг оси z
            x=(x-xc) * cos - (y-yp) * sin/wh+xc;
            y=wh*(x-xc) * sin + (y-yp) * cos+yp;
        }

        vertices[i]=x; vertices[i1]=y;
    }

    // передача изменённых вершин в webGL
    gl.bindBuffer(gl.ARRAY_BUFFER, imgPosBuf);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
    drawScene();
}

// ЗВУК ------------------------------------------------------------

function stop() {if (played) source.stop(); played=false}
function startVoice() {
    stop();
    speech=cbG.checked();
    if (speech) {nWav=rand(0,waves.length)|0; startSpeech(); breath=false;}
    else {tna=qma; if (cbD.checked()) changeBreath()}
}

function baseToBinary(base64) {      // преобразование base64 в строку байтов кодов символов
    const binaryStr = atob(base64);  // atob - строка, где каждый символ = 1 байт
    freq=binaryStr.charCodeAt(25)*256+binaryStr.charCodeAt(24) // частота
    bits=binaryStr.charCodeAt(34)    // бит на сэмпл
    return binaryStr;
}

function getSample(wavBase64) {
// получает wav файл в формате base64 и выдаёт его отсчеты в массив int16 или int8
    const binaryStr=baseToBinary(wavBase64); // Декодируем строку Base64
    if (bits==8) {
       const wavBytes = new Int8Array(binaryStr.length-44);
       for (let i = 44; i < binaryStr.length; i++) wavBytes[i] = binaryStr.charCodeAt(i)-128;
       return wavBytes;
    }
// bits==16
    const wavBytes = new Uint8Array(binaryStr.length-44);
    for (let i = 44; i < binaryStr.length; i++) wavBytes[i] = binaryStr.charCodeAt(i);
    return new Int16Array(wavBytes.buffer)
}

function base64ToArrayBuffer(base64) {
   const byteCharacters = baseToBinary(base64);
   const byteNumbers = new Array(byteCharacters.length);
   for (let i = 0; i < byteCharacters.length; i++)
        byteNumbers[i] = byteCharacters.charCodeAt(i); // Получаем коды символов
   return new Uint8Array(byteNumbers);
}

function playBase64(wav,v=-1) { // запуск проигрывания wav в формате base64
    const byteArray = base64ToArrayBuffer(wav); // массив байт WAV-файла
    const arrayBuffer = new Uint8Array(byteArray).buffer;
    audioCtx.decodeAudioData(arrayBuffer, (audioBuffer) => {
       source = audioCtx.createBufferSource();       // Создание узла источника
       source.onended = function() {played=false}
       source.buffer = audioBuffer;
       source.connect(audioCtx.destination); // Подключение к динамикам
       source.connect( gainNode );
       gainNode.gain.value = -1+(v>=0?v:vol);
       gainNode.connect(audioCtx.destination)
       source.start(0); // Начало воспроизведения
       startSoundTime=performance.now()
       played=true
    },
    (error) => {console.error('Ошибка декодирования аудио:', error);}
  );
}

var ma=[], qma, tna, // массив средних громкостей в течении кадра,
    max, // максимальный уровень звука
    speech=false, // говорить самостоятельно и всё время
    server=false, // синтез речи на сервере
    sto=null;     //setTimeout(startSpeech
const SERVER_URL = 'http://127.0.0.1:8888/'; // куда отправляем запрос на синтез голоса
// сервер присылает файл звука типа wav в виде скрипта, который сразу выполняется:
// wav="содержимое wav в кодировке base64";

function startSpeech(say='') { // запуск речи из готовых файлов wav
  if (!speech && !say) return;
  breath=false;
  if (played)   {setTimeout(startSpeech, 2000); return} // подождать пока закончит говорить
  nHeadX=nHeadY=0;
  if (server)   spechFromServer(); else {
      if (nWav>=waves.length) nWav=0;
      if (say && find(say,/.wav$/)) wav=files[say]; else  wav=files[waves[nWav++]];
      if (!wav) return;
      playWav();
  }
  sto=setTimeout(startSpeech, rand(4000,8000))
}

function getNextText() {return text.length>0?text[nText++%text.length]:'Привет, мир!';}

function playWav() { // проигрывание звука из wav в base64 с анимацией
    const i16 = getSample(wav);
    const qsf=freq /FPS | 0;     //  l('число отсчетов на кадр='+qsf);
    let s=0, q=0, qa=0, v;
    max=qma=tna=0; ma=[];

    for (let i=0; i<i16.length; i++) {
        v=Math.abs(i16[i]);
        s+=v;
        if (v>max) max=v;
        if (++q==qsf) {ma.push(s/q); q=s=0;}
    }
    if (q>0)  ma.push(s/q);
    qma=ma.length;  // l('число кусочков отсчетов='+qma); l('максимум='+max);
    playBase64(wav, vol*rand(0.6,1.2));
}

function spechFromServer() { // говорить текст из text с синтезом голоса на сервере
    let txt='';
    while (txt.length<20) txt+=' '+getNextText();
    const script = document.createElement('script');
    script.src = SERVER_URL+'?t='+encodeURI(txt.trim())+'&s=xenia';
    script.onload = playWav;
    script.onerror = function() {
       cbE.checked('N'); cbG.checked('N'); server=speech=false;
       const e="Ошибка при загрузке скрипта из адреса "+SERVER_URL+
       '\nВозможно, не запущен voice_server.exe';
        alert(e);
    };
    document.head.appendChild(script);
}

function sendKey() {
  if (find(document.location.href,/^(http:\/\/.+?\/)/)) {
// запущено через сервер, нажимаем клавишу Enter из сервера, чтобы браузер играл звук
     let url=rx[1]+'?key=13&title='+document.title;
     let xmlHttp = new XMLHttpRequest();
     xmlHttp.open( "GET", url, false ); // false for synchronous request
     xmlHttp.send( null );
     cbG.checked('Y'); setTimeout(startVoice,1000)
 }
 else
 cbG.checked('N') // чтобы пользователь нажал
}

function addListener() { // добавка обработчиков событий
  document.addEventListener('keydown', (event)=>{ l('Нажата клавиша '+event.keyCode);
    switch (event.key) {
    case 'PageDown': changeImage(null,+1); break;
    case 'PageUp':   changeImage(null,-1); break;
    case 'h':        changeAdjust(!adjust);break;
    // Добавьте другие клавиши по мере необходимости
   }
  });

  window.addEventListener('resize', resizeCanvas);

 //addEventListener("beforeunload", writeIni); // для тестирования убрать
}
function changeAdjust(a) {// смена видимости регулировок
   if (gl && adjust!=a) {
     let v=a?'flex':'none';
     cbD.style.display=cbL.style.display=v
     const m=[changeImg,saveImg,nameImg,tbVol,tbI,tbX,tbZ,tbY,tbG,tbW,tbB,tbV,
              tbA,tbR,tbU,tbS,tbP,tbT,tbN,tbM,tbC,tbE, cbG,cbE,cbS,cbM];
     for (let i=0;i<m.length-1;i++) m[i].style.display=v;
   }
   adjust=a;
}

fani=function (p={}) { // загрузка всего и запуск анимации  из другой программы js
    //  Проверка входных параметров
   if (typeof p !== 'object' || p === null) throw new TypeError('Argument "p" must be a non-null object');

   if (p.adjust!=undefined) changeAdjust(p.adjust);
   if (!gl) {   //первый раз всё создаётся и присваивается
     createUI() // создание компонентов UI
     extractNames()
     extractText()
//   readIni(); // для тестирования убрать
     if (p.scale) {scaleValue=p.scale; d.m=scaleValue/100}
     image=p.image? p.image:images[ni];
     back =p.back ? p.back:backes[nb];
     if (!files[image] && images.length>0) image=images[0];
     if (!files[back]  && back.length  >0) back =backes[0];
     filesToArrays();
     ini3D();
     iniAni();
     makeTexture('back',   back);
     makeTexture('image',  image);
     makeTexture('mouth', 'mouth.jpg');
     addListener()
   }
   if (p.ani!=undefined) {ani=p.ani; cbS.checked(ani?'Y':'N')};
   if (p.say) startSpeech(p.say)
}
})();
