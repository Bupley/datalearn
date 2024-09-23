select 
	*
from 
	magazine.subscriptions as s 
inner join 

	magazine.orders as o
	on
	o.subscription_id =s.subscription_id;

-- задание 1 и немного творчества
select 
	s.description,
	s.subsrciption_length,
	extract(day from o.purchase_date) as day,
	COUNT(o.order_id) as orders,
	COUNT(distinct (o.cistomer_id)) as customers,
	SUM(s.price_per_month) as income
	
from 
	magazine.subscriptions as s 
inner join 

	magazine.orders as o
	on
	o.subscription_id =s.subscription_id
where s.description = 'Fashion Magazine'
group by s.description, day, s.subsrciption_length
order by day, s.subsrciption_length;

--задание 2
select 
	s.description,
	s.price_per_month
from 
	magazine.subscriptions as s 
inner join 
	magazine.orders as o
	on
		o.subscription_id =s.subscription_id
where s.subsrciption_length = '12 months'

--задание 3 посчитать кол-во подписчиков на online издания
select 
	count(l.id)
from 
	magazine.online as l

--задание 4 посчитать кол-во пересекающихся подписчиков
	
select
	count (distinct (n.last_name))
from 
	magazine.newspaper as n
inner join 
	magazine.online as l
		on l.first_name=n.first_name or l.last_name=n.last_name

-- задание 5 left join
select 
	end_month-start_month as length,
	COUNT (id) 
from 
	magazine.newspaper
group by 
	length
order by 
	COUNT (id) desc

-- Урок 17 

select
	id,
	last_name
from 
	magazine.newspaper
union all
select
	last_name, 
	id
from 
	magazine.online
order by 1

 -- урок 18 
-- вывод через фул джойн

select 
	*
from 
	magazine.newspaper as n
full join
	magazine.online as o
on 
	o.id=n.id
where 
	o.id is null 
	or 
	n.id is null
-- вывод через юнион и ексепт
select 
	*
from 
	(select 
	*
	from 
	magazine.newspaper	
	except
	select 
	*
	from magazine.online) as only_np
union
select 
	*
from
	(select 
	*
	from 
	magazine.online	
	except
	select 
	*
	from magazine.newspaper) as only_on
	
-- джойны на 3 таблицы
	
select 
	c.customer_name,
	s.description
from 
	magazine.customers as c
left join
	magazine.orders as o
on
	c.customer_id = o.cistomer_id
left join
	magazine.subscriptions as s
on
	o.subscription_id = s.subscription_id

--интерсект
select
	first_name,
	last_name
from 
	magazine.newspaper
intersect
select
	last_name,
	first_name
from 
	magazine.online;
	
select 
	*
from 
	magazine.newspaper as n
inner join
	magazine.online as o
using (id)
 
-- урок 19
select 
	product_name,
	length(product_name)
from 
	public.orders_new
where 
	product_name like '%phone%'
order by 
	2 desc

-- оператор case
select 
	name,
	neighborhood,
	cuisine,
	reviev,
	price,
	health,
	case 
		when review > 4.5 then 'extraordinary'
		when review > 4.0 then 'excellent'
		when review > 3.0 then 'good'
		when review > 2 then 'fair'
		else 'poor'
	end as grade
from 
	public.nomnom

	--функции даты и времени
select 
	now():: date,
	now():: time

-- объединение строк
select
		field || ' '||"object"||' '||well
from
	public.gtm;


-- урок 20
--через иннерджойн
select 
	ds.first_name,
	ds.last_name,
	ds.id
from 
	public.DRAMA_students as ds
inner join 
	public.band_students
	using (id);
	
--через подзапрос
	select 
	ds.first_name,
	ds.last_name,
	ds.id
from 
	public.DRAMA_students as ds
where 
	ds.id 
 	in (
 	select
 		bs.id
 	from
 		public.band_students as bs
 	);
 	
 
 	select 
	*
from 
	public.band_students as bs
