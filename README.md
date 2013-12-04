Установка
========

Для работы прототипа необходимо

1. NodeJS
2. MongoDB

После устанвки NodeJS выполнить
    
    npm install -g grunt-cli coffee-script
    
Из директории проекта выполнить

    npm install
    
Для создание базы данных
  
    coffee populate_fake.coffee create_base
    
Данна команда выведет id музея и контент-провайдера по умолчанию. Значения подставить в файл

    ./public/js/coffee/services.coffee
    
В месте объявления сервиса 'backendWrapper'


Затем выполнить команду
    
    coffee populate_fake.coffee create_museums

Для создания тестовых пустых музеев

Кроме прочего - обновить файл /routes/processing.coffee указав правильные значения в строках

    backend_url  = "http://prototype.izi.travel"
    backend_path = "/home/ubuntu/izi_backend_emulator/"
    
Если нужен LiveReload при изменениях в фале

    ./views.index.slim
    
Раскомментировать строку 

    script src="http://192.168.158.128:35729/livereload.js" 
    
И указать адрес сервера, на котором запускается прототип, обычно - localhost

Проект можно запускать:
  
    grunt build && grunt nodemon
    
Для компиляции ассетов и автоматической перезагрузки кода nodejs

Или  через

    grunt default
    
Для livereload и автоматической перекомпиляции ассетов при изменении
