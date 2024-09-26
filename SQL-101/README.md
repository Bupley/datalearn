# 22.09.24
Пройдено 2/3 от практического задания по разделу 2.  
Короткая справка по использованным командам:

### Обычные табличные выражения
 ```
 with january
as
	(select
		*
	from
		songify.plays
	where
		extract(month from play_date)=1)
```
Можно создать несколько таких табличных выраженйи подряд через запятую, для нового табличного выражения пропуская `WITH`. Они должны располагаться строго перед `SELECT` в основном запросе.
 
### Создание нового столбца с оператором `CASE`
```
SELECT 
		CASE
			WHEN medium ILIKE '%gold%' then 'gold'
			WHEN medium ILIKE '%silver%' then 'silver'
			ELSE NULL
			END AS metal,
		 count(id)
	FROM metropolitan.met
	GROUP BY metal
```
Этот оператор задает для условий после `WHEN` значения, расположенные после `THEN`.Эти значения располагаются в новом столбце, называющимся словом после `END AS` (в данном случае - `metal`)

### Поиск в значениях столбцов части слова с оператором `ILIKE`
```
WHERE date ILIKE '1600-%'
```
после `ILIKE` в одинарных кавычках указывается искомая комбинация. `%` - указывае на неопределенное количество симоволов, `_` указывает на 1 символ. Их можно ставить до, после, или между буквами или пробелами.

# 23.09.24
Пройдено практическое задание для раздела 2. 

Короткая справка по новым командам:
### Подзапросы 
Пишутся обычно после `WHERE` в круглых скобках.
```
WHERE 
	e.personality = (
		SELECT 
			personality
		FROM
			vr_startup.employees
		GROUP BY 
			personality
		ORDER BY
			count(employee_id) DESC
			LIMIT 1)
```
В данном случае, условием было, чтобы в поле `e.personality` содержались значения, полученные в результате выполнения подзапроса в скобках. То есть, в подзапросе должно быть только одно значение (не очень понятно, как он будет работать с несколькими значениями - для этого лучше пользоваться *обычными табличными выражениями*)

# 27.09.24
Начато прохождение [урока 21](https://www.youtube.com/watch?v=MK9hF9-FLFs&list=PLkcP_moW_BpOs4gO6SrPrvXu0sPcTyUyp&index=29), в котором идет речь про **оконные функции**.

### Пример использования функции`PARTITION BY`:
```
SELECT 
		 	*,
		 	max(gross_salary) OVER(PARTITION BY department) AS max_salary
		 FROM 
		 	windows_functions.salary
```
составые части:
- `PARTITION BY` - задается столбец, по которому будет проводиться группировка
- `OVER()` - открывается оконная функция

### Пример использования функции`FIRST_VALUE()`:

```
SELECT
 	s.*,
	FIRST_VALUE(s.first_name) OVER(PARTITION BY s.department ORDER BY s. gross_salary DESC) AS hi_emp
FROM 
 	windows_functions.salary AS s;
```
, где:
- `OVER()` - открывается оконная функция
- `PARTITION BY` - задается столбец, по которому будет проводиться группировка
- `ORDER BY` - задается столбец, по которому будет проводиться сортировка,
- `FIRST_VALUE()` - задается столбец, значение из которого будет выведено при нахождении наибольшего значения из группы, заданной в `PARTITION BY`

### Пример использования функции`LAST_VALUE()`:
```
SELECT
 	s.*,
	LAST_VALUE (s.first_name) OVER(PARTITION BY s.department ORDER BY s. gross_salary ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS low_emp
FROM 
 	windows_functions.salary AS s;
```
, где:
- `OVER()` - открывается оконная функция
- `PARTITION BY` - задается столбец, по которому будет проводиться группировка
- `ORDER BY` - задается столбец, по которому будет проводиться сортировка
- `ROWS BETWEEN **A** AND **B**` - задает строки, среди которых будет проводиться поиск наименьшего значения.  
Варианты для **A**:
	- `UNBOUNDED PRECEDING` - предыдущие строки, ограниченные группой `PARTITION BY`
	- `1 PRECEDING` - предыдущая одна строка
	- `CURRENT ROW` - текущая строка.
	
  Варианты для **B**:
	- `UNBOUNDED FOLLOWING` - предыдущие строки, ограниченные группой `PARTITION BY`
	- `1 FOLLOWING` - предыдущая одна строка
	- `CURRENT ROW` - текущая строка.
- `LAST_VALUE()` - задается столбец, значение из которого будет выведено при нахождении наименьшего значения из группы, заданной в `PARTITION BY` и ограниченной `ROWS BETWEEN`