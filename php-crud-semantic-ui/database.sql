-- Criação do banco de dados e tabela para o sistema de gestão de cursos

CREATE DATABASE IF NOT EXISTS `portfolio_cursos` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `portfolio_cursos`;

CREATE TABLE IF NOT EXISTS `cursos` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `titulo` VARCHAR(255) NOT NULL,
  `descricao` TEXT,
  `carga_horaria` INT(11) NOT NULL,
  `status` ENUM('ativo', 'inativo') DEFAULT 'ativo',
  `data_criacao` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_status` (`status`) -- Demonstra conhecimento em otimização/índices
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Inserindo alguns dados de exemplo
INSERT INTO `cursos` (`titulo`, `descricao`, `carga_horaria`, `status`) VALUES
('Capacitação em Gestão Pública', 'Curso focado em eficiência no serviço público municipal.', 40, 'ativo'),
('Lógica de Programação para Servidores', 'Introdução ao pensamento computacional e automação.', 60, 'ativo'),
('Atendimento ao Cidadão', 'Melhores práticas no atendimento direto ao público.', 20, 'inativo');
