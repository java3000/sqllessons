/*База данных «Страны и города мира»(бд geodata из второго урока):
1. Сделать запрос, в котором мы выберем все данные о городе – регион, 
страна(из трёх разных таблиц, объединяем эти таблицы, учитывая, 
что у нас есть города в которых ид_региона =NULL).*/

use geodata;
select co.title, r.title, ci.title  from _cities ci
left join _regions r on ci.region_id = r.region_id
left join _countries co on ci.country_id = co.country_id;

/*2.Выбрать все города из Московской области(Мы можем использовать функцию like или просто указать область, тут достаточно объединить две таблицы).
*/

select c.title from _cities c
join _regions r on c.region_id = r.region_id
where r.title like 'Московская%';

/*База данных «Сотрудники»(бд employees сотрудники не уволенные это те, которые в таблице dept_emp.to_date='9999-01-01'):
1. Выбрать среднюю зарплату по отделам(Применить группировку для связи отдела, 
подсчитываем среднюю зарплату по неуволенным сотрудникам, не забываем применять функции для округления round(),ceiling(),floor(),).*/

use employees;
select ds.dept_name as 'Департамент', round(avg(s.salary), 2) as 'Средняя зп' from departments ds
join dept_emp de on ds.dept_no = de.dept_no
join salaries s on s.emp_no = de.emp_no
group by ds.dept_name;

#2. Выбрать максимальную зарплату у сотрудника(сотрудник не должне быть уволен, так же применяется агрегатная функция group by).

select e.emp_no, max(s.salary) from employees e
join salaries s on s.emp_no = e.emp_no
join dept_emp de on de.emp_no = e.emp_no
where de.to_date='9999-01-01'
group by e.emp_no
order by  max(s.salary) desc;

/****3. Удалить одного сотрудника, у которого максимальная зарплата(Применение подзапросов обязательно, 
сотрудник должен быть не уволенным, и удалить мы должны одного сотрудника).*/

delete from employees where emp_no = 
(
	select x.emp_no from
	(
		select e.emp_no, max(s.salary) from employees e
		join salaries s on s.emp_no = e.emp_no
		join dept_emp de on de.emp_no = e.emp_no
		where de.to_date='9999-01-01'
		group by e.emp_no
        order by  max(s.salary) desc
	) x
    limit 1
);

#4. Посчитать количество сотрудников во всех отделах(Мы подсчитываем количество не уволенных сотрудников).

select ds.dept_name as 'Департамент', count(*) as 'кол-во сотрудников' from employees e
join dept_emp de on de.emp_no = e.emp_no
join departments ds on ds.dept_no = de.dept_no
where de.to_date='9999-01-01'
group by ds.dept_name;

/*5. Найти количество сотрудников в отделах и посмотреть, сколько всего денег получает отдел
(По не уволенным сотрудникам мы проводим статистику, и применяем функции для группировки данных. 
И берём за основу суммы выплат последнего периода salaries.to_date='9999-01-01'. 
Так как в salaries - лежат данные выплат по годам для сотрудника).*/

select ds.dept_name as 'Департамент', count(*) as 'кол-во сотрудников', sum(s.salary) as 'всего затрат' from employees e
join salaries s on s.emp_no = e.emp_no
join dept_emp de on de.emp_no = e.emp_no
join departments ds on ds.dept_no = de.dept_no
where de.to_date='9999-01-01' and s.to_date='9999-01-01'
group by ds.dept_name;