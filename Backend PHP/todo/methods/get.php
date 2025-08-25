<?php
    class Get{
        protected $pdo;

        public function __construct(\PDO $pdo){
            $this->pdo = $pdo;
        }

        public function getAllTodos($d){

           
            $data = [];

           
            $sql = "SELECT * FROM todo_tables WHERE account_id='$d->account_id'";

            
            if($res = $this->pdo->query($sql)->fetchAll()) {
                
                
                foreach ($res as $record) {
					array_push($data, $record);
				}

				return array("data"=>$data);
            }
            
            else {
             
                return array("error"=>"Pas de tache pour cet id");
            } 
        }
    }
?>