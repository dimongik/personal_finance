#Область ПрограммныйИнтерфейс

// Формирует документ бюджет по переданым параметрам.
// Параметры:
//	Параметры	- Структура - см. 
//	
Процедура ОтразитьИзмененияБюджета(Параметры) Экспорт
	
	ДокументБюджет 				= Документы.ОтражениеИзмененияВБюджете.СоздатьДокумент();
	ДокументБюджет.Дата 		= Параметры.ПериодОтражения;
	ДокументБюджет.ВидОтражения = Перечисления.ВидыОтраженийБюджета.План;
	ДокументБюджет.СтатьяЗатрат = Параметры.СтатьяЗатрат;
	Если Параметры.СуммаПлан > 0 Тогда
		ДокументБюджет.Сумма		= Параметры.СуммаПлан;
		ДокументБюджет.ВидОтражения	= Перечисления.ВидыОтраженийБюджета.План;
	КонецЕсли;
	Если Параметры.СуммаФакт > 0 Тогда
		ДокументБюджет.Сумма		= Параметры.СуммаФакт;
		ДокументБюджет.ВидОтражения	= Перечисления.ВидыОтраженийБюджета.Факт;
	КонецЕсли;
	Попытка
		ДокументБюджет.Записать(РежимЗаписиДокумента.Проведение);
	Исключение
		ОбщегоНазначения.СообщитьПользователю(ОписаниеОшибки());
	КонецПопытки;
	
КонецПроцедуры

// Расчитывает итоговые данные за указаный период
// 
// Параметры:
//  ДатаНачала 		- Дата
//  ДатаОкончания	- Дата
// 
// Возвращаемое значение:
// 	Структура - структура с итоговыми данными по бюджету:
//  	* Итого 			- Число
//   	* ИтогоПотрачено 	- Число 
//		* ИтогоОстаток		- Число
// 
Функция ИтоговыеДанныеЗаПериод(ДатаНачала, ДатаОкончания) Экспорт
	
	Данные = Новый Структура("ИтогоПотрачено,Итого,ИтогоОстаток", 0, 0, 0);
		
	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр("НачалоПериода", ДатаНачала);
	Запрос.УстановитьПараметр("ОкончаниеПериода", ДатаОкончания);
	Запрос.Текст = "ВЫБРАТЬ
	|	ВложенныйЗапрос.ИтогоПотрачено,
	|	ВложенныйЗапрос.Итого,
	|	ВложенныйЗапрос.Итого - ВложенныйЗапрос.ИтогоПотрачено КАК ИтогоОстаток
	|ИЗ
	|	(ВЫБРАТЬ
	|		СУММА(БюджетОбороты.ФактОборот) КАК ИтогоПотрачено,
	|		СУММА(БюджетОбороты.ПланОборот) КАК Итого
	|	ИЗ
	|		РегистрНакопления.Бюджет.Обороты(&НачалоПериода, &ОкончаниеПериода,,) КАК БюджетОбороты) КАК ВложенныйЗапрос";
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Если Выборка.Следующий() Тогда
		ЗаполнитьЗначенияСвойств(Данные, Выборка);
	КонецЕсли;
	
	Возврат Данные;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Формирует структуру с значениями по умолчанию для отражения данных по бюджету
// 
// Возвращаемое значение:
//	Структура	- Структура - Ключи:
//		*СтатьяЗатрат		- СправочникСсылка.СтатьиЗатрат
//		*ИмяДляРазработчика	- Строка
//		*СуммаПлан			- Число
//		*СуммаФакт			- Число
//		*ПериодОтражения	- Дата
//
Функция ИнициализироватьПараметрыОтраженияБюджета() Экспорт
	
	Результат = Новый Структура();
	Результат.Вставить("СтатьяЗатрат", Справочники.СтатьиЗатрат.ПустаяСсылка());
	Результат.Вставить("ИмяДляРазработчика", "");
	Результат.Вставить("СуммаПлан", 0);
	Результат.Вставить("СуммаФакт", 0);
	Результат.Вставить("ПериодОтражения", Дата(1, 1, 1));
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

//#Область СлужебныеПроцедурыИФункции
//// Код процедур и функций
//#КонецОбласти