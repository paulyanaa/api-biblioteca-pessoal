-- Tipo enum para status de leitura
CREATE TYPE statusLeitura AS ENUM ('Lido', 'Lendo', 'Não lido');

-- Tabela de status de leitura
CREATE TABLE status_Leitura(
    id SERIAL PRIMARY KEY,
    statusLeitura statusLeitura NOT NULL DEFAULT 'Não lido'
);

-- Tabela de empréstimos com nomePessoa
CREATE TABLE emprestimo(
    id SERIAL PRIMARY KEY,
    nomePessoa VARCHAR(255) NOT NULL,
    dataEmprestimo DATE NOT NULL DEFAULT CURRENT_DATE,
    dataDevolucao DATE
);

-- Tabela de livros
CREATE TABLE livro(
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(255) NOT NULL,
    capaurl TEXT,
    categoria VARCHAR(100),
    statusLeitura_id INTEGER NOT NULL REFERENCES status_leitura(id) DEFAULT 1,
    anotacoes VARCHAR,
    avaliacao NUMERIC(3,2) CHECK(avaliacao >= 0 AND avaliacao <= 5),
    emprestimo_id INTEGER REFERENCES emprestimo(id)
);

INSERT INTO status_leitura (statusLeitura)
VALUES 
  ('Lido'),
  ('Lendo'),
  ('Não lido');