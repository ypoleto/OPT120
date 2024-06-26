CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8;
USE `mydb`;
CREATE TABLE IF NOT EXISTS `usuario` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nome` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `senha` VARCHAR(45) NULL,
  UNIQUE INDEX `email_UNIQUE` (`email`)
);

CREATE TABLE IF NOT EXISTS `atividade` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `titulo` VARCHAR(255) NOT NULL,
  `desc` VARCHAR(255) NULL,
  `data` DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS `usuario_atividades` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `usuario_id` INT,
  `atividade_id` INT,
  `entrega` DATETIME NOT NULL,
  `nota` FLOAT NOT NULL,
  INDEX `idx_usuario_atividade_atividade_id` (`atividade_id`),
  INDEX `idx_usuario_atividade_usuario_id` (`usuario_id`),
  CONSTRAINT `fk_usuario_atividade_usuario_id` FOREIGN KEY (`usuario_id`)
    REFERENCES `usuario` (`id`),
  CONSTRAINT `fk_usuario_atividade_atividade_id` FOREIGN KEY (`atividade_id`)
    REFERENCES `atividade` (`id`)
);
