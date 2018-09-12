file snake
set disassembly-flavor intel
# дизассемблировать блоки кода
disas main
disas fin
b main
run
# цикл пока счетчик команд меньше
# адреса метки fin
while $pc<fin
# показать текущую инструкцию
x/i $pc
# выполнить инструкцию
ni
# показать регистры
info registers
end
c
quit

