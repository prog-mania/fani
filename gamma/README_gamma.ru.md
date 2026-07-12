## Описание
Программа Gamma.exe устанавливает яркость дисплея в соответствии с освещением.

## Подробнее
Программа Gamma написана на Delphi 7.<br>
Исходные тексты в этой папке в gamma_source.zip.<br>
Файл проекта gamma.dpr. Также есть уже скомпилированный и сжатый UPX файл gamma.exe.<br>
Для работы программы нужна поключённая Arduina с программой из файла gamma.ino
с припаянными к ней фоторезистором GL5516 между A5 и 5V и 10 кОм между A5 и GND.<br>
При компиляции на "Remove the declaration?" выбирать "No"<br>
В Project/Options/Directoties.../Search path записать Gamma\comPort\Source<br>
Driver для arduino nano: https://ftdichip.com/drivers/vcp-drivers/


###### Программа в разработке. Это не окончательный вариант.