where 
	bs.grade 
 	in (
 	select
 		bs.grade
 	from
 		public.band_students as bs
 	where bs.id = 20
 	);
 	

  -- обычные табличные выражения
 with previos_query
  as
	  (select 
	  	customer_id,
	  	count(subscription_id)
	  from 
	  	public.orders
	  group by 
		customer_id)
 select 
 	*
 from  
 	previos_query as pq
 inner join 
 	public.customers as c
 	using(customer_id);
 	
 	--ПРОЕКТ 1
 --Давайте посмотрим, какие тарифные планы используют премиум-пользователи
 select 
 	pus.user_id,
 	pl.description
 from 
 	songify.premium_users as pus
 inner join
 	songify."plans"as pn
 on
 	pus.membership_plan_id = pn.id;
 
 --Давайте посмотрим названия песен, которые cлушает каждый пользователь
select 
	pl.user_id,
	pl.play_date,
	s.title
from 
 	songify.plays as pl
inner join
 	songify.songs as s
on
 	pl.song_id = s.id;
 
 --Какие пользователи не являются премиум-пользователями?
 select
 	us.first_name,
 	us.last_name
 from 
 	songify.users as us
 full outer join 
 	songify.premium_users as pus
 on 
 	pus.user_id = us.id
 where 
 	pus.user_id is null;
 	
--С помощью СTE найдите пользователей, которые слушали музыку в январе и феврале, а потом оставьте
--только тех пользователей, которые слушали музыку ТОЛЬКО в январе.
with january
as
	(select
		*
	from
		songify.plays
	where
		extract(month from play_date)=1),
february
as
	(select
		*
	from
		songify.plays
	where
		extract(month from play_date)=2)
select
	january.user_id
from
	january
left join
	february
using (user_id)
where february.song_id is null;

--Для каждого месяца в таблице months мы хотим знать, был ли каждый премиум-пользователь
--активным или удаленным (не продлевал свою подписку на сервис)

select
	m.months,
	pus.user_id,
	pus.purchase_date,
	pus.cancel_date,
	case	
		when pus.purchase_date <= m.months and pus.cancel_date >= m.months then 'active'
		when pus.purchase_date <= m.months and pus.cancel_date is null then 'active'
		--when extract (month from pus.purchase_date) <= extract (month from m.months) and extract (month from pus.cancel_date) >= extract (month from m.months) then 'active'
		--when extract (month from pus.purchase_date) <= extract (month from m.months) and pus.cancel_date is null then 'active'
		else 'inactive'
	end as status
from
	songify.premium_users as pus
cross join
	songify.months as m
order by
	pus.user_id,
	m.months ASC;
	
--Объедините таблицу songs и bonus_songs с помощью UNION и выберите все столбцы.
--Поскольку таблица songs очень большая, просто посмотрите на некий срез данных
--и выведите только 10 строк с помощью LIMIT.
SELECT 
	*
FROM 
	songify.songs
UNION
SELECT 
	*
FROM 
	songify.bonus_songs
LIMIT 10;

--Найти количество раз, которое была прослушана каждая песня,
--добавить дополнительную информацию из таблицs songs
WITH repeat AS 
	(SELECT 
		s.id,
		COUNT (pl.song_id) AS repeat_num
	FROM 
		songify.plays AS pl
	LEFT JOIN 
		songify.songs AS s
	ON 
		pl.song_id = s.id
	GROUP BY 
		s.id)
SELECT 
	songify.songs.*,
	repeat.repeat_num
FROM 
	repeat
FULL OUTER JOIN 
	songify.songs
USING (id);
	
--задание 2
CREATE SCHEMA IF NOT EXISTS metropolitan;

--Сколько произведений в коллекции американского декоративного искусства

SELECT 
	count(*)
FROM 
	metropolitan.met ;

--Подсчитайте количество произведений исскуства, в которых в category содержится слово 'celery' (сельдерей)

SELECT 
	count(DISTINCT(category))
FROM 
	metropolitan.met
WHERE
	category ILIKE '%celery%';
	
--Выведите title и medium самых старых произведений исскуств в коллекции
--минимальная дата
SELECT 
		min(date)
	FROM 
		metropolitan.met
		
SELECT 
	date,
	title,
	medium
FROM metropolitan.met
WHERE date LIKE '1600-%'
ORDER BY date ASC;

--Найдите 10 стран с наибольшим количеством предметов в коллекции
SELECT 
	country,
	count(id)
FROM 
	metropolitan.met
WHERE country IS NOT null
GROUP BY 
	country 
ORDER BY 
	count(id) DESC
LIMIT 
	10
	
--Найдите категории, в которых больше 100 произведений исскуства
SELECT 
	category,
	count(id)
FROM 
	metropolitan.met
