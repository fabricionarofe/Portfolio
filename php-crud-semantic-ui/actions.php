<?php
session_start();

/**
 * Controller simplificado para receber requisições POST do frontend
 * e acionar a Model Curso.
 */
require_once 'classes/Curso.php';

// Apenas aceitamos POST para evitar ações via URL diretamente
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Validação de segurança CSRF (Cross-Site Request Forgery)
    if (!isset($_POST['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) {
        die("Erro de segurança: Token CSRF inválido.");
    }
    
    // Identificar a ação pretendida
    $action = isset($_POST['action']) ? $_POST['action'] : '';
    $curso = new Curso();

    switch ($action) {
        case 'create':
            $curso->titulo = $_POST['titulo'] ?? '';
            $curso->descricao = $_POST['descricao'] ?? '';
            $curso->carga_horaria = $_POST['carga_horaria'] ?? 0;
            $curso->status = $_POST['status'] ?? 'ativo';

            if ($curso->create()) {
                header("Location: index.php?msg=created");
                exit;
            } else {
                die("Erro ao criar o curso.");
            }
            break;

        case 'delete':
            $curso->id = $_POST['id'] ?? 0;
            
            if ($curso->id > 0 && $curso->delete()) {
                header("Location: index.php?msg=deleted");
                exit;
            } else {
                die("Erro ao deletar o curso ou ID inválido.");
            }
            break;
            
        // Ação de update omitida neste exemplo, 
        // mas a lógica seria similar populando as propriedades e chamando $curso->update()

        default:
            header("Location: index.php");
            exit;
    }
} else {
    // Redireciona acessos GET indevidos
    header("Location: index.php");
    exit;
}
