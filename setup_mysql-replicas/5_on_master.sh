## On the master server: 

  use mydatabase;
   create table user (id int);
   insert into user values (1);
   select * from user;


## On the replica server:
   use mydatabase;
   select * from user;

 