GROUP BY 
	category
HAVING count(id)>100;

--Посчитаем количество произведений исскуства, которые сделаны из золота или серебра.

WITH silver AS 
	(SELECT 
	 	*
	FROM metropolitan.met
	WHERE medium='Silver'),

gold AS 
		(SELECT 
		 	*
		FROM metropolitan.met
		WHERE medium='Gold')

SELECT 
	m.medium,
	count(id)
FROM 
	metropolitan.met AS m
RIGHT OUTER JOIN 
	silver
USING (id)
GROUP BY 
	m.medium
UNION
SELECT 
	m.medium,
	count(id)
FROM 
	metropolitan.met AS m
RIGHT OUTER JOIN 
	gold
USING (id)
GROUP BY 
	m.medium

--вараинт полегче
SELECT 
	 medium,
	 count(id)
FROM metropolitan.met
WHERE medium IN ('Gold', 'Silver')
GROUP BY medium

--  а теперь нужны предметы, в состав которых сходит золото или серебро

WITH "silver-n-gold" AS 
	(SELECT 
		CASE
			WHEN medium ILIKE '%gold%' then 'gold'
			WHEN medium ILIKE '%silver%' then 'silver'
			ELSE NULL
			END AS metal,
		 count(id)
	FROM metropolitan.met
	GROUP BY metal)
 SELECT
  *
 FROM
 	"silver-n-gold"
 WHERE metal IS NOT NULL;
 
--Третий проект
 
CREATE SCHEMA IF NOT EXISTS VR_startup;

--Как зовут сотрудников, которые не выбрали проект?
SELECT 
	first_name,
	last_name
FROM 
	vr_startup.employees
WHERE 
	current_project IS NULL;
	
--Как называются проекты, которые не выбраны никем из сотрудников?
SELECT
	p.project_name
FROM 
	vr_startup.projects AS p
LEFT JOIN
	vr_startup.employees AS e
ON
	e.current_project=p.project_id
WHERE 
	e.current_project IS NULL
GROUP BY 
	p.project_name;

SELECT
	project_name
FROM 
	vr_startup.projects AS p
WHERE project_id NOT IN
	(SELECT
		current_project
	FROM 
		vr_startup.employees AS e
	WHERE
		current_project IS NOT NULL);
	
--Какой проект выбирают большинство сотрудников (укажите название)?

SELECT
	p.project_name,
	count(e.current_project) AS num
FROM
	vr_startup.projects AS p
INNER JOIN
	vr_startup.employees AS e
ON
	e.current_project=p.project_id
GROUP BY 
	p.project_name
ORDER BY
	num DESC
LIMIT 
	1;

--Какие проекты выбрали несколько сотрудников (то есть больше 1)?

SELECT
	p.project_name,
	count(e.employee_id) AS num
FROM
	vr_startup.employees AS e
INNER JOIN
	vr_startup.projects AS p
ON
	e.current_project=p.project_id
GROUP BY 
	p.project_name
HAVING
	count(e.employee_id) > 1;
	
 --На каждый проект нужно как минимум 2 разработчика. Сколько доступных проектных позиций для разработчиков?
--Достаточно ли у нас разработчиков для заполнения необходимых вакансий?

--количество незанятых вакансий на проектах
WITH devs AS
(SELECT 
	p.project_name,
	count(employee_id) AS num
FROM
	vr_startup.projects AS p
FULL OUTER JOIN
	vr_startup.employees AS e
ON 
	e.current_project=p.project_id
WHERE 
	e."position" = 'Developer'
GROUP BY
	p.project_name)
SELECT
	sum(CASE 
		WHEN devs.num IS NULL THEN 2
		ELSE 2-devs.num
	END) AS vacation
FROM
	vr_startup.projects AS p
LEFT OUTER JOIN
	devs
USING(project_name);

-- количество незанятых разрабов
SELECT
	count(employee_id)
FROM
	vr_startup.employees AS e
WHERE
	e."position" = 'Developer'
AND 
	current_project IS NULL;

--как в видео
SELECT
	(count(p.*)*2)
	-
(SELECT
	count(e.*)
FROM
	vr_startup.employees AS e
WHERE 
	"position" = 'Developer') AS have
	
FROM
	vr_startup.projects AS p;	
	
