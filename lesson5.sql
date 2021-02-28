/* 1. Подумать, какие операции являются транзакционными, и написать несколько примеров с транзакционными запросами.
Предлагаю уволить человека из базы по табельному номеру. (у каждого есть должность 
в таблице titles - указать дату до какой он её занимает, каждый работает в каком то отделе - таблица dept_emp, 
и выплаты по каждому работнику лежат в таблице salaries - там тоже есть дата по какой мы понимаем до какой даты человек работал. 
Основная таблица employees - так и хранит данные о сотруднике) */

#из задания 3 урока 3
SET @target = 
	( select e.emp_no from employees e
		join salaries s on s.emp_no = e.emp_no
		join dept_emp de on de.emp_no = e.emp_no
		where de.to_date='9999-01-01'
		group by e.emp_no
		order by  max(s.salary) desc
		limit 1
	);
        
START TRANSACTION;
	update dept_emp set to_date = CURDATE() where emp_no = @target;
    update titles set to_date = CURDATE() where emp_no = @target and to_date = '9999-01-01';
    update salaries set to_date = CURDATE() where emp_no = @target and to_date = '9999-01-01';
    INSERT INTO salaries VALUES (@target , 1000 , CURDATE() , CURDATE());    
COMMIT;

/* *** Проанализировать несколько запросов с помощью EXPLAIN(есть графический вариант, есть вариант консольный). 
Можно проверить раннее используемые запросы. Добавить в запросы where по ограничению неуволенных работников 
или отделов, оценить как измениться ЦЕНА запроса. Запрос можно улучшить с помощью индекса. 
Но это надо делать с "умеренным" аппетитом. */

select ds.dept_name as 'Департамент', count(*) as 'кол-во сотрудников', sum(s.salary) as 'всего затрат' from employees e
join salaries s on s.emp_no = e.emp_no
join dept_emp de on de.emp_no = e.emp_no
join departments ds on ds.dept_no = de.dept_no
where de.to_date='9999-01-01' and s.to_date='9999-01-01'
group by ds.dept_name;  ## <-- here "full index scan". Cost hint: High - especially for large indexes

select ds.dept_name as 'Департамент', count(*) as 'кол-во сотрудников', sum(s.salary) as 'всего затрат' from employees e
join salaries s on s.emp_no = e.emp_no
join dept_emp de on de.emp_no = e.emp_no
join departments ds on ds.dept_no = de.dept_no
where (de.to_date='9999-01-01' and s.to_date='9999-01-01') 
and ds.dept_name = 'Customer Service' ## <-- here "Single Row(constant)" cost hint: very low cost
group by ds.dept_name;