<?php
require_once __DIR__ . '/../config/Database.php';

/**
 * Model Curso
 * Lida com a lógica de banco de dados (CRUD) da entidade Curso.
 */
class Curso {
    private $conn;
    private $table_name = "cursos";

    public $id;
    public $titulo;
    public $descricao;
    public $carga_horaria;
    public $status;
    public $data_criacao;

    public function __construct() {
        $this->conn = Database::getConnection();
    }

    /**
     * Retorna todos os cursos (READ).
     * @return array
     */
    public function readAll() {
        // Query preparada para maior segurança (mesmo sem parâmetros)
        $query = "SELECT * FROM " . $this->table_name . " ORDER BY id DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    /**
     * Retorna um único curso pelo ID.
     * @param int $id
     * @return array|false
     */
    public function readOne($id) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = :id LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetch();
    }

    /**
     * Insere um novo curso (CREATE).
     * @return bool
     */
    public function create() {
        $query = "INSERT INTO " . $this->table_name . " 
                  (titulo, descricao, carga_horaria, status) 
                  VALUES (:titulo, :descricao, :carga_horaria, :status)";

        $stmt = $this->conn->prepare($query);

        // Binding dos parâmetros (Previne SQL Injection via prepared statements)
        $stmt->bindParam(':titulo', $this->titulo);
        $stmt->bindParam(':descricao', $this->descricao);
        $stmt->bindParam(':carga_horaria', $this->carga_horaria, PDO::PARAM_INT);
        $stmt->bindParam(':status', $this->status);

        return $stmt->execute();
    }

    /**
     * Atualiza um curso existente (UPDATE).
     * @return bool
     */
    public function update() {
        $query = "UPDATE " . $this->table_name . " 
                  SET titulo = :titulo, descricao = :descricao, 
                      carga_horaria = :carga_horaria, status = :status
                  WHERE id = :id";

        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':titulo', $this->titulo);
        $stmt->bindParam(':descricao', $this->descricao);
        $stmt->bindParam(':carga_horaria', $this->carga_horaria, PDO::PARAM_INT);
        $stmt->bindParam(':status', $this->status);
        $stmt->bindParam(':id', $this->id, PDO::PARAM_INT);

        return $stmt->execute();
    }

    /**
     * Remove um curso (DELETE).
     * @return bool
     */
    public function delete() {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        
        $stmt->bindParam(':id', $this->id, PDO::PARAM_INT);

        return $stmt->execute();
    }
}
