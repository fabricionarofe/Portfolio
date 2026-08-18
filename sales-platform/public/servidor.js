const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const session = require('express-session');

const app = express();
const PORT = 3000;

// ----------------------------------------------------
// 1. CONFIGURAÇÃO DO BANCO DE DADOS (SQLITE)
// ----------------------------------------------------
const db = new sqlite3.Database('./banco.sqlite', (err) => {
    if (err) {
        console.error('❌ Erro ao abrir o banco de dados', err);
    } else {
        console.log('✅ Banco de dados SQLite conectado e pronto.');
        
        // db.serialize garante que os comandos rodem em fila (um espera o outro terminar)
        db.serialize(() => {
            // Cria a tabela de alunos se ela não existir
            db.run(`CREATE TABLE IF NOT EXISTS alunos (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT UNIQUE,
                senha TEXT
            )`);
            
            // Cria o SEU login de testes automaticamente (e-mail: admin@fa.com | senha: 123)
            db.run(`INSERT OR IGNORE INTO alunos (email, senha) VALUES ('admin@fa.com', '123')`);
        });
    }
});

// ----------------------------------------------------
// 2. CONFIGURAÇÕES DO SERVIDOR (SEGURANÇA E DADOS)
// ----------------------------------------------------
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Configura a sessão de login do usuário no navegador
app.use(session({
    secret : '[YOUR_KEY_HERE]',
    resave: false,
    saveUninitialized: false
}));

// ----------------------------------------------------
// 3. ROTAS DO SITE (VITRINE ABERTA)
// ----------------------------------------------------
// Libera o acesso para todas as páginas estáticas (imagens, fa_academy.html, etc)
app.use(express.static(__dirname));

// ----------------------------------------------------
// 4. TELA DE LOGIN
// ----------------------------------------------------
app.get('/login', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html lang="pt-BR"><head><meta charset="UTF-8"><title>Login - Área de Membros</title>
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600&family=Montserrat:wght@400&display=swap');
            body { font-family: 'Montserrat', sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; background: #FCF9F9; margin: 0;}
            .box { background: #FFF; padding: 50px 40px; border-radius: 8px; box-shadow: 0 15px 40px rgba(0,0,0,0.05); text-align: center; max-width: 400px; width: 90%; }
            h2 { font-family: 'Playfair Display', serif; color: #3A2E2B; margin-bottom: 30px; font-size: 2rem;}
            input { width: 100%; padding: 15px; margin-bottom: 20px; border: 1px solid #EAEAEA; border-radius: 4px; box-sizing: border-box; font-family: 'Montserrat', sans-serif;}
            button { width: 100%; padding: 15px; background: #3A2E2B; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 1rem; font-family: 'Montserrat', sans-serif; transition: 0.3s;}
            button:hover { background: #D49A89; }
        </style>
        </head><body>
        <div class="box">
            <h2>Acesso Restrito</h2>
            <form action="/login" method="POST">
                <input type="email" name="email" placeholder="E-mail de acesso" required>
                <input type="password" name="senha" placeholder="Sua senha" required>
                <button type="submit">Entrar no Curso</button>
            </form>
        </div>
        </body></html>
    `);
});

// Valida o e-mail e a senha digitados contra o Banco de Dados
app.post('/login', (req, res) => {
    const { email, senha } = req.body;
    
    db.get('SELECT * FROM alunos WHERE email = ? AND senha = ?', [email, senha], (err, row) => {
        if (row) {
            // Sucesso! Grava a sessão do navegador
            req.session.logado = true;
            req.session.email = row.email;
            res.redirect('/curso');
        } else {
            // Erro!
            res.send('<script>alert("E-mail ou senha incorretos!"); window.location.href="/login";</script>');
        }
    });
});

// ----------------------------------------------------
// 5. ÁREA DE MEMBROS (ROTA PROTEGIDA)
// ----------------------------------------------------
app.get('/curso', (req, res) => {
    // O servidor verifica: "Essa pessoa tem uma sessão válida de login?"
    if (req.session.logado) {
        // Manda o arquivo secreto do curso
        res.sendFile(path.join(__dirname, 'area_de_alunas.html'));
    } else {
        // Chuta o curioso de volta para a tela de login
        res.redirect('/login');
    }
});

// Inicia o Servidor
app.listen(PORT, () => {
    console.log(`\n🚀 SERVIDOR ONLINE!`);
    console.log(`Abra no seu navegador: http://[HOST_REMOVED]:${PORT}/login`);
});