--Какая личность наиболее характерна для наших сотрудников?
SELECT 
		personality,
		count(employee_id)
	FROM
		vr_startup.employees
	GROUP BY 
		personality
	ORDER BY
		count(employee_id) DESC
		LIMIT 1;

--Какие названия проектов выбирают сотрудники с наиболее распространенным типом личности?
	

SELECT 
	p.project_name,
	count(e.employee_id)
FROM
	vr_startup.projects AS p
LEFT OUTER JOIN
	vr_startup.employees AS e
ON
	e.current_project=p.project_id
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
GROUP BY
	p.project_name;
	
--Найдите тип личности, наиболее представленный сотрудниками с выбранным проектом.
--Как зовут этих сотрудников, тип личности и названия проекта, который они выбрали?
	
 -- тип личности
WITH top_type AS
				(SELECT
					personality,
					count(employee_id)
				FROM
					vr_startup.employees AS e
				WHERE
					current_project IS NOT NULL
				GROUP BY 
					personality
				ORDER BY
					count(employee_id) DESC
				LIMIT 2)	
-- информция о них
SELECT 
	e.first_name,
	e.last_name,
	p.project_name,
	e.personality
FROM
	vr_startup.employees AS e
INNER JOIN
	vr_startup.projects AS p
ON 
	e.current_project=p.project_id
INNER JOIN
	top_type
USING (personality)

--Для каждого сотрудника укажите его имя, личность, названия любых выбранных ими проектов
--и количество несовместимых сотрудников.
		
		-- Тип личности			…не совместим с
-- 	INFP			ISFP, ESFP, ISTP, ESTP, ISFJ, ESFJ, ISTJ, ESTJ - ТЛ где есть S
-- 	ENFP			ISFP, ESFP, ISTP, ESTP, ISFJ, ESFJ, ISTJ, ESTJ - ТЛ где есть S
-- 	INFJ			ISFP, ESFP, ISTP, ESTP, ISFJ, ESFJ, ISTJ, ESTJ - ТЛ где есть S
-- 	ENFJ			      ESFP, ISTP, ESTP, ISFJ, ESFJ, ISTJ, ESTJ - ТЛ где есть S ex. ISFP
-- 	ISFP			INFP, ENFP, INFJ  - ТЛ где есть NF ex. ENFJ
-- 	ESFP			INFP, ENFP, INFJ, ENFJ - ТЛ где есть NF
-- 	ISTP			INFP, ENFP, INFJ, ENFJ - ТЛ где есть NF
-- 	ESTP			INFP, ENFP, INFJ, ENFJ - ТЛ где есть NF
-- 	ISFJ			INFP, ENFP, INFJ, ENFJ - ТЛ где есть NF
-- 	ESFJ			INFP, ENFP, INFJ, ENFJ - ТЛ где есть NF
-- 	ISTJ			INFP, ENFP, INFJ, ENFJ - ТЛ где есть NF
-- 	ESTJ			INFP, ENFP, INFJ, ENFJ - ТЛ где есть NF
	
	
	SELECT 
	e.first_name,
	e.personality,
	p.project_name,
	CASE
		WHEN e.personality='ENFJ' THEN 
									(SELECT
										count(*)
									FROM 
										vr_startup.employees
									WHERE 
										personality IN('ESFP', 'ISTP', 'ESTP', 'ISFJ', 'ESFJ', 'ISTJ', 'ESTJ'))
		WHEN e.personality LIKE '_NF_' THEN
									(SELECT
										count(*)
									FROM 
										vr_startup.employees
									WHERE 
										personality IN('ISFP', 'ESFP', 'ISTP', 'ESTP', 'ISFJ', 'ESFJ', 'ISTJ', 'ESTJ'))
		WHEN e.personality='ISFP' THEN
									(SELECT
										count(*)
									FROM 
										vr_startup.employees
									WHERE 
										personality IN('INFP', 'ENFP', 'INFJ'))	
		WHEN e.personality LIKE '_S__' THEN
									(SELECT
										count(*)
									FROM 
										vr_startup.employees
									WHERE 
										personality IN('INFP', 'ENFP', 'INFJ', 'ENFJ'))	
		ELSE 0
	END AS incomparable
FROM
	vr_startup.employees AS e
LEFT OUTER JOIN
	vr_startup.projects AS p
ON 
	e.current_project=p.project_id;
	
	
	
	
	
	
	
	
	
	
	
	