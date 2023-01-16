## ITInvent-SQL-Alert - реализация оповещений о истечении срока действия лицензий.

Описание некоторых таблиц: \
**BRANCHES** - Филиалы; \
**VENDORS** - Общие - Производители; \
**CI_TYPES** - Оборудование - Типы; \
**CI_MODELS** - Оборудование - Модели; \
**OWNERS** - Общие - Сотрудники; \
**USERS** - Общие - Пользователи (учетные записи); \
**CI_HISTORY** - история изменений в карточках (CH_USER, CH_DATE, CH_COMMENT, SERIAL_NO_OLD, SERIAL_NO_NEW, INV_NO_OLD, INV_NO_NEW).

Таблица, которая нас интересует - **ITEMS**. Содержимое столбцов: \
**DESCR** - Описание карточки; \
**ADDINFO** - Примечание (вкладка Дополнительно); \
**SERIAL_NO** - Серийный номер; \
**INV_NO** - Инвентарный номер; \
**LICENCE_DATE** - Лицензия До; \
**LICENCE_NO** - Порядковый номер лицензии; \
**LICENCE_MAX** - Общее количество лицензий; \
**CREATE_DATE** - дата создания (первая дата изменения в истории, т.е. добавления); \
**CH_DATE** - Дата Изменения (вкладка История); \
**CH_USER** - Изменил (вкладка История, имя пользователя); \
**PRODUCT_KEY** - Ключ продукта/Рег. имя; \
**ACTIVATION_CODE** - Код активации.

**Зависимые столбцы**: \
**CI_TYPE** - Номер 2, означает тип "Программы"; \
**TYPE_NO** - Название. Значение (39), которое ссылается на значене столбца **TYPE_NAME** (Adobe) в таблице **CI_TYPES** по такому же номеру стобца **TYPE_NO** (39) и фильтрует по номеру столбца **CI_TYPE** (2); \
**MODEL_NO** - Версия. Значение, которое ссылается на значене столбца **MODEL_NAME** в таблице **CI_MODELS** по такому же номеру стобца **MODEL_NO** и **TYPE_NO**.

### 1. Получение данных, для формирования таблицы, в которой содержится название и версия программы.
Отфильтровать таблицу **TYPE_NO** по номеру типа "Программы" (**CI_TYPE**), т.к. номера для тругих типов (оборудование, комплектующие и т.п.) повторяются и соот-но пересекаются:
` SELECT TYPE_NO,TYPE_NAME FROM ITINVENT.dbo.CI_TYPES where CI_TYPE like '2' `

Отфильтровать таблицу **CI_MODELS**:
` SELECT MODEL_NO,MODEL_NAME FROM ITINVENT.dbo.CI_MODELS where CI_TYPE like '2' `

Отфильтрвоать таблицу **ITEMS**, где отсутствует пустые значения в стобце **LICENCE_DATE**:
` SELECT LICENCE_DATE,ADDINFO,DESCR FROM ITINVENT.dbo.ITEMS where LICENCE_DATE IS NOT NULL `

### 2. Получение данных, для постобработки в powershell:
Выбираем модуль, я использую **System.Data.SqlClient**, который присутствует в классе .NET (не требует установки). Так же выбираем метод аутентификации, по умолчанию подключение к БД будет происходить из под доменной учетной записи, от которой запущен powershell (с применением **Integrated Security=True**), или, можно указать учетную запись в самом скрипте. Забираем две таблицы: **$db_type** и **$db_model**, при формировании итоговой таблицы **ITEMS** (переменная **$db_date**) удаляем время и подставляем значения из первых двух, заменив содержимое значений с помощью select.

Данные в ITInvent (которые используются в текущем примере):

![Image alt](https://github.com/Lifailon/ITInvent-SQL-Alert/blob/rsa/Screen/ITInvent.jpg)

> [ITInvent-SQL-Alert-Table.ps1](https://github.com/Lifailon/ITInvent-SQL-Alert/blob/rsa/Scripts-Public/ITInvent-SQL-Alert-Table.ps1) - вывести полученные данные в Out-GridView:

![Image alt](https://github.com/Lifailon/ITInvent-SQL-Alert/blob/rsa/Screen/Table.jpg)

### 3. Настраиваем оповещения.

За основу беру [метод оповещений из Excel](https://github.com/Lifailon/Excel-Date-Report), в данном случае будем осуществлять отправку в **Telegram**, применяется четыре триггерных значения: 30, 14, 7 и 3 дня (дата, на момент проверки: 17.01.2023).

![Image alt](https://github.com/Lifailon/ITInvent-SQL-Alert/blob/rsa/Screen/Telegram.jpg)

> Для проверки триггерных значений, можно использовать вывод в консоль: [ITInvent-SQL-Alert-Console.ps1](https://github.com/Lifailon/ITInvent-SQL-Alert/blob/rsa/Scripts-Public/ITInvent-SQL-Alert-Console.ps1).

![Image alt](https://github.com/Lifailon/ITInvent-SQL-Alert/blob/rsa/Screen/Console.jpg)
