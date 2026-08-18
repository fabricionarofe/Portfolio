<?php
session_start();
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

require_once 'classes/Curso.php';

$curso = new Curso();
$todos_cursos = $curso->readAll();
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestão de Cursos - SEGEP (Portfólio Sênior)</title>
    <!-- Importando o CSS do Semantic UI -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.5.0/semantic.min.css">
    <style>
        body { background-color: #f4f4f4; padding-top: 40px; }
        .main.container { background-color: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    </style>
</head>
<body>

<div class="ui main container">
    <h2 class="ui header">
        <i class="graduation cap icon"></i>
        <div class="content">
            Gestão de Cursos de Capacitação
            <div class="sub header">Administração de cursos para servidores (Demonstração CRUD + PHP 7+ + Semantic UI)</div>
        </div>
    </h2>
    <div class="ui divider"></div>

    <!-- Botão Adicionar (Aciona Modal) -->
    <button class="ui primary button" onclick="$('.ui.modal.novo-curso').modal('show');">
        <i class="plus icon"></i> Novo Curso
    </button>

    <!-- Tabela de Listagem -->
    <table class="ui celled striped table mt-4">
        <thead>
            <tr>
                <th>ID</th>
                <th>Título</th>
                <th>Descrição</th>
                <th>Carga Horária</th>
                <th>Status</th>
                <th>Ações</th>
            </tr>
        </thead>
        <tbody>
            <?php if(count($todos_cursos) > 0): ?>
                <?php foreach($todos_cursos as $c): ?>
                <tr>
                    <td><?= htmlspecialchars($c['id']) ?></td>
                    <td><?= htmlspecialchars($c['titulo']) ?></td>
                    <td><?= htmlspecialchars($c['descricao']) ?></td>
                    <td><?= htmlspecialchars($c['carga_horaria']) ?>h</td>
                    <td>
                        <?php if($c['status'] == 'ativo'): ?>
                            <a class="ui green label">Ativo</a>
                        <?php else: ?>
                            <a class="ui red label">Inativo</a>
                        <?php endif; ?>
                    </td>
                    <td class="collapsing">
                        <!-- Formulário Inline para Excluir (Melhor prática do que GET) -->
                        <form action="actions.php" method="POST" onsubmit="return confirm('Tem certeza que deseja excluir?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?>">
                            <input type="hidden" name="id" value="<?= $c['id'] ?>">
                            <button type="submit" class="ui red small button"><i class="trash icon"></i></button>
                        </form>
                    </td>
                </tr>
                <?php endforeach; ?>
            <?php else: ?>
                <tr><td colspan="6" class="center aligned">Nenhum curso cadastrado.</td></tr>
            <?php endif; ?>
        </tbody>
    </table>
</div>

<!-- Modal Semantic UI para Novo Curso -->
<div class="ui modal novo-curso">
    <i class="close icon"></i>
    <div class="header">
        Cadastrar Novo Curso
    </div>
    <div class="content">
        <form class="ui form" action="actions.php" method="POST" id="form-curso">
            <input type="hidden" name="action" value="create">
            <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?>">
            <div class="field">
                <label>Título do Curso</label>
                <input type="text" name="titulo" placeholder="Ex: Gestão de Projetos" required>
            </div>
            <div class="field">
                <label>Descrição</label>
                <textarea name="descricao" rows="2" placeholder="Breve descrição do curso" required></textarea>
            </div>
            <div class="two fields">
                <div class="field">
                    <label>Carga Horária (horas)</label>
                    <input type="number" name="carga_horaria" placeholder="Ex: 40" required>
                </div>
                <div class="field">
                    <label>Status Inicial</label>
                    <select class="ui dropdown" name="status">
                        <option value="ativo">Ativo</option>
                        <option value="inativo">Inativo</option>
                    </select>
                </div>
            </div>
        </form>
    </div>
    <div class="actions">
        <div class="ui black deny button">
            Cancelar
        </div>
        <button type="submit" form="form-curso" class="ui positive right labeled icon button">
            Salvar Registro
            <i class="checkmark icon"></i>
        </button>
    </div>
</div>

<!-- JS do jQuery e Semantic UI -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.5.0/semantic.min.js"></script>
<script>
    // Inicialização de componentes do Semantic UI
    $(document).ready(function(){
        $('.ui.dropdown').dropdown();
    });
</script>
</body>
</html>
