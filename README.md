#  Дипломная работа по профессии «Системный администратор»

Содержание
==========
* [Задача](#Задача)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)
    * [Дополнительно](#Дополнительно)
* [Выполнение работы](#Выполнение-работы)
* [Критерии сдачи](#Критерии-сдачи)
* [Как правильно задавать вопросы дипломному руководителю](#Как-правильно-задавать-вопросы-дипломному-руководителю) 

---------

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

Так как прерываемая ВМ проработает не больше 24ч, после сдачи работы на проверку свяжитесь с вашим дипломным руководителем и договоритесь запустить инфраструктуру к указанному времени.

**Продвинутый вариант:** Вместо создания обычной ВМ, создайте Instance Groups с прерываемыми ВМ. После остановки работы ВМ, Instance Groups автоматически их запустит. Подробности в  [инструкции](https://cloud.yandex.ru/docs/compute/concepts/instance-groups/). 

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и 
могут влиять друг на друга.

![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/1.png)

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.


***nginx утсновлен*** 
![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/vm1nginx.png)
![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/vm2nginx.png)

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/group.png)

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.
![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/back.png)

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.
![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/router.jpg)
Протестируйте сайт
`curl -v <публичный IP балансера>:80` 
![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/curll.jpg)

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 
![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/zabbix1.jpg)

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.
![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/zabbix2.png)


### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.
![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/elastic.jpg)
На nginxserver1 и nginxserver2 установлены filebeat.Заходим поочередно на сервера и настраиваем конфиг файл на отправку логов.

Так как одним из заданий была реализация концепции bastion host,то на сервера будем заходить через него. Пример доступа к nginxserver1 и nginxserver2
```
ssh dokukin@10.0.1.28
```
```
ssh dokukin@10.0.2.27 
```

```
sudo nano /etc/filebeat/filebeat.yml
```

вставляем ip elastic и ip kibana

```
sudo nano /etc/filebeat/modules.d/nginx.yml
```
 Заменить false на true в блоках error и access

```
sudo systemctl restart filebeat
```
```
sudo filebeat modules enable nginx
```
```
sudo filebeat setup
```
```
sudo filebeat -e 
```
******************************************************************************************************

![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/el1.jpg)
![img](https://github.com/Dokukin1/diplom-sys/blob/main/img/el2.jpg)


### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.
