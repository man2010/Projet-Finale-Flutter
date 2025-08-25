<?php
    class Put {
        protected $pdo;

        public function __construct(\PDO $pdo){
            $this->pdo = $pdo;
        }

        public function updateTodo($d){
            $sql = "UPDATE todo_tables SET date = '$d->date', todo = '$d->todo ,done= $d->done' WHERE todo_id = '$d->todo_id'";

            
            $sql = $this->pdo->prepare($sql);

            #execute the query
			$sql->execute([]);

            #count affected rows
            $count = $sql->rowCount();

            if($count){
                return array("data"=>"Mise a jour reussie $count todo(s)");
            }
            else{
                return array("error"=>"Impossible");
            }
        }
    }
?>