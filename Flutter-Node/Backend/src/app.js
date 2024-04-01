const express = require('express');
const usuarios = require('./routes/usuarios');
const atividades = require('./routes/atividades');
const usuarioatividades = require('./routes/usuario-atividades');

const app = express();

app.use(express.json());

const port = 3000; 

app.use('/usuarios',usuarios);
app.use('/atividades',atividades);
app.use('/usuario-atividades',usuarioatividades);

app.listen(port, () => {
  console.log(`Servidor Express em execução na porta ${port}`);
});
