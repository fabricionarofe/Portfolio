<?php
/**
 * Classe Database para gerenciar a conexão PDO com o MySQL.
 * Utiliza o padrão Singleton para evitar múltiplas conexões.
 */
class Database {
    private static $host = '127.0.0.1';
    private static $db_name = 'portfolio_cursos';
    private static $username = 'root'; // Ajuste conforme ambiente local
    private static $password = '';     // Ajuste conforme ambiente local
    private static $conn = null;

    /**
     * Retorna a conexão com o banco de dados.
     * @return PDO
     */
    public static function getConnection() {
        if (self::$conn === null) {
            try {
                // PDO oferece mais segurança (Prepared Statements) e abstração que o mysqli
                self::$conn = new PDO(
                    "mysql:host=" . self::$host . ";dbname=" . self::$db_name . ";charset=utf8mb4",
                    self::$username,
                    self::$password,
                    array(
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, // Lança exceções em erros SQL
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC // Retorna arrays associativos por padrão
                    )
                );
            } catch(PDOException $e) {
                // Em um ambiente real de produção, salvaríamos num arquivo de log.
                die("Erro de Conexão: " . $e->getMessage());
            }
        }
        return self::$conn;
    }
}
