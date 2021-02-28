#1.Создать VIEW на основе запросов, которые вы сделали в ДЗ к уроку 3(create or replace view ...). 1-го достаточно.

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `count_employees_by_depth_with_sum_salary` AS
    SELECT 
        `ds`.`dept_name` AS `Департамент`,
        COUNT(0) AS `кол-во сотрудников`,
        SUM(`s`.`salary`) AS `всего затрат`
    FROM
        (((`employees` `e`
        JOIN `salaries` `s` ON ((`s`.`emp_no` = `e`.`emp_no`)))
        JOIN `dept_emp` `de` ON ((`de`.`emp_no` = `e`.`emp_no`)))
        JOIN `departments` `ds` ON ((`ds`.`dept_no` = `de`.`dept_no`)))
    WHERE
        ((`de`.`to_date` = '9999-01-01')
            AND (`s`.`to_date` = '9999-01-01'))
    GROUP BY `ds`.`dept_name`;
    
/*2.Создать функцию, которая найдет табельный номер менеджера(у нас есть таблица менеджеров - dept_manager) 
по имени( или части) и фамилии(или части) или выдаст "0"- если его нет такого. (limit 1). 
Можно использовать функции ifnull(par1,par2), if(...)*/

CREATE DEFINER=`root`@`localhost` FUNCTION `get_manager_no`(first_name varchar(10), last_name varchar(20)) RETURNS int
    READS SQL DATA
BEGIN
	DECLARE result int;
    
		SET result = (SELECT e.emp_no FROM employees.dept_manager dm
		join employees e on dm.emp_no = e.emp_no
		where e.first_name like concat('%',first_name,'%') and e.last_name like concat('%',last_name,'%'));
        
	RETURN (IFNULL(result,0));
END

/*3.Создать триггер, который при добавлении нового сотрудника происходит в таблицу employees будет выплачивать ему 
вступительный бонус(1000 - допустим), занося запись об этом в таблицу salaries Может асбтрагироваться и для проставления 
полей дат использовать функцию curdate() . Это упростить задачу не будем думать на какой именно период мы 
выплачиваем этот бонус - главное это то, что в поля дат должны быть проставлены какие то данные(типа date).*/

CREATE 
    TRIGGER  welcome_bonus
 AFTER INSERT ON employees FOR EACH ROW 
    INSERT INTO salaries VALUES (new.emp_no , 1000 , CURDATE() , CURDATE());
