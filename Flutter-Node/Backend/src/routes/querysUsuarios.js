const connection = require('../connection')

const getAllUsuarios = async () => {
    const [query] = await connection.execute('SELECT * FROM usuario')
    return query
}
const createUsuario = async (userData) => {
    try {
        const [result] = await connection.execute('INSERT INTO usuario (nome, email, senha) VALUES (?, ?, ?)', [userData.nome, userData.email, userData.senha]);
        return { id: result.insertId, ...userData };
    } catch (error) {
        throw new Error(`Erro ao criar usuário: ${error.message}`);
    }
}

const getUsuariosById = async (id) => {
    const [query] = await connection.execute('SELECT * FROM usuario WHERE id = ?', [id]);
    return query
}

const updateUsuario = async (userData) => {
   const item = await getUsuariosById(userData.id);
   if (item.length === 0) {
       throw new Error('Usuário não encontrado');
   }
   const [query] = await connection.execute('UPDATE usuario SET nome = ?, email = ?, senha = ? WHERE id =?', [userData.nome, userData.email, userData.senha, userData.id]);
   return query;
}
const deleteUsuario = async (id) => {
    const item = await getUsuariosById(id);
    if (item.length === 0) {
        throw new Error('Usuário não encontrado');
    }
    const [query] = await connection.execute('DELETE FROM usuario WHERE id = ?', [id]);
    return query
}





module.exports = { getAllUsuarios, createUsuario, getUsuariosById, updateUsuario, deleteUsuario